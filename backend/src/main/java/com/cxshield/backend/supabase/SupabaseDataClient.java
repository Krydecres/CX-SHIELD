package com.cxshield.backend.supabase;

import java.io.IOException;
import java.net.URI;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.client.ClientHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriBuilder;

import com.cxshield.backend.config.CxShieldProperties;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.json.JsonMapper;

/**
 * Gọi Supabase Data API (PostgREST) bằng access token của người dùng,
 * để các RLS policy trên CSDL được áp dụng đúng theo người đang đăng nhập.
 */
@Component
public class SupabaseDataClient {

	private final RestClient restClient;
	private final JsonMapper jsonMapper;

	@Autowired
	public SupabaseDataClient(CxShieldProperties properties, JsonMapper jsonMapper) {
		this(properties, jsonMapper, RestClient.builder());
	}

	SupabaseDataClient(CxShieldProperties properties, JsonMapper jsonMapper, RestClient.Builder builder) {
		this.jsonMapper = jsonMapper;
		this.restClient = builder
			.baseUrl(properties.supabase().restUrl())
			.defaultHeader("apikey", properties.supabase().publishableKey())
			.defaultStatusHandler(HttpStatusCode::isError, (request, response) -> {
				PostgrestError error = readError(response);
				throw new SupabaseException(response.getStatusCode().value(), error.code(), error.message());
			})
			.build();
	}

	public <T> List<T> select(String accessToken, String table, Map<String, String> query,
			ParameterizedTypeReference<List<T>> type) {
		List<T> rows = restClient.get()
			.uri(builder -> withQuery(builder.path("/" + table), query))
			.headers(headers -> headers.setBearerAuth(accessToken))
			.retrieve()
			.body(type);
		return rows == null ? List.of() : rows;
	}

	public <T> List<T> insert(String accessToken, String table, Object body, ParameterizedTypeReference<List<T>> type) {
		List<T> rows = restClient.post()
			.uri("/" + table)
			.headers(headers -> {
				headers.setBearerAuth(accessToken);
				headers.set("Prefer", "return=representation");
			})
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.body(type);
		return rows == null ? List.of() : rows;
	}

	/**
	 * Insert không đọc lại dòng mới. Dùng khi SELECT policy của bảng chưa thấy dòng vừa tạo
	 * trong cùng câu lệnh (ví dụ branches: policy kiểm tra quyền dựa trên chính bảng branches).
	 */
	public void insertWithoutReturn(String accessToken, String table, Object body) {
		restClient.post()
			.uri("/" + table)
			.headers(headers -> {
				headers.setBearerAuth(accessToken);
				headers.set("Prefer", "return=minimal");
			})
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.toBodilessEntity();
	}

	public <T> List<T> update(String accessToken, String table, Map<String, String> filter, Object body,
			ParameterizedTypeReference<List<T>> type) {
		List<T> rows = restClient.patch()
			.uri(builder -> withQuery(builder.path("/" + table), filter))
			.headers(headers -> {
				headers.setBearerAuth(accessToken);
				headers.set("Prefer", "return=representation");
			})
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.body(type);
		return rows == null ? List.of() : rows;
	}

	public <T> T rpc(String accessToken, String function, Object args, Class<T> type) {
		return restClient.post()
			.uri("/rpc/" + function)
			.headers(headers -> headers.setBearerAuth(accessToken))
			.contentType(MediaType.APPLICATION_JSON)
			.body(args)
			.retrieve()
			.body(type);
	}

	// Giá trị lọc của PostgREST (eq.xxx, select=a,b(c)) được truyền qua biến URI để luôn được mã hoá đúng.
	private static URI withQuery(UriBuilder builder, Map<String, String> query) {
		query.keySet().forEach(key -> builder.queryParam(key, "{" + key + "}"));
		return builder.build(query);
	}

	private PostgrestError readError(ClientHttpResponse response) {
		try {
			byte[] body = response.getBody().readAllBytes();
			return jsonMapper.readValue(body, PostgrestError.class);
		}
		catch (IOException | JacksonException ex) {
			return new PostgrestError(null, "Phản hồi lỗi không đọc được từ Supabase");
		}
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record PostgrestError(String code, String message) {
	}

}
