package com.cxshield.backend.repository;

import com.cxshield.backend.entity.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.json.JsonMapper;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class EntityJsonSerializationTest {

    private final JsonMapper jsonMapper = JsonMapper.builder().build();

    private Map<String, Object> toMap(Object obj) throws Exception {
        String json = jsonMapper.writeValueAsString(obj);
        return jsonMapper.readValue(json, new TypeReference<Map<String, Object>>() {});
    }

    private void assertAllKeysSnakeCaseAndValid(Map<String, Object> map, Set<String> allowedColumns) {
        for (String key : map.keySet()) {
            assertThat(allowedColumns)
                    .as("Key '%s' không nằm trong danh sách cột CSDL hợp lệ!", key)
                    .contains(key);

            // Đảm bảo không chứa camelCase (chữ in hoa)
            assertThat(key)
                    .as("Key '%s' chứa chữ in hoa (camelCase), vi phạm định dạng cột CSDL!", key)
                    .isEqualTo(key.toLowerCase());
        }
    }

    @Test
    @DisplayName("SurveyResponse: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa publicBypass hay camelCase")
    void surveyResponseJsonKeysMatchDatabaseColumns() throws Exception {
        SurveyResponse response = new SurveyResponse();
        response.setId(UUID.randomUUID());
        response.setBusinessId(UUID.randomUUID());
        response.setSessionId(UUID.randomUUID());
        response.setStarRating(5);
        response.setSentimentGroup("SATISFIED");
        response.setSelectedKeywordIds(List.of(UUID.randomUUID()));
        response.setCopiedPromptText("Món ăn rất ngon");
        response.setPublicBypass(true);
        response.setReviewPlatformId(UUID.randomUUID());
        response.setRedirectClickedAt(Instant.now());
        response.setRatedAt(Instant.now());
        response.setCreatedAt(Instant.now());
        response.setUpdatedAt(Instant.now());

        Map<String, Object> jsonMap = toMap(response);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "session_id", "star_rating", "sentiment_group",
                "selected_keyword_ids", "copied_prompt_text", "is_public_bypass",
                "review_platform_id", "redirect_clicked_at", "rated_at", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).containsKey("is_public_bypass");
        assertThat(jsonMap).doesNotContainKey("publicBypass");
        assertThat(jsonMap).doesNotContainKey("isPublicBypass");
        assertThat(jsonMap).doesNotContainKey("starRating");
        assertThat(jsonMap).doesNotContainKey("businessId");
        assertThat(jsonMap).doesNotContainKey("sessionId");
    }

    @Test
    @DisplayName("Feedback: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa urgentCallback hay camelCase")
    void feedbackJsonKeysMatchDatabaseColumns() throws Exception {
        Feedback feedback = new Feedback();
        feedback.setId(UUID.randomUUID());
        feedback.setBusinessId(UUID.randomUUID());
        feedback.setBranchId(UUID.randomUUID());
        feedback.setResponseId(UUID.randomUUID());
        feedback.setCustomerId(UUID.randomUUID());
        feedback.setCommentText("Góp ý phục vụ");
        feedback.setCustomerPhone("0901234567");
        feedback.setContactPurpose("Cần hỗ trợ gấp");
        feedback.setConsentAt(Instant.now());
        feedback.setVoiceRecordUrl("https://example.com/audio.mp3");
        feedback.setVoiceDurationSeconds(15);
        feedback.setTranscriptText("Đoạn ghi âm");
        feedback.setSttStatus("COMPLETED");
        feedback.setUrgentCallback(true);
        feedback.setUrgencyLevel(3);
        feedback.setStatus("NEW");
        feedback.setSubmittedAt(Instant.now());
        feedback.setCreatedAt(Instant.now());
        feedback.setUpdatedAt(Instant.now());

        Map<String, Object> jsonMap = toMap(feedback);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "branch_id", "response_id", "customer_id",
                "comment_text", "customer_phone", "contact_purpose", "consent_at",
                "voice_record_url", "voice_duration_seconds", "transcript_text",
                "stt_status", "is_urgent_callback", "urgency_level", "status",
                "submitted_at", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).containsKey("is_urgent_callback");
        assertThat(jsonMap).doesNotContainKey("urgentCallback");
        assertThat(jsonMap).doesNotContainKey("isUrgentCallback");
        assertThat(jsonMap).doesNotContainKey("businessId");
        assertThat(jsonMap).doesNotContainKey("branchId");
        assertThat(jsonMap).doesNotContainKey("responseId");
        assertThat(jsonMap).doesNotContainKey("commentText");
    }

    @Test
    @DisplayName("ReviewPlatform: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa active hay camelCase")
    void reviewPlatformJsonKeysMatchDatabaseColumns() throws Exception {
        ReviewPlatform platform = new ReviewPlatform(
                UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), "Google Maps", "ChIJ123",
                "https://maps.google.com", "Maison", "123 Le Loi"
        );
        platform.setActive(true);

        Map<String, Object> jsonMap = toMap(platform);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "branch_id", "platform_name", "google_place_id", "review_direct_url",
                "place_name", "place_address", "connection_status", "routing_weight_percent",
                "is_active", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).containsKey("is_active");
        assertThat(jsonMap).doesNotContainKey("active");
        assertThat(jsonMap).doesNotContainKey("isActive");
        assertThat(jsonMap).doesNotContainKey("businessId");
        assertThat(jsonMap).doesNotContainKey("branchId");
        assertThat(jsonMap).doesNotContainKey("platformName");
        assertThat(jsonMap).doesNotContainKey("googlePlaceId");
    }

    @Test
    @DisplayName("FeedbackTopic: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa active hay camelCase")
    void feedbackTopicJsonKeysMatchDatabaseColumns() throws Exception {
        FeedbackTopic topic = new FeedbackTopic(UUID.randomUUID(), UUID.randomUUID(), "Thái độ phục vụ", true);

        Map<String, Object> jsonMap = toMap(topic);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "name", "is_active", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).containsKey("is_active");
        assertThat(jsonMap).doesNotContainKey("active");
        assertThat(jsonMap).doesNotContainKey("isActive");
        assertThat(jsonMap).doesNotContainKey("businessId");
    }

    @Test
    @DisplayName("SurveySession: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa camelCase")
    void surveySessionJsonKeysMatchDatabaseColumns() throws Exception {
        SurveySession session = new SurveySession();
        session.setId(UUID.randomUUID());
        session.setBusinessId(UUID.randomUUID());
        session.setQrCodeId(UUID.randomUUID());
        session.setBranchId(UUID.randomUUID());
        session.setCustomerId(UUID.randomUUID());
        session.setPosTransactionId(UUID.randomUUID());
        session.setTableOrAreaCode("B04");
        session.setClientIp("127.0.0.1");
        session.setUserAgent("Mozilla/5.0");
        session.setRecaptchaScore(new BigDecimal("0.90"));
        session.setStatus("STARTED");
        session.setStartedAt(Instant.now());
        session.setCompletedAt(Instant.now());
        session.setCreatedAt(Instant.now());
        session.setUpdatedAt(Instant.now());

        Map<String, Object> jsonMap = toMap(session);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "qr_code_id", "branch_id", "customer_id",
                "pos_transaction_id", "table_or_area_code", "client_ip", "user_agent",
                "recaptcha_score", "status", "started_at", "completed_at", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).doesNotContainKey("businessId");
        assertThat(jsonMap).doesNotContainKey("qrCodeId");
        assertThat(jsonMap).doesNotContainKey("branchId");
        assertThat(jsonMap).doesNotContainKey("tableOrAreaCode");
    }

    @Test
    @DisplayName("QrCode: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa camelCase")
    void qrCodeJsonKeysMatchDatabaseColumns() throws Exception {
        QrCode qrCode = new QrCode(UUID.randomUUID(), UUID.randomUUID(), "MC-B04", "TABLE", "Bàn 04", "ACTIVE");
        qrCode.setShiftId(UUID.randomUUID());
        qrCode.setMembershipId(UUID.randomUUID());

        Map<String, Object> jsonMap = toMap(qrCode);

        Set<String> dbColumns = Set.of(
                "id", "branch_id", "code", "type", "name", "shift_id", "membership_id", "status", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).doesNotContainKey("branchId");
        assertThat(jsonMap).doesNotContainKey("shiftId");
        assertThat(jsonMap).doesNotContainKey("membershipId");
    }

    @Test
    @DisplayName("Branch: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa camelCase")
    void branchJsonKeysMatchDatabaseColumns() throws Exception {
        Branch branch = new Branch(UUID.randomUUID(), UUID.randomUUID(), "CN-Q1", "Chi nhánh Q1", "123 Đồng Khởi", "0901234567", "ACTIVE");
        branch.setManagerMembershipId(UUID.randomUUID());

        Map<String, Object> jsonMap = toMap(branch);

        Set<String> dbColumns = Set.of(
                "id", "business_id", "code", "name", "address", "hotline", "manager_membership_id", "status", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).doesNotContainKey("businessId");
        assertThat(jsonMap).doesNotContainKey("managerMembershipId");
    }

    @Test
    @DisplayName("Business: JSON gửi đi chỉ chứa đúng tên cột CSDL, không chứa camelCase")
    void businessJsonKeysMatchDatabaseColumns() throws Exception {
        Business business = new Business(UUID.randomUUID(), "Maison Coffee", "Maison Coffee", "F&B", "0901234567", "https://logo.png", "#FF5500", "0123456789", "maison-coffee", "ACTIVE");

        Map<String, Object> jsonMap = toMap(business);

        Set<String> dbColumns = Set.of(
                "id", "brand_name", "display_name", "industry", "phone", "logo_url", "primary_color", "tax_code", "public_slug", "status", "created_at", "updated_at"
        );

        assertAllKeysSnakeCaseAndValid(jsonMap, dbColumns);

        assertThat(jsonMap).doesNotContainKey("brandName");
        assertThat(jsonMap).doesNotContainKey("displayName");
        assertThat(jsonMap).doesNotContainKey("logoUrl");
        assertThat(jsonMap).doesNotContainKey("primaryColor");
        assertThat(jsonMap).doesNotContainKey("taxCode");
        assertThat(jsonMap).doesNotContainKey("publicSlug");
    }
}

