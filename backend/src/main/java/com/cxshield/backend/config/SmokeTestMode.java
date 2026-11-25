package com.cxshield.backend.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.env.Environment;
import org.springframework.core.env.Profiles;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

/**
 * Quản lý trạng thái môi trường kiểm thử Smoke / CI.
 * Dữ liệu giả lập trên RAM CHỈ được kích hoạt khi profile "smoke" hoặc "ci" được bật tường minh.
 * Môi trường Production tuyệt đối không sử dụng chế độ này.
 */
@Component
public class SmokeTestMode {

    private static final Logger log = LoggerFactory.getLogger(SmokeTestMode.class);

    private final boolean enabled;

    public SmokeTestMode(Environment environment) {
        this.enabled = environment.acceptsProfiles(Profiles.of("smoke", "ci"))
                || Boolean.parseBoolean(environment.getProperty("cxshield.smoke-mode", "false"));
    }

    @PostConstruct
    public void logStatus() {
        if (enabled) {
            log.info("================================================================================");
            log.info("[TEST-PROFILE] KÍCH HOẠT CHẾ ĐỘ KIỂM THỬ SMOKE / CI (IN-MEMORY MOCK)");
            log.info("[TEST-PROFILE] CÁC REPOSITORY SẼ SỬ DỤNG DỮ LIỆU GIẢ LẬP TRÊN RAM");
            log.info("[TEST-PROFILE] KHÔNG GỌI SUPABASE THẬT - MÔI TRƯỜNG KIỂM THỬ ĐỘC LẬP HOÀN TOÀN");
            log.info("================================================================================");
        }
    }

    public boolean isEnabled() {
        return enabled;
    }
}
