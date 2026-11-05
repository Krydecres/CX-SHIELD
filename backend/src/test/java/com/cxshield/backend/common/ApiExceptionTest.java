package com.cxshield.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

class ApiExceptionTest {

	@Test
	void factoriesSetHttpStatus() {
		assertThat(ApiException.badRequest("X", "m").getStatus()).isEqualTo(HttpStatus.BAD_REQUEST);
		assertThat(ApiException.notFound("X", "m").getStatus()).isEqualTo(HttpStatus.NOT_FOUND);
		assertThat(ApiException.conflict("X", "m").getStatus()).isEqualTo(HttpStatus.CONFLICT);
		assertThat(ApiException.unprocessable("X", "m").getStatus()).isEqualTo(HttpStatus.UNPROCESSABLE_CONTENT);
	}

	@Test
	void forbiddenUsesStandardCode() {
		ApiException exception = ApiException.forbidden("Không có quyền");

		assertThat(exception.getStatus()).isEqualTo(HttpStatus.FORBIDDEN);
		assertThat(exception.getCode()).isEqualTo("FORBIDDEN");
		assertThat(exception.getMessage()).isEqualTo("Không có quyền");
	}

}
