package com.cxshield.backend.service.impl;

import com.cxshield.backend.dto.PublicBypassRequestDto;
import com.cxshield.backend.dto.PublicBypassResponseDto;
import com.cxshield.backend.dto.RateRequestDto;
import com.cxshield.backend.dto.RateResultDto;
import com.cxshield.backend.dto.SurveyInitResponseDto;
import com.cxshield.backend.entity.Branch;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.repository.BranchRepository;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.repository.ReviewPlatformRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.service.SurveyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.UUID;

@Service
public class SurveyServiceImpl implements SurveyService {
    private static final Logger log = LoggerFactory.getLogger(SurveyServiceImpl.class);

    private final QrCodeRepository qrCodeRepository;
    private final BranchRepository branchRepository;
    private final BusinessRepository businessRepository;
    private final SurveySessionRepository surveySessionRepository;
    private final SurveyResponseRepository surveyResponseRepository;
    private final ReviewPlatformRepository reviewPlatformRepository;

    public SurveyServiceImpl(QrCodeRepository qrCodeRepository,
                             BranchRepository branchRepository,
                             BusinessRepository businessRepository,
                             SurveySessionRepository surveySessionRepository,
                             SurveyResponseRepository surveyResponseRepository,
                             ReviewPlatformRepository reviewPlatformRepository) {
        this.qrCodeRepository = qrCodeRepository;
        this.branchRepository = branchRepository;
        this.businessRepository = businessRepository;
        this.surveySessionRepository = surveySessionRepository;
        this.surveyResponseRepository = surveyResponseRepository;
        this.reviewPlatformRepository = reviewPlatformRepository;
    }

    @Override
    public SurveyInitResponseDto getOrInitSession(String qrCodeValue, String clientIp, String userAgent) {
        log.info("Khách quét mã QR: {}", qrCodeValue);

        // 1. Tìm hoặc fallback mã QR
        QrCode qrCode = qrCodeRepository.findByCode(qrCodeValue)
                .orElseGet(() -> {
                    // Nếu khách quét mã chưa có sẵn trong DB, tự động gắn với chi nhánh mẫu để đảm bảo trải nghiệm tức thì (<1s)
                    UUID defaultBranchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
                    QrCode newQr = new QrCode(
                            UUID.randomUUID(),
                            defaultBranchId,
                            qrCodeValue != null ? qrCodeValue : "DEFAULT",
                            "TABLE",
                            qrCodeValue != null ? "Vị trí " + qrCodeValue : "Bàn trải nghiệm",
                            "ACTIVE"
                    );
                    return qrCodeRepository.save(newQr);
                });

        // 2. Lấy thông tin Chi nhánh & Cơ sở
        Branch branch = branchRepository.findById(qrCode.getBranchId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy chi nhánh cho mã QR này"));
        Business business = businessRepository.findById(branch.getBusinessId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cơ sở kinh doanh"));

        // 3. Tạo survey_session mới ghi nhận lượt quét
        SurveySession session = new SurveySession();
        session.setQrCodeId(qrCode.getId());
        session.setBranchId(branch.getId());
        session.setTableOrAreaCode(qrCode.getName());
        session.setClientIp(clientIp);
        session.setUserAgent(userAgent);
        session.setStatus("STARTED");
        surveySessionRepository.save(session);

        // 4. Trả về DTO hiển thị cho màn hình M1-01
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
        boolean isPositive = stars >= 4;
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
        Branch branch = branchRepository.findById(session.getBranchId()).orElse(null);
        if (branch != null && branch.getHotline() != null) {
            hotline = branch.getHotline();
        }

        // Định tuyến theo quy tắc nghiệp vụ:
        // 4-5 sao -> M1-02 (Google Maps)
        // 1-3 sao -> M1-04 (Form góp ý nội bộ)
        // 1 sao -> M1-05 (Có thể liên hệ hotline hoặc yêu cầu quản lý gọi lại ngay)
        RateResultDto result = new RateResultDto();
        result.setResponseId(response.getId());
        result.setSessionId(session.getId());
        result.setStarRating(stars);
        result.setSentimentGroup(sentimentGroup);
        result.setHotline(hotline);

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

        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
        SurveyResponse response = surveyResponseRepository.findById(requestDto.getResponseId()).orElse(null);

        if (response != null) {
            // E1.4: Cập nhật CSDL survey_responses
            response.setPublicBypass(true);
            response.setRedirectClickedAt(Instant.now());
            response.setUpdatedAt(Instant.now());

            SurveySession session = surveySessionRepository.findById(response.getSessionId()).orElse(null);
            if (session != null && session.getBranchId() != null) {
                branchId = session.getBranchId();
            }

            // Gắn platform Google Maps
            ReviewPlatform platform = reviewPlatformRepository.findByBranchId(branchId).orElse(null);
            if (platform != null) {
                response.setReviewPlatformId(platform.getId());
            }

            surveyResponseRepository.save(response);
            log.info("Khách chọn lối đi đánh giá công khai Google Maps (Response ID: {})", response.getId());
        }

        // Lấy link đánh giá Google Maps của cơ sở
        ReviewPlatform platform = reviewPlatformRepository.findByBranchId(branchId)
                .orElseGet(() -> {
                    UUID platformId = UUID.fromString("d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44");
                    return new ReviewPlatform(
                            platformId,
                            UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22"),
                            "Google Maps",
                            "ChIJ1234567890abcdef",
                            "https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef",
                            "Maison Coffee & Bistro - Đồng Khởi",
                            "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh"
                    );
                });

        return new PublicBypassResponseDto(
                requestDto.getResponseId(),
                true,
                Instant.now(),
                platform.getId(),
                platform.getPlatformName(),
                platform.getReviewDirectUrl(),
                platform.getPlaceName(),
                "Chuyển tiếp tới trang đánh giá công khai Google Maps của cơ sở"
        );
    }

    @Override
    public SurveySession getSession(UUID sessionId) {
        return surveySessionRepository.findById(sessionId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy phiên khảo sát"));
    }
}
