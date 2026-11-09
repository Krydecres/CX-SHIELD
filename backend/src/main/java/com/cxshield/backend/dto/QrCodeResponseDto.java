package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record QrCodeResponseDto(
        UUID id,
        UUID branchId,
        String code,
        String type,
        String name,
        String status,
        String targetUrl,
        Instant createdAt
) {}
