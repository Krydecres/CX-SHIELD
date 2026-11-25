package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
import com.cxshield.backend.entity.Branch;
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
 * Quản lý dữ liệu chi nhánh qua Supabase (E1.1).
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), sử dụng chi nhánh mẫu Quận 1 trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), truy vấn Supabase thật.
 */
@Repository
public class BranchRepository {

    private static final ParameterizedTypeReference<List<Branch>> BRANCH_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, Branch> store = new ConcurrentHashMap<>();

    public BranchRepository() {
        this(null, false);
    }

    public BranchRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public BranchRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public BranchRepository(SupabaseAdminClient supabase, boolean smokeMode) {
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
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        Branch defaultBranch = new Branch(
                branchId,
                businessId,
                "CN-Q1",
                "Chi nhánh Quận 1 - Đồng Khởi",
                "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                "02838221122",
                "ACTIVE"
        );
        store.put(branchId, defaultBranch);
    }

    public Optional<Branch> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("branches", Map.of("id", "eq." + id), BRANCH_ROWS)
                .stream()
                .findFirst();
    }

    public Branch save(Branch branch) {
        if (branch.getId() == null) {
            branch.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            store.put(branch.getId(), branch);
            return branch;
        }
        supabase.upsert("branches", "id", branch);
        return branch;
    }
}
