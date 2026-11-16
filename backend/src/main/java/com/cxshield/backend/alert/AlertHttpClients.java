package com.cxshield.backend.alert;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.time.Duration;

import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/**
 * Tin cảnh báo phải tới trong 10 giây (E2.2), nên timeout tổng của một lần gửi không quá 8 giây.
 * Không tự theo redirect để Webhook URL không thể dẫn backend vào mạng nội bộ.
 */
final class AlertHttpClients {

	private AlertHttpClients() {
	}

	static RestClient.Builder builder() {
		SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory() {
			@Override
			protected void prepareConnection(HttpURLConnection connection, String httpMethod) throws IOException {
				super.prepareConnection(connection, httpMethod);
				connection.setInstanceFollowRedirects(false);
			}
		};
		factory.setConnectTimeout(Duration.ofSeconds(3));
		factory.setReadTimeout(Duration.ofSeconds(5));
		return RestClient.builder().requestFactory(factory);
	}

}
