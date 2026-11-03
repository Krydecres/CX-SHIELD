package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class Branch {
    private UUID id;
    private UUID businessId;
    private String code;
    private String name;
    private String address;
    private String hotline;
    private UUID managerMembershipId;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;

    public Branch() {
        this.id = UUID.randomUUID();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public Branch(UUID id, UUID businessId, String code, String name, String address, String hotline, String status) {
        this.id = id;
        this.businessId = businessId;
        this.code = code;
        this.name = name;
        this.address = address;
        this.hotline = hotline;
        this.status = status;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getHotline() { return hotline; }
    public void setHotline(String hotline) { this.hotline = hotline; }
    public UUID getManagerMembershipId() { return managerMembershipId; }
    public void setManagerMembershipId(UUID managerMembershipId) { this.managerMembershipId = managerMembershipId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

