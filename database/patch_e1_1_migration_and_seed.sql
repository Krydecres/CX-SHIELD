-- ==============================================================================
-- BẢN VÁ CSDL CHO [E1.1]: MIGRATION BỔ SUNG & SEED MÃ QR
-- File: database/patch_e1_1_migration_and_seed.sql
-- Hướng dẫn: Mở Supabase Dashboard > SQL Editor, dán toàn bộ nội dung này và bấm RUN.
-- ==============================================================================

-- 1. Bổ sung cột branch_id cho bảng feedbacks (nếu chưa có)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'feedbacks' AND column_name = 'branch_id'
    ) THEN
        ALTER TABLE public.feedbacks ADD COLUMN branch_id UUID;
    END IF;
END $$;

-- 2. Thêm khóa ngoại feedbacks.branch_id -> branches.id (nếu chưa có)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_feedbacks_branch'
    ) THEN
        ALTER TABLE public.feedbacks 
            ADD CONSTRAINT fk_feedbacks_branch 
            FOREIGN KEY (branch_id) REFERENCES public.branches(id) ON DELETE CASCADE;
    END IF;
END $$;

-- 3. Thêm khóa ngoại notifications.feedback_id -> feedbacks.id (nếu chưa có)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_notifications_feedback'
    ) THEN
        ALTER TABLE public.notifications 
            ADD CONSTRAINT fk_notifications_feedback 
            FOREIGN KEY (feedback_id) REFERENCES public.feedbacks(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 4. Đảm bảo có Cơ sở mẫu (Maison Coffee & Bistro)
INSERT INTO public.businesses (id, brand_name, display_name, industry, phone, logo_url, primary_color, tax_code, public_slug, status)
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

-- 5. Đảm bảo có Chi nhánh mẫu (CN Quận 1)
INSERT INTO public.branches (id, business_id, code, name, address, hotline, status)
VALUES (
    'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'CN-Q1',
    'Chi nhánh Quận 1 - Đồng Khởi',
    '123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. Hồ Chí Minh',
    '02838221122',
    'ACTIVE'
) ON CONFLICT (id) DO NOTHING;

-- 6. Đảm bảo có nền tảng Google Maps cho chi nhánh mẫu
INSERT INTO public.review_platforms (id, business_id, branch_id, platform_name, google_place_id, review_direct_url, place_name, place_address, connection_status, routing_weight_percent, is_active)
VALUES (
    'd0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44',
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
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

-- 7. Thêm các mã QR mẫu cho Tester quét thử (đặc biệt là MC-B04 mặc định)
INSERT INTO public.qr_codes (id, branch_id, code, type, name, status)
VALUES
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'MC-B04', 'TABLE', 'Bàn 04', 'ACTIVE'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'MC-B01', 'TABLE', 'Bàn 01', 'ACTIVE'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a32', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'MC-B02', 'TABLE', 'Bàn 02', 'ACTIVE'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a35', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'MC-VIP', 'AREA', 'Khu VIP 01', 'ACTIVE'),
    ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a36', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'MC-QUAY', 'COUNTER', 'Quầy Thu Ngân', 'ACTIVE')
ON CONFLICT (code) DO UPDATE 
    SET status = 'ACTIVE', name = EXCLUDED.name, branch_id = EXCLUDED.branch_id;

-- 8. Tự động gắn thêm mã QR cho bất kỳ chi nhánh thật nào khác trên CSDL nếu chưa có mã QR
INSERT INTO public.qr_codes (branch_id, code, type, name, status)
SELECT 
    b.id, 
    CONCAT('QR-', SUBSTRING(b.id::text, 1, 6)), 
    'TABLE', 
    'Bàn 01', 
    'ACTIVE'
FROM public.branches b
WHERE NOT EXISTS (
    SELECT 1 FROM public.qr_codes q WHERE q.branch_id = b.id
);

