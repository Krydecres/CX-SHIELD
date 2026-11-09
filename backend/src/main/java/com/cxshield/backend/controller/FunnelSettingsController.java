package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.*;
import com.cxshield.backend.service.FunnelSettingsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1")
public class FunnelSettingsController {

    private final FunnelSettingsService funnelSettingsService;

    public FunnelSettingsController(FunnelSettingsService funnelSettingsService) {
        this.funnelSettingsService = funnelSettingsService;
    }

    // 1. Quản lý Từ khóa gợi ý SEO (Review Keywords)
    @GetMapping("/businesses/{businessId}/keywords")
    public ResponseEntity<ApiResponse<List<ReviewKeywordDto>>> getKeywords(
            @PathVariable UUID businessId,
            @RequestParam(required = false) String industry
    ) {
        List<ReviewKeywordDto> keywords = funnelSettingsService.getKeywords(businessId, industry);
        return ResponseEntity.ok(ApiResponse.success(keywords));
    }

    @PostMapping("/businesses/{businessId}/keywords")
    public ResponseEntity<ApiResponse<ReviewKeywordDto>> addKeyword(
            @PathVariable UUID businessId,
            @RequestBody CreateKeywordRequestDto request
    ) {
        ReviewKeywordDto created = funnelSettingsService.addKeyword(businessId, request);
        return ResponseEntity.ok(ApiResponse.success("Thêm từ khóa gợi ý thành công", created));
    }

    @PutMapping("/businesses/{businessId}/keywords/{keywordId}")
    public ResponseEntity<ApiResponse<ReviewKeywordDto>> updateKeyword(
            @PathVariable UUID businessId,
            @PathVariable UUID keywordId,
            @RequestBody UpdateKeywordRequestDto request
    ) {
        ReviewKeywordDto updated = funnelSettingsService.updateKeyword(businessId, keywordId, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật từ khóa thành công", updated));
    }

    @DeleteMapping("/businesses/{businessId}/keywords/{keywordId}")
    public ResponseEntity<ApiResponse<Void>> deleteKeyword(
            @PathVariable UUID businessId,
            @PathVariable UUID keywordId
    ) {
        funnelSettingsService.deleteKeyword(businessId, keywordId);
        return ResponseEntity.ok(ApiResponse.success("Xóa từ khóa thành công", null));
    }

    @PostMapping("/businesses/{businessId}/keywords/apply-template")
    public ResponseEntity<ApiResponse<List<ReviewKeywordDto>>> applyTemplate(
            @PathVariable UUID businessId,
            @RequestParam(defaultValue = "F&B") String industry
    ) {
        List<ReviewKeywordDto> keywords = funnelSettingsService.applyIndustryTemplate(businessId, industry);
        return ResponseEntity.ok(ApiResponse.success("Áp dụng bộ từ khóa mẫu ngành " + industry + " thành công", keywords));
    }

    // 2. Quản lý Quy tắc Phân luồng Cảm xúc (Routing Rules)
    @GetMapping("/businesses/{businessId}/routing-rules")
    public ResponseEntity<ApiResponse<RoutingRuleDto>> getRoutingRule(@PathVariable UUID businessId) {
        RoutingRuleDto rule = funnelSettingsService.getRoutingRule(businessId);
        return ResponseEntity.ok(ApiResponse.success(rule));
    }

    @PutMapping("/businesses/{businessId}/routing-rules")
    public ResponseEntity<ApiResponse<RoutingRuleDto>> updateRoutingRule(
            @PathVariable UUID businessId,
            @RequestBody UpdateRoutingRuleRequestDto request
    ) {
        RoutingRuleDto updated = funnelSettingsService.updateRoutingRule(businessId, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật quy tắc phân luồng cảm xúc thành công", updated));
    }

    // 3. Danh mục Template từ khóa gợi ý theo ngành
    @GetMapping("/funnel-settings/industry-templates")
    public ResponseEntity<ApiResponse<List<IndustryTemplateDto>>> getIndustryTemplates() {
        List<IndustryTemplateDto> templates = funnelSettingsService.getIndustryTemplates();
        return ResponseEntity.ok(ApiResponse.success(templates));
    }
}

