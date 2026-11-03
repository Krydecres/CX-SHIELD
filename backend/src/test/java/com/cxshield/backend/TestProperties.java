package com.cxshield.backend;

import java.util.List;

import com.cxshield.backend.config.CxShieldProperties;

public final class TestProperties {

	public static final String SUPABASE_URL = "https://example.supabase.co";

	private TestProperties() {
	}

	public static CxShieldProperties create(String placesApiKey) {
		return new CxShieldProperties(new CxShieldProperties.Supabase(SUPABASE_URL, "sb_publishable_test", "business-logos"),
				new CxShieldProperties.Google(placesApiKey), new CxShieldProperties.Cors(List.of("http://localhost:3000")));
	}

}
