package com.cxshield.backend.funnel;

import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cxshield.backend.funnel.dto.GooglePlaceDtos.GooglePlaceConfigResponse;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.SaveGooglePlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/branches/{branchId}/google-place")
public class GooglePlaceController {

	private final GooglePlaceService googlePlaceService;

	public GooglePlaceController(GooglePlaceService googlePlaceService) {
		this.googlePlaceService = googlePlaceService;
	}

	@GetMapping
	public GooglePlaceConfigResponse get(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId) {
		return googlePlaceService.getConfig(jwt.getTokenValue(), branchId);
	}

	@PostMapping("/verifications")
	public VerifyPlaceResponse verify(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId,
			@Valid @RequestBody VerifyPlaceRequest request) {
		return googlePlaceService.verify(jwt.getTokenValue(), branchId, request.placeId());
	}

	@PutMapping
	public GooglePlaceConfigResponse save(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId,
			@Valid @RequestBody SaveGooglePlaceRequest request) {
		return googlePlaceService.save(jwt.getTokenValue(), branchId, request);
	}

}
