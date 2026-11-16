package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import com.cxshield.backend.alert.dto.AlertDtos.SaveAlertChannelRequest;

class AlertChannelControllerTest {

	private static final UUID BRANCH_ID = UUID.randomUUID();

	private AlertChannelService service;
	private AlertChannelController controller;
	private Jwt jwt;

	@BeforeEach
	void setUp() {
		service = mock(AlertChannelService.class);
		controller = new AlertChannelController(service);
		jwt = Jwt.withTokenValue("token").header("alg", "ES256").subject(UUID.randomUUID().toString()).build();
	}

	@Test
	void listUsesUserToken() {
		controller.list(jwt, BRANCH_ID);

		verify(service).getChannels("token", BRANCH_ID);
	}

	@Test
	void savePassesRequest() {
		SaveAlertChannelRequest request = new SaveAlertChannelRequest(true, null, null, null, "a@b.vn");

		controller.save(jwt, BRANCH_ID, AlertChannelType.EMAIL, request);

		verify(service).save("token", BRANCH_ID, AlertChannelType.EMAIL, request);
	}

	@Test
	void testPassesType() {
		controller.test(jwt, BRANCH_ID, AlertChannelType.ZALO);

		verify(service).sendTest("token", BRANCH_ID, AlertChannelType.ZALO);
	}

	@Test
	void requestToStringHidesSecrets() {
		String text = new SaveAlertChannelRequest(true, "secret-token", "1", "https://secret.example.com", null).toString();

		assertThat(text).doesNotContain("secret");
	}

}
