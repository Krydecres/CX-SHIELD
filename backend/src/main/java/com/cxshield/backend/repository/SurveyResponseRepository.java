package com.cxshield.backend.repository;

import com.cxshield.backend.config.SmokeTestMode;
import com.cxshield.backend.entity.SurveyResponse;
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
 * Lưu trữ và truy vấn kết quả đánh giá survey_responses trên Supabase (E1.1).
 * Khi chạy profile smoke/CI hoặc khi khởi tạo không có Supabase (unit test), lưu trữ đánh giá trên RAM.
 * Trong môi trường Production (supabase != null && !smokeMode), lưu trữ trên Supabase thật.
 */
@Repository
public class SurveyResponseRepository {

    private static final ParameterizedTypeReference<List<SurveyResponse>> RESPONSE_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;
    private final boolean smokeMode;
    private final Map<UUID, SurveyResponse> store = new ConcurrentHashMap<>();

    public SurveyResponseRepository() {
        this(null, false);
    }

    public SurveyResponseRepository(SupabaseAdminClient supabase) {
        this(supabase, false);
    }

    @Autowired
    public SurveyResponseRepository(SupabaseAdminClient supabase, @Autowired(required = false) SmokeTestMode smokeTestMode) {
        this(supabase, smokeTestMode != null && smokeTestMode.isEnabled());
    }

    public SurveyResponseRepository(SupabaseAdminClient supabase, boolean smokeMode) {
        this.supabase = supabase;
        this.smokeMode = smokeMode;
    }

    private boolean shouldUseStore() {
        return supabase == null || smokeMode;
    }

    public Optional<SurveyResponse> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        if (shouldUseStore()) {
            return Optional.ofNullable(store.get(id));
        }
        return supabase.select("survey_responses", Map.of("id", "eq." + id), RESPONSE_ROWS)
                .stream()
                .findFirst();
    }

    public SurveyResponse save(SurveyResponse response) {
        if (response.getId() == null) {
            response.setId(UUID.randomUUID());
        }
        if (shouldUseStore()) {
            store.put(response.getId(), response);
            return response;
        }
        supabase.upsert("survey_responses", "id", response);
        return response;
    }
}
