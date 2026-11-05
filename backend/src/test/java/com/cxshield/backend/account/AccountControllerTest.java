package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import com.cxshield.backend.account.dto.AccountDtos.MeResponse;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingRequest;

class AccountControllerTest {

	private static final UUID USER_ID = UUID.randomUUID();

	private AccountService accountService;
	private OnboardingService onboardingService;
	private AccountController controller;
	private Jwt jwt;

	@BeforeEach
	void setUp() {
		accountService = mock(AccountService.class);
		onboardingService = mock(OnboardingService.class);
		controller = new AccountController(accountService, onboardingService);
		jwt = Jwt.withTokenValue("token")
			.header("alg", "ES256")
			.subject(USER_ID.toString())
			.claim("email", "chu@example.com")
			.build();
	}

	@Test
	void mePassesUserFromToken() {
		MeResponse expected = new MeResponse(USER_ID, "chu@example.com", null, null, false, List.of());
		when(accountService.getMe("token", USER_ID, "chu@example.com")).thenReturn(expected);

		assertThat(controller.me(jwt)).isEqualTo(expected);
	}

	@Test
	void onboardingUsesUserFromToken() {
		OnboardingRequest request = new OnboardingRequest("Maison", null, "Bán lẻ", null, null, null);

		controller.onboard(jwt, request);

		verify(onboardingService).onboard("token", USER_ID, request);
	}

	@Test
	void branchesUseUserFromToken() {
		UUID businessId = UUID.randomUUID();

		controller.branches(jwt, businessId);

		verify(accountService).getBranches("token", USER_ID, businessId);
	}

}
