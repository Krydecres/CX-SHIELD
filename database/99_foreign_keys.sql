-- ==============================================================================
-- KHÓA NGOẠI LIÊN KẾT (FOREIGN KEYS)
-- File: database/99_foreign_keys.sql
-- ==============================================================================

-- Liên kết branches -> businesses
ALTER TABLE branches
    ADD CONSTRAINT fk_branches_business
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;

-- Liên kết qr_codes -> branches
ALTER TABLE qr_codes
    ADD CONSTRAINT fk_qr_codes_branch
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;

-- Liên kết survey_sessions -> businesses, qr_codes & branches
ALTER TABLE survey_sessions
    ADD CONSTRAINT fk_survey_sessions_business
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;

ALTER TABLE survey_sessions
    ADD CONSTRAINT fk_survey_sessions_qr_code
    FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id) ON DELETE RESTRICT;

ALTER TABLE survey_sessions
    ADD CONSTRAINT fk_survey_sessions_branch
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;

-- Liên kết survey_responses -> businesses, survey_sessions & review_platforms
ALTER TABLE survey_responses
    ADD CONSTRAINT fk_survey_responses_business
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;

ALTER TABLE survey_responses
    ADD CONSTRAINT fk_survey_responses_session
    FOREIGN KEY (session_id) REFERENCES survey_sessions(id) ON DELETE CASCADE;

ALTER TABLE survey_responses
    ADD CONSTRAINT fk_survey_responses_platform
    FOREIGN KEY (review_platform_id) REFERENCES review_platforms(id) ON DELETE SET NULL;

-- Liên kết feedbacks -> businesses & survey_responses
ALTER TABLE feedbacks
    ADD CONSTRAINT fk_feedbacks_business
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;

ALTER TABLE feedbacks
    ADD CONSTRAINT fk_feedbacks_response
    FOREIGN KEY (response_id) REFERENCES survey_responses(id) ON DELETE CASCADE;

-- Liên kết notifications -> feedbacks (E1.1 / E2.2)
ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_feedback
    FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE SET NULL;
