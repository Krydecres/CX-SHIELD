package com.cxshield.backend;

import com.cxshield.backend.controller.FunnelSettingsController;
import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.RoutingRule;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.ReviewKeywordRepository;
import com.cxshield.backend.repository.RoutingRuleRepository;
import com.cxshield.backend.service.FunnelSettingsService;
import com.cxshield.backend.service.impl.FunnelSettingsServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class FunnelSettingsTest {

    private ReviewKeywordRepository keywordRepository;
    private RoutingRuleRepository routingRuleRepository;
    private BusinessRepository businessRepository;
    private FunnelSettingsService funnelSettingsService;
    private FunnelSettingsController funnelSettingsController;

    private UUID testBusinessId;

    @BeforeEach
    void setUp() {
        keywordRepository = new ReviewKeywordRepository();
        routingRuleRepository = new RoutingRuleRepository();
        businessRepository = new BusinessRepository();

        testBusinessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        Business biz = new Business();
        biz.setId(testBusinessId);
        biz.setBrandName("Maison Coffee");
        biz.setDisplayName("Maison Coffee & Bistro");
        biz.setIndustry("F&B");
        businessRepository.save(biz);

        funnelSettingsService = new FunnelSettingsServiceImpl(
                keywordRepository,
                routingRuleRepository,
                businessRepository
        );
        funnelSettingsController = new FunnelSettingsController(funnelSettingsService);
    }

    @Test
    @DisplayName("E4.3: Lấy danh sách từ khóa gợi ý SEO mặc định cho cơ sở F&B")
    void testGetDefaultKeywords() {
        List<ReviewKeywordDto> keywords = funnelSettingsService.getKeywords(testBusinessId, null);
        assertNotNull(keywords);
        assertFalse(keywords.isEmpty());
        assertTrue(keywords.stream().anyMatch(k -> k.keyword().contains("Cà phê")));
    }

    @Test
    @DisplayName("E4.3: Thêm từ khóa gợi ý mới theo ngành thành công")
    void testAddKeyword() {
        CreateKeywordRequestDto request = new CreateKeywordRequestDto("Tráng miệng bánh sừng bò thơm nức", "F&B");
        ReviewKeywordDto created = funnelSettingsService.addKeyword(testBusinessId, request);

        assertNotNull(created);
        assertNotNull(created.id());
        assertEquals("Tráng miệng bánh sừng bò thơm nức", created.keyword());
        assertTrue(created.active());

        // Kiểm tra danh sách cập nhật
        List<ReviewKeywordDto> all = funnelSettingsService.getKeywords(testBusinessId, null);
        assertTrue(all.stream().anyMatch(k -> k.id().equals(created.id())));
    }

    @Test
    @DisplayName("E4.3: Validation - Thêm từ khóa rỗng bị từ chối")
    void testAddEmptyKeywordValidation() {
        CreateKeywordRequestDto request = new CreateKeywordRequestDto("   ", "F&B");
        assertThrows(IllegalArgumentException.class, () ->
                funnelSettingsService.addKeyword(testBusinessId, request)
        );
    }

    @Test
    @DisplayName("E4.3: Sửa từ khóa và bật/tắt trạng thái kích hoạt (active)")
    void testUpdateKeyword() {
        ReviewKeywordDto initial = funnelSettingsService.getKeywords(testBusinessId, null).getFirst();

        UpdateKeywordRequestDto updateReq = new UpdateKeywordRequestDto("Cà phê pha phin hảo hạng", false);
        ReviewKeywordDto updated = funnelSettingsService.updateKeyword(testBusinessId, initial.id(), updateReq);

        assertEquals("Cà phê pha phin hảo hạng", updated.keyword());
        assertFalse(updated.active());

        // Khi tắt active, không còn xuất hiện trong danh sách từ khóa cho khách M1-02
        List<String> activeKeywords = funnelSettingsService.getActiveKeywordsForSurvey(testBusinessId);
        assertFalse(activeKeywords.contains("Cà phê pha phin hảo hạng"));
    }

    @Test
    @DisplayName("E4.3: Xóa từ khóa gợi ý khỏi cơ sở")
    void testDeleteKeyword() {
        CreateKeywordRequestDto request = new CreateKeywordRequestDto("Từ khóa thử nghiệm cần xóa", "F&B");
        ReviewKeywordDto created = funnelSettingsService.addKeyword(testBusinessId, request);

        funnelSettingsService.deleteKeyword(testBusinessId, created.id());

        List<ReviewKeywordDto> afterDelete = funnelSettingsService.getKeywords(testBusinessId, null);
        assertFalse(afterDelete.stream().anyMatch(k -> k.id().equals(created.id())));
    }

    @Test
    @DisplayName("E4.3: Áp dụng bộ từ khóa mẫu cho ngành Nha khoa")
    void testApplyIndustryTemplate() {
        List<ReviewKeywordDto> dentalKeywords = funnelSettingsService.applyIndustryTemplate(testBusinessId, "NHA_KHOA");

        assertNotNull(dentalKeywords);
        assertFalse(dentalKeywords.isEmpty());
        assertTrue(dentalKeywords.stream().anyMatch(k -> k.keyword().contains("Bác sĩ")));
        assertEquals("NHA_KHOA", dentalKeywords.getFirst().industry());
    }

    @Test
    @DisplayName("E4.3: Lấy quy tắc phân luồng mặc định (4-5 sao -> Google)")
    void testGetDefaultRoutingRule() {
        RoutingRuleDto rule = funnelSettingsService.getRoutingRule(testBusinessId);
        assertNotNull(rule);
        assertEquals(4, rule.satisfiedMinScore());
        assertEquals(5, rule.satisfiedMaxScore());
        assertTrue(rule.publicReviewEnabled());
    }

    @Test
    @DisplayName("E4.3: Cập nhật ngưỡng phân luồng cảm xúc (ngưỡng 5 sao)")
    void testUpdateRoutingRule() {
        UpdateRoutingRuleRequestDto updateReq = new UpdateRoutingRuleRequestDto(5, 5, true);
        RoutingRuleDto updated = funnelSettingsService.updateRoutingRule(testBusinessId, updateReq);

        assertEquals(5, updated.satisfiedMinScore());
        assertEquals(5, updated.satisfiedMaxScore());

        // Kiểm tra thực thể trong CSDL
        RoutingRule entity = funnelSettingsService.getRoutingRuleEntity(testBusinessId);
        assertFalse(entity.isSatisfied(4)); // 4 sao không còn là Hài lòng
        assertTrue(entity.isSatisfied(5));  // Chỉ 5 sao mới là Hài lòng
    }

    @Test
    @DisplayName("E4.3: Validation - Ngưỡng điểm sao không hợp lệ bị từ chối")
    void testRoutingRuleInvalidRange() {
        // Min > 5
        UpdateRoutingRuleRequestDto req1 = new UpdateRoutingRuleRequestDto(6, 5, true);
        assertThrows(IllegalArgumentException.class, () ->
                funnelSettingsService.updateRoutingRule(testBusinessId, req1)
        );

        // Max < Min
        UpdateRoutingRuleRequestDto req2 = new UpdateRoutingRuleRequestDto(4, 3, true);
        assertThrows(IllegalArgumentException.class, () ->
                funnelSettingsService.updateRoutingRule(testBusinessId, req2)
        );
    }
}

