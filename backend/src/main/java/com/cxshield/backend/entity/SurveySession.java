package com.cxshield.backend.entity;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class SurveySession {
    private UUID id;
    private UUID qrCodeId;
    private UUID branchId;
    private UUID customerId;
    private UUID posTransactionId;
    private String tableOrAreaCode;
    private String clientIp;
    private String userAgent;
    private BigDecimal recaptchaScore;
    private String status; // STARTED, COMPLETED, EXPIRED, CANCELLED
    private Instant startedAt;
    private Instant completedAt;
    private Instant createdAt;
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

