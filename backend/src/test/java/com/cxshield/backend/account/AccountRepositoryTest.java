package com.cxshield.backend.account;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import com.cxshield.backend.account.AccountRepository.MembershipRow;
import com.cxshield.backend.account.AccountRepository.RoleRef;
import com.cxshield.backend.supabase.SupabaseDataClient;

class AccountRepositoryTest {

	private static final String TOKEN = "token";
	private static final UUID ID = UUID.randomUUID();

	private SupabaseDataClient supabase;
	private AccountRepository repository;

	@BeforeEach
	void setUp() {
		supabase = mock(SupabaseDataClient.class);
		repository = new AccountRepository(supabase);
	}

	@Test
	void findsOnlyActiveMembershipsOfUser() {
		repository.findActiveMemberships(TOKEN, ID);

		assertThat(capturedQuery("memberships")).containsEntry("user_id", "eq." + ID)
			.containsEntry("status", "eq.ACTIVE")
			.containsEntry("deleted_at", "is.null");
	}

	@Test
	void findsBranchesThatAreNotDeleted() {
		repository.findBranches(TOKEN, ID);

		assertThat(capturedQuery("branches")).containsEntry("business_id", "eq." + ID)
			.containsEntry("deleted_at", "is.null");
	}

	@Test
	void findUserIsEmptyWhenNoRow() {
		when(supabase.select(eq(TOKEN), eq("users"), anyMap(), any())).thenReturn(List.of());

		assertThat(repository.findUser(TOKEN, ID)).isEmpty();
	}

	@Test
	void createsBusinessThroughOnboardingFunction() {
		when(supabase.rpc(eq(TOKEN), eq("create_business_onboarding"), any(), eq(UUID.class))).thenReturn(ID);

		UUID businessId = repository.createBusinessWithOwner(TOKEN, "Maison", "maison-ab12", "Bán lẻ", null, "#1E40AF");

		assertThat(businessId).isEqualTo(ID);
		ArgumentCaptor<Object> args = ArgumentCaptor.forClass(Object.class);
		verify(supabase).rpc(eq(TOKEN), eq("create_business_onboarding"), args.capture(), eq(UUID.class));
		assertThat(List.<Object>copyOf(((Map<?, ?>) args.getValue()).keySet())).containsExactly("p_brand_name",
				"p_public_slug", "p_industry", "p_phone", "p_primary_color");
	}

	@Test
	void createsBranchWithoutReadingItBack() {
		UUID businessId = UUID.randomUUID();

		repository.createBranch(TOKEN, ID, businessId, "CN01", "Maison Q1", null);

		ArgumentCaptor<Object> body = ArgumentCaptor.forClass(Object.class);
		verify(supabase).insertWithoutReturn(eq(TOKEN), eq("branches"), body.capture());
		Map<?, ?> values = (Map<?, ?>) body.getValue();
		assertThat(values.get("id")).isEqualTo(ID);
		assertThat(values.get("business_id")).isEqualTo(businessId);
		assertThat(values.get("code")).isEqualTo("CN01");
	}

	@Test
	void updateBusinessFailsWhenNoRowChanged() {
		when(supabase.update(eq(TOKEN), eq("businesses"), anyMap(), any(), any())).thenReturn(List.of());

		assertThatThrownBy(() -> repository.updateBusinessProfile(TOKEN, ID, Map.of("logo_url", "x")))
			.isInstanceOf(IllegalStateException.class);
	}

	@Test
	void roleNameIsNullWithoutRole() {
		assertThat(new MembershipRow(ID, ID, "ACTIVE", null, null).roleName()).isNull();
		assertThat(new MembershipRow(ID, ID, "ACTIVE", new RoleRef("OWNER"), null).roleName()).isEqualTo("OWNER");
	}

	@SuppressWarnings("unchecked")
	private Map<String, String> capturedQuery(String table) {
		ArgumentCaptor<Map<String, String>> query = ArgumentCaptor.forClass(Map.class);
		verify(supabase).select(eq(TOKEN), eq(table), query.capture(), any());
		return query.getValue();
	}

}
