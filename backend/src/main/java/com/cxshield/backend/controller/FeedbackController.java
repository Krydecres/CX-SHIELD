package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.FeedbackRequestDto;
import com.cxshield.backend.dto.FeedbackResponseDto;
import com.cxshield.backend.entity.FeedbackTopic;
import com.cxshield.backend.service.FeedbackService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/feedbacks")
public class FeedbackController {

    private final FeedbackService feedbackService;

    public FeedbackController(FeedbackService feedbackService) {
        this.feedbackService = feedbackService;
    }

    /**
     * E1.3: Gửi form góp ý riêng tư nội bộ (1-3 sao)
     * Lưu vào feedbacks, phát sự kiện cảnh báo E2.2, điều hướng sang M1-06
     */
    @PostMapping
    public ApiResponse<FeedbackResponseDto> submitFeedback(@RequestBody FeedbackRequestDto requestDto) {
        FeedbackResponseDto response = feedbackService.submitFeedback(requestDto);
        return ApiResponse.success("Gửi góp ý thành công", response);
    }

    /**
     * Lấy danh sách các chủ đề góp ý phục vụ gợi ý trên form
     */
    @GetMapping("/topics")
    public ApiResponse<List<FeedbackTopic>> getTopics() {
        List<FeedbackTopic> topics = feedbackService.getActiveTopics();
        return ApiResponse.success(topics);
    }
}

