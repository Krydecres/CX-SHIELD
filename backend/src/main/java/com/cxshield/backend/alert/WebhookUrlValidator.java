package com.cxshield.backend.alert;

import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.UnknownHostException;

import org.springframework.stereotype.Component;

import com.cxshield.backend.common.ApiException;

/**
 * Backend sẽ tự gọi URL do người dùng nhập, nên chỉ nhận https và chặn địa chỉ mạng nội bộ.
 */
@Component
public class WebhookUrlValidator {

	private static final String INVALID_CODE = "INVALID_WEBHOOK_URL";

	public void validate(String url) {
		URI uri = parse(url);
		if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null || uri.getUserInfo() != null) {
			throw ApiException.unprocessable(INVALID_CODE, "Webhook URL phải là địa chỉ https hợp lệ.");
		}
		for (InetAddress address : resolve(uri.getHost())) {
			if (isInternal(address)) {
				throw ApiException.unprocessable(INVALID_CODE, "Webhook URL không được trỏ tới mạng nội bộ.");
			}
		}
	}

	InetAddress[] resolve(String host) {
		try {
			return InetAddress.getAllByName(host);
		}
		catch (UnknownHostException ex) {
			throw ApiException.unprocessable(INVALID_CODE, "Không tìm thấy tên miền của Webhook URL.");
		}
	}

	private static URI parse(String url) {
		try {
			return new URI(url.trim());
		}
		catch (URISyntaxException ex) {
			throw ApiException.unprocessable(INVALID_CODE, "Webhook URL phải là địa chỉ https hợp lệ.");
		}
	}

	private static boolean isInternal(InetAddress address) {
		byte[] raw = address.getAddress();
		boolean carrierNat = raw.length == 4 && (raw[0] & 0xFF) == 100 && (raw[1] & 0xC0) == 64;
		boolean uniqueLocal = raw.length == 16 && (raw[0] & 0xFE) == 0xFC;
		return address.isLoopbackAddress() || address.isAnyLocalAddress() || address.isLinkLocalAddress()
				|| address.isSiteLocalAddress() || address.isMulticastAddress() || carrierNat || uniqueLocal;
	}

}
