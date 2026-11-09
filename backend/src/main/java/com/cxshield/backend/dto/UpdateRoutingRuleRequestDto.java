package com.cxshield.backend.dto;

public record UpdateRoutingRuleRequestDto(
        Integer satisfiedMinScore,
        Integer satisfiedMaxScore,
        Boolean publicReviewEnabled
) {}
