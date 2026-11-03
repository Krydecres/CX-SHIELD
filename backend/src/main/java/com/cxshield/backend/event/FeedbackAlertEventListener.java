package com.cxshield.backend.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

/**
 * Lắng nghe sự kiện góp ý mới để phát cảnh báo sang E2.2 (Telegram / Zalo / Email).
 * Tuân thủ Coding Conventions: Tuyệt đối KHÔNG ghi SĐT hay nội dung góp ý ra log.
 */
@Component
public class FeedbackAlertEventListener {
    private static final Logger log = LoggerFactory.getLogger(FeedbackAlertEventListener.class);

    @EventListener
    public void onFeedbackCreated(FeedbackCreatedEvent event) {
        log.info("[E2.2 Alert Dispatcher] Nhận sự kiện góp ý mới (ID: {}, Star: {}, Urgent: {}, HasPhone: {}). Chuẩn bị chuyển tiếp cảnh báo Telegram/Zalo...",
                event.getFeedbackId(),
                event.getStarRating(),
                event.isUrgentCallback(),
                event.isHasPhone());
        
        // Trong hệ thống đầy đủ, chỗ này gọi Webhook / Telegram Bot / Zalo ZNS tới Quản lý chi nhánh
    }
}

