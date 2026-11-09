-- ==============================================================================
-- PHÂN HỆ 3: CÀI ĐẶT PHỄU - TỪ KHÓA GỢI Ý SEO & QUY TẮC PHÂN LUỒNG CẢM XÚC (E4.3)
-- Màn hình: D3-07 / M1-02
-- Bảng: review_keywords, routing_rules
-- ==============================================================================

-- 1. Bảng từ khóa gợi ý SEO theo ngành (ReviewKeyword)
CREATE TABLE IF NOT EXISTS review_keywords (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    industry TEXT NOT NULL,
    keyword TEXT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_review_keywords_business_industry
    ON review_keywords (business_id, industry, is_active);

-- 2. Bảng quy tắc phân luồng cảm xúc theo điểm sao (RoutingRule)
CREATE TABLE IF NOT EXISTS routing_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL UNIQUE,
    satisfied_min_score INTEGER NOT NULL DEFAULT 4 CHECK (satisfied_min_score BETWEEN 1 AND 5),
    satisfied_max_score INTEGER NOT NULL DEFAULT 5 CHECK (satisfied_max_score BETWEEN 1 AND 5),
    public_review_enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_routing_rules_business
    ON routing_rules (business_id);

-- Dữ liệu mẫu ban đầu cho cơ sở "Maison Coffee & Bistro" (F&B)
INSERT INTO routing_rules (business_id, satisfied_min_score, satisfied_max_score, public_review_enabled)
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 4, 5, true)
ON CONFLICT (business_id) DO NOTHING;

INSERT INTO review_keywords (business_id, industry, keyword, is_active)
VALUES
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Cà phê đậm đà ngon', true),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Không gian ấm cúng, view đẹp', true),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Nhân viên nhiệt tình, chu đáo', true),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Phục vụ nhanh chóng', true),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Đồ uống đa dạng, decor xinh', true),
    ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'F&B', 'Nhạc nhẹ nhàng, thư giãn', true)
ON CONFLICT DO NOTHING;
