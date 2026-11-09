package com.cxshield.backend.dto;

import java.time.Instant;
import java.util.UUID;

public record NfcOrderResponseDto(
        UUID id,
        UUID businessId,
        UUID designId,
        String material,
        String materialLabel,
        int quantity,
        long unitPrice,
        long totalAmount,
        String shipName,
        String shipPhone,
        String shipAddress,
        String status,
        String statusLabel,
        String estimatedDelivery,
        Instant createdAt
) {}

