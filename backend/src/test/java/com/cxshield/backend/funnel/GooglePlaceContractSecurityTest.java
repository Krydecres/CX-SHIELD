package com.cxshield.backend.funnel;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.OffsetDateTime;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.GooglePlaceConfigResponse;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.SaveGooglePlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceResponse;

/**
 * SCRUM-196: Backend Source Code, Security, Authorization & API Contract Tests
 * cho phân hệ Google Place ID (/api/v1/branches/{branchId}/google-place).
 */
@SpringBootTest
@AutoConfigureMockMvc
class GooglePlaceContractSecurityTest {

	private static final UUID BRANCH_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");
	private static final UUID OTHER_BRANCH_ID = UUID.fromString("22222222-2222-2222-2222-222222222222");
	private static final String VALID_PLACE_ID = "ChIJN1t_tDeuEmsRUsoyG83frY4";
	private static final String REVIEW_URL = "https://search.google.com/local/writereview?placeid=" + VALID_PLACE_ID;

	@Autowired
	private MockMvc mockMvc;

	@MockitoBean
	private GooglePlaceService googlePlaceService;

	// -------------------------------------------------------------------------
	// 1. Authentication & Security (401 Unauthorized)
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-01: Chặn 401 khi GET cấu hình mà không có JWT token")
	void getWithoutTokenReturns401() throws Exception {
		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", BRANCH_ID))
			.andExpect(status().isUnauthorized());

		verify(googlePlaceService, never()).getConfig(any(), any());
	}

	@Test
	@DisplayName("TC-196-02: Chặn 401 khi POST xác minh mà không có JWT token")
	void verifyWithoutTokenReturns401() throws Exception {
		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isUnauthorized());

