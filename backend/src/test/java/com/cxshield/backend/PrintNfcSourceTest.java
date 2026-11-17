package com.cxshield.backend;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.NfcOrderController;
import com.cxshield.backend.controller.PrintDesignController;
import com.cxshield.backend.dto.NfcOrderRequestDto;
import com.cxshield.backend.dto.NfcOrderResponseDto;
import com.cxshield.backend.dto.PrintDesignRequestDto;
import com.cxshield.backend.dto.PrintDesignResponseDto;
import com.cxshield.backend.entity.NfcOrder;
import com.cxshield.backend.entity.NfcOrderStatus;
import com.cxshield.backend.entity.PrintDesign;
import com.cxshield.backend.entity.PrintTemplate;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.repository.NfcOrderRepository;
import com.cxshield.backend.repository.PrintDesignRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.service.PrintExportService;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * SCRUM-237: [E5.3] Kiểm thử mã nguồn xuất file in ấn và đơn đặt thẻ NFC.
 * Phạm vi: Backend Controller, Service, Repository, Validation, Multi-tenant
 * Isolation.
 */
class PrintNfcSourceTest {

        private PrintDesignRepository printDesignRepository;
        private NfcOrderRepository nfcOrderRepository;
        private QrCodeRepository qrCodeRepository;
        private PrintExportService printExportService;
        private PrintDesignController printDesignController;
        private NfcOrderController nfcOrderController;

        private UUID businessIdA;
        private UUID businessIdB;
        private UUID designIdA;
        private UUID qrCodeIdA;
        private UUID orderIdA;

        @BeforeEach
        void setUp() {
                printDesignRepository = new PrintDesignRepository();
                nfcOrderRepository = new NfcOrderRepository();
                qrCodeRepository = new QrCodeRepository();
                printExportService = new PrintExportService();

                printDesignController = new PrintDesignController(printDesignRepository, qrCodeRepository,
                                printExportService);
                nfcOrderController = new NfcOrderController(nfcOrderRepository, printDesignRepository);

                businessIdA = UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");
                businessIdB = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
                designIdA = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");
                qrCodeIdA = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
                orderIdA = UUID.fromString("f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66");
        }

        // =========================================================================
        // PHẦN 1: LOGIC XUẤT FILE IN ẤN (PDF & PNG, 300 DPI, METADATA, DECODING)
        // =========================================================================

        @Test
        @DisplayName("SRC-237-01: Xuất PNG chuẩn kích thước A6 và A5 tương ứng cấu hình 300 DPI")
        void testExportPngResolutionA6AndA5() throws Exception {
                // 1. Kiểm tra xuất khổ A6
                ResponseEntity<byte[]> responseA6 = printDesignController.exportPrintDesign(designIdA, "png", 300);
                assertEquals(HttpStatus.OK, responseA6.getStatusCode());
                assertEquals(MediaType.IMAGE_PNG, responseA6.getHeaders().getContentType());
                assertEquals("300", responseA6.getHeaders().getFirst("X-Print-DPI"));
                assertNotNull(responseA6.getBody());

                BufferedImage imgA6 = ImageIO.read(new ByteArrayInputStream(responseA6.getBody()));
                assertNotNull(imgA6);
                assertEquals(PrintExportService.DPI_300_A6_WIDTH, imgA6.getWidth());
                assertEquals(PrintExportService.DPI_300_A6_HEIGHT, imgA6.getHeight());

                // 2. Kiểm tra xuất khổ A5
                PrintDesign designA5 = new PrintDesign(
                                UUID.randomUUID(), businessIdA, qrCodeIdA, PrintTemplate.TABLE_TENT,
                                "Maison A5", "CTA", "#1E3A8A", null, "PNG", "A5", null);
                printDesignRepository.save(designA5);

                ResponseEntity<byte[]> responseA5 = printDesignController.exportPrintDesign(designA5.getId(), "png",
                                300);
                BufferedImage imgA5 = ImageIO.read(new ByteArrayInputStream(responseA5.getBody()));
                assertEquals(PrintExportService.DPI_300_A5_WIDTH, imgA5.getWidth());
                assertEquals(PrintExportService.DPI_300_A5_HEIGHT, imgA5.getHeight());
        }

