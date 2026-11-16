package com.cxshield.backend.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.core.ParameterizedTypeReference;

import com.cxshield.backend.funnel.GooglePlacesClient;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceStats;
import com.cxshield.backend.report.GoogleMetricsSnapshotJob.PlatformRow;
import com.cxshield.backend.supabase.SupabaseAdminClient;

class GoogleMetricsSnapshotJobTest {

	private static final UUID BRANCH_ID = UUID.randomUUID();

	private SupabaseAdminClient supabase;
	private GooglePlacesClient places;
	private GoogleMetricsSnapshotJob job;

	@BeforeEach
	void setUp() {
		supabase = mock(SupabaseAdminClient.class);
		places = mock(GooglePlacesClient.class);
		// 06/11/2026 là thứ Sáu.
		job = new GoogleMetricsSnapshotJob(supabase, places, Clock.fixed(Instant.parse("2026-11-06T03:00:00Z"), ZoneOffset.UTC));
		when(supabase.isEnabled()).thenReturn(true);
		when(places.isEnabled()).thenReturn(true);
		when(supabase.select(eq("review_platforms"), anyMap(), any(ParameterizedTypeReference.class)))
			.thenReturn(List.of(new PlatformRow(BRANCH_ID, "place-1")));
	}

	@Test
	@SuppressWarnings({ "unchecked", "rawtypes" })
	void savesStatsIntoCurrentWeek() {
		when(places.lookupStats("place-1")).thenReturn(Optional.of(new PlaceStats(120, 4.6)));

		job.snapshot();

		ArgumentCaptor<Map<String, Object>> values = (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
		verify(supabase).upsert(eq("metrics"), eq("branch_id,period_start,period_end"), values.capture());
		assertThat(values.getValue()).containsEntry("branch_id", BRANCH_ID)
			.containsEntry("period_start", "2026-11-02")
			.containsEntry("period_end", "2026-11-08")
			.containsEntry("google_review_count", 120)
			.containsEntry("google_avg_rating", 4.6);
	}

	@Test
	void skipsBranchWithoutGoogleData() {
		when(places.lookupStats("place-1")).thenReturn(Optional.empty());

		job.snapshot();

		verify(supabase, never()).upsert(anyString(), anyString(), any());
	}

	@Test
	void doesNothingWithoutServiceRoleKey() {
		when(supabase.isEnabled()).thenReturn(false);

		job.snapshot();

		verify(places, never()).lookupStats(anyString());
	}

	@Test
	void doesNothingWithoutPlacesKey() {
		when(places.isEnabled()).thenReturn(false);

		job.snapshot();

		verify(places, never()).lookupStats(anyString());
	}

}
