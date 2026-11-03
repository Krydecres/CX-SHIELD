package com.cxshield.backend.dto;

import java.util.UUID;

public class PublicBypassRequestDto {
    private UUID responseId;

    public PublicBypassRequestDto() {}

    public PublicBypassRequestDto(UUID responseId) {
        this.responseId = responseId;
    }

    public UUID getResponseId() { return responseId; }
    public void setResponseId(UUID responseId) { this.responseId = responseId; }
}

