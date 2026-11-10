package com.cxshield.backend.alert;

/**
 * Lỗi gửi tin. Thông điệp hiển thị được cho người dùng, không chứa Bot Token hay URL gốc.
 */
public class AlertSendException extends RuntimeException {

	public AlertSendException(String message) {
		super(message);
	}

}
