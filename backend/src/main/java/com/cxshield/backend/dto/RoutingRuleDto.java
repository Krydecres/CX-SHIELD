package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record RoutingRuleDto(
        UUID id,
        UUID businessId,
        int satisfiedMinScore,
        int satisfiedMaxScore,
        boolean publicReviewEnabled,
        Instant createdAt,
        Instant updatedAt
) {}

