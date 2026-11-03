package com.cxshield.backend.funnel;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.funnel.GooglePlacesClient.PlaceLookup;
import com.cxshield.backend.funnel.ReviewPlatformRepository.ReviewPlatformRow;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.GooglePlaceConfigResponse;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.SaveGooglePlaceRequest;
import com.cxshield.backend.funnel.dto.GooglePlaceDtos.VerifyPlaceResponse;

class GooglePlaceServiceTest {

	private static final String TOKEN = "token";
	private static final String PLACE_ID = "ChIJN1t_tDeuEmsRUsoyG83frY4";
	private static final UUID BRANCH_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();

	private AccountRepository accountRepository;
	private ReviewPlatformRepository reviewPlatformRepository;
	private GooglePlacesClient googlePlacesClient;
	private GooglePlaceService service;

	@BeforeEach
	void setUp() {
		accountRepository = mock(AccountRepository.class);
		reviewPlatformRepository = mock(ReviewPlatformRepository.class);
		googlePlacesClient = mock(GooglePlacesClient.class);
		service = new GooglePlaceService(accountRepository, reviewPlatformRepository, googlePlacesClient);
		when(accountRepository.findBranch(TOKEN, BRANCH_ID)).thenReturn(
				Optional.of(new BranchRow(BRANCH_ID, BUSINESS_ID, "CN01", "Maison Q1", null, null, "ACTIVE", null)));
		when(reviewPlatformRepository.insert(eq(TOKEN), anyMap())).thenAnswer(invocation -> Optional.of(row(invocation.getArgument(1))));
		when(reviewPlatformRepository.update(eq(TOKEN), any(), anyMap())).thenAnswer(invocation -> Optional.of(row(invocation.getArgument(2))));
	}

	@Test
	void getConfigReturnsNotConnectedWhenNothingSaved() {
		when(reviewPlatformRepository.findGoogle(TOKEN, BRANCH_ID)).thenReturn(Optional.empty());

		GooglePlaceConfigResponse config = service.getConfig(TOKEN, BRANCH_ID);

		assertThat(config.connectionStatus()).isEqualTo(GooglePlaceService.NOT_CONNECTED);
		assertThat(config.branchName()).isEqualTo("Maison Q1");
	}

	@Test
	void getConfigFailsForInaccessibleBranch() {
		UUID other = UUID.randomUUID();
		when(accountRepository.findBranch(TOKEN, other)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.getConfig(TOKEN, other)).isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo("BRANCH_NOT_FOUND");
	}

