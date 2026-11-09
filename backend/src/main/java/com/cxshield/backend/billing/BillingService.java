package com.cxshield.backend.billing;

import java.time.Clock;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository;
import com.cxshield.backend.billing.BillingRepository.BillingProfileRow;
import com.cxshield.backend.billing.BillingRepository.PaymentRow;
import com.cxshield.backend.billing.BillingRepository.PlanRow;
import com.cxshield.backend.billing.BillingRepository.SubscriptionRow;
import com.cxshield.backend.billing.dto.BillingDtos.BillingProfileDto;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutRequest;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PaymentStatusResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PlanResponse;
import com.cxshield.backend.billing.dto.BillingDtos.SubscriptionResponse;
import com.cxshield.backend.common.ApiException;

/**
 * Bảng giá (E8.1 · D5-10) và tạo lệnh thanh toán (E8.2 · D5-11).
 * Số tiền luôn tính ở backend từ bảng plans, không nhận từ giao diện.
 */
@Service
public class BillingService {

	static final int VAT_PERCENT = 10;

	private static final String OWNER = "OWNER";
	private static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");
	private static final DateTimeFormatter CODE_TIME = DateTimeFormatter.ofPattern("yyMMddHHmmss").withZone(VIETNAM);
	private static final Pattern TAX_CODE = Pattern.compile("^\\d{10}(-?\\d{3})?$");
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

	private final AccountRepository accountRepository;
	private final BillingRepository billingRepository;
	private final PaymentAdminRepository paymentRepository;
	private final VnpayGateway vnpay;
	private final InvoiceExportService invoiceExportService;
	private final Clock clock;

	@Autowired
	public BillingService(AccountRepository accountRepository, BillingRepository billingRepository,
			PaymentAdminRepository paymentRepository, VnpayGateway vnpay, InvoiceExportService invoiceExportService) {
		this(accountRepository, billingRepository, paymentRepository, vnpay, invoiceExportService, Clock.systemUTC());
	}

	BillingService(AccountRepository accountRepository, BillingRepository billingRepository,
			PaymentAdminRepository paymentRepository, VnpayGateway vnpay, InvoiceExportService invoiceExportService, Clock clock) {
		this.accountRepository = accountRepository;
		this.billingRepository = billingRepository;
		this.paymentRepository = paymentRepository;
		this.vnpay = vnpay;
		this.invoiceExportService = invoiceExportService;
		this.clock = clock;
	}

	BillingService(AccountRepository accountRepository, BillingRepository billingRepository,
			PaymentAdminRepository paymentRepository, VnpayGateway vnpay, Clock clock) {
		this(accountRepository, billingRepository, paymentRepository, vnpay, new InvoiceExportService(), clock);
	}

	public List<PlanResponse> getPlans(String token) {
		return billingRepository.findActivePlans(token).stream().map(BillingService::toPlanResponse).toList();
	}

	public SubscriptionResponse getSubscription(String token, UUID userId, UUID businessId) {
		requireOwner(token, userId, businessId);
		return billingRepository.findCurrentSubscription(token, businessId)
			.map(row -> toSubscriptionResponse(row))
			.orElseGet(() -> new SubscriptionResponse(null, null, null, null, null, null));
	}

	public SubscriptionResponse updateAutoRenew(String token, UUID userId, UUID businessId, boolean autoRenew) {
		requireOwner(token, userId, businessId);
		SubscriptionRow current = billingRepository.findCurrentSubscription(token, businessId)
				.orElseThrow(() -> ApiException.notFound("SUBSCRIPTION_NOT_FOUND", "Không tìm thấy thuê bao của cơ sở."));

		SubscriptionRow updated = billingRepository.updateSubscriptionAutoRenew(token, current.id(), autoRenew)
				.orElse(new SubscriptionRow(current.id(), current.planId(), current.billingCycle(), current.status(),
						current.startDate(), current.endDate(), autoRenew, current.trialEndDate(), current.graceUntil(), current.plans()));

		return toSubscriptionResponse(updated);
	}

