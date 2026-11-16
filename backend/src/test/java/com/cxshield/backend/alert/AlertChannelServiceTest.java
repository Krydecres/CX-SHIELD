package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertRuleRow;
import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelsResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertTestResponse;
import com.cxshield.backend.alert.dto.AlertDtos.SaveAlertChannelRequest;
import com.cxshield.backend.common.ApiException;

class AlertChannelServiceTest {

	private static final String TOKEN = "token";
	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID CHANNEL_ID = UUID.randomUUID();
	private static final String BOT_TOKEN = "123456789:AAEabcdefghijklmnopqrstuvwxyz_12345";
	private static final Instant NOW = Instant.parse("2026-11-06T03:00:00Z");

	private AccountRepository accountRepository;
	private AlertChannelRepository channelRepository;
	private WebhookUrlValidator urlValidator;
	private AlertSender telegramSender;
	private AlertChannelService service;

	@BeforeEach
	void setUp() {
		accountRepository = mock(AccountRepository.class);
		channelRepository = mock(AlertChannelRepository.class);
		urlValidator = mock(WebhookUrlValidator.class);
		telegramSender = mock(AlertSender.class);
		when(telegramSender.type()).thenReturn(AlertChannelType.TELEGRAM);
		service = new AlertChannelService(accountRepository, channelRepository, urlValidator, List.of(telegramSender),
				Clock.fixed(NOW, ZoneOffset.UTC));
		when(accountRepository.findBranch(TOKEN, BRANCH_ID)).thenReturn(
				Optional.of(new BranchRow(BRANCH_ID, BUSINESS_ID, "CN01", "Maison Q1", null, null, "ACTIVE", null)));
		when(channelRepository.findChannel(eq(TOKEN), eq(BRANCH_ID), any())).thenReturn(Optional.empty());
		when(channelRepository.findLowRatingRule(TOKEN, BRANCH_ID)).thenReturn(Optional.empty());
		when(channelRepository.insertChannel(eq(TOKEN), anyMap())).thenAnswer(invocation -> Optional.of(row(invocation.getArgument(1))));
		when(channelRepository.updateChannel(eq(TOKEN), any(), anyMap())).thenAnswer(invocation -> Optional.of(row(invocation.getArgument(2))));
	}

	@Test
	void listsAllThreeChannelTypesWithDefaultThreshold() {
		when(channelRepository.findChannels(TOKEN, BRANCH_ID)).thenReturn(List.of());

		AlertChannelsResponse response = service.getChannels(TOKEN, BRANCH_ID);

		assertThat(response.thresholdStar()).isEqualTo(4);
		assertThat(response.branchName()).isEqualTo("Maison Q1");
		assertThat(response.channels()).extracting(AlertChannelResponse::type)
			.containsExactly(AlertChannelType.TELEGRAM, AlertChannelType.ZALO, AlertChannelType.EMAIL);
		assertThat(response.channels()).allMatch(channel -> !channel.configured() && !channel.enabled());
	}

	@Test
	void masksTokenAndWebhookInResponse() {
		when(channelRepository.findChannels(TOKEN, BRANCH_ID)).thenReturn(List.of(telegram(true),
				new AlertChannelRow(UUID.randomUUID(), BUSINESS_ID, BRANCH_ID, AlertChannelType.ZALO, null, null,
						"https://hook.example.com/secret-path", null, true, null)));

		AlertChannelsResponse response = service.getChannels(TOKEN, BRANCH_ID);

		AlertChannelResponse telegram = response.channels().get(0);
		assertThat(telegram.maskedBotToken()).endsWith("2345").doesNotContain(BOT_TOKEN);
		AlertChannelResponse zalo = response.channels().get(1);
		assertThat(zalo.maskedWebhookUrl()).contains("hook.example.com").doesNotContain("secret-path");
	}

	@Test
	void usesThresholdFromBranchRule() {
		when(channelRepository.findChannels(TOKEN, BRANCH_ID)).thenReturn(List.of());
		when(channelRepository.findLowRatingRule(TOKEN, BRANCH_ID))
			.thenReturn(Optional.of(new AlertRuleRow(UUID.randomUUID(), 3, true)));

		assertThat(service.getChannels(TOKEN, BRANCH_ID).thresholdStar()).isEqualTo(3);
	}

