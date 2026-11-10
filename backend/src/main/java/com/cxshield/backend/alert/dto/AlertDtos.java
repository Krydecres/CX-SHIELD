package com.cxshield.backend.alert.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import com.cxshield.backend.alert.AlertChannelType;

import jakarta.validation.constraints.Size;

public final class AlertDtos {

	private AlertDtos() {
	}

	public record AlertChannelsResponse(UUID branchId, String branchName, int thresholdStar,
			List<AlertChannelResponse> channels) {
	}

	/**
	 * Bot Token và Webhook URL chỉ trả về dạng đã che, không bao giờ trả giá trị gốc cho giao diện.
	 */
	public record AlertChannelResponse(AlertChannelType type, boolean configured, boolean enabled, String maskedBotToken,
			String chatId, String maskedWebhookUrl, String email, OffsetDateTime lastTestedAt) {
	}

	/**
	 * Để trống botToken hoặc webhookUrl khi sửa nghĩa là giữ giá trị đã lưu.
	 */
	public record SaveAlertChannelRequest(boolean enabled, @Size(max = 200) String botToken, @Size(max = 100) String chatId,
			@Size(max = 500) String webhookUrl, @Size(max = 254) String email) {

		@Override
		public String toString() {
			return "SaveAlertChannelRequest[enabled=" + enabled + "]";
		}

	}

	public record AlertTestResponse(boolean success, String message, OffsetDateTime lastTestedAt) {
	}

}
