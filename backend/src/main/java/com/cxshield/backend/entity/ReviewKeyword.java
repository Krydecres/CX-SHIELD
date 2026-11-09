package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

/**
 * Thực thể review_keywords (E4.3 / CLS-01):
 * Danh sách từ khóa gợi ý đánh giá tích cực theo ngành nghề (F&B, Nha khoa, Spa...)
 */
public class ReviewKeyword {
    private UUID id;
    private UUID businessId;
    private String industry;
    private String keyword;
    private boolean active;
    private Instant createdAt;
    private Instant updatedAt;

    public ReviewKeyword() {
        this.id = UUID.randomUUID();
        this.active = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public ReviewKeyword(UUID id, UUID businessId, String industry, String keyword, boolean active) {
        this.id = id != null ? id : UUID.randomUUID();
        this.businessId = businessId;
        this.industry = industry;
        this.keyword = keyword;
        this.active = active;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
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

    public String getIndustry() {
        return industry;
    }

    public void setIndustry(String industry) {
        this.industry = industry;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
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
