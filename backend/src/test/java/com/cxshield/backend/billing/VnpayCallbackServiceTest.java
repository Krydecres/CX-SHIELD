package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cxshield.backend.TestProperties;
import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.billing.dto.BillingDtos.VnpayIpnResponse;

class VnpayCallbackServiceTest {

	private static final String CODE = "CX261106100000ABCDEF";
	private static final long AMOUNT = 385000;

	private VnpayGateway gateway;
	private PaymentAdminRepository repository;
	private VnpayCallbackService service;

	@BeforeEach
	void setUp() {
		gateway = mock(VnpayGateway.class);
		repository = mock(PaymentAdminRepository.class);
		service = new VnpayCallbackService(gateway, repository, TestProperties.create(null));
		when(gateway.verify(any())).thenReturn(true);
		when(repository.findByTransactionCode(CODE)).thenReturn(Optional.of(payment("PENDING")));
		when(repository.confirmSuccess(anyString(), any(), anyString())).thenReturn("CONFIRMED");
	}

	@Test
	void successfulPaymentActivatesSubscription() {
		VnpayIpnResponse response = service.handleIpn(params("00", "00"));

		assertThat(response.rspCode()).isEqualTo("00");
		assertThat(response.message()).isEqualTo("Confirm Success");
		verify(repository).confirmSuccess(CODE, "14000000", "00");
		verify(repository, never()).markFailed(any(), any());
	}

	@Test
	void cancelledPaymentDoesNotActivate() {
		VnpayIpnResponse response = service.handleIpn(params("24", "02"));

		assertThat(response.rspCode()).isEqualTo("00");
		verify(repository).markFailed(CODE, "24");
		verify(repository, never()).confirmSuccess(any(), any(), any());
	}

	@Test
	void successResponseCodeWithFailedTransactionStatusDoesNotActivate() {
		service.handleIpn(params("00", "02"));

		verify(repository).markFailed(CODE, "00");
		verify(repository, never()).confirmSuccess(any(), any(), any());
	}

	@Test
	void invalidSignatureChangesNothing() {
		when(gateway.verify(any())).thenReturn(false);

		VnpayIpnResponse response = service.handleIpn(params("00", "00"));

		assertThat(response.rspCode()).isEqualTo("97");
		verify(repository, never()).findByTransactionCode(any());
		verify(repository, never()).confirmSuccess(any(), any(), any());
	}

	@Test
	void unknownOrderIsReported() {
		when(repository.findByTransactionCode(CODE)).thenReturn(Optional.empty());

		assertThat(service.handleIpn(params("00", "00")).rspCode()).isEqualTo("01");
	}

	@Test
	void missingOrderReferenceIsReported() {
		Map<String, String> params = params("00", "00");
		params.remove("vnp_TxnRef");

		assertThat(service.handleIpn(params).rspCode()).isEqualTo("01");
	}

	@Test
	void wrongAmountDoesNotActivate() {
		Map<String, String> params = params("00", "00");
		params.put("vnp_Amount", "100");

		assertThat(service.handleIpn(params).rspCode()).isEqualTo("04");
		verify(repository, never()).confirmSuccess(any(), any(), any());
	}

	@Test
	void malformedAmountDoesNotActivate() {
		Map<String, String> params = params("00", "00");
		params.put("vnp_Amount", "abc");

		assertThat(service.handleIpn(params).rspCode()).isEqualTo("04");
	}

	@Test
	void repeatedNotificationIsNotAppliedTwice() {
		when(repository.findByTransactionCode(CODE)).thenReturn(Optional.of(payment("SUCCESS")));

		assertThat(service.handleIpn(params("00", "00")).rspCode()).isEqualTo("02");
		verify(repository, never()).confirmSuccess(any(), any(), any());
	}

	@Test
	void unexpectedErrorReturnsUnknownCode() {
		when(repository.findByTransactionCode(CODE)).thenThrow(new IllegalStateException("db"));

		assertThat(service.handleIpn(params("00", "00")).rspCode()).isEqualTo("99");
	}

	@Test
	void returnProcessesPaymentAndRedirectsToResultPage() {
		String url = service.handleReturn(params("00", "00"));

		assertThat(url).isEqualTo(TestProperties.FRONTEND_URL + "/#/billing/plans/result?code=" + CODE);
		verify(repository).confirmSuccess(CODE, "14000000", "00");
	}

	@Test
	void returnWithBadSignatureDoesNotExposeCode() {
		when(gateway.verify(any())).thenReturn(false);

		String url = service.handleReturn(params("00", "00"));

		assertThat(url).endsWith("/billing/plans/result?invalid=1").doesNotContain(CODE);
	}

	private static Map<String, String> params(String responseCode, String transactionStatus) {
		Map<String, String> params = new HashMap<>();
		params.put("vnp_TxnRef", CODE);
		params.put("vnp_Amount", String.valueOf(AMOUNT * 100));
		params.put("vnp_ResponseCode", responseCode);
		params.put("vnp_TransactionStatus", transactionStatus);
		params.put("vnp_TransactionNo", "14000000");
		params.put("vnp_SecureHash", "hash");
		return params;
	}

	private static PaymentRow payment(String status) {
		return new PaymentRow(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), BillingCycle.MONTHLY, CODE, AMOUNT, status,
				null, null);
	}

}
