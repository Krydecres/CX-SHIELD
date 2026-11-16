package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.service.SurveyService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/surveys")
public class SurveyController {

    private final SurveyService surveyService;

    public SurveyController(SurveyService surveyService) {
        this.surveyService = surveyService;
    }

    /**
     * E1.1 - Quét mã QR mở trang khảo sát (< 1s)
     * Nhận diện chi nhánh, vị trí bàn và tạo survey_session
     */
    @GetMapping("/qr/{code}")
    public ApiResponse<SurveyInitResponseDto> scanQr(
            @PathVariable("code") String code,
            HttpServletRequest request) {
        String clientIp = request.getRemoteAddr();
        String userAgent = request.getHeader("User-Agent");

        SurveyInitResponseDto result = surveyService.getOrInitSession(code, clientIp, userAgent);
        return ApiResponse.success("Khởi tạo khảo sát thành công", result);
    }

    /**
     * E1.1 - Đánh giá 1 - 5 sao
     * Phân luồng cảm xúc: 4-5 sao -> M1-02, 1-3 sao -> M1-04 (1 sao có M1-05)
     */
    @PostMapping("/rate")
    public ApiResponse<RateResultDto> submitRating(@RequestBody RateRequestDto requestDto) {
        RateResultDto result = surveyService.submitRating(requestDto);
        return ApiResponse.success("Ghi nhận đánh giá thành công", result);
    }

    /**
     * E1.2 - Chuyển tiếp khách hài lòng (4-5 sao) sang Google Maps
     * Ghi nhận redirect_clicked_at và trả về link viết đánh giá Google của cơ sở (tạo từ Place ID)
     */
    @PostMapping("/google-redirect")
    public ApiResponse<GoogleRedirectResponseDto> recordGoogleRedirect(@RequestBody GoogleRedirectRequestDto requestDto) {
        GoogleRedirectResponseDto result = surveyService.recordGoogleRedirect(requestDto);
        return ApiResponse.success("Ghi nhận chuyển hướng đánh giá Google Maps thành công", result);
    }

    /**
     * E1.4 - Lối đi đánh giá công khai cho khách 1-3 sao (Chống lọc đánh giá - review gating)
     * Cập nhật is_public_bypass = true, redirect_clicked_at = now() và trả về link Google Maps
     */
    @PostMapping("/public-review")
    public ApiResponse<PublicBypassResponseDto> recordPublicBypass(@RequestBody PublicBypassRequestDto requestDto) {
        PublicBypassResponseDto result = surveyService.recordPublicBypass(requestDto);
        return ApiResponse.success("Ghi nhận chuyển hướng đánh giá công khai thành công", result);
    }

    /**
     * Lấy thông tin phiên khảo sát
     */
    @GetMapping("/session/{sessionId}")
    public ApiResponse<SurveySession> getSession(@PathVariable("sessionId") UUID sessionId) {
        SurveySession session = surveyService.getSession(sessionId);
        return ApiResponse.success(session);
    }
}