	@Test
	void verifyReturnsPlaceInfoWhenGoogleFindsPlace() {
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.FOUND, "Maison", "1 Lê Lợi"));

		VerifyPlaceResponse result = service.verify(TOKEN, BRANCH_ID, PLACE_ID);

		assertThat(result.connectionStatus()).isEqualTo(GooglePlaceService.CONNECTED);
		assertThat(result.placeName()).isEqualTo("Maison");
		assertThat(result.reviewUrl()).endsWith("placeid=" + PLACE_ID);
	}

	@Test
	void verifyReturnsErrorStatusWhenGoogleCannotFindPlace() {
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.NOT_FOUND, null, null));

		VerifyPlaceResponse result = service.verify(TOKEN, BRANCH_ID, PLACE_ID);

		assertThat(result.connectionStatus()).isEqualTo(GooglePlaceService.ERROR);
		assertThat(result.reviewUrl()).isNull();
	}

	@Test
	void verifyRejectsInvalidFormatWithoutCallingGoogle() {
		assertThatThrownBy(() -> service.verify(TOKEN, BRANCH_ID, "abc")).isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo(PlaceIdParser.INVALID_PLACE_ID);
		verify(googlePlacesClient, never()).lookup(any());
	}

	@Test
	void saveInsertsConnectedGooglePlatform() {
		when(reviewPlatformRepository.findGoogle(TOKEN, BRANCH_ID)).thenReturn(Optional.empty());
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.FOUND, "Maison", "1 Lê Lợi"));

		GooglePlaceConfigResponse config = service.save(TOKEN, BRANCH_ID, new SaveGooglePlaceRequest(PLACE_ID, null));

		Map<String, Object> values = capturedInsert();
		assertThat(values).containsEntry("business_id", BUSINESS_ID)
			.containsEntry("branch_id", BRANCH_ID)
			.containsEntry("platform_name", "GOOGLE")
			.containsEntry("connection_status", "CONNECTED")
			.containsEntry("review_direct_url", PlaceIdParser.reviewUrl(PLACE_ID));
		assertThat(config.connectionStatus()).isEqualTo("CONNECTED");
	}

	@Test
	void saveKeepsPendingStatusWhenVerificationIsNotConfigured() {
		when(reviewPlatformRepository.findGoogle(TOKEN, BRANCH_ID)).thenReturn(Optional.empty());
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.NOT_CONFIGURED, null, null));

		service.save(TOKEN, BRANCH_ID, new SaveGooglePlaceRequest(PLACE_ID, "https://g.page/r/abc/review"));

		assertThat(capturedInsert()).containsEntry("connection_status", "PENDING")
			.containsEntry("review_direct_url", "https://g.page/r/abc/review");
	}

	@Test
	void saveUpdatesExistingRow() {
		UUID existingId = UUID.randomUUID();
		when(reviewPlatformRepository.findGoogle(TOKEN, BRANCH_ID)).thenReturn(Optional.of(new ReviewPlatformRow(existingId,
				BUSINESS_ID, BRANCH_ID, "GOOGLE", PLACE_ID, null, "Tên cũ", "Địa chỉ cũ", "PENDING", true, null)));
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.UNAVAILABLE, null, null));

		service.save(TOKEN, BRANCH_ID, new SaveGooglePlaceRequest(PLACE_ID, null));

		@SuppressWarnings("unchecked")
		ArgumentCaptor<Map<String, Object>> values = ArgumentCaptor.forClass(Map.class);
		verify(reviewPlatformRepository).update(eq(TOKEN), eq(existingId), values.capture());
		assertThat(values.getValue()).containsEntry("place_name", "Tên cũ").doesNotContainKey("business_id");
		verify(reviewPlatformRepository, never()).insert(any(), anyMap());
	}

	@Test
	void saveRejectsPlaceThatGoogleCannotFind() {
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.NOT_FOUND, null, null));

		assertThatThrownBy(() -> service.save(TOKEN, BRANCH_ID, new SaveGooglePlaceRequest(PLACE_ID, null)))
			.isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo("PLACE_NOT_FOUND");
		verify(reviewPlatformRepository, never()).insert(any(), anyMap());
	}

	@Test
	void saveFailsWhenRlsBlocksUpdate() {
		when(reviewPlatformRepository.findGoogle(TOKEN, BRANCH_ID)).thenReturn(Optional.of(new ReviewPlatformRow(
				UUID.randomUUID(), BUSINESS_ID, BRANCH_ID, "GOOGLE", PLACE_ID, null, null, null, "PENDING", true, null)));
		when(reviewPlatformRepository.update(eq(TOKEN), any(), anyMap())).thenReturn(Optional.empty());
		when(googlePlacesClient.lookup(PLACE_ID)).thenReturn(new PlaceLookup(PlaceLookup.Result.NOT_CONFIGURED, null, null));

		assertThatThrownBy(() -> service.save(TOKEN, BRANCH_ID, new SaveGooglePlaceRequest(PLACE_ID, null)))
			.isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo("FORBIDDEN");
	}

	private Map<String, Object> capturedInsert() {
		@SuppressWarnings("unchecked")
		ArgumentCaptor<Map<String, Object>> values = ArgumentCaptor.forClass(Map.class);
		verify(reviewPlatformRepository).insert(eq(TOKEN), values.capture());
		return values.getValue();
	}

	private static ReviewPlatformRow row(Map<String, Object> values) {
		return new ReviewPlatformRow(UUID.randomUUID(), BUSINESS_ID, BRANCH_ID, "GOOGLE", (String) values.get("google_place_id"),
				(String) values.get("review_direct_url"), (String) values.get("place_name"),
				(String) values.get("place_address"), (String) values.get("connection_status"), true, null);
	}

}
