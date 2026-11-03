package com.cxshield.backend.service;

import com.cxshield.backend.dto.FeedbackRequestDto;
import com.cxshield.backend.dto.FeedbackResponseDto;
import com.cxshield.backend.entity.FeedbackTopic;

import java.util.List;

public interface FeedbackService {
    /**
     * Tiếp nhận góp ý nội bộ từ khách (1-3 sao)
     * Lưu vào feedbacks, phát sự kiện cảnh báo E2.2, chuyển sang M1-06
     */
    FeedbackResponseDto submitFeedback(FeedbackRequestDto dto);

    /**
     * Lấy danh sách các chủ đề góp ý đang hoạt động
     */
    List<FeedbackTopic> getActiveTopics();
}

