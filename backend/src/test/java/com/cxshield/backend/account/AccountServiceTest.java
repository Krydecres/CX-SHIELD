package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.account.AccountRepository.BusinessRow;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.RoleRef;
import com.cxshield.backend.account.AccountRepository.UserRow;
import com.cxshield.backend.account.dto.AccountDtos.BranchResponse;
import com.cxshield.backend.account.dto.AccountDtos.MeResponse;
import com.cxshield.backend.common.ApiException;

class AccountServiceTest {

	private static final String TOKEN = "token";
	private static final UUID USER_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final BusinessRow BUSINESS = new BusinessRow(BUSINESS_ID, "Maison", "Maison Q1", "Bán lẻ", null, null,
			"#1E40AF");
	private static final MembershipRow OWNER = new MembershipRow(UUID.randomUUID(), BUSINESS_ID, "ACTIVE",
			new RoleRef("OWNER"), BUSINESS);
	private static final BranchRow BRANCH = new BranchRow(UUID.randomUUID(), BUSINESS_ID, "CN01", "Maison Q1", null,
			"0901234567", "ACTIVE", null);

	private AccountRepository repository;
	private AccountService service;

	@BeforeEach
	void setUp() {
		repository = mock(AccountRepository.class);
		service = new AccountService(repository);
	}

	@Test
	void meIsOnboardedWhenFirstBusinessHasBranch() {
		when(repository.findUser(TOKEN, USER_ID))
			.thenReturn(Optional.of(new UserRow(USER_ID, "chu@example.com", "Chủ cơ sở", "EMAIL")));
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(OWNER));
		when(repository.findBranches(TOKEN, BUSINESS_ID)).thenReturn(List.of(BRANCH));

		MeResponse me = service.getMe(TOKEN, USER_ID, "token@example.com");

		assertThat(me.onboarded()).isTrue();
		assertThat(me.email()).isEqualTo("chu@example.com");
		assertThat(me.fullName()).isEqualTo("Chủ cơ sở");
		assertThat(me.authProvider()).isEqualTo("EMAIL");
		assertThat(me.memberships()).singleElement().satisfies(membership -> {
			assertThat(membership.role()).isEqualTo("OWNER");
			assertThat(membership.business().brandName()).isEqualTo("Maison");
		});
	}

	@Test
	void meIsNotOnboardedWithoutMembership() {
		when(repository.findUser(TOKEN, USER_ID)).thenReturn(Optional.empty());
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());

		MeResponse me = service.getMe(TOKEN, USER_ID, "token@example.com");

		assertThat(me.onboarded()).isFalse();
		assertThat(me.memberships()).isEmpty();
		verify(repository, never()).findBranches(eq(TOKEN), any());
	}

	@Test
	void meIsNotOnboardedWhenBranchCreationFailedHalfway() {
		when(repository.findUser(TOKEN, USER_ID)).thenReturn(Optional.empty());
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(OWNER));
		when(repository.findBranches(TOKEN, BUSINESS_ID)).thenReturn(List.of());

		assertThat(service.getMe(TOKEN, USER_ID, null).onboarded()).isFalse();
	}

	@Test
	void meFallsBackToTokenEmailWhenUserRowIsMissing() {
		when(repository.findUser(TOKEN, USER_ID)).thenReturn(Optional.empty());
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());

		MeResponse me = service.getMe(TOKEN, USER_ID, "token@example.com");

		assertThat(me.email()).isEqualTo("token@example.com");
		assertThat(me.fullName()).isNull();
		assertThat(me.authProvider()).isNull();
	}

	@Test
	void meFallsBackToTokenEmailWhenUserRowHasNoEmail() {
		when(repository.findUser(TOKEN, USER_ID)).thenReturn(Optional.of(new UserRow(USER_ID, null, null, "GOOGLE")));
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());

		assertThat(service.getMe(TOKEN, USER_ID, "token@example.com").email()).isEqualTo("token@example.com");
	}

	@Test
	void branchesAreReturnedForMember() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(OWNER));
		when(repository.findBranches(TOKEN, BUSINESS_ID)).thenReturn(List.of(BRANCH));

		List<BranchResponse> branches = service.getBranches(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(branches).singleElement().satisfies(branch -> {
			assertThat(branch.id()).isEqualTo(BRANCH.id());
			assertThat(branch.code()).isEqualTo("CN01");
			assertThat(branch.hotline()).isEqualTo("0901234567");
		});
	}

	@Test
	void branchesOfAnotherBusinessAreHidden() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(OWNER));
		UUID otherBusiness = UUID.randomUUID();

		assertThatThrownBy(() -> service.getBranches(TOKEN, USER_ID, otherBusiness))
			.isInstanceOfSatisfying(ApiException.class, ex -> {
				assertThat(ex.getStatus()).isEqualTo(HttpStatus.NOT_FOUND);
				assertThat(ex.getCode()).isEqualTo("BUSINESS_NOT_FOUND");
			});
		verify(repository, never()).findBranches(TOKEN, otherBusiness);
	}

	@Test
	void businessMappingAcceptsMissingBusiness() {
		assertThat(AccountService.toBusiness(null)).isNull();
	}

}
