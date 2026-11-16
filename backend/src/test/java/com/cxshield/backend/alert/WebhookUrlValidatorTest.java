package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import com.cxshield.backend.common.ApiException;

class WebhookUrlValidatorTest {

	/** Trả về địa chỉ cố định để test không phụ thuộc DNS thật. */
	private static WebhookUrlValidator resolvingTo(String ip) {
		return new WebhookUrlValidator() {
			@Override
			InetAddress[] resolve(String host) {
				try {
					return new InetAddress[] { InetAddress.getByName(ip) };
				}
				catch (UnknownHostException ex) {
					throw new IllegalStateException(ex);
				}
			}
		};
	}

	@Test
	void acceptsPublicHttpsUrl() {
		assertThatCode(() -> resolvingTo("8.8.8.8").validate("https://hook.example.com/a")).doesNotThrowAnyException();
	}

	@ParameterizedTest
	@ValueSource(strings = { "http://hook.example.com/a", "ftp://hook.example.com", "hook.example.com/a", "not a url",
			"https://user:pass@hook.example.com/a" })
	void rejectsNonHttpsOrMalformedUrl(String url) {
		assertInvalid(resolvingTo("8.8.8.8"), url);
	}

	@ParameterizedTest
	@ValueSource(strings = { "127.0.0.1", "10.1.2.3", "172.16.0.1", "192.168.1.1", "169.254.169.254", "0.0.0.0", "100.64.0.1",
			"::1", "fd00::1", "fe80::1" })
	void rejectsInternalAddresses(String ip) {
		assertInvalid(resolvingTo(ip), "https://hook.example.com/a");
	}

	@Test
	void reportsUnknownHost() {
		WebhookUrlValidator validator = new WebhookUrlValidator() {
			@Override
			InetAddress[] resolve(String host) {
				throw ApiException.unprocessable("INVALID_WEBHOOK_URL", "Không tìm thấy tên miền của Webhook URL.");
			}
		};

		assertInvalid(validator, "https://hook.example.com/a");
	}

	private static void assertInvalid(WebhookUrlValidator validator, String url) {
		assertThatThrownBy(() -> validator.validate(url)).isInstanceOf(ApiException.class)
			.hasFieldOrPropertyWithValue("code", "INVALID_WEBHOOK_URL");
	}

}
