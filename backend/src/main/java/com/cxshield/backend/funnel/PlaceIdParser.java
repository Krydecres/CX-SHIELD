package com.cxshield.backend.funnel;

import java.net.URI;
import java.util.Locale;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.cxshield.backend.common.ApiException;

/**
 * Chuẩn hoá và kiểm tra định dạng Google Place ID, tạo link viết đánh giá Google (E4.1).
 */
public final class PlaceIdParser {

	public static final String INVALID_PLACE_ID = "INVALID_PLACE_ID";
	public static final String INVALID_REVIEW_URL = "INVALID_REVIEW_URL";

	// Place ID là chuỗi base64url, thường bắt đầu bằng "ChIJ" và dài từ 27 ký tự.
	private static final Pattern PLACE_ID = Pattern.compile("^[A-Za-z0-9_-]{20,512}$");
	// Cho phép dán cả link chứa Place ID: ...?placeid=XXX, ...?place_id=XXX hoặc place_id:XXX
	private static final Pattern PLACE_ID_IN_TEXT = Pattern.compile("place_?id[=:]([A-Za-z0-9_-]+)",
			Pattern.CASE_INSENSITIVE);
	private static final String WRITE_REVIEW_URL = "https://search.google.com/local/writereview?placeid=";
	private static final Set<String> GOOGLE_REVIEW_HOSTS = Set.of("google.com", "g.page", "goo.gl");

	private PlaceIdParser() {
	}

	public static String normalize(String input) {
		if (input == null || input.isBlank()) {
			throw ApiException.badRequest(INVALID_PLACE_ID, "Vui lòng nhập Google Place ID.");
		}
		String value = input.trim();
		Matcher embedded = PLACE_ID_IN_TEXT.matcher(value);
		if (embedded.find()) {
			value = embedded.group(1);
		}
		if (!PLACE_ID.matcher(value).matches()) {
			throw ApiException.badRequest(INVALID_PLACE_ID,
					"Place ID sai định dạng. Place ID gồm chữ, số, dấu - hoặc _ và thường bắt đầu bằng \"ChIJ\".");
		}
		return value;
	}

	public static String reviewUrl(String placeId) {
		return WRITE_REVIEW_URL + placeId;
	}

	/**
	 * Link nhập thủ công phải là https và thuộc tên miền Google.
	 */
	public static String validateManualReviewUrl(String url) {
		String value = url.trim();
		try {
			URI uri = URI.create(value);
			String host = uri.getHost() == null ? "" : uri.getHost().toLowerCase(Locale.ROOT);
			boolean googleHost = GOOGLE_REVIEW_HOSTS.stream()
				.anyMatch(allowed -> host.equals(allowed) || host.endsWith("." + allowed));
			if ("https".equalsIgnoreCase(uri.getScheme()) && googleHost) {
				return value;
			}
		}
		catch (IllegalArgumentException ignored) {
			// rơi xuống lỗi chung bên dưới
		}
		throw ApiException.badRequest(INVALID_REVIEW_URL,
				"Link đánh giá phải là đường dẫn https của Google (google.com, g.page, goo.gl).");
	}

}
