package com.cxshield.backend.report;

import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.supabase.SupabaseDataClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Số liệu D5-01 tính từ survey_sessions / survey_responses, cùng số liệu Google trong bảng metrics.
 * Gọi bằng token người dùng nên RLS giới hạn dữ liệu theo chi nhánh được xem.
 */
@Repository
public class DashboardRepository {

	private static final ParameterizedTypeReference<List<MetricRow>> METRIC_ROWS = new ParameterizedTypeReference<>() {
	};

	private final SupabaseDataClient supabase;

	public DashboardRepository(SupabaseDataClient supabase) {
		this.supabase = supabase;
	}

	public SurveyStats getSurveyStats(String token, UUID businessId, UUID branchId, LocalDate from, LocalDate to) {
		Map<String, Object> args = new LinkedHashMap<>();
		args.put("p_business_id", businessId);
		args.put("p_branch_id", branchId);
		args.put("p_from", from.toString());
		args.put("p_to", to.toString());
		return supabase.rpc(token, "get_dashboard_stats", args, SurveyStats.class);
	}

	public List<MetricRow> findGoogleMetrics(String token, UUID businessId, UUID branchId, LocalDate from, LocalDate to) {
		Map<String, String> query = new LinkedHashMap<>();
		query.put("select", "branch_id,period_start,google_review_count,google_avg_rating,branches!inner(business_id)");
		query.put("branches.business_id", "eq." + businessId);
		query.put("and", "(period_start.gte." + from + ",period_start.lte." + to + ")");
		query.put("order", "period_start.asc");
		if (branchId != null) {
			query.put("branch_id", "eq." + branchId);
		}
		return supabase.select(token, "metrics", query, METRIC_ROWS);
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record SurveyStats(long scanCount, long ratedCount, long satisfiedCount, long googleRedirectCount,
			List<WeeklyStats> weekly) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record WeeklyStats(LocalDate weekStart, long scanCount, long ratedCount, long satisfiedCount,
			long googleRedirectCount) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record MetricRow(@JsonProperty("branch_id") UUID branchId, @JsonProperty("period_start") LocalDate periodStart,
			@JsonProperty("google_review_count") Integer googleReviewCount,
			@JsonProperty("google_avg_rating") Double googleAvgRating) {
	}

}
