package com.cxshield.backend.alert;

import java.time.Clock;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.Executor;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.cxshield.backend.alert.AlertAdminRepository.BranchInfo;
import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertRuleRow;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.event.FeedbackCreatedEvent;
import com.cxshield.backend.repository.FeedbackRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;

/**
 * Gửi cảnh báo tới các kênh đang bật khi có góp ý dưới ngưỡng (E2.2 · X4-02).
 * Mỗi kênh gửi song song để kênh chậm không làm trễ kênh khác; timeout mỗi kênh dưới 10 giây.
 * Quy ước log: chỉ ghi ID và trạng thái, không ghi SĐT, nội dung góp ý hay Bot Token.
 */
@Service
public class AlertDispatcher {

	private static final Logger log = LoggerFactory.getLogger(AlertDispatcher.class);
	private static final int MAX_ERROR_LENGTH = 300;

	private final AlertAdminRepository alertRepository;
	private final FeedbackRepository feedbackRepository;
	private final SurveyResponseRepository responseRepository;
	private final SurveySessionRepository sessionRepository;
	private final Map<AlertChannelType, AlertSender> senders;
	private final Executor executor;
	private final Clock clock;

	@Autowired
	public AlertDispatcher(AlertAdminRepository alertRepository, FeedbackRepository feedbackRepository,
			SurveyResponseRepository responseRepository, SurveySessionRepository sessionRepository, List<AlertSender> senders,
			@Qualifier("alertExecutor") Executor executor) {
		this(alertRepository, feedbackRepository, responseRepository, sessionRepository, senders, executor, Clock.systemUTC());
	}

	AlertDispatcher(AlertAdminRepository alertRepository, FeedbackRepository feedbackRepository,
			SurveyResponseRepository responseRepository, SurveySessionRepository sessionRepository, List<AlertSender> senders,
			Executor executor, Clock clock) {
		this.alertRepository = alertRepository;
		this.feedbackRepository = feedbackRepository;
		this.responseRepository = responseRepository;
		this.sessionRepository = sessionRepository;
		this.senders = senders.stream().collect(Collectors.toMap(AlertSender::type, Function.identity()));
		this.executor = executor;
		this.clock = clock;
	}

	/**
	 * Chạy ở luồng riêng để khách gửi góp ý không phải chờ gửi tin. Lỗi ở đây không được ảnh hưởng tới góp ý đã lưu.
	 */
	public void dispatchAsync(FeedbackCreatedEvent event) {
		executor.execute(() -> {
			try {
				dispatch(event);
			}
			catch (RuntimeException ex) {
				log.error("Không xử lý được cảnh báo cho góp ý {}: {}", event.getFeedbackId(), ex.getClass().getSimpleName());
			}
		});
	}

	void dispatch(FeedbackCreatedEvent event) {
		if (!alertRepository.isEnabled()) {
			log.warn("Bỏ qua cảnh báo cho góp ý {}: chưa cấu hình SUPABASE_SERVICE_ROLE_KEY", event.getFeedbackId());
			return;
		}
		Optional<BranchInfo> branch = alertRepository.findBranch(event.getBranchId());
		if (branch.isEmpty()) {
			log.warn("Bỏ qua cảnh báo cho góp ý {}: không có chi nhánh {} trên CSDL", event.getFeedbackId(), event.getBranchId());
			return;
		}
		Optional<AlertRuleRow> rule = alertRepository.findLowRatingRule(event.getBranchId());
		if (rule.isPresent() && !rule.get().enabled()) {
			return;
		}
		int threshold = rule.map(AlertRuleRow::thresholdStar).orElse(AlertChannelService.DEFAULT_THRESHOLD_STAR);
		if (event.getStarRating() >= threshold) {
			return;
		}
		List<AlertChannelRow> channels = alertRepository.findEnabledChannels(event.getBranchId());
		if (channels.isEmpty()) {
			log.info("Chi nhánh {} chưa bật kênh cảnh báo nào", event.getBranchId());
			return;
		}

		Feedback feedback = feedbackRepository.findById(event.getFeedbackId()).orElse(null);
		String tableCode = findTableCode(event.getResponseId());
		// SĐT chỉ đưa vào tin khi khách đã đồng ý liên hệ.
		String phone = feedback != null && feedback.getConsentAt() != null ? feedback.getCustomerPhone() : null;
		String comment = feedback == null ? null : feedback.getCommentText();
		Instant time = feedback == null || feedback.getSubmittedAt() == null ? event.getCreatedAt() : feedback.getSubmittedAt();

		String branchName = branch.get().name();
		String subject = AlertMessages.subject(event.isUrgentCallback(), branchName);
		String text = AlertMessages.feedbackMessage(event.isUrgentCallback(), branchName, tableCode, event.getStarRating(), comment,
				time, phone);
		UUID ruleId = rule.map(AlertRuleRow::id).orElse(null);
		int severity = event.isUrgentCallback() ? 3 : 1;

		for (AlertChannelRow channel : channels) {
			executor.execute(() -> sendToChannel(event, channel, ruleId, subject, text, tableCode, severity));
		}
	}

	private void sendToChannel(FeedbackCreatedEvent event, AlertChannelRow channel, UUID ruleId, String subject, String text,
			String tableCode, int severity) {
		AlertSender sender = senders.get(channel.type());
		Map<String, Object> values = new LinkedHashMap<>();
		values.put("business_id", channel.businessId());
		values.put("branch_id", channel.branchId());
		values.put("rule_id", ruleId);
		values.put("channel_id", channel.id());
		values.put("feedback_id", event.getFeedbackId());
		values.put("recipient", sender.recipient(channel));
		values.put("content", text);
		values.put("table_code", tableCode);
		values.put("severity", severity);
		try {
			sender.send(channel, subject, text);
			values.put("status", "SENT");
			values.put("sent_at", clock.instant().toString());
		}
		catch (AlertSendException ex) {
			log.warn("Gửi cảnh báo qua {} thất bại cho góp ý {}", channel.type(), event.getFeedbackId());
			values.put("status", "FAILED");
			values.put("error_message", truncate(ex.getMessage()));
		}
		catch (RuntimeException ex) {
			log.error("Lỗi không mong đợi khi gửi qua {} cho góp ý {}: {}", channel.type(), event.getFeedbackId(),
					ex.getClass().getSimpleName());
			values.put("status", "FAILED");
			values.put("error_message", "Lỗi hệ thống khi gửi tin.");
		}
		try {
			alertRepository.insertNotification(values);
		}
		catch (RuntimeException ex) {
			log.error("Không lưu được notifications cho góp ý {}: {}", event.getFeedbackId(), ex.getClass().getSimpleName());
		}
	}

	private String findTableCode(UUID responseId) {
		return responseRepository.findById(responseId)
			.map(SurveyResponse::getSessionId)
			.flatMap(sessionRepository::findById)
			.map(SurveySession::getTableOrAreaCode)
			.orElse(null);
	}

	private static String truncate(String message) {
		if (message == null) {
			return null;
		}
		return message.length() <= MAX_ERROR_LENGTH ? message : message.substring(0, MAX_ERROR_LENGTH);
	}

}
