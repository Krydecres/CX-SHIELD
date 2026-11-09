package com.cxshield.backend.service.impl;

import com.cxshield.backend.dto.PublicBypassRequestDto;
import com.cxshield.backend.dto.PublicBypassResponseDto;
import com.cxshield.backend.dto.RateRequestDto;
import com.cxshield.backend.dto.RateResultDto;
import com.cxshield.backend.dto.SurveyInitResponseDto;
import com.cxshield.backend.entity.*;
import com.cxshield.backend.repository.*;
import com.cxshield.backend.service.SurveyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    public SurveyServiceImpl(QrCodeRepository qrCodeRepository,
                             BranchRepository branchRepository,
                             BusinessRepository businessRepository,
                             SurveySessionRepository surveySessionRepository,
                             SurveyResponseRepository surveyResponseRepository,
                             @org.springframework.beans.factory.annotation.Qualifier("surveyReviewPlatformRepository") ReviewPlatformRepository reviewPlatformRepository,
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

        // 1. Tìm hoặc fallback mã QR
        QrCode qrCode = qrCodeRepository.findByCode(qrCodeValue)
                .orElseGet(() -> {
                    // Nếu khách quét mã chưa có sẵn trong DB, tự động gắn với chi nhánh mẫu để đảm bảo trải nghiệm tức thì (<1s)
                    QrCode fallback = new QrCode();
                    fallback.setCode(qrCodeValue);
                    fallback.setBranchId(UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22"));
                    fallback.setName("Bàn 04");
                    return qrCodeRepository.save(fallback);
                });

        // 2. Tìm chi nhánh tương ứng
        Branch branch = branchRepository.findById(qrCode.getBranchId())
                .orElseGet(() -> {
                    Branch fallbackBranch = new Branch();
                    fallbackBranch.setId(qrCode.getBranchId());
                    fallbackBranch.setBusinessId(UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"));
                    fallbackBranch.setName("Chi nhánh Quận 1 - Đồng Khởi");
                    fallbackBranch.setAddress("123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh");
                    fallbackBranch.setHotline("02838221122");
                    return branchRepository.save(fallbackBranch);
                });

        // 3. Tìm cơ sở kinh doanh tương ứng
        Business business = businessRepository.findById(branch.getBusinessId())
                .orElseGet(() -> {
                    Business fallbackBiz = new Business();
                    fallbackBiz.setId(branch.getBusinessId());
                    fallbackBiz.setBrandName("Maison Coffee");
                    fallbackBiz.setDisplayName("Maison Coffee & Bistro");
                    fallbackBiz.setPrimaryColor("#2C1810");
                    return businessRepository.save(fallbackBiz);
                });

        // 4. Tạo phiên khảo sát mới trong survey_sessions
        SurveySession session = new SurveySession();
        session.setQrCodeId(qrCode.getId());
        session.setBranchId(branch.getId());
        session.setStartedAt(Instant.now());
        session.setStatus("ACTIVE");
        session.setClientIp(clientIp);
        session.setUserAgent(userAgent);
        surveySessionRepository.save(session);

        // 5. Trả về DTO khởi tạo cho màn hình M1-01
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

        // Lấy chi nhánh và cơ sở tương ứng
        Branch branch = branchRepository.findById(session.getBranchId()).orElse(null);
        UUID businessId = branch != null ? branch.getBusinessId() : null;

        // E4.3: Đọc quy tắc phân luồng cảm xúc theo cơ sở từ routing_rules
        RoutingRule routingRule = routingRuleRepository.findByBusinessId(businessId)
                .orElse(new RoutingRule(businessId, 4, 5, true));

        boolean isPositive = routingRule.isSatisfied(stars);
        String sentimentGroup = isPositive ? "POSITIVE" : "NEGATIVE";

        // Cập nhật trạng thái phiên khảo sát
        session.setStatus("COMPLETED");
        session.setCompletedAt(Instant.now());
        session.setUpdatedAt(Instant.now());
        surveySessionRepository.save(session);

        // Lưu bản ghi kết quả đánh giá survey_responses
        SurveyResponse response = new SurveyResponse();
        response.setSessionId(session.getId());
        response.setStarRating(stars);
        response.setSentimentGroup(sentimentGroup);
        response.setRatedAt(Instant.now());
        surveyResponseRepository.save(response);

        // Lấy hotline chi nhánh nếu có khiếu nại khẩn
        String hotline = "02838221122";
        if (branch != null && branch.getHotline() != null) {
            hotline = branch.getHotline();
        }

        // E4.3: Lấy danh sách từ khóa gợi ý SEO đang kích hoạt cho màn M1-02
        List<String> keywords = reviewKeywordRepository.findByBusinessIdAndActiveTrue(businessId)
                .stream()
                .map(ReviewKeyword::getKeyword)
                .collect(Collectors.toList());

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
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kết quả khảo sát"));

        SurveySession session = surveySessionRepository.findById(response.getSessionId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiên khảo sát tương ứng"));

        ReviewPlatform platform = reviewPlatformRepository.findByBranchId(session.getBranchId())
                .orElseGet(() -> {
                    ReviewPlatform fallback = new ReviewPlatform();
                    fallback.setBranchId(session.getBranchId());
                    fallback.setPlatformName("Google Maps");
                    fallback.setReviewDirectUrl("https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef");
                    fallback.setPlaceName("Maison Coffee & Bistro");
                    fallback.setPlaceAddress("123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh");
                    return fallback;
                });

        response.setPublicBypass(true);
        response.setRedirectClickedAt(Instant.now());
        response.setReviewPlatformId(platform.getId());
        surveyResponseRepository.save(response);

        log.info("Khách chọn lối đi đánh giá công khai Google Maps (Response ID: {})", response.getId());

        PublicBypassResponseDto dto = new PublicBypassResponseDto();
        dto.setResponseId(response.getId());
        dto.setPublicBypass(true);
        dto.setRedirectClickedAt(response.getRedirectClickedAt());
        dto.setReviewPlatformId(platform.getId());
        dto.setPlatformName(platform.getPlatformName());
        dto.setReviewDirectUrl(platform.getReviewDirectUrl());
        dto.setPlaceName(platform.getPlaceName());
        dto.setMessage("Chuyển hướng đến trang đánh giá Google Maps thành công");

        return dto;
    }

    @Override
    public SurveySession getSession(UUID sessionId) {
        return surveySessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiên khảo sát"));
    }
}
