package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record GoogleRedirectResponseDto(
        UUID responseId,
        Instant redirectClickedAt,
        UUID reviewPlatformId,
        String platformName,
        String reviewDirectUrl,
        String placeName,
        String message
) {}