	public List<com.cxshield.backend.billing.dto.BillingDtos.PaymentHistoryResponse> getPaymentHistory(
			String token, UUID userId, UUID businessId) {
		requireOwner(token, userId, businessId);
		List<PaymentRow> payments = billingRepository.findPaymentsByBusiness(token, businessId);
		List<com.cxshield.backend.billing.BillingRepository.InvoiceRow> invoices = billingRepository.findInvoicesByBusiness(token, businessId);
		Map<UUID, com.cxshield.backend.billing.BillingRepository.InvoiceRow> invoiceMap = invoices.stream()
				.collect(java.util.stream.Collectors.toMap(com.cxshield.backend.billing.BillingRepository.InvoiceRow::paymentId, inv -> inv, (a, b) -> a));

		return payments.stream().map(p -> {
			com.cxshield.backend.billing.BillingRepository.InvoiceRow inv = invoiceMap.get(p.id());
			return new com.cxshield.backend.billing.dto.BillingDtos.PaymentHistoryResponse(
					p.id(),
					p.businessId(),
					p.planId(),
					p.planName() != null ? p.planName() : "Gói dịch vụ CX-SHIELD",
					p.billingCycle(),
					p.transactionCode(),
					p.amount(),
					p.status(),
					p.method() != null ? p.method() : "VNPAY",
					p.gatewayResponseCode(),
					p.paidAt(),
					p.createdAt() != null ? p.createdAt() : (p.paidAt() != null ? p.paidAt() : java.time.OffsetDateTime.now()),
					inv != null ? inv.id() : null,
					inv != null ? inv.invoiceNumber() : ("SUCCESS".equals(p.status()) ? "HD-" + p.transactionCode() : null)
			);
		}).toList();
	}

	public List<com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse> getInvoices(
			String token, UUID userId, UUID businessId) {
		requireOwner(token, userId, businessId);
		List<com.cxshield.backend.billing.BillingRepository.InvoiceRow> dbInvoices = billingRepository.findInvoicesByBusiness(token, businessId);
		if (!dbInvoices.isEmpty()) {
			return dbInvoices.stream().map(this::toInvoiceResponse).toList();
		}

		// Tạo danh sách hoá đơn tổng hợp từ các payment SUCCESS
		List<PaymentRow> payments = billingRepository.findPaymentsByBusiness(token, businessId);
		BillingProfileDto profile = getBillingProfile(token, userId, businessId);

		return payments.stream()
				.filter(p -> "SUCCESS".equalsIgnoreCase(p.status()))
				.map(p -> synthesizeInvoice(businessId, p, profile))
				.toList();
	}

	public com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse getInvoice(
			String token, UUID userId, UUID businessId, UUID invoiceId) {
		requireOwner(token, userId, businessId);
		return billingRepository.findInvoiceById(token, invoiceId)
				.map(this::toInvoiceResponse)
				.orElseGet(() -> getInvoices(token, userId, businessId).stream()
						.filter(inv -> invoiceId.equals(inv.id()))
						.findFirst()
						.orElseThrow(() -> ApiException.notFound("INVOICE_NOT_FOUND", "Không tìm thấy hóa đơn.")));
	}

	public byte[] exportInvoicePdf(String token, UUID userId, UUID businessId, UUID invoiceId) throws java.io.IOException {
		com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse invoice = getInvoice(token, userId, businessId, invoiceId);
		return invoiceExportService.exportPdf(invoice);
	}

	public byte[] exportInvoiceXml(String token, UUID userId, UUID businessId, UUID invoiceId) {
		com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse invoice = getInvoice(token, userId, businessId, invoiceId);
		return invoiceExportService.exportXml(invoice);
	}

	public BillingProfileDto getBillingProfile(String token, UUID userId, UUID businessId) {
		requireOwner(token, userId, businessId);
		return billingRepository.findBillingProfile(token, businessId)
			.map(row -> new BillingProfileDto(row.taxCode(), row.companyName(), row.companyAddress(), row.billingEmail(),
					row.buyerName()))
			.orElseGet(() -> new BillingProfileDto(null, null, null, null, null));
	}

