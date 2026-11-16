package com.cxshield.backend.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record QrCodeRequestDto(
        @NotNull(message = "Chi nhánh không được để trống")
        UUID branchId,

        String code,

        String type, // TABLE, AREA, COUNTER, STAFF

        String name
) {}

