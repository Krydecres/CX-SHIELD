package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.Set;
import java.util.stream.Collectors;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import com.cxshield.backend.account.dto.AccountDtos.OnboardingRequest;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

class OnboardingRequestValidationTest {

	private static ValidatorFactory factory;
	private static Validator validator;

	@BeforeAll
	static void createValidator() {
		factory = Validation.buildDefaultValidatorFactory();
		validator = factory.getValidator();
	}

	@AfterAll
	static void closeValidator() {
		factory.close();
	}

	@Test
	void acceptsRequiredFieldsOnly() {
		assertThat(invalidFields(new OnboardingRequest("Maison", null, "Bán lẻ", null, null, null))).isEmpty();
	}

	@Test
	void requiresBrandNameAndIndustry() {
		assertThat(invalidFields(new OnboardingRequest(" ", null, "", null, null, null)))
			.containsExactlyInAnyOrder("brandName", "industry");
	}

	@Test
	void limitsNameLength() {
		String tooLong = "a".repeat(121);

		assertThat(invalidFields(new OnboardingRequest(tooLong, tooLong, "Bán lẻ", null, null, null)))
			.containsExactlyInAnyOrder("brandName", "branchName");
	}

	@ParameterizedTest
	@ValueSource(strings = { "0901234567", "+84901234567", "09012345678" })
	void acceptsVietnamesePhone(String phone) {
		assertThat(invalidFields(new OnboardingRequest("Maison", null, "Bán lẻ", phone, null, null))).isEmpty();
	}

	@ParameterizedTest
	@ValueSource(strings = { "12345", "090123456", "0901abc567", "84901234567" })
	void rejectsInvalidPhone(String phone) {
		assertThat(invalidFields(new OnboardingRequest("Maison", null, "Bán lẻ", phone, null, null)))
			.containsExactly("phone");
	}

	@ParameterizedTest
	@ValueSource(strings = { "#1E40AF", "#1e40af" })
	void acceptsHexColor(String color) {
		assertThat(invalidFields(new OnboardingRequest("Maison", null, "Bán lẻ", null, null, color))).isEmpty();
	}

	@ParameterizedTest
	@ValueSource(strings = { "1E40AF", "#1E40A", "#GGGGGG", "blue" })
	void rejectsInvalidColor(String color) {
		assertThat(invalidFields(new OnboardingRequest("Maison", null, "Bán lẻ", null, null, color)))
			.containsExactly("primaryColor");
	}

	private Set<String> invalidFields(OnboardingRequest request) {
		return validator.validate(request)
			.stream()
			.map(violation -> violation.getPropertyPath().toString())
			.collect(Collectors.toSet());
	}

}