	public CheckoutResponse createCheckout(String token, UUID userId, UUID businessId, CheckoutRequest request, String clientIp) {
		requireOwner(token, userId, businessId);
		if (!vnpay.isEnabled() || !paymentRepository.isEnabled()) {
			throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE, "PAYMENT_NOT_CONFIGURED",
					"Hệ thống chưa cấu hình cổng thanh toán, vui lòng thử lại sau.");
		}
		PlanRow plan = billingRepository.findPlan(token, request.planId())
			.orElseThrow(() -> ApiException.notFound("PLAN_NOT_FOUND", "Không tìm thấy gói dịch vụ."));
		Long price = plan.priceFor(request.billingCycle());
		if (price == null) {
			throw ApiException.unprocessable("CYCLE_NOT_AVAILABLE", "Gói này không có chu kỳ thanh toán đã chọn.");
		}
		if (request.billingProfile() != null) {
			saveBillingProfile(token, businessId, request.billingProfile());
		}

		long vat = price * VAT_PERCENT / 100;
		long total = price + vat;
		String code = newTransactionCode();
		Map<String, Object> payment = new LinkedHashMap<>();
		payment.put("business_id", businessId);
		payment.put("plan_id", plan.id());
		payment.put("billing_cycle", request.billingCycle().name());
		payment.put("transaction_code", code);
		payment.put("description", "Thanh toán gói " + plan.name());
		payment.put("amount", total);
		payment.put("currency", "VND");
		payment.put("method", "VNPAY");
		paymentRepository.insertPayment(payment);

