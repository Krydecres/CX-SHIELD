package com.cxshield.backend.billing;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Clock;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.cxshield.backend.config.CxShieldProperties;

/**
 * Tạo URL thanh toán và kiểm tra chữ ký VNPAY (API 2.1.0, HMAC-SHA512).
 * Chữ ký tính trên các tham số vnp_ đã sắp theo tên và mã hoá URL.
 */
@Component
public class VnpayGateway {

	static final String SECURE_HASH = "vnp_SecureHash";
	static final String SECURE_HASH_TYPE = "vnp_SecureHashType";

	private static final String HMAC_ALGORITHM = "HmacSHA512";
	private static final int EXPIRE_MINUTES = 15;
	private static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");
	private static final DateTimeFormatter TIME_FORMAT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

	private final CxShieldProperties.Vnpay vnpay;
	private final Clock clock;

	@Autowired
	public VnpayGateway(CxShieldProperties properties) {
		this(properties, Clock.system(VIETNAM));
	}

	VnpayGateway(CxShieldProperties properties, Clock clock) {
		this.vnpay = properties.vnpay();
		this.clock = clock;
	}

	public boolean isEnabled() {
		return vnpay != null && vnpay.enabled();
	}

	/**
	 * @param amount số tiền VND; VNPAY nhận giá trị nhân 100
	 * @param orderInfo nội dung thanh toán, không dấu và không ký tự đặc biệt theo yêu cầu của VNPAY
	 */
	public String buildPaymentUrl(String transactionCode, long amount, String orderInfo, String clientIp) {
		ZonedDateTime now = ZonedDateTime.now(clock.withZone(VIETNAM));
		Map<String, String> params = new TreeMap<>();
		params.put("vnp_Version", "2.1.0");
		params.put("vnp_Command", "pay");
		params.put("vnp_TmnCode", vnpay.tmnCode());
		params.put("vnp_Amount", String.valueOf(amount * 100));
		params.put("vnp_CurrCode", "VND");
		params.put("vnp_TxnRef", transactionCode);
		params.put("vnp_OrderInfo", orderInfo);
		params.put("vnp_OrderType", "other");
		params.put("vnp_Locale", "vn");
		params.put("vnp_ReturnUrl", vnpay.returnUrl());
		params.put("vnp_IpAddr", clientIp);
		params.put("vnp_CreateDate", TIME_FORMAT.format(now));
		params.put("vnp_ExpireDate", TIME_FORMAT.format(now.plusMinutes(EXPIRE_MINUTES)));
		String query = canonicalQuery(params);
		return vnpay.payUrl() + "?" + query + "&" + SECURE_HASH + "=" + sign(query);
	}

	/**
	 * Kiểm tra chữ ký của tham số VNPAY gửi về. So sánh theo thời gian cố định để không lộ chữ ký qua thời gian phản hồi.
	 */
	public boolean verify(Map<String, String> params) {
		String received = params.get(SECURE_HASH);
		if (received == null || received.isBlank() || !isEnabled()) {
			return false;
		}
		Map<String, String> signed = new TreeMap<>();
		params.forEach((key, value) -> {
			if (key.startsWith("vnp_") && !SECURE_HASH.equals(key) && !SECURE_HASH_TYPE.equals(key) && value != null
					&& !value.isEmpty()) {
				signed.put(key, value);
			}
		});
		byte[] expected = sign(canonicalQuery(signed)).getBytes(StandardCharsets.US_ASCII);
		return MessageDigest.isEqual(expected, received.toLowerCase().getBytes(StandardCharsets.US_ASCII));
	}

	String sign(String data) {
		try {
			Mac mac = Mac.getInstance(HMAC_ALGORITHM);
			mac.init(new SecretKeySpec(vnpay.hashSecret().getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM));
			return HexFormat.of().formatHex(mac.doFinal(data.getBytes(StandardCharsets.UTF_8)));
		}
		catch (GeneralSecurityException ex) {
			throw new IllegalStateException("Không tạo được chữ ký VNPAY", ex);
		}
	}

	private static String canonicalQuery(Map<String, String> sortedParams) {
		return sortedParams.entrySet()
			.stream()
			.map(entry -> encode(entry.getKey()) + "=" + encode(entry.getValue()))
			.collect(Collectors.joining("&"));
	}

	private static String encode(String value) {
		return URLEncoder.encode(value, StandardCharsets.US_ASCII);
	}

}
