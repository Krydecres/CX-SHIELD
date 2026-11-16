package com.cxshield.backend.billing;

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

}
