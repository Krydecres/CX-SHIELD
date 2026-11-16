package com.cxshield.backend.alert;

import java.net.URI;

/**
 * Che dữ liệu nhạy cảm của kênh cảnh báo trước khi trả về giao diện hoặc lưu vào notifications.
 */
final class AlertMasking {

	private static final String DOTS = "••••••";

	private AlertMasking() {
	}

	static String maskToken(String token) {
		if (token == null || token.isBlank()) {
			return null;
		}
		return token.length() <= 4 ? DOTS : DOTS + token.substring(token.length() - 4);
	}

	static String maskUrl(String url) {
		if (url == null || url.isBlank()) {
			return null;
		}
		try {
			String host = URI.create(url).getHost();
			return host == null ? DOTS : "https://" + host + "/" + DOTS;
		}
		catch (IllegalArgumentException ex) {
			return DOTS;
		}
	}

}
