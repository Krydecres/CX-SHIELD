package com.cxshield.backend.repository;

import com.cxshield.backend.entity.Feedback;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class FeedbackRepository {
    private final Map<UUID, Feedback> store = new ConcurrentHashMap<>();
    private final Map<UUID, UUID> responseIndex = new ConcurrentHashMap<>();

    public Feedback save(Feedback feedback) {
        store.put(feedback.getId(), feedback);
        if (feedback.getResponseId() != null) {
            responseIndex.put(feedback.getResponseId(), feedback.getId());
        }
        return feedback;
    }

    public Optional<Feedback> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public Optional<Feedback> findByResponseId(UUID responseId) {
        UUID feedbackId = responseIndex.get(responseId);
        if (feedbackId == null) return Optional.empty();
        return Optional.ofNullable(store.get(feedbackId));
    }
}

