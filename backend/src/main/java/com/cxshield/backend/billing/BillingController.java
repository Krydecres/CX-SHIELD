package com.cxshield.backend.billing;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.cxshield.backend.billing.dto.BillingDtos.AutoRenewRequest;
import com.cxshield.backend.billing.dto.BillingDtos.BillingProfileDto;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutRequest;
import com.cxshield.backend.billing.dto.BillingDtos.CheckoutResponse;
import com.cxshield.backend.billing.dto.BillingDtos.InvoiceResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PaymentHistoryResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PaymentStatusResponse;
import com.cxshield.backend.billing.dto.BillingDtos.PlanResponse;
import com.cxshield.backend.billing.dto.BillingDtos.SubscriptionResponse;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1")
public class BillingController {

	private final BillingService billingService;

	public BillingController(BillingService billingService) {
		this.billingService = billingService;
	}

	@GetMapping("/plans")
	public List<PlanResponse> plans(@AuthenticationPrincipal Jwt jwt) {
		return billingService.getPlans(jwt.getTokenValue());
	}

	@GetMapping("/businesses/{businessId}/subscription")
	public SubscriptionResponse subscription(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId) {
		return billingService.getSubscription(jwt.getTokenValue(), userId(jwt), businessId);
	}

	@GetMapping("/businesses/{businessId}/billing-profile")
	public BillingProfileDto billingProfile(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId) {
		return billingService.getBillingProfile(jwt.getTokenValue(), userId(jwt), businessId);
	}

	@PostMapping("/businesses/{businessId}/checkouts")
	@ResponseStatus(HttpStatus.CREATED)
	public CheckoutResponse checkout(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@Valid @RequestBody CheckoutRequest request, HttpServletRequest servletRequest) {
		return billingService.createCheckout(jwt.getTokenValue(), userId(jwt), businessId, request,
				servletRequest.getRemoteAddr());
	}

	@GetMapping("/businesses/{businessId}/payments/{transactionCode}")
	public PaymentStatusResponse payment(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@PathVariable String transactionCode) {
		return billingService.getPayment(jwt.getTokenValue(), userId(jwt), businessId, transactionCode);
	}

	@PutMapping("/businesses/{businessId}/subscription/auto-renew")
	public SubscriptionResponse updateAutoRenew(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@Valid @RequestBody AutoRenewRequest request) {
		return billingService.updateAutoRenew(jwt.getTokenValue(), userId(jwt), businessId, request.autoRenew());
	}

	@GetMapping("/businesses/{businessId}/payments")
	public List<PaymentHistoryResponse> paymentHistory(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId) {
		return billingService.getPaymentHistory(jwt.getTokenValue(), userId(jwt), businessId);
	}

	@GetMapping("/businesses/{businessId}/invoices")
	public List<InvoiceResponse> invoices(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId) {
		return billingService.getInvoices(jwt.getTokenValue(), userId(jwt), businessId);
	}

	@GetMapping("/businesses/{businessId}/invoices/{invoiceId}")
	public InvoiceResponse invoice(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@PathVariable UUID invoiceId) {
		return billingService.getInvoice(jwt.getTokenValue(), userId(jwt), businessId, invoiceId);
	}

	@GetMapping("/businesses/{businessId}/invoices/{invoiceId}/pdf")
	public ResponseEntity<byte[]> exportInvoicePdf(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@PathVariable UUID invoiceId) throws java.io.IOException {
		byte[] pdfBytes = billingService.exportInvoicePdf(jwt.getTokenValue(), userId(jwt), businessId, invoiceId);
		return ResponseEntity.ok()
				.contentType(MediaType.APPLICATION_PDF)
				.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"hoa-don-vat-" + invoiceId + ".pdf\"")
				.body(pdfBytes);
	}

	@GetMapping("/businesses/{businessId}/invoices/{invoiceId}/xml")
	public ResponseEntity<byte[]> exportInvoiceXml(@AuthenticationPrincipal Jwt jwt, @PathVariable UUID businessId,
			@PathVariable UUID invoiceId) {
		byte[] xmlBytes = billingService.exportInvoiceXml(jwt.getTokenValue(), userId(jwt), businessId, invoiceId);
		return ResponseEntity.ok()
				.contentType(MediaType.APPLICATION_XML)
				.header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"hoa-don-vat-" + invoiceId + ".xml\"")
				.body(xmlBytes);
	}

	private static UUID userId(Jwt jwt) {
		return UUID.fromString(jwt.getSubject());
	}

}
