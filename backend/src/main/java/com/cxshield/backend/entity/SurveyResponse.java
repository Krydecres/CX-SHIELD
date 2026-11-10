package com.cxshield.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SurveyResponse {
    @JsonProperty("id")
    private UUID id;

    @JsonProperty("business_id")
    private UUID businessId;

    @JsonProperty("session_id")
    private UUID sessionId;

    @JsonProperty("star_rating")
    private int starRating; // 1 - 5

    @JsonProperty("sentiment_group")
    private String sentimentGroup; // SATISFIED (4-5), UNSATISFIED (1-3)

    @JsonProperty("selected_keyword_ids")
    private List<UUID> selectedKeywordIds;

    @JsonProperty("copied_prompt_text")
    private String copiedPromptText;

    @JsonProperty("is_public_bypass")
    private boolean isPublicBypass;

    @JsonProperty("review_platform_id")
    private UUID reviewPlatformId;

    @JsonProperty("redirect_clicked_at")
    private Instant redirectClickedAt;

    @JsonProperty("rated_at")
    private Instant ratedAt;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
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
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
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
