package com.cxshield.backend.billing;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.supabase.SupabaseDataClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Đọc gói, thuê bao, hồ sơ hoá đơn và thanh toán bằng token người dùng nên RLS giới hạn theo Chủ cơ sở.
 */
@Repository
public class BillingRepository {

	private static final String PLAN_COLUMNS = "id,name,monthly_price,yearly_price,lifetime_price,max_branches,max_qr_codes,"
			+ "features,included_print_items";
	private static final String PROFILE_COLUMNS = "id,business_id,company_name,company_address,tax_code,billing_email,buyer_name";

	private static final ParameterizedTypeReference<List<PlanRow>> PLAN_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<SubscriptionRow>> SUBSCRIPTION_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<BillingProfileRow>> PROFILE_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<PaymentRow>> PAYMENT_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<InvoiceRow>> INVOICE_ROWS = new ParameterizedTypeReference<>() {
	};

	private static final String INVOICE_COLUMNS = "id,business_id,payment_id,invoice_number,company_name,company_address,"
			+ "tax_code,buyer_name,billing_email,subtotal,vat_rate,vat_amount,total_amount,issued_at,pdf_url,xml_url";

	private final SupabaseDataClient supabase;

	public BillingRepository(SupabaseDataClient supabase) {
		this.supabase = supabase;
	}

	public List<PlanRow> findActivePlans(String token) {
		return supabase.select(token, "plans", Map.of("select", PLAN_COLUMNS, "is_active", "eq.true", "order", "monthly_price.asc"),
				PLAN_ROWS);
	}

