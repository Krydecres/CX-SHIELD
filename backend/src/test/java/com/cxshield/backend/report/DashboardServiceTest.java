package com.cxshield.backend.report;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.report.DashboardRepository.MetricRow;
import com.cxshield.backend.report.DashboardRepository.SurveyStats;
import com.cxshield.backend.report.DashboardRepository.WeeklyStats;
import com.cxshield.backend.report.dto.DashboardDtos.DashboardResponse;
import com.cxshield.backend.report.dto.DashboardDtos.WeeklyPoint;

class DashboardServiceTest {

	private static final String TOKEN = "token";
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final UUID OTHER_BRANCH = UUID.randomUUID();
	private static final LocalDate TODAY = LocalDate.of(2026, 11, 6);
	private static final LocalDate WEEK_1 = LocalDate.of(2026, 10, 26);
	private static final LocalDate WEEK_2 = LocalDate.of(2026, 11, 2);

	private AccountRepository accountRepository;
	private DashboardRepository repository;
	private DashboardService service;

	@BeforeEach
	void setUp() {
		accountRepository = mock(AccountRepository.class);
		repository = mock(DashboardRepository.class);
		service = new DashboardService(accountRepository, repository,
				Clock.fixed(Instant.parse("2026-11-06T03:00:00Z"), ZoneOffset.UTC));
		when(accountRepository.findBranches(TOKEN, BUSINESS_ID)).thenReturn(
				List.of(new BranchRow(BRANCH_ID, BUSINESS_ID, "CN01", "Q1", null, null, "ACTIVE", null),
						new BranchRow(OTHER_BRANCH, BUSINESS_ID, "CN02", "Q3", null, null, "ACTIVE", null)));
		when(repository.getSurveyStats(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(new SurveyStats(0, 0, 0, 0, List.of()));
		when(repository.findGoogleMetrics(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any())).thenReturn(List.of());
	}

	@Test
	void calculatesSatisfactionFromRatedResponses() {
		when(repository.getSurveyStats(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any())).thenReturn(new SurveyStats(10, 8, 6, 5,
				List.of(new WeeklyStats(WEEK_1, 4, 3, 1, 1), new WeeklyStats(WEEK_2, 6, 5, 5, 4))));

		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.scanCount()).isEqualTo(10);
		assertThat(response.ratedCount()).isEqualTo(8);
		assertThat(response.satisfactionRate()).isEqualTo(75.0);
		assertThat(response.googleRedirectCount()).isEqualTo(5);
		assertThat(response.weekly()).extracting(WeeklyPoint::weekStart).containsExactly(WEEK_1, WEEK_2);
		assertThat(response.weekly().get(0).satisfactionRate()).isEqualTo(33.3);
		assertThat(response.weekly().get(1).satisfactionRate()).isEqualTo(100.0);
	}

	@Test
	void emptyDataHasNoRate() {
		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.scanCount()).isZero();
		assertThat(response.satisfactionRate()).isNull();
		assertThat(response.googleReviewCount()).isNull();
		assertThat(response.googleAvgRating()).isNull();
		assertThat(response.weekly()).isEmpty();
	}

	@Test
	void weekWithScansButNoRatingHasNullRate() {
		when(repository.getSurveyStats(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(new SurveyStats(3, 0, 0, 0, List.of(new WeeklyStats(WEEK_1, 3, 0, 0, 0))));

		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.satisfactionRate()).isNull();
		assertThat(response.weekly().get(0).satisfactionRate()).isNull();
	}

	@Test
	void defaultRangeIsLastEightWeeks() {
		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.to()).isEqualTo(TODAY);
		assertThat(response.from()).isEqualTo(TODAY.minusDays(56));
	}

	@Test
	void passesBranchAndRangeToRepository() {
		LocalDate from = LocalDate.of(2026, 11, 4);

		service.getDashboard(TOKEN, BUSINESS_ID, BRANCH_ID, from, TODAY);

		verify(repository).getSurveyStats(TOKEN, BUSINESS_ID, BRANCH_ID, from, TODAY);
		// Thứ Tư 04/11 thuộc tuần bắt đầu từ thứ Hai 02/11.
		verify(repository).findGoogleMetrics(TOKEN, BUSINESS_ID, BRANCH_ID, WEEK_2, TODAY);
	}

	@Test
	void usesLatestGoogleWeekForCards() {
		when(repository.findGoogleMetrics(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(List.of(new MetricRow(BRANCH_ID, WEEK_1, 100, 4.2), new MetricRow(BRANCH_ID, WEEK_2, 110, 4.3)));

		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, BRANCH_ID, null, null);

		assertThat(response.googleReviewCount()).isEqualTo(110);
		assertThat(response.googleAvgRating()).isEqualTo(4.3);
		assertThat(response.weekly()).hasSize(2);
		assertThat(response.weekly().get(0).scanCount()).isZero();
		assertThat(response.weekly().get(0).googleReviewCount()).isEqualTo(100);
	}

	@Test
	void combinesBranchesWithWeightedRating() {
		when(repository.findGoogleMetrics(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(List.of(new MetricRow(BRANCH_ID, WEEK_2, 100, 5.0), new MetricRow(OTHER_BRANCH, WEEK_2, 300, 4.0)));

		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.googleReviewCount()).isEqualTo(400);
		assertThat(response.googleAvgRating()).isEqualTo(4.3);
	}

	@Test
	void ignoresMetricRowsWithoutGoogleData() {
		when(repository.findGoogleMetrics(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(List.of(new MetricRow(BRANCH_ID, WEEK_2, null, null)));

		assertThat(service.getDashboard(TOKEN, BUSINESS_ID, null, null, null).googleReviewCount()).isNull();
	}

	@Test
	void zeroGoogleReviewsHasNoRating() {
		when(repository.findGoogleMetrics(eq(TOKEN), eq(BUSINESS_ID), any(), any(), any()))
			.thenReturn(List.of(new MetricRow(BRANCH_ID, WEEK_2, 0, null)));

		DashboardResponse response = service.getDashboard(TOKEN, BUSINESS_ID, null, null, null);

		assertThat(response.googleReviewCount()).isZero();
		assertThat(response.googleAvgRating()).isNull();
	}

	@Test
	void rejectsReversedRange() {
		assertCode(() -> service.getDashboard(TOKEN, BUSINESS_ID, null, TODAY, TODAY.minusDays(1)), "INVALID_DATE_RANGE");
		verify(repository, never()).getSurveyStats(any(), any(), any(), any(), any());
	}

	@Test
	void rejectsRangeOverOneYear() {
		assertCode(() -> service.getDashboard(TOKEN, BUSINESS_ID, null, TODAY.minusDays(367), TODAY), "INVALID_DATE_RANGE");
	}

	@Test
	void rejectsBusinessWithoutAccess() {
		UUID other = UUID.randomUUID();
		when(accountRepository.findBranches(TOKEN, other)).thenReturn(List.of());

		assertCode(() -> service.getDashboard(TOKEN, other, null, null, null), "BUSINESS_NOT_FOUND");
	}

	@Test
	void rejectsBranchOfAnotherBusiness() {
		assertCode(() -> service.getDashboard(TOKEN, BUSINESS_ID, UUID.randomUUID(), null, null), "BRANCH_NOT_FOUND");
	}

	private static void assertCode(org.assertj.core.api.ThrowableAssert.ThrowingCallable call, String code) {
		assertThatThrownBy(call).isInstanceOf(ApiException.class).hasFieldOrPropertyWithValue("code", code);
	}

}