        @Test
        @DisplayName("SRC-237-02: Mã QR trong file PNG xuất ra có thể giải mã 100% bằng ZXing Reader")
        void testExportPngQrCodeIsDecodable() throws Exception {
                ResponseEntity<byte[]> response = printDesignController.exportPrintDesign(designIdA, "png", 300);
                BufferedImage img = ImageIO.read(new ByteArrayInputStream(response.getBody()));

                BufferedImageLuminanceSource source = new BufferedImageLuminanceSource(img);
                BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
                Result result = new MultiFormatReader().decode(bitmap);

                assertNotNull(result);
                assertEquals("https://cxshield.vn/survey?qr=MC-B04", result.getText());
        }

        @Test
        @DisplayName("SRC-237-03: Cấu hình DPI đầu vào tự động được chuẩn hóa lên tối thiểu 300 DPI")
        void testExportDpiNormalizationEnforcesMinimum300Dpi() throws Exception {
                // Khi client truyền dpi = 72 hoặc 150
                ResponseEntity<byte[]> response = printDesignController.exportPrintDesign(designIdA, "png", 72);
                assertEquals("300", response.getHeaders().getFirst("X-Print-DPI"));

                BufferedImage img = ImageIO.read(new ByteArrayInputStream(response.getBody()));
                assertEquals(PrintExportService.DPI_300_A6_WIDTH, img.getWidth());
                assertEquals(PrintExportService.DPI_300_A6_HEIGHT, img.getHeight());
        }

        @Test
        @DisplayName("SRC-237-04: Phân tích metadata PNG - Xác nhận ImageIO chỉ ghi cấu hình kích thước, thiếu chunk pHYs nhúng DPI")
        void testExportPngMetadataAbsenceOfPhysChunk() throws Exception {
                ResponseEntity<byte[]> response = printDesignController.exportPrintDesign(designIdA, "png", 300);
                byte[] bytes = response.getBody();
                assertNotNull(bytes);

                // Kiểm tra chữ ký PNG: 89 50 4E 47 0D 0A 1A 0A
                assertEquals((byte) 0x89, bytes[0]);
                assertEquals((byte) 0x50, bytes[1]);
                assertEquals((byte) 0x4E, bytes[2]);
                assertEquals((byte) 0x47, bytes[3]);

                // Tìm kiếm chuỗi "pHYs" (Physical pixel dimensions chunk) trong PNG bytes
                String rawContent = new String(bytes, StandardCharsets.ISO_8859_1);
                boolean hasPhysChunk = rawContent.contains("pHYs");

                // Ghi nhận thực tế: ImageIO mặc định không tự tạo pHYs chunk cho 300 DPI
                // Cần ghi nhận vào báo cáo để không khẳng định sai về metadata
                assertFalse(hasPhysChunk, "ImageIO.write() mặc định không nhúng chunk pHYs metadata DPI");
        }

        @Test
        @DisplayName("SRC-237-05: Xuất PDF header đạt chuẩn %PDF-1.4 và cấu trúc Catalog, Pages, XObject")
        void testExportPdfStructureAndHeaders() throws Exception {
                ResponseEntity<byte[]> response = printDesignController.exportPrintDesign(designIdA, "pdf", 300);
                assertEquals(HttpStatus.OK, response.getStatusCode());
                assertEquals(MediaType.APPLICATION_PDF, response.getHeaders().getContentType());

                byte[] pdfBytes = response.getBody();
                assertNotNull(pdfBytes);
                String pdfStr = new String(pdfBytes, StandardCharsets.ISO_8859_1);

                assertTrue(pdfStr.startsWith("%PDF-1.4"));
                assertTrue(pdfStr.contains("/Type /Catalog"));
                assertTrue(pdfStr.contains("/Type /Pages"));
                assertTrue(pdfStr.contains("/MediaBox [0 0 298 420]")); // Cỡ trang chuẩn A6 dạng point
                assertTrue(pdfStr.contains("startxref"));
                assertTrue(pdfStr.endsWith("%%EOF\n"));
        }

