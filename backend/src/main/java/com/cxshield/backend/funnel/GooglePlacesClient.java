package com.cxshield.backend.funnel;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import com.cxshield.backend.config.CxShieldProperties;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Tra cứu địa điểm bằng Google Places API (New). Chỉ hoạt động khi có GOOGLE_PLACES_API_KEY.
 */
@Component
public class GooglePlacesClient {

	private static final Logger log = LoggerFactory.getLogger(GooglePlacesClient.class);

	private final RestClient restClient;
	private final CxShieldProperties.Google google;

	public GooglePlacesClient(CxShieldProperties properties) {
		this.google = properties.google();
		this.restClient = RestClient.builder().baseUrl("https://places.googleapis.com/v1").build();
	}

	public boolean isEnabled() {
		return google != null && google.placesEnabled();
	}

	public PlaceLookup lookup(String placeId) {
		if (!isEnabled()) {
			return PlaceLookup.notConfigured();
		}
		try {
			return restClient.get()
				.uri(builder -> builder.path("/places/{placeId}").queryParam("languageCode", "vi").build(placeId))
				.header("X-Goog-Api-Key", google.placesApiKey())
				.header("X-Goog-FieldMask", "id,displayName,formattedAddress")
				.exchange((request, response) -> {
					HttpStatus status = HttpStatus.resolve(response.getStatusCode().value());
					if (response.getStatusCode().is2xxSuccessful()) {
						PlaceResponse place = response.bodyTo(PlaceResponse.class);
						return place == null ? PlaceLookup.unavailable()
								: PlaceLookup.found(place.displayName() == null ? null : place.displayName().text(),
										place.formattedAddress());
					}
					if (status == HttpStatus.NOT_FOUND || status == HttpStatus.BAD_REQUEST) {
						return PlaceLookup.notFound();
					}
					log.warn("Google Places API trả về HTTP {}", response.getStatusCode().value());
					return PlaceLookup.unavailable();
				});
		}
		catch (RestClientException ex) {
			log.warn("Không gọi được Google Places API: {}", ex.getMessage());
			return PlaceLookup.unavailable();
		}
	}

	public record PlaceLookup(Result result, String name, String address) {

		public enum Result {
			FOUND, NOT_FOUND, UNAVAILABLE, NOT_CONFIGURED
		}

		static PlaceLookup found(String name, String address) {
			return new PlaceLookup(Result.FOUND, name, address);
		}

		static PlaceLookup notFound() {
			return new PlaceLookup(Result.NOT_FOUND, null, null);
		}

		static PlaceLookup unavailable() {
			return new PlaceLookup(Result.UNAVAILABLE, null, null);
		}

		static PlaceLookup notConfigured() {
			return new PlaceLookup(Result.NOT_CONFIGURED, null, null);
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record PlaceResponse(String id, LocalizedText displayName, String formattedAddress) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	record LocalizedText(String text, String languageCode) {
	}

}
