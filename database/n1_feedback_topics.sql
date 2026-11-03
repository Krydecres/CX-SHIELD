-- ==============================================================================
-- BỔ SUNG BẢNG CHỦ ĐỀ GÓP Ý (FEEDBACK TOPICS) CHO [E1.3]
-- File: database/n1_feedback_topics.sql
-- ==============================================================================

-- 1. Bảng chủ đề góp ý (FeedbackTopic)
CREATE TABLE IF NOT EXISTS feedback_topics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_feedback_topics_business FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- 2. Bảng liên kết góp ý - chủ đề (FeedbackTopicLink)
CREATE TABLE IF NOT EXISTS feedback_topic_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    feedback_id UUID,
    complaint_id UUID,
    topic_id UUID NOT NULL,
    source TEXT DEFAULT 'CUSTOMER_SELECT', -- CUSTOMER_SELECT, AI_EXTRACTED, MANUAL
    confidence NUMERIC(3, 2) DEFAULT 1.00,
    edited_manually BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_topic_links_feedback FOREIGN KEY (feedback_id) REFERENCES feedbacks(id) ON DELETE CASCADE,
    CONSTRAINT fk_topic_links_topic FOREIGN KEY (topic_id) REFERENCES feedback_topics(id) ON DELETE CASCADE
);

-- 3. Dữ liệu mẫu chủ đề góp ý cho Maison Coffee & Bistro
INSERT INTO feedback_topics (id, business_id, name, is_active)
VALUES 
    ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380001', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Món ăn / Đồ uống', TRUE),
    ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380002', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Thái độ phục vụ', TRUE),
    ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380003', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Thời gian chờ món', TRUE),
    ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380004', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Không gian & Vệ sinh', TRUE),
    ('e1eebc99-9c0b-4ef8-bb6d-6bb9bd380005', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Giá cả & Hóa đơn', TRUE)
ON CONFLICT (id) DO NOTHING;

