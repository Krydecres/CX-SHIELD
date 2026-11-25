package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Business;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Quản lý dữ liệu cơ sở kinh doanh qua Supabase (E1.1).
 * Không nạp cơ sở mẫu tĩnh.
 */
@Repository
public class BusinessRepository {

    private static final ParameterizedTypeReference<List<Business>> BUSINESS_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final Map<UUID, Business> store = new java.util.concurrent.ConcurrentHashMap<>();

    /** Chế độ bộ nhớ trong, chỉ dùng cho unit test. */
    public BusinessRepository() {
        this(null);
    }

    /**
     * Chế độ chạy thật qua Supabase. Phải có @Autowired vì lớp có hai constructor;
     * thiếu nó Spring sẽ chọn constructor rỗng và bỏ qua Supabase.
     */
    @Autowired
    public BusinessRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<Business> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (supabase != null) {
            return supabase.select("businesses", Map.of("id", "eq." + id), BUSINESS_ROWS)
                    .stream()
                    .findFirst();
        }
        return Optional.ofNullable(store.get(id));
    }

    public Business save(Business business) {
        if (business.getId() == null) {
            business.setId(UUID.randomUUID());
        }
        if (supabase != null) {
            supabase.upsert("businesses", "id", business);
        } else {
            store.put(business.getId(), business);
        }
        return business;
    }
}
