package com.cxshield.backend.billing.dto;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import com.cxshield.backend.billing.BillingCycle;
import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public final class BillingDtos {

	private BillingDtos() {
	}

	public record PlanResponse(UUID id, String name, Long monthlyPrice, Long yearlyPrice, Long lifetimePrice, Integer maxBranches,
			Integer maxQrCodes, List<String> features, String includedPrintItems) {
	}

	/**
	 * status null nghĩa là cơ sở chưa có gói nào.
	 * Bổ sung autoRenew, daysRemaining, trialEndDate, graceUntil, isExpiringSoon, isOverdue cho E8.3.
	 */
	public record SubscriptionResponse(UUID planId, String planName, BillingCycle billingCycle, String status,
			LocalDate startDate, LocalDate endDate, Boolean autoRenew, Integer daysRemaining,
			LocalDate trialEndDate, LocalDate graceUntil, Boolean isExpiringSoon, Boolean isOverdue) {

		public SubscriptionResponse(UUID planId, String planName, BillingCycle billingCycle, String status,
				LocalDate startDate, LocalDate endDate) {
			this(planId, planName, billingCycle, status, startDate, endDate, true, null, null, null, false, false);
		}
	}

	public record AutoRenewRequest(@NotNull Boolean autoRenew) {
	}

	public record PaymentHistoryResponse(UUID id, UUID businessId, UUID planId, String planName,
			BillingCycle billingCycle, String transactionCode, long amount, String status,
			String method, String gatewayResponseCode, OffsetDateTime paidAt, OffsetDateTime createdAt,
			UUID invoiceId, String invoiceNumber) {

		public boolean hasInvoice() {
			return invoiceId != null || invoiceNumber != null;
		}
	}

	public record InvoiceResponse(UUID id, UUID businessId, UUID paymentId, String transactionCode,
			String invoiceNumber, String companyName, String companyAddress, String taxCode,
			String buyerName, String billingEmail, long subtotal, double vatRate, long vatAmount,
			long totalAmount, OffsetDateTime issuedAt, String pdfUrl, String xmlUrl) {
	}

	public record BillingProfileDto(@Size(max = 20) String taxCode, @Size(max = 200) String companyName,
			@Size(max = 300) String companyAddress, @Size(max = 254) String billingEmail, @Size(max = 100) String buyerName) {
	}

	/**
	 * billingProfile null nghĩa là khách không cần xuất hoá đơn.
	 */
	public record CheckoutRequest(@NotNull UUID planId, @NotNull BillingCycle billingCycle, @Valid BillingProfileDto billingProfile) {
	}

	public record CheckoutResponse(String transactionCode, long subtotal, long vatAmount, long totalAmount, String paymentUrl) {
	}

	public record PaymentStatusResponse(String transactionCode, String status, long amount, BillingCycle billingCycle,
			OffsetDateTime paidAt, String message) {
	}

	/**
	 * Mẫu phản hồi IPN do VNPAY quy định, tên trường viết hoa chữ đầu.
	 */
	public record VnpayIpnResponse(@JsonProperty("RspCode") String rspCode, @JsonProperty("Message") String message) {
	}

}
