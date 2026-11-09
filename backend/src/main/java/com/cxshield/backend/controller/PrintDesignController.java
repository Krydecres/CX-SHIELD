package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.PrintDesignRequestDto;
import com.cxshield.backend.dto.PrintDesignResponseDto;
import com.cxshield.backend.entity.PrintDesign;
import com.cxshield.backend.entity.PrintTemplate;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.repository.PrintDesignRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.service.PrintExportService;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/print-designs")
public class PrintDesignController {

    private final PrintDesignRepository printDesignRepository;
    private final QrCodeRepository qrCodeRepository;
    private final PrintExportService printExportService;

    public PrintDesignController(PrintDesignRepository printDesignRepository,
                                 QrCodeRepository qrCodeRepository,
                                 PrintExportService printExportService) {
        this.printDesignRepository = printDesignRepository;
        this.qrCodeRepository = qrCodeRepository;
        this.printExportService = printExportService;
    }

    /**
     * E5.3: Lấy danh sách thiết kế ấn phẩm in ấn
     */
    @GetMapping
    public ApiResponse<List<PrintDesignResponseDto>> getDesigns(
            @RequestParam(required = false) UUID businessId) {
        List<PrintDesign> list = printDesignRepository.findByBusinessId(businessId);
        List<PrintDesignResponseDto> dtos = list.stream().map(this::toDto).toList();
        return ApiResponse.success("Lấy danh sách thiết kế thành công", dtos);
    }

    /**
     * E5.3: Lấy chi tiết một thiết kế ấn phẩm
     */
    @GetMapping("/{id}")
    public ApiResponse<PrintDesignResponseDto> getDesignById(@PathVariable UUID id) {
        PrintDesign design = printDesignRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "DESIGN_NOT_FOUND", "Không tìm thấy mẫu thiết kế"));
        return ApiResponse.success(toDto(design));
    }

    /**
     * E5.3: Tạo hoặc cập nhật thiết kế ấn phẩm in ấn
     */
    @PostMapping
    public ApiResponse<PrintDesignResponseDto> createOrUpdateDesign(
            @Valid @RequestBody PrintDesignRequestDto request) {
        if (request.qrCodeId() == null) {
            throw new IllegalArgumentException("Mã QR liên kết không được để trống");
        }
        if (request.brandName() == null || request.brandName().isBlank()) {
            throw new IllegalArgumentException("Tên thương hiệu không được để trống");
        }

        QrCode qrCode = qrCodeRepository.findById(request.qrCodeId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "QR_NOT_FOUND", "Mã QR liên kết không tồn tại"));

        PrintTemplate template = PrintTemplate.TABLE_TENT;
        if (request.template() != null) {
            try {
                template = PrintTemplate.valueOf(request.template().toUpperCase());
            } catch (Exception ignored) {}
        }

        UUID businessId = request.businessId() != null
                ? request.businessId()
                : UUID.fromString("a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11");

        PrintDesign design = new PrintDesign(
                null,
                businessId,
                qrCode.getId(),
                template,
                request.brandName().trim(),
                request.ctaText() != null ? request.ctaText().trim() : "Quét mã để đánh giá & nhận ưu đãi",
                request.color() != null ? request.color().trim() : "#1E3A8A",
                request.logoUrl(),
                request.exportFormat() != null ? request.exportFormat().toUpperCase() : "PDF",
                request.size() != null ? request.size().toUpperCase() : "A6",
                null
        );

        PrintDesign saved = printDesignRepository.save(design);
        return ApiResponse.success("Lưu thiết kế ấn phẩm thành công", toDto(saved));
    }

    /**
     * E5.3: Xuất file in ấn vector chuẩn PDF/PNG độ phân giải cao (≥ 300 dpi)
     */
    @GetMapping("/{id}/export")
    public ResponseEntity<byte[]> exportPrintDesign(
            @PathVariable UUID id,
            @RequestParam(defaultValue = "pdf") String format,
            @RequestParam(defaultValue = "300") int dpi) throws IOException {

        PrintDesign design = printDesignRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "DESIGN_NOT_FOUND", "Không tìm thấy mẫu thiết kế"));

        QrCode qrCode = qrCodeRepository.findById(design.getQrCodeId()).orElse(null);
        String qrValue = qrCode != null ? qrCode.getCode() : "MC-B04";
        String targetUrl = "https://cxshield.vn/survey?qr=" + qrValue;

        int finalDpi = Math.max(dpi, 300); // Đảm bảo tối thiểu 300 DPI theo tiêu chí nghiệm thu

        byte[] fileBytes;
        MediaType contentType;
        String extension;

        if ("png".equalsIgnoreCase(format)) {
            fileBytes = printExportService.exportToPngBytes(design, qrCode, targetUrl, finalDpi);
            contentType = MediaType.IMAGE_PNG;
            extension = "png";
        } else {
            fileBytes = printExportService.exportToPdfBytes(design, qrCode, targetUrl, finalDpi);
            contentType = MediaType.APPLICATION_PDF;
            extension = "pdf";
        }

        String filename = String.format("an-pham-qr-%s-%sdpi.%s",
                design.getSize().toLowerCase(), finalDpi, extension);

        return ResponseEntity.ok()
                .contentType(contentType)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .header("X-Print-DPI", String.valueOf(finalDpi))
                .body(fileBytes);
    }

    private PrintDesignResponseDto toDto(PrintDesign design) {
        QrCode qrCode = qrCodeRepository.findById(design.getQrCodeId()).orElse(null);
        String code = qrCode != null ? qrCode.getCode() : "MC-B04";
        String targetUrl = "https://cxshield.vn/survey?qr=" + code;
        String downloadUrl = "/api/v1/print-designs/" + design.getId() + "/export?format="
                + design.getExportFormat().toLowerCase() + "&dpi=300";

        return new PrintDesignResponseDto(
                design.getId(),
                design.getBusinessId(),
                design.getQrCodeId(),
                code,
                targetUrl,
                design.getTemplate().name(),
                design.getTemplate().getDisplayName(),
                design.getBrandName(),
                design.getCtaText(),
                design.getColor(),
                design.getLogoUrl(),
                design.getExportFormat(),
                design.getSize(),
                downloadUrl,
                design.getCreatedAt()
        );
    }
}

