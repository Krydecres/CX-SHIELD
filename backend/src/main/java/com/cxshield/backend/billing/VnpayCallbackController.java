package com.cxshield.backend.billing;

import java.net.URI;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.cxshield.backend.billing.dto.BillingDtos.VnpayIpnResponse;

/**
 * Hai địa chỉ công khai cho VNPAY, không có token đăng nhập; độ tin cậy dựa vào chữ ký HMAC.
 */
@RestController
@RequestMapping("/api/v1/payments/vnpay")
public class VnpayCallbackController {

	private final VnpayCallbackService callbackService;

	public VnpayCallbackController(VnpayCallbackService callbackService) {
		this.callbackService = callbackService;
	}

	@GetMapping("/ipn")
	public VnpayIpnResponse ipn(@RequestParam Map<String, String> params) {
		return callbackService.handleIpn(params);
	}

	@GetMapping("/return")
	public ResponseEntity<Void> returnToApp(@RequestParam Map<String, String> params) {
		return ResponseEntity.status(HttpStatus.FOUND).location(URI.create(callbackService.handleReturn(params))).build();
	}

}