	@Test
	void rejectsUnknownBranch() {
		UUID other = UUID.randomUUID();
		when(accountRepository.findBranch(TOKEN, other)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.getChannels(TOKEN, other)).isInstanceOf(ApiException.class)
			.hasFieldOrPropertyWithValue("code", "BRANCH_NOT_FOUND");
	}

	@Test
	void createsTelegramChannel() {
		service.save(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM, new SaveAlertChannelRequest(true, BOT_TOKEN, "-100123", null, null));

		ArgumentCaptor<Map<String, Object>> values = valuesCaptor();
		verify(channelRepository).insertChannel(eq(TOKEN), values.capture());
		assertThat(values.getValue()).containsEntry("bot_token", BOT_TOKEN)
			.containsEntry("chat_id", "-100123")
			.containsEntry("type", "TELEGRAM")
			.containsEntry("business_id", BUSINESS_ID)
			.containsEntry("branch_id", BRANCH_ID)
			.containsEntry("is_enabled", true);
	}

	@Test
	void keepsSavedTokenWhenLeftBlank() {
		when(channelRepository.findChannel(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM)).thenReturn(Optional.of(telegram(true)));

		service.save(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM, new SaveAlertChannelRequest(false, " ", "@maison_alerts", null, null));

		ArgumentCaptor<Map<String, Object>> values = valuesCaptor();
		verify(channelRepository).updateChannel(eq(TOKEN), eq(CHANNEL_ID), values.capture());
		assertThat(values.getValue()).doesNotContainKey("bot_token")
			.containsEntry("chat_id", "@maison_alerts")
			.containsEntry("is_enabled", false);
	}

	@Test
	void newTelegramChannelNeedsToken() {
		assertCode(new SaveAlertChannelRequest(true, null, "123", null, null), AlertChannelType.TELEGRAM, "INVALID_BOT_TOKEN");
	}

	@Test
	void rejectsMalformedToken() {
		assertCode(new SaveAlertChannelRequest(true, "not-a-token", "123", null, null), AlertChannelType.TELEGRAM, "INVALID_BOT_TOKEN");
	}

	@Test
	void rejectsMissingOrMalformedChatId() {
		assertCode(new SaveAlertChannelRequest(true, BOT_TOKEN, null, null, null), AlertChannelType.TELEGRAM, "INVALID_CHAT_ID");
		assertCode(new SaveAlertChannelRequest(true, BOT_TOKEN, "chat id", null, null), AlertChannelType.TELEGRAM, "INVALID_CHAT_ID");
	}

	@Test
	void validatesZaloWebhookUrl() {
		service.save(TOKEN, BRANCH_ID, AlertChannelType.ZALO,
				new SaveAlertChannelRequest(true, null, null, " https://hook.example.com/a ", null));

		verify(urlValidator).validate("https://hook.example.com/a");
	}

	@Test
	void rejectsInternalZaloWebhookUrl() {
		doThrow(ApiException.unprocessable("INVALID_WEBHOOK_URL", "x")).when(urlValidator).validate(anyString());

		assertCode(new SaveAlertChannelRequest(true, null, null, "https://10.0.0.1/a", null), AlertChannelType.ZALO, "INVALID_WEBHOOK_URL");
		verify(channelRepository, never()).insertChannel(any(), anyMap());
	}

	@Test
	void newZaloChannelNeedsUrl() {
		assertCode(new SaveAlertChannelRequest(true, null, null, null, null), AlertChannelType.ZALO, "INVALID_WEBHOOK_URL");
	}

	@Test
	void rejectsMalformedEmail() {
		assertCode(new SaveAlertChannelRequest(true, null, null, null, "a@b"), AlertChannelType.EMAIL, "INVALID_EMAIL");
		assertCode(new SaveAlertChannelRequest(true, null, null, null, null), AlertChannelType.EMAIL, "INVALID_EMAIL");
	}

