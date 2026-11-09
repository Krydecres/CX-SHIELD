package com.cxshield.backend.repository;

import com.cxshield.backend.entity.FeedbackTopicLink;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class FeedbackTopicLinkRepository {
    private final Map<UUID, FeedbackTopicLink> store = new ConcurrentHashMap<>();

    public FeedbackTopicLink save(FeedbackTopicLink link) {
        store.put(link.getId(), link);
        return link;
    }

    public List<FeedbackTopicLink> findByFeedbackId(UUID feedbackId) {
        List<FeedbackTopicLink> result = new ArrayList<>();
        if (feedbackId == null) return result;
        for (FeedbackTopicLink link : store.values()) {
            if (feedbackId.equals(link.getFeedbackId())) {
                result.add(link);
            }
        }
        return result;
    }

    public void deleteByFeedbackId(UUID feedbackId) {
        if (feedbackId == null) return;
        store.values().removeIf(link -> feedbackId.equals(link.getFeedbackId()));
    }

    public long count() {
        return store.size();
    }
}
