package com.cxshield.backend.repository;

import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Truy vấn nền tảng đánh giá review_platforms của chi nhánh qua Supabase (E1.1).
 * Không nạp liên kết cứng mẫu.
 */
@Repository("surveyReviewPlatformRepository")
public class ReviewPlatformRepository {

    private static final ParameterizedTypeReference<List<ReviewPlatform>> PLATFORM_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public ReviewPlatformRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<ReviewPlatform> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("review_platforms", Map.of("id", "eq." + id), PLATFORM_ROWS)
                .stream()
                .findFirst();
    }

    public Optional<ReviewPlatform> findByBranchId(UUID branchId) {
        if (branchId == null) {
            return Optional.empty();
        }
        return supabase.select("review_platforms", Map.of("branch_id", "eq." + branchId, "is_active", "eq.true"), PLATFORM_ROWS)
                .stream()
                .findFirst();
    }

    public ReviewPlatform save(ReviewPlatform platform) {
        if (platform.getId() == null) {
            platform.setId(UUID.randomUUID());
        }
        supabase.upsert("review_platforms", "id", platform);
        return platform;
    }
}
