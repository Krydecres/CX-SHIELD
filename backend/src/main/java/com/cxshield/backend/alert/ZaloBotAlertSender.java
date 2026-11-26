package com.cxshield.backend.alert;

import java.net.URI;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Gửi tin thẳng vào Zalo qua Zalo Bot API (bot.zaloplatforms.com), cấu hình giống Telegram: Bot Token + Chat ID.
 * Người nhận phải nhắn cho bot trước thì bot mới được phép trả lời vào cuộc trò chuyện đó.
 */
@Component
public class ZaloBotAlertSender implements AlertSender {

	static final String API_URL = "https://bot-api.zaloplatforms.com/bot";

	/** Zalo Bot API nhận tối đa 2000 ký tự mỗi tin. */
	static final int MAX_TEXT_LENGTH = 2000;

	private final RestClient restClient;

	@Autowired
	public ZaloBotAlertSender() {
		this(AlertHttpClients.builder());
	}

	ZaloBotAlertSender(RestClient.Builder builder) {
		this.restClient = builder.build();
	}

	@Override
	public AlertChannelType type() {
		return AlertChannelType.ZALO;
	}

	@Override
	public void send(AlertChannelRow channel, String subject, String text) {
		ZaloBotResult result;
		try {
			result = restClient.post()
				.uri(URI.create(API_URL + channel.botToken() + "/sendMessage"))
				.contentType(MediaType.APPLICATION_JSON)
				.body(Map.of("chat_id", channel.chatId(), "text", fitLength(text)))
				.exchange((request, response) -> {
					ZaloBotResponse body = readBody(response);
					int code = body != null && body.errorCode() != null ? body.errorCode() : response.getStatusCode().value();
					boolean ok = response.getStatusCode().is2xxSuccessful() && body != null && body.ok();
					return new ZaloBotResult(ok, code);
				});
		}
		catch (RestClientException ex) {
			// Thông điệp gốc có URL chứa Bot Token nên không đưa ra ngoài.
			throw new AlertSendException("Không kết nối được Zalo, vui lòng thử lại.");
		}
		if (result == null || !result.ok()) {
			throw new AlertSendException(rejectionMessage(result == null ? 0 : result.code()));
		}
	}

	@Override
	public String recipient(AlertChannelRow channel) {
		return "Zalo " + channel.chatId();
	}

	static String fitLength(String text) {
		return text.length() <= MAX_TEXT_LENGTH ? text : text.substring(0, MAX_TEXT_LENGTH - 1) + "…";
	}

	/** Mã lỗi theo tài liệu Zalo Bot API (bot.zaloplatforms.com/docs/error-code). */
	static String rejectionMessage(int code) {
		return switch (code) {
			case 401 -> "Zalo từ chối: Bot Token không đúng hoặc đã bị đặt lại.";
			case 410 -> "Zalo từ chối: Chat ID không đúng.";
			case 422 -> "Zalo từ chối: bot chưa được nhắn cho Chat ID này. Người nhận cần nhắn cho bot trước.";
			case 429 -> "Zalo từ chối: bot đã dùng hết hạn mức tin nhắn của tháng.";
			default -> "Zalo từ chối tin nhắn, kiểm tra Bot Token và Chat ID.";
		};
	}

	private static ZaloBotResponse readBody(RestClient.RequestHeadersSpec.ConvertibleClientHttpResponse response) {
		try {
			return response.bodyTo(ZaloBotResponse.class);
		}
		catch (RestClientException | IllegalStateException ex) {
			return null;
		}
	}

	private record ZaloBotResult(boolean ok, int code) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record ZaloBotResponse(boolean ok, @JsonProperty("error_code") Integer errorCode, String description) {
	}

}
