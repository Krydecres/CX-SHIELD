package com.cxshield.backend;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.PrintDesignController;
import com.cxshield.backend.controller.QrCodeController;
import com.cxshield.backend.dto.PrintDesignRequestDto;
import com.cxshield.backend.dto.PrintDesignResponseDto;
import com.cxshield.backend.dto.QrCodeRequestDto;
import com.cxshield.backend.dto.QrCodeResponseDto;
import com.cxshield.backend.entity.PrintTemplate;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.repository.PrintDesignRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.service.PrintExportService;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

/**
 * SCRUM-234: Bộ kiểm thử mã nguồn Studio Thiết Kế Ấn Phẩm QR [E5.1].
 * Kiểm thử chi tiết 7 trọng tâm nghiệp vụ:
 * 1. Tạo mã QR cho chi nhánh.
 * 2. Không tạo QR trùng nếu chi nhánh đã có mã.
 * 3. Lưu và đọc dữ liệu print_designs.
 * 4. Kiểm tra định dạng và kích thước file logo.
 * 5. Kiểm tra nội dung CTA.
 * 6. Kiểm tra quyền truy cập theo cơ sở/chi nhánh.
 * 7. Xử lý lỗi đầu vào, lỗi lưu dữ liệu và lỗi hệ thống.
 */
class QrStudioSourceTest {

    private QrCodeRepository qrCodeRepository;
    private PrintDesignRepository printDesignRepository;
    private PrintExportService printExportService;
    private QrCodeController qrCodeController;
    private PrintDesignController printDesignController;

    private final UUID existingBranchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
    private final UUID existingQrId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
    private final UUID existingBusinessId = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
    private final UUID existingDesignId = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");

    @BeforeEach
    void setUp() {
        qrCodeRepository = new QrCodeRepository();
        printDesignRepository = new PrintDesignRepository();
        printExportService = new PrintExportService();

        qrCodeController = new QrCodeController(qrCodeRepository);
        printDesignController = new PrintDesignController(printDesignRepository, qrCodeRepository, printExportService);
    }

    // =========================================================================
    // TRỌNG TÂM 1: Tạo mã QR cho chi nhánh
    // =========================================================================

    @Test
    @DisplayName("TC-234-01: Tạo mã QR cho chi nhánh với các loại vị trí tự sinh đúng tiền tố mã")
    void testCreateQrCodeWithVariousTypesGeneratesCorrectPrefix() {
        UUID branchId = UUID.randomUUID();

        // 1. TABLE -> MC-BAN
        QrCodeRequestDto tableReq = new QrCodeRequestDto(branchId, null, "TABLE", "Bàn VIP 01");
        ApiResponse<QrCodeResponseDto> tableRes = qrCodeController.createQrCode(tableReq);
        assertTrue(tableRes.isSuccess());
        assertTrue(tableRes.getData().code().startsWith("MC-BAN"));
        assertEquals("TABLE", tableRes.getData().type());
        assertEquals("Bàn VIP 01", tableRes.getData().name());

        // 2. COUNTER -> MC-QUAY
        QrCodeRequestDto counterReq = new QrCodeRequestDto(branchId, null, "COUNTER", "Quầy Bar");
        ApiResponse<QrCodeResponseDto> counterRes = qrCodeController.createQrCode(counterReq);
        assertTrue(counterRes.isSuccess());
        assertTrue(counterRes.getData().code().startsWith("MC-QUAY"));
        assertEquals("COUNTER", counterRes.getData().type());

        // 3. AREA -> MC-KHU
        QrCodeRequestDto areaReq = new QrCodeRequestDto(branchId, null, "AREA", "Khu Vườn Ngoài Trời");
        ApiResponse<QrCodeResponseDto> areaRes = qrCodeController.createQrCode(areaReq);
        assertTrue(areaRes.isSuccess());
        assertTrue(areaRes.getData().code().startsWith("MC-KHU"));

        // 4. STAFF -> MC-NV
        QrCodeRequestDto staffReq = new QrCodeRequestDto(branchId, null, "STAFF", "Nhân viên Order");
        ApiResponse<QrCodeResponseDto> staffRes = qrCodeController.createQrCode(staffReq);
        assertTrue(staffRes.isSuccess());
        assertTrue(staffRes.getData().code().startsWith("MC-NV"));
    }

