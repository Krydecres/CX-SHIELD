package com.cxshield.backend.dto;

import java.util.UUID;

public class RateRequestDto {
    private UUID sessionId;
    private int starRating;

    public RateRequestDto() {}

    public RateRequestDto(UUID sessionId, int starRating) {
        this.sessionId = sessionId;
        this.starRating = starRating;
    }

    public UUID getSessionId() { return sessionId; }
    public void setSessionId(UUID sessionId) { this.sessionId = sessionId; }
    public int getStarRating() { return starRating; }
    public void setStarRating(int starRating) { this.starRating = starRating; }
}

