package com.cxshield.backend.report;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.report.dto.DashboardDtos.DashboardResponse;
import com.cxshield.backend.report.dto.DashboardDtos.WeeklyPoint;

@SpringBootTest
@AutoConfigureMockMvc
class DashboardControllerSecurityTest {

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private DashboardService dashboardService;

	private static final UUID BUSINESS_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");
	private static final UUID BRANCH_ID = UUID.fromString("22222222-2222-2222-2222-222222222222");
	private static final LocalDate FROM = LocalDate.of(2026, 9, 11);
	private static final LocalDate TO = LocalDate.of(2026, 11, 6);

	@Test
	@DisplayName("TC-D501-AUT-API-01: Chặn 401 khi thiếu Bearer Token")
	void unauthenticatedRequestReturns401() throws Exception {
		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID))
			.andExpect(status().isUnauthorized());
	}

	@Test
	@DisplayName("TC-D501-AUT-API-02: Trả về 200 và đầy đủ dữ liệu khi có JWT hợp lệ")
	void authenticatedRequestReturns200WithFullData() throws Exception {
		DashboardResponse mockResponse = new DashboardResponse(
			null, FROM, TO, 1248, 1000, 825, 82.5, 684, 1032, 4.6,
			List.of(new WeeklyPoint(LocalDate.of(2026, 11, 2), 1248, 82.5, 684, 1032, 4.6))
		);

		when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), isNull(), isNull(), isNull()))
			.thenReturn(mockResponse);

		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
				.with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.scanCount").value(1248))
			.andExpect(jsonPath("$.ratedCount").value(1000))
			.andExpect(jsonPath("$.satisfiedCount").value(825))
			.andExpect(jsonPath("$.satisfactionRate").value(82.5))
			.andExpect(jsonPath("$.googleRedirectCount").value(684))
			.andExpect(jsonPath("$.googleReviewCount").value(1032))
			.andExpect(jsonPath("$.googleAvgRating").value(4.6))
			.andExpect(jsonPath("$.weekly[0].scanCount").value(1248));
	}

	@Test
	@DisplayName("TC-D501-AUT-API-03: Truyền đúng branchId và khoảng ngày vào service")
	void authenticatedRequestWithBranchAndDateFilters() throws Exception {
		DashboardResponse mockResponse = new DashboardResponse(
			BRANCH_ID, FROM, TO, 500, 400, 320, 80.0, 200, 500, 4.5, List.of()
		);

		when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), eq(BRANCH_ID), eq(FROM), eq(TO)))
			.thenReturn(mockResponse);

		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
				.param("branchId", BRANCH_ID.toString())
				.param("from", FROM.toString())
				.param("to", TO.toString())
				.with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.branchId").value(BRANCH_ID.toString()))
			.andExpect(jsonPath("$.scanCount").value(500))
			.andExpect(jsonPath("$.satisfactionRate").value(80.0));

		verify(dashboardService).getDashboard(any(), eq(BUSINESS_ID), eq(BRANCH_ID), eq(FROM), eq(TO));
	}

	@Test
	@DisplayName("TC-D501-AUT-API-04: Xử lý 404 khi người dùng không có quyền trên cơ sở")
	void authenticatedRequestWithoutBusinessAccessReturns404() throws Exception {
		when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), any(), any(), any()))
			.thenThrow(ApiException.notFound("BUSINESS_NOT_FOUND", "Không tìm thấy cơ sở hoặc bạn không có quyền"));

		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
				.with(jwt().jwt(token -> token.tokenValue("unauthorized-jwt").subject("user-other"))))
			.andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("BUSINESS_NOT_FOUND"));
	}

	@Test
	@DisplayName("TC-D501-AUT-API-05: Xử lý 400 khi khoảng ngày đảo ngược")
	void authenticatedRequestWithReversedDateRangeReturns400() throws Exception {
		when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), any(), eq(TO), eq(FROM)))
			.thenThrow(ApiException.badRequest("INVALID_DATE_RANGE", "Ngày bắt đầu phải trước ngày kết thúc"));

		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
				.param("from", TO.toString())
				.param("to", FROM.toString())
				.with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("INVALID_DATE_RANGE"));
	}

	@Test
	@DisplayName("TC-D501-AUT-API-06: Chặn 400 khi businessId sai định dạng UUID")
	void authenticatedRequestWithMalformedUuidReturns400() throws Exception {
		mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", "invalid-uuid-format")
				.with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
			.andExpect(status().isBadRequest());
	}
}
