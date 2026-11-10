-- ==============================================================================
-- PHÂN HỆ 1: PHỄU KHẢO SÁT CỦA KHÁCH (SURVEY FUNNEL)
-- File: database/n1_khao_sat.sql
-- ==============================================================================

-- 1. Bảng phiên khảo sát (SurveySession)
CREATE TABLE IF NOT EXISTS survey_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    qr_code_id UUID NOT NULL,
    branch_id UUID NOT NULL,
    customer_id UUID,
    pos_transaction_id UUID,
    table_or_area_code TEXT,
    client_ip TEXT,
    user_agent TEXT,
    recaptcha_score NUMERIC(3, 2),
    status TEXT DEFAULT 'STARTED', -- STARTED, COMPLETED, EXPIRED, CANCELLED
    started_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng kết quả đánh giá sao (SurveyResponse)
CREATE TABLE IF NOT EXISTS survey_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    session_id UUID NOT NULL,
    star_rating INTEGER NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
    sentiment_group TEXT NOT NULL, -- SATISFIED (4-5 sao) hoặc UNSATISFIED (1-3 sao)
    selected_keyword_ids UUID[],
    copied_prompt_text TEXT,
    is_public_bypass BOOLEAN DEFAULT FALSE,
    review_platform_id UUID,
    redirect_clicked_at TIMESTAMPTZ,
    rated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng nền tảng đánh giá (ReviewPlatform)
CREATE TABLE IF NOT EXISTS review_platforms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID NOT NULL,
    platform_name TEXT NOT NULL DEFAULT 'Google Maps',
    google_place_id TEXT,
    review_direct_url TEXT,
    place_name TEXT,
    place_address TEXT,
    connection_status TEXT DEFAULT 'CONNECTED',
    routing_weight_percent NUMERIC(5, 2) DEFAULT 100.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng góp ý nội bộ (Feedback)
CREATE TABLE IF NOT EXISTS feedbacks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL,
    branch_id UUID,
    response_id UUID NOT NULL,
    customer_id UUID,
    comment_text TEXT,
    customer_phone TEXT,
    contact_purpose TEXT,
    consent_at TIMESTAMPTZ,
    voice_record_url TEXT,
    voice_duration_seconds INTEGER,
    transcript_text TEXT,
    stt_status TEXT DEFAULT 'PENDING',
    is_urgent_callback BOOLEAN DEFAULT FALSE,
    urgency_level INTEGER DEFAULT 1,
    status TEXT DEFAULT 'NEW',
    submitted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
