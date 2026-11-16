package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record PrintDesignResponseDto(
        UUID id,
        UUID businessId,
        UUID qrCodeId,
        String qrCodeValue,
        String targetUrl,
        String template,
        String templateName,
        String brandName,
        String ctaText,
        String color,
        String logoUrl,
        String exportFormat,
        String size,
        String downloadUrl,
        Instant createdAt
) {}

