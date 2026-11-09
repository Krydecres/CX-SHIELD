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

-- Liên kết survey_sessions -> qr_codes & branches
ALTER TABLE survey_sessions
    ADD CONSTRAINT fk_survey_sessions_qr_code
    FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id) ON DELETE RESTRICT;

ALTER TABLE survey_sessions
    ADD CONSTRAINT fk_survey_sessions_branch
    FOREIGN KEY (branch_id) REFERENCES branches(id) ON DELETE CASCADE;

-- Liên kết survey_responses -> survey_sessions & review_platforms
ALTER TABLE survey_responses
    ADD CONSTRAINT fk_survey_responses_session
    FOREIGN KEY (session_id) REFERENCES survey_sessions(id) ON DELETE CASCADE;

ALTER TABLE survey_responses
    ADD CONSTRAINT fk_survey_responses_platform
    FOREIGN KEY (review_platform_id) REFERENCES review_platforms(id) ON DELETE SET NULL;

-- Liên kết feedbacks -> survey_responses
ALTER TABLE feedbacks
    ADD CONSTRAINT fk_feedbacks_response
    FOREIGN KEY (response_id) REFERENCES survey_responses(id) ON DELETE CASCADE;

-- Liên kết feedback_topics -> businesses [E1.3]
ALTER TABLE feedback_topics
    ADD CONSTRAINT fk_feedback_topics_business
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE;

-- Liên kết feedback_topic_links -> feedbacks & feedback_topics [E1.3]
ALTER TABLE feedback_topic_links
    ADD CONSTRAINT fk_topic_links_feedback
    FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE CASCADE;

ALTER TABLE feedback_topic_links
    ADD CONSTRAINT fk_topic_links_topic
    FOREIGN KEY (topic_id) REFERENCES feedback_topics(id) ON DELETE CASCADE;


