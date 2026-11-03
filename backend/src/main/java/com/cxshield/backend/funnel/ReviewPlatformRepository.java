package com.cxshield.backend.funnel;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.supabase.SupabaseDataClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Bảng review_platforms (phân hệ 1), dùng cho cấu hình Google Place ID của chi nhánh.
 */
@Repository
public class ReviewPlatformRepository {

	public static final String GOOGLE = "GOOGLE";

	private static final ParameterizedTypeReference<List<ReviewPlatformRow>> ROWS = new ParameterizedTypeReference<>() {
	};
	private static final String COLUMNS = "id,business_id,branch_id,platform_name,google_place_id,review_direct_url,"
			+ "place_name,place_address,connection_status,is_active,updated_at";

	private final SupabaseDataClient supabase;

	public ReviewPlatformRepository(SupabaseDataClient supabase) {
		this.supabase = supabase;
	}

	public Optional<ReviewPlatformRow> findGoogle(String token, UUID branchId) {
		return supabase
			.select(token, "review_platforms", Map.of("select", COLUMNS, "branch_id", "eq." + branchId, "platform_name",
					"eq." + GOOGLE, "order", "created_at.asc", "limit", "1"), ROWS)
			.stream()
			.findFirst();
	}

	public Optional<ReviewPlatformRow> insert(String token, Map<String, Object> values) {
		return supabase.insert(token, "review_platforms", values, ROWS).stream().findFirst();
	}

	/**
	 * Trả về rỗng khi RLS không cho cập nhật (PostgREST không báo lỗi mà chỉ trả 0 dòng).
	 */
	public Optional<ReviewPlatformRow> update(String token, UUID id, Map<String, Object> values) {
		return supabase.update(token, "review_platforms", Map.of("id", "eq." + id), values, ROWS).stream().findFirst();
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record ReviewPlatformRow(UUID id, @JsonProperty("business_id") UUID businessId,
			@JsonProperty("branch_id") UUID branchId, @JsonProperty("platform_name") String platformName,
			@JsonProperty("google_place_id") String googlePlaceId,
			@JsonProperty("review_direct_url") String reviewDirectUrl, @JsonProperty("place_name") String placeName,
			@JsonProperty("place_address") String placeAddress,
			@JsonProperty("connection_status") String connectionStatus, @JsonProperty("is_active") Boolean isActive,
			@JsonProperty("updated_at") OffsetDateTime updatedAt) {
	}

}
