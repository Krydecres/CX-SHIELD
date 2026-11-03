package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class QrCode {
    private UUID id;
    private UUID branchId;
    private String code;
    private String type; // TABLE, AREA, COUNTER, STAFF
    private String name; // Bàn 04, Khu VIP, v.v.
    private UUID shiftId;
    private UUID membershipId;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;

    public QrCode() {
        this.id = UUID.randomUUID();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public QrCode(UUID id, UUID branchId, String code, String type, String name, String status) {
        this.id = id;
        this.branchId = branchId;
        this.code = code;
        this.type = type;
        this.name = name;
        this.status = status;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBranchId() { return branchId; }
    public void setBranchId(UUID branchId) { this.branchId = branchId; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public UUID getShiftId() { return shiftId; }
    public void setShiftId(UUID shiftId) { this.shiftId = shiftId; }
    public UUID getMembershipId() { return membershipId; }
    public void setMembershipId(UUID membershipId) { this.membershipId = membershipId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

