package com.cxshield.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;

import com.cxshield.backend.supabase.SupabaseException;

class GlobalExceptionHandlerTest {

	private final GlobalExceptionHandler handler = new GlobalExceptionHandler();

	@Test
	void businessErrorKeepsStatusAndCode() {
		ResponseEntity<ApiErrorResponse> response = handler
			.handleApi(ApiException.conflict("ALREADY_ONBOARDED", "Tài khoản đã có cơ sở."));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
		assertThat(response.getBody().code()).isEqualTo("ALREADY_ONBOARDED");
		assertThat(response.getBody().message()).isEqualTo("Tài khoản đã có cơ sở.");
	}

	@Test
	void validationKeepsFirstMessageOfEachField() throws Exception {
		BeanPropertyBindingResult result = new BeanPropertyBindingResult(new Object(), "request");
		result.addError(new FieldError("request", "phone", "Lỗi đầu"));
		result.addError(new FieldError("request", "phone", "Lỗi sau"));
		result.addError(new FieldError("request", "brandName", "Thiếu tên"));
		MethodParameter parameter = new MethodParameter(Object.class.getMethod("equals", Object.class), 0);

		ResponseEntity<ApiErrorResponse> response = handler
			.handleValidation(new MethodArgumentNotValidException(parameter, result));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
		assertThat(response.getBody().code()).isEqualTo("VALIDATION_ERROR");
		assertThat(response.getBody().fieldErrors()).containsEntry("phone", "Lỗi đầu")
			.containsEntry("brandName", "Thiếu tên");
	}

	@Test
	void malformedRequestIsBadRequest() {
		ResponseEntity<ApiErrorResponse> response = handler.handleBadInput(new RuntimeException("not readable"));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
		assertThat(response.getBody().code()).isEqualTo("BAD_REQUEST");
	}

	@Test
	void rlsErrorBecomesForbidden() {
		ResponseEntity<ApiErrorResponse> response = handler.handleSupabase(new SupabaseException(401, "42501", "rls"));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.FORBIDDEN);
		assertThat(response.getBody().code()).isEqualTo("FORBIDDEN");
	}

	@Test
	void expiredTokenBecomesUnauthorized() {
		ResponseEntity<ApiErrorResponse> response = handler.handleSupabase(new SupabaseException(401, "PGRST301", "jwt"));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
		assertThat(response.getBody().code()).isEqualTo("UNAUTHORIZED");
	}

	@Test
	void otherSupabaseErrorDoesNotLeakDetails() {
		ResponseEntity<ApiErrorResponse> response = handler
			.handleSupabase(new SupabaseException(500, "XX000", "internal detail"));

		assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_GATEWAY);
		assertThat(response.getBody().code()).isEqualTo("UPSTREAM_ERROR");
		assertThat(response.getBody().message()).doesNotContain("internal detail");
	}

}
