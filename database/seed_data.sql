-- ==============================================================================
-- SEED DATA MẪU: Maison Coffee & Bistro
-- File: database/seed_data.sql
-- ==============================================================================

-- 1. Thêm cơ sở mẫu
INSERT INTO businesses (id, brand_name, display_name, industry, phone, logo_url, primary_color, tax_code, public_slug, status)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'Maison Coffee & Bistro',
    'Maison Coffee & Bistro',
    'F&B',
    '0901234567',
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&auto=format&fit=crop&q=80',
    '#2C1810',
    '0312345678',
    'maison-coffee',
    'ACTIVE'
) ON CONFLICT (id) DO NOTHING;

-- 2. Thêm chi nhánh mẫu
INSERT INTO branches (id, business_id, code, name, address, hotline, status)
VALUES (
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'CN-Q1',
    'Chi nhánh Quận 1 - Đồng Khởi',
    '123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    '02838221122',
    'ACTIVE'
) ON CONFLICT (id) DO NOTHING;

-- 3. Thêm mã QR mẫu (Bàn 04)
INSERT INTO qr_codes (id, branch_id, code, type, name, status)
VALUES (
    'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'MC-B04',
    'TABLE',
    'Bàn 04',
    'ACTIVE'
) ON CONFLICT (id) DO NOTHING;

-- 4. Thêm nền tảng Google Maps cho chi nhánh
INSERT INTO review_platforms (id, branch_id, platform_name, google_place_id, review_direct_url, place_name, place_address, connection_status, routing_weight_percent, is_active)
VALUES (
    'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'Google Maps',
    'ChIJ1234567890abcdef',
    'https://maps.google.com/?cid=1234567890',
    'Maison Coffee & Bistro - Đồng Khởi',
    '123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    'CONNECTED',
    100.00,
    TRUE
) ON CONFLICT (id) DO NOTHING;

