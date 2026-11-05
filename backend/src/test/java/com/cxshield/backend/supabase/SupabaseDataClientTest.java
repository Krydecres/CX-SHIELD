package com.cxshield.backend.supabase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.queryParam;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import com.cxshield.backend.TestProperties;

import tools.jackson.databind.json.JsonMapper;

class SupabaseDataClientTest {

	private static final String REST_URL = TestProperties.SUPABASE_URL + "/rest/v1";
	private static final ParameterizedTypeReference<List<Row>> ROWS = new ParameterizedTypeReference<>() {
	};

	private MockRestServiceServer server;
	private SupabaseDataClient client;

	@BeforeEach
	void setUp() {
		RestClient.Builder builder = RestClient.builder();
		server = MockRestServiceServer.bindTo(builder).build();
		client = new SupabaseDataClient(TestProperties.create(null), JsonMapper.builder().build(), builder);
	}

	@Test
	void selectSendsKeyUserTokenAndFilters() {
		server.expect(requestTo(startsWith(REST_URL + "/branches?")))
			.andExpect(method(HttpMethod.GET))
			.andExpect(header("apikey", "sb_publishable_test"))
			.andExpect(header("Authorization", "Bearer token"))
			.andExpect(queryParam("code", "eq.CN01"))
			.andRespond(withSuccess("[{\"name\":\"Maison Q1\"}]", MediaType.APPLICATION_JSON));

		List<Row> rows = client.select("token", "branches", Map.of("code", "eq.CN01"), ROWS);

		assertThat(rows).containsExactly(new Row("Maison Q1"));
		server.verify();
	}

	@Test
	void insertAsksForCreatedRow() {
		server.expect(requestTo(REST_URL + "/review_platforms"))
			.andExpect(method(HttpMethod.POST))
			.andExpect(header("Prefer", "return=representation"))
			.andRespond(withSuccess("[{\"name\":\"Google\"}]", MediaType.APPLICATION_JSON));

		assertThat(client.insert("token", "review_platforms", Map.of("name", "Google"), ROWS))
			.containsExactly(new Row("Google"));
		server.verify();
	}

	@Test
	void insertWithoutReturnAsksForMinimalResponse() {
		server.expect(requestTo(REST_URL + "/branches"))
			.andExpect(method(HttpMethod.POST))
			.andExpect(header("Prefer", "return=minimal"))
			.andRespond(withStatus(HttpStatus.CREATED));

		client.insertWithoutReturn("token", "branches", Map.of("code", "CN01"));

		server.verify();
	}

	@Test
	void updateUsesPatchWithFilter() {
		server.expect(requestTo(startsWith(REST_URL + "/businesses?")))
			.andExpect(method(HttpMethod.PATCH))
			.andExpect(queryParam("id", "eq.1"))
			.andExpect(header("Prefer", "return=representation"))
			.andRespond(withSuccess("[]", MediaType.APPLICATION_JSON));

		assertThat(client.update("token", "businesses", Map.of("id", "eq.1"), Map.of("phone", "090"), ROWS)).isEmpty();
		server.verify();
	}

	@Test
	void rpcReturnsFunctionResult() {
		UUID id = UUID.randomUUID();
		server.expect(requestTo(REST_URL + "/rpc/create_business_onboarding"))
			.andExpect(method(HttpMethod.POST))
			.andRespond(withSuccess("\"" + id + "\"", MediaType.APPLICATION_JSON));

		assertThat(client.rpc("token", "create_business_onboarding", Map.of(), UUID.class)).isEqualTo(id);
		server.verify();
	}

	@Test
	void postgrestErrorBecomesSupabaseException() {
		server.expect(requestTo(REST_URL + "/businesses"))
			.andRespond(withStatus(HttpStatus.CONFLICT).contentType(MediaType.APPLICATION_JSON)
				.body("{\"code\":\"23505\",\"message\":\"duplicate key\",\"hint\":null}"));

		assertThatThrownBy(() -> client.insert("token", "businesses", Map.of(), ROWS))
			.isInstanceOfSatisfying(SupabaseException.class, ex -> {
				assertThat(ex.getStatus()).isEqualTo(409);
				assertThat(ex.isUniqueViolation()).isTrue();
				assertThat(ex.getMessage()).isEqualTo("duplicate key");
			});
	}

	@Test
	void unreadableErrorBodyStillBecomesSupabaseException() {
		server.expect(requestTo(REST_URL + "/businesses"))
			.andRespond(withStatus(HttpStatus.BAD_GATEWAY).body("<html>Bad gateway</html>"));

		assertThatThrownBy(() -> client.insert("token", "businesses", Map.of(), ROWS))
			.isInstanceOfSatisfying(SupabaseException.class, ex -> {
				assertThat(ex.getStatus()).isEqualTo(502);
				assertThat(ex.getCode()).isNull();
			});
	}

	record Row(String name) {
	}

}
