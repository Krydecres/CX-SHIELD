package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

/**
 * Thực thể routing_rules (E4.3 / CLS-01):
 * Quy tắc phân luồng cảm xúc theo điểm sao và điều kiện hiển thị lối đi công khai
 */
public class RoutingRule {
    private UUID id;
    private UUID businessId;
    private int satisfiedMinScore;
    private int satisfiedMaxScore;
    private boolean publicReviewEnabled;
    private Instant createdAt;
    private Instant updatedAt;

    public RoutingRule() {
        this.id = UUID.randomUUID();
        this.satisfiedMinScore = 4;
        this.satisfiedMaxScore = 5;
        this.publicReviewEnabled = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public RoutingRule(UUID businessId, int satisfiedMinScore, int satisfiedMaxScore, boolean publicReviewEnabled) {
        this.id = UUID.randomUUID();
        this.businessId = businessId;
        this.satisfiedMinScore = satisfiedMinScore;
        this.satisfiedMaxScore = satisfiedMaxScore;
        this.publicReviewEnabled = publicReviewEnabled;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public RoutingRule(UUID id, UUID businessId, int satisfiedMinScore, int satisfiedMaxScore, boolean publicReviewEnabled) {
        this.id = id != null ? id : UUID.randomUUID();
        this.businessId = businessId;
        this.satisfiedMinScore = satisfiedMinScore;
        this.satisfiedMaxScore = satisfiedMaxScore;
        this.publicReviewEnabled = publicReviewEnabled;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public boolean isSatisfied(int rating) {
        return rating >= satisfiedMinScore && rating <= satisfiedMaxScore;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getBusinessId() {
        return businessId;
    }

    public void setBusinessId(UUID businessId) {
        this.businessId = businessId;
    }

    public int getSatisfiedMinScore() {
        return satisfiedMinScore;
    }

    public void setSatisfiedMinScore(int satisfiedMinScore) {
        this.satisfiedMinScore = satisfiedMinScore;
    }

    public int getSatisfiedMaxScore() {
        return satisfiedMaxScore;
    }

    public void setSatisfiedMaxScore(int satisfiedMaxScore) {
        this.satisfiedMaxScore = satisfiedMaxScore;
    }

    public boolean isPublicReviewEnabled() {
        return publicReviewEnabled;
    }

    public void setPublicReviewEnabled(boolean publicReviewEnabled) {
        this.publicReviewEnabled = publicReviewEnabled;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
