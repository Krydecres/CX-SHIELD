package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class SurveyResponse {
    private UUID id;
    private UUID sessionId;
    private int starRating; // 1 - 5
    private String sentimentGroup; // POSITIVE (4-5), NEGATIVE (1-3)
    private List<UUID> selectedKeywordIds;
    private String copiedPromptText;
    private boolean isPublicBypass;
    private UUID reviewPlatformId;
    private Instant redirectClickedAt;
    private Instant ratedAt;
    private Instant createdAt;
    private Instant updatedAt;

    public SurveyResponse() {
        this.id = UUID.randomUUID();
        this.ratedAt = Instant.now();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
        this.isPublicBypass = false;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getSessionId() { return sessionId; }
    public void setSessionId(UUID sessionId) { this.sessionId = sessionId; }
    public int getStarRating() { return starRating; }
    public void setStarRating(int starRating) { this.starRating = starRating; }
    public String getSentimentGroup() { return sentimentGroup; }
    public void setSentimentGroup(String sentimentGroup) { this.sentimentGroup = sentimentGroup; }
    public List<UUID> getSelectedKeywordIds() { return selectedKeywordIds; }
    public void setSelectedKeywordIds(List<UUID> selectedKeywordIds) { this.selectedKeywordIds = selectedKeywordIds; }
    public String getCopiedPromptText() { return copiedPromptText; }
    public void setCopiedPromptText(String copiedPromptText) { this.copiedPromptText = copiedPromptText; }
    public boolean isPublicBypass() { return isPublicBypass; }
    public void setPublicBypass(boolean isPublicBypass) { this.isPublicBypass = isPublicBypass; }
    public UUID getReviewPlatformId() { return reviewPlatformId; }
    public void setReviewPlatformId(UUID reviewPlatformId) { this.reviewPlatformId = reviewPlatformId; }
    public Instant getRedirectClickedAt() { return redirectClickedAt; }
    public void setRedirectClickedAt(Instant redirectClickedAt) { this.redirectClickedAt = redirectClickedAt; }
    public Instant getRatedAt() { return ratedAt; }
    public void setRatedAt(Instant ratedAt) { this.ratedAt = ratedAt; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

