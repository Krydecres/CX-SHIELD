package com.cxshield.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class Feedback {
    @JsonProperty("id")
    private UUID id;

    @JsonProperty("business_id")
    private UUID businessId;

    @JsonProperty("branch_id")
    private UUID branchId;

    @JsonProperty("response_id")
    private UUID responseId;

    @JsonProperty("customer_id")
    private UUID customerId;

    @JsonProperty("comment_text")
    private String commentText;

    @JsonProperty("customer_phone")
    private String customerPhone;

    @JsonProperty("contact_purpose")
    private String contactPurpose;

    @JsonProperty("consent_at")
    private Instant consentAt;

    @JsonProperty("voice_record_url")
    private String voiceRecordUrl;

    @JsonProperty("voice_duration_seconds")
    private Integer voiceDurationSeconds;

    @JsonProperty("transcript_text")
    private String transcriptText;

    @JsonProperty("stt_status")
    private String sttStatus; // PENDING, PROCESSING, COMPLETED, FAILED

    @JsonProperty("is_urgent_callback")
    private boolean isUrgentCallback;

    @JsonProperty("urgency_level")
    private int urgencyLevel; // 1 (bình thường), 2 (cao), 3 (khẩn cấp)

    @JsonProperty("status")
    private String status;    // NEW, IN_PROGRESS, RESOLVED, CLOSED_WITH_NOTE

    @JsonProperty("submitted_at")
    private Instant submittedAt;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    public Feedback() {
        this.id = UUID.randomUUID();
        this.status = "NEW";
        this.sttStatus = "PENDING";
        this.urgencyLevel = 1;
        this.submittedAt = Instant.now();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public UUID getBranchId() { return branchId; }
    public void setBranchId(UUID branchId) { this.branchId = branchId; }
    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
    public UUID getCustomerId() { return customerId; }
    public void setCustomerId(UUID customerId) { this.customerId = customerId; }
    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public String getContactPurpose() { return contactPurpose; }
    public void setContactPurpose(String contactPurpose) { this.contactPurpose = contactPurpose; }
    public Instant getConsentAt() { return consentAt; }
    public void setConsentAt(Instant consentAt) { this.consentAt = consentAt; }
    public String getVoiceRecordUrl() { return voiceRecordUrl; }
    public void setVoiceRecordUrl(String voiceRecordUrl) { this.voiceRecordUrl = voiceRecordUrl; }
    public Integer getVoiceDurationSeconds() { return voiceDurationSeconds; }
    public void setVoiceDurationSeconds(Integer voiceDurationSeconds) { this.voiceDurationSeconds = voiceDurationSeconds; }
    public String getTranscriptText() { return transcriptText; }
    public void setTranscriptText(String transcriptText) { this.transcriptText = transcriptText; }
    public String getSttStatus() { return sttStatus; }
    public void setSttStatus(String sttStatus) { this.sttStatus = sttStatus; }
    public boolean isUrgentCallback() { return isUrgentCallback; }
    public void setUrgentCallback(boolean urgentCallback) { isUrgentCallback = urgentCallback; }
    public int getUrgencyLevel() { return urgencyLevel; }
    public void setUrgencyLevel(int urgencyLevel) { this.urgencyLevel = urgencyLevel; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Instant submittedAt) { this.submittedAt = submittedAt; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
