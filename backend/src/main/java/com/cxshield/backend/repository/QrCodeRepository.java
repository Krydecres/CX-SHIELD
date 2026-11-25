package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
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
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), sử dụng dữ liệu mẫu trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), tuyệt đối truy vấn Supabase thật.
 */
@Repository
public class QrCodeRepository {

    private static final ParameterizedTypeReference<List<QrCode>> QR_CODE_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, QrCode> store = new ConcurrentHashMap<>();
    private final Map<String, UUID> codeIndex = new ConcurrentHashMap<>();

    /**
     * Chế độ bộ nhớ trong, chỉ dùng cho unit test: nạp sẵn một mã QR mẫu.
     */
    public QrCodeRepository() {
        this(null, false);
    }

    public QrCodeRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public QrCodeRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public QrCodeRepository(SupabaseAdminClient supabase, boolean smokeMode) {
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
        UUID qrId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");

        QrCode mcB04 = new QrCode(
                qrId,
                branchId,
                "MC-B04",
                "TABLE",
                "Bàn 04",
                "ACTIVE"
        );
        putInMemory(mcB04);
    }

    private void putInMemory(QrCode qrCode) {
        store.put(qrCode.getId(), qrCode);
        if (qrCode.getCode() != null) {
            codeIndex.put(qrCode.getCode().trim().toUpperCase(), qrCode.getId());
        }
    }

    public Optional<QrCode> findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            UUID id = codeIndex.get(code.trim().toUpperCase());
            if (id == null) return Optional.empty();
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("qr_codes", Map.of("code", "eq." + code.trim(), "status", "eq.ACTIVE"), QR_CODE_ROWS)
                .stream()
                .findFirst();
    }

    public Optional<QrCode> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("qr_codes", Map.of("id", "eq." + id), QR_CODE_ROWS)
                .stream()
                .findFirst();
    }

    public List<QrCode> findByBranchId(UUID branchId) {
        if (branchId == null) {
            return findAll();
        }
        if (shouldUseStore()) {
            return store.values().stream()
                    .filter(q -> branchId.equals(q.getBranchId()))
                    .toList();
        }
        return supabase.select("qr_codes", Map.of("branch_id", "eq." + branchId), QR_CODE_ROWS);
    }

    public List<QrCode> findAll() {
        if (shouldUseStore()) {
            return List.copyOf(store.values());
        }
        return supabase.select("qr_codes", Map.of(), QR_CODE_ROWS);
    }

    public QrCode save(QrCode qrCode) {
        if (qrCode.getId() == null) {
            qrCode.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            putInMemory(qrCode);
            return qrCode;
        }
        supabase.upsert("qr_codes", "id", qrCode);
        return qrCode;
    }
}
