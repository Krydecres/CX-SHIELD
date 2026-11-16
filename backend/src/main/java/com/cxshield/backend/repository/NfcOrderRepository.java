package com.cxshield.backend.repository;

import com.cxshield.backend.entity.NfcOrder;
import com.cxshield.backend.entity.NfcOrderStatus;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class NfcOrderRepository {
    private final Map<UUID, NfcOrder> store = new ConcurrentHashMap<>();

    public NfcOrderRepository() {
        // Đơn mẫu cho Maison Coffee
        UUID defaultOrderId = UUID.fromString("f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66");
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        UUID designId = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");

        NfcOrder order = new NfcOrder(
                defaultOrderId,
                businessId,
                designId,
                "WOOD",
                10,
                "Nguyễn Văn Chủ Quán",
                "0901234567",
                "123 Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh",
                45000L,
                450000L,
                NfcOrderStatus.PENDING
        );
        store.put(defaultOrderId, order);
    }

    public List<NfcOrder> findByBusinessId(UUID businessId) {
        if (businessId == null) {
            return new ArrayList<>(store.values());
        }
        return store.values().stream()
                .filter(o -> businessId.equals(o.getBusinessId()))
                .sorted((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()))
                .toList();
    }

    public Optional<NfcOrder> findById(UUID id) {
        if (id == null) return Optional.empty();
        return Optional.ofNullable(store.get(id));
    }

    public NfcOrder save(NfcOrder order) {
        if (order.getId() == null) {
            order.setId(UUID.randomUUID());
        }
        store.put(order.getId(), order);
        return order;
    }
}

