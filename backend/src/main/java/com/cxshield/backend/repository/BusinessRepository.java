package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Business;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class BusinessRepository {
    private final Map<UUID, Business> store = new ConcurrentHashMap<>();

    public BusinessRepository() {
        // Khởi tạo cơ sở mẫu theo User Story: Maison Coffee & Bistro
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        Business maison = new Business(
                businessId,
                "Maison Coffee & Bistro",
                "Maison Coffee & Bistro",
                "F&B",
                "0901234567",
                "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&auto=format&fit=crop&q=80",
                "#2C1810",
                "0312345678",
                "maison-coffee",
                "ACTIVE"
        );
        store.put(businessId, maison);
    }

    public Optional<Business> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public Business save(Business business) {
        store.put(business.getId(), business);
        return business;
    }
}

