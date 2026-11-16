package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cxshield.backend.TestProperties;
import com.cxshield.backend.config.CxShieldProperties;

class VnpayGatewayTest {

	private VnpayGateway gateway;

	@BeforeEach
	void setUp() {
		gateway = new VnpayGateway(TestProperties.create(null), Clock.fixed(Instant.parse("2026-11-06T03:00:00Z"), ZoneOffset.UTC));
	}

	private Map<String, String> params(String url) {
		return Arrays.stream(URI.create(url).getRawQuery().split("&"))
			.map(pair -> pair.split("=", 2))
			.collect(Collectors.toMap(pair -> pair[0], pair -> URLDecoder.decode(pair[1], StandardCharsets.US_ASCII), (a, b) -> a,
					LinkedHashMap::new));
	}

	@Test
	void paymentUrlHasRequiredFields() {
		String url = gateway.buildPaymentUrl("CX1", 385000, "Thanh toan goi", "1.2.3.4");

		assertThat(url).startsWith(TestProperties.VNPAY_PAY_URL + "?");
		assertThat(params(url)).containsEntry("vnp_Version", "2.1.0")
			.containsEntry("vnp_Command", "pay")
			.containsEntry("vnp_TmnCode", TestProperties.VNPAY_TMN_CODE)
			.containsEntry("vnp_Amount", "38500000")
			.containsEntry("vnp_CurrCode", "VND")
			.containsEntry("vnp_TxnRef", "CX1")
			.containsEntry("vnp_OrderInfo", "Thanh toan goi")
			.containsEntry("vnp_ReturnUrl", TestProperties.VNPAY_RETURN_URL)
			.containsEntry("vnp_IpAddr", "1.2.3.4");
	}

	@Test
	void timesAreInVietnamTimeAndExpireAfterFifteenMinutes() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4"));

		assertThat(params).containsEntry("vnp_CreateDate", "20261106100000").containsEntry("vnp_ExpireDate", "20261106101500");
	}

	@Test
	void parametersAreSortedBeforeSigning() {
		String query = URI.create(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4")).getRawQuery();
		List<String> keys = Arrays.stream(query.split("&")).map(pair -> pair.split("=")[0]).filter(key -> !key.equals("vnp_SecureHash")).toList();

		assertThat(keys).isSorted();
		assertThat(query).contains("vnp_SecureHash=");
	}

	@Test
	void signatureMatchesKnownHmacSha512Value() {
		// Giá trị tính độc lập bằng: printf 'vnp_Amount=100' | openssl dgst -sha512 -hmac TESTHASHSECRET
		assertThat(gateway.sign("vnp_Amount=100")).isEqualTo(
				"65d6d8ad65b870b7cc06e0c36f142156d3ba1fb6fda042f3007e828861976821ddbbe9a312bddf2fc590970905314811f4d24f308f65f6304e8b0ac95378b56b");
	}

	@Test
	void verifiesOwnSignature() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "Thanh toan goi", "1.2.3.4"));

		assertThat(gateway.verify(params)).isTrue();
	}

	@Test
	void acceptsUppercaseHashAndIgnoresHashType() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4"));
		params.put("vnp_SecureHash", params.get("vnp_SecureHash").toUpperCase());
		params.put("vnp_SecureHashType", "HmacSHA512");

		assertThat(gateway.verify(params)).isTrue();
	}

	@Test
	void ignoresParametersOutsideVnpNamespace() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4"));
		params.put("utm_source", "abc");

		assertThat(gateway.verify(params)).isTrue();
	}

	@Test
	void rejectsTamperedAmount() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4"));
		params.put("vnp_Amount", "1");

		assertThat(gateway.verify(params)).isFalse();
	}

	@Test
	void rejectsMissingHash() {
		Map<String, String> params = params(gateway.buildPaymentUrl("CX1", 1000, "x", "1.2.3.4"));
		params.remove("vnp_SecureHash");

		assertThat(gateway.verify(params)).isFalse();
	}

	@Test
	void disabledGatewayRejectsEverything() {
		CxShieldProperties base = TestProperties.create(null);
		CxShieldProperties noKeys = new CxShieldProperties(base.supabase(), base.google(), base.cors(), base.mail(),
				new CxShieldProperties.Vnpay("", "", "url", "return"), base.frontend());
		VnpayGateway disabled = new VnpayGateway(noKeys);

		assertThat(disabled.isEnabled()).isFalse();
		assertThat(disabled.verify(Map.of("vnp_SecureHash", "abc"))).isFalse();
	}

}
