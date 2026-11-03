package com.cxshield.backend.config;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "cxshield")
public record CxShieldProperties(Supabase supabase, Google google, Cors cors) {

	public record Supabase(String url, String publishableKey, String logoBucket) {

		public String restUrl() {
			return url + "/rest/v1";
		}

		public String publicLogoPrefix() {
			return url + "/storage/v1/object/public/" + logoBucket + "/";
		}

	}

	public record Google(String placesApiKey) {

		public boolean placesEnabled() {
			return placesApiKey != null && !placesApiKey.isBlank();
		}

	}

	public record Cors(List<String> allowedOrigins) {
	}

}
