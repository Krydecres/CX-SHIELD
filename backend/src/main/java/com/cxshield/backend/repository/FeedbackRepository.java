package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Feedback;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

/**
 * Lưu trữ và truy vấn góp ý nội bộ feedbacks trên Supabase (E1.1 / E1.3).
 * Bắt buộc ghi nhận business_id để đồng bộ dữ liệu và bảo vệ phân quyền.
 */
@Repository
public class FeedbackRepository {

    private static final ParameterizedTypeReference<List<Feedback>> FEEDBACK_ROWS = new ParameterizedTypeReference<>() {};

    private final SupabaseAdminClient supabase;

    public FeedbackRepository(SupabaseAdminClient supabase) {
        this.supabase = supabase;
    }

    public Optional<Feedback> findById(UUID id) {
        if (id == null) {
            return Optional.empty();
        }
        return supabase.select("feedbacks", Map.of("id", "eq." + id), FEEDBACK_ROWS)
                .stream()
                .findFirst();
    }

    public Optional<Feedback> findByResponseId(UUID responseId) {
        if (responseId == null) {
            return Optional.empty();
        }
        return supabase.select("feedbacks", Map.of("response_id", "eq." + responseId), FEEDBACK_ROWS)
                .stream()
                .findFirst();
    }

    public Feedback save(Feedback feedback) {
        if (feedback.getId() == null) {
            feedback.setId(UUID.randomUUID());
        }
        supabase.upsert("feedbacks", "id", feedback);
        return feedback;
    }
}
