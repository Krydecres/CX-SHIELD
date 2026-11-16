package com.cxshield.backend.repository;

import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Lưu trữ và truy vấn phiên khảo sát survey_sessions trên Supabase (E1.1).
 * Bắt buộc ghi nhận business_id và trạng thái enum session_status.
 */
@Repository
public class SurveySessionRepository {

    private static final ParameterizedTypeReference<List<SurveySession>> SESSION_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public SurveySessionRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<SurveySession> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("survey_sessions", Map.of("id", "eq." + id), SESSION_ROWS)
                .stream()
                .findFirst();
    }

    public SurveySession save(SurveySession session) {
        if (session.getId() == null) {
            session.setId(UUID.randomUUID());
        }
        supabase.upsert("survey_sessions", "id", session);
        return session;
    }
}
