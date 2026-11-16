package com.cxshield.backend.dto;

import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record GoogleRedirectRequestDto(
        @NotNull(message = "Response ID không được để trống")
        UUID responseId
) {}

