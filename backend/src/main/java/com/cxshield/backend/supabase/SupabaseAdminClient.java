package com.cxshield.backend.supabase;

import java.io.IOException;
import java.net.URI;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriBuilder;

import com.cxshield.backend.config.CxShieldProperties;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.json.JsonMapper;

/**
 * Gọi Supabase Data API bằng service role, bỏ qua RLS. Chỉ dùng cho việc không có người đăng nhập:
 * gửi cảnh báo khi khách góp ý, xác nhận thanh toán từ cổng, cập nhật số liệu định kỳ.
 * Luồng có người đăng nhập phải dùng {@link SupabaseDataClient} để RLS vẫn áp dụng.
 */
@Component
public class SupabaseAdminClient {

	private final RestClient restClient;
	private final JsonMapper jsonMapper;
	private final boolean enabled;

	@Autowired
	public SupabaseAdminClient(CxShieldProperties properties, JsonMapper jsonMapper) {
		this(properties, jsonMapper, RestClient.builder());
	}

	SupabaseAdminClient(CxShieldProperties properties, JsonMapper jsonMapper, RestClient.Builder builder) {
		this.jsonMapper = jsonMapper;
		CxShieldProperties.Supabase supabase = properties.supabase();
		this.enabled = supabase.serviceRoleEnabled();
		String key = enabled ? supabase.serviceRoleKey() : "";
		this.restClient = builder.baseUrl(supabase.restUrl())
			.defaultHeader("apikey", key)
			.defaultHeaders(headers -> {
				// Khoá service_role kiểu cũ là JWT; khoá sb_secret_ mới chỉ gửi qua header apikey.
				if (key.startsWith("eyJ")) {
					headers.set(HttpHeaders.AUTHORIZATION, "Bearer " + key);
				}
			})
			.defaultStatusHandler(HttpStatusCode::isError, (request, response) -> {
				PostgrestError error = readError(response.getBody().readAllBytes());
				throw new SupabaseException(response.getStatusCode().value(), error.code(), error.message());
			})
			.build();
	}

	public boolean isEnabled() {
		return enabled;
	}

	public <T> List<T> select(String table, Map<String, String> query, ParameterizedTypeReference<List<T>> type) {
		List<T> rows = restClient.get().uri(builder -> withQuery(builder.path("/" + table), query)).retrieve().body(type);
		return rows == null ? List.of() : rows;
	}

	public <T> List<T> insert(String table, Object body, ParameterizedTypeReference<List<T>> type) {
		List<T> rows = restClient.post()
			.uri("/" + table)
			.header("Prefer", "return=representation")
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.body(type);
		return rows == null ? List.of() : rows;
	}

	public void insertWithoutReturn(String table, Object body) {
		restClient.post()
			.uri("/" + table)
			.header("Prefer", "return=minimal")
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.toBodilessEntity();
	}

	public void update(String table, Map<String, String> filter, Object body) {
		restClient.patch()
			.uri(builder -> withQuery(builder.path("/" + table), filter))
			.header("Prefer", "return=minimal")
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.toBodilessEntity();
	}

	/**
	 * Ghi đè dòng trùng theo ràng buộc UNIQUE {@code onConflict}.
	 */
	public void upsert(String table, String onConflict, Object body) {
		restClient.post()
			.uri(builder -> builder.path("/" + table).queryParam("on_conflict", onConflict).build())
			.header("Prefer", "resolution=merge-duplicates,return=minimal")
			.contentType(MediaType.APPLICATION_JSON)
			.body(body)
			.retrieve()
			.toBodilessEntity();
	}

	public <T> T rpc(String function, Object args, Class<T> type) {
		// Đọc byte rồi tự parse JSON: nếu để RestClient đọc thẳng String thì giá trị còn nguyên dấu ngoặc kép.
		byte[] body = restClient.post()
			.uri("/rpc/" + function)
			.contentType(MediaType.APPLICATION_JSON)
			.body(args)
			.retrieve()
			.body(byte[].class);
		return jsonMapper.readValue(body, type);
	}

	private static URI withQuery(UriBuilder builder, Map<String, String> query) {
		query.keySet().forEach(key -> builder.queryParam(key, "{" + key + "}"));
		return builder.build(query);
	}

	private PostgrestError readError(byte[] body) throws IOException {
		try {
			return jsonMapper.readValue(body, PostgrestError.class);
		}
		catch (JacksonException ex) {
			return new PostgrestError(null, "Phản hồi lỗi không đọc được từ Supabase");
		}
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record PostgrestError(String code, String message) {
	}

}
