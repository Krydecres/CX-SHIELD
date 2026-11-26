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
	/** Zalo Bot: token dạng "số:chuỗi bí mật" (ví dụ 12345689:abc-xyz), Chat ID là chuỗi do Zalo cấp. */
	private static final Pattern ZALO_BOT_TOKEN = Pattern.compile("^\\d{3,}:[A-Za-z0-9_-]{6,}$");
	private static final Pattern ZALO_CHAT_ID = Pattern.compile("^[A-Za-z0-9._-]{3,64}$");
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

	private final AccountRepository accountRepository;
	private final AlertChannelRepository channelRepository;
	private final Map<AlertChannelType, AlertSender> senders;
	private final Clock clock;

	@Autowired
	public AlertChannelService(AccountRepository accountRepository, AlertChannelRepository channelRepository,
			List<AlertSender> senders) {
		this(accountRepository, channelRepository, senders, Clock.systemUTC());
	}

	AlertChannelService(AccountRepository accountRepository, AlertChannelRepository channelRepository,
			List<AlertSender> senders, Clock clock) {
		this.accountRepository = accountRepository;
		this.channelRepository = channelRepository;
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
			case TELEGRAM -> putBotAndChat(values, request, existing, BOT_TOKEN, CHAT_ID);
			case ZALO -> putBotAndChat(values, request, existing, ZALO_BOT_TOKEN, ZALO_CHAT_ID);
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

	/**
	 * Telegram và Zalo Bot cùng cấu hình Bot Token + Chat ID. Để trống Bot Token khi sửa nghĩa là giữ token đã lưu.
	 */
	private static void putBotAndChat(Map<String, Object> values, SaveAlertChannelRequest request, AlertChannelRow existing,
			Pattern tokenPattern, Pattern chatIdPattern) {
		String botToken = trimmed(request.botToken());
		if (botToken != null) {
			requireMatch(tokenPattern, botToken, "INVALID_BOT_TOKEN", "Bot Token không đúng định dạng.");
			values.put("bot_token", botToken);
		}
		else if (existing == null || existing.botToken() == null) {
			throw ApiException.unprocessable("INVALID_BOT_TOKEN", "Vui lòng nhập Bot Token.");
		}
		String chatId = trimmed(request.chatId());
		if (chatId == null) {
			throw ApiException.unprocessable("INVALID_CHAT_ID", "Vui lòng nhập Chat ID.");
		}
		requireMatch(chatIdPattern, chatId, "INVALID_CHAT_ID", "Chat ID không đúng định dạng.");
		values.put("chat_id", chatId);
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
				row.email(), row.lastTestedAt());
	}

	private static AlertChannelResponse notConfigured(AlertChannelType type) {
		return new AlertChannelResponse(type, false, false, null, null, null, null);
	}

}
