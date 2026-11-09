package com.cxshield.backend.entity;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

public class FeedbackTopicLink {
    private UUID id;
    private UUID feedbackId;
    private UUID complaintId;
    private UUID topicId;
    private String source; // CUSTOMER_SELECT, AI_EXTRACTED, MANUAL
    private BigDecimal confidence;
    private boolean editedManually;
    private Instant createdAt;

    public FeedbackTopicLink() {
        this.id = UUID.randomUUID();
        this.source = "CUSTOMER_SELECT";
        this.confidence = BigDecimal.ONE;
        this.editedManually = false;
        this.createdAt = Instant.now();
    }

    public FeedbackTopicLink(UUID id, UUID feedbackId, UUID complaintId, UUID topicId, String source, BigDecimal confidence, boolean editedManually, Instant createdAt) {
        this.id = id;
        this.feedbackId = feedbackId;
        this.complaintId = complaintId;
        this.topicId = topicId;
        this.source = source != null ? source : "CUSTOMER_SELECT";
        this.confidence = confidence != null ? confidence : BigDecimal.ONE;
        this.editedManually = editedManually;
        this.createdAt = createdAt != null ? createdAt : Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getFeedbackId() { return feedbackId; }
    public void setFeedbackId(UUID feedbackId) { this.feedbackId = feedbackId; }
    public UUID getComplaintId() { return complaintId; }
    public void setComplaintId(UUID complaintId) { this.complaintId = complaintId; }
    public UUID getTopicId() { return topicId; }
    public void setTopicId(UUID topicId) { this.topicId = topicId; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public BigDecimal getConfidence() { return confidence; }
    public void setConfidence(BigDecimal confidence) { this.confidence = confidence; }
    public boolean isEditedManually() { return editedManually; }
    public void setEditedManually(boolean editedManually) { this.editedManually = editedManually; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
}

