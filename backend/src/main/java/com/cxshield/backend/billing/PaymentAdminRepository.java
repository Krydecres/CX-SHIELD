package com.cxshield.backend.billing;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.supabase.SupabaseAdminClient;

/**
 * Ghi payments và kích hoạt thuê bao bằng service role: người dùng không có quyền ghi các bảng này,
 * và cổng thanh toán gọi về không kèm token đăng nhập.
 */
@Repository
public class PaymentAdminRepository {

	static final String PAYMENT_COLUMNS = "id,business_id,plan_id,billing_cycle,transaction_code,amount,status,"
			+ "gateway_response_code,paid_at";

	private static final ParameterizedTypeReference<List<PaymentRow>> PAYMENT_ROWS = new ParameterizedTypeReference<>() {
	};

	private final SupabaseAdminClient supabase;

	public PaymentAdminRepository(SupabaseAdminClient supabase) {
		this.supabase = supabase;
	}

	public boolean isEnabled() {
		return supabase.isEnabled();
	}

	public void insertPayment(Map<String, Object> values) {
		supabase.insertWithoutReturn("payments", values);
	}

	public Optional<PaymentRow> findByTransactionCode(String transactionCode) {
		return supabase
			.select("payments", Map.of("select", PAYMENT_COLUMNS, "transaction_code", "eq." + transactionCode), PAYMENT_ROWS)
			.stream()
			.findFirst();
	}

	/**
	 * Chỉ đổi dòng còn PENDING để không ghi đè thanh toán đã thành công.
	 */
	public void markFailed(String transactionCode, String responseCode) {
		Map<String, Object> values = new LinkedHashMap<>();
		values.put("status", "FAILED");
		values.put("gateway_response_code", responseCode);
		supabase.update("payments", Map.of("transaction_code", "eq." + transactionCode, "status", "eq.PENDING"), values);
	}

	/**
	 * @return CONFIRMED, ALREADY_CONFIRMED, NOT_PENDING hoặc NOT_FOUND
	 */
	public String confirmSuccess(String transactionCode, String gatewayTxnId, String responseCode) {
		Map<String, Object> args = new LinkedHashMap<>();
		args.put("p_transaction_code", transactionCode);
		args.put("p_gateway_txn_id", gatewayTxnId);
		args.put("p_response_code", responseCode);
		return supabase.rpc("confirm_payment_success", args, String.class);
	}

}
