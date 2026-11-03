package com.cxshield.backend.supabase;

/**
 * Lỗi trả về từ Supabase Data API (PostgREST). {@code code} là mã lỗi PostgreSQL / PostgREST.
 */
public class SupabaseException extends RuntimeException {

	public static final String UNIQUE_VIOLATION = "23505";
	public static final String INSUFFICIENT_PRIVILEGE = "42501";

	private final int status;
	private final String code;

	public SupabaseException(int status, String code, String message) {
		super(message);
		this.status = status;
		this.code = code;
	}

	public int getStatus() {
		return status;
	}

	public String getCode() {
		return code;
	}

	public boolean isUniqueViolation() {
		return UNIQUE_VIOLATION.equals(code);
	}

	public boolean isPermissionDenied() {
		return status == 403 || INSUFFICIENT_PRIVILEGE.equals(code);
	}

}
