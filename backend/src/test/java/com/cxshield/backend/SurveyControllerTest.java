package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.SurveyController;
import com.cxshield.backend.dto.PublicBypassRequestDto;
import com.cxshield.backend.dto.PublicBypassResponseDto;
import com.cxshield.backend.dto.RateRequestDto;
import com.cxshield.backend.dto.RateResultDto;
import com.cxshield.backend.dto.SurveyInitResponseDto;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.repository.BranchRepository;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.repository.ReviewPlatformRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.service.SurveyService;
import com.cxshield.backend.service.impl.SurveyServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class SurveyControllerTest {

    private SurveyService surveyService;
    private SurveyController surveyController;
    private SurveyResponseRepository surveyResponseRepository;

    @BeforeEach
    void setUp() {
        QrCodeRepository qrCodeRepository = new QrCodeRepository();
        BranchRepository branchRepository = new BranchRepository();
        BusinessRepository businessRepository = new BusinessRepository();
        SurveySessionRepository surveySessionRepository = new SurveySessionRepository();
        surveyResponseRepository = new SurveyResponseRepository();
        ReviewPlatformRepository reviewPlatformRepository = new ReviewPlatformRepository();

        surveyService = new SurveyServiceImpl(
                qrCodeRepository,
                branchRepository,
                businessRepository,
                surveySessionRepository,
                surveyResponseRepository,
                reviewPlatformRepository
        );
        surveyController = new SurveyController(surveyService);
    }

    @Test
    @DisplayName("E1.1: Quét mã QR nhận diện cơ sở Maison Coffee & Bistro và Bàn 04")
    void testScanQrCode() {
        SurveyInitResponseDto dto = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Safari");

        assertNotNull(dto);
        assertNotNull(dto.getSessionId());
        assertEquals("Maison Coffee & Bistro", dto.getBusinessName());
        assertEquals("Bàn 04", dto.getTableOrAreaCode());
        assertEquals("Chi nhánh Quận 1 - Đồng Khởi", dto.getBranchName());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 5 sao -> phân luồng POSITIVE và điều hướng sang M1-02 (Google Maps)")
    void testSubmitRatingPositive() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        UUID sessionId = init.getSessionId();

        RateRequestDto request = new RateRequestDto(sessionId, 5);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertNotNull(result);
        assertEquals(5, result.getStarRating());
        assertEquals("POSITIVE", result.getSentimentGroup());
        assertEquals("M1-02", result.getTargetScreen());
        assertFalse(result.isAllowUrgentCall());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 4 sao -> phân luồng POSITIVE và điều hướng sang M1-02")
    void testSubmitRatingFourStars() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 4);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        assertEquals("POSITIVE", response.getData().getSentimentGroup());
        assertEquals("M1-02", response.getData().getTargetScreen());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 2 hoặc 3 sao -> phân luồng NEGATIVE và điều hướng sang M1-04 (Góp ý nội bộ)")
    void testSubmitRatingNegative() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 3);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertEquals(3, result.getStarRating());
        assertEquals("NEGATIVE", result.getSentimentGroup());
        assertEquals("M1-04", result.getTargetScreen());
        assertFalse(result.isAllowUrgentCall());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 1 sao -> phân luồng NEGATIVE, điều hướng sang M1-04 kèm hỗ trợ M1-05 (Hotline/gọi lại)")
    void testSubmitRatingOneStarUrgent() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 1);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertEquals(1, result.getStarRating());
        assertEquals("NEGATIVE", result.getSentimentGroup());
        assertEquals("M1-04", result.getTargetScreen());
        assertTrue(result.isAllowUrgentCall());
        assertNotNull(result.getHotline());
    }

    @Test
    @DisplayName("E1.4: Lối đi đánh giá công khai (Chống review gating) cập nhật is_public_bypass và trả link Google Maps")
    void testRecordPublicBypass() {
        // 1. Quét QR và đánh giá 2 sao
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateResultDto rateResult = surveyController.submitRating(new RateRequestDto(init.getSessionId(), 2)).getData();
        UUID responseId = rateResult.getResponseId();

        // 2. Bấm link đánh giá công khai (E1.4 bypass)
        PublicBypassRequestDto bypassDto = new PublicBypassRequestDto(responseId);
        ApiResponse<PublicBypassResponseDto> bypassResponse = surveyController.recordPublicBypass(bypassDto);

        assertTrue(bypassResponse.isSuccess());
        PublicBypassResponseDto data = bypassResponse.getData();
        assertNotNull(data);
        assertTrue(data.isPublicBypass());
        assertNotNull(data.getRedirectClickedAt());
        assertTrue(data.getReviewDirectUrl().contains("writereview"));
        assertEquals("Google Maps", data.getPlatformName());

        // Kiểm tra trong CSDL survey_responses
        Optional<SurveyResponse> saved = surveyResponseRepository.findById(responseId);
        assertTrue(saved.isPresent());
        assertTrue(saved.get().isPublicBypass());
        assertNotNull(saved.get().getRedirectClickedAt());
        assertNotNull(saved.get().getReviewPlatformId());
    }

    @Test
    @DisplayName("E1.1: Đánh giá sao không hợp lệ (<1 hoặc >5) phải ném ngoại lệ")
    void testInvalidRating() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        assertThrows(IllegalArgumentException.class, () -> {
            surveyService.submitRating(new RateRequestDto(init.getSessionId(), 6));
        });
        assertThrows(IllegalArgumentException.class, () -> {
            surveyService.submitRating(new RateRequestDto(init.getSessionId(), 0));
        });
    }
}