		verify(googlePlaceService, never()).verify(any(), any(), any());
	}

	@Test
	@DisplayName("TC-196-03: Chặn 401 khi PUT lưu cấu hình mà không có JWT token")
	void saveWithoutTokenReturns401() throws Exception {
		mockMvc.perform(put("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isUnauthorized());

		verify(googlePlaceService, never()).save(any(), any(), any());
	}

	// -------------------------------------------------------------------------
	// 2. Branch Authorization & Access Control (404 / 403)
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-04: Trả về 404 BRANCH_NOT_FOUND khi người dùng truy cập chi nhánh ngoài phạm vi cho phép")
	void getForInaccessibleBranchReturns404() throws Exception {
		when(googlePlaceService.getConfig(any(), eq(OTHER_BRANCH_ID)))
			.thenThrow(ApiException.notFound("BRANCH_NOT_FOUND", "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."));

		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", OTHER_BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString()))))
			.andExpect(status().isNotFound())
			.andExpect(jsonPath("$.code").value("BRANCH_NOT_FOUND"))
			.andExpect(jsonPath("$.message").value("Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."));
	}

	@Test
	@DisplayName("TC-196-05: Trả về 403 FORBIDDEN khi người dùng không có quyền quản trị chi nhánh để lưu cấu hình")
	void saveForbiddenWhenUserLacksManagementPermission() throws Exception {
		SaveGooglePlaceRequest request = new SaveGooglePlaceRequest(VALID_PLACE_ID, null);
		when(googlePlaceService.save(any(), eq(BRANCH_ID), eq(request)))
			.thenThrow(ApiException.forbidden("Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."));

		mockMvc.perform(put("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isForbidden())
			.andExpect(jsonPath("$.code").value("FORBIDDEN"))
			.andExpect(jsonPath("$.message").value("Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."));
	}

	// -------------------------------------------------------------------------
	// 3. API Contract: GET /api/v1/branches/{branchId}/google-place
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-06: API Contract GET cấu hình trả về đúng schema và HTTP 200")
	void getConfigReturnsValidSchemaAnd200() throws Exception {
		OffsetDateTime now = OffsetDateTime.now();
		GooglePlaceConfigResponse response = new GooglePlaceConfigResponse(
				BRANCH_ID, "Chi nhánh Quận 1", VALID_PLACE_ID, "Maison Central",
				"1 Lê Lợi, P. Bến Nghé, Q.1, TP.HCM", REVIEW_URL, "CONNECTED", now, true);

		when(googlePlaceService.getConfig(any(), eq(BRANCH_ID))).thenReturn(response);

		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString()))))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.branchId").value(BRANCH_ID.toString()))
			.andExpect(jsonPath("$.branchName").value("Chi nhánh Quận 1"))
			.andExpect(jsonPath("$.placeId").value(VALID_PLACE_ID))
			.andExpect(jsonPath("$.placeName").value("Maison Central"))
			.andExpect(jsonPath("$.placeAddress").value("1 Lê Lợi, P. Bến Nghé, Q.1, TP.HCM"))
			.andExpect(jsonPath("$.reviewUrl").value(REVIEW_URL))
			.andExpect(jsonPath("$.connectionStatus").value("CONNECTED"))
			.andExpect(jsonPath("$.updatedAt").exists())
			.andExpect(jsonPath("$.googleVerificationEnabled").value(true));
	}

	@Test
	@DisplayName("TC-196-07: Trả về 400 BAD_REQUEST khi branchId không phải định dạng UUID hợp lệ")
	void getWithInvalidUuidReturns400() throws Exception {
		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", "not-a-valid-uuid")
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString()))))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("BAD_REQUEST"))
			.andExpect(jsonPath("$.message").value("Yêu cầu không hợp lệ."));
	}

	// -------------------------------------------------------------------------
	// 4. API Contract & Validation: POST .../verifications
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-08: Xác minh Place ID rỗng trả về 400 VALIDATION_ERROR")
	void verifyWithEmptyPlaceIdReturnsValidationError() throws Exception {
		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"\"}"))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
			.andExpect(jsonPath("$.fieldErrors.placeId").value("Vui lòng nhập Google Place ID."));

		verify(googlePlaceService, never()).verify(any(), any(), any());
	}

	@Test
	@DisplayName("TC-196-09: Xác minh Place ID sai định dạng (quá ngắn/chứa ký tự lạ) trả về 400 INVALID_PLACE_ID")
	void verifyWithInvalidFormatReturnsInvalidPlaceId() throws Exception {
		when(googlePlaceService.verify(any(), eq(BRANCH_ID), eq("invalid_short_id")))
			.thenThrow(ApiException.badRequest("INVALID_PLACE_ID",
					"Place ID sai định dạng. Place ID gồm chữ, số, dấu - hoặc _ và thường bắt đầu bằng \"ChIJ\"."));

		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"invalid_short_id\"}"))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("INVALID_PLACE_ID"));
	}

	@Test
	@DisplayName("TC-196-10: Xác minh thành công khi Google API trả về địa điểm tồn tại (CONNECTED)")
	void verifyPlaceFoundReturnsConnected() throws Exception {
		VerifyPlaceResponse response = new VerifyPlaceResponse(
				VALID_PLACE_ID, "Maison Central", "1 Lê Lợi, Q1", REVIEW_URL, "CONNECTED", true,
				"Đã xác minh địa điểm với Google.");

		when(googlePlaceService.verify(any(), eq(BRANCH_ID), eq(VALID_PLACE_ID))).thenReturn(response);

		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.placeId").value(VALID_PLACE_ID))
			.andExpect(jsonPath("$.placeName").value("Maison Central"))
			.andExpect(jsonPath("$.placeAddress").value("1 Lê Lợi, Q1"))
			.andExpect(jsonPath("$.reviewUrl").value(REVIEW_URL))
			.andExpect(jsonPath("$.connectionStatus").value("CONNECTED"))
			.andExpect(jsonPath("$.verifiedWithGoogle").value(true))
			.andExpect(jsonPath("$.message").value("Đã xác minh địa điểm với Google."));
	}

	@Test
	@DisplayName("TC-196-11: Xác minh trả về ERROR khi Google API không tìm thấy địa điểm (NOT_FOUND)")
	void verifyPlaceNotFoundReturnsErrorStatus() throws Exception {
		VerifyPlaceResponse response = new VerifyPlaceResponse(
				VALID_PLACE_ID, null, null, null, "ERROR", true,
				"Google không tìm thấy địa điểm với Place ID này.");

		when(googlePlaceService.verify(any(), eq(BRANCH_ID), eq(VALID_PLACE_ID))).thenReturn(response);

		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.placeId").value(VALID_PLACE_ID))
			.andExpect(jsonPath("$.connectionStatus").value("ERROR"))
			.andExpect(jsonPath("$.verifiedWithGoogle").value(true))
			.andExpect(jsonPath("$.reviewUrl").doesNotExist())
			.andExpect(jsonPath("$.message").value("Google không tìm thấy địa điểm với Place ID này."));
	}

	@Test
	@DisplayName("TC-196-12: Xác minh trả về PENDING khi Google API gặp lỗi mạng/timeout/5xx (UNAVAILABLE)")
	void verifyPlaceUnavailableReturnsPendingStatus() throws Exception {
		VerifyPlaceResponse response = new VerifyPlaceResponse(
				VALID_PLACE_ID, null, null, REVIEW_URL, "PENDING", false,
				"Place ID đúng định dạng nhưng chưa kết nối được Google để xác minh, vui lòng thử lại sau.");

		when(googlePlaceService.verify(any(), eq(BRANCH_ID), eq(VALID_PLACE_ID))).thenReturn(response);

		mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.placeId").value(VALID_PLACE_ID))
			.andExpect(jsonPath("$.connectionStatus").value("PENDING"))
			.andExpect(jsonPath("$.verifiedWithGoogle").value(false))
			.andExpect(jsonPath("$.reviewUrl").value(REVIEW_URL));
	}

	// -------------------------------------------------------------------------
	// 5. API Contract & Logic: PUT /api/v1/branches/{branchId}/google-place
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-13: Lưu cấu hình thành công trả về HTTP 200 và cấu hình đã đồng bộ")
	void saveConfigurationSuccess() throws Exception {
		SaveGooglePlaceRequest request = new SaveGooglePlaceRequest(VALID_PLACE_ID, null);
		GooglePlaceConfigResponse response = new GooglePlaceConfigResponse(
				BRANCH_ID, "Chi nhánh Quận 1", VALID_PLACE_ID, "Maison Central",
				"1 Lê Lợi, Q1", REVIEW_URL, "CONNECTED", OffsetDateTime.now(), true);

		when(googlePlaceService.save(any(), eq(BRANCH_ID), eq(request))).thenReturn(response);

		mockMvc.perform(put("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isOk())
			.andExpect(jsonPath("$.branchId").value(BRANCH_ID.toString()))
			.andExpect(jsonPath("$.placeId").value(VALID_PLACE_ID))
			.andExpect(jsonPath("$.connectionStatus").value("CONNECTED"));
	}

	@Test
	@DisplayName("TC-196-14: Từ chối lưu và trả về 422 PLACE_NOT_FOUND khi Google xác nhận địa điểm không tồn tại")
	void saveRejectsNotFoundPlaceWith422() throws Exception {
		SaveGooglePlaceRequest request = new SaveGooglePlaceRequest(VALID_PLACE_ID, null);
		when(googlePlaceService.save(any(), eq(BRANCH_ID), eq(request)))
			.thenThrow(ApiException.unprocessable("PLACE_NOT_FOUND", "Google không tìm thấy địa điểm với Place ID này."));

		mockMvc.perform(put("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
			.andExpect(status().isUnprocessableEntity())
			.andExpect(jsonPath("$.code").value("PLACE_NOT_FOUND"))
			.andExpect(jsonPath("$.message").value("Google không tìm thấy địa điểm với Place ID này."));
	}

	@Test
	@DisplayName("TC-196-15: Từ chối lưu và trả về 400 INVALID_REVIEW_URL khi link thủ công không thuộc tên miền Google")
	void saveRejectsInvalidManualReviewUrlWith400() throws Exception {
		SaveGooglePlaceRequest request = new SaveGooglePlaceRequest(VALID_PLACE_ID, "https://phishing-site.com/review");
		when(googlePlaceService.save(any(), eq(BRANCH_ID), eq(request)))
			.thenThrow(ApiException.badRequest("INVALID_REVIEW_URL",
					"Link đánh giá phải là đường dẫn https của Google (google.com, g.page, goo.gl)."));

		mockMvc.perform(put("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"placeId\":\"" + VALID_PLACE_ID + "\",\"reviewUrl\":\"https://phishing-site.com/review\"}"))
			.andExpect(status().isBadRequest())
			.andExpect(jsonPath("$.code").value("INVALID_REVIEW_URL"));
	}

	// -------------------------------------------------------------------------
	// 6. Branch Data Mapping Integrity & Isolation
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-16: Đảm bảo branchId trên URL path được gán chính xác vào service, không bị tráo đổi cơ sở")
	void verifyBranchIdDataIntegrity() throws Exception {
		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString()))))
			.andExpect(status().isOk());

		verify(googlePlaceService).getConfig(any(), eq(BRANCH_ID));
		verify(googlePlaceService, never()).getConfig(any(), eq(OTHER_BRANCH_ID));
	}

	// -------------------------------------------------------------------------
	// 7. Unexpected Exception Handling (500 Internal Server Error)
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-17: Xử lý exception không mong muốn trả về HTTP 500 với format ApiResponse lỗi chuẩn")
	void unexpectedExceptionReturns500WithStandardFormat() throws Exception {
		when(googlePlaceService.getConfig(any(), eq(BRANCH_ID)))
			.thenThrow(new RuntimeException("Kết nối cơ sở dữ liệu bị gián đoạn đột ngột"));

		mockMvc.perform(get("/api/v1/branches/{branchId}/google-place", BRANCH_ID)
				.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString()))))
			.andExpect(status().isInternalServerError())
			.andExpect(jsonPath("$.success").value(false))
			.andExpect(jsonPath("$.message").value("Đã xảy ra lỗi máy chủ: Kết nối cơ sở dữ liệu bị gián đoạn đột ngột"));
	}

	// -------------------------------------------------------------------------
	// 8. Rate Limiting Verification (OBSERVATION: NOT IMPLEMENTED in Backend)
	// -------------------------------------------------------------------------

	@Test
	@DisplayName("TC-196-18: Kiểm tra Rate Limiting - ghi nhận NOT IMPLEMENTED khi gửi nhiều request dồn dập")
	void rateLimitingVerificationShowsNotImplemented() throws Exception {
		VerifyPlaceResponse response = new VerifyPlaceResponse(
				VALID_PLACE_ID, "Maison Central", "1 Lê Lợi, Q1", REVIEW_URL, "CONNECTED", true,
				"Đã xác minh địa điểm với Google.");
		when(googlePlaceService.verify(any(), eq(BRANCH_ID), eq(VALID_PLACE_ID))).thenReturn(response);

		// Gửi liên tiếp 10 request xác minh
		int successCount = 0;
		int tooManyRequestsCount = 0;
		for (int i = 0; i < 10; i++) {
			int statusCode = mockMvc.perform(post("/api/v1/branches/{branchId}/google-place/verifications", BRANCH_ID)
					.with(jwt().jwt(t -> t.subject(UUID.randomUUID().toString())))
					.contentType(MediaType.APPLICATION_JSON)
					.content("{\"placeId\":\"" + VALID_PLACE_ID + "\"}"))
				.andReturn()
				.getResponse()
				.getStatus();

			if (statusCode == 200) {
				successCount++;
			} else if (statusCode == 429) {
				tooManyRequestsCount++;
			}
		}

		// Chứng minh backend KHÔNG triển khai Rate Limiting: toàn bộ 10 request đều trả về 200, 0 request bị chặn 429
		assertThat(successCount).isEqualTo(10);
		assertThat(tooManyRequestsCount).isEqualTo(0);
	}

}
