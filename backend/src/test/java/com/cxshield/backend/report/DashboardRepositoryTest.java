package com.cxshield.backend.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import java.time.LocalDate;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.core.ParameterizedTypeReference;

import com.cxshield.backend.report.DashboardRepository.SurveyStats;
import com.cxshield.backend.supabase.SupabaseDataClient;

class DashboardRepositoryTest {

	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final LocalDate FROM = LocalDate.of(2026, 11, 2);
	private static final LocalDate TO = LocalDate.of(2026, 11, 6);

	private SupabaseDataClient supabase;
	private DashboardRepository repository;

	@BeforeEach
	void setUp() {
		supabase = mock(SupabaseDataClient.class);
		repository = new DashboardRepository(supabase);
	}

	@Test
	@SuppressWarnings({ "unchecked", "rawtypes" })
	void surveyStatsCallsRpcWithNullBranchForAllBranches() {
		repository.getSurveyStats("token", BUSINESS_ID, null, FROM, TO);

		ArgumentCaptor<Map<String, Object>> args = (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
		verify(supabase).rpc(eq("token"), eq("get_dashboard_stats"), args.capture(), eq(SurveyStats.class));
		assertThat(args.getValue()).containsEntry("p_business_id", BUSINESS_ID)
			.containsEntry("p_branch_id", null)
			.containsEntry("p_from", "2026-11-02")
			.containsEntry("p_to", "2026-11-06");
	}

	@Test
	@SuppressWarnings({ "unchecked", "rawtypes" })
	void metricsFilterByBusinessAndPeriod() {
		repository.findGoogleMetrics("token", BUSINESS_ID, null, FROM, TO);

		ArgumentCaptor<Map<String, String>> query = (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
		verify(supabase).select(eq("token"), eq("metrics"), query.capture(), any(ParameterizedTypeReference.class));
		assertThat(query.getValue()).containsEntry("branches.business_id", "eq." + BUSINESS_ID)
			.containsEntry("and", "(period_start.gte.2026-11-02,period_start.lte.2026-11-06)")
			.doesNotContainKey("branch_id");
	}

	@Test
	@SuppressWarnings({ "unchecked", "rawtypes" })
	void metricsFilterByBranchWhenSelected() {
		repository.findGoogleMetrics("token", BUSINESS_ID, BRANCH_ID, FROM, TO);

		ArgumentCaptor<Map<String, String>> query = (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
		verify(supabase).select(eq("token"), eq("metrics"), query.capture(), any(ParameterizedTypeReference.class));
		assertThat(query.getValue()).containsEntry("branch_id", "eq." + BRANCH_ID);
	}

}