    @Test
    @DisplayName("TC-234-02: Đảm bảo mã QR tạo ra có targetUrl đúng chuẩn khảo sát và status mặc định ACTIVE")
    void testCreateQrCodeDefaultValuesAndTargetUrlFormat() {
        QrCodeRequestDto req = new QrCodeRequestDto(existingBranchId, "MC-BAN99", "TABLE", "Bàn 99");
        ApiResponse<QrCodeResponseDto> res = qrCodeController.createQrCode(req);

        assertTrue(res.isSuccess());
        QrCodeResponseDto dto = res.getData();
        assertEquals("MC-BAN99", dto.code());
        assertEquals("ACTIVE", dto.status());
        assertEquals("https://cxshield.vn/survey?qr=MC-BAN99", dto.targetUrl());
        assertNotNull(dto.id());
        assertNotNull(dto.createdAt());
    }

    // =========================================================================
    // TRỌNG TÂM 2: Không tạo QR trùng nếu chi nhánh đã có mã
    // =========================================================================

    @Test
    @DisplayName("TC-234-03: ensureDefaultQrCode không tạo mã trùng nếu chi nhánh đã có ít nhất một mã QR")
    void testEnsureDefaultQrCodeWhenBranchAlreadyHasQr() {
        // Chi nhánh existingBranchId đã có mã MC-B04 sẵn trong repo
        List<QrCodeResponseDto> initialQrs = qrCodeController.getQrCodes(existingBranchId).getData();
        assertEquals(1, initialQrs.size());
        assertEquals("MC-B04", initialQrs.getFirst().code());

        // Gọi ensureDefaultQrCode
        ApiResponse<QrCodeResponseDto> response = qrCodeController.ensureDefaultQrCode(existingBranchId);

        assertTrue(response.isSuccess());
        assertEquals("Chi nhánh đã có mã QR", response.getMessage());
        assertEquals("MC-B04", response.getData().code());

        // Đảm bảo không tạo thêm bất kỳ bản ghi thừa nào
        List<QrCodeResponseDto> afterQrs = qrCodeController.getQrCodes(existingBranchId).getData();
        assertEquals(1, afterQrs.size());
    }

    @Test
    @DisplayName("TC-234-04: Lưu và tra cứu mã QR theo code tùy chỉnh (Ghi nhận hiện trạng tính duy nhất của mã)")
    void testCreateQrCodeCustomCodeIndexAndUniquenessObservation() {
        UUID branchId = UUID.randomUUID();
        QrCodeRequestDto req1 = new QrCodeRequestDto(branchId, "MC-VIP-SPECIAL", "TABLE", "Bàn VIP Đặc Biệt");
        ApiResponse<QrCodeResponseDto> res1 = qrCodeController.createQrCode(req1);

        assertTrue(res1.isSuccess());
        assertEquals("MC-VIP-SPECIAL", res1.getData().code());

        // Tra cứu qua repository findByCode
        assertTrue(qrCodeRepository.findByCode("MC-VIP-SPECIAL").isPresent());
        assertEquals(res1.getData().id(), qrCodeRepository.findByCode("MC-VIP-SPECIAL").get().getId());

        // Ghi nhận hiện trạng: backend cho phép tạo thêm QR trùng mã code mà không ném ngoại lệ 409
        QrCodeRequestDto reqDuplicate = new QrCodeRequestDto(branchId, "MC-VIP-SPECIAL", "COUNTER", "Quầy trùng code");
        ApiResponse<QrCodeResponseDto> resDup = qrCodeController.createQrCode(reqDuplicate);
        assertTrue(resDup.isSuccess());
        assertNotEquals(res1.getData().id(), resDup.getData().id());
    }

    // =========================================================================
    // TRỌNG TÂM 3: Lưu và đọc dữ liệu print_designs
    // =========================================================================

