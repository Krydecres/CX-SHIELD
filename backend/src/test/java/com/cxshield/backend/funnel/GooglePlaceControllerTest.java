package com.cxshield.backend.funnel;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import com.cxshield.backend.funnel.dto.GooglePlaceDtos.SaveGooglePlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceRequest;

class GooglePlaceControllerTest {

	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final String PLACE_ID = "ChIJN1t_tDeuEmsRUsoyG83frY4";

	private GooglePlaceService service;
	private GooglePlaceController controller;
	private Jwt jwt;

	@BeforeEach
	void setUp() {
		service = mock(GooglePlaceService.class);
		controller = new GooglePlaceController(service);
		jwt = Jwt.withTokenValue("token").header("alg", "ES256").subject(UUID.randomUUID().toString()).build();
	}

	@Test
	void getUsesUserToken() {
		controller.get(jwt, BRANCH_ID);

		verify(service).getConfig("token", BRANCH_ID);
	}

	@Test
	void verifyPassesPlaceId() {
		controller.verify(jwt, BRANCH_ID, new VerifyPlaceRequest(PLACE_ID));

		verify(service).verify("token", BRANCH_ID, PLACE_ID);
	}

	@Test
	void savePassesRequest() {
		SaveGooglePlaceRequest request = new SaveGooglePlaceRequest(PLACE_ID, null);

		controller.save(jwt, BRANCH_ID, request);

		verify(service).save("token", BRANCH_ID, request);
	}

}
