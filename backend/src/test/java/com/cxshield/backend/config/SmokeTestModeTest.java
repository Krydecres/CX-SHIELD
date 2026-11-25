package com.cxshield.backend.config;

import com.cxshield.backend.entity.Branch;
import com.cxshield.backend.entity.Business;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.entity.ReviewPlatform;
import com.cxshield.backend.entity.SurveyResponse;
import com.cxshield.backend.entity.SurveySession;
import com.cxshield.backend.repository.BranchRepository;
import com.cxshield.backend.repository.BusinessRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.repository.ReviewPlatformRepository;
import com.cxshield.backend.repository.SurveyResponseRepository;
import com.cxshield.backend.repository.SurveySessionRepository;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

class SmokeTestModeTest {

    @Test
    @DisplayName("Default / Production profile: SmokeTestMode is disabled")
    void testDefaultProfileIsDisabled() {
        MockEnvironment env = new MockEnvironment();
        SmokeTestMode mode = new SmokeTestMode(env);
        assertFalse(mode.isEnabled());
    }

    @Test
    @DisplayName("Smoke profile: SmokeTestMode is enabled")
    void testSmokeProfileIsEnabled() {
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("smoke");
        SmokeTestMode mode = new SmokeTestMode(env);
        assertTrue(mode.isEnabled());
    }

    @Test
    @DisplayName("Production mode: Repositories call Supabase, never fallback to memory")
    void testProductionModeCallsSupabase() {
        SupabaseAdminClient supabase = mock(SupabaseAdminClient.class);
        SmokeTestMode disabledMode = new SmokeTestMode(new MockEnvironment()); // default: disabled

        QrCodeRepository qrRepo = new QrCodeRepository(supabase, disabledMode);
        BranchRepository branchRepo = new BranchRepository(supabase, disabledMode);
        BusinessRepository bizRepo = new BusinessRepository(supabase, disabledMode);
        SurveySessionRepository sessRepo = new SurveySessionRepository(supabase, disabledMode);
        SurveyResponseRepository respRepo = new SurveyResponseRepository(supabase, disabledMode);
        ReviewPlatformRepository platRepo = new ReviewPlatformRepository(supabase, disabledMode);

        // When smokeMode is false, findByCode must query Supabase
        qrRepo.findByCode("MC-B04");
        verify(supabase, times(1)).select(eq("qr_codes"), any(), any());

        UUID branchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
        branchRepo.findById(branchId);
        verify(supabase, times(1)).select(eq("branches"), any(), any());

        UUID bizId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
        bizRepo.findById(bizId);
        verify(supabase, times(1)).select(eq("businesses"), any(), any());

        UUID sessId = UUID.randomUUID();
        sessRepo.findById(sessId);
        verify(supabase, times(1)).select(eq("survey_sessions"), any(), any());

        UUID respId = UUID.randomUUID();
        respRepo.findById(respId);
        verify(supabase, times(1)).select(eq("survey_responses"), any(), any());

        platRepo.findByBranchId(branchId);
        verify(supabase, times(1)).select(eq("review_platforms"), any(), any());
    }

    @Test
    @DisplayName("Smoke mode: Repositories use in-memory store without calling Supabase")
    void testSmokeModeUsesInMemoryStore() {
        SupabaseAdminClient supabase = mock(SupabaseAdminClient.class);
        MockEnvironment env = new MockEnvironment();
        env.setActiveProfiles("smoke");
        SmokeTestMode enabledMode = new SmokeTestMode(env);

        QrCodeRepository qrRepo = new QrCodeRepository(supabase, enabledMode);
        BranchRepository branchRepo = new BranchRepository(supabase, enabledMode);
        BusinessRepository bizRepo = new BusinessRepository(supabase, enabledMode);
        SurveySessionRepository sessRepo = new SurveySessionRepository(supabase, enabledMode);
        SurveyResponseRepository respRepo = new SurveyResponseRepository(supabase, enabledMode);
        ReviewPlatformRepository platRepo = new ReviewPlatformRepository(supabase, enabledMode);

        // 1. Quét QR MC-B04
        Optional<QrCode> qr = qrRepo.findByCode("MC-B04");
        assertTrue(qr.isPresent());
        assertEquals("MC-B04", qr.get().getCode());
        assertEquals("Bàn 04", qr.get().getName());

        // 2. Tra cứu chi nhánh
        Optional<Branch> branch = branchRepo.findById(qr.get().getBranchId());
        assertTrue(branch.isPresent());
        assertEquals("Chi nhánh Quận 1 - Đồng Khởi", branch.get().getName());

        // 3. Tra cứu cơ sở
        Optional<Business> biz = bizRepo.findById(branch.get().getBusinessId());
        assertTrue(biz.isPresent());
        assertEquals("Maison Coffee & Bistro", biz.get().getDisplayName());

        // 4. Lưu và tra cứu session
        SurveySession session = new SurveySession();
        session.setBusinessId(biz.get().getId());
        session.setBranchId(branch.get().getId());
        session.setQrCodeId(qr.get().getId());
        session.setStatus("STARTED");
        sessRepo.save(session);
        assertNotNull(session.getId());

        Optional<SurveySession> foundSess = sessRepo.findById(session.getId());
        assertTrue(foundSess.isPresent());
        assertEquals("STARTED", foundSess.get().getStatus());

        // 5. Lưu và tra cứu response
        SurveyResponse response = new SurveyResponse();
        response.setSessionId(session.getId());
        response.setStarRating(5);
        response.setSentimentGroup("POSITIVE");
        respRepo.save(response);
        assertNotNull(response.getId());

        Optional<SurveyResponse> foundResp = respRepo.findById(response.getId());
        assertTrue(foundResp.isPresent());
        assertEquals(5, foundResp.get().getStarRating());

        // 6. Tra cứu platform Google Maps
        Optional<ReviewPlatform> plat = platRepo.findByBranchId(branch.get().getId());
        assertTrue(plat.isPresent());
        assertEquals("Google Maps", plat.get().getPlatformName());

        // Xác nhận hoàn toàn KHÔNG gọi Supabase
        verifyNoInteractions(supabase);
    }
}
