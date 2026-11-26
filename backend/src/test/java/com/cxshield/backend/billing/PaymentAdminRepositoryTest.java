package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Map;

import org.junit.jupiter.api.Test;

import com.cxshield.backend.supabase.SupabaseAdminClient;

class PaymentAdminRepositoryTest {

	@Test
	void confirmSuccessCallsAtomicActivationRpcWithGatewayDetails() {
		SupabaseAdminClient supabase = mock(SupabaseAdminClient.class);
		PaymentAdminRepository repository = new PaymentAdminRepository(supabase);
		when(supabase.rpc(eq("confirm_payment_success"), anyMap(), eq(String.class))).thenReturn("CONFIRMED");

		String result = repository.confirmSuccess("CXTEST123", "GATEWAY-456", "00");

		assertThat(result).isEqualTo("CONFIRMED");
		verify(supabase).rpc("confirm_payment_success",
				Map.of("p_transaction_code", "CXTEST123", "p_gateway_txn_id", "GATEWAY-456", "p_response_code", "00"),
				String.class);
	}
}
