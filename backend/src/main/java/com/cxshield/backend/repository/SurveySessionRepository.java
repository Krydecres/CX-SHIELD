package com.cxshield.backend.repository;

import com.cxshield.backend.entity.SurveySession;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class SurveySessionRepository {
    private final Map<UUID, SurveySession> store = new ConcurrentHashMap<>();

    public Optional<SurveySession> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public SurveySession save(SurveySession session) {
        store.put(session.getId(), session);
        return session;
    }
}

