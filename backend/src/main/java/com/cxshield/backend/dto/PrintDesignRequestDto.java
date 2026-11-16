package com.cxshield.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record PrintDesignRequestDto(
        UUID id,

        UUID businessId,

        @NotNull(message = "Mã QR liên kết không được để trống")
        UUID qrCodeId,

        String template, // TABLE_TENT, COUNTER_STAND, WINDOW_STICKER, CARD_NFC

        @NotBlank(message = "Tên thương hiệu không được để trống")
        String brandName,

        String ctaText,

        String color, // Mã hex, e.g. #1E3A8A

        String logoUrl,

        String exportFormat, // PDF, PNG

        String size // A6, A5, STAND
) {
    public PrintDesignRequestDto(UUID businessId, UUID qrCodeId, String template,
                                 String brandName, String ctaText, String color,
                                 String logoUrl, String exportFormat, String size) {
        this(null, businessId, qrCodeId, template, brandName, ctaText, color, logoUrl, exportFormat, size);
    }
}


