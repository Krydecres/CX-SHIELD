package com.cxshield.backend.repository;

import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Lưu trữ và truy vấn kết quả đánh giá survey_responses trên Supabase (E1.1).
 * Ghi nhận business_id và phân nhóm cảm xúc SATISFIED / UNSATISFIED.
 */
@Repository
public class SurveyResponseRepository {

    private static final ParameterizedTypeReference<List<SurveyResponse>> RESPONSE_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public SurveyResponseRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<SurveyResponse> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("survey_responses", Map.of("id", "eq." + id), RESPONSE_ROWS)
                .stream()
                .findFirst();
    }

    public SurveyResponse save(SurveyResponse response) {
        if (response.getId() == null) {
            response.setId(UUID.randomUUID());
        }
        supabase.upsert("survey_responses", "id", response);
        return response;
    }
}
