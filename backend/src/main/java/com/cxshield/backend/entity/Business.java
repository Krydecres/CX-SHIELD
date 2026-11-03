package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class Business {
    private UUID id;
    private String brandName;
    private String displayName;
    private String industry;
    private String phone;
    private String logoUrl;
    private String primaryColor;
    private String taxCode;
    private String publicSlug;
    private String status;
    private Instant createdAt;
    private Instant updatedAt;

    public Business() {
        this.id = UUID.randomUUID();
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public Business(UUID id, String brandName, String displayName, String industry, String phone, String logoUrl, String primaryColor, String taxCode, String publicSlug, String status) {
        this.id = id;
        this.brandName = brandName;
        this.displayName = displayName;
        this.industry = industry;
        this.phone = phone;
        this.logoUrl = logoUrl;
        this.primaryColor = primaryColor;
        this.taxCode = taxCode;
        this.publicSlug = publicSlug;
        this.status = status;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }
    public String getDisplayName() { return displayName; }
    public void setDisplayName(String displayName) { this.displayName = displayName; }
    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
    public String getPrimaryColor() { return primaryColor; }
    public void setPrimaryColor(String primaryColor) { this.primaryColor = primaryColor; }
    public String getTaxCode() { return taxCode; }
    public void setTaxCode(String taxCode) { this.taxCode = taxCode; }
    public String getPublicSlug() { return publicSlug; }
    public void setPublicSlug(String publicSlug) { this.publicSlug = publicSlug; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

