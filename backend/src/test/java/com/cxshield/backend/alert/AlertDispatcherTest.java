package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.alert.AlertAdminRepository.BranchInfo;
import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertRuleRow;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.event.FeedbackAlertEventListener;
import com.cxshield.backend.event.FeedbackCreatedEvent;
import com.cxshield.backend.repository.FeedbackRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;

class AlertDispatcherTest {

	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID RESPONSE_ID = UUID.randomUUID();
	private static final UUID SESSION_ID = UUID.randomUUID();
	private static final Instant NOW = Instant.parse("2026-11-06T03:00:00Z");
	private static final String PHONE = "0901234567";

	private AlertAdminRepository alertRepository;
	private FeedbackRepository feedbackRepository;
	private SurveyResponseRepository responseRepository;
	private SurveySessionRepository sessionRepository;
	private AlertSender telegram;
	private AlertSender zalo;
	private AlertDispatcher dispatcher;
	private Feedback feedback;

	@BeforeEach
	void setUp() {
		alertRepository = mock(AlertAdminRepository.class);
		feedbackRepository = mock(FeedbackRepository.class);
		responseRepository = mock(SurveyResponseRepository.class);
		sessionRepository = mock(SurveySessionRepository.class);
		telegram = sender(AlertChannelType.TELEGRAM);
		zalo = sender(AlertChannelType.ZALO);
		dispatcher = new AlertDispatcher(alertRepository, feedbackRepository, responseRepository, sessionRepository,
				List.of(telegram, zalo), Runnable::run, Clock.fixed(NOW, ZoneOffset.UTC));

		when(alertRepository.isEnabled()).thenReturn(true);
		when(alertRepository.findBranch(BRANCH_ID)).thenReturn(Optional.of(new BranchInfo(BRANCH_ID, "Maison Q1")));
		when(alertRepository.findLowRatingRule(BRANCH_ID)).thenReturn(Optional.empty());
		when(alertRepository.findEnabledChannels(BRANCH_ID)).thenReturn(List.of(channel(AlertChannelType.TELEGRAM)));

		feedback = new Feedback();
		feedback.setCommentText("Món ra chậm");
		feedback.setCustomerPhone(PHONE);
		feedback.setConsentAt(NOW);
		feedback.setSubmittedAt(NOW);
		when(feedbackRepository.findById(any())).thenReturn(Optional.of(feedback));
		SurveyResponse response = new SurveyResponse();
		response.setSessionId(SESSION_ID);
		when(responseRepository.findById(RESPONSE_ID)).thenReturn(Optional.of(response));
		SurveySession session = new SurveySession();
		session.setTableOrAreaCode("Bàn 04");
		when(sessionRepository.findById(SESSION_ID)).thenReturn(Optional.of(session));
	}

	@Test
	void sendsFullMessageAndStoresSentNotification() {
		FeedbackCreatedEvent event = event(2, false);

		dispatcher.dispatch(event);

		ArgumentCaptor<String> text = ArgumentCaptor.forClass(String.class);
		verify(telegram).send(any(), contains("Maison Q1"), text.capture());
		assertThat(text.getValue()).contains("Chi nhánh: Maison Q1", "Bàn: Bàn 04", "Đánh giá: 2/5 sao", "Góp ý: Món ra chậm",
				"Thời gian: 10:00 06/11/2026", "SĐT khách: " + PHONE);
		Map<String, Object> stored = storedNotification();
		assertThat(stored).containsEntry("status", "SENT")
			.containsEntry("sent_at", NOW.toString())
			.containsEntry("feedback_id", event.getFeedbackId())
			.containsEntry("branch_id", BRANCH_ID)
			.containsEntry("business_id", BUSINESS_ID)
			.containsEntry("table_code", "Bàn 04")
			.containsEntry("severity", 1)
			.containsEntry("recipient", "người nhận");
	}

	@Test
	void hidesPhoneWithoutConsent() {
		feedback.setConsentAt(null);

		dispatcher.dispatch(event(2, false));

		ArgumentCaptor<String> text = ArgumentCaptor.forClass(String.class);
		verify(telegram).send(any(), anyString(), text.capture());
		assertThat(text.getValue()).doesNotContain(PHONE).doesNotContain("SĐT");
	}

	@Test
	void urgentFeedbackIsMarked() {
		dispatcher.dispatch(event(1, true));

		ArgumentCaptor<String> text = ArgumentCaptor.forClass(String.class);
		verify(telegram).send(any(), contains("[KHẨN]"), text.capture());
		assertThat(text.getValue()).startsWith("[KHẨN]");
		assertThat(storedNotification()).containsEntry("severity", 3);
	}

	@Test
	void sendsToEveryEnabledChannel() {
		when(alertRepository.findEnabledChannels(BRANCH_ID))
			.thenReturn(List.of(channel(AlertChannelType.TELEGRAM), channel(AlertChannelType.ZALO)));

		dispatcher.dispatch(event(3, false));

		verify(telegram).send(any(), anyString(), anyString());
		verify(zalo).send(any(), anyString(), anyString());
		verify(alertRepository, times(2)).insertNotification(anyMap());
	}

	@Test
	void failedChannelIsRecordedAndOthersStillSend() {
		when(alertRepository.findEnabledChannels(BRANCH_ID))
			.thenReturn(List.of(channel(AlertChannelType.TELEGRAM), channel(AlertChannelType.ZALO)));
		doThrow(new AlertSendException("Telegram từ chối")).when(telegram).send(any(), anyString(), anyString());

		dispatcher.dispatch(event(2, false));

		verify(zalo).send(any(), anyString(), anyString());
		ArgumentCaptor<Map<String, Object>> stored = notificationCaptor();
		verify(alertRepository, times(2)).insertNotification(stored.capture());
		assertThat(stored.getAllValues().get(0)).containsEntry("status", "FAILED")
			.containsEntry("error_message", "Telegram từ chối")
			.doesNotContainKey("sent_at");
		assertThat(stored.getAllValues().get(1)).containsEntry("status", "SENT");
	}

