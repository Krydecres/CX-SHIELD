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
    private java.util.List<UUID> topicIds = new java.util.ArrayList<>();
    private java.util.List<String> topicNames = new java.util.ArrayList<>();

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
    public java.util.List<UUID> getTopicIds() { return topicIds; }
    public void setTopicIds(java.util.List<UUID> topicIds) { this.topicIds = topicIds != null ? topicIds : new java.util.ArrayList<>(); }
    public java.util.List<String> getTopicNames() { return topicNames; }
    public void setTopicNames(java.util.List<String> topicNames) { this.topicNames = topicNames != null ? topicNames : new java.util.ArrayList<>(); }
}