	@Test
	void savesEmailChannel() {
		AlertChannelResponse response = service.save(TOKEN, BRANCH_ID, AlertChannelType.EMAIL,
				new SaveAlertChannelRequest(true, null, null, null, "quanly@maison.vn"));

		assertThat(response.email()).isEqualTo("quanly@maison.vn");
		assertThat(response.configured()).isTrue();
	}

	@Test
	void reportsForbiddenWhenRlsBlocksInsert() {
		when(channelRepository.insertChannel(eq(TOKEN), anyMap())).thenReturn(Optional.empty());

		assertCode(new SaveAlertChannelRequest(true, BOT_TOKEN, "123", null, null), AlertChannelType.TELEGRAM, "FORBIDDEN");
	}

	@Test
	void reportsForbiddenWhenRlsBlocksUpdate() {
		when(channelRepository.findChannel(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM)).thenReturn(Optional.of(telegram(true)));
		when(channelRepository.updateChannel(eq(TOKEN), any(), anyMap())).thenReturn(Optional.empty());

		assertCode(new SaveAlertChannelRequest(true, null, "123", null, null), AlertChannelType.TELEGRAM, "FORBIDDEN");
	}

	@Test
	void sendTestStoresLastTestedAt() {
		when(channelRepository.findChannel(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM)).thenReturn(Optional.of(telegram(true)));

		AlertTestResponse response = service.sendTest(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM);

		assertThat(response.success()).isTrue();
		assertThat(response.lastTestedAt().toInstant()).isEqualTo(NOW);
		verify(telegramSender).send(any(), eq(AlertMessages.TEST_SUBJECT), anyString());
		ArgumentCaptor<Map<String, Object>> values = valuesCaptor();
		verify(channelRepository).updateChannel(eq(TOKEN), eq(CHANNEL_ID), values.capture());
		assertThat(values.getValue()).containsKey("last_tested_at");
	}

	@Test
	void failedTestKeepsOldTimestampAndReturnsReason() {
		OffsetDateTime previous = OffsetDateTime.parse("2026-11-01T00:00:00Z");
		AlertChannelRow channel = new AlertChannelRow(CHANNEL_ID, BUSINESS_ID, BRANCH_ID, AlertChannelType.TELEGRAM, BOT_TOKEN,
				"123", null, null, true, previous);
		when(channelRepository.findChannel(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM)).thenReturn(Optional.of(channel));
		doThrow(new AlertSendException("Telegram từ chối")).when(telegramSender).send(any(), anyString(), anyString());

		AlertTestResponse response = service.sendTest(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM);

		assertThat(response.success()).isFalse();
		assertThat(response.message()).isEqualTo("Telegram từ chối");
		assertThat(response.lastTestedAt()).isEqualTo(previous);
		verify(channelRepository, never()).updateChannel(any(), any(), anyMap());
	}

	@Test
	void testNeedsSavedChannel() {
		assertThatThrownBy(() -> service.sendTest(TOKEN, BRANCH_ID, AlertChannelType.TELEGRAM)).isInstanceOf(ApiException.class)
			.hasFieldOrPropertyWithValue("code", "ALERT_CHANNEL_NOT_FOUND");
	}

	private void assertCode(SaveAlertChannelRequest request, AlertChannelType type, String code) {
		assertThatThrownBy(() -> service.save(TOKEN, BRANCH_ID, type, request)).isInstanceOf(ApiException.class)
			.hasFieldOrPropertyWithValue("code", code);
	}

	private static AlertChannelRow telegram(boolean enabled) {
		return new AlertChannelRow(CHANNEL_ID, BUSINESS_ID, BRANCH_ID, AlertChannelType.TELEGRAM, BOT_TOKEN, "123", null, null,
				enabled, null);
	}

	private static AlertChannelRow row(Map<String, Object> values) {
		return new AlertChannelRow(CHANNEL_ID, BUSINESS_ID, BRANCH_ID, AlertChannelType.EMAIL, (String) values.get("bot_token"),
				(String) values.get("chat_id"), (String) values.get("webhook_url"), (String) values.get("email"),
				Boolean.TRUE.equals(values.get("is_enabled")), null);
	}

	@SuppressWarnings({ "unchecked", "rawtypes" })
	private static ArgumentCaptor<Map<String, Object>> valuesCaptor() {
		return (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
	}

}
