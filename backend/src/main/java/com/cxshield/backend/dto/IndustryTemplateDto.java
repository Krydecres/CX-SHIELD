package com.cxshield.backend.dto;

import java.util.List;

public record IndustryTemplateDto(
        String industry,
        String displayName,
        List<String> keywords
) {}
