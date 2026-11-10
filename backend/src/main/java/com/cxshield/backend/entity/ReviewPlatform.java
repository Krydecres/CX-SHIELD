package com.cxshield.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@JsonIgnoreProperties(ignoreUnknown = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ReviewPlatform {
    @JsonProperty("id")
    private UUID id;

    @JsonProperty("branch_id")
    private UUID branchId;

    @JsonProperty("platform_name")
    private String platformName; // Google Maps, TripAdvisor, Fanpage, ...

    @JsonProperty("google_place_id")
    private String googlePlaceId;

    @JsonProperty("review_direct_url")
    private String reviewDirectUrl;

    @JsonProperty("place_name")
    private String placeName;

    @JsonProperty("place_address")
    private String placeAddress;

    @JsonProperty("connection_status")
    private String connectionStatus; // CONNECTED, DISCONNECTED

    @JsonProperty("routing_weight_percent")
    private BigDecimal routingWeightPercent;

    @JsonProperty("is_active")
    private boolean isActive;

    @JsonProperty("created_at")
    private Instant createdAt;

    @JsonProperty("updated_at")
    private Instant updatedAt;

    public ReviewPlatform() {
        this.id = UUID.randomUUID();
        this.platformName = "Google Maps";
        this.connectionStatus = "CONNECTED";
        this.routingWeightPercent = new BigDecimal("100.00");
        this.isActive = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public ReviewPlatform(UUID id, UUID branchId, String platformName, String googlePlaceId, String reviewDirectUrl, String placeName, String placeAddress) {
        this.id = id;
        this.branchId = branchId;
        this.platformName = platformName;
        this.googlePlaceId = googlePlaceId;
        this.reviewDirectUrl = reviewDirectUrl;
        this.placeName = placeName;
        this.placeAddress = placeAddress;
        this.connectionStatus = "CONNECTED";
        this.routingWeightPercent = new BigDecimal("100.00");
        this.isActive = true;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getBranchId() { return branchId; }
    public void setBranchId(UUID branchId) { this.branchId = branchId; }
    public String getPlatformName() { return platformName; }
    public void setPlatformName(String platformName) { this.platformName = platformName; }
    public String getGooglePlaceId() { return googlePlaceId; }
    public void setGooglePlaceId(String googlePlaceId) { this.googlePlaceId = googlePlaceId; }
    public String getReviewDirectUrl() { return reviewDirectUrl; }
    public void setReviewDirectUrl(String reviewDirectUrl) { this.reviewDirectUrl = reviewDirectUrl; }
    public String getPlaceName() { return placeName; }
    public void setPlaceName(String placeName) { this.placeName = placeName; }
    public String getPlaceAddress() { return placeAddress; }
    public void setPlaceAddress(String placeAddress) { this.placeAddress = placeAddress; }
    public String getConnectionStatus() { return connectionStatus; }
    public void setConnectionStatus(String connectionStatus) { this.connectionStatus = connectionStatus; }
    public BigDecimal getRoutingWeightPercent() { return routingWeightPercent; }
    public void setRoutingWeightPercent(BigDecimal routingWeightPercent) { this.routingWeightPercent = routingWeightPercent; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
