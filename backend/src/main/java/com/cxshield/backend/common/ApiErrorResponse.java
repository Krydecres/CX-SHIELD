package com.cxshield.backend.common;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_EMPTY)
public record ApiErrorResponse(String code, String message, Map<String, String> fieldErrors) {

	public ApiErrorResponse(String code, String message) {
		this(code, message, Map.of());
	}

}
