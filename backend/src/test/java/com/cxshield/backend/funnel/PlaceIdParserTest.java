package com.cxshield.backend.funnel;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import com.cxshield.backend.common.ApiException;

class PlaceIdParserTest {

	private static final String PLACE_ID = "ChIJN1t_tDeuEmsRUsoyG83frY4";

	@Test
	void normalizeTrimsValidPlaceId() {
		assertThat(PlaceIdParser.normalize("  " + PLACE_ID + " ")).isEqualTo(PLACE_ID);
	}

	@ParameterizedTest
	@ValueSource(strings = { "https://search.google.com/local/writereview?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4",
			"https://www.google.com/maps/search/?api=1&query=x&query_place_id=ChIJN1t_tDeuEmsRUsoyG83frY4",
			"place_id:ChIJN1t_tDeuEmsRUsoyG83frY4" })
	void normalizeExtractsPlaceIdFromPastedLink(String input) {
		assertThat(PlaceIdParser.normalize(input)).isEqualTo(PLACE_ID);
	}

	@ParameterizedTest
	@ValueSource(strings = { "", "   ", "ChIJ123", "ChIJ N1t tDeuEmsRUsoyG83frY4", "ChIJN1t_tDeuEmsRUsoyG83frY4!",
			"Quán cà phê Maison" })
	void normalizeRejectsInvalidFormat(String input) {
		assertThatThrownBy(() -> PlaceIdParser.normalize(input)).isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo(PlaceIdParser.INVALID_PLACE_ID);
	}

	@Test
	void reviewUrlUsesGoogleWriteReviewLink() {
		assertThat(PlaceIdParser.reviewUrl(PLACE_ID))
			.isEqualTo("https://search.google.com/local/writereview?placeid=" + PLACE_ID);
	}

	@ParameterizedTest
	@ValueSource(strings = { "https://g.page/r/CabcXYZ/review", "https://search.google.com/local/writereview?placeid=x",
			"https://maps.app.goo.gl/abc" })
	void manualReviewUrlAcceptsGoogleHttpsLinks(String url) {
		assertThat(PlaceIdParser.validateManualReviewUrl(url)).isEqualTo(url);
	}

	@ParameterizedTest
	@ValueSource(strings = { "http://g.page/r/abc", "https://evil-google.com/review", "https://google.com.evil.io/x",
			"không phải link" })
	void manualReviewUrlRejectsOtherLinks(String url) {
		assertThatThrownBy(() -> PlaceIdParser.validateManualReviewUrl(url)).isInstanceOf(ApiException.class)
			.extracting("code")
			.isEqualTo(PlaceIdParser.INVALID_REVIEW_URL);
	}

}
