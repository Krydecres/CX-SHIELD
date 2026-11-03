package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class FeedbackTopic {
    private UUID id;
    private UUID businessId;
    private String name;
    private boolean isActive;
    private Instant createdAt;
    private Instant updatedAt;

    public FeedbackTopic() {
        this.id = UUID.randomUUID();
        this.isActive = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public FeedbackTopic(UUID id, UUID businessId, String name, boolean isActive) {
        this.id = id;
        this.businessId = businessId;
        this.name = name;
        this.isActive = isActive;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

