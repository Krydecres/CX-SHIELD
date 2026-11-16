package com.cxshield.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SurveySession {
    @JsonProperty("id")
    private UUID id;

    @JsonProperty("business_id")
    private UUID businessId;

    @JsonProperty("qr_code_id")
    private UUID qrCodeId;

    @JsonProperty("branch_id")
    private UUID branchId;

    @JsonProperty("customer_id")
    private UUID customerId;

    @JsonProperty("pos_transaction_id")
    private UUID posTransactionId;

    @JsonProperty("table_or_area_code")
    private String tableOrAreaCode;

    @JsonProperty("client_ip")
    private String clientIp;

    @JsonProperty("user_agent")
    private String userAgent;

    @JsonProperty("recaptcha_score")
    private BigDecimal recaptchaScore;

    @JsonProperty("status")
    private String status; // STARTED, COMPLETED, EXPIRED, CANCELLED

    @JsonProperty("started_at")
    private Instant startedAt;

    @JsonProperty("completed_at")
    private Instant completedAt;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    public SurveySession() {
        this.id = UUID.randomUUID();
        this.status = "STARTED";
        this.startedAt = Instant.now();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public UUID getQrCodeId() { return qrCodeId; }
    public void setQrCodeId(UUID qrCodeId) { this.qrCodeId = qrCodeId; }
    public UUID getBranchId() { return branchId; }
    public void setBranchId(UUID branchId) { this.branchId = branchId; }
    public UUID getCustomerId() { return customerId; }
    public void setCustomerId(UUID customerId) { this.customerId = customerId; }
    public UUID getPosTransactionId() { return posTransactionId; }
    public void setPosTransactionId(UUID posTransactionId) { this.posTransactionId = posTransactionId; }
    public String getTableOrAreaCode() { return tableOrAreaCode; }
    public void setTableOrAreaCode(String tableOrAreaCode) { this.tableOrAreaCode = tableOrAreaCode; }
    public String getClientIp() { return clientIp; }
    public void setClientIp(String clientIp) { this.clientIp = clientIp; }
    public String getUserAgent() { return userAgent; }
    public void setUserAgent(String userAgent) { this.userAgent = userAgent; }
    public BigDecimal getRecaptchaScore() { return recaptchaScore; }
    public void setRecaptchaScore(BigDecimal recaptchaScore) { this.recaptchaScore = recaptchaScore; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getStartedAt() { return startedAt; }
    public void setStartedAt(Instant startedAt) { this.startedAt = startedAt; }
    public Instant getCompletedAt() { return completedAt; }
    public void setCompletedAt(Instant completedAt) { this.completedAt = completedAt; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
