package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Branch;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Quản lý dữ liệu chi nhánh qua Supabase (E1.1).
 * Không nạp chi nhánh mẫu tĩnh.
 */
@Repository
public class BranchRepository {

    private static final ParameterizedTypeReference<List<Branch>> BRANCH_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public BranchRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<Branch> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("branches", Map.of("id", "eq." + id), BRANCH_ROWS)
                .stream()
                .findFirst();
    }

    public Branch save(Branch branch) {
        if (branch.getId() == null) {
            branch.setId(UUID.randomUUID());
        }
        supabase.upsert("branches", "id", branch);
        return branch;
    }
}
