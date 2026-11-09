package com.cxshield.backend.dto;

public record UpdateKeywordRequestDto(
        String keyword,
        Boolean active
) {}
