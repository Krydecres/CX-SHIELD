package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.HttpStatus;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.RoleRef;
import com.cxshield.backend.billing.BillingRepository.BillingProfileRow;
import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.billing.BillingRepository.PlanRef;
import com.cxshield.backend.billing.BillingRepository.PlanRow;
import com.cxshield.backend.billing.BillingRepository.SubscriptionRow;
import com.cxshield.backend.billing.dto.BillingDtos.BillingProfileDto;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutRequest;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PaymentStatusResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PlanResponse;
import com.cxshield.backend.billing.dto.BillingDtos.SubscriptionResponse;
import com.cxshield.backend.common.ApiException;

class BillingServiceTest {

	private static final String TOKEN = "token";
	private static final UUID USER_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID PLAN_ID = UUID.randomUUID();
	private static final String IP = "1.2.3.4";
	private static final PlanRow PLAN = new PlanRow(PLAN_ID, "Nâng cao", 350000L, 3360000L, null, 1, null, List.of("Mã QR không giới hạn"),
			null);
	private static final BillingProfileDto PROFILE = new BillingProfileDto("0312345678", "Công ty A", "1 Lê Lợi", "ketoan@a.vn", "Lan");

	private AccountRepository accountRepository;
	private BillingRepository billingRepository;
	private PaymentAdminRepository paymentRepository;
	private VnpayGateway vnpay;
	private BillingService service;

	@BeforeEach
	void setUp() {
		accountRepository = mock(AccountRepository.class);
		billingRepository = mock(BillingRepository.class);
		paymentRepository = mock(PaymentAdminRepository.class);
		vnpay = mock(VnpayGateway.class);
		service = new BillingService(accountRepository, billingRepository, paymentRepository, vnpay,
				Clock.fixed(Instant.parse("2026-11-06T03:00:00Z"), ZoneOffset.UTC));
		when(accountRepository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(membership(BUSINESS_ID, "OWNER")));
		when(billingRepository.findPlan(TOKEN, PLAN_ID)).thenReturn(Optional.of(PLAN));
		when(billingRepository.findBillingProfile(TOKEN, BUSINESS_ID)).thenReturn(Optional.empty());
		when(vnpay.isEnabled()).thenReturn(true);
		when(paymentRepository.isEnabled()).thenReturn(true);
		when(vnpay.buildPaymentUrl(anyString(), anyLong(), anyString(), anyString())).thenReturn("https://pay");
	}

	@Test
	void plansComeFromDatabase() {
		when(billingRepository.findActivePlans(TOKEN)).thenReturn(List.of(PLAN));

		List<PlanResponse> plans = service.getPlans(TOKEN);

		assertThat(plans).hasSize(1);
		assertThat(plans.get(0).name()).isEqualTo("Nâng cao");
		assertThat(plans.get(0).monthlyPrice()).isEqualTo(350000L);
		assertThat(plans.get(0).features()).containsExactly("Mã QR không giới hạn");
	}

	@Test
	void subscriptionIsEmptyWhenBusinessHasNoPlan() {
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.empty());

