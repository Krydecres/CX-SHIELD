package com.cxshield.backend.repository;

import com.cxshield.backend.entity.ReviewPlatform;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository("surveyReviewPlatformRepository")
public class ReviewPlatformRepository {
    private final Map<UUID, ReviewPlatform> store = new ConcurrentHashMap<>();
    private final Map<UUID, UUID> branchIndex = new ConcurrentHashMap<>();

    public ReviewPlatformRepository() {
        // Nền tảng Google Maps chính thức của Chi nhánh Quận 1 - Maison Coffee & Bistro
        UUID platformId = UUID.fromString("d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44");
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

        ReviewPlatform googleMaps = new ReviewPlatform(
                platformId,
                branchId,
                "Google Maps",
                "ChIJ1234567890abcdef",
                "https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef",
                "Maison Coffee & Bistro - Đồng Khởi",
                "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh"
        );
        save(googleMaps);
    }

    public ReviewPlatform save(ReviewPlatform platform) {
        store.put(platform.getId(), platform);
        if (platform.getBranchId() != null) {
            branchIndex.put(platform.getBranchId(), platform.getId());
        }
        return platform;
    }

    public Optional<ReviewPlatform> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public Optional<ReviewPlatform> findByBranchId(UUID branchId) {
        if (branchId == null) return Optional.empty();
        UUID platformId = branchIndex.get(branchId);
        if (platformId == null) return Optional.empty();
        return Optional.ofNullable(store.get(platformId));
    }
}
