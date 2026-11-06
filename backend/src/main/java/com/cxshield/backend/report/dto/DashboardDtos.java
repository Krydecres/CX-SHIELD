package com.cxshield.backend.report.dto;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public final class DashboardDtos {

	private DashboardDtos() {
	}

	/**
	 * satisfactionRate là phần trăm (0–100), null khi chưa có lượt đánh giá.
	 * Số liệu Google null khi chưa đồng bộ được từ Google.
	 */
	public record DashboardResponse(UUID branchId, LocalDate from, LocalDate to, long scanCount, long ratedCount,
			long satisfiedCount, Double satisfactionRate, long googleRedirectCount, Integer googleReviewCount,
			Double googleAvgRating, List<WeeklyPoint> weekly) {
	}

	public record WeeklyPoint(LocalDate weekStart, long scanCount, Double satisfactionRate, long googleRedirectCount,
			Integer googleReviewCount, Double googleAvgRating) {
	}

}
