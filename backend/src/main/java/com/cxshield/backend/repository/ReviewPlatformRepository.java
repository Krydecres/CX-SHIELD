package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Truy vấn nền tảng đánh giá review_platforms của chi nhánh qua Supabase (E1.1).
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), sử dụng liên kết Google Maps mẫu trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), truy vấn Supabase thật.
 */
@Repository("surveyReviewPlatformRepository")
public class ReviewPlatformRepository {

    private static final ParameterizedTypeReference<List<ReviewPlatform>> PLATFORM_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, ReviewPlatform> store = new ConcurrentHashMap<>();
    private final Map<UUID, UUID> branchIndex = new ConcurrentHashMap<>();

    public ReviewPlatformRepository() {
        this(null, false);
    }

    public ReviewPlatformRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public ReviewPlatformRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public ReviewPlatformRepository(SupabaseAdminClient supabase, boolean smokeMode) {
        this.supabase = supabase;
        this.smokeMode = smokeMode;
        if (shouldUseStore()) {
            initSmokeData();
        }
    }

    private boolean shouldUseStore() {
        return supabase == null || smokeMode;
    }

    private void initSmokeData() {
        UUID platformId = UUID.fromString("d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44");
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

        ReviewPlatform platform = new ReviewPlatform(
                platformId,
                branchId,
                "Google Maps",
                "ChIJ1234567890abcdef",
                "https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef",
                "Maison Coffee & Bistro - Đồng Khởi",
                "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh"
        );
        putInMemory(platform);
    }

    private void putInMemory(ReviewPlatform platform) {
        store.put(platform.getId(), platform);
        if (platform.getBranchId() != null) {
            branchIndex.put(platform.getBranchId(), platform.getId());
        }
    }

    public Optional<ReviewPlatform> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("review_platforms", Map.of("id", "eq." + id), PLATFORM_ROWS)
                .stream()
                .findFirst();
    }

    public Optional<ReviewPlatform> findByBranchId(UUID branchId) {
        if (branchId == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            UUID platformId = branchIndex.get(branchId);
            if (platformId == null) return Optional.empty();
            return Optional.ofNullable(store.get(platformId));
        }
        return supabase.select("review_platforms", Map.of("branch_id", "eq." + branchId, "is_active", "eq.true"), PLATFORM_ROWS)
                .stream()
                .findFirst();
    }

    public ReviewPlatform save(ReviewPlatform platform) {
        if (platform.getId() == null) {
            platform.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            putInMemory(platform);
            return platform;
        }
        supabase.upsert("review_platforms", "id", platform);
        return platform;
    }
}
