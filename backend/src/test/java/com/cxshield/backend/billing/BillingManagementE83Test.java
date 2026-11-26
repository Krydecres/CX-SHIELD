package com.cxshield.backend.billing;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.RoleRef;
import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.billing.BillingRepository.PlanRef;
import com.cxshield.backend.billing.BillingRepository.SubscriptionRow;
import com.cxshield.backend.billing.dto.BillingDtos.SubscriptionResponse;
import com.cxshield.backend.common.ApiException;

class BillingManagementE83Test {

	private static final String TOKEN = "test-token";
	private static final UUID USER_ID = UUID.randomUUID();
	private static final UUID BUSINESS_ID = UUID.randomUUID();
	private static final UUID PLAN_ID = UUID.randomUUID();

	private AccountRepository accountRepository;
	private BillingRepository billingRepository;
	private BillingService service;

	@BeforeEach
	void setUp() {
		accountRepository = mock(AccountRepository.class);
		billingRepository = mock(BillingRepository.class);
		service = new BillingService(accountRepository, billingRepository, mock(PaymentAdminRepository.class), mock(VnpayGateway.class),
				Clock.fixed(Instant.parse("2026-11-06T03:00:00Z"), ZoneOffset.UTC));
		when(accountRepository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(membership("OWNER")));
	}

	@Test
	void subscriptionExpiringExactlyInSevenDaysShowsBanner() {
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID))
				.thenReturn(Optional.of(subscription("ACTIVE", BillingCycle.MONTHLY, LocalDate.of(2026, 11, 13), false)));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.daysRemaining()).isEqualTo(7);
		assertThat(response.isExpiringSoon()).isTrue();
		assertThat(response.autoRenew()).isFalse();
	}

	@Test
	void subscriptionExpiringInEightDaysDoesNotShowBanner() {
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID))
				.thenReturn(Optional.of(subscription("ACTIVE", BillingCycle.MONTHLY, LocalDate.of(2026, 11, 14), true)));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.daysRemaining()).isEqualTo(8);
		assertThat(response.isExpiringSoon()).isFalse();
	}

	@Test
	void lifetimeSubscriptionHasNoExpiryCountdownOrBanner() {
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID))
				.thenReturn(Optional.of(subscription("ACTIVE", BillingCycle.LIFETIME, null, true)));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.daysRemaining()).isNull();
		assertThat(response.isExpiringSoon()).isFalse();
		assertThat(response.isOverdue()).isFalse();
	}

	@Test
	void trialDatesAndGraceWindowAreReturnedWithoutChangingStatus() {
		SubscriptionRow trial = new SubscriptionRow(UUID.randomUUID(), PLAN_ID, BillingCycle.MONTHLY, "TRIAL",
				LocalDate.of(2026, 10, 1), LocalDate.of(2026, 12, 1), false, LocalDate.of(2026, 11, 10),
				LocalDate.of(2026, 12, 8), new PlanRef("Nâng cao"));
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(trial));

		SubscriptionResponse response = service.getSubscription(TOKEN, USER_ID, BUSINESS_ID);

		assertThat(response.status()).isEqualTo("TRIAL");
		assertThat(response.trialEndDate()).isEqualTo(LocalDate.of(2026, 11, 10));
		assertThat(response.graceUntil()).isEqualTo(LocalDate.of(2026, 12, 8));
		assertThat(response.autoRenew()).isFalse();
	}

	@Test
	void ownerCanDisableAutoRenew() {
		UUID subscriptionId = UUID.randomUUID();
		SubscriptionRow current = subscription(subscriptionId, "ACTIVE", LocalDate.of(2026, 12, 1), true);
		SubscriptionRow updated = subscription(subscriptionId, "ACTIVE", LocalDate.of(2026, 12, 1), false);
		when(billingRepository.findCurrentSubscription(TOKEN, BUSINESS_ID)).thenReturn(Optional.of(current));
		when(billingRepository.updateSubscriptionAutoRenew(TOKEN, subscriptionId, false)).thenReturn(Optional.of(updated));

		SubscriptionResponse response = service.updateAutoRenew(TOKEN, USER_ID, BUSINESS_ID, false);

		assertThat(response.autoRenew()).isFalse();
		verify(billingRepository).updateSubscriptionAutoRenew(TOKEN, subscriptionId, false);
	}

	@Test
	void nonOwnerCannotReadPaymentHistoryOrInvoicesForBusiness() {
		when(accountRepository.findActiveMemberships(TOKEN, USER_ID)).thenReturn(List.of(membership("BRANCH_MANAGER")));

		assertThatThrownBy(() -> service.getPaymentHistory(TOKEN, USER_ID, BUSINESS_ID))
				.isInstanceOf(ApiException.class).hasFieldOrPropertyWithValue("code", "FORBIDDEN");
		assertThatThrownBy(() -> service.getInvoices(TOKEN, USER_ID, BUSINESS_ID))
				.isInstanceOf(ApiException.class).hasFieldOrPropertyWithValue("code", "FORBIDDEN");
		verify(billingRepository, never()).findPaymentsByBusiness(TOKEN, BUSINESS_ID);
		verify(billingRepository, never()).findInvoicesByBusiness(TOKEN, BUSINESS_ID);
	}

	@Test
	void invoiceFromAnotherBusinessCannotBeExported() {
		UUID invoiceId = UUID.randomUUID();
		when(billingRepository.findInvoiceById(TOKEN, invoiceId)).thenReturn(Optional.empty());
		when(billingRepository.findInvoicesByBusiness(TOKEN, BUSINESS_ID)).thenReturn(List.of());
		when(billingRepository.findPaymentsByBusiness(TOKEN, BUSINESS_ID)).thenReturn(List.<PaymentRow>of());

		assertThatThrownBy(() -> service.getInvoice(TOKEN, USER_ID, BUSINESS_ID, invoiceId))
				.isInstanceOf(ApiException.class).hasFieldOrPropertyWithValue("code", "INVOICE_NOT_FOUND");
	}

	private static MembershipRow membership(String role) {
		return new MembershipRow(UUID.randomUUID(), BUSINESS_ID, "ACTIVE", new RoleRef(role), null);
	}

	private static SubscriptionRow subscription(String status, BillingCycle cycle, LocalDate endDate, boolean autoRenew) {
		return subscription(UUID.randomUUID(), status, cycle, endDate, autoRenew);
	}

	private static SubscriptionRow subscription(UUID id, String status, LocalDate endDate, boolean autoRenew) {
		return subscription(id, status, BillingCycle.MONTHLY, endDate, autoRenew);
	}

	private static SubscriptionRow subscription(UUID id, String status, BillingCycle cycle, LocalDate endDate, boolean autoRenew) {
		return new SubscriptionRow(id, PLAN_ID, cycle, status, LocalDate.of(2026, 10, 1), endDate, autoRenew,
				null, null, new PlanRef("Nâng cao"));
	}
}
