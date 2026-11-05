package com.cxshield.backend.funnel;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.io.IOException;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.EnumSource;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import com.cxshield.backend.TestProperties;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceLookup;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceLookup.Result;

class GooglePlacesClientTest {

	private static final String PLACE_ID = "ChIJN1t_tDeuEmsRUsoyG83frY4";
	private static final String PLACE_URL = "https://places.googleapis.com/v1/places/" + PLACE_ID + "?languageCode=vi";

	private MockRestServiceServer server;
	private GooglePlacesClient client;

	@BeforeEach
	void setUp() {
		RestClient.Builder builder = RestClient.builder();
		server = MockRestServiceServer.bindTo(builder).build();
		client = new GooglePlacesClient(TestProperties.create("test-key"), builder);
	}

	@Test
	void doesNotCallGoogleWithoutApiKey() {
		GooglePlacesClient disabled = new GooglePlacesClient(TestProperties.create(""));

		assertThat(disabled.isEnabled()).isFalse();
		assertThat(disabled.lookup(PLACE_ID).result()).isEqualTo(Result.NOT_CONFIGURED);
	}

	@Test
	void returnsNameAndAddressWhenPlaceExists() {
		server.expect(requestTo(PLACE_URL))
			.andExpect(method(HttpMethod.GET))
			.andExpect(header("X-Goog-Api-Key", "test-key"))
			.andExpect(header("X-Goog-FieldMask", "id,displayName,formattedAddress"))
			.andRespond(withSuccess("""
					{"id": "x", "displayName": {"text": "Maison", "languageCode": "vi"}, "formattedAddress": "1 Lê Lợi"}
					""", MediaType.APPLICATION_JSON));

		PlaceLookup lookup = client.lookup(PLACE_ID);

		assertThat(lookup.result()).isEqualTo(Result.FOUND);
		assertThat(lookup.name()).isEqualTo("Maison");
		assertThat(lookup.address()).isEqualTo("1 Lê Lợi");
		server.verify();
	}

	@Test
	void toleratesPlaceWithoutDisplayName() {
		server.expect(requestTo(PLACE_URL)).andRespond(withSuccess("{\"id\": \"x\"}", MediaType.APPLICATION_JSON));

		PlaceLookup lookup = client.lookup(PLACE_ID);

		assertThat(lookup.result()).isEqualTo(Result.FOUND);
		assertThat(lookup.name()).isNull();
	}

	@ParameterizedTest
	@EnumSource(value = HttpStatus.class, names = { "NOT_FOUND", "BAD_REQUEST" })
	void reportsMissingPlace(HttpStatus status) {
		server.expect(requestTo(PLACE_URL)).andRespond(withStatus(status));

		assertThat(client.lookup(PLACE_ID).result()).isEqualTo(Result.NOT_FOUND);
	}

	@ParameterizedTest
	@EnumSource(value = HttpStatus.class, names = { "FORBIDDEN", "TOO_MANY_REQUESTS", "INTERNAL_SERVER_ERROR" })
	void reportsUnavailableWhenGoogleFails(HttpStatus status) {
		server.expect(requestTo(PLACE_URL)).andRespond(withStatus(status));

		assertThat(client.lookup(PLACE_ID).result()).isEqualTo(Result.UNAVAILABLE);
	}

	@Test
	void reportsUnavailableOnNetworkError() {
		server.expect(requestTo(PLACE_URL)).andRespond(request -> {
			throw new IOException("timeout");
		});

		assertThat(client.lookup(PLACE_ID).result()).isEqualTo(Result.UNAVAILABLE);
	}

}