    @Test
    @DisplayName("TC-234-05: Lưu và đọc dữ liệu print_designs đầy đủ thuộc tính mẫu, màu sắc, khổ in")
    void testSaveAndLoadPrintDesignFullLifecycle() {
        UUID newDesignId = UUID.randomUUID();
        PrintDesignRequestDto request = new PrintDesignRequestDto(
                newDesignId,
                existingBusinessId,
                existingQrId,
                "COUNTER_STAND",
                "Highland Roastery",
                "Quét mã phản hồi nhận ngay voucher 20%",
                "#047857",
                "https://images.unsplash.com/logo-hl.png",
                "PNG",
                "A5"
        );

        ApiResponse<PrintDesignResponseDto> createRes = printDesignController.createOrUpdateDesign(request);
        assertTrue(createRes.isSuccess());
        assertEquals("Highland Roastery", createRes.getData().brandName());
        assertEquals("COUNTER_STAND", createRes.getData().template());
        assertEquals("Đế mica quầy thu ngân (A5)", createRes.getData().templateName());
        assertEquals("#047857", createRes.getData().color());
        assertEquals("A5", createRes.getData().size());
        assertEquals("PNG", createRes.getData().exportFormat());

        // Đọc lại qua getDesignById
        ApiResponse<PrintDesignResponseDto> getRes = printDesignController.getDesignById(newDesignId);
        assertTrue(getRes.isSuccess());
        assertEquals("Highland Roastery", getRes.getData().brandName());
        assertEquals(existingQrId, getRes.getData().qrCodeId());
        assertEquals("MC-B04", getRes.getData().qrCodeValue());
    }

    @Test
    @DisplayName("TC-234-06: Xóa mẫu thiết kế ấn phẩm thành công và trả về 404 khi truy vấn lại hoặc xóa tiếp")
    void testDeletePrintDesignLifecycle() {
        // Xóa mẫu mặc định
        ApiResponse<Void> deleteRes = printDesignController.deleteDesign(existingDesignId);
        assertTrue(deleteRes.isSuccess());

        // Truy vấn lại phải ném 404 DESIGN_NOT_FOUND
        ApiException getEx = assertThrows(ApiException.class, () -> printDesignController.getDesignById(existingDesignId));
        assertEquals("DESIGN_NOT_FOUND", getEx.getCode());
        assertEquals(HttpStatus.NOT_FOUND, getEx.getStatus());

        // Xóa lần nữa cũng ném 404 DESIGN_NOT_FOUND
        ApiException delEx = assertThrows(ApiException.class, () -> printDesignController.deleteDesign(existingDesignId));
        assertEquals("DESIGN_NOT_FOUND", delEx.getCode());
    }

    // =========================================================================
    // TRỌNG TÂM 4: Kiểm tra định dạng và kích thước file logo
    // =========================================================================

    @Test
    @DisplayName("TC-234-07: Lưu mẫu thiết kế với logoUrl hợp lệ dạng HTTPS URL được lưu trữ đầy đủ")
    void testSavePrintDesignWithValidLogoUrl() {
        String validLogo = "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400&format=png";
        PrintDesignRequestDto request = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                existingQrId,
                "TABLE_TENT",
                "Café De Paris",
                "Quét mã đánh giá nhận croissant",
                "#1E3A8A",
                validLogo,
                "PDF",
                "A6"
        );

