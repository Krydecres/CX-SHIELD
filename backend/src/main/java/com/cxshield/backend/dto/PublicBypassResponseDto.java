package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public class PublicBypassResponseDto {
    private UUID responseId;
    private boolean isPublicBypass;
    private Instant redirectClickedAt;
    private UUID reviewPlatformId;
    private String platformName;
    private String reviewDirectUrl;
    private String placeName;
    private String message;

    public PublicBypassResponseDto() {}

    public PublicBypassResponseDto(UUID responseId, boolean isPublicBypass, Instant redirectClickedAt, UUID reviewPlatformId, String platformName, String reviewDirectUrl, String placeName, String message) {
        this.responseId = responseId;
        this.isPublicBypass = isPublicBypass;
        this.redirectClickedAt = redirectClickedAt;
        this.reviewPlatformId = reviewPlatformId;
        this.platformName = platformName;
        this.reviewDirectUrl = reviewDirectUrl;
        this.placeName = placeName;
        this.message = message;
    }

    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
    public boolean isPublicBypass() { return isPublicBypass; }
    public void setPublicBypass(boolean publicBypass) { isPublicBypass = publicBypass; }
    public Instant getRedirectClickedAt() { return redirectClickedAt; }
    public void setRedirectClickedAt(Instant redirectClickedAt) { this.redirectClickedAt = redirectClickedAt; }
    public UUID getReviewPlatformId() { return reviewPlatformId; }
    public void setReviewPlatformId(UUID reviewPlatformId) { this.reviewPlatformId = reviewPlatformId; }
    public String getPlatformName() { return platformName; }
    public void setPlatformName(String platformName) { this.platformName = platformName; }
    public String getReviewDirectUrl() { return reviewDirectUrl; }
    public void setReviewDirectUrl(String reviewDirectUrl) { this.reviewDirectUrl = reviewDirectUrl; }
    public String getPlaceName() { return placeName; }
    public void setPlaceName(String placeName) { this.placeName = placeName; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}