        @Test
        @DisplayName("SRC-237-06: Phân tích stream PDF - Nhúng PNG bytes nhưng khai báo /Filter /DCTDecode; xác minh bằng PDFBox parser")
        void testExportPdfEmbeddedStreamDctDecodeDiscrepancy() throws Exception {
                ResponseEntity<byte[]> response = printDesignController.exportPrintDesign(designIdA, "pdf", 300);
                byte[] pdfBytes = response.getBody();
                assertNotNull(pdfBytes);
                String pdfStr = new String(pdfBytes, StandardCharsets.ISO_8859_1);

                // Code PrintExportService.java (L222) dùng /Filter /DCTDecode cho pngBytes
                boolean declaresDctDecode = pdfStr.contains("/Filter /DCTDecode");
                assertTrue(declaresDctDecode, "PDF khai báo bộ lọc DCTDecode (vốn dành riêng cho JPEG)");

                // Kiểm tra stream có chứa chữ ký PNG ‰PNG (0x89 0x50 0x4E 0x47)
                boolean containsPngSignature = pdfStr.contains("\u0089PNG");
                assertTrue(containsPngSignature, "Stream PDF thực tế chứa định dạng ảnh PNG");

                // Dùng thư viện chuẩn Apache PDFBox để mở và kiểm tra đối tượng ảnh Image
                // XObject
                try (org.apache.pdfbox.pdmodel.PDDocument document = org.apache.pdfbox.Loader.loadPDF(pdfBytes)) {
                        assertEquals(1, document.getNumberOfPages());
                        org.apache.pdfbox.pdmodel.PDPage page = document.getPage(0);
                        org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject xImage = (org.apache.pdfbox.pdmodel.graphics.image.PDImageXObject) page
                                        .getResources().getXObject(org.apache.pdfbox.cos.COSName.getPDFName("Im1"));
                        assertNotNull(xImage);
                        assertEquals("DCTDecode",
                                        xImage.getCOSObject().getNameAsString(org.apache.pdfbox.cos.COSName.FILTER));

                        // Khi gọi trực tiếp xImage.getImage(), PDFBox sử dụng DCTFilter để giải mã
                        // JPEG.
                        // Vì dữ liệu nhúng là PNG nên decoder ném IOException: Not a JPEG file.
                        assertThrows(java.io.IOException.class, xImage::getImage,
                                        "PDFBox PDImageXObject.getImage() ném IOException khi giải mã PNG bytes dưới bộ lọc DCTDecode");
                }
        }

        @Test
        @DisplayName("SRC-237-07: Xuất file với designId không tồn tại ném lỗi 404 DESIGN_NOT_FOUND")
        void testExportNonExistentDesignThrowsNotFound() {
                UUID nonExistentId = UUID.randomUUID();
                ApiException ex = assertThrows(ApiException.class,
                                () -> printDesignController.exportPrintDesign(nonExistentId, "pdf", 300));
                assertEquals("DESIGN_NOT_FOUND", ex.getCode());
                assertEquals(HttpStatus.NOT_FOUND, ex.getStatus());
        }

        // =========================================================================
        // PHẦN 2: FORM ĐẶT THẺ NFC & VALIDATION
        // =========================================================================

        @Test
        @DisplayName("SRC-237-08: Đặt phôi thẻ GỖ tính đúng đơn giá 45.000 VNĐ và tổng tiền")
        void testCreateNfcOrderWoodMaterialAndPricing() {
                NfcOrderRequestDto req = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 8, "Nguyễn Văn A", "0901234567",
                                "123 Đường Bến Nghé, Quận 1");
                ApiResponse<NfcOrderResponseDto> res = nfcOrderController.createOrder(req);

