package com.cxshield.backend.service;

import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.ReviewKeyword;
import com.cxshield.backend.entity.RoutingRule;

import java.util.List;
import java.util.UUID;

public interface FunnelSettingsService {

    List<ReviewKeywordDto> getKeywords(UUID businessId, String industry);

    ReviewKeywordDto addKeyword(UUID businessId, CreateKeywordRequestDto request);

    ReviewKeywordDto updateKeyword(UUID businessId, UUID keywordId, UpdateKeywordRequestDto request);

    void deleteKeyword(UUID businessId, UUID keywordId);

    List<ReviewKeywordDto> applyIndustryTemplate(UUID businessId, String industry);

    RoutingRuleDto getRoutingRule(UUID businessId);

    RoutingRuleDto updateRoutingRule(UUID businessId, UpdateRoutingRuleRequestDto request);

    List<IndustryTemplateDto> getIndustryTemplates();

    List<String> getActiveKeywordsForSurvey(UUID businessId);

    RoutingRule getRoutingRuleEntity(UUID businessId);
}

