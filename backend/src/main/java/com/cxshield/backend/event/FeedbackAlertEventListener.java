package com.cxshield.backend.event;

import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import com.cxshield.backend.alert.AlertDispatcher;

/**
 * Lắng nghe sự kiện góp ý mới và chuyển cho E2.2 gửi cảnh báo Telegram / Zalo / Email.
 */
@Component
public class FeedbackAlertEventListener {

    private final AlertDispatcher alertDispatcher;

    public FeedbackAlertEventListener(AlertDispatcher alertDispatcher) {
        this.alertDispatcher = alertDispatcher;
    }

    @EventListener
    public void onFeedbackCreated(FeedbackCreatedEvent event) {
        alertDispatcher.dispatchAsync(event);
    }
}
