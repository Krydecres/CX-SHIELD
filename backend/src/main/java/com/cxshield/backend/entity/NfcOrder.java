package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class NfcOrder {
    private UUID id;
    private UUID businessId;
    private UUID designId;
    private String material; // WOOD (Gỗ Walnut), MICA (Mica trong suốt)
    private int quantity;
    private String shipName;
    private String shipPhone;
    private String shipAddress;
    private long unitPrice; // VND
    private long totalAmount; // VND
    private NfcOrderStatus status;
    private Instant createdAt;
    private Instant updatedAt;

    public NfcOrder() {
        this.id = UUID.randomUUID();
        this.status = NfcOrderStatus.PENDING;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public NfcOrder(UUID id, UUID businessId, UUID designId, String material,
                    int quantity, String shipName, String shipPhone, String shipAddress,
                    long unitPrice, long totalAmount, NfcOrderStatus status) {
        this.id = id != null ? id : UUID.randomUUID();
        this.businessId = businessId;
        this.designId = designId;
        this.material = material;
        this.quantity = quantity;
        this.shipName = shipName;
        this.shipPhone = shipPhone;
        this.shipAddress = shipAddress;
        this.unitPrice = unitPrice;
        this.totalAmount = totalAmount;
        this.status = status != null ? status : NfcOrderStatus.PENDING;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }

    public UUID getDesignId() { return designId; }
    public void setDesignId(UUID designId) { this.designId = designId; }

    public String getMaterial() { return material; }
    public void setMaterial(String material) { this.material = material; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public String getShipName() { return shipName; }
    public void setShipName(String shipName) { this.shipName = shipName; }

    public String getShipPhone() { return shipPhone; }
    public void setShipPhone(String shipPhone) { this.shipPhone = shipPhone; }

    public String getShipAddress() { return shipAddress; }
    public void setShipAddress(String shipAddress) { this.shipAddress = shipAddress; }

    public long getUnitPrice() { return unitPrice; }
    public void setUnitPrice(long unitPrice) { this.unitPrice = unitPrice; }

    public long getTotalAmount() { return totalAmount; }
    public void setTotalAmount(long totalAmount) { this.totalAmount = totalAmount; }

    public NfcOrderStatus getStatus() { return status; }
    public void setStatus(NfcOrderStatus status) { this.status = status; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

