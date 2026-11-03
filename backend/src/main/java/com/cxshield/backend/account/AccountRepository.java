package com.cxshield.backend.account;

import java.time.OffsetDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.supabase.SupabaseDataClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Truy cập các bảng lõi của phân hệ 3: users, memberships, businesses, branches.
 */
@Repository
public class AccountRepository {

	private static final ParameterizedTypeReference<List<UserRow>> USER_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<MembershipRow>> MEMBERSHIP_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<BusinessRow>> BUSINESS_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<BranchRow>> BRANCH_ROWS = new ParameterizedTypeReference<>() {
	};

	private static final String BRANCH_COLUMNS = "id,business_id,code,name,address,hotline,status,created_at";

	private final SupabaseDataClient supabase;

	public AccountRepository(SupabaseDataClient supabase) {
		this.supabase = supabase;
	}

	public Optional<UserRow> findUser(String token, UUID userId) {
		return supabase
			.select(token, "users", Map.of("select", "id,email,full_name,auth_provider", "id", "eq." + userId), USER_ROWS)
			.stream()
			.findFirst();
	}

	public List<MembershipRow> findActiveMemberships(String token, UUID userId) {
		return supabase.select(token, "memberships",
				Map.of("select",
						"id,business_id,status,roles(name),businesses(id,brand_name,display_name,industry,phone,logo_url,primary_color)",
						"user_id", "eq." + userId, "status", "eq.ACTIVE", "deleted_at", "is.null", "order",
						"created_at.asc"),
				MEMBERSHIP_ROWS);
	}

	public UUID createBusinessWithOwner(String token, String brandName, String publicSlug, String industry, String phone,
			String primaryColor) {
		Map<String, Object> args = new LinkedHashMap<>();
		args.put("p_brand_name", brandName);
		args.put("p_public_slug", publicSlug);
		args.put("p_industry", industry);
		args.put("p_phone", phone);
		args.put("p_primary_color", primaryColor);
		return supabase.rpc(token, "create_business_onboarding", args, UUID.class);
	}

	public BusinessRow updateBusinessProfile(String token, UUID businessId, Map<String, Object> changes) {
		return supabase.update(token, "businesses", Map.of("id", "eq." + businessId), changes, BUSINESS_ROWS)
			.stream()
			.findFirst()
			.orElseThrow(() -> new IllegalStateException("Không cập nhật được cơ sở " + businessId));
	}

	public List<BranchRow> findBranches(String token, UUID businessId) {
		return supabase.select(token, "branches", Map.of("select", BRANCH_COLUMNS, "business_id", "eq." + businessId,
				"deleted_at", "is.null", "order", "created_at.asc"), BRANCH_ROWS);
	}

	public Optional<BranchRow> findBranch(String token, UUID branchId) {
		return supabase
			.select(token, "branches", Map.of("select", BRANCH_COLUMNS, "id", "eq." + branchId, "deleted_at", "is.null"),
					BRANCH_ROWS)
			.stream()
			.findFirst();
	}

	public void createBranch(String token, UUID branchId, UUID businessId, String code, String name, String hotline) {
		Map<String, Object> body = new LinkedHashMap<>();
		body.put("id", branchId);
		body.put("business_id", businessId);
		body.put("code", code);
		body.put("name", name);
		body.put("hotline", hotline);
		supabase.insertWithoutReturn(token, "branches", body);
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record UserRow(UUID id, String email, @JsonProperty("full_name") String fullName,
			@JsonProperty("auth_provider") String authProvider) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record MembershipRow(UUID id, @JsonProperty("business_id") UUID businessId, String status, RoleRef roles,
			BusinessRow businesses) {

		public String roleName() {
			return roles == null ? null : roles.name();
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record RoleRef(String name) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record BusinessRow(UUID id, @JsonProperty("brand_name") String brandName,
			@JsonProperty("display_name") String displayName, String industry, String phone,
			@JsonProperty("logo_url") String logoUrl, @JsonProperty("primary_color") String primaryColor) {
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record BranchRow(UUID id, @JsonProperty("business_id") UUID businessId, String code, String name,
			String address, String hotline, String status, @JsonProperty("created_at") OffsetDateTime createdAt) {
	}

}
