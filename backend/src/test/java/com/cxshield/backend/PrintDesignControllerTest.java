package com.cxshield.backend;

import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.PrintDesignController;
import com.cxshield.backend.dto.PrintDesignRequestDto;
import com.cxshield.backend.dto.PrintDesignResponseDto;
import com.cxshield.backend.entity.PrintDesign;
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
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PrintDesignControllerTest {

    private PrintDesignRepository printDesignRepository;
    private QrCodeRepository qrCodeRepository;
    private PrintExportService printExportService;
    private PrintDesignController controller;

    private UUID existingDesignId;
    private UUID existingQrId;

    @BeforeEach
    void setUp() {
        printDesignRepository = new PrintDesignRepository();
        qrCodeRepository = new QrCodeRepository();
        printExportService = new PrintExportService();
        controller = new PrintDesignController(printDesignRepository, qrCodeRepository, printExportService);

        existingDesignId = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");
        existingQrId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");
    }

    @Test
    @DisplayName("E5.3: Lấy danh sách thiết kế thành công")
    void testGetDesigns() {
        ApiResponse<List<PrintDesignResponseDto>> res = controller.getDesigns(null);
        assertTrue(res.isSuccess());
        assertFalse(res.getData().isEmpty());
        assertEquals("Maison Coffee & Bistro", res.getData().get(0).brandName());
    }

    @Test
    @DisplayName("E5.3: Lấy chi tiết một thiết kế theo ID")
    void testGetDesignById() {
        ApiResponse<PrintDesignResponseDto> res = controller.getDesignById(existingDesignId);
        assertTrue(res.isSuccess());
        assertEquals("TABLE_TENT", res.getData().template());
        assertEquals("MC-B04", res.getData().qrCodeValue());
    }

    @Test
    @DisplayName("E5.3: Tạo thiết kế mới thành công")
    void testCreateDesign() {
        PrintDesignRequestDto req = new PrintDesignRequestDto(
                UUID.randomUUID(),
                existingQrId,
                "COUNTER_STAND",
                "Phở Thêu Gia Truyền",
                "Quét mã phản hồi nhận ngay trà đá",
                "#B91C1C",
                null,
                "PNG",
                "A5"
        );

        ApiResponse<PrintDesignResponseDto> res = controller.createOrUpdateDesign(req);
        assertTrue(res.isSuccess());
        assertEquals("Phở Thêu Gia Truyền", res.getData().brandName());
        assertEquals("COUNTER_STAND", res.getData().template());
        assertEquals("A5", res.getData().size());
    }

    @Test
    @DisplayName("E5.3: Tạo thiết kế thiếu tên thương hiệu hoặc qrId phải ném ngoại lệ")
    void testCreateDesignValidation() {
        PrintDesignRequestDto missingBrand = new PrintDesignRequestDto(
                null, existingQrId, "TABLE_TENT", "", "CTA", "#1E3A8A", null, "PDF", "A6"
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrUpdateDesign(missingBrand));

        PrintDesignRequestDto missingQr = new PrintDesignRequestDto(
                null, null, "TABLE_TENT", "Brand", "CTA", "#1E3A8A", null, "PDF", "A6"
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrUpdateDesign(missingQr));
    }

    @Test
    @DisplayName("E5.3: Xuất file in ấn PNG chuẩn ≥ 300 DPI và QR code quét được 100%")
    void testExportPngHighResolutionAndScannable() throws Exception {
        ResponseEntity<byte[]> response = controller.exportPrintDesign(existingDesignId, "png", 300);

        assertEquals(200, response.getStatusCode().value());
        assertEquals(MediaType.IMAGE_PNG, response.getHeaders().getContentType());
        assertEquals("300", response.getHeaders().getFirst("X-Print-DPI"));
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 1000);

        // Đọc lại ảnh và kiểm tra độ phân giải A6 tại 300 DPI (1240 x 1754 px)
        BufferedImage img = ImageIO.read(new ByteArrayInputStream(response.getBody()));
        assertNotNull(img);
        assertEquals(PrintExportService.DPI_300_A6_WIDTH, img.getWidth());
        assertEquals(PrintExportService.DPI_300_A6_HEIGHT, img.getHeight());

        // Quét lại mã QR từ hình ảnh bằng ZXing MultiFormatReader để đảm bảo quét được
        BufferedImageLuminanceSource source = new BufferedImageLuminanceSource(img);
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
        Result result = new MultiFormatReader().decode(bitmap);

        assertNotNull(result);
        assertTrue(result.getText().contains("https://cxshield.vn/survey?qr=MC-B04"));
    }

    @Test
    @DisplayName("E5.3: Xuất file in ấn vector chuẩn PDF")
    void testExportPdfHighQuality() throws Exception {
        ResponseEntity<byte[]> response = controller.exportPrintDesign(existingDesignId, "pdf", 300);

        assertEquals(200, response.getStatusCode().value());
        assertEquals(MediaType.APPLICATION_PDF, response.getHeaders().getContentType());
        assertNotNull(response.getBody());
        assertTrue(response.getBody().length > 1000);

        // Kiểm tra magic number của định dạng PDF: %PDF-1.4
        String header = new String(response.getBody(), 0, 8);
        assertTrue(header.startsWith("%PDF-1."));
    }

    @Test
    @DisplayName("E5.1: Cập nhật mẫu thiết kế hiện có khi truyền ID")
    void testUpdateExistingDesign() {
        PrintDesignRequestDto updateReq = new PrintDesignRequestDto(
                existingDesignId,
                null,
                existingQrId,
                "WINDOW_STICKER",
                "Maison Coffee Cập Nhật",
                "Quét mã để nhận ưu đãi 20%",
                "#991B1B",
                "https://example.com/logo.png",
                "PNG",
                "A5"
        );

        ApiResponse<PrintDesignResponseDto> response = controller.createOrUpdateDesign(updateReq);

        assertTrue(response.isSuccess());
        assertEquals(existingDesignId, response.getData().id());
        assertEquals("WINDOW_STICKER", response.getData().template());
        assertEquals("Maison Coffee Cập Nhật", response.getData().brandName());
        assertEquals("#991B1B", response.getData().color());
    }

    @Test
    @DisplayName("E5.1: Xóa mẫu thiết kế ấn phẩm thành công và xử lý 404 khi không tìm thấy")
    void testDeleteDesign() {
        ApiResponse<Void> deleteRes = controller.deleteDesign(existingDesignId);
        assertTrue(deleteRes.isSuccess());

        // Kiểm tra xóa lần 2 sẽ ném 404 DESIGN_NOT_FOUND
        com.cxshield.backend.common.ApiException ex = assertThrows(
                com.cxshield.backend.common.ApiException.class,
                () -> controller.deleteDesign(existingDesignId)
        );
        assertEquals("DESIGN_NOT_FOUND", ex.getCode());
    }
}

