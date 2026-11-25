package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
import com.cxshield.backend.entity.Business;
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
 * Quản lý dữ liệu cơ sở kinh doanh qua Supabase (E1.1).
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), sử dụng cơ sở mẫu Maison Coffee & Bistro trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), truy vấn Supabase thật.
 */
@Repository
public class BusinessRepository {

    private static final ParameterizedTypeReference<List<Business>> BUSINESS_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, Business> store = new ConcurrentHashMap<>();

    /** Chế độ bộ nhớ trong, chỉ dùng cho unit test. */
    public BusinessRepository() {
        this(null, false);
    }

    /**
     * Chế độ chạy thật qua Supabase.
     */
    public BusinessRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public BusinessRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public BusinessRepository(SupabaseAdminClient supabase, boolean smokeMode) {
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
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        Business maison = new Business(
                businessId,
                "Maison Coffee & Bistro",
                "Maison Coffee & Bistro",
                "F&B",
                "0901234567",
                "https://example.com/logo.png",
                "#2C1810",
                "0312345678",
                "maison-coffee",
                "ACTIVE"
        );
        store.put(businessId, maison);
    }

    public Optional<Business> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("businesses", Map.of("id", "eq." + id), BUSINESS_ROWS)
                .stream()
                .findFirst();
    }

    public Business save(Business business) {
        if (business.getId() == null) {
            business.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            store.put(business.getId(), business);
            return business;
        }
        supabase.upsert("businesses", "id", business);
        return business;
    }
}
