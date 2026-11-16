package com.cxshield.backend.repository;

import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Quản lý dữ liệu mã QR khảo sát qua Supabase (E1.1).
 * Không tạo mã QR mẫu tự động, báo lỗi khi mã QR không tồn tại.
 */
@Repository
public class QrCodeRepository {

    private static final ParameterizedTypeReference<List<QrCode>> QR_CODE_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public QrCodeRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<QrCode> findByCode(String code) {
        if (code == null || code.trim().isEmpty()) {
            return Optional.empty();
        }
        return supabase.select("qr_codes", Map.of("code", "eq." + code.trim(), "status", "eq.ACTIVE"), QR_CODE_ROWS)
                .stream()
                .findFirst();
    }

    public Optional<QrCode> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("qr_codes", Map.of("id", "eq." + id), QR_CODE_ROWS)
                .stream()
                .findFirst();
    }

    public QrCode save(QrCode qrCode) {
        if (qrCode.getId() == null) {
            qrCode.setId(UUID.randomUUID());
        }
        supabase.upsert("qr_codes", "id", qrCode);
        return qrCode;
    }
}
