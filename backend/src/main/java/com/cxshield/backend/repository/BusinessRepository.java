package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Business;
import com.cxshield.backend.supabase.SupabaseAdminClient;
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

    public BusinessRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<Business> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("businesses", Map.of("id", "eq." + id), BUSINESS_ROWS)
                .stream()
                .findFirst();
    }

    public Business save(Business business) {
        if (business.getId() == null) {
            business.setId(UUID.randomUUID());
        }
        supabase.upsert("businesses", "id", business);
        return business;
    }
}
