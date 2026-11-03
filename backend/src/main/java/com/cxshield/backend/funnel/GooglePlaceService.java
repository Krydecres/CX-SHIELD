package com.cxshield.backend.funnel;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceLookup;
import com.cxshield.backend.funnel.ReviewPlatformRepository.ReviewPlatformRow;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.GooglePlaceConfigResponse;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.SaveGooglePlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceResponse;

/**
 * Cài đặt phễu: Google Place ID theo chi nhánh (E4.1 · D3-05).
 */
@Service
public class GooglePlaceService {

	static final String NOT_CONNECTED = "NOT_CONNECTED";
	static final String PENDING = "PENDING";
	static final String CONNECTED = "CONNECTED";
	static final String ERROR = "ERROR";

	private final AccountRepository accountRepository;
	private final ReviewPlatformRepository reviewPlatformRepository;
	private final GooglePlacesClient googlePlacesClient;

	public GooglePlaceService(AccountRepository accountRepository, ReviewPlatformRepository reviewPlatformRepository,
			GooglePlacesClient googlePlacesClient) {
		this.accountRepository = accountRepository;
		this.reviewPlatformRepository = reviewPlatformRepository;
		this.googlePlacesClient = googlePlacesClient;
	}

	public GooglePlaceConfigResponse getConfig(String token, UUID branchId) {
		BranchRow branch = requireBranch(token, branchId);
		return toConfig(branch, reviewPlatformRepository.findGoogle(token, branchId).orElse(null));
	}

	public VerifyPlaceResponse verify(String token, UUID branchId, String rawPlaceId) {
		requireBranch(token, branchId);
		String placeId = PlaceIdParser.normalize(rawPlaceId);
		String reviewUrl = PlaceIdParser.reviewUrl(placeId);
		PlaceLookup lookup = googlePlacesClient.lookup(placeId);
		return switch (lookup.result()) {
			case FOUND -> new VerifyPlaceResponse(placeId, lookup.name(), lookup.address(), reviewUrl, CONNECTED, true,
					"Đã xác minh địa điểm với Google.");
			case NOT_FOUND -> new VerifyPlaceResponse(placeId, null, null, null, ERROR, true,
					"Google không tìm thấy địa điểm với Place ID này.");
			case UNAVAILABLE -> new VerifyPlaceResponse(placeId, null, null, reviewUrl, PENDING, false,
					"Place ID đúng định dạng nhưng chưa kết nối được Google để xác minh, vui lòng thử lại sau.");
			case NOT_CONFIGURED -> new VerifyPlaceResponse(placeId, null, null, reviewUrl, PENDING, false,
					"Place ID đúng định dạng. Hệ thống chưa bật xác minh tự động với Google.");
		};
	}

	public GooglePlaceConfigResponse save(String token, UUID branchId, SaveGooglePlaceRequest request) {
		BranchRow branch = requireBranch(token, branchId);
		String placeId = PlaceIdParser.normalize(request.placeId());
		String reviewUrl = request.reviewUrl() == null || request.reviewUrl().isBlank() ? PlaceIdParser.reviewUrl(placeId)
				: PlaceIdParser.validateManualReviewUrl(request.reviewUrl());

		PlaceLookup lookup = googlePlacesClient.lookup(placeId);
		if (lookup.result() == PlaceLookup.Result.NOT_FOUND) {
			throw ApiException.unprocessable("PLACE_NOT_FOUND", "Google không tìm thấy địa điểm với Place ID này.");
		}

		Optional<ReviewPlatformRow> existing = reviewPlatformRepository.findGoogle(token, branchId);
		boolean found = lookup.result() == PlaceLookup.Result.FOUND;
		// Khi chưa xác minh được, giữ tên / địa chỉ đã lưu nếu vẫn là Place ID cũ.
		ReviewPlatformRow samePlace = existing.filter(row -> placeId.equals(row.googlePlaceId())).orElse(null);

		Map<String, Object> values = new LinkedHashMap<>();
		values.put("google_place_id", placeId);
		values.put("review_direct_url", reviewUrl);
		values.put("place_name", found ? lookup.name() : samePlace == null ? null : samePlace.placeName());
		values.put("place_address", found ? lookup.address() : samePlace == null ? null : samePlace.placeAddress());
		values.put("connection_status", found ? CONNECTED : PENDING);
		values.put("is_active", true);

		ReviewPlatformRow saved;
		if (existing.isPresent()) {
			saved = reviewPlatformRepository.update(token, existing.get().id(), values)
				.orElseThrow(() -> ApiException.forbidden("Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."));
		}
		else {
			values.put("business_id", branch.businessId());
			values.put("branch_id", branchId);
			values.put("platform_name", ReviewPlatformRepository.GOOGLE);
			saved = reviewPlatformRepository.insert(token, values)
				.orElseThrow(() -> ApiException.forbidden("Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."));
		}
		return toConfig(branch, saved);
	}

	private BranchRow requireBranch(String token, UUID branchId) {
		return accountRepository.findBranch(token, branchId)
			.orElseThrow(() -> ApiException.notFound("BRANCH_NOT_FOUND", "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."));
	}

	private GooglePlaceConfigResponse toConfig(BranchRow branch, ReviewPlatformRow row) {
		boolean verification = googlePlacesClient.isEnabled();
		if (row == null) {
			return new GooglePlaceConfigResponse(branch.id(), branch.name(), null, null, null, null, NOT_CONNECTED, null,
					verification);
		}
		return new GooglePlaceConfigResponse(branch.id(), branch.name(), row.googlePlaceId(), row.placeName(),
				row.placeAddress(), row.reviewDirectUrl(), row.connectionStatus(), row.updatedAt(), verification);
	}

}
