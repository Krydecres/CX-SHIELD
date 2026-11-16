package com.cxshield.backend.service.impl;

import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.*;
import com.cxshield.backend.repository.*;
import com.cxshield.backend.service.SurveyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class SurveyServiceImpl implements SurveyService {

    private static final Logger log = LoggerFactory.getLogger(SurveyServiceImpl.class);

    private final QrCodeRepository qrCodeRepository;
    private final BranchRepository branchRepository;
    private final BusinessRepository businessRepository;
    private final SurveySessionRepository surveySessionRepository;
    private final SurveyResponseRepository surveyResponseRepository;
    private final ReviewPlatformRepository reviewPlatformRepository;
    private final RoutingRuleRepository routingRuleRepository;
    private final ReviewKeywordRepository reviewKeywordRepository;

    public SurveyServiceImpl(
            QrCodeRepository qrCodeRepository,
            BranchRepository branchRepository,
            BusinessRepository businessRepository,
            SurveySessionRepository surveySessionRepository,
            SurveyResponseRepository surveyResponseRepository,
            @Qualifier("surveyReviewPlatformRepository") ReviewPlatformRepository reviewPlatformRepository,
            RoutingRuleRepository routingRuleRepository,
            ReviewKeywordRepository reviewKeywordRepository) {
        this.qrCodeRepository = qrCodeRepository;
        this.branchRepository = branchRepository;
        this.businessRepository = businessRepository;
        this.surveySessionRepository = surveySessionRepository;
        this.surveyResponseRepository = surveyResponseRepository;
        this.reviewPlatformRepository = reviewPlatformRepository;
        this.routingRuleRepository = routingRuleRepository;
        this.reviewKeywordRepository = reviewKeywordRepository;
    }

    @Override
    public SurveyInitResponseDto getOrInitSession(String qrCodeValue, String clientIp, String userAgent) {
        log.info("Khách quét mã QR: {}", qrCodeValue);

        if (qrCodeValue == null || qrCodeValue.trim().isEmpty()) {
            throw new IllegalArgumentException("Mã QR không hợp lệ hoặc bị trống");
        }

        // 1. Tìm mã QR trong CSDL Supabase
        QrCode qrCode = qrCodeRepository.findByCode(qrCodeValue.trim())
                .orElseThrow(() -> new IllegalArgumentException("Mã QR không tồn tại trong hệ thống: " + qrCodeValue));

        // 2. Tìm chi nhánh & cơ sở tương ứng
        Branch branch = branchRepository.findById(qrCode.getBranchId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh cho mã QR này"));
        Business business = businessRepository.findById(branch.getBusinessId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cơ sở kinh doanh"));

        // 3. Tạo survey_session mới ghi nhận lượt quét vào Supabase
        SurveySession session = new SurveySession();
        session.setBusinessId(business.getId());
        session.setBranchId(branch.getId());
        session.setQrCodeId(qrCode.getId());
        session.setTableOrAreaCode(qrCode.getName());
        session.setClientIp(clientIp);
        session.setUserAgent(userAgent);
        surveySessionRepository.save(session);

        // 4. Trả về DTO khởi tạo cho màn hình M1-01
        SurveyInitResponseDto dto = new SurveyInitResponseDto();
        dto.setSessionId(session.getId());
        dto.setQrCode(qrCode.getCode());
        dto.setBusinessName(business.getDisplayName());
        dto.setBranchName(branch.getName());
        dto.setBranchAddress(branch.getAddress());
        dto.setTableOrAreaCode(qrCode.getName());
        dto.setLogoUrl(business.getLogoUrl());
        dto.setPrimaryColor(business.getPrimaryColor());
        dto.setHotline(branch.getHotline());

        return dto;
    }

    @Override
    public RateResultDto submitRating(RateRequestDto requestDto) {
        if (requestDto.getSessionId() == null) {
            throw new IllegalArgumentException("Session ID không được để trống");
        }
        if (requestDto.getStarRating() < 1 || requestDto.getStarRating() > 5) {
            throw new IllegalArgumentException("Đánh giá sao phải từ 1 đến 5");
        }

        SurveySession session = surveySessionRepository.findById(requestDto.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("Phiên khảo sát không tồn tại hoặc đã hết hạn"));

        int stars = requestDto.getStarRating();
        UUID businessId = session.getBusinessId();

        // E4.3: Đọc quy tắc phân luồng cảm xúc theo cơ sở từ routing_rules
        RoutingRule routingRule = routingRuleRepository != null
                ? routingRuleRepository.findByBusinessId(businessId).orElse(new RoutingRule(businessId, 4, 5, true))
                : new RoutingRule(businessId, 4, 5, true);

        boolean isPositive = routingRule.isSatisfied(stars);
        String sentimentGroup = isPositive ? "SATISFIED" : "UNSATISFIED";

        // Cập nhật trạng thái phiên khảo sát về đúng enum session_status: COMPLETED
        session.setStatus("COMPLETED");
        session.setCompletedAt(Instant.now());
        session.setUpdatedAt(Instant.now());
        surveySessionRepository.save(session);

        // Lưu bản ghi kết quả đánh giá survey_responses vào Supabase
        SurveyResponse response = new SurveyResponse();
        response.setBusinessId(session.getBusinessId());
        response.setSessionId(session.getId());
        response.setStarRating(stars);
        response.setSentimentGroup(sentimentGroup);
        response.setRatedAt(Instant.now());
        response.setUpdatedAt(Instant.now());
        surveyResponseRepository.save(response);

        // Lấy hotline chi nhánh nếu có khiếu nại khẩn
        String hotline = null;
        Branch branch = branchRepository.findById(session.getBranchId()).orElse(null);
        if (branch != null && branch.getHotline() != null) {
            hotline = branch.getHotline();
        }

        // E4.3: Lấy danh sách từ khóa gợi ý SEO đang kích hoạt cho màn M1-02
        List<String> keywords = List.of();
        if (reviewKeywordRepository != null) {
            keywords = reviewKeywordRepository.findByBusinessIdAndActiveTrue(businessId)
                    .stream()
                    .map(ReviewKeyword::getKeyword)
                    .collect(Collectors.toList());
        }

        if (keywords.isEmpty()) {
            keywords = List.of(
                    "Cà phê đậm đà ngon",
                    "Không gian ấm cúng, view đẹp",
                    "Nhân viên nhiệt tình, chu đáo",
                    "Phục vụ nhanh chóng"
            );
        }

        RateResultDto result = new RateResultDto();
        result.setResponseId(response.getId());
        result.setSessionId(session.getId());
        result.setStarRating(stars);
        result.setSentimentGroup(sentimentGroup);
        result.setHotline(hotline);
        result.setSuggestedKeywords(keywords);
        result.setPublicReviewEnabled(routingRule.isPublicReviewEnabled());

        if (isPositive) {
            result.setTargetScreen("M1-02");
            result.setAllowUrgentCall(false);
            result.setMessage("Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps.");
            ReviewPlatform platform = reviewPlatformRepository.findByBranchId(session.getBranchId()).orElse(null);
            String reviewUrl = platform != null && platform.getReviewDirectUrl() != null
                    ? platform.getReviewDirectUrl()
                    : "https://maps.google.com";
            result.setGoogleReviewUrl(reviewUrl);
        } else {
            result.setTargetScreen("M1-04");
            result.setAllowUrgentCall(stars == 1);
            result.setMessage(stars == 1
                    ? "Rất tiếc vì bạn chưa hài lòng. Bạn có thể gửi góp ý riêng hoặc gọi trực tiếp quản lý để được hỗ trợ ngay tại bàn."
                    : "Rất tiếc vì trải nghiệm chưa trọn vẹn. Hãy góp ý để chúng tôi cải thiện ngay nhé.");
        }

        return result;
    }

    @Override
    public PublicBypassResponseDto recordPublicBypass(PublicBypassRequestDto requestDto) {
        if (requestDto.getResponseId() == null) {
            throw new IllegalArgumentException("Response ID không được để trống");
        }

        SurveyResponse response = surveyResponseRepository.findById(requestDto.getResponseId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kết quả đánh giá"));

        SurveySession session = surveySessionRepository.findById(response.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiên khảo sát tương ứng"));

        UUID branchId = session.getBranchId();

        // E1.4: Cập nhật CSDL survey_responses
        response.setPublicBypass(true);
        response.setRedirectClickedAt(Instant.now());
        response.setUpdatedAt(Instant.now());

        // Gắn platform Google Maps
        ReviewPlatform platform = reviewPlatformRepository.findByBranchId(branchId).orElse(null);
        if (platform != null) {
            response.setReviewPlatformId(platform.getId());
        }

        surveyResponseRepository.save(response);
        log.info("Khách chọn lối đi đánh giá công khai Google Maps (Response ID: {})", response.getId());

        String reviewUrl = platform != null && platform.getReviewDirectUrl() != null
                ? platform.getReviewDirectUrl()
                : "https://maps.google.com";
        String platformName = platform != null ? platform.getPlatformName() : "Google Maps";
        String placeName = platform != null ? platform.getPlaceName() : "";
        UUID platformId = platform != null ? platform.getId() : null;

        return new PublicBypassResponseDto(
                requestDto.getResponseId(),
                true,
                response.getRedirectClickedAt(),
                platformId,
                platformName,
                reviewUrl,
                placeName,
                "Chuyển tiếp tới trang đánh giá công khai Google Maps của cơ sở"
        );
    }

    @Override
    public SurveySession getSession(UUID sessionId) {
        return surveySessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiên khảo sát"));
    }
}
