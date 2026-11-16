package com.cxshield.backend.billing;

import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.billing.dto.BillingDtos.VnpayIpnResponse;
import com.cxshield.backend.config.CxShieldProperties;

/**
 * Xử lý kết quả VNPAY gửi về qua IPN (server gọi server) và Return URL (trình duyệt quay lại).
 * Hai đường cùng một logic và xác nhận lặp lại không tính thêm, vì khi chạy trên máy cá nhân VNPAY
 * không gọi được IPN nên Return URL là đường duy nhất tới được backend.
 */
@Service
public class VnpayCallbackService {

	private static final Logger log = LoggerFactory.getLogger(VnpayCallbackService.class);
	private static final String SUCCESS_CODE = "00";

	private final VnpayGateway vnpay;
	private final PaymentAdminRepository paymentRepository;
	private final String frontendUrl;

	public VnpayCallbackService(VnpayGateway vnpay, PaymentAdminRepository paymentRepository, CxShieldProperties properties) {
		this.vnpay = vnpay;
		this.paymentRepository = paymentRepository;
		this.frontendUrl = properties.frontend().url();
	}

	public VnpayIpnResponse handleIpn(Map<String, String> params) {
		try {
			return process(params);
		}
		catch (RuntimeException ex) {
			log.error("Không xử lý được kết quả VNPAY: {}", ex.getClass().getSimpleName());
			return new VnpayIpnResponse("99", "Unknown error");
		}
	}

	/**
	 * @return URL giao diện để chuyển trình duyệt về; chỉ gắn mã giao dịch khi chữ ký hợp lệ
	 */
	public String handleReturn(Map<String, String> params) {
		VnpayIpnResponse result = handleIpn(params);
		String page = frontendUrl + "/#/billing/plans/result";
		if ("97".equals(result.rspCode())) {
			return page + "?invalid=1";
		}
		String code = UriComponentsBuilder.newInstance()
			.queryParam("code", params.get("vnp_TxnRef"))
			.encode()
			.build()
			.getQuery();
		return page + "?" + code;
	}

	private VnpayIpnResponse process(Map<String, String> params) {
		if (!vnpay.verify(params)) {
			log.warn("Kết quả VNPAY sai chữ ký");
			return new VnpayIpnResponse("97", "Invalid Checksum");
		}
		String transactionCode = params.get("vnp_TxnRef");
		Optional<PaymentRow> found = transactionCode == null ? Optional.empty()
				: paymentRepository.findByTransactionCode(transactionCode);
		if (found.isEmpty()) {
			return new VnpayIpnResponse("01", "Order not found");
		}
		PaymentRow payment = found.get();
		if (!amountMatches(payment, params.get("vnp_Amount"))) {
			log.warn("Số tiền VNPAY không khớp giao dịch {}", transactionCode);
			return new VnpayIpnResponse("04", "Invalid amount");
		}
		if (!"PENDING".equals(payment.status())) {
			return new VnpayIpnResponse("02", "Order already confirmed");
		}

		String responseCode = params.get("vnp_ResponseCode");
		boolean paid = SUCCESS_CODE.equals(responseCode) && SUCCESS_CODE.equals(params.get("vnp_TransactionStatus"));
		if (paid) {
			String result = paymentRepository.confirmSuccess(transactionCode, params.get("vnp_TransactionNo"), responseCode);
			log.info("Giao dịch {} xác nhận: {}", transactionCode, result);
		}
		else {
			paymentRepository.markFailed(transactionCode, responseCode);
			log.info("Giao dịch {} thất bại với mã {}", transactionCode, responseCode);
		}
		return new VnpayIpnResponse("00", "Confirm Success");
	}

	private static boolean amountMatches(PaymentRow payment, String vnpAmount) {
		try {
			return vnpAmount != null && Long.parseLong(vnpAmount) == payment.amount() * 100;
		}
		catch (NumberFormatException ex) {
			return false;
		}
	}

}
