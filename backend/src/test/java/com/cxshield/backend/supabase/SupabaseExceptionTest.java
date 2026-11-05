package com.cxshield.backend.supabase;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SupabaseExceptionTest {

	@Test
	void detectsUniqueViolation() {
		assertThat(new SupabaseException(409, "23505", "duplicate").isUniqueViolation()).isTrue();
		assertThat(new SupabaseException(400, "22P02", "bad input").isUniqueViolation()).isFalse();
	}

	@Test
	void detectsPermissionDeniedByStatusOrPostgresCode() {
		assertThat(new SupabaseException(403, null, "forbidden").isPermissionDenied()).isTrue();
		assertThat(new SupabaseException(401, "42501", "rls").isPermissionDenied()).isTrue();
		assertThat(new SupabaseException(500, "XX000", "error").isPermissionDenied()).isFalse();
	}

}
