package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.Jwt;

import com.cxshield.backend.billing.dto.BillingDtos.CheckoutRequest;

import jakarta.servlet.http.HttpServletRequest;

class BillingControllerTest {

	private static final UUID USER_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();

	private BillingService service;
	private BillingController controller;
	private Jwt jwt;

	@BeforeEach
	void setUp() {
		service = mock(BillingService.class);
		controller = new BillingController(service);
		jwt = Jwt.withTokenValue("token").header("alg", "ES256").subject(USER_ID.toString()).build();
	}

	@Test
	void plansUseUserToken() {
		controller.plans(jwt);

		verify(service).getPlans("token");
	}

	@Test
	void subscriptionPassesUserAndBusiness() {
		controller.subscription(jwt, BUSINESS_ID);

		verify(service).getSubscription("token", USER_ID, BUSINESS_ID);
	}

	@Test
	void billingProfilePassesUserAndBusiness() {
		controller.billingProfile(jwt, BUSINESS_ID);

		verify(service).getBillingProfile("token", USER_ID, BUSINESS_ID);
	}

	@Test
	void checkoutPassesClientIp() {
		CheckoutRequest request = new CheckoutRequest(UUID.randomUUID(), BillingCycle.MONTHLY, null);
		HttpServletRequest servletRequest = mock(HttpServletRequest.class);
		when(servletRequest.getRemoteAddr()).thenReturn("1.2.3.4");

		controller.checkout(jwt, BUSINESS_ID, request, servletRequest);

		verify(service).createCheckout("token", USER_ID, BUSINESS_ID, request, "1.2.3.4");
	}

	@Test
	void paymentPassesCode() {
		controller.payment(jwt, BUSINESS_ID, "CX1");

		verify(service).getPayment("token", USER_ID, BUSINESS_ID, "CX1");
	}

	@Test
	void updateAutoRenewCallsService() {
		com.cxshield.backend.billing.dto.BillingDtos.AutoRenewRequest req =
				new com.cxshield.backend.billing.dto.BillingDtos.AutoRenewRequest(true);
		controller.updateAutoRenew(jwt, BUSINESS_ID, req);

		verify(service).updateAutoRenew("token", USER_ID, BUSINESS_ID, true);
	}

	@Test
	void paymentHistoryCallsService() {
		controller.paymentHistory(jwt, BUSINESS_ID);

		verify(service).getPaymentHistory("token", USER_ID, BUSINESS_ID);
	}

	@Test
	void invoicesCallsService() {
		controller.invoices(jwt, BUSINESS_ID);

		verify(service).getInvoices("token", USER_ID, BUSINESS_ID);
	}

	@Test
	void exportInvoicePdfCallsService() throws Exception {
		UUID invoiceId = UUID.randomUUID();
		when(service.exportInvoicePdf("token", USER_ID, BUSINESS_ID, invoiceId))
				.thenReturn("%PDF-1.4 sample".getBytes());

		org.springframework.http.ResponseEntity<byte[]> response =
				controller.exportInvoicePdf(jwt, BUSINESS_ID, invoiceId);

		assertThat(response.getStatusCode().value()).isEqualTo(200);
		assertThat(response.getHeaders().getContentType()).isEqualTo(org.springframework.http.MediaType.APPLICATION_PDF);
		verify(service).exportInvoicePdf("token", USER_ID, BUSINESS_ID, invoiceId);
	}

	@Test
	void exportInvoiceXmlCallsService() {
		UUID invoiceId = UUID.randomUUID();
		when(service.exportInvoiceXml("token", USER_ID, BUSINESS_ID, invoiceId))
				.thenReturn("<HDon></HDon>".getBytes());

		org.springframework.http.ResponseEntity<byte[]> response =
				controller.exportInvoiceXml(jwt, BUSINESS_ID, invoiceId);

		assertThat(response.getStatusCode().value()).isEqualTo(200);
		assertThat(response.getHeaders().getContentType()).isEqualTo(org.springframework.http.MediaType.APPLICATION_XML);
		verify(service).exportInvoiceXml("token", USER_ID, BUSINESS_ID, invoiceId);
	}

}
