package com.cxshield.backend;

import java.util.List;

import com.cxshield.backend.config.CxShieldProperties;

public final class TestProperties {

	public static final String SUPABASE_URL = "https://example.supabase.co";
	public static final String FRONTEND_URL = "http://localhost:3000";
	public static final String VNPAY_TMN_CODE = "TESTTMN1";
	public static final String VNPAY_HASH_SECRET = "TESTHASHSECRET";
	public static final String VNPAY_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
	public static final String VNPAY_RETURN_URL = "http://localhost:8080/api/v1/payments/vnpay/return";

	private TestProperties() {
	}

	public static CxShieldProperties create(String placesApiKey) {
		return create(placesApiKey, null);
	}

	public static CxShieldProperties create(String placesApiKey, String serviceRoleKey) {
		return new CxShieldProperties(
				new CxShieldProperties.Supabase(SUPABASE_URL, "sb_publishable_test", "business-logos", serviceRoleKey),
				new CxShieldProperties.Google(placesApiKey), new CxShieldProperties.Cors(List.of(FRONTEND_URL)),
				new CxShieldProperties.Mail("alerts@example.com"), new CxShieldProperties.Vnpay(VNPAY_TMN_CODE,
						VNPAY_HASH_SECRET, VNPAY_PAY_URL, VNPAY_RETURN_URL),
				new CxShieldProperties.Frontend(FRONTEND_URL));
	}

}
