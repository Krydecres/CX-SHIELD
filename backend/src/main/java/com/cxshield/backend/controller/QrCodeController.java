package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.QrCodeRequestDto;
import com.cxshield.backend.dto.QrCodeResponseDto;
import com.cxshield.backend.entity.QrCode;
import com.cxshield.backend.repository.QrCodeRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/qr-codes")
public class QrCodeController {

    private final QrCodeRepository qrCodeRepository;

    public QrCodeController(QrCodeRepository qrCodeRepository) {
        this.qrCodeRepository = qrCodeRepository;
    }

    /**
     * E5.1: Lấy danh sách mã QR theo chi nhánh
     */
    @GetMapping
    public ApiResponse<List<QrCodeResponseDto>> getQrCodes(
            @RequestParam(required = false) UUID branchId) {
        List<QrCode> list = qrCodeRepository.findByBranchId(branchId);
        List<QrCodeResponseDto> dtos = list.stream().map(this::toDto).toList();
        return ApiResponse.success("Lấy danh sách mã QR thành công", dtos);
    }

    /**
     * E5.1: Lấy chi tiết một mã QR
     */
    @GetMapping("/{id}")
    public ApiResponse<QrCodeResponseDto> getQrCodeById(@PathVariable UUID id) {
        QrCode qr = qrCodeRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "QR_NOT_FOUND", "Không tìm thấy mã QR"));
        return ApiResponse.success(toDto(qr));
    }

    /**
     * E5.1: Tạo mới mã QR cho chi nhánh
     */
    @PostMapping
    public ApiResponse<QrCodeResponseDto> createQrCode(
            @Valid @RequestBody QrCodeRequestDto request) {
        if (request.branchId() == null) {
            throw new IllegalArgumentException("Chi nhánh không được để trống");
        }

        String type = (request.type() != null && !request.type().isBlank())
                ? request.type().trim().toUpperCase()
                : "COUNTER";

        String name = (request.name() != null && !request.name().isBlank())
                ? request.name().trim()
                : ("TABLE".equalsIgnoreCase(type) ? "Bàn mới" : "Quầy thu ngân");

        String code = request.code();
        if (code == null || code.isBlank()) {
            code = generateCodeForType(type);
        } else {
            code = code.trim().toUpperCase();
        }

        QrCode qrCode = new QrCode(
                UUID.randomUUID(),
                request.branchId(),
                code,
                type,
                name,
                "ACTIVE"
        );

        QrCode saved = qrCodeRepository.save(qrCode);
        return ApiResponse.success("Tạo mã QR thành công", toDto(saved));
    }

    /**
     * E5.1: Đảm bảo chi nhánh có ít nhất 1 mã QR mặc định (Tạo mã QR cho chi nhánh nếu chưa có)
     */
    @PostMapping("/ensure-default")
    public ApiResponse<QrCodeResponseDto> ensureDefaultQrCode(
            @RequestParam UUID branchId) {
        List<QrCode> existing = qrCodeRepository.findByBranchId(branchId);
        if (!existing.isEmpty()) {
            return ApiResponse.success("Chi nhánh đã có mã QR", toDto(existing.getFirst()));
        }

        QrCode defaultQr = new QrCode(
                UUID.randomUUID(),
                branchId,
                "MC-B04",
                "TABLE",
                "Bàn 04 (Mặc định)",
                "ACTIVE"
        );

        QrCode saved = qrCodeRepository.save(defaultQr);
        return ApiResponse.success("Đã khởi tạo mã QR mặc định cho chi nhánh", toDto(saved));
    }

    private String generateCodeForType(String type) {
        String prefix = switch (type.toUpperCase()) {
            case "TABLE" -> "MC-BAN";
            case "AREA" -> "MC-KHU";
            case "STAFF" -> "MC-NV";
            default -> "MC-QUAY";
        };
        int suffix = 10 + (int) (Math.random() * 89);
        return prefix + suffix;
    }

    private QrCodeResponseDto toDto(QrCode qr) {
        String targetUrl = "https://cxshield.vn/survey?qr=" + qr.getCode();
        return new QrCodeResponseDto(
                qr.getId(),
                qr.getBranchId(),
                qr.getCode(),
                qr.getType(),
                qr.getName(),
                qr.getStatus() != null ? qr.getStatus() : "ACTIVE",
                targetUrl,
                qr.getCreatedAt() != null ? qr.getCreatedAt() : Instant.now()
        );
    }
}
