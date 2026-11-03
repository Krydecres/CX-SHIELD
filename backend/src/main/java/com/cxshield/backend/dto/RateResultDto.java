package com.cxshield.backend.dto;

import java.util.UUID;

public class RateResultDto {
    private UUID responseId;
    private UUID sessionId;
    private int starRating;
    private String sentimentGroup; // POSITIVE, NEGATIVE
    private String targetScreen;   // M1-02, M1-04
    private boolean allowUrgentCall; // true if starRating == 1 (for M1-05 option)
    private String message;
    private String hotline;

    public RateResultDto() {}

    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
    public UUID getSessionId() { return sessionId; }
    public void setSessionId(UUID sessionId) { this.sessionId = sessionId; }
    public int getStarRating() { return starRating; }
    public void setStarRating(int starRating) { this.starRating = starRating; }
    public String getSentimentGroup() { return sentimentGroup; }
    public void setSentimentGroup(String sentimentGroup) { this.sentimentGroup = sentimentGroup; }
    public String getTargetScreen() { return targetScreen; }
    public void setTargetScreen(String targetScreen) { this.targetScreen = targetScreen; }
    public boolean isAllowUrgentCall() { return allowUrgentCall; }
    public void setAllowUrgentCall(boolean allowUrgentCall) { this.allowUrgentCall = allowUrgentCall; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getHotline() { return hotline; }
    public void setHotline(String hotline) { this.hotline = hotline; }
}

