package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record ReviewKeywordDto(
        UUID id,
        UUID businessId,
        String industry,
        String keyword,
        boolean active,
        Instant createdAt,
        Instant updatedAt
) {}

