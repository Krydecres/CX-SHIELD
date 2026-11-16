package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Branch;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.core.ParameterizedTypeReference;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class SurveyRepositorySupabaseTest {

    private SupabaseAdminClient supabase;

    private QrCodeRepository qrCodeRepository;
    private BranchRepository branchRepository;
    private BusinessRepository businessRepository;
    private SurveySessionRepository surveySessionRepository;
    private SurveyResponseRepository surveyResponseRepository;
    private FeedbackRepository feedbackRepository;
    private ReviewPlatformRepository reviewPlatformRepository;

    private static final UUID BUSINESS_ID = UUID.randomUUID();
    private static final UUID BRANCH_ID = UUID.randomUUID();
    private static final UUID QR_ID = UUID.randomUUID();
    private static final UUID SESSION_ID = UUID.randomUUID();
    private static final UUID RESPONSE_ID = UUID.randomUUID();
    private static final UUID FEEDBACK_ID = UUID.randomUUID();
    private static final UUID PLATFORM_ID = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        supabase = mock(SupabaseAdminClient.class);

        qrCodeRepository = new QrCodeRepository(supabase);
        branchRepository = new BranchRepository(supabase);
        businessRepository = new BusinessRepository(supabase);
        surveySessionRepository = new SurveySessionRepository(supabase);
        surveyResponseRepository = new SurveyResponseRepository(supabase);
        feedbackRepository = new FeedbackRepository(supabase);
        reviewPlatformRepository = new ReviewPlatformRepository(supabase);
    }

    @Test
    @DisplayName("QrCodeRepository: Tìm mã QR qua code gọi Supabase query đúng bảng và điều kiện")
    void qrCodeRepositoryFindByCode() {
        QrCode qrCode = new QrCode(QR_ID, BRANCH_ID, "MC-B04", "TABLE", "Bàn 04", "ACTIVE");
        when(supabase.select(eq("qr_codes"), anyMap(), any())).thenReturn(List.of(qrCode));

        Optional<QrCode> result = qrCodeRepository.findByCode("MC-B04");

        assertThat(result).isPresent();
        assertThat(result.get().getCode()).isEqualTo("MC-B04");

        ArgumentCaptor<Map<String, String>> captor = ArgumentCaptor.forClass(Map.class);
        verify(supabase).select(eq("qr_codes"), captor.capture(), any());
        assertThat(captor.getValue()).containsEntry("code", "eq.MC-B04")
                .containsEntry("status", "eq.ACTIVE");
    }

    @Test
    @DisplayName("QrCodeRepository: Lưu mã QR gọi upsert trên bảng qr_codes")
    void qrCodeRepositorySave() {
        QrCode qrCode = new QrCode(QR_ID, BRANCH_ID, "MC-B04", "TABLE", "Bàn 04", "ACTIVE");
        qrCodeRepository.save(qrCode);

        verify(supabase).upsert(eq("qr_codes"), eq("id"), eq(qrCode));
    }

    @Test
    @DisplayName("BranchRepository: Tìm chi nhánh qua id gọi bảng branches")
    void branchRepositoryFindById() {
        Branch branch = new Branch(BRANCH_ID, BUSINESS_ID, "CN-Q1", "Chi nhánh Q1", "123 Lê Lợi", "0901234567", "ACTIVE");
        when(supabase.select(eq("branches"), anyMap(), any())).thenReturn(List.of(branch));

        Optional<Branch> result = branchRepository.findById(BRANCH_ID);

        assertThat(result).isPresent();
        assertThat(result.get().getName()).isEqualTo("Chi nhánh Q1");

        ArgumentCaptor<Map<String, String>> captor = ArgumentCaptor.forClass(Map.class);
        verify(supabase).select(eq("branches"), captor.capture(), any());
        assertThat(captor.getValue()).containsEntry("id", "eq." + BRANCH_ID);
    }

    @Test
    @DisplayName("BusinessRepository: Tìm cơ sở kinh doanh qua id gọi bảng businesses")
    void businessRepositoryFindById() {
        Business business = new Business(BUSINESS_ID, "Maison Coffee", "Maison Coffee", "F&B", "0901234567", null, "#2C1810", null, "maison", "ACTIVE");
        when(supabase.select(eq("businesses"), anyMap(), any())).thenReturn(List.of(business));

        Optional<Business> result = businessRepository.findById(BUSINESS_ID);

        assertThat(result).isPresent();
        assertThat(result.get().getBrandName()).isEqualTo("Maison Coffee");

        ArgumentCaptor<Map<String, String>> captor = ArgumentCaptor.forClass(Map.class);
        verify(supabase).select(eq("businesses"), captor.capture(), any());
        assertThat(captor.getValue()).containsEntry("id", "eq." + BUSINESS_ID);
    }

    @Test
    @DisplayName("SurveySessionRepository: Lưu phiên khảo sát gọi upsert trên survey_sessions")
    void surveySessionRepositorySave() {
        SurveySession session = new SurveySession();
        session.setId(SESSION_ID);
        session.setBusinessId(BUSINESS_ID);
        session.setBranchId(BRANCH_ID);
        session.setQrCodeId(QR_ID);
        session.setStatus("STARTED");

        surveySessionRepository.save(session);

        verify(supabase).upsert(eq("survey_sessions"), eq("id"), eq(session));
    }

    @Test
    @DisplayName("SurveyResponseRepository: Lưu kết quả đánh giá gọi upsert trên survey_responses")
    void surveyResponseRepositorySave() {
        SurveyResponse response = new SurveyResponse();
        response.setId(RESPONSE_ID);
        response.setBusinessId(BUSINESS_ID);
        response.setSessionId(SESSION_ID);
        response.setStarRating(5);
        response.setSentimentGroup("SATISFIED");

        surveyResponseRepository.save(response);

        verify(supabase).upsert(eq("survey_responses"), eq("id"), eq(response));
    }

    @Test
    @DisplayName("FeedbackRepository: Lưu góp ý gọi upsert trên feedbacks")
    void feedbackRepositorySave() {
        Feedback feedback = new Feedback();
        feedback.setId(FEEDBACK_ID);
        feedback.setBusinessId(BUSINESS_ID);
        feedback.setBranchId(BRANCH_ID);
        feedback.setResponseId(RESPONSE_ID);
        feedback.setCommentText("Không gian sạch sẽ");

        feedbackRepository.save(feedback);

        verify(supabase).upsert(eq("feedbacks"), eq("id"), eq(feedback));
    }

    @Test
    @DisplayName("FeedbackRepository: Tìm góp ý theo response_id gọi bảng feedbacks")
    void feedbackRepositoryFindByResponseId() {
        Feedback feedback = new Feedback();
        feedback.setId(FEEDBACK_ID);
        feedback.setResponseId(RESPONSE_ID);
        when(supabase.select(eq("feedbacks"), anyMap(), any())).thenReturn(List.of(feedback));

        Optional<Feedback> result = feedbackRepository.findByResponseId(RESPONSE_ID);

        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo(FEEDBACK_ID);

        ArgumentCaptor<Map<String, String>> captor = ArgumentCaptor.forClass(Map.class);
        verify(supabase).select(eq("feedbacks"), captor.capture(), any());
        assertThat(captor.getValue()).containsEntry("response_id", "eq." + RESPONSE_ID);
    }

    @Test
    @DisplayName("ReviewPlatformRepository: Tìm nền tảng Google Maps của chi nhánh")
    void reviewPlatformRepositoryFindByBranchId() {
        ReviewPlatform platform = new ReviewPlatform(PLATFORM_ID, BRANCH_ID, "Google Maps", "ChIJ123", "https://maps.google.com", "Maison Q1", "123 Lê Lợi");
        when(supabase.select(eq("review_platforms"), anyMap(), any())).thenReturn(List.of(platform));

        Optional<ReviewPlatform> result = reviewPlatformRepository.findByBranchId(BRANCH_ID);

        assertThat(result).isPresent();
        assertThat(result.get().getPlatformName()).isEqualTo("Google Maps");

        ArgumentCaptor<Map<String, String>> captor = ArgumentCaptor.forClass(Map.class);
        verify(supabase).select(eq("review_platforms"), captor.capture(), any());
        assertThat(captor.getValue()).containsEntry("branch_id", "eq." + BRANCH_ID)
                .containsEntry("is_active", "eq.true");
    }
}

