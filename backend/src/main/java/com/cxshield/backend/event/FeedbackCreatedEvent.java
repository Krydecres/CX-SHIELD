package com.cxshield.backend.event;

import java.time.Instant;
import java.util.UUID;

public class FeedbackCreatedEvent {
    private final UUID feedbackId;
    private final UUID responseId;
    private final UUID branchId;
    private final int starRating;
    private final boolean isUrgentCallback;
    private final boolean hasPhone;
    private final Instant createdAt;

    public FeedbackCreatedEvent(UUID feedbackId, UUID responseId, UUID branchId, int starRating, boolean isUrgentCallback, boolean hasPhone) {
        this.feedbackId = feedbackId;
        this.responseId = responseId;
        this.branchId = branchId;
        this.starRating = starRating;
        this.isUrgentCallback = isUrgentCallback;
        this.hasPhone = hasPhone;
        this.createdAt = Instant.now();
    }

    public UUID getFeedbackId() { return feedbackId; }
    public UUID getResponseId() { return responseId; }
    public UUID getBranchId() { return branchId; }
    public int getStarRating() { return starRating; }
    public boolean isUrgentCallback() { return isUrgentCallback; }
    public boolean isHasPhone() { return hasPhone; }
    public Instant getCreatedAt() { return createdAt; }
}

