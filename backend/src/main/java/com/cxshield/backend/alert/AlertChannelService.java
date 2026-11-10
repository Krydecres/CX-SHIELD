package com.cxshield.backend.alert;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Function;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertRuleRow;
import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelsResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertTestResponse;
import com.cxshield.backend.alert.dto.AlertDtos.SaveAlertChannelRequest;
import com.cxshield.backend.common.ApiException;

/**
 * Cài kênh cảnh báo Telegram / Zalo / Email theo chi nhánh (E2.1 · D4-01).
 */
@Service
public class AlertChannelService {

	/** Ngưỡng mặc định: góp ý dưới 4 sao thì cảnh báo. */
	public static final int DEFAULT_THRESHOLD_STAR = 4;

	private static final String NO_PERMISSION = "Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được cấu hình kênh cảnh báo.";
	private static final Pattern BOT_TOKEN = Pattern.compile("^\\d{5,}:[A-Za-z0-9_-]{20,}$");
	private static final Pattern CHAT_ID = Pattern.compile("^(-?\\d{1,20}|@[A-Za-z0-9_]{5,32})$");
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

	private final AccountRepository accountRepository;
	private final AlertChannelRepository channelRepository;
	private final WebhookUrlValidator urlValidator;
	private final Map<AlertChannelType, AlertSender> senders;
	private final Clock clock;

	@Autowired
	public AlertChannelService(AccountRepository accountRepository, AlertChannelRepository channelRepository,
			WebhookUrlValidator urlValidator, List<AlertSender> senders) {
		this(accountRepository, channelRepository, urlValidator, senders, Clock.systemUTC());
	}

	AlertChannelService(AccountRepository accountRepository, AlertChannelRepository channelRepository,
			WebhookUrlValidator urlValidator, List<AlertSender> senders, Clock clock) {
		this.accountRepository = accountRepository;
		this.channelRepository = channelRepository;
		this.urlValidator = urlValidator;
		this.senders = senders.stream().collect(Collectors.toMap(AlertSender::type, Function.identity()));
		this.clock = clock;
	}

	public AlertChannelsResponse getChannels(String token, UUID branchId) {
		BranchRow branch = requireBranch(token, branchId);
		Map<AlertChannelType, AlertChannelRow> saved = channelRepository.findChannels(token, branchId)
			.stream()
			.collect(Collectors.toMap(AlertChannelRow::type, Function.identity()));
		List<AlertChannelResponse> channels = new ArrayList<>();
		Arrays.stream(AlertChannelType.values())
			.forEach(type -> channels.add(saved.containsKey(type) ? toResponse(saved.get(type)) : notConfigured(type)));
		int threshold = channelRepository.findLowRatingRule(token, branchId)
			.map(AlertRuleRow::thresholdStar)
			.orElse(DEFAULT_THRESHOLD_STAR);
		return new AlertChannelsResponse(branch.id(), branch.name(), threshold, channels);
	}

	public AlertChannelResponse save(String token, UUID branchId, AlertChannelType type, SaveAlertChannelRequest request) {
		BranchRow branch = requireBranch(token, branchId);
		Optional<AlertChannelRow> existing = channelRepository.findChannel(token, branchId, type);
		Map<String, Object> values = validatedValues(type, request, existing.orElse(null));
		values.put("is_enabled", request.enabled());

		AlertChannelRow saved;
		if (existing.isPresent()) {
			saved = channelRepository.updateChannel(token, existing.get().id(), values)
				.orElseThrow(() -> ApiException.forbidden(NO_PERMISSION));
		}
		else {
			values.put("business_id", branch.businessId());
			values.put("branch_id", branchId);
			values.put("type", type.name());
			saved = channelRepository.insertChannel(token, values).orElseThrow(() -> ApiException.forbidden(NO_PERMISSION));
		}
		return toResponse(saved);
	}

