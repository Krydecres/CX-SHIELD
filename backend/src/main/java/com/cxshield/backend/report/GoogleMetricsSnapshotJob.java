package com.cxshield.backend.report;

import java.time.Clock;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.TemporalAdjusters;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.cxshield.backend.funnel.GooglePlacesClient;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceStats;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Mỗi ngày lưu số đánh giá và điểm sao Google của từng chi nhánh vào dòng metrics của tuần hiện tại.
 * Cần GOOGLE_PLACES_API_KEY và SUPABASE_SERVICE_ROLE_KEY; thiếu thì bỏ qua và Dashboard hiện "Chưa có dữ liệu".
 */
@Component
public class GoogleMetricsSnapshotJob {

	private static final Logger log = LoggerFactory.getLogger(GoogleMetricsSnapshotJob.class);
	private static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");
	private static final ParameterizedTypeReference<List<PlatformRow>> PLATFORM_ROWS = new ParameterizedTypeReference<>() {
	};

	private final SupabaseAdminClient supabase;
	private final GooglePlacesClient placesClient;
	private final Clock clock;

	@Autowired
	public GoogleMetricsSnapshotJob(SupabaseAdminClient supabase, GooglePlacesClient placesClient) {
		this(supabase, placesClient, Clock.system(VIETNAM));
	}

	GoogleMetricsSnapshotJob(SupabaseAdminClient supabase, GooglePlacesClient placesClient, Clock clock) {
		this.supabase = supabase;
		this.placesClient = placesClient;
		this.clock = clock;
	}

	@Scheduled(cron = "0 0 1 * * *", zone = "Asia/Ho_Chi_Minh")
	public void snapshot() {
		if (!supabase.isEnabled() || !placesClient.isEnabled()) {
			return;
		}
		LocalDate today = LocalDate.now(clock);
		LocalDate weekStart = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
		List<PlatformRow> platforms = supabase.select("review_platforms", Map.of("select", "branch_id,google_place_id",
				"platform_name", "eq.GOOGLE", "is_active", "eq.true", "google_place_id", "not.is.null"), PLATFORM_ROWS);
		for (PlatformRow platform : platforms) {
			placesClient.lookupStats(platform.googlePlaceId())
				.ifPresent(stats -> save(platform.branchId(), weekStart, stats));
		}
		log.info("Đã cập nhật số liệu Google cho {} chi nhánh", platforms.size());
	}

	private void save(UUID branchId, LocalDate weekStart, PlaceStats stats) {
		Map<String, Object> values = new LinkedHashMap<>();
		values.put("branch_id", branchId);
		values.put("period_start", weekStart.toString());
		values.put("period_end", weekStart.plusDays(6).toString());
		values.put("google_review_count", stats.reviewCount());
		values.put("google_avg_rating", stats.rating());
		supabase.upsert("metrics", "branch_id,period_start,period_end", values);
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record PlatformRow(@JsonProperty("branch_id") UUID branchId, @JsonProperty("google_place_id") String googlePlaceId) {
	}

}
