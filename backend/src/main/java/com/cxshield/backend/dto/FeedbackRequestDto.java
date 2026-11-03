package com.cxshield.backend.dto;

import java.util.List;
import java.util.UUID;

public class FeedbackRequestDto {
    private UUID responseId;
    private String commentText;
    private String customerPhone;
    private boolean consentToContact;
    private boolean isUrgentCallback;
    private List<UUID> topicIds;

    public FeedbackRequestDto() {}

    public FeedbackRequestDto(UUID responseId, String commentText, String customerPhone, boolean consentToContact) {
        this.responseId = responseId;
        this.commentText = commentText;
        this.customerPhone = customerPhone;
        this.consentToContact = consentToContact;
    }

    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
    public String getCommentText() { return commentText; }
    public void setCommentText(String commentText) { this.commentText = commentText; }
    public String getCustomerPhone() { return customerPhone; }
    public void setCustomerPhone(String customerPhone) { this.customerPhone = customerPhone; }
    public boolean isConsentToContact() { return consentToContact; }
    public void setConsentToContact(boolean consentToContact) { this.consentToContact = consentToContact; }
    public boolean isUrgentCallback() { return isUrgentCallback; }
    public void setUrgentCallback(boolean urgentCallback) { isUrgentCallback = urgentCallback; }
    public List<UUID> getTopicIds() { return topicIds; }
    public void setTopicIds(List<UUID> topicIds) { this.topicIds = topicIds; }
}

