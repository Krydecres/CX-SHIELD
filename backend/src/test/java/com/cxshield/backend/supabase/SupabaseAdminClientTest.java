package com.cxshield.backend.supabase;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.headerDoesNotExist;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.jsonPath;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.util.List;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import com.cxshield.backend.TestProperties;

import tools.jackson.databind.json.JsonMapper;

class SupabaseAdminClientTest {

	private static final String REST = TestProperties.SUPABASE_URL + "/rest/v1";
	private static final ParameterizedTypeReference<List<Map<String, Object>>> ROWS = new ParameterizedTypeReference<>() {
	};

	private MockRestServiceServer server;

	private SupabaseAdminClient client(String key) {
		RestClient.Builder builder = RestClient.builder();
		server = MockRestServiceServer.bindTo(builder).build();
		return new SupabaseAdminClient(TestProperties.create(null, key), JsonMapper.builder().build(), builder);
	}

	@Test
	void disabledWithoutKey() {
		assertThat(client(null).isEnabled()).isFalse();
		assertThat(client(" ").isEnabled()).isFalse();
		assertThat(client("sb_secret_x").isEnabled()).isTrue();
	}

	@Test
	void secretKeyGoesOnlyInApikeyHeader() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/plans?select=id"))
			.andExpect(method(HttpMethod.GET))
			.andExpect(header("apikey", "sb_secret_x"))
			.andExpect(headerDoesNotExist(HttpHeaders.AUTHORIZATION))
			.andRespond(withSuccess("[{\"id\":\"a\"}]", MediaType.APPLICATION_JSON));

		List<Map<String, Object>> rows = client.select("plans", Map.of("select", "id"), ROWS);

		assertThat(rows).hasSize(1);
		server.verify();
	}

	@Test
	void legacyJwtKeyAlsoGoesInAuthorizationHeader() {
		SupabaseAdminClient client = client("eyJhbGciOi.x.y");
		server.expect(requestTo(REST + "/plans?select=id"))
			.andExpect(header("apikey", "eyJhbGciOi.x.y"))
			.andExpect(header(HttpHeaders.AUTHORIZATION, "Bearer eyJhbGciOi.x.y"))
			.andRespond(withSuccess("[]", MediaType.APPLICATION_JSON));

		assertThat(client.select("plans", Map.of("select", "id"), ROWS)).isEmpty();
	}

	@Test
	void insertReturnsRows() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/payments"))
			.andExpect(method(HttpMethod.POST))
			.andExpect(header("Prefer", "return=representation"))
			.andExpect(jsonPath("$.amount").value(1))
			.andRespond(withSuccess("[{\"id\":\"a\"}]", MediaType.APPLICATION_JSON));

		assertThat(client.insert("payments", Map.of("amount", 1), ROWS)).hasSize(1);
	}

	@Test
	void insertWithoutReturnUsesMinimalPrefer() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/notifications"))
			.andExpect(header("Prefer", "return=minimal"))
			.andRespond(withStatus(HttpStatus.CREATED));

		client.insertWithoutReturn("notifications", Map.of("content", "x"));

		server.verify();
	}

	@Test
	void updateFiltersRows() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/payments?id=eq.1"))
			.andExpect(method(HttpMethod.PATCH))
			.andExpect(jsonPath("$.status").value("FAILED"))
			.andRespond(withStatus(HttpStatus.NO_CONTENT));

		client.update("payments", Map.of("id", "eq.1"), Map.of("status", "FAILED"));

		server.verify();
	}

	@Test
	void upsertMergesDuplicates() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/metrics?on_conflict=branch_id,period_start,period_end"))
			.andExpect(method(HttpMethod.POST))
			.andExpect(header("Prefer", "resolution=merge-duplicates,return=minimal"))
			.andRespond(withStatus(HttpStatus.CREATED));

		client.upsert("metrics", "branch_id,period_start,period_end", Map.of("scan_count", 0));

		server.verify();
	}

	@Test
	void rpcReturnsValue() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/rpc/confirm_payment_success"))
			.andExpect(method(HttpMethod.POST))
			.andRespond(withSuccess("\"CONFIRMED\"", MediaType.APPLICATION_JSON));

		assertThat(client.rpc("confirm_payment_success", Map.of(), String.class)).isEqualTo("CONFIRMED");
	}

	@Test
	void errorBecomesSupabaseException() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/plans?select=id"))
			.andRespond(withStatus(HttpStatus.CONFLICT).contentType(MediaType.APPLICATION_JSON)
				.body("{\"code\":\"23505\",\"message\":\"duplicate\"}"));

		assertThatThrownBy(() -> client.select("plans", Map.of("select", "id"), ROWS)).isInstanceOf(SupabaseException.class)
			.hasFieldOrPropertyWithValue("code", "23505");
	}

	@Test
	void unreadableErrorStillBecomesSupabaseException() {
		SupabaseAdminClient client = client("sb_secret_x");
		server.expect(requestTo(REST + "/plans?select=id")).andRespond(withStatus(HttpStatus.BAD_GATEWAY).body("<html>"));

		assertThatThrownBy(() -> client.select("plans", Map.of("select", "id"), ROWS)).isInstanceOf(SupabaseException.class)
			.hasFieldOrPropertyWithValue("status", 502);
	}

}
