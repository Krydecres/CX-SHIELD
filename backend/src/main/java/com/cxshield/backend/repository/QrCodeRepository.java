package com.cxshield.backend.repository;

import com.cxshield.backend.entity.QrCode;
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
 * Kho dữ liệu mã QR khảo sát.
 */
@Repository
public class QrCodeRepository {

    private static final ParameterizedTypeReference<List<QrCode>> QR_CODE_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final Map<UUID, QrCode> store = new ConcurrentHashMap<>();
    private final Map<String, UUID> codeIndex = new ConcurrentHashMap<>();

    /**
     * Chế độ bộ nhớ trong, chỉ dùng cho unit test: nạp sẵn một mã QR mẫu.
     */
    public QrCodeRepository() {
        this.supabase = null;
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
        store.put(qrCode.getId(), qrCode);
        codeIndex.put(qrCode.getCode().trim().toUpperCase(), qrCode.getId());
    }

    /**
     * Chế độ chạy thật: đọc ghi bảng qr_codes trên Supabase, không có dữ liệu mẫu.
     * Phải có @Autowired vì lớp có hai constructor; thiếu nó Spring sẽ chọn constructor rỗng
     * và backend chạy bằng bộ nhớ trong thay vì Supabase.
     */
    @Autowired
    public QrCodeRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<QrCode> findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return Optional.empty();
        }
        if (supabase != null) {
            return supabase.select("qr_codes", Map.of("code", "eq." + code.trim(), "status", "eq.ACTIVE"), QR_CODE_ROWS)
                    .stream()
                    .findFirst();
        }
        UUID id = codeIndex.get(code.trim().toUpperCase());
        if (id == null) return Optional.empty();
        return Optional.ofNullable(store.get(id));
    }

    public Optional<QrCode> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (supabase != null) {
            return supabase.select("qr_codes", Map.of("id", "eq." + id), QR_CODE_ROWS)
                    .stream()
                    .findFirst();
        }
        return Optional.ofNullable(store.get(id));
    }

    public List<QrCode> findByBranchId(UUID branchId) {
        if (branchId == null) {
            return findAll();
        }
        if (supabase != null) {
            return supabase.select("qr_codes", Map.of("branch_id", "eq." + branchId), QR_CODE_ROWS);
        }
        return store.values().stream()
                .filter(q -> branchId.equals(q.getBranchId()))
                .toList();
    }

    public List<QrCode> findAll() {
        if (supabase != null) {
            return supabase.select("qr_codes", Map.of(), QR_CODE_ROWS);
        }
        return List.copyOf(store.values());
    }

    public QrCode save(QrCode qrCode) {
        if (qrCode.getId() == null) {
            qrCode.setId(UUID.randomUUID());
        }
        if (supabase != null) {
            supabase.upsert("qr_codes", "id", qrCode);
            return qrCode;
        }
        store.put(qrCode.getId(), qrCode);
        if (qrCode.getCode() != null) {
            codeIndex.put(qrCode.getCode().trim().toUpperCase(), qrCode.getId());
        }
        return qrCode;
    }
}
