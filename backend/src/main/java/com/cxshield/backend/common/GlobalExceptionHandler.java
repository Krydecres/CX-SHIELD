package com.cxshield.backend.common;

import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import com.cxshield.backend.supabase.SupabaseException;

@RestControllerAdvice
public class GlobalExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	@ExceptionHandler(ApiException.class)
	ResponseEntity<ApiErrorResponse> handleApi(ApiException ex) {
		return ResponseEntity.status(ex.getStatus()).body(new ApiErrorResponse(ex.getCode(), ex.getMessage()));
	}

	@ExceptionHandler(IllegalArgumentException.class)
	ResponseEntity<ApiResponse<Void>> handleIllegalArgument(IllegalArgumentException ex) {
		return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	ResponseEntity<ApiErrorResponse> handleValidation(MethodArgumentNotValidException ex) {
		Map<String, String> fieldErrors = new LinkedHashMap<>();
		for (FieldError error : ex.getBindingResult().getFieldErrors()) {
			fieldErrors.putIfAbsent(error.getField(), error.getDefaultMessage());
		}
		return ResponseEntity.badRequest()
			.body(new ApiErrorResponse("VALIDATION_ERROR", "Dữ liệu chưa hợp lệ, vui lòng kiểm tra lại.", fieldErrors));
	}

	@ExceptionHandler({ HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class })
	ResponseEntity<ApiErrorResponse> handleBadInput(Exception ex) {
		return ResponseEntity.badRequest().body(new ApiErrorResponse("BAD_REQUEST", "Yêu cầu không hợp lệ."));
	}

	@ExceptionHandler(SupabaseException.class)
	ResponseEntity<ApiErrorResponse> handleSupabase(SupabaseException ex) {
		if (ex.isPermissionDenied()) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN)
				.body(new ApiErrorResponse("FORBIDDEN", "Bạn không có quyền thực hiện thao tác này."));
		}
		if (ex.getStatus() == HttpStatus.UNAUTHORIZED.value()) {
			return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
				.body(new ApiErrorResponse("UNAUTHORIZED", "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại."));
		}
		log.error("Supabase error status={} code={}: {}", ex.getStatus(), ex.getCode(), ex.getMessage());
		return ResponseEntity.status(HttpStatus.BAD_GATEWAY)
			.body(new ApiErrorResponse("UPSTREAM_ERROR", "Không kết nối được cơ sở dữ liệu, vui lòng thử lại."));
	}

	@ExceptionHandler(Exception.class)
	ResponseEntity<ApiResponse<Void>> handleGeneralException(Exception ex) {
		log.error("Unhandled exception: ", ex);
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
			.body(ApiResponse.error("Đã xảy ra lỗi máy chủ: " + ex.getMessage()));
	}

}
