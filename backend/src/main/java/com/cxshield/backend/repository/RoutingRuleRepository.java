package com.cxshield.backend.repository;

import com.cxshield.backend.entity.RoutingRule;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Repository
public class RoutingRuleRepository {
    private final Map<UUID, RoutingRule> store = new ConcurrentHashMap<>();
    private final Map<UUID, UUID> businessIndex = new ConcurrentHashMap<>();

    public RoutingRuleRepository() {
        // Cấu hình phân luồng mặc định cho cơ sở mẫu "Maison Coffee & Bistro"
        // 4-5 sao -> Google Maps, 1-3 sao -> góp ý nội bộ
        UUID maisonId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        RoutingRule defaultRule = new RoutingRule(maisonId, 4, 5, true);
        save(defaultRule);
    }

    public RoutingRule save(RoutingRule rule) {
        if (rule.getId() == null) {
            rule.setId(UUID.randomUUID());
        }
        store.put(rule.getId(), rule);
        if (rule.getBusinessId() != null) {
            businessIndex.put(rule.getBusinessId(), rule.getId());
        }
        return rule;
    }

    public Optional<RoutingRule> findById(UUID id) {
        return Optional.ofNullable(store.get(id));
    }

    public Optional<RoutingRule> findByBusinessId(UUID businessId) {
        if (businessId == null) return Optional.empty();
        UUID ruleId = businessIndex.get(businessId);
        if (ruleId == null) {
            // Nếu cơ sở chưa có rule riêng, fallback trả về rule mặc định chuẩn (4-5 sao)
            RoutingRule fallback = new RoutingRule(businessId, 4, 5, true);
            save(fallback);
            return Optional.of(fallback);
        }
        return Optional.ofNullable(store.get(ruleId));
    }

    public boolean deleteById(UUID id) {
        RoutingRule rule = store.remove(id);
        if (rule != null && rule.getBusinessId() != null) {
            businessIndex.remove(rule.getBusinessId());
            return true;
        }
        return false;
    }
}
