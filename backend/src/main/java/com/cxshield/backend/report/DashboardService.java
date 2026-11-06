package com.cxshield.backend.report;

import java.time.Clock;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.report.DashboardRepository.MetricRow;
import com.cxshield.backend.report.DashboardRepository.SurveyStats;
import com.cxshield.backend.report.DashboardRepository.WeeklyStats;
import com.cxshield.backend.report.dto.DashboardDtos.DashboardResponse;
import com.cxshield.backend.report.dto.DashboardDtos.WeeklyPoint;

/**
 * Dashboard tổng quan (E3.1 · D5-01). Tỷ lệ hài lòng = số lượt 4–5 sao / tổng lượt đánh giá.
 */
@Service
public class DashboardService {

	static final int DEFAULT_RANGE_DAYS = 56;
	static final int MAX_RANGE_DAYS = 366;

	private static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");

	private final AccountRepository accountRepository;
	private final DashboardRepository dashboardRepository;
	private final Clock clock;

	@Autowired
	public DashboardService(AccountRepository accountRepository, DashboardRepository dashboardRepository) {
		this(accountRepository, dashboardRepository, Clock.system(VIETNAM));
	}

	DashboardService(AccountRepository accountRepository, DashboardRepository dashboardRepository, Clock clock) {
		this.accountRepository = accountRepository;
		this.dashboardRepository = dashboardRepository;
		this.clock = clock;
	}

	public DashboardResponse getDashboard(String token, UUID businessId, UUID branchId, LocalDate requestedFrom,
			LocalDate requestedTo) {
		LocalDate to = requestedTo == null ? LocalDate.now(clock) : requestedTo;
		LocalDate from = requestedFrom == null ? to.minusDays(DEFAULT_RANGE_DAYS) : requestedFrom;
		validateRange(from, to);
		requireAccess(token, businessId, branchId);

		SurveyStats stats = dashboardRepository.getSurveyStats(token, businessId, branchId, from, to);
		// Tuần chứa ngày bắt đầu có thể bắt đầu trước from, nên mở rộng khoảng đọc metrics theo tuần.
		LocalDate metricsFrom = from.minusDays(from.getDayOfWeek().getValue() - 1L);
		TreeMap<LocalDate, GoogleWeek> google = groupByWeek(
				dashboardRepository.findGoogleMetrics(token, businessId, branchId, metricsFrom, to));

		Map<LocalDate, WeeklyStats> surveyWeeks = stats.weekly().stream()
			.collect(Collectors.toMap(WeeklyStats::weekStart, week -> week));
		TreeSet<LocalDate> weeks = new TreeSet<>(surveyWeeks.keySet());
		weeks.addAll(google.keySet());

		List<WeeklyPoint> points = new ArrayList<>();
		for (LocalDate week : weeks) {
			WeeklyStats survey = surveyWeeks.get(week);
			GoogleWeek googleWeek = google.get(week);
			points.add(new WeeklyPoint(week, survey == null ? 0 : survey.scanCount(),
					survey == null ? null : percent(survey.satisfiedCount(), survey.ratedCount()),
					survey == null ? 0 : survey.googleRedirectCount(), googleWeek == null ? null : googleWeek.reviewCount(),
					googleWeek == null ? null : googleWeek.avgRating()));
		}

		GoogleWeek latest = google.isEmpty() ? null : google.lastEntry().getValue();
		return new DashboardResponse(branchId, from, to, stats.scanCount(), stats.ratedCount(),
				percent(stats.satisfiedCount(), stats.ratedCount()), stats.googleRedirectCount(),
				latest == null ? null : latest.reviewCount(), latest == null ? null : latest.avgRating(), points);
	}

	private void requireAccess(String token, UUID businessId, UUID branchId) {
		List<BranchRow> branches = accountRepository.findBranches(token, businessId);
		if (branches.isEmpty()) {
			throw ApiException.notFound("BUSINESS_NOT_FOUND", "Không tìm thấy cơ sở hoặc bạn không có quyền truy cập.");
		}
		if (branchId != null && branches.stream().noneMatch(branch -> branch.id().equals(branchId))) {
			throw ApiException.notFound("BRANCH_NOT_FOUND", "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập.");
		}
	}

	private static void validateRange(LocalDate from, LocalDate to) {
		if (from.isAfter(to)) {
			throw ApiException.badRequest("INVALID_DATE_RANGE", "Ngày bắt đầu phải trước ngày kết thúc.");
		}
		if (ChronoUnit.DAYS.between(from, to) > MAX_RANGE_DAYS) {
			throw ApiException.badRequest("INVALID_DATE_RANGE", "Khoảng thời gian không được vượt quá 1 năm.");
		}
	}

	/**
	 * Gộp các chi nhánh theo tuần: cộng số đánh giá, điểm sao lấy trung bình theo số đánh giá.
	 */
	private static TreeMap<LocalDate, GoogleWeek> groupByWeek(List<MetricRow> rows) {
		Map<LocalDate, List<MetricRow>> byWeek = rows.stream()
			.filter(row -> row.googleReviewCount() != null)
			.collect(Collectors.groupingBy(MetricRow::periodStart, TreeMap::new, Collectors.toList()));
		TreeMap<LocalDate, GoogleWeek> weeks = new TreeMap<>();
		byWeek.forEach((week, metrics) -> {
			int count = metrics.stream().mapToInt(MetricRow::googleReviewCount).sum();
			double weighted = metrics.stream()
				.filter(metric -> metric.googleAvgRating() != null)
				.mapToDouble(metric -> metric.googleAvgRating() * metric.googleReviewCount())
				.sum();
			weeks.put(week, new GoogleWeek(count, count == 0 ? null : round(weighted / count)));
		});
		return weeks;
	}

	private static Double percent(long part, long total) {
		return total == 0 ? null : round(part * 100.0 / total);
	}

	private static double round(double value) {
		return Math.round(value * 10) / 10.0;
	}

	private record GoogleWeek(int reviewCount, Double avgRating) {
	}

}
