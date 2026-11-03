package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.FeedbackController;
import com.cxshield.backend.dto.FeedbackRequestDto;
import com.cxshield.backend.dto.FeedbackResponseDto;
import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.entity.FeedbackTopic;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.repository.FeedbackRepository;
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
}

