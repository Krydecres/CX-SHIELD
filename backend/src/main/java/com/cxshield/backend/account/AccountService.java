package com.cxshield.backend.account;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.cxshield.backend.account.AccountRepository.BranchRow;
import com.cxshield.backend.account.AccountRepository.BusinessRow;
import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.UserRow;
import com.cxshield.backend.account.dto.AccountDtos.BranchResponse;
import com.cxshield.backend.account.dto.AccountDtos.BusinessResponse;
import com.cxshield.backend.account.dto.AccountDtos.MeResponse;
import com.cxshield.backend.account.dto.AccountDtos.MembershipResponse;
import com.cxshield.backend.common.ApiException;

@Service
public class AccountService {

	private final AccountRepository accountRepository;

	public AccountService(AccountRepository accountRepository) {
		this.accountRepository = accountRepository;
	}

	public MeResponse getMe(String token, UUID userId, String tokenEmail) {
		UserRow user = accountRepository.findUser(token, userId).orElse(null);
		List<MembershipRow> memberships = accountRepository.findActiveMemberships(token, userId);
		// Onboarding chỉ coi là xong khi cơ sở đầu tiên đã có chi nhánh (bước tạo chi nhánh có thể lỗi giữa chừng).
		boolean onboarded = !memberships.isEmpty()
				&& !accountRepository.findBranches(token, memberships.getFirst().businessId()).isEmpty();
		return new MeResponse(userId, user != null && user.email() != null ? user.email() : tokenEmail,
				user == null ? null : user.fullName(), user == null ? null : user.authProvider(), onboarded,
				memberships.stream()
					.map(m -> new MembershipResponse(m.id(), m.roleName(), toBusiness(m.businesses())))
					.toList());
	}

	public List<BranchResponse> getBranches(String token, UUID userId, UUID businessId) {
		boolean member = accountRepository.findActiveMemberships(token, userId)
			.stream()
			.anyMatch(m -> m.businessId().equals(businessId));
		if (!member) {
			throw ApiException.notFound("BUSINESS_NOT_FOUND", "Không tìm thấy cơ sở.");
		}
		return accountRepository.findBranches(token, businessId).stream().map(AccountService::toBranch).toList();
	}

	static BusinessResponse toBusiness(BusinessRow row) {
		if (row == null) {
			return null;
		}
		return new BusinessResponse(row.id(), row.brandName(), row.displayName(), row.industry(), row.phone(),
				row.logoUrl(), row.primaryColor());
	}

	static BranchResponse toBranch(BranchRow row) {
		return new BranchResponse(row.id(), row.businessId(), row.code(), row.name(), row.address(), row.hotline(),
				row.status());
	}

}
