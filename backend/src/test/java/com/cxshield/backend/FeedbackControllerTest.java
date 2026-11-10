package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.FeedbackController;
import com.cxshield.backend.dto.FeedbackRequestDto;
import com.cxshield.backend.dto.FeedbackResponseDto;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.FeedbackTopic;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.event.FeedbackCreatedEvent;
import com.cxshield.backend.repository.FeedbackRepository;
import com.cxshield.backend.repository.FeedbackTopicRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.service.FeedbackService;
import com.cxshield.backend.service.impl.FeedbackServiceImpl;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class FeedbackControllerTest {

    private static final UUID BUSINESS_ID = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
    private static final UUID BRANCH_ID = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

    private SupabaseAdminClient supabase;
    private FeedbackRepository feedbackRepository;
    private SurveyResponseRepository surveyResponseRepository;
    private SurveySessionRepository surveySessionRepository;
    private FeedbackService feedbackService;
    private FeedbackController feedbackController;
    private ApplicationEventPublisher eventPublisher;

    private UUID testSessionId;
    private UUID testResponseId;
    private final Map<UUID, Feedback> feedbackStore = new ConcurrentHashMap<>();

    @BeforeEach
    void setUp() {
        supabase = mock(SupabaseAdminClient.class);
        eventPublisher = mock(ApplicationEventPublisher.class);
        feedbackStore.clear();

        // 1. Tạo phiên khảo sát có business_id và branch_id
        SurveySession session = new SurveySession();
        testSessionId = session.getId();
        session.setBusinessId(BUSINESS_ID);
        session.setBranchId(BRANCH_ID);
        session.setTableOrAreaCode("Bàn 04");

        when(supabase.select(eq("survey_sessions"), argThat(m -> ("eq." + testSessionId).equals(m.get("id"))), any()))
                .thenReturn(List.of(session));

        // 2. Tạo kết quả đánh giá 2 sao có business_id và sentiment_group UNSATISFIED
        SurveyResponse response = new SurveyResponse();
        testResponseId = response.getId();
        response.setBusinessId(BUSINESS_ID);
        response.setSessionId(testSessionId);
        response.setStarRating(2);
        response.setSentimentGroup("UNSATISFIED");

        when(supabase.select(eq("survey_responses"), argThat(m -> ("eq." + testResponseId).equals(m.get("id"))), any()))
                .thenReturn(List.of(response));

        // 3. Mock lưu feedback vào Supabase
        doAnswer(invocation -> {
            Feedback f = invocation.getArgument(2);
            feedbackStore.put(f.getId(), f);
            return null;
        }).when(supabase).upsert(eq("feedbacks"), eq("id"), any(Feedback.class));

        when(supabase.select(eq("feedbacks"), anyMap(), any())).thenAnswer(invocation -> {
            Map<String, String> query = invocation.getArgument(1);
            String idVal = query.get("id");
            if (idVal != null && idVal.startsWith("eq.")) {
                UUID id = UUID.fromString(idVal.substring(3));
                Feedback f = feedbackStore.get(id);
                return f != null ? List.of(f) : List.of();
            }
            return List.of();
        });

        feedbackRepository = new FeedbackRepository(supabase);
        FeedbackTopicRepository feedbackTopicRepository = new FeedbackTopicRepository();
        surveyResponseRepository = new SurveyResponseRepository(supabase);
        surveySessionRepository = new SurveySessionRepository(supabase);

        feedbackService = new FeedbackServiceImpl(
                feedbackRepository,
                feedbackTopicRepository,
                surveyResponseRepository,
                surveySessionRepository,
                eventPublisher
        );
        feedbackController = new FeedbackController(feedbackService);
    }

    @Test
    @DisplayName("E1.3: Gửi góp ý hợp lệ có SĐT và đồng ý liên hệ -> Lưu Supabase với business_id, phát event cảnh báo chi nhánh thật, chuyển M1-06")
    void testSubmitValidFeedbackWithPhone() {
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "Nhân viên phục vụ nước uống hơi lâu, cần khắc phục.",
                "0901234567",
                true
        );

        ApiResponse<FeedbackResponseDto> response = feedbackController.submitFeedback(dto);

        assertTrue(response.isSuccess());
        FeedbackResponseDto data = response.getData();
        assertNotNull(data);
        assertNotNull(data.getFeedbackId());
        assertEquals("M1-06", data.getTargetScreen());

        // Kiểm tra đã lưu vào bảng feedbacks trên Supabase kèm business_id & branch_id
        Optional<Feedback> saved = feedbackRepository.findById(data.getFeedbackId());
        assertTrue(saved.isPresent());
        assertEquals(BUSINESS_ID, saved.get().getBusinessId());
        assertEquals(BRANCH_ID, saved.get().getBranchId());
        assertEquals("Nhân viên phục vụ nước uống hơi lâu, cần khắc phục.", saved.get().getCommentText());
        assertEquals("0901234567", saved.get().getCustomerPhone());
        assertNotNull(saved.get().getConsentAt());

        // Kiểm tra phát sự kiện FeedbackCreatedEvent có branchId thật
        ArgumentCaptor<FeedbackCreatedEvent> captor = ArgumentCaptor.forClass(FeedbackCreatedEvent.class);
        verify(eventPublisher).publishEvent(captor.capture());
        FeedbackCreatedEvent event = captor.getValue();
        assertEquals(BRANCH_ID, event.getBranchId());
        assertEquals(2, event.getStarRating());
        assertTrue(event.isHasPhone());
    }

    @Test
    @DisplayName("E1.3: Gửi góp ý hợp lệ không có SĐT (không bắt buộc) -> Thành công, chuyển M1-06")
    void testSubmitValidFeedbackWithoutPhone() {
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "Không gian hơi ồn ào vào giờ trưa.",
                null,
                false
        );

        ApiResponse<FeedbackResponseDto> response = feedbackController.submitFeedback(dto);

        assertTrue(response.isSuccess());
        assertEquals("M1-06", response.getData().getTargetScreen());

        Optional<Feedback> saved = feedbackRepository.findById(response.getData().getFeedbackId());
        assertTrue(saved.isPresent());
        assertEquals(BUSINESS_ID, saved.get().getBusinessId());
        assertNull(saved.get().getCustomerPhone());
        assertNull(saved.get().getConsentAt());
    }

    @Test
    @DisplayName("E1.3: SĐT sai định dạng Việt Nam -> Báo lỗi")
    void testInvalidVietnamesePhone() {
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "Món ăn nguội.",
                "0123456", // Không hợp lệ
                true
        );

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                feedbackController.submitFeedback(dto));
        assertTrue(ex.getMessage().contains("Số điện thoại không đúng định dạng"));
    }

    @Test
    @DisplayName("E1.3: Nội dung góp ý để trống -> Báo lỗi bắt buộc")
    void testEmptyCommentText() {
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "   ",
                "0901234567",
                true
        );

        assertThrows(IllegalArgumentException.class, () ->
                feedbackController.submitFeedback(dto));
    }

    @Test
    @DisplayName("E1.3: Nội dung vượt quá 1000 ký tự -> Báo lỗi giới hạn")
    void testCommentTextTooLong() {
        String longComment = "a".repeat(1005);
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                longComment,
                "0901234567",
                true
        );

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () ->
                feedbackController.submitFeedback(dto));
        assertTrue(ex.getMessage().contains("1000 ký tự"));
    }

    @Test
    @DisplayName("E1.3: Lấy danh sách chủ đề góp ý (topics)")
    void testGetTopics() {
        ApiResponse<List<FeedbackTopic>> response = feedbackController.getTopics();
        assertTrue(response.isSuccess());
        assertNotNull(response.getData());
        assertFalse(response.getData().isEmpty());
    }
}
