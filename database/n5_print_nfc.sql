-- ==============================================================================
-- PHÂN HỆ 5: TRÌNH TẠO & XUẤT BẢN ẤN PHẨM QR / ĐẶT THẺ CHẠM NFC
-- File: database/n5_print_nfc.sql
-- User Story: E5.3 - Xuất File In Ấn Chất lượng cao & Đặt Hàng Phôi Thẻ NFC Vật lý
-- Màn hình: D3-11
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Bảng thiết kế ấn phẩm in ấn (print_designs)
CREATE TABLE IF NOT EXISTS print_designs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    qr_code_id UUID NOT NULL,
    template TEXT NOT NULL DEFAULT 'TABLE_TENT', -- TABLE_TENT, COUNTER_STAND, STICKER, CARD_NFC
    brand_name TEXT NOT NULL,
    cta_text TEXT NOT NULL DEFAULT 'Quét mã để đánh giá & nhận ưu đãi',
    color TEXT NOT NULL DEFAULT '#1E3A8A',
    logo_url TEXT,
    export_format TEXT NOT NULL DEFAULT 'PDF', -- PDF, PNG
    size TEXT NOT NULL DEFAULT 'A6',           -- A6, A5, STAND, BADGE
    file_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_print_designs_business FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT fk_print_designs_qr_code FOREIGN KEY (qr_code_id) REFERENCES qr_codes(id) ON DELETE CASCADE
);

-- 2. Bảng đơn đặt hàng phôi thẻ NFC vật lý (nfc_orders)
CREATE TABLE IF NOT EXISTS nfc_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    design_id UUID NOT NULL,
    material TEXT NOT NULL,                    -- WOOD (Gỗ dẻ gai/Walnut), MICA (Mica/Acrylic trong suốt)
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    ship_name TEXT NOT NULL,
    ship_phone TEXT NOT NULL,
    ship_address TEXT NOT NULL,
    unit_price NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'PENDING',    -- PENDING, PROCESSING, SHIPPED, DELIVERED, CANCELLED
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_nfc_orders_business FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    CONSTRAINT fk_nfc_orders_design FOREIGN KEY (design_id) REFERENCES print_designs(id) ON DELETE RESTRICT
);

-- Chỉ mục hỗ trợ tra cứu nhanh
CREATE INDEX IF NOT EXISTS idx_print_designs_business ON print_designs(business_id);
CREATE INDEX IF NOT EXISTS idx_nfc_orders_business ON nfc_orders(business_id);
CREATE INDEX IF NOT EXISTS idx_nfc_orders_status ON nfc_orders(status);

