package com.cxshield.backend.account;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.cxshield.backend.account.dto.AccountDtos.BranchResponse;
import com.cxshield.backend.account.dto.AccountDtos.MeResponse;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingRequest;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1")
public class AccountController {

	private final AccountService accountService;
	private final OnboardingService onboardingService;

	public AccountController(AccountService accountService, OnboardingService onboardingService) {
		this.accountService = accountService;
		this.onboardingService = onboardingService;
	}

	@GetMapping("/me")
	public MeResponse me(@AuthenticationPrincipal Jwt jwt) {
		return accountService.getMe(jwt.getTokenValue(), userId(jwt), jwt.getClaimAsString("email"));
	}

	@PostMapping("/onboarding")
	@ResponseStatus(HttpStatus.CREATED)
	public OnboardingResponse onboard(@AuthenticationPrincipal Jwt jwt, @Valid @RequestBody OnboardingRequest request) {
		return onboardingService.onboard(jwt.getTokenValue(), userId(jwt), request);
	}

	@GetMapping("/businesses/{businessId}/branches")
	public List<BranchResponse> branches(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId) {
		return accountService.getBranches(jwt.getTokenValue(), userId(jwt), businessId);
	}

	static UUID userId(Jwt jwt) {
		return UUID.fromString(jwt.getSubject());
	}

}
