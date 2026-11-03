package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Branch;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class BranchRepository {
    private final Map<UUID, Branch> store = new ConcurrentHashMap<>();

    public BranchRepository() {
        // Chi nhánh mẫu Quận 1
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");

        Branch branch = new Branch(
                branchId,
                businessId,
                "CN-Q1",
                "Chi nhánh Quận 1 - Đồng Khởi",
                "123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                "02838221122",
                "ACTIVE"
        );
        store.put(branchId, branch);
    }

    public Optional<Branch> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public Branch save(Branch branch) {
        store.put(branch.getId(), branch);
        return branch;
    }
}

