package com.cxshield.backend.config;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "cxshield")
public record CxShieldProperties(Supabase supabase, Google google, Cors cors, Mail mail, Vnpay vnpay, Frontend frontend) {

	public record Supabase(String url, String publishableKey, String logoBucket, String serviceRoleKey) {

		public String restUrl() {
			return url + "/rest/v1";
		}

		public String publicLogoPrefix() {
			return url + "/storage/v1/object/public/" + logoBucket + "/";
		}

		public boolean serviceRoleEnabled() {
			return serviceRoleKey != null && !serviceRoleKey.isBlank();
		}

	}

	public record Google(String placesApiKey) {

		public boolean placesEnabled() {
			return placesApiKey != null && !placesApiKey.isBlank();
		}

	}

	public record Cors(List<String> allowedOrigins) {
	}

	public record Mail(String from) {

		public boolean enabled() {
			return from != null && !from.isBlank();
		}

	}

	public record Vnpay(String tmnCode, String hashSecret, String payUrl, String returnUrl) {

		public boolean enabled() {
			return tmnCode != null && !tmnCode.isBlank() && hashSecret != null && !hashSecret.isBlank();
		}

	}

	public record Frontend(String url) {
	}

}
