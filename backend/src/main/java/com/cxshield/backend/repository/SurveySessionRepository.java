package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
import com.cxshield.backend.entity.SurveySession;
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
 * Lưu trữ và truy vấn phiên khảo sát survey_sessions trên Supabase (E1.1).
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), lưu trữ phiên trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), lưu trữ trên Supabase thật.
 */
@Repository
public class SurveySessionRepository {

    private static final ParameterizedTypeReference<List<SurveySession>> SESSION_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, SurveySession> store = new ConcurrentHashMap<>();

    public SurveySessionRepository() {
        this(null, false);
    }

    public SurveySessionRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public SurveySessionRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public SurveySessionRepository(SupabaseAdminClient supabase, boolean smokeMode) {
        this.supabase = supabase;
        this.smokeMode = smokeMode;
    }

    private boolean shouldUseStore() {
        return supabase == null || smokeMode;
    }

    public Optional<SurveySession> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("survey_sessions", Map.of("id", "eq." + id), SESSION_ROWS)
                .stream()
                .findFirst();
    }

    public SurveySession save(SurveySession session) {
        if (session.getId() == null) {
            session.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            store.put(session.getId(), session);
            return session;
        }
        supabase.upsert("survey_sessions", "id", session);
        return session;
    }
}
