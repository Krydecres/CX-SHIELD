package com.cxshield.backend.alert;

import java.time.OffsetDateTime;
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
 * Bảng alert_channels và alert_rules, gọi bằng token của người đang đăng nhập nên RLS giới hạn quyền.
 */
@Repository
public class AlertChannelRepository {

	static final String CHANNEL_COLUMNS = "id,business_id,branch_id,type,bot_token,chat_id,webhook_url,email,is_enabled,"
			+ "last_tested_at";

	private static final ParameterizedTypeReference<List<AlertChannelRow>> CHANNEL_ROWS = new ParameterizedTypeReference<>() {
	};
	private static final ParameterizedTypeReference<List<AlertRuleRow>> RULE_ROWS = new ParameterizedTypeReference<>() {
	};

	private final SupabaseDataClient supabase;

	public AlertChannelRepository(SupabaseDataClient supabase) {
		this.supabase = supabase;
	}

	public List<AlertChannelRow> findChannels(String token, UUID branchId) {
		return supabase.select(token, "alert_channels", Map.of("select", CHANNEL_COLUMNS, "branch_id", "eq." + branchId),
				CHANNEL_ROWS);
	}

	public Optional<AlertChannelRow> findChannel(String token, UUID branchId, AlertChannelType type) {
		return supabase
			.select(token, "alert_channels",
					Map.of("select", CHANNEL_COLUMNS, "branch_id", "eq." + branchId, "type", "eq." + type.name()),
					CHANNEL_ROWS)
			.stream()
			.findFirst();
	}

	public Optional<AlertChannelRow> insertChannel(String token, Map<String, Object> values) {
		return supabase.insert(token, "alert_channels", values, CHANNEL_ROWS).stream().findFirst();
	}

	/**
	 * Trả về rỗng khi RLS không cho cập nhật (PostgREST không báo lỗi mà chỉ trả 0 dòng).
	 */
	public Optional<AlertChannelRow> updateChannel(String token, UUID id, Map<String, Object> values) {
		return supabase.update(token, "alert_channels", Map.of("id", "eq." + id), values, CHANNEL_ROWS).stream().findFirst();
	}

	public Optional<AlertRuleRow> findLowRatingRule(String token, UUID branchId) {
		return supabase
			.select(token, "alert_rules", Map.of("select", "id,threshold_star,is_enabled", "branch_id", "eq." + branchId,
					"rule_type", "eq.LOW_RATING"), RULE_ROWS)
			.stream()
			.findFirst();
	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record AlertChannelRow(UUID id, @JsonProperty("business_id") UUID businessId,
			@JsonProperty("branch_id") UUID branchId, AlertChannelType type, @JsonProperty("bot_token") String botToken,
			@JsonProperty("chat_id") String chatId, @JsonProperty("webhook_url") String webhookUrl, String email,
			@JsonProperty("is_enabled") boolean enabled, @JsonProperty("last_tested_at") OffsetDateTime lastTestedAt) {

		/**
		 * Không in Bot Token và Webhook URL khi record bị ghi ra log.
		 */
		@Override
		public String toString() {
			return "AlertChannelRow[id=" + id + ", type=" + type + ", enabled=" + enabled + "]";
		}

	}

	@JsonIgnoreProperties(ignoreUnknown = true)
	public record AlertRuleRow(UUID id, @JsonProperty("threshold_star") int thresholdStar,
			@JsonProperty("is_enabled") boolean enabled) {
	}

}
