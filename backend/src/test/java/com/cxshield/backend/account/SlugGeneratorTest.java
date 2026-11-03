package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SlugGeneratorTest {

	@Test
	void slugifyRemovesVietnameseDiacritics() {
		assertThat(SlugGenerator.slugify("Đặc sản Phở Hà Nội")).isEqualTo("dac-san-pho-ha-noi");
		assertThat(SlugGenerator.slugify("Maison Coffee & Bistro")).isEqualTo("maison-coffee-bistro");
	}

	@Test
	void slugifyFallsBackWhenNothingRemains() {
		assertThat(SlugGenerator.slugify("!!!")).isEqualTo("co-so");
	}

	@Test
	void slugifyLimitsLength() {
		assertThat(SlugGenerator.slugify("a".repeat(30) + " " + "b".repeat(30))).hasSizeLessThanOrEqualTo(40)
			.doesNotEndWith("-");
	}

	@Test
	void generateAddsRandomSuffix() {
		assertThat(SlugGenerator.generate("Maison Coffee")).matches("maison-coffee-[a-z0-9]{4}");
	}

}
