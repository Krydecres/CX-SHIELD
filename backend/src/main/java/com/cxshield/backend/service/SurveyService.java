package com.cxshield.backend.service;

import com.cxshield.backend.dto.PublicBypassRequestDto;
import com.cxshield.backend.dto.PublicBypassResponseDto;
import com.cxshield.backend.dto.RateRequestDto;
import com.cxshield.backend.dto.RateResultDto;
import com.cxshield.backend.dto.SurveyInitResponseDto;
import com.cxshield.backend.entity.SurveySession;

import java.util.UUID;

public interface SurveyService {
    /**
     * Nhận diện chi nhánh, bàn từ mã QR và khởi tạo survey_session (< 1s)
     */
    SurveyInitResponseDto getOrInitSession(String qrCode, String clientIp, String userAgent);

    /**
     * Lưu kết quả đánh giá 1-5 sao và phân luồng cảm xúc:
     * 4-5 sao -> M1-02 (Google Maps)
     * 1-3 sao -> M1-04 (Góp ý nội bộ), riêng 1 sao hỗ trợ M1-05 (Hotline khẩn)
     */
    RateResultDto submitRating(RateRequestDto requestDto);

    /**
     * E1.4: Ghi nhận lối đi đánh giá công khai (Chống review gating)
     * Cập nhật survey_responses: is_public_bypass = true, redirect_clicked_at = now()
     * Trả về đường link đánh giá Google Maps chính thức của cơ sở
     */
    PublicBypassResponseDto recordPublicBypass(PublicBypassRequestDto requestDto);

    /**
     * Lấy thông tin session
     */
    SurveySession getSession(UUID sessionId);
}
