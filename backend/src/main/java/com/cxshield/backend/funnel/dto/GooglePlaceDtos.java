package com.cxshield.backend.funnel.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * DTO của API cài đặt phễu: Google Place ID (E4.1 · D3-05).
 */
public final class GooglePlaceDtos {

	private GooglePlaceDtos() {
	}

	/**
	 * connectionStatus: NOT_CONNECTED (chưa có cấu hình) hoặc giá trị enum connection_status trong CSDL
	 * (PENDING, CONNECTED, ERROR, DISCONNECTED).
	 */
	public record GooglePlaceConfigResponse(UUID branchId, String branchName, String placeId, String placeName,
			String placeAddress, String reviewUrl, String connectionStatus, OffsetDateTime updatedAt,
			boolean googleVerificationEnabled) {
	}

	public record VerifyPlaceRequest(@NotBlank(message = "Vui lòng nhập Google Place ID.") @Size(max = 2048) String placeId) {
	}

	public record VerifyPlaceResponse(String placeId, String placeName, String placeAddress, String reviewUrl,
			String connectionStatus, boolean verifiedWithGoogle, String message) {
	}

	public record SaveGooglePlaceRequest(
			@NotBlank(message = "Vui lòng nhập Google Place ID.") @Size(max = 2048) String placeId,
			@Size(max = 2048) String reviewUrl) {
	}

}