		String paymentUrl = vnpay.buildPaymentUrl(code, total, "Thanh toan goi dich vu " + code, clientIp);
		return new CheckoutResponse(code, price, vat, total, paymentUrl);
	}

	public PaymentStatusResponse getPayment(String token, UUID userId, UUID businessId, String transactionCode) {
		requireOwner(token, userId, businessId);
		PaymentRow payment = billingRepository.findPayment(token, businessId, transactionCode)
			.orElseThrow(() -> ApiException.notFound("PAYMENT_NOT_FOUND", "Không tìm thấy giao dịch."));
		return new PaymentStatusResponse(payment.transactionCode(), payment.status(), payment.amount(), payment.billingCycle(),
				payment.paidAt(), messageFor(payment));
	}

	static String messageFor(PaymentRow payment) {
		return switch (payment.status()) {
			case "SUCCESS" -> "Thanh toán thành công, gói dịch vụ đã được kích hoạt.";
			case "PENDING" -> "Giao dịch đang chờ xác nhận từ cổng thanh toán.";
			default -> "24".equals(payment.gatewayResponseCode()) ? "Bạn đã huỷ giao dịch, gói dịch vụ chưa được kích hoạt."
					: "Thanh toán không thành công, gói dịch vụ chưa được kích hoạt.";
		};
	}

	private void saveBillingProfile(String token, UUID businessId, BillingProfileDto profile) {
		String taxCode = trimmed(profile.taxCode());
		String companyName = trimmed(profile.companyName());
		String email = trimmed(profile.billingEmail());
		if (taxCode == null || !TAX_CODE.matcher(taxCode).matches()) {
			throw ApiException.unprocessable("INVALID_TAX_CODE", "Mã số thuế gồm 10 hoặc 13 chữ số.");
		}
		if (companyName == null) {
			throw ApiException.unprocessable("INVALID_COMPANY_NAME", "Vui lòng nhập tên công ty.");
		}
		if (email == null || !EMAIL.matcher(email).matches()) {
			throw ApiException.unprocessable("INVALID_BILLING_EMAIL", "Email nhận hoá đơn không đúng định dạng.");
		}
		Map<String, Object> values = new LinkedHashMap<>();
		values.put("tax_code", taxCode);
		values.put("company_name", companyName);
		values.put("company_address", trimmed(profile.companyAddress()));
		values.put("billing_email", email);
		values.put("buyer_name", trimmed(profile.buyerName()));

		Optional<BillingProfileRow> existing = billingRepository.findBillingProfile(token, businessId);
		if (existing.isPresent()) {
			billingRepository.updateBillingProfile(token, existing.get().id(), values);
		}
		else {
			values.put("business_id", businessId);
			billingRepository.insertBillingProfile(token, values);
		}
	}

	private void requireOwner(String token, UUID userId, UUID businessId) {
		boolean owner = accountRepository.findActiveMemberships(token, userId)
			.stream()
			.anyMatch(membership -> businessId.equals(membership.businessId()) && OWNER.equals(membership.roleName()));
		if (!owner) {
			throw ApiException.forbidden("Chỉ Chủ cơ sở được quản lý gói dịch vụ và thanh toán.");
		}
	}

	/** Mã chỉ gồm chữ và số vì VNPAY dùng làm vnp_TxnRef. */
	private String newTransactionCode() {
		byte[] random = new byte[3];
		ThreadLocalRandom.current().nextBytes(random);
		return "CX" + CODE_TIME.format(clock.instant()) + HexFormat.of().withUpperCase().formatHex(random);
	}

	private static String trimmed(String value) {
		return value == null || value.isBlank() ? null : value.trim();
	}

	private static PlanResponse toPlanResponse(PlanRow row) {
		return new PlanResponse(row.id(), row.name(), row.monthlyPrice(), row.yearlyPrice(), row.lifetimePrice(), row.maxBranches(),
				row.maxQrCodes(), row.features(), row.includedPrintItems());
	}

	private SubscriptionResponse toSubscriptionResponse(SubscriptionRow row) {
		java.time.LocalDate today = java.time.LocalDate.now(clock.withZone(VIETNAM));
		Integer daysRemaining = null;
		boolean isExpiringSoon = false;
		boolean isOverdue = "OVERDUE".equalsIgnoreCase(row.status());

		if (row.billingCycle() != BillingCycle.LIFETIME && row.endDate() != null) {
			long diff = java.time.temporal.ChronoUnit.DAYS.between(today, row.endDate());
			daysRemaining = (int) diff;
			if (diff >= 0 && diff <= 7) {
				isExpiringSoon = true;
			} else if (diff < 0) {
				isOverdue = true;
			}
		}

		return new SubscriptionResponse(
				row.planId(),
				row.planName(),
				row.billingCycle(),
				row.status(),
				row.startDate(),
				row.endDate(),
				row.isAutoRenew(),
				daysRemaining,
				row.trialEndDate(),
				row.graceUntil(),
				isExpiringSoon,
				isOverdue
		);
	}

	private com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse toInvoiceResponse(
			com.cxshield.backend.billing.BillingRepository.InvoiceRow row) {
		String pdfUrl = "/api/v1/businesses/" + row.businessId() + "/invoices/" + row.id() + "/pdf";
		String xmlUrl = "/api/v1/businesses/" + row.businessId() + "/invoices/" + row.id() + "/xml";

		return new com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse(
				row.id(),
				row.businessId(),
				row.paymentId(),
				row.invoiceNumber(),
				row.invoiceNumber(),
				row.companyName(),
				row.companyAddress(),
				row.taxCode(),
				row.buyerName(),
				row.billingEmail(),
				row.subtotal(),
				row.vatRate(),
				row.vatAmount(),
				row.totalAmount(),
				row.issuedAt(),
				pdfUrl,
				xmlUrl
		);
	}

	private com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse synthesizeInvoice(
			UUID businessId, PaymentRow payment, BillingProfileDto profile) {
		long total = payment.amount();
		long subtotal = Math.round(total / 1.10);
		long vat = total - subtotal;
		String invNum = "HD-" + payment.transactionCode();
		java.time.OffsetDateTime issuedAt = payment.paidAt() != null ? payment.paidAt() : java.time.OffsetDateTime.now(clock);
		String pdfUrl = "/api/v1/businesses/" + businessId + "/invoices/" + payment.id() + "/pdf";
		String xmlUrl = "/api/v1/businesses/" + businessId + "/invoices/" + payment.id() + "/xml";

		return new com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse(
				payment.id(),
				businessId,
				payment.id(),
				payment.transactionCode(),
				invNum,
				profile != null ? profile.companyName() : "Khách hàng doanh nghiệp",
				profile != null ? profile.companyAddress() : "Việt Nam",
				profile != null ? profile.taxCode() : "",
				profile != null ? profile.buyerName() : "Chủ cơ sở",
				profile != null ? profile.billingEmail() : "billing@cxshield.vn",
				subtotal,
				10.0,
				vat,
				total,
				issuedAt,
				pdfUrl,
				xmlUrl
		);
	}

}
