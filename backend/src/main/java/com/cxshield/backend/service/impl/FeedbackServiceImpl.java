package com.cxshield.backend.service.impl;

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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

@Service
public class FeedbackServiceImpl implements FeedbackService {
    private static final Logger log = LoggerFactory.getLogger(FeedbackServiceImpl.class);

    // Regex kiểm tra số điện thoại Việt Nam (10 số, đầu 03, 05, 07, 08, 09 hoặc +84)
    private static final Pattern VN_PHONE_PATTERN = Pattern.compile("^(0|\\+84)(3|5|7|8|9)[0-9]{8}$");

    private final FeedbackRepository feedbackRepository;
    private final FeedbackTopicRepository feedbackTopicRepository;
    private final SurveyResponseRepository surveyResponseRepository;
    private final SurveySessionRepository surveySessionRepository;
    private final ApplicationEventPublisher eventPublisher;

    public FeedbackServiceImpl(FeedbackRepository feedbackRepository,
                               FeedbackTopicRepository feedbackTopicRepository,
                               SurveyResponseRepository surveyResponseRepository,
                               SurveySessionRepository surveySessionRepository,
                               ApplicationEventPublisher eventPublisher) {
        this.feedbackRepository = feedbackRepository;
        this.feedbackTopicRepository = feedbackTopicRepository;
        this.surveyResponseRepository = surveyResponseRepository;
        this.surveySessionRepository = surveySessionRepository;
        this.eventPublisher = eventPublisher;
    }

    @Override
    public FeedbackResponseDto submitFeedback(FeedbackRequestDto dto) {
        // 1. Kiểm tra responseId
        if (dto.getResponseId() == null) {
            throw new IllegalArgumentException("Mã kết quả đánh giá (responseId) không được để trống");
        }

        // 2. Kiểm tra nội dung góp ý (Bắt buộc, 5 - 1000 ký tự)
        if (dto.getCommentText() == null || dto.getCommentText().trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung góp ý không được để trống");
        }
        String comment = dto.getCommentText().trim();
        if (comment.length() < 3) {
            throw new IllegalArgumentException("Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)");
        }
        if (comment.length() > 1000) {
            throw new IllegalArgumentException("Nội dung góp ý không được vượt quá 1000 ký tự");
        }

        // 3. Kiểm tra số điện thoại liên hệ (Không bắt buộc, nhưng nếu có phải đúng chuẩn VN)
        String phone = null;
        if (dto.getCustomerPhone() != null && !dto.getCustomerPhone().trim().isEmpty()) {
            String sanitizedPhone = dto.getCustomerPhone().trim().replaceAll("[\\s.-]", "");
            if (!VN_PHONE_PATTERN.matcher(sanitizedPhone).matches()) {
                throw new IllegalArgumentException("Số điện thoại không đúng định dạng Việt Nam (ví dụ: 0901234567 hoặc +84901234567)");
            }
            phone = sanitizedPhone;
        }

        // 4. Lấy thông tin đánh giá gốc để trích xuất branchId & starRating
        int starRating = 2; // Mặc định trong nhóm 1-3 sao
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

        SurveyResponse response = surveyResponseRepository.findById(dto.getResponseId()).orElse(null);
        if (response != null) {
            starRating = response.getStarRating();
            SurveySession session = surveySessionRepository.findById(response.getSessionId()).orElse(null);
            if (session != null && session.getBranchId() != null) {
                branchId = session.getBranchId();
            }
        }

        // 5. Khởi tạo và lưu thực thể Feedback
        Feedback feedback = new Feedback();
        feedback.setResponseId(dto.getResponseId());
        feedback.setCommentText(comment);
        feedback.setCustomerPhone(phone);
        feedback.setContactPurpose("CUSTOMER_CARE");
        if (dto.isConsentToContact()) {
            feedback.setConsentAt(Instant.now());
        }

        boolean isUrgent = dto.isUrgentCallback() || starRating == 1;
        feedback.setUrgentCallback(isUrgent);
        feedback.setUrgencyLevel(isUrgent ? 3 : 1);
        feedback.setStatus("NEW");

        feedbackRepository.save(feedback);

        // Tuân thủ quy ước: KHÔNG ghi SĐT và nội dung ra log, chỉ log ID
        log.info("Đã lưu thành công góp ý nội bộ ID: {} cho Response ID: {}", feedback.getId(), dto.getResponseId());

        // 6. Phát sự kiện để E2.2 gửi cảnh báo (Telegram / Zalo / Email)
        eventPublisher.publishEvent(new FeedbackCreatedEvent(
                feedback.getId(),
                dto.getResponseId(),
                branchId,
                starRating,
                isUrgent,
                phone != null
        ));

        // 7. Trả về kết quả điều hướng sang màn hình cảm ơn M1-06
        return new FeedbackResponseDto(
                feedback.getId(),
                feedback.getResponseId(),
                feedback.getStatus(),
                "M1-06",
                "Góp ý của bạn đã được gửi trực tiếp tới Ban Quản lý. Chúng tôi xin chân thành cảm ơn!",
                feedback.getSubmittedAt()
        );
    }

    @Override
    public List<FeedbackTopic> getActiveTopics() {
        return feedbackTopicRepository.findAllActive();
    }
}

