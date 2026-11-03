package com.cxshield.backend.account;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.account.AccountRepository.BusinessRow;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingRequest;
import com.cxshield.backend.account.dto.AccountDtos.OnboardingResponse;
import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.config.CxShieldProperties;
import com.cxshield.backend.supabase.SupabaseException;

/**
 * Onboarding (E7.1 · D3-02): tạo cơ sở, vai trò OWNER, membership và chi nhánh đầu tiên.
 */
@Service
public class OnboardingService {

	static final String DEFAULT_PRIMARY_COLOR = "#1E40AF";
	static final String FIRST_BRANCH_CODE = "CN01";
	private static final int MAX_SLUG_ATTEMPTS = 3;

	private final AccountRepository accountRepository;
	private final CxShieldProperties properties;

	public OnboardingService(AccountRepository accountRepository, CxShieldProperties properties) {
		this.accountRepository = accountRepository;
		this.properties = properties;
	}

	public OnboardingResponse onboard(String token, UUID userId, OnboardingRequest request) {
		String brandName = request.brandName().trim();
		String branchName = isBlank(request.branchName()) ? brandName : request.branchName().trim();
		String phone = blankToNull(request.phone());
		String color = isBlank(request.primaryColor()) ? DEFAULT_PRIMARY_COLOR : request.primaryColor().toUpperCase();
		String logoUrl = blankToNull(request.logoUrl());
		if (logoUrl != null && !logoUrl.startsWith(properties.supabase().publicLogoPrefix() + userId + "/")) {
			throw ApiException.badRequest("INVALID_LOGO_URL", "Logo phải được tải lên qua hệ thống.");
		}

		UUID businessId = resolveBusiness(token, userId, brandName, request.industry().trim(), phone, color);

		Map<String, Object> profile = new LinkedHashMap<>();
		profile.put("brand_name", brandName);
		profile.put("display_name", branchName);
		profile.put("industry", request.industry().trim());
		profile.put("phone", phone);
		profile.put("primary_color", color);
		profile.put("logo_url", logoUrl);
		BusinessRow business = accountRepository.updateBusinessProfile(token, businessId, profile);

		UUID branchId = UUID.randomUUID();
		accountRepository.createBranch(token, branchId, businessId, FIRST_BRANCH_CODE, branchName, phone);
		BranchRow branch = accountRepository.findBranch(token, branchId)
			.orElseThrow(() -> new IllegalStateException("Không đọc lại được chi nhánh vừa tạo"));

		return new OnboardingResponse(AccountService.toBusiness(business), AccountService.toBranch(branch));
	}

	/**
	 * Trả về cơ sở cần hoàn tất onboarding: cơ sở mới tạo, hoặc cơ sở OWNER đã tạo nhưng chưa có chi nhánh
	 * (lần onboarding trước bị gián đoạn).
	 */
	private UUID resolveBusiness(String token, UUID userId, String brandName, String industry, String phone,
			String color) {
		List<MembershipRow> memberships = accountRepository.findActiveMemberships(token, userId);
		if (!memberships.isEmpty()) {
			MembershipRow first = memberships.getFirst();
			boolean resumable = "OWNER".equals(first.roleName())
					&& accountRepository.findBranches(token, first.businessId()).isEmpty();
			if (!resumable) {
				throw ApiException.conflict("ALREADY_ONBOARDED", "Tài khoản đã được thiết lập cơ sở.");
			}
			return first.businessId();
		}

		for (int attempt = 1;; attempt++) {
			try {
				return accountRepository.createBusinessWithOwner(token, brandName, SlugGenerator.generate(brandName),
						industry, phone, color);
			}
			catch (SupabaseException ex) {
				if (!ex.isUniqueViolation() || attempt >= MAX_SLUG_ATTEMPTS) {
					throw ex;
				}
			}
		}
	}

	private static boolean isBlank(String value) {
		return value == null || value.isBlank();
	}

	private static String blankToNull(String value) {
		return isBlank(value) ? null : value.trim();
	}

}
