package com.cxshield.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@ConfigurationPropertiesScan
@EnableScheduling
public class CxShieldBackendApplication {

	public static void main(String[] args) {
		SpringApplication.run(CxShieldBackendApplication.class, args);
	}

}
