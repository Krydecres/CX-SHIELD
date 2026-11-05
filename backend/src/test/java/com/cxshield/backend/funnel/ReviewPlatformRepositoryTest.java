package com.cxshield.backend.funnel;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.supabase.SupabaseDataClient;

class ReviewPlatformRepositoryTest {

	private static final String TOKEN = "token";
	private static final UUID ID = UUID.randomUUID();

	private SupabaseDataClient supabase;
	private ReviewPlatformRepository repository;

	@BeforeEach
	void setUp() {
		supabase = mock(SupabaseDataClient.class);
		repository = new ReviewPlatformRepository(supabase);
	}

	@Test
	@SuppressWarnings("unchecked")
	void findsOnlyGooglePlatformOfBranch() {
		when(supabase.select(eq(TOKEN), eq("review_platforms"), anyMap(), any())).thenReturn(List.of());

		assertThat(repository.findGoogle(TOKEN, ID)).isEmpty();

		ArgumentCaptor<Map<String, String>> query = ArgumentCaptor.forClass(Map.class);
		verify(supabase).select(eq(TOKEN), eq("review_platforms"), query.capture(), any());
		assertThat(query.getValue()).containsEntry("branch_id", "eq." + ID)
			.containsEntry("platform_name", "eq.GOOGLE")
			.containsEntry("limit", "1");
	}

	@Test
	void updateIsEmptyWhenRlsBlocksIt() {
		when(supabase.update(eq(TOKEN), eq("review_platforms"), eq(Map.of("id", "eq." + ID)), any(), any()))
			.thenReturn(List.of());

		assertThat(repository.update(TOKEN, ID, Map.of("is_active", true))).isEmpty();
	}

}