	/**
	 * Gửi tin mẫu theo cấu hình đã lưu. Gửi lỗi trả về success = false thay vì lỗi HTTP để giao diện hiện đúng lý do.
	 */
	public AlertTestResponse sendTest(String token, UUID branchId, AlertChannelType type) {
		BranchRow branch = requireBranch(token, branchId);
		AlertChannelRow channel = channelRepository.findChannel(token, branchId, type)
			.orElseThrow(() -> ApiException.notFound("ALERT_CHANNEL_NOT_FOUND", "Hãy lưu cấu hình kênh trước khi gửi thử."));
		try {
			senders.get(type).send(channel, AlertMessages.TEST_SUBJECT, AlertMessages.testMessage(branch.name()));
		}
		catch (AlertSendException ex) {
			return new AlertTestResponse(false, ex.getMessage(), channel.lastTestedAt());
		}
		OffsetDateTime now = OffsetDateTime.now(clock);
		channelRepository.updateChannel(token, channel.id(), Map.of("last_tested_at", now.toString()))
			.orElseThrow(() -> ApiException.forbidden(NO_PERMISSION));
		return new AlertTestResponse(true, "Đã gửi tin thử thành công.", now);
	}

	private Map<String, Object> validatedValues(AlertChannelType type, SaveAlertChannelRequest request, AlertChannelRow existing) {
		Map<String, Object> values = new LinkedHashMap<>();
		switch (type) {
			case TELEGRAM -> {
				String botToken = trimmed(request.botToken());
				if (botToken != null) {
					requireMatch(BOT_TOKEN, botToken, "INVALID_BOT_TOKEN", "Bot Token không đúng định dạng.");
					values.put("bot_token", botToken);
				}
				else if (existing == null || existing.botToken() == null) {
					throw ApiException.unprocessable("INVALID_BOT_TOKEN", "Vui lòng nhập Bot Token.");
				}
				String chatId = trimmed(request.chatId());
				if (chatId == null) {
					throw ApiException.unprocessable("INVALID_CHAT_ID", "Vui lòng nhập Chat ID.");
				}
				requireMatch(CHAT_ID, chatId, "INVALID_CHAT_ID", "Chat ID không đúng định dạng.");
				values.put("chat_id", chatId);
			}
			case ZALO -> {
				String webhookUrl = trimmed(request.webhookUrl());
				if (webhookUrl != null) {
					urlValidator.validate(webhookUrl);
					values.put("webhook_url", webhookUrl);
				}
				else if (existing == null || existing.webhookUrl() == null) {
					throw ApiException.unprocessable("INVALID_WEBHOOK_URL", "Vui lòng nhập Webhook URL.");
				}
			}
			case EMAIL -> {
				String email = trimmed(request.email());
				if (email == null) {
					throw ApiException.unprocessable("INVALID_EMAIL", "Vui lòng nhập email nhận cảnh báo.");
				}
				requireMatch(EMAIL, email, "INVALID_EMAIL", "Email không đúng định dạng.");
				values.put("email", email);
			}
		}
		return values;
	}

	private BranchRow requireBranch(String token, UUID branchId) {
		return accountRepository.findBranch(token, branchId)
			.orElseThrow(() -> ApiException.notFound("BRANCH_NOT_FOUND", "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."));
	}

	private static void requireMatch(Pattern pattern, String value, String code, String message) {
		if (!pattern.matcher(value).matches()) {
			throw ApiException.unprocessable(code, message);
		}
	}

	private static String trimmed(String value) {
		return value == null || value.isBlank() ? null : value.trim();
	}

	private static AlertChannelResponse toResponse(AlertChannelRow row) {
		return new AlertChannelResponse(row.type(), true, row.enabled(), AlertMasking.maskToken(row.botToken()), row.chatId(),
				AlertMasking.maskUrl(row.webhookUrl()), row.email(), row.lastTestedAt());
	}

	private static AlertChannelResponse notConfigured(AlertChannelType type) {
		return new AlertChannelResponse(type, false, false, null, null, null, null, null);
	}

}
