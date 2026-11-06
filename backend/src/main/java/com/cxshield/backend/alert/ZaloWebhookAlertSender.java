package com.cxshield.backend.alert;

import java.net.URI;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.common.ApiException;

/**
 * Gửi tin tới Webhook URL của Zalo. Tên sự kiện theo quy ước API: review.low_rating.
 */
@Component
public class ZaloWebhookAlertSender implements AlertSender {

	static final String EVENT = "review.low_rating";

	private final RestClient restClient;
	private final WebhookUrlValidator urlValidator;

	@Autowired
	public ZaloWebhookAlertSender(WebhookUrlValidator urlValidator) {
		this(AlertHttpClients.builder(), urlValidator);
	}

	ZaloWebhookAlertSender(RestClient.Builder builder, WebhookUrlValidator urlValidator) {
		this.restClient = builder.build();
		this.urlValidator = urlValidator;
	}

	@Override
	public AlertChannelType type() {
		return AlertChannelType.ZALO;
	}

	@Override
	public void send(AlertChannelRow channel, String subject, String text) {
		try {
			// Kiểm tra lại lúc gửi vì tên miền có thể đã đổi địa chỉ sau khi lưu.
			urlValidator.validate(channel.webhookUrl());
			boolean accepted = restClient.post()
				.uri(URI.create(channel.webhookUrl()))
				.contentType(MediaType.APPLICATION_JSON)
				.body(Map.of("event", EVENT, "title", subject, "text", text))
				.exchange((request, response) -> response.getStatusCode().is2xxSuccessful());
			if (!accepted) {
				throw new AlertSendException("Webhook Zalo từ chối tin nhắn, kiểm tra lại URL.");
			}
		}
		catch (ApiException ex) {
			throw new AlertSendException(ex.getMessage());
		}
		catch (RestClientException ex) {
			throw new AlertSendException("Không kết nối được Webhook Zalo, vui lòng thử lại.");
		}
	}

	@Override
	public String recipient(AlertChannelRow channel) {
		return "Zalo " + AlertMasking.maskUrl(channel.webhookUrl());
	}

}
