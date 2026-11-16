package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.SurveyController;
import com.cxshield.backend.dto.PublicBypassRequestDto;
import com.cxshield.backend.dto.PublicBypassResponseDto;
import com.cxshield.backend.dto.RateRequestDto;
import com.cxshield.backend.dto.RateResultDto;
import com.cxshield.backend.dto.SurveyInitResponseDto;
import com.cxshield.backend.entity.Branch;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.repository.BranchRepository;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.repository.ReviewPlatformRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.service.SurveyService;
import com.cxshield.backend.service.impl.SurveyServiceImpl;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class SurveyControllerTest {

    private static final UUID BUSINESS_ID = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
    private static final UUID BRANCH_ID = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
    private static final UUID QR_ID = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
    private static final UUID PLATFORM_ID = UUID.fromString("d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44");

    private SupabaseAdminClient supabase;
    private SurveyService surveyService;
    private SurveyController surveyController;
    private SurveyResponseRepository surveyResponseRepository;
    private SurveySessionRepository surveySessionRepository;

    private final Map<UUID, SurveySession> sessionStore = new ConcurrentHashMap<>();
    private final Map<UUID, SurveyResponse> responseStore = new ConcurrentHashMap<>();

    @BeforeEach
    void setUp() {
        supabase = mock(SupabaseAdminClient.class);
        sessionStore.clear();
        responseStore.clear();

        // 1. Dữ liệu mẫu QrCode
        QrCode qrCode = new QrCode(QR_ID, BRANCH_ID, "MC-B04", "TABLE", "Bàn 04", "ACTIVE");
        when(supabase.select(eq("qr_codes"), argThat(m -> "eq.MC-B04".equals(m.get("code"))), any()))
                .thenReturn(List.of(qrCode));
        when(supabase.select(eq("qr_codes"), argThat(m -> ("eq." + QR_ID).equals(m.get("id"))), any()))
                .thenReturn(List.of(qrCode));

        // 2. Dữ liệu mẫu Branch
        Branch branch = new Branch(BRANCH_ID, BUSINESS_ID, "CN-Q1", "Chi nhánh Quận 1 - Đồng Khởi",
                "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh", "02838221122", "ACTIVE");
        when(supabase.select(eq("branches"), argThat(m -> ("eq." + BRANCH_ID).equals(m.get("id"))), any()))
                .thenReturn(List.of(branch));

        // 3. Dữ liệu mẫu Business
        Business business = new Business(BUSINESS_ID, "Maison Coffee & Bistro", "Maison Coffee & Bistro",
                "F&B", "0901234567", "https://example.com/logo.png", "#2C1810", "0312345678", "maison-coffee", "ACTIVE");
        when(supabase.select(eq("businesses"), argThat(m -> ("eq." + BUSINESS_ID).equals(m.get("id"))), any()))
                .thenReturn(List.of(business));

        // 4. Dữ liệu mẫu ReviewPlatform
        ReviewPlatform platform = new ReviewPlatform(PLATFORM_ID, BRANCH_ID, "Google Maps",
                "ChIJ1234567890abcdef", "https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef",
                "Maison Coffee & Bistro - Đồng Khởi", "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh");
        when(supabase.select(eq("review_platforms"), argThat(m -> ("eq." + BRANCH_ID).equals(m.get("branch_id"))), any()))
                .thenReturn(List.of(platform));

        // 5. Mock lưu trữ survey_sessions
        doAnswer(invocation -> {
            SurveySession s = invocation.getArgument(2);
            sessionStore.put(s.getId(), s);
            return null;
        }).when(supabase).upsert(eq("survey_sessions"), eq("id"), any(SurveySession.class));

        when(supabase.select(eq("survey_sessions"), anyMap(), any())).thenAnswer(invocation -> {
            Map<String, String> query = invocation.getArgument(1);
            String idVal = query.get("id");
            if (idVal != null && idVal.startsWith("eq.")) {
                UUID id = UUID.fromString(idVal.substring(3));
                SurveySession s = sessionStore.get(id);
                return s != null ? List.of(s) : List.of();
            }
            return List.of();
        });

        // 6. Mock lưu trữ survey_responses
        doAnswer(invocation -> {
            SurveyResponse r = invocation.getArgument(2);
            responseStore.put(r.getId(), r);
            return null;
        }).when(supabase).upsert(eq("survey_responses"), eq("id"), any(SurveyResponse.class));

        when(supabase.select(eq("survey_responses"), anyMap(), any())).thenAnswer(invocation -> {
            Map<String, String> query = invocation.getArgument(1);
            String idVal = query.get("id");
            if (idVal != null && idVal.startsWith("eq.")) {
                UUID id = UUID.fromString(idVal.substring(3));
                SurveyResponse r = responseStore.get(id);
                return r != null ? List.of(r) : List.of();
            }
            return List.of();
        });

        QrCodeRepository qrCodeRepository = new QrCodeRepository(supabase);
        BranchRepository branchRepository = new BranchRepository(supabase);
        BusinessRepository businessRepository = new BusinessRepository(supabase);
        surveySessionRepository = new SurveySessionRepository(supabase);
        surveyResponseRepository = new SurveyResponseRepository(supabase);
        ReviewPlatformRepository reviewPlatformRepository = new ReviewPlatformRepository(supabase);

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
    @DisplayName("E1.1: Quét mã QR nhận diện cơ sở Maison Coffee & Bistro và Bàn 04, lưu vào Supabase với business_id")
    void testScanQrCode() {
        SurveyInitResponseDto dto = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Safari");

        assertNotNull(dto);
        assertNotNull(dto.getSessionId());
        assertEquals("Maison Coffee & Bistro", dto.getBusinessName());
        assertEquals("Bàn 04", dto.getTableOrAreaCode());
        assertEquals("Chi nhánh Quận 1 - Đồng Khởi", dto.getBranchName());

        // Kiểm tra phiên khảo sát đã được lưu vào Supabase với business_id và status STARTED
        SurveySession saved = sessionStore.get(dto.getSessionId());
        assertNotNull(saved);
        assertEquals(BUSINESS_ID, saved.getBusinessId());
        assertEquals(BRANCH_ID, saved.getBranchId());
        assertEquals(QR_ID, saved.getQrCodeId());
        assertEquals("STARTED", saved.getStatus());
    }

    @Test
    @DisplayName("E1.1: Quét mã QR không tồn tại trong qr_codes phải báo lỗi")
    void testScanNonExistentQrCodeThrowsException() {
        when(supabase.select(eq("qr_codes"), argThat(m -> "eq.INVALID_QR".equals(m.get("code"))), any()))
                .thenReturn(List.of());

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                surveyService.getOrInitSession("INVALID_QR", "127.0.0.1", "Mobile Safari"));
        assertTrue(ex.getMessage().contains("Mã QR không tồn tại"));
    }

    @Test
    @DisplayName("E1.1: Đánh giá 5 sao -> phân luồng SATISFIED và điều hướng sang M1-02 (Google Maps)")
    void testSubmitRatingPositive() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        UUID sessionId = init.getSessionId();

        RateRequestDto request = new RateRequestDto(sessionId, 5);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertNotNull(result);
        assertEquals(5, result.getStarRating());
        assertEquals("SATISFIED", result.getSentimentGroup());
        assertEquals("M1-02", result.getTargetScreen());
        assertFalse(result.isAllowUrgentCall());

        // Phiên đổi sang COMPLETED
        SurveySession updatedSession = sessionStore.get(sessionId);
        assertNotNull(updatedSession);
        assertEquals("COMPLETED", updatedSession.getStatus());
        assertNotNull(updatedSession.getCompletedAt());

        // Kết quả đánh giá được lưu với business_id
        SurveyResponse savedResp = responseStore.get(result.getResponseId());
        assertNotNull(savedResp);
        assertEquals(BUSINESS_ID, savedResp.getBusinessId());
        assertEquals(sessionId, savedResp.getSessionId());
        assertEquals("SATISFIED", savedResp.getSentimentGroup());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 4 sao -> phân luồng SATISFIED và điều hướng sang M1-02")
    void testSubmitRatingFourStars() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 4);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        assertEquals("SATISFIED", response.getData().getSentimentGroup());
        assertEquals("M1-02", response.getData().getTargetScreen());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 2 hoặc 3 sao -> phân luồng UNSATISFIED và điều hướng sang M1-04 (Góp ý nội bộ)")
    void testSubmitRatingNegative() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 3);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertEquals(3, result.getStarRating());
        assertEquals("UNSATISFIED", result.getSentimentGroup());
        assertEquals("M1-04", result.getTargetScreen());
        assertFalse(result.isAllowUrgentCall());
    }

    @Test
    @DisplayName("E1.1: Đánh giá 1 sao -> phân luồng UNSATISFIED, điều hướng sang M1-04 kèm hỗ trợ M1-05 (Hotline/gọi lại)")
    void testSubmitRatingOneStarUrgent() {
        SurveyInitResponseDto init = surveyService.getOrInitSession("MC-B04", "127.0.0.1", "Mobile Chrome");
        RateRequestDto request = new RateRequestDto(init.getSessionId(), 1);
        ApiResponse<RateResultDto> response = surveyController.submitRating(request);

        assertTrue(response.isSuccess());
        RateResultDto result = response.getData();
        assertEquals(1, result.getStarRating());
        assertEquals("UNSATISFIED", result.getSentimentGroup());
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
        assertThrows(IllegalArgumentException.class, () ->
                surveyService.submitRating(new RateRequestDto(init.getSessionId(), 6)));
        assertThrows(IllegalArgumentException.class, () ->
                surveyService.submitRating(new RateRequestDto(init.getSessionId(), 0)));
    }
}
