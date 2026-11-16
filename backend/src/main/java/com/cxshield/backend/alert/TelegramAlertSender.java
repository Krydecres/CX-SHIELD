package com.cxshield.backend.alert;

import java.net.URI;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;

/**
 * Gửi tin qua Telegram Bot API. Gửi dạng văn bản thuần để nội dung góp ý của khách không bị hiểu là định dạng.
 */
@Component
public class TelegramAlertSender implements AlertSender {

	private static final String API_URL = "https://api.telegram.org/bot";

	private final RestClient restClient;

	@Autowired
	public TelegramAlertSender() {
		this(AlertHttpClients.builder());
	}

	TelegramAlertSender(RestClient.Builder builder) {
		this.restClient = builder.build();
	}

	@Override
	public AlertChannelType type() {
		return AlertChannelType.TELEGRAM;
	}

	@Override
	public void send(AlertChannelRow channel, String subject, String text) {
		try {
			boolean accepted = restClient.post()
				.uri(URI.create(API_URL + channel.botToken() + "/sendMessage"))
				.contentType(MediaType.APPLICATION_JSON)
				.body(Map.of("chat_id", channel.chatId(), "text", text))
				.exchange((request, response) -> response.getStatusCode().is2xxSuccessful());
			if (!accepted) {
				throw new AlertSendException("Telegram từ chối tin nhắn, kiểm tra Bot Token và Chat ID.");
			}
		}
		catch (RestClientException ex) {
			// Thông điệp gốc có URL chứa Bot Token nên không đưa ra ngoài.
			throw new AlertSendException("Không kết nối được Telegram, vui lòng thử lại.");
		}
	}

	@Override
	public String recipient(AlertChannelRow channel) {
		return "Telegram " + channel.chatId();
	}

}