        ApiResponse<PrintDesignResponseDto> res = printDesignController.createOrUpdateDesign(request);
        assertTrue(res.isSuccess());
        assertEquals(validLogo, res.getData().logoUrl());
    }

    @Test
    @DisplayName("TC-234-08: Kiểm tra giới hạn kiểm soát logo: Backend thiếu tầng validate định dạng file và kích thước (Observation)")
    void testLogoValidationBackendLacksFormatAndSizeEnforcementObservation() {
        // Truyền URL đuôi .exe hoặc không phải định dạng ảnh chuẩn
        String nonImageUrl = "https://malicious.example.com/payload.exe";
        PrintDesignRequestDto request = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                existingQrId,
                "WINDOW_STICKER",
                "Tiệm Bánh Ngọt",
                "Quét mã tích điểm",
                "#B91C1C",
                nonImageUrl,
                "PDF",
                "A6"
        );

        // Hiện tại backend không kiểm tra header Content-Type hay đuôi file ảnh mà vẫn lưu thành công
        ApiResponse<PrintDesignResponseDto> res = printDesignController.createOrUpdateDesign(request);
        assertTrue(res.isSuccess());
        assertEquals(nonImageUrl, res.getData().logoUrl());
    }

    // =========================================================================
    // TRỌNG TÂM 5: Kiểm tra nội dung CTA
    // =========================================================================

    @Test
    @DisplayName("TC-234-09: Tự động trim khoảng trắng và gán nội dung CTA mặc định chuẩn khi để trống")
    void testCtaTextTrimWhitespaceAndDefaultFallback() {
        // Trường hợp ctaText là null -> fallback về giá trị mặc định chuẩn
        PrintDesignRequestDto nullCtaReq = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                existingQrId,
                "TABLE_TENT",
                "Quán Ăn Ngon",
                null,
                "#1E3A8A",
                null,
                "PDF",
                "A6"
        );
        ApiResponse<PrintDesignResponseDto> nullCtaRes = printDesignController.createOrUpdateDesign(nullCtaReq);
        assertTrue(nullCtaRes.isSuccess());
        assertEquals("Quét mã để đánh giá & nhận ưu đãi", nullCtaRes.getData().ctaText());

        // Trường hợp ctaText có khoảng trắng đầu cuối -> tự động trim
        PrintDesignRequestDto paddedCtaReq = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                existingQrId,
                "TABLE_TENT",
                "Quán Ăn Ngon",
                "   Góp ý ngay nhận quà liền tay   ",
                "#1E3A8A",
                null,
                "PDF",
                "A6"
        );
        ApiResponse<PrintDesignResponseDto> paddedCtaRes = printDesignController.createOrUpdateDesign(paddedCtaReq);
        assertTrue(paddedCtaRes.isSuccess());
        assertEquals("Góp ý ngay nhận quà liền tay", paddedCtaRes.getData().ctaText());
    }

    @Test
    @DisplayName("TC-234-10: Nội dung CTA hỗ trợ ký tự tiếng Việt có dấu và ký tự đặc biệt, xuất ấn phẩm thành công")
    void testCtaTextSupportsVietnameseUnicodeAndExport() throws IOException {
        String unicodeCta = "Quét mã để đánh giá & nhận ngay quà tri ân từ quán!";
        PrintDesignRequestDto req = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                existingQrId,
                "CARD_NFC",
                "Maison Coffee & Bistro",
                unicodeCta,
                "#3B82F6",
                null,
                "PDF",
                "A6"
        );

        ApiResponse<PrintDesignResponseDto> saveRes = printDesignController.createOrUpdateDesign(req);
        assertTrue(saveRes.isSuccess());
        assertEquals(unicodeCta, saveRes.getData().ctaText());

        // Xuất file in ấn với CTA tiếng Việt để đảm bảo không lỗi font/graphics
        ResponseEntity<byte[]> exportRes = printDesignController.exportPrintDesign(saveRes.getData().id(), "pdf", 300);
        assertEquals(200, exportRes.getStatusCode().value());
        assertNotNull(exportRes.getBody());
        assertTrue(exportRes.getBody().length > 1000);
    }

    // =========================================================================
    // TRỌNG TÂM 6: Kiểm tra quyền truy cập theo cơ sở/chi nhánh
    // =========================================================================

    @Test
    @DisplayName("TC-234-11: Cô lập dữ liệu thiết kế print_designs theo cơ sở (businessId) ngăn ngừa rò rỉ dữ liệu")
    void testTenantIsolationPrintDesignsByBusinessId() {
        UUID bizA = UUID.randomUUID();
        UUID bizB = UUID.randomUUID();

        // Tạo thiết kế cho cơ sở A
        PrintDesignRequestDto designA = new PrintDesignRequestDto(
                UUID.randomUUID(), bizA, existingQrId, "TABLE_TENT", "Brand Cơ sở A", "CTA A", "#1E3A8A", null, "PDF", "A6"
        );
        printDesignController.createOrUpdateDesign(designA);

        // Tạo thiết kế cho cơ sở B
        PrintDesignRequestDto designB = new PrintDesignRequestDto(
                UUID.randomUUID(), bizB, existingQrId, "TABLE_TENT", "Brand Cơ sở B", "CTA B", "#1E3A8A", null, "PDF", "A6"
        );
        printDesignController.createOrUpdateDesign(designB);

        // Lấy danh sách theo bizA chỉ thấy của bizA
        List<PrintDesignResponseDto> listA = printDesignController.getDesigns(bizA).getData();
        assertEquals(1, listA.size());
        assertEquals("Brand Cơ sở A", listA.getFirst().brandName());

        // Lấy danh sách theo bizB chỉ thấy của bizB
        List<PrintDesignResponseDto> listB = printDesignController.getDesigns(bizB).getData();
        assertEquals(1, listB.size());
        assertEquals("Brand Cơ sở B", listB.getFirst().brandName());
    }

    @Test
    @DisplayName("TC-234-12: Cô lập dữ liệu mã QR theo chi nhánh qua mock Supabase PostgREST client (Live RLS: NOT RUN)")
    void testBranchIsolationQrCodesFilteredByBranchIdMockSupabase() {
        SupabaseAdminClient mockSupabase = Mockito.mock(SupabaseAdminClient.class);
        UUID targetBranchId = UUID.randomUUID();
        QrCode branchQr = new QrCode(UUID.randomUUID(), targetBranchId, "MC-CN01", "TABLE", "Bàn 1 Chi nhánh 1", "ACTIVE");

        Mockito.when(mockSupabase.select(eq("qr_codes"), eq(Map.of("branch_id", "eq." + targetBranchId)), any()))
                .thenReturn(List.of(branchQr));

        QrCodeRepository repoWithSupabase = new QrCodeRepository(mockSupabase);
        List<QrCode> result = repoWithSupabase.findByBranchId(targetBranchId);

        assertEquals(1, result.size());
        assertEquals("MC-CN01", result.getFirst().getCode());
        assertEquals(targetBranchId, result.getFirst().getBranchId());

        // Xác nhận client mock gọi đúng query filter branch_id
        Mockito.verify(mockSupabase, Mockito.times(1))
                .select(eq("qr_codes"), eq(Map.of("branch_id", "eq." + targetBranchId)), any());
    }

    // =========================================================================
    // TRỌNG TÂM 7: Xử lý lỗi đầu vào, lỗi lưu dữ liệu và lỗi hệ thống
    // =========================================================================

    @Test
    @DisplayName("TC-234-13: Từ chối lưu thiết kế ấn phẩm khi qrCodeId không tồn tại trả về 400 QR_NOT_FOUND")
    void testCreateDesignWithNonExistentQrCodeThrows400() {
        UUID nonExistentQrId = UUID.randomUUID();
        PrintDesignRequestDto invalidQrReq = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingBusinessId,
                nonExistentQrId,
                "TABLE_TENT",
                "Quán Trà Sữa",
                "Quét mã nhận ưu đãi",
                "#1E3A8A",
                null,
                "PDF",
                "A6"
        );

        ApiException ex = assertThrows(ApiException.class, () -> printDesignController.createOrUpdateDesign(invalidQrReq));
        assertEquals("QR_NOT_FOUND", ex.getCode());
        assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
        assertEquals("Mã QR liên kết không tồn tại", ex.getMessage());
    }

    @Test
    @DisplayName("TC-234-14: Xử lý lỗi đầu vào: Từ chối branchId null hoặc brandName rỗng với IllegalArgumentException")
    void testInputValidationThrowsIllegalArgumentException() {
        // 1. Tạo QR thiếu branchId
        QrCodeRequestDto invalidQrDto = new QrCodeRequestDto(null, "MC-B01", "TABLE", "Bàn 1");
        IllegalArgumentException qrEx = assertThrows(
                IllegalArgumentException.class,
                () -> qrCodeController.createQrCode(invalidQrDto)
        );
        assertEquals("Chi nhánh không được để trống", qrEx.getMessage());

        // 2. Lưu thiết kế thiếu qrCodeId
        PrintDesignRequestDto missingQrDto = new PrintDesignRequestDto(
                UUID.randomUUID(), existingBusinessId, null, "TABLE_TENT", "Brand Test", "CTA", "#1E3A8A", null, "PDF", "A6"
        );
        IllegalArgumentException designQrEx = assertThrows(
                IllegalArgumentException.class,
                () -> printDesignController.createOrUpdateDesign(missingQrDto)
        );
        assertEquals("Mã QR liên kết không được để trống", designQrEx.getMessage());

        // 3. Lưu thiết kế với brandName rỗng / toàn khoảng trắng
        PrintDesignRequestDto blankBrandDto = new PrintDesignRequestDto(
                UUID.randomUUID(), existingBusinessId, existingQrId, "TABLE_TENT", "   ", "CTA", "#1E3A8A", null, "PDF", "A6"
        );
        IllegalArgumentException brandEx = assertThrows(
                IllegalArgumentException.class,
                () -> printDesignController.createOrUpdateDesign(blankBrandDto)
        );
        assertEquals("Tên thương hiệu không được để trống", brandEx.getMessage());
    }
}
