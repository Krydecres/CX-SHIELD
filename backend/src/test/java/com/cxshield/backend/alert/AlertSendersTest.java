package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.jsonPath;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.io.IOException;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mail.MailSendException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import com.cxshield.backend.TestProperties;
import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.common.ApiException;

class AlertSendersTest {

	private static final String BOT_TOKEN = "123456789:AAEabcdefghijklmnopqrstuvwxyz_12345";
	private static final String TELEGRAM_URL = "https://api.telegram.org/bot" + BOT_TOKEN + "/sendMessage";
	private static final String WEBHOOK_URL = "https://hook.example.com/zalo/secret";
	private static final String ZALO_TOKEN = "12345689:abcdef-xyz";
	private static final String ZALO_CHAT = "6ede9afa66b88fe6d6a9";
	private static final String ZALO_URL = "https://bot-api.zaloplatforms.com/bot" + ZALO_TOKEN + "/sendMessage";

	private static AlertChannelRow zaloChannel() {
		return new AlertChannelRow(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), AlertChannelType.ZALO, ZALO_TOKEN, ZALO_CHAT,
				null, null, true, null);
	}

	private static AlertChannelRow channel(AlertChannelType type) {
		return new AlertChannelRow(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), type, BOT_TOKEN, "-100123", WEBHOOK_URL,
				"quanly@maison.vn", true, null);
	}

	@Test
	void telegramPostsPlainText() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		TelegramAlertSender sender = new TelegramAlertSender(builder);
		server.expect(requestTo(TELEGRAM_URL))
			.andExpect(method(HttpMethod.POST))
			.andExpect(jsonPath("$.chat_id").value("-100123"))
			.andExpect(jsonPath("$.text").value("Nội dung"))
			.andExpect(jsonPath("$.parse_mode").doesNotExist())
			.andRespond(withSuccess("{\"ok\":true}", MediaType.APPLICATION_JSON));

		sender.send(channel(AlertChannelType.TELEGRAM), "Tiêu đề", "Nội dung");

		server.verify();
		assertThat(sender.type()).isEqualTo(AlertChannelType.TELEGRAM);
	}

	@Test
	void telegramRejectionHidesToken() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		TelegramAlertSender sender = new TelegramAlertSender(builder);
		server.expect(requestTo(TELEGRAM_URL)).andRespond(withStatus(HttpStatus.UNAUTHORIZED));

		assertThatThrownBy(() -> sender.send(channel(AlertChannelType.TELEGRAM), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageContaining("Telegram từ chối")
			.hasMessageNotContaining(BOT_TOKEN);
	}

	@Test
	void telegramNetworkFailureHidesToken() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		TelegramAlertSender sender = new TelegramAlertSender(builder);
		server.expect(requestTo(TELEGRAM_URL)).andRespond(request -> {
			throw new IOException("timeout at " + TELEGRAM_URL);
		});

		assertThatThrownBy(() -> sender.send(channel(AlertChannelType.TELEGRAM), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageNotContaining(BOT_TOKEN);
	}

	@Test
	void telegramRecipientShowsChatId() {
		assertThat(new TelegramAlertSender(RestClient.builder()).recipient(channel(AlertChannelType.TELEGRAM)))
			.isEqualTo("Telegram -100123");
	}

	@Test
	void zaloBotPostsChatIdAndText() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		ZaloBotAlertSender sender = new ZaloBotAlertSender(builder);
		server.expect(requestTo(ZALO_URL))
			.andExpect(method(HttpMethod.POST))
			.andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
			.andExpect(jsonPath("$.chat_id").value(ZALO_CHAT))
			.andExpect(jsonPath("$.text").value("Nội dung"))
			.andRespond(withSuccess("{\"ok\":true,\"result\":{\"message_id\":\"82599fa32f56d00e8941\"}}", MediaType.APPLICATION_JSON));

		sender.send(zaloChannel(), "Tiêu đề", "Nội dung");

		server.verify();
		assertThat(sender.type()).isEqualTo(AlertChannelType.ZALO);
	}

	@Test
	void zaloBotOkFalseBecomesSendError() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		ZaloBotAlertSender sender = new ZaloBotAlertSender(builder);
		server.expect(requestTo(ZALO_URL))
			.andRespond(withSuccess("{\"ok\":false,\"error_code\":422,\"description\":\"not allowed\"}", MediaType.APPLICATION_JSON));

		assertThatThrownBy(() -> sender.send(zaloChannel(), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageContaining("nhắn cho bot trước")
			.hasMessageNotContaining(ZALO_TOKEN);
	}

	@Test
	void zaloBotHttpErrorHidesToken() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		ZaloBotAlertSender sender = new ZaloBotAlertSender(builder);
		server.expect(requestTo(ZALO_URL)).andRespond(withStatus(HttpStatus.UNAUTHORIZED));

		assertThatThrownBy(() -> sender.send(zaloChannel(), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageContaining("Bot Token")
			.hasMessageNotContaining(ZALO_TOKEN);
	}

	@Test
	void zaloBotNetworkFailureHidesToken() {
		RestClient.Builder builder = RestClient.builder();
		MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
		ZaloBotAlertSender sender = new ZaloBotAlertSender(builder);
		server.expect(requestTo(ZALO_URL)).andRespond(request -> {
			throw new IOException("timeout at " + ZALO_URL);
		});

		assertThatThrownBy(() -> sender.send(zaloChannel(), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageNotContaining(ZALO_TOKEN);
	}

	@Test
	void zaloBotTruncatesLongText() {
		String text = "a".repeat(2500);

		assertThat(ZaloBotAlertSender.fitLength(text)).hasSize(2000).endsWith("…");
		assertThat(ZaloBotAlertSender.fitLength("ngắn")).isEqualTo("ngắn");
	}

	@Test
	void zaloRecipientShowsChatId() {
		assertThat(new ZaloBotAlertSender(RestClient.builder()).recipient(zaloChannel())).isEqualTo("Zalo " + ZALO_CHAT);
	}

	@Test
	@SuppressWarnings("unchecked")
	void emailUsesConfiguredSender() {
		ObjectProvider<JavaMailSender> provider = mock(ObjectProvider.class);
		JavaMailSender mailSender = mock(JavaMailSender.class);
		when(provider.getIfAvailable()).thenReturn(mailSender);
		EmailAlertSender sender = new EmailAlertSender(provider, TestProperties.create(null));

		sender.send(channel(AlertChannelType.EMAIL), "Tiêu đề", "Nội dung");

		ArgumentCaptor<SimpleMailMessage> message = ArgumentCaptor.forClass(SimpleMailMessage.class);
		verify(mailSender).send(message.capture());
		assertThat(message.getValue().getTo()).containsExactly("quanly@maison.vn");
		assertThat(message.getValue().getFrom()).isEqualTo("alerts@example.com");
		assertThat(message.getValue().getSubject()).isEqualTo("Tiêu đề");
		assertThat(message.getValue().getText()).isEqualTo("Nội dung");
		assertThat(sender.recipient(channel(AlertChannelType.EMAIL))).isEqualTo("quanly@maison.vn");
	}

	@Test
	@SuppressWarnings("unchecked")
	void emailReportsMissingServer() {
		ObjectProvider<JavaMailSender> provider = mock(ObjectProvider.class);
		when(provider.getIfAvailable()).thenReturn(null);
		EmailAlertSender sender = new EmailAlertSender(provider, TestProperties.create(null));

		assertThatThrownBy(() -> sender.send(channel(AlertChannelType.EMAIL), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageContaining("chưa cấu hình");
	}

	@Test
	@SuppressWarnings("unchecked")
	void emailWrapsMailFailure() {
		ObjectProvider<JavaMailSender> provider = mock(ObjectProvider.class);
		JavaMailSender mailSender = mock(JavaMailSender.class);
		when(provider.getIfAvailable()).thenReturn(mailSender);
		doThrow(new MailSendException("smtp down")).when(mailSender).send(any(SimpleMailMessage.class));
		EmailAlertSender sender = new EmailAlertSender(provider, TestProperties.create(null));

		assertThatThrownBy(() -> sender.send(channel(AlertChannelType.EMAIL), "t", "x")).isInstanceOf(AlertSendException.class)
			.hasMessageNotContaining("smtp down");
	}

}
