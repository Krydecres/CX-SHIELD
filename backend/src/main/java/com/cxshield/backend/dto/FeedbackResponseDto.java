package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public class FeedbackResponseDto {
    private UUID feedbackId;
    private UUID responseId;
    private String status;
    private String targetScreen; // M1-06 (Màn cảm ơn)
    private String message;
    private Instant submittedAt;

    public FeedbackResponseDto() {}

    public FeedbackResponseDto(UUID feedbackId, UUID responseId, String status, String targetScreen, String message, Instant submittedAt) {
        this.feedbackId = feedbackId;
        this.responseId = responseId;
        this.status = status;
        this.targetScreen = targetScreen;
        this.message = message;
        this.submittedAt = submittedAt;
    }

    public UUID getFeedbackId() { return feedbackId; }
    public void setFeedbackId(UUID feedbackId) { this.feedbackId = feedbackId; }
    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getTargetScreen() { return targetScreen; }
    public void setTargetScreen(String targetScreen) { this.targetScreen = targetScreen; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public Instant getSubmittedAt() { return submittedAt; }
    public void setSubmittedAt(Instant submittedAt) { this.submittedAt = submittedAt; }
}

