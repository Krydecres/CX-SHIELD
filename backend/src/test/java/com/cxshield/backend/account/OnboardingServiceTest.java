package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.TestProperties;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.account.AccountRepository.BusinessRow;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.RoleRef;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingRequest;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingResponse;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.supabase.SupabaseException;

class OnboardingServiceTest {

	private static final String TOKEN = "token";
	private static final UUID USER_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();

	private AccountRepository repository;
	private OnboardingService service;

	@BeforeEach
	void setUp() {
		repository = mock(AccountRepository.class);
		service = new OnboardingService(repository, TestProperties.create(null));
		when(repository.updateBusinessProfile(eq(TOKEN), eq(BUSINESS_ID), anyMap()))
			.thenReturn(new BusinessRow(BUSINESS_ID, "Maison", "Maison Q1", "Cà phê & đồ uống", null, null, "#1E40AF"));
		when(repository.findBranch(eq(TOKEN), any())).thenAnswer(invocation -> Optional.of(new BranchRow(
				invocation.getArgument(1), BUSINESS_ID, "CN01", "Maison Q1", null, null, "ACTIVE", null)));
	}

	@Test
	void createsBusinessOwnerAndFirstBranch() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());
		when(repository.createBusinessWithOwner(eq(TOKEN), eq("Maison"), anyString(), eq("Cà phê & đồ uống"),
				eq("0901234567"), eq("#1E40AF")))
			.thenReturn(BUSINESS_ID);

		OnboardingResponse response = service.onboard(TOKEN, USER_ID,
				new OnboardingRequest(" Maison ", "Maison Q1", "Cà phê & đồ uống", "0901234567", null, "#1e40af"));

		assertThat(response.business().id()).isEqualTo(BUSINESS_ID);
		assertThat(response.branch().code()).isEqualTo("CN01");
		verify(repository).createBranch(eq(TOKEN), any(UUID.class), eq(BUSINESS_ID), eq("CN01"), eq("Maison Q1"),
				eq("0901234567"));
	}

	@Test
	void usesBrandNameWhenBranchNameIsBlank() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());
		when(repository.createBusinessWithOwner(any(), any(), any(), any(), any(), any())).thenReturn(BUSINESS_ID);

		service.onboard(TOKEN, USER_ID, new OnboardingRequest("Maison", " ", "Spa & làm đẹp", null, null, null));

		@SuppressWarnings("unchecked")
		ArgumentCaptor<Map<String, Object>> profile = ArgumentCaptor.forClass(Map.class);
		verify(repository).updateBusinessProfile(eq(TOKEN), eq(BUSINESS_ID), profile.capture());
		assertThat(profile.getValue()).containsEntry("display_name", "Maison")
			.containsEntry("primary_color", OnboardingService.DEFAULT_PRIMARY_COLOR);
		verify(repository).createBranch(eq(TOKEN), any(UUID.class), eq(BUSINESS_ID), eq("CN01"), eq("Maison"), isNull());
	}

	@Test
	void retriesWhenPublicSlugAlreadyExists() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());
		when(repository.createBusinessWithOwner(any(), any(), any(), any(), any(), any()))
			.thenThrow(new SupabaseException(409, SupabaseException.UNIQUE_VIOLATION, "duplicate"))
			.thenReturn(BUSINESS_ID);

		service.onboard(TOKEN, USER_ID, new OnboardingRequest("Maison", null, "Khác", null, null, null));

		verify(repository, times(2)).createBusinessWithOwner(any(), any(), any(), any(), any(), any());
	}

	@Test
	void rejectsUserThatAlreadyHasBusinessWithBranches() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(owner()));
		when(repository.findBranches(TOKEN, BUSINESS_ID))
			.thenReturn(List.of(new BranchRow(UUID.randomUUID(), BUSINESS_ID, "CN01", "A", null, null, "ACTIVE", null)));

		assertThatThrownBy(() -> service.onboard(TOKEN, USER_ID,
				new OnboardingRequest("Maison", null, "Khác", null, null, null)))
			.isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo("ALREADY_ONBOARDED");
		verify(repository, never()).createBranch(any(), any(), any(), any(), any(), any());
	}

	@Test
	void resumesOnboardingWhenOwnerBusinessHasNoBranch() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(owner()));
		when(repository.findBranches(TOKEN, BUSINESS_ID)).thenReturn(List.of());

		service.onboard(TOKEN, USER_ID, new OnboardingRequest("Maison", null, "Khác", null, null, null));

		verify(repository, never()).createBusinessWithOwner(any(), any(), any(), any(), any(), any());
		verify(repository).createBranch(eq(TOKEN), any(UUID.class), eq(BUSINESS_ID), eq("CN01"), eq("Maison"), isNull());
	}

	@Test
	void rejectsLogoOutsideOwnStorageFolder() {
		assertThatThrownBy(() -> service.onboard(TOKEN, USER_ID,
				new OnboardingRequest("Maison", null, "Khác", null, "https://evil.io/logo.png", null)))
			.isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo("INVALID_LOGO_URL");
	}

	@Test
	void acceptsLogoInOwnStorageFolder() {
		when(repository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of());
		when(repository.createBusinessWithOwner(any(), any(), any(), any(), any(), any())).thenReturn(BUSINESS_ID);
		String logoUrl = TestProperties.SUPABASE_URL + "/storage/v1/object/public/business-logos/" + USER_ID + "/logo.png";

		service.onboard(TOKEN, USER_ID, new OnboardingRequest("Maison", null, "Khác", null, logoUrl, null));

		@SuppressWarnings("unchecked")
		ArgumentCaptor<Map<String, Object>> profile = ArgumentCaptor.forClass(Map.class);
		verify(repository).updateBusinessProfile(eq(TOKEN), eq(BUSINESS_ID), profile.capture());
		assertThat(profile.getValue()).containsEntry("logo_url", logoUrl);
	}

	private static MembershipRow owner() {
		return new MembershipRow(UUID.randomUUID(), BUSINESS_ID, "ACTIVE", new RoleRef("OWNER"), null);
	}

}
