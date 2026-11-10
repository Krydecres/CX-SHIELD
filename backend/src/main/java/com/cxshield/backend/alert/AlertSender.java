package com.cxshield.backend.alert;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;

/**
 * Gửi một tin cảnh báo qua một loại kênh. Lỗi gửi được ném ra dưới dạng {@link AlertSendException}.
 */
public interface AlertSender {

	AlertChannelType type();

	void send(AlertChannelRow channel, String subject, String text);

	/**
	 * Người nhận hiển thị trong notifications, đã che dữ liệu nhạy cảm.
	 */
	String recipient(AlertChannelRow channel);

}
