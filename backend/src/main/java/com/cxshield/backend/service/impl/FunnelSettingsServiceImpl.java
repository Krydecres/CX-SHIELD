package com.cxshield.backend.service.impl;

import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.ReviewKeyword;
import com.cxshield.backend.entity.RoutingRule;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.ReviewKeywordRepository;
import com.cxshield.backend.repository.RoutingRuleRepository;
import com.cxshield.backend.service.FunnelSettingsService;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class FunnelSettingsServiceImpl implements FunnelSettingsService {

    private final ReviewKeywordRepository keywordRepository;
    private final RoutingRuleRepository routingRuleRepository;
    private final BusinessRepository businessRepository;

    private static final List<IndustryTemplateDto> TEMPLATES = List.of(
            new IndustryTemplateDto(
                    "F&B",
                    "Ẩm thực & Đồ uống (F&B)",
                    List.of(
                            "Cà phê đậm đà ngon",
                            "Không gian ấm cúng, view đẹp",
                            "Nhân viên nhiệt tình, chu đáo",
                            "Phục vụ nhanh chóng",
                            "Đồ uống đa dạng, decor xinh",
                            "Nhạc nhẹ nhàng, thư giãn"
                    )
            ),
            new IndustryTemplateDto(
                    "NHA_KHOA",
                    "Nha khoa & Y tế",
                    List.of(
                            "Bác sĩ tận tâm, tay nghề cao",
                            "Cơ sở hiện đại, vô trùng sạch sẽ",
                            "Khám kỹ lưỡng, tư vấn nhiệt tình",
                            "Không đau, nhẹ nhàng",
                            "Chi phí rõ ràng, minh bạch",
                            "Đặt lịch nhanh, không phải chờ"
                    )
            ),
            new IndustryTemplateDto(
                    "SPA",
                    "Spa & Thẩm mỹ viện",
                    List.of(
                            "Tay nghề kỹ thuật viên rất tốt",
                            "Không gian thư giãn, mùi hương dễ chịu",
                            "Da cải thiện rõ rệt sau liệu trình",
                            "Tư vấn đúng nhu cầu, không chèo kéo",
                            "Dịch vụ 5 sao chu đáo",
                            "Mỹ phẩm chính hãng cao cấp"
                    )
            ),
            new IndustryTemplateDto(
                    "KHACH_SAN",
                    "Khách sạn & Lưu trú",
                    List.of(
                            "Phòng ốc sạch sẽ, tiện nghi",
                            "Vị trí thuận tiện đi lại",
                            "Lễ tân thân thiện, hỗ trợ 24/7",
                            "Bữa sáng ngon miệng, phong phú",
                            "View ban công tuyệt đẹp",
                            "Thủ tục check-in nhanh gọn"
                    )
            ),
            new IndustryTemplateDto(
                    "KHAC",
                    "Dịch vụ tổng hợp",
                    List.of(
                            "Chất lượng dịch vụ tuyệt vời",
                            "Hỗ trợ khách hàng rất nhanh",
                            "Nhân viên chuyên nghiệp",
                            "Giá cả cạnh tranh, xứng đáng",
                            "Sẽ tiếp tục ủng hộ và giới thiệu bạn bè"
                    )
            )
    );

    public FunnelSettingsServiceImpl(
            ReviewKeywordRepository keywordRepository,
            RoutingRuleRepository routingRuleRepository,
            BusinessRepository businessRepository
    ) {
        this.keywordRepository = keywordRepository;
        this.routingRuleRepository = routingRuleRepository;
        this.businessRepository = businessRepository;
    }

    @Override
    public List<ReviewKeywordDto> getKeywords(UUID businessId, String industry) {
        if (businessId == null) {
            throw new IllegalArgumentException("Mã cơ sở không được để trống");
        }
        List<ReviewKeyword> list = (industry != null && !industry.isBlank())
                ? keywordRepository.findByBusinessIdAndIndustry(businessId, industry)
                : keywordRepository.findByBusinessId(businessId);

        return list.stream().map(this::toKeywordDto).collect(Collectors.toList());
    }

    @Override
    public ReviewKeywordDto addKeyword(UUID businessId, CreateKeywordRequestDto request) {
        if (businessId == null) {
            throw new IllegalArgumentException("Mã cơ sở không được để trống");
        }
        if (request == null || request.keyword() == null || request.keyword().trim().isEmpty()) {
            throw new IllegalArgumentException("Nội dung từ khóa không được để trống");
        }

        String industry = (request.industry() != null && !request.industry().isBlank())
                ? request.industry().trim()
                : resolveBusinessIndustry(businessId);

        ReviewKeyword keyword = new ReviewKeyword(
                null,
                businessId,
                industry,
                request.keyword().trim(),
                true
        );

        ReviewKeyword saved = keywordRepository.save(keyword);
        return toKeywordDto(saved);
    }

    @Override
    public ReviewKeywordDto updateKeyword(UUID businessId, UUID keywordId, UpdateKeywordRequestDto request) {
        if (businessId == null || keywordId == null) {
            throw new IllegalArgumentException("Mã cơ sở và mã từ khóa không được để trống");
        }
        ReviewKeyword existing = keywordRepository.findById(keywordId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy từ khóa ID: " + keywordId));

        if (!Objects.equals(existing.getBusinessId(), businessId)) {
            throw new IllegalArgumentException("Từ khóa không thuộc cơ sở này");
        }

        if (request.keyword() != null && !request.keyword().trim().isEmpty()) {
            existing.setKeyword(request.keyword().trim());
        }
        if (request.active() != null) {
            existing.setActive(request.active());
        }
        existing.setUpdatedAt(Instant.now());

        ReviewKeyword saved = keywordRepository.save(existing);
        return toKeywordDto(saved);
    }

    @Override
    public void deleteKeyword(UUID businessId, UUID keywordId) {
        if (businessId == null || keywordId == null) {
            throw new IllegalArgumentException("Mã cơ sở và mã từ khóa không được để trống");
        }
        ReviewKeyword existing = keywordRepository.findById(keywordId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy từ khóa ID: " + keywordId));

        if (!Objects.equals(existing.getBusinessId(), businessId)) {
            throw new IllegalArgumentException("Từ khóa không thuộc cơ sở này");
        }

        keywordRepository.deleteById(keywordId);
    }

    @Override
    public List<ReviewKeywordDto> applyIndustryTemplate(UUID businessId, String industry) {
        if (businessId == null) {
            throw new IllegalArgumentException("Mã cơ sở không được để trống");
        }
        String ind = (industry != null && !industry.isBlank()) ? industry : "F&B";
        IndustryTemplateDto template = TEMPLATES.stream()
                .filter(t -> t.industry().equalsIgnoreCase(ind))
                .findFirst()
                .orElse(TEMPLATES.getFirst());

        // Xóa các từ khóa cũ của cơ sở
        keywordRepository.deleteByBusinessId(businessId);

        List<ReviewKeyword> created = new ArrayList<>();
        for (String kw : template.keywords()) {
            ReviewKeyword entity = new ReviewKeyword(null, businessId, template.industry(), kw, true);
            created.add(keywordRepository.save(entity));
        }

        return created.stream().map(this::toKeywordDto).collect(Collectors.toList());
    }

    @Override
    public RoutingRuleDto getRoutingRule(UUID businessId) {
        if (businessId == null) {
            throw new IllegalArgumentException("Mã cơ sở không được để trống");
        }
        RoutingRule rule = routingRuleRepository.findByBusinessId(businessId)
                .orElseGet(() -> {
                    RoutingRule fallback = new RoutingRule(businessId, 4, 5, true);
                    return routingRuleRepository.save(fallback);
                });
        return toRoutingRuleDto(rule);
    }

    @Override
    public RoutingRuleDto updateRoutingRule(UUID businessId, UpdateRoutingRuleRequestDto request) {
        if (businessId == null) {
            throw new IllegalArgumentException("Mã cơ sở không được để trống");
        }
        if (request == null) {
            throw new IllegalArgumentException("Dữ liệu cập nhật quy tắc không hợp lệ");
        }

        RoutingRule existing = routingRuleRepository.findByBusinessId(businessId)
                .orElseGet(() -> new RoutingRule(businessId, 4, 5, true));

        if (request.satisfiedMinScore() != null) {
            int min = request.satisfiedMinScore();
            if (min < 1 || min > 5) {
                throw new IllegalArgumentException("Điểm sao tối thiểu phải từ 1 đến 5");
            }
            existing.setSatisfiedMinScore(min);
        }

        if (request.satisfiedMaxScore() != null) {
            int max = request.satisfiedMaxScore();
            if (max < 1 || max > 5) {
                throw new IllegalArgumentException("Điểm sao tối đa phải từ 1 đến 5");
            }
            if (max < existing.getSatisfiedMinScore()) {
                throw new IllegalArgumentException("Điểm sao tối đa không thể nhỏ hơn điểm sao tối thiểu");
            }
            existing.setSatisfiedMaxScore(max);
        }

        if (request.publicReviewEnabled() != null) {
            existing.setPublicReviewEnabled(request.publicReviewEnabled());
        }

        existing.setUpdatedAt(Instant.now());
        RoutingRule saved = routingRuleRepository.save(existing);
        return toRoutingRuleDto(saved);
    }

    @Override
    public List<IndustryTemplateDto> getIndustryTemplates() {
        return TEMPLATES;
    }

    @Override
    public List<String> getActiveKeywordsForSurvey(UUID businessId) {
        if (businessId == null) {
            return TEMPLATES.getFirst().keywords();
        }
        List<ReviewKeyword> list = keywordRepository.findByBusinessIdAndActiveTrue(businessId);
        if (list.isEmpty()) {
            return TEMPLATES.getFirst().keywords();
        }
        return list.stream().map(ReviewKeyword::getKeyword).collect(Collectors.toList());
    }

    @Override
    public RoutingRule getRoutingRuleEntity(UUID businessId) {
        return routingRuleRepository.findByBusinessId(businessId)
                .orElse(new RoutingRule(businessId, 4, 5, true));
    }

    private String resolveBusinessIndustry(UUID businessId) {
        return businessRepository.findById(businessId)
                .map(Business::getIndustry)
                .filter(ind -> ind != null && !ind.isBlank())
                .orElse("F&B");
    }

    private ReviewKeywordDto toKeywordDto(ReviewKeyword k) {
        return new ReviewKeywordDto(
                k.getId(),
                k.getBusinessId(),
                k.getIndustry(),
                k.getKeyword(),
                k.isActive(),
                k.getCreatedAt(),
                k.getUpdatedAt()
        );
    }

    private RoutingRuleDto toRoutingRuleDto(RoutingRule r) {
        return new RoutingRuleDto(
                r.getId(),
                r.getBusinessId(),
                r.getSatisfiedMinScore(),
                r.getSatisfiedMaxScore(),
                r.isPublicReviewEnabled(),
                r.getCreatedAt(),
                r.getUpdatedAt()
        );
    }
}