		assertThat(service.getSubscription(TOKEN, USER_ID, BUSINESS_ID).status()).isNull();
	}

	@Test
	void subscriptionShowsCurrentPlan() {
		LocalDate end = LocalDate.of(2026, 12, 6);
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(new SubscriptionRow(UUID.randomUUID(),
				PLAN_ID, BillingCycle.MONTHLY, "ACTIVE", LocalDate.of(2026, 11, 6), end, new PlanRef("Nâng cao"))));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.planName()).isEqualTo("Nâng cao");
		assertThat(response.status()).isEqualTo("ACTIVE");
		assertThat(response.endDate()).isEqualTo(end);
		assertThat(response.daysRemaining()).isEqualTo(30);
		assertThat(response.isExpiringSoon()).isFalse();
		assertThat(response.isOverdue()).isFalse();
	}

	@Test
	void subscriptionShowsExpiringSoonWhenWithinSevenDays() {
		LocalDate end = LocalDate.of(2026, 11, 10);
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(new SubscriptionRow(UUID.randomUUID(),
				PLAN_ID, BillingCycle.MONTHLY, "ACTIVE", LocalDate.of(2026, 10, 10), end, new PlanRef("Nâng cao"))));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.daysRemaining()).isEqualTo(4);
		assertThat(response.isExpiringSoon()).isTrue();
		assertThat(response.isOverdue()).isFalse();
	}

	@Test
	void subscriptionShowsOverdueWhenPastEndDate() {
		LocalDate end = LocalDate.of(2026, 11, 1);
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(new SubscriptionRow(UUID.randomUUID(),
				PLAN_ID, BillingCycle.MONTHLY, "OVERDUE", LocalDate.of(2026, 10, 1), end, new PlanRef("Nâng cao"))));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.daysRemaining()).isEqualTo(-5);
		assertThat(response.isExpiringSoon()).isFalse();
		assertThat(response.isOverdue()).isTrue();
	}

	@Test
	void updatesAutoRenewSuccessfully() {
		UUID subId = UUID.randomUUID();
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(new SubscriptionRow(subId,
				PLAN_ID, BillingCycle.MONTHLY, "ACTIVE", LocalDate.of(2026, 11, 1), LocalDate.of(2026, 12, 1), new PlanRef("Nâng cao"))));

		SubscriptionResponse response = service.updateAutoRenew(TOKEN, USER_ID, BUSINESS_ID, true);

		verify(billingRepository).updateSubscriptionAutoRenew(TOKEN, subId, true);
		assertThat(response.autoRenew()).isTrue();
	}

	@Test
	void paymentHistoryReturnsFormattedPayments() {
		UUID payId = UUID.randomUUID();
		PaymentRow p = new PaymentRow(payId, BUSINESS_ID, PLAN_ID, BillingCycle.MONTHLY, "CX100", 385000L, "SUCCESS", "00", java.time.OffsetDateTime.now());
		when(billingRepository.findPaymentsByBusiness(TOKEN, BUSINESS_ID)).thenReturn(List.of(p));

		var history = service.getPaymentHistory(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(history).hasSize(1);
		assertThat(history.get(0).transactionCode()).isEqualTo("CX100");
		assertThat(history.get(0).status()).isEqualTo("SUCCESS");
		assertThat(history.get(0).hasInvoice()).isTrue();
	}

	@Test
	void invoicesCanBeExportedAsPdfAndXml() throws Exception {
		UUID invId = UUID.randomUUID();
		UUID payId = UUID.randomUUID();
		var invRow = new com.cxshield.backend.billing.BillingRepository.InvoiceRow(
				invId, BUSINESS_ID, payId, "HD-CX100", "Công ty ABC", "123 Đường A", "0123456789", "Nguyễn Văn A", "ketoan@abc.vn",
				350000L, 10.0, 35000L, 385000L, java.time.OffsetDateTime.now());
		when(billingRepository.findInvoiceById(TOKEN, invId)).thenReturn(Optional.of(invRow));

		byte[] pdfBytes = service.exportInvoicePdf(TOKEN, USER_ID, BUSINESS_ID, invId);
		assertThat(pdfBytes).isNotEmpty();

		byte[] xmlBytes = service.exportInvoiceXml(TOKEN, USER_ID, BUSINESS_ID, invId);
		assertThat(xmlBytes).isNotEmpty();
		assertThat(new String(xmlBytes)).contains("<HDon").contains("</HDon>").contains("0123456789");
	}

	@Test
	void billingProfileIsEmptyWhenNotSaved() {
		assertThat(service.getBillingProfile(TOKEN, USER_ID, BUSINESS_ID).taxCode()).isNull();
	}

	@Test
	void billingProfileReturnsSavedValues() {
		when(billingRepository.findBillingProfile(TOKEN, BUSINESS_ID)).thenReturn(
				Optional.of(new BillingProfileRow(UUID.randomUUID(), BUSINESS_ID, "Công ty A", null, "0312345678", "a@b.vn", null)));

		assertThat(service.getBillingProfile(TOKEN, USER_ID, BUSINESS_ID).companyName()).isEqualTo("Công ty A");
	}

	@Test
	void checkoutCalculatesAmountFromPlanWithVat() {
		CheckoutResponse response = checkout(BillingCycle.MONTHLY, null);

		assertThat(response.subtotal()).isEqualTo(350000);
		assertThat(response.vatAmount()).isEqualTo(35000);
		assertThat(response.totalAmount()).isEqualTo(385000);
		assertThat(response.paymentUrl()).isEqualTo("https://pay");
		assertThat(response.transactionCode()).startsWith("CX261106100000").matches("[A-Z0-9]+");

		Map<String, Object> payment = storedPayment();
		assertThat(payment).containsEntry("amount", 385000L)
			.containsEntry("business_id", BUSINESS_ID)
			.containsEntry("plan_id", PLAN_ID)
			.containsEntry("billing_cycle", "MONTHLY")
			.containsEntry("method", "VNPAY")
			.containsEntry("transaction_code", response.transactionCode());
		verify(vnpay).buildPaymentUrl(eq(response.transactionCode()), eq(385000L), anyString(), eq(IP));
	}

	@Test
	void yearlyUsesYearlyPrice() {
		assertThat(checkout(BillingCycle.YEARLY, null).subtotal()).isEqualTo(3360000);
	}

	@Test
	void transactionCodesAreUnique() {
		assertThat(checkout(BillingCycle.MONTHLY, null).transactionCode()).isNotEqualTo(checkout(BillingCycle.MONTHLY, null).transactionCode());
	}

	@Test
	void rejectsCycleThePlanDoesNotOffer() {
		assertCode(() -> checkout(BillingCycle.LIFETIME, null), "CYCLE_NOT_AVAILABLE");
		verify(paymentRepository, never()).insertPayment(anyMap());
	}

	@Test
	void rejectsUnknownPlan() {
		UUID other = UUID.randomUUID();
		when(billingRepository.findPlan(TOKEN, other)).thenReturn(Optional.empty());

		assertCode(() -> service.createCheckout(TOKEN, USER_ID, BUSINESS_ID, new CheckoutRequest(other, BillingCycle.MONTHLY, null), IP),
				"PLAN_NOT_FOUND");
	}

	@Test
	void onlyOwnerCanCheckout() {
		when(accountRepository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(membership(BUSINESS_ID, "BRANCH_MANAGER")));

		assertCode(() -> checkout(BillingCycle.MONTHLY, null), "FORBIDDEN");
		verify(paymentRepository, never()).insertPayment(anyMap());
	}

	@Test
	void ownerOfAnotherBusinessIsRejected() {
		when(accountRepository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(membership(UUID.randomUUID(), "OWNER")));

		assertCode(() -> service.getSubscription(TOKEN, USER_ID, BUSINESS_ID), "FORBIDDEN");
	}

	@Test
	void reportsGatewayNotConfigured() {
		when(vnpay.isEnabled()).thenReturn(false);

		assertThatThrownBy(() -> checkout(BillingCycle.MONTHLY, null)).isInstanceOf(ApiException.class)
			.hasFieldOrPropertyWithValue("code", "PAYMENT_NOT_CONFIGURED")
			.hasFieldOrPropertyWithValue("status", HttpStatus.SERVICE_UNAVAILABLE);
	}

	@Test
	void reportsMissingServiceRoleKey() {
		when(paymentRepository.isEnabled()).thenReturn(false);

		assertCode(() -> checkout(BillingCycle.MONTHLY, null), "PAYMENT_NOT_CONFIGURED");
	}

	@Test
	void savesNewBillingProfile() {
		checkout(BillingCycle.MONTHLY, PROFILE);

		ArgumentCaptor<Map<String, Object>> values = captor();
		verify(billingRepository).insertBillingProfile(eq(TOKEN), values.capture());
		assertThat(values.getValue()).containsEntry("tax_code", "0312345678")
			.containsEntry("company_name", "Công ty A")
			.containsEntry("billing_email", "ketoan@a.vn")
			.containsEntry("business_id", BUSINESS_ID);
	}

	@Test
	void updatesExistingBillingProfile() {
		UUID profileId = UUID.randomUUID();
		when(billingRepository.findBillingProfile(TOKEN, BUSINESS_ID))
			.thenReturn(Optional.of(new BillingProfileRow(profileId, BUSINESS_ID, null, null, null, null, null)));

		checkout(BillingCycle.MONTHLY, PROFILE);

		verify(billingRepository).updateBillingProfile(eq(TOKEN), eq(profileId), anyMap());
		verify(billingRepository, never()).insertBillingProfile(any(), anyMap());
	}

	@Test
	void validatesBillingProfile() {
		assertCode(() -> checkout(BillingCycle.MONTHLY, new BillingProfileDto("123", "A", null, "a@b.vn", null)), "INVALID_TAX_CODE");
		assertCode(() -> checkout(BillingCycle.MONTHLY, new BillingProfileDto("0312345678", " ", null, "a@b.vn", null)), "INVALID_COMPANY_NAME");
		assertCode(() -> checkout(BillingCycle.MONTHLY, new BillingProfileDto("0312345678", "A", null, "a@b", null)), "INVALID_BILLING_EMAIL");
		verify(paymentRepository, never()).insertPayment(anyMap());
	}

	@Test
	void acceptsThirteenDigitTaxCode() {
		checkout(BillingCycle.MONTHLY, new BillingProfileDto("0312345678-001", "A", null, "a@b.vn", null));

		verify(paymentRepository).insertPayment(anyMap());
	}

	@Test
	void paymentStatusShowsMessage() {
		when(billingRepository.findPayment(TOKEN, BUSINESS_ID, "CX1")).thenReturn(Optional.of(payment("SUCCESS", "00")));

		PaymentStatusResponse response = service.getPayment(TOKEN, USER_ID, BUSINESS_ID, "CX1");

		assertThat(response.status()).isEqualTo("SUCCESS");
		assertThat(response.message()).contains("đã được kích hoạt");
	}

	@Test
	void messagesExplainEachOutcome() {
		assertThat(BillingService.messageFor(payment("PENDING", null))).contains("chờ xác nhận");
		assertThat(BillingService.messageFor(payment("FAILED", "24"))).contains("huỷ giao dịch").contains("chưa được kích hoạt");
		assertThat(BillingService.messageFor(payment("FAILED", "51"))).contains("không thành công").contains("chưa được kích hoạt");
	}

	@Test
	void unknownPaymentIsNotFound() {
		when(billingRepository.findPayment(TOKEN, BUSINESS_ID, "CX1")).thenReturn(Optional.empty());

		assertCode(() -> service.getPayment(TOKEN, USER_ID, BUSINESS_ID, "CX1"), "PAYMENT_NOT_FOUND");
	}

	private CheckoutResponse checkout(BillingCycle cycle, BillingProfileDto profile) {
		return service.createCheckout(TOKEN, USER_ID, BUSINESS_ID, new CheckoutRequest(PLAN_ID, cycle, profile), IP);
	}

	private Map<String, Object> storedPayment() {
		ArgumentCaptor<Map<String, Object>> values = captor();
		verify(paymentRepository).insertPayment(values.capture());
		return values.getValue();
	}

	private static void assertCode(org.assertj.core.api.ThrowableAssert.ThrowingCallable call, String code) {
		assertThatThrownBy(call).isInstanceOf(ApiException.class).hasFieldOrPropertyWithValue("code", code);
	}

	private static MembershipRow membership(UUID businessId, String role) {
		return new MembershipRow(UUID.randomUUID(), businessId, "ACTIVE", new RoleRef(role), null);
	}

	private static PaymentRow payment(String status, String responseCode) {
		return new PaymentRow(UUID.randomUUID(), BUSINESS_ID, PLAN_ID, BillingCycle.MONTHLY, "CX1", 385000, status, responseCode, null);
	}

	@SuppressWarnings({ "unchecked", "rawtypes" })
	private static ArgumentCaptor<Map<String, Object>> captor() {
		return (ArgumentCaptor) ArgumentCaptor.forClass(Map.class);
	}

}
