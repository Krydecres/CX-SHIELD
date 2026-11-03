-- ==============================================================================
-- PHÂN HỆ 3: TÀI KHOẢN & THIẾT LẬP CỦA CHỦ CƠ SỞ (CORE TABLES)
-- File: database/n3_thiet_lap.sql
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Bảng cơ sở kinh doanh (Business / Tenant)
CREATE TABLE IF NOT EXISTS businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_name TEXT NOT NULL,
    display_name TEXT NOT NULL,
    industry TEXT,
    phone TEXT,
    logo_url TEXT,
    primary_color TEXT DEFAULT '#1E3A8A',
    tax_code TEXT,
    public_slug TEXT UNIQUE,
    status TEXT DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng chi nhánh (Branch)
CREATE TABLE IF NOT EXISTS branches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    code TEXT NOT NULL,
    name TEXT NOT NULL,
    address TEXT,
    hotline TEXT,
    manager_membership_id UUID,
    status TEXT DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_branches_business_code UNIQUE (business_id, code)
);

-- 3. Bảng mã QR (QRCode)
CREATE TABLE IF NOT EXISTS qr_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID NOT NULL,
    code TEXT UNIQUE NOT NULL,
    type TEXT DEFAULT 'TABLE', -- TABLE, AREA, COUNTER, STAFF
    name TEXT NOT NULL,        -- Ví dụ: Bàn 04, Khu VIP 1, Quầy 1
    shift_id UUID,
    membership_id UUID,
    status TEXT DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

