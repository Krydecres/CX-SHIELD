package com.cxshield.backend.config;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import com.cxshield.backend.TestProperties;

class CxShieldPropertiesTest {

	@Test
	void buildsSupabaseUrls() {
		CxShieldProperties.Supabase supabase = TestProperties.create(null).supabase();

		assertThat(supabase.restUrl()).isEqualTo("https://example.supabase.co/rest/v1");
		assertThat(supabase.publicLogoPrefix())
			.isEqualTo("https://example.supabase.co/storage/v1/object/public/business-logos/");
	}

	@Test
	void googleVerificationNeedsApiKey() {
		assertThat(new CxShieldProperties.Google(null).placesEnabled()).isFalse();
		assertThat(new CxShieldProperties.Google("  ").placesEnabled()).isFalse();
		assertThat(new CxShieldProperties.Google("key").placesEnabled()).isTrue();
	}

}
