package com.cxshield.backend.account;

import java.security.SecureRandom;
import java.text.Normalizer;
import java.util.Locale;

/**
 * Tạo public_slug cho cơ sở từ tên thương hiệu tiếng Việt, ví dụ "Maison Coffee & Bistro" → "maison-coffee-bistro-k3x9".
 */
public final class SlugGenerator {

	private static final int MAX_BASE_LENGTH = 40;
	private static final String SUFFIX_CHARS = "abcdefghijkmnpqrstuvwxyz23456789";
	private static final SecureRandom RANDOM = new SecureRandom();

	private SlugGenerator() {
	}

	public static String slugify(String text) {
		String normalized = Normalizer.normalize(text.replace('đ', 'd').replace('Đ', 'D'), Normalizer.Form.NFD)
			.replaceAll("\\p{M}", "")
			.toLowerCase(Locale.ROOT)
			.replaceAll("[^a-z0-9]+", "-")
			.replaceAll("^-+|-+$", "");
		if (normalized.length() > MAX_BASE_LENGTH) {
			normalized = normalized.substring(0, MAX_BASE_LENGTH).replaceAll("-+$", "");
		}
		return normalized.isEmpty() ? "co-so" : normalized;
	}

	public static String generate(String brandName) {
		StringBuilder suffix = new StringBuilder(4);
		for (int i = 0; i < 4; i++) {
			suffix.append(SUFFIX_CHARS.charAt(RANDOM.nextInt(SUFFIX_CHARS.length())));
		}
		return slugify(brandName) + "-" + suffix;
	}

}
