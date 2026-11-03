package com.cxshield.backend.repository;

import com.cxshield.backend.entity.SurveyResponse;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class SurveyResponseRepository {
    private final Map<UUID, SurveyResponse> store = new ConcurrentHashMap<>();

    public Optional<SurveyResponse> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public SurveyResponse save(SurveyResponse response) {
        store.put(response.getId(), response);
        return response;
    }
}

