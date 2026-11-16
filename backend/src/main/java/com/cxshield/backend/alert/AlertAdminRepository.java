package com.cxshield.backend.alert;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Repository;

import com.cxshield.backend.alert.AlertChannelRepository.AlertChannelRow;
import com.cxshield.backend.alert.AlertChannelRepository.AlertRuleRow;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Dữ liệu cho luồng gửi cảnh báo. Khách góp ý không đăng nhập nên phải đọc và ghi bằng service role.
 */
@Repository
public class AlertAdminRepository {

	private static final ParameterizedTypeReference<List<AlertChannelRow>> CHANNEL_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<AlertRuleRow>> RULE_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<BranchInfo>> BRANCH_ROWS = new ParameterizedTypeReference<>() {
	};

	private final SupabaseAdminClient supabase;

	public AlertAdminRepository(SupabaseAdminClient supabase) {
		this.supabase = supabase;
	}

	public boolean isEnabled() {
		return supabase.isEnabled();
	}

	public Optional<BranchInfo> findBranch(UUID branchId) {
		return supabase.select("branches", Map.of("select", "id,name", "id", "eq." + branchId), BRANCH_ROWS).stream().findFirst();
	}

	public List<AlertChannelRow> findEnabledChannels(UUID branchId) {
		return supabase.select("alert_channels", Map.of("select", AlertChannelRepository.CHANNEL_COLUMNS, "branch_id",
				"eq." + branchId, "is_enabled", "eq.true"), CHANNEL_ROWS);
	}

	public Optional<AlertRuleRow> findLowRatingRule(UUID branchId) {
		return supabase
			.select("alert_rules", Map.of("select", "id,threshold_star,is_enabled", "branch_id", "eq." + branchId, "rule_type",
					"eq.LOW_RATING"), RULE_ROWS)
			.stream()
			.findFirst();
	}

	public void insertNotification(Map<String, Object> values) {
		supabase.insertWithoutReturn("notifications", values);
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record BranchInfo(UUID id, String name) {
	}

}
