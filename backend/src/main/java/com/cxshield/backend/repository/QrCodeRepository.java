package com.cxshield.backend.repository;

import com.cxshield.backend.entity.QrCode;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class QrCodeRepository {
    private final Map<UUID, QrCode> store = new ConcurrentHashMap<>();
    private final Map<String, UUID> codeIndex = new ConcurrentHashMap<>();

    public QrCodeRepository() {
        // Mã QR mẫu cho Bàn 04
        UUID qrId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

        QrCode qrCode = new QrCode(
                qrId,
                branchId,
                "MC-B04",
                "TABLE",
                "Bàn 04",
                "ACTIVE"
        );
        save(qrCode);
    }

    public Optional<QrCode> findByCode(String code) {
        if (code == null) return Optional.empty();
        UUID id = codeIndex.get(code.trim().toUpperCase());
        if (id == null) return Optional.empty();
        return Optional.ofNullable(store.get(id));
    }

    public Optional<QrCode> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public java.util.List<QrCode> findByBranchId(UUID branchId) {
        if (branchId == null) {
            return java.util.List.copyOf(store.values());
        }
        return store.values().stream()
                .filter(q -> branchId.equals(q.getBranchId()))
                .toList();
    }

    public java.util.List<QrCode> findAll() {
        return java.util.List.copyOf(store.values());
    }

    public QrCode save(QrCode qrCode) {
        store.put(qrCode.getId(), qrCode);
        codeIndex.put(qrCode.getCode().trim().toUpperCase(), qrCode.getId());
        return qrCode;
    }
}