	@Test
	void unexpectedSenderErrorIsRecordedAsFailed() {
		doThrow(new IllegalStateException("bug")).when(telegram).send(any(), anyString(), anyString());

		dispatcher.dispatch(event(2, false));

		assertThat(storedNotification()).containsEntry("status", "FAILED").containsEntry("error_message", "Lỗi hệ thống khi gửi tin.");
	}

	@Test
	void longErrorIsTruncated() {
		doThrow(new AlertSendException("x".repeat(500))).when(telegram).send(any(), anyString(), anyString());

		dispatcher.dispatch(event(2, false));

		assertThat((String) storedNotification().get("error_message")).hasSize(300);
	}

	@Test
	void storingNotificationFailureDoesNotThrow() {
		doThrow(new IllegalStateException("db")).when(alertRepository).insertNotification(anyMap());

		assertThatCode(() -> dispatcher.dispatch(event(2, false))).doesNotThrowAnyException();
	}

	@Test
	void ratingAtDefaultThresholdIsNotAlerted() {
		dispatcher.dispatch(event(4, false));

		verifyNothingSent();
	}

	@Test
	void usesBranchRuleThreshold() {
		UUID ruleId = UUID.randomUUID();
		when(alertRepository.findLowRatingRule(BRANCH_ID)).thenReturn(Optional.of(new AlertRuleRow(ruleId, 3, true)));

		dispatcher.dispatch(event(3, false));
		verifyNothingSent();

		dispatcher.dispatch(event(2, false));
		assertThat(storedNotification()).containsEntry("rule_id", ruleId);
	}

	@Test
	void disabledRuleStopsAlerts() {
		when(alertRepository.findLowRatingRule(BRANCH_ID)).thenReturn(Optional.of(new AlertRuleRow(UUID.randomUUID(), 4, false)));

		dispatcher.dispatch(event(1, true));

		verifyNothingSent();
	}

	@Test
	void skipsWithoutServiceRoleKey() {
		when(alertRepository.isEnabled()).thenReturn(false);

		dispatcher.dispatch(event(2, false));

		verify(alertRepository, never()).findBranch(any());
		verifyNothingSent();
	}

	@Test
	void skipsBranchMissingFromDatabase() {
		when(alertRepository.findBranch(BRANCH_ID)).thenReturn(Optional.empty());

		dispatcher.dispatch(event(2, false));

		verifyNothingSent();
	}

	@Test
	void skipsWhenNoChannelEnabled() {
		when(alertRepository.findEnabledChannels(BRANCH_ID)).thenReturn(List.of());

		dispatcher.dispatch(event(2, false));

		verifyNothingSent();
	}

	@Test
	void stillSendsWhenFeedbackDetailsAreMissing() {
		when(feedbackRepository.findById(any())).thenReturn(Optional.empty());
		when(responseRepository.findById(RESPONSE_ID)).thenReturn(Optional.empty());

		dispatcher.dispatch(event(2, false));

		ArgumentCaptor<String> text = ArgumentCaptor.forClass(String.class);
		verify(telegram).send(any(), anyString(), text.capture());
		assertThat(text.getValue()).contains("Đánh giá: 2/5 sao").doesNotContain("Bàn:").doesNotContain("Góp ý:");
	}

	@Test
	void asyncDispatchSwallowsErrorsSoFeedbackIsNotAffected() {
		when(alertRepository.findBranch(BRANCH_ID)).thenThrow(new IllegalStateException("supabase down"));

		assertThatCode(() -> dispatcher.dispatchAsync(event(2, false))).doesNotThrowAnyException();
	}

	@Test
	void listenerForwardsEvent() {
		AlertDispatcher mockDispatcher = mock(AlertDispatcher.class);
		FeedbackCreatedEvent event = event(2, false);

		new FeedbackAlertEventListener(mockDispatcher).onFeedbackCreated(event);

		verify(mockDispatcher).dispatchAsync(eq(event));
	}

	private void verifyNothingSent() {
		verify(telegram, never()).send(any(), anyString(), anyString());
		verify(alertRepository, never()).insertNotification(anyMap());
	}

	private Map<String, Object> storedNotification() {
		ArgumentCaptor<Map<String, Object>> stored = notificationCaptor();
		verify(alertRepository).insertNotification(stored.capture());
		return stored.getValue();
	}

	private static FeedbackCreatedEvent event(int stars, boolean urgent) {
		return new FeedbackCreatedEvent(UUID.randomUUID(), RESPONSE_ID, BRANCH_ID, stars, urgent, true);
	}

	private static AlertChannelRow channel(AlertChannelType type) {
		return new AlertChannelRow(UUID.randomUUID(), BUSINESS_ID, BRANCH_ID, type, "token", "1", "https://a.example.com", null, true,
				null);
	}

	private static AlertSender sender(AlertChannelType type) {
		AlertSender sender = mock(AlertSender.class);
		when(sender.type()).thenReturn(type);
		when(sender.recipient(any())).thenReturn("người nhận");
		return sender;
	}

	@SuppressWarnings({ "unchecked", "rawtypes" })
	private static ArgumentCaptor<Map<String, Object>> notificationCaptor() {
		return (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
	}

}
