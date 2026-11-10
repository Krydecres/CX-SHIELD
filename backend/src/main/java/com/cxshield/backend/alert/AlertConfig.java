package com.cxshield.backend.alert;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AlertConfig {

	/**
	 * Virtual thread hợp với việc chờ mạng khi gửi tin; mỗi kênh một luồng nên không phải xếp hàng.
	 */
	@Bean(destroyMethod = "shutdown")
	ExecutorService alertExecutor() {
		return Executors.newVirtualThreadPerTaskExecutor();
	}

}
