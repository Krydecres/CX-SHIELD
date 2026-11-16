package com.cxshield.backend.repository;

import com.cxshield.backend.entity.PrintDesign;
import com.cxshield.backend.entity.PrintTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class PrintDesignRepository {
    private final Map<UUID, PrintDesign> store = new ConcurrentHashMap<>();

    public PrintDesignRepository() {
        // Mẫu thiết kế có sẵn cho Maison Coffee (Bàn 04)
        UUID defaultDesignId = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        UUID qrCodeId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");

        PrintDesign design = new PrintDesign(
                defaultDesignId,
                businessId,
                qrCodeId,
                PrintTemplate.TABLE_TENT,
                "Maison Coffee & Bistro",
                "Quét mã để đánh giá & nhận ngay quà tri ân",
                "#2C1810",
                "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&auto=format&fit=crop&q=80",
                "PDF",
                "A6",
                null
        );
        store.put(defaultDesignId, design);
    }

    public List<PrintDesign> findByBusinessId(UUID businessId) {
        if (businessId == null) {
            return new ArrayList<>(store.values());
        }
        return store.values().stream()
                .filter(d -> businessId.equals(d.getBusinessId()))
                .toList();
    }

    public Optional<PrintDesign> findById(UUID id) {
        if (id == null) return Optional.empty();
        return Optional.ofNullable(store.get(id));
    }

    public PrintDesign save(PrintDesign design) {
        if (design.getId() == null) {
            design.setId(UUID.randomUUID());
        }
        store.put(design.getId(), design);
        return design;
    }

    public boolean deleteById(UUID id) {
        return store.remove(id) != null;
    }
}

