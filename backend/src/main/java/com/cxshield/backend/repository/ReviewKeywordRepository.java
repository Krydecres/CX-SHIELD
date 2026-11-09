package com.cxshield.backend.repository;

import com.cxshield.backend.entity.ReviewKeyword;
import org.springframework.stereotype.Repository;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Repository
public class ReviewKeywordRepository {
    private final Map<UUID, ReviewKeyword> store = new ConcurrentHashMap<>();

    public ReviewKeywordRepository() {
        // Khởi tạo các từ khóa mặc định cho cơ sở mẫu "Maison Coffee & Bistro"
        UUID maisonId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        List<String> defaultKeywords = List.of(
                "Cà phê đậm đà ngon",
                "Không gian ấm cúng, view đẹp",
                "Nhân viên nhiệt tình, chu đáo",
                "Phục vụ nhanh chóng",
                "Đồ uống đa dạng, decor xinh",
                "Nhạc nhẹ nhàng, thư giãn"
        );
        for (String kw : defaultKeywords) {
            ReviewKeyword keyword = new ReviewKeyword(null, maisonId, "F&B", kw, true);
            store.put(keyword.getId(), keyword);
        }
    }

    public ReviewKeyword save(ReviewKeyword keyword) {
        if (keyword.getId() == null) {
            keyword.setId(UUID.randomUUID());
        }
        store.put(keyword.getId(), keyword);
        return keyword;
    }

    public List<ReviewKeyword> saveAll(List<ReviewKeyword> keywords) {
        keywords.forEach(this::save);
        return keywords;
    }

    public Optional<ReviewKeyword> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public List<ReviewKeyword> findByBusinessId(UUID businessId) {
        return store.values().stream()
                .filter(k -> Objects.equals(k.getBusinessId(), businessId))
                .sorted(Comparator.comparing(ReviewKeyword::getCreatedAt))
                .collect(Collectors.toList());
    }

    public List<ReviewKeyword> findByBusinessIdAndActiveTrue(UUID businessId) {
        return store.values().stream()
                .filter(k -> Objects.equals(k.getBusinessId(), businessId) && k.isActive())
                .sorted(Comparator.comparing(ReviewKeyword::getCreatedAt))
                .collect(Collectors.toList());
    }

    public List<ReviewKeyword> findByBusinessIdAndIndustry(UUID businessId, String industry) {
        return store.values().stream()
                .filter(k -> Objects.equals(k.getBusinessId(), businessId)
                        && (industry == null || industry.equalsIgnoreCase(k.getIndustry())))
                .sorted(Comparator.comparing(ReviewKeyword::getCreatedAt))
                .collect(Collectors.toList());
    }

    public boolean deleteById(UUID id) {
        return store.remove(id) != null;
    }

    public void deleteByBusinessId(UUID businessId) {
        store.entrySet().removeIf(entry -> Objects.equals(entry.getValue().getBusinessId(), businessId));
    }

    public long countByBusinessId(UUID businessId) {
        return store.values().stream()
                .filter(k -> Objects.equals(k.getBusinessId(), businessId))
                .count();
    }
}
