package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.FeedbackController;
import com.cxshield.backend.dto.FeedbackRequestDto;
import com.cxshield.backend.dto.FeedbackResponseDto;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.FeedbackTopic;
import com.cxshield.backend.entity.FeedbackTopicLink;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.repository.FeedbackRepository;
import com.cxshield.backend.repository.FeedbackTopicLinkRepository;
import com.cxshield.backend.repository.FeedbackTopicRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.service.FeedbackService;
import com.cxshield.backend.service.impl.FeedbackServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.context.ApplicationEventPublisher;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class FeedbackControllerTest {

    private FeedbackRepository feedbackRepository;
    private FeedbackTopicLinkRepository feedbackTopicLinkRepository;
    private SurveyResponseRepository surveyResponseRepository;
    private SurveySessionRepository surveySessionRepository;
    private FeedbackService feedbackService;
    private FeedbackController feedbackController;

    private UUID testSessionId;
    private UUID testResponseId;

    @BeforeEach
    void setUp() {
        feedbackRepository = new FeedbackRepository();
        FeedbackTopicRepository feedbackTopicRepository = new FeedbackTopicRepository();
        feedbackTopicLinkRepository = new FeedbackTopicLinkRepository();
        surveyResponseRepository = new SurveyResponseRepository();
        surveySessionRepository = new SurveySessionRepository();

        // Tạo sẵn phiên & kết quả 2 sao
        SurveySession session = new SurveySession();
        testSessionId = session.getId();
        surveySessionRepository.save(session);

        SurveyResponse response = new SurveyResponse();
        testResponseId = response.getId();
        response.setSessionId(testSessionId);
        response.setStarRating(2);
        response.setSentimentGroup("NEGATIVE");
        surveyResponseRepository.save(response);

        ApplicationEventPublisher mockPublisher = event -> {
            // Mock event publishing
        };

        feedbackService = new FeedbackServiceImpl(
                feedbackRepository,
                feedbackTopicRepository,
                feedbackTopicLinkRepository,
                surveyResponseRepository,
                surveySessionRepository,
                mockPublisher
        );
        feedbackController = new FeedbackController(feedbackService);
    }

    @Test
    @DisplayName("E1.3: Gửi góp ý hợp lệ có SĐT và đồng ý liên hệ -> Lưu bảng feedbacks, chuyển M1-06")
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

        // Kiểm tra đã lưu vào bảng feedbacks
        Optional<Feedback> saved = feedbackRepository.findById(data.getFeedbackId());
        assertTrue(saved.isPresent());
        assertEquals("Nhân viên phục vụ nước uống hơi lâu, cần khắc phục.", saved.get().getCommentText());
        assertEquals("0901234567", saved.get().getCustomerPhone());
        assertNotNull(saved.get().getConsentAt());
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

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            feedbackController.submitFeedback(dto);
        });
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

        assertThrows(IllegalArgumentException.class, () -> {
            feedbackController.submitFeedback(dto);
        });
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

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            feedbackController.submitFeedback(dto);
        });
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

    @Test
    @DisplayName("E1.3: Gửi góp ý kèm chủ đề liên kết (feedback_topic_links)")
    void testSubmitFeedbackWithTopicLinks() {
        UUID topic1 = UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380001");
        UUID topic2 = UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380002");

        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "Món ăn nguội và nhân viên chưa nhiệt tình",
                "0901234567",
                true
        );
        dto.setTopicIds(List.of(topic1, topic2));

        ApiResponse<FeedbackResponseDto> response = feedbackController.submitFeedback(dto);
        assertTrue(response.isSuccess());

        FeedbackResponseDto data = response.getData();
        assertNotNull(data);
        assertEquals(2, data.getTopicIds().size());
        assertTrue(data.getTopicNames().contains("Món ăn / Đồ uống"));
        assertTrue(data.getTopicNames().contains("Thái độ phục vụ"));

        // Kiểm tra lưu vào repository liên kết chủ đề
        List<FeedbackTopicLink> links = feedbackTopicLinkRepository.findByFeedbackId(data.getFeedbackId());
        assertEquals(2, links.size());
        assertEquals("CUSTOMER_SELECT", links.get(0).getSource());
    }

    @Test
    @DisplayName("E1.3: Nội dung ngắn dưới 3 ký tự -> Báo lỗi")
    void testCommentTooShort() {
        FeedbackRequestDto dto = new FeedbackRequestDto(
                testResponseId,
                "ab",
                "0901234567",
                true
        );

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            feedbackController.submitFeedback(dto);
        });
        assertTrue(ex.getMessage().contains("tối thiểu 3 ký tự"));
    }
}

