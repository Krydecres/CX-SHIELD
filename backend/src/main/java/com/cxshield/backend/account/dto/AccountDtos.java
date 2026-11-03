package com.cxshield.backend.account.dto;

import java.util.List;
import java.util.UUID;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * DTO của API tài khoản & onboarding (E7.1 · D3-01, D3-02).
 */
public final class AccountDtos {

	private AccountDtos() {
	}

	public record MeResponse(UUID userId, String email, String fullName, String authProvider, boolean onboarded,
			List<MembershipResponse> memberships) {
	}

	public record MembershipResponse(UUID membershipId, String role, BusinessResponse business) {
	}

	public record BusinessResponse(UUID id, String brandName, String displayName, String industry, String phone,
			String logoUrl, String primaryColor) {
	}

	public record BranchResponse(UUID id, UUID businessId, String code, String name, String address, String hotline,
			String status) {
	}

	public record OnboardingRequest(
			@NotBlank(message = "Vui lòng nhập tên thương hiệu.") @Size(max = 120,
					message = "Tên thương hiệu tối đa 120 ký tự.") String brandName,
			@Size(max = 120, message = "Tên cơ sở / chi nhánh tối đa 120 ký tự.") String branchName,
			@NotBlank(message = "Vui lòng chọn ngành nghề.") @Size(max = 60) String industry,
			@Pattern(regexp = "^(\\+84|0)[0-9]{9,10}$",
					message = "Số điện thoại không hợp lệ (ví dụ 0901234567).") String phone,
			@Size(max = 1000) String logoUrl,
			@Pattern(regexp = "^#[0-9A-Fa-f]{6}$", message = "Mã màu phải có dạng #RRGGBB.") String primaryColor) {
	}

	public record OnboardingResponse(BusinessResponse business, BranchResponse branch) {
	}

}