	public Optional<PlanRow> findPlan(String token, UUID planId) {
		return supabase
			.select(token, "plans", Map.of("select", PLAN_COLUMNS, "id", "eq." + planId, "is_active", "eq.true"), PLAN_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<SubscriptionRow> findCurrentSubscription(String token, UUID businessId) {
		return supabase
			.select(token, "subscriptions",
					Map.of("select", "id,plan_id,billing_cycle,status,start_date,end_date,auto_renew,trial_end_date,grace_until,plans(name)", "business_id",
							"eq." + businessId, "status", "neq.CANCELLED", "order", "created_at.desc", "limit", "1"),
					SUBSCRIPTION_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<SubscriptionRow> updateSubscriptionAutoRenew(String token, UUID subscriptionId, boolean autoRenew) {
		return supabase
			.update(token, "subscriptions", Map.of("id", "eq." + subscriptionId), Map.of("auto_renew", autoRenew), SUBSCRIPTION_ROWS)
			.stream()
			.findFirst();
	}

	public List<PaymentRow> findPaymentsByBusiness(String token, UUID businessId) {
		return supabase.select(token, "payments",
				Map.of("select", PaymentAdminRepository.PAYMENT_COLUMNS + ",created_at,method", "business_id", "eq." + businessId,
						"order", "created_at.desc"),
				PAYMENT_ROWS);
	}

	public List<InvoiceRow> findInvoicesByBusiness(String token, UUID businessId) {
		return supabase.select(token, "invoices",
				Map.of("select", INVOICE_COLUMNS, "business_id", "eq." + businessId, "order", "issued_at.desc"),
				INVOICE_ROWS);
	}

	public Optional<InvoiceRow> findInvoiceById(String token, UUID invoiceId) {
		return supabase
			.select(token, "invoices", Map.of("select", INVOICE_COLUMNS, "id", "eq." + invoiceId), INVOICE_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<InvoiceRow> findInvoiceByPaymentId(String token, UUID paymentId) {
		return supabase
			.select(token, "invoices", Map.of("select", INVOICE_COLUMNS, "payment_id", "eq." + paymentId), INVOICE_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<InvoiceRow> insertInvoice(String token, Map<String, Object> values) {
		return supabase.insert(token, "invoices", values, INVOICE_ROWS).stream().findFirst();
	}

	public Optional<BillingProfileRow> findBillingProfile(String token, UUID businessId) {
		return supabase
			.select(token, "billing_profiles", Map.of("select", PROFILE_COLUMNS, "business_id", "eq." + businessId), PROFILE_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<BillingProfileRow> insertBillingProfile(String token, Map<String, Object> values) {
		return supabase.insert(token, "billing_profiles", values, PROFILE_ROWS).stream().findFirst();
	}

	public Optional<BillingProfileRow> updateBillingProfile(String token, UUID id, Map<String, Object> values) {
		return supabase.update(token, "billing_profiles", Map.of("id", "eq." + id), values, PROFILE_ROWS).stream().findFirst();
	}

	public Optional<PaymentRow> findPayment(String token, UUID businessId, String transactionCode) {
		return supabase
			.select(token, "payments", Map.of("select", PaymentAdminRepository.PAYMENT_COLUMNS, "business_id", "eq." + businessId,
					"transaction_code", "eq." + transactionCode), PAYMENT_ROWS)
			.stream()
			.findFirst();
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record PlanRow(UUID id, String name, @JsonProperty("monthly_price") Long monthlyPrice,
			@JsonProperty("yearly_price") Long yearlyPrice, @JsonProperty("lifetime_price") Long lifetimePrice,
			@JsonProperty("max_branches") Integer maxBranches, @JsonProperty("max_qr_codes") Integer maxQrCodes,
			List<String> features, @JsonProperty("included_print_items") String includedPrintItems) {

		public Long priceFor(BillingCycle cycle) {
			return switch (cycle) {
				case MONTHLY -> monthlyPrice;
				case YEARLY -> yearlyPrice;
				case LIFETIME -> lifetimePrice;
			};
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record SubscriptionRow(UUID id, @JsonProperty("plan_id") UUID planId,
			@JsonProperty("billing_cycle") BillingCycle billingCycle, String status,
			@JsonProperty("start_date") LocalDate startDate, @JsonProperty("end_date") LocalDate endDate,
			@JsonProperty("auto_renew") Boolean autoRenew,
			@JsonProperty("trial_end_date") LocalDate trialEndDate,
			@JsonProperty("grace_until") LocalDate graceUntil,
			PlanRef plans) {

		public SubscriptionRow(UUID id, UUID planId, BillingCycle billingCycle, String status, LocalDate startDate, LocalDate endDate, PlanRef plans) {
			this(id, planId, billingCycle, status, startDate, endDate, true, null, null, plans);
		}

		public String planName() {
			return plans == null ? null : plans.name();
		}

		public boolean isAutoRenew() {
			return autoRenew == null || autoRenew;
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record PlanRef(String name) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record BillingProfileRow(UUID id, @JsonProperty("business_id") UUID businessId,
			@JsonProperty("company_name") String companyName, @JsonProperty("company_address") String companyAddress,
			@JsonProperty("tax_code") String taxCode, @JsonProperty("billing_email") String billingEmail,
			@JsonProperty("buyer_name") String buyerName) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record PaymentRow(UUID id, @JsonProperty("business_id") UUID businessId, @JsonProperty("plan_id") UUID planId,
			@JsonProperty("billing_cycle") BillingCycle billingCycle, @JsonProperty("transaction_code") String transactionCode,
			long amount, String status, @JsonProperty("gateway_response_code") String gatewayResponseCode,
			@JsonProperty("paid_at") OffsetDateTime paidAt, @JsonProperty("created_at") OffsetDateTime createdAt,
			String method, PlanRef plans) {

		public PaymentRow(UUID id, UUID businessId, UUID planId, BillingCycle billingCycle, String transactionCode,
				long amount, String status, String gatewayResponseCode, OffsetDateTime paidAt) {
			this(id, businessId, planId, billingCycle, transactionCode, amount, status, gatewayResponseCode, paidAt,
					paidAt != null ? paidAt : OffsetDateTime.now(), "VNPAY", null);
		}

		public String planName() {
			return plans == null ? null : plans.name();
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record InvoiceRow(UUID id, @JsonProperty("business_id") UUID businessId,
			@JsonProperty("payment_id") UUID paymentId, @JsonProperty("invoice_number") String invoiceNumber,
			@JsonProperty("company_name") String companyName, @JsonProperty("company_address") String companyAddress,
			@JsonProperty("tax_code") String taxCode, @JsonProperty("buyer_name") String buyerName,
			@JsonProperty("billing_email") String billingEmail, long subtotal,
			@JsonProperty("vat_rate") double vatRate, @JsonProperty("vat_amount") long vatAmount,
			@JsonProperty("total_amount") long totalAmount, @JsonProperty("issued_at") OffsetDateTime issuedAt,
			@JsonProperty("pdf_url") String pdfUrl, @JsonProperty("xml_url") String xmlUrl) {

		public InvoiceRow(UUID id, UUID businessId, UUID paymentId, String invoiceNumber,
				String companyName, String companyAddress, String taxCode, String buyerName,
				String billingEmail, long subtotal, double vatRate, long vatAmount,
				long totalAmount, OffsetDateTime issuedAt) {
			this(id, businessId, paymentId, invoiceNumber, companyName, companyAddress, taxCode, buyerName,
					billingEmail, subtotal, vatRate, vatAmount, totalAmount, issuedAt, null, null);
		}
	}

}
