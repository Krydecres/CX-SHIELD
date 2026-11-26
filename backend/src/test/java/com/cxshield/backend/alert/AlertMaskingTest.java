package com.cxshield.backend.alert;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class AlertMaskingTest {

	@Test
	void tokenKeepsLastFourCharacters() {
		assertThat(AlertMasking.maskToken("123456:abcdefgh")).isEqualTo("••••••efgh");
	}

	@Test
	void shortTokenIsFullyMasked() {
		assertThat(AlertMasking.maskToken("abc")).isEqualTo("••••••");
	}

	@Test
	void emptyTokenStaysEmpty() {
		assertThat(AlertMasking.maskToken(null)).isNull();
		assertThat(AlertMasking.maskToken(" ")).isNull();
	}

}
