package com.cxshield.backend;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class ApiSecurityTest {

	@Autowired
	private MockMvc mockMvc;

	@Test
	void rejectsRequestWithoutToken() throws Exception {
		mockMvc.perform(get("/api/v1/me")).andExpect(status().isUnauthorized());
	}

	@Test
	void validatesOnboardingRequest() throws Exception {
		mockMvc
			.perform(post("/api/v1/onboarding").with(jwt().jwt(token -> token.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("""
						{"brandName": " ", "industry": "Khác", "phone": "12ab", "primaryColor": "blue"}
						"""))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
			.andExpect(jsonPath("$.fieldErrors.brandName").exists())
			.andExpect(jsonPath("$.fieldErrors.phone").exists())
			.andExpect(jsonPath("$.fieldErrors.primaryColor").exists());
	}

	@Test
	void rejectsInvalidPlaceIdBeforeTouchingDatabase() throws Exception {
		mockMvc
			.perform(post("/api/v1/branches/{id}/google-place/verifications", UUID.randomUUID())
				.with(jwt().jwt(token -> token.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\": \"\"}"))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.fieldErrors.placeId").exists());
	}

}
