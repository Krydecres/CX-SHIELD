package com.cxshield.backend.repository;

import com.cxshield.backend.entity.FeedbackTopic;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class FeedbackTopicRepository {
    private final Map<UUID, FeedbackTopic> store = new ConcurrentHashMap<>();

    public FeedbackTopicRepository() {
        UUID businessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");

        save(new FeedbackTopic(UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380001"), businessId, "Món ăn / Đồ uống", true));
        save(new FeedbackTopic(UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380002"), businessId, "Thái độ phục vụ", true));
        save(new FeedbackTopic(UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380003"), businessId, "Thời gian chờ món", true));
        save(new FeedbackTopic(UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380004"), businessId, "Không gian & Vệ sinh", true));
        save(new FeedbackTopic(UUID.fromString("e1eebc99-9c0b-4ef8-bb6d-6bb9bd380005"), businessId, "Giá cả & Hóa đơn", true));
    }

    public FeedbackTopic save(FeedbackTopic topic) {
        store.put(topic.getId(), topic);
        return topic;
    }

    public List<FeedbackTopic> findAllActive() {
        List<FeedbackTopic> list = new ArrayList<>();
        for (FeedbackTopic topic : store.values()) {
            if (topic.isActive()) {
                list.add(topic);
            }
        }
        return list;
    }

    public java.util.Optional<FeedbackTopic> findById(UUID id) {
        if (id == null) return java.util.Optional.empty();
        return java.util.Optional.ofNullable(store.get(id));
    }
}

