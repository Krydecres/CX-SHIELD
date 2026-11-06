package com.cxshield.backend.alert;

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

import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertChannelsResponse;
import com.cxshield.backend.alert.dto.AlertDtos.AlertTestResponse;
import com.cxshield.backend.alert.dto.AlertDtos.SaveAlertChannelRequest;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/branches/{branchId}/alert-channels")
public class AlertChannelController {

	private final AlertChannelService alertChannelService;

	public AlertChannelController(AlertChannelService alertChannelService) {
		this.alertChannelService = alertChannelService;
	}

	@GetMapping
	public AlertChannelsResponse list(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId) {
		return alertChannelService.getChannels(jwt.getTokenValue(), branchId);
	}

	@PutMapping("/{type}")
	public AlertChannelResponse save(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId,
			@PathVariable AlertChannelType type, @Valid @RequestBody SaveAlertChannelRequest request) {
		return alertChannelService.save(jwt.getTokenValue(), branchId, type, request);
	}

	@PostMapping("/{type}/tests")
	public AlertTestResponse test(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID branchId,
			@PathVariable AlertChannelType type) {
		return alertChannelService.sendTest(jwt.getTokenValue(), branchId, type);
	}

}