                assertTrue(res.isSuccess());
                assertEquals("WOOD", res.getData().material());
                assertEquals(NfcOrderController.WOOD_PRICE_VND, res.getData().unitPrice());
                assertEquals(45000L * 8, res.getData().totalAmount());
                assertEquals(NfcOrderStatus.PENDING.name(), res.getData().status());
        }

        @Test
        @DisplayName("SRC-237-09: Đặt phôi thẻ MICA tính đúng đơn giá 35.000 VNĐ và tổng tiền")
        void testCreateNfcOrderMicaMaterialAndPricing() {
                NfcOrderRequestDto req = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "MICA", 15, "Lê Thị B", "0987654321",
                                "456 Đường Nguyễn Huệ, Quận 1");
                ApiResponse<NfcOrderResponseDto> res = nfcOrderController.createOrder(req);

                assertTrue(res.isSuccess());
                assertEquals("MICA", res.getData().material());
                assertEquals(NfcOrderController.MICA_PRICE_VND, res.getData().unitPrice());
                assertEquals(35000L * 15, res.getData().totalAmount());
                assertEquals(NfcOrderStatus.PENDING.name(), res.getData().status());
        }

        @Test
        @DisplayName("SRC-237-10: Từ chối đơn hàng có số lượng <= 0 (quantity validation)")
        void testCreateNfcOrderQuantityValidation() {
                NfcOrderRequestDto zeroQty = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 0, "Trần C", "0901234567", "123 Đường ABC");
                IllegalArgumentException exZero = assertThrows(IllegalArgumentException.class,
                                () -> nfcOrderController.createOrder(zeroQty));
                assertTrue(exZero.getMessage().contains("Số lượng phôi thẻ phải tối thiểu là 1"));

                NfcOrderRequestDto negativeQty = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", -5, "Trần C", "0901234567", "123 Đường ABC");
                assertThrows(IllegalArgumentException.class, () -> nfcOrderController.createOrder(negativeQty));
        }

        @ParameterizedTest
        @ValueSource(strings = { "0901234567", "+84912345678", "0323456789", "0898765432", "0765432109", "0587654321" })
        @DisplayName("SRC-237-11A: Chấp nhận các số điện thoại hợp lệ chuẩn Việt Nam")
        void testCreateNfcOrderValidPhone(String validPhone) {
                NfcOrderRequestDto req = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 2, "Người nhận", validPhone,
                                "123 Đường Bến Nghé");
                ApiResponse<NfcOrderResponseDto> res = nfcOrderController.createOrder(req);
                assertTrue(res.isSuccess());
                assertEquals(validPhone, res.getData().shipPhone());
        }

        @ParameterizedTest
        @ValueSource(strings = { "123456", "090123456", "090123456789", "abc0901234", "0123456789", "0412345678", "" })
        @DisplayName("SRC-237-11B: Từ chối các số điện thoại sai định dạng chuẩn Việt Nam")
        void testCreateNfcOrderInvalidPhone(String invalidPhone) {
                NfcOrderRequestDto req = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 2, "Người nhận", invalidPhone,
                                "123 Đường Bến Nghé");
                IllegalArgumentException ex = assertThrows(IllegalArgumentException.class,
                                () -> nfcOrderController.createOrder(req));
                assertTrue(ex.getMessage().contains("Số điện thoại nhận hàng không đúng định dạng Việt Nam"));
        }

        @Test
        @DisplayName("SRC-237-12: Từ chối tên người nhận trống và địa chỉ nhận hàng dưới 5 ký tự")
        void testCreateNfcOrderNameAndAddressValidation() {
                // Tên để trống
                NfcOrderRequestDto blankName = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 2, "   ", "0901234567", "123 Đường Bến Nghé");
                IllegalArgumentException exName = assertThrows(IllegalArgumentException.class,
                                () -> nfcOrderController.createOrder(blankName));
                assertTrue(exName.getMessage().contains("Tên người nhận không được để trống"));

                // Địa chỉ quá ngắn (< 5 ký tự)
                NfcOrderRequestDto shortAddress = new NfcOrderRequestDto(
                                UUID.randomUUID(), designIdA, "WOOD", 2, "Trần Văn D", "0901234567", "123 ");
                IllegalArgumentException exAddr = assertThrows(IllegalArgumentException.class,
                                () -> nfcOrderController.createOrder(shortAddress));
                assertTrue(exAddr.getMessage().contains("Địa chỉ nhận hàng phải có ít nhất 5 ký tự"));
        }

        @Test
        @DisplayName("SRC-237-13: Từ chối đặt hàng khi mẫu thiết kế designId không tồn tại")
        void testCreateNfcOrderNonExistentDesignThrowsBadRequest() {
                UUID nonExistentDesignId = UUID.randomUUID();
                NfcOrderRequestDto req = new NfcOrderRequestDto(
                                UUID.randomUUID(), nonExistentDesignId, "WOOD", 2, "Trần E", "0901234567",
                                "123 Đường ABC");
                ApiException ex = assertThrows(ApiException.class, () -> nfcOrderController.createOrder(req));
                assertEquals("DESIGN_NOT_FOUND", ex.getCode());
                assertEquals(HttpStatus.BAD_REQUEST, ex.getStatus());
        }

        // =========================================================================
        // PHẦN 3: LƯU ĐƠN HÀNG VÀO nfc_orders & TRẠNG THÁI KHỞI TẠO
        // =========================================================================

        @Test
        @DisplayName("SRC-237-14: Đơn hàng mới lưu vào nfc_orders được gán ID tự động và trạng thái ban đầu PENDING")
        void testSaveOrderPersistenceAndInitialStatus() {
                NfcOrder order = new NfcOrder(
                                null, businessIdA, designIdA, "WOOD", 12,
                                "Chủ Nhà Hàng", "0901234567", "789 Đồng Khởi, Bến Nghé, Quận 1",
                                45000L, 540000L, NfcOrderStatus.PENDING);
                NfcOrder saved = nfcOrderRepository.save(order);

                assertNotNull(saved.getId(), "Repository phải tự động sinh UUID cho đơn hàng mới");
                assertEquals(NfcOrderStatus.PENDING, saved.getStatus());
                assertEquals("Mới tiếp nhận", saved.getStatus().getDisplayName());
                assertNotNull(saved.getCreatedAt());

                // Kiểm tra đọc lại từ repository
                NfcOrder fetched = nfcOrderRepository.findById(saved.getId()).orElse(null);
                assertNotNull(fetched);
                assertEquals(12, fetched.getQuantity());
                assertEquals(540000L, fetched.getTotalAmount());
        }

        // =========================================================================
        // PHẦN 4: PHÂN QUYỀN TRUY CẬP (MULTI-TENANT ISOLATION & ACCESS CONTROL)
        // =========================================================================

        @Test
        @DisplayName("SRC-237-15: Lọc đơn hàng và thiết kế theo businessId cách ly dữ liệu; phát hiện rủi ro khi businessId rỗng")
        void testRepositoryAccessControlMultiTenantIsolation() {
                // Tạo thêm thiết kế và đơn hàng cho cơ sở B (businessIdB)
                PrintDesign designB = new PrintDesign(
                                UUID.randomUUID(), businessIdB, qrCodeIdA, PrintTemplate.COUNTER_STAND,
                                "Chi Nhánh B", "CTA B", "#000000", null, "PDF", "A6", null);
                printDesignRepository.save(designB);

                NfcOrder orderB = new NfcOrder(
                                UUID.randomUUID(), businessIdB, designB.getId(), "MICA", 5,
                                "Quản lý B", "0987654321", "456 Lê Duẩn, Quận 1",
                                35000L, 175000L, NfcOrderStatus.PENDING);
                nfcOrderRepository.save(orderB);

                // 1. Khi truyền đúng businessId của từng cơ sở -> cách ly chính xác
                List<NfcOrder> ordersOfA = nfcOrderRepository.findByBusinessId(businessIdA);
                assertTrue(ordersOfA.stream().allMatch(o -> businessIdA.equals(o.getBusinessId())));
                assertFalse(ordersOfA.stream().anyMatch(o -> businessIdB.equals(o.getBusinessId())));

                List<PrintDesign> designsOfB = printDesignRepository.findByBusinessId(businessIdB);
                assertTrue(designsOfB.stream().allMatch(d -> businessIdB.equals(d.getBusinessId())));

                // 2. RỦI RO BẢO MẬT: Khi client không truyền businessId (null), API trả về TOÀN
                // BỘ dữ liệu của mọi tenant
                ApiResponse<List<NfcOrderResponseDto>> allOrdersRes = nfcOrderController.getOrders(null);
                assertTrue(allOrdersRes.getData().size() >= 2,
                                "Lỗ hổng: getOrders(null) trả về đơn hàng của tất cả cơ sở kinh doanh");
        }

        @Test
        @DisplayName("SRC-237-16: Phân tích quyền truy cập theo ID - Thiếu kiểm tra quyền sở hữu cơ sở (IDOR)")
        void testAccessControlMissingOwnershipCheckOnGetAndExport() {
                // Người dùng từ business B có thể truy vấn đơn hàng của business A nếu biết ID
                ApiResponse<NfcOrderResponseDto> orderOfA = nfcOrderController.getOrderById(orderIdA);
                assertNotNull(orderOfA.getData());
                assertEquals(businessIdA, orderOfA.getData().businessId());

                // Người dùng từ business B có thể xuất file thiết kế của business A nếu biết ID
                ResponseEntity<byte[]> exportRes = assertDoesNotThrow(
                                () -> printDesignController.exportPrintDesign(designIdA, "pdf", 300));
                assertEquals(HttpStatus.OK, exportRes.getStatusCode());

                // Người dùng từ business B có thể xóa mẫu thiết kế của business A nếu biết ID mà không bị kiểm tra quyền sở hữu
                ApiResponse<Void> deleteRes = printDesignController.deleteDesign(designIdA);
                assertTrue(deleteRes.isSuccess());
                assertFalse(printDesignRepository.findById(designIdA).isPresent(), "Thiết kế của Tenant A đã bị xóa bởi request không được kiểm tra quyền sở hữu");
        }
}
