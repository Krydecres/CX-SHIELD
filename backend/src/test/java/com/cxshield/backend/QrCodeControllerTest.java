package com.cxshield.backend;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.QrCodeController;
import com.cxshield.backend.dto.QrCodeRequestDto;
import com.cxshield.backend.dto.QrCodeResponseDto;
import com.cxshield.backend.repository.QrCodeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class QrCodeControllerTest {

    private QrCodeRepository qrCodeRepository;
    private QrCodeController controller;

    private final UUID existingBranchId = UUID.fromString("b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22");
    private final UUID existingQrId = UUID.fromString("c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33");

    @BeforeEach
    void setUp() {
        qrCodeRepository = new QrCodeRepository();
        controller = new QrCodeController(qrCodeRepository);
    }

    @Test
    @DisplayName("E5.1: Lấy danh sách mã QR theo chi nhánh thành công")
    void testGetQrCodesByBranch() {
        ApiResponse<List<QrCodeResponseDto>> response = controller.getQrCodes(existingBranchId);

        assertTrue(response.isSuccess());
        assertNotNull(response.getData());
        assertFalse(response.getData().isEmpty());
        assertEquals("MC-B04", response.getData().getFirst().code());
        assertEquals("TABLE", response.getData().getFirst().type());
        assertTrue(response.getData().getFirst().targetUrl().contains("MC-B04"));
    }

    @Test
    @DisplayName("E5.1: Lấy chi tiết mã QR theo ID")
    void testGetQrCodeById() {
        ApiResponse<QrCodeResponseDto> response = controller.getQrCodeById(existingQrId);

        assertTrue(response.isSuccess());
        assertEquals(existingQrId, response.getData().id());
        assertEquals("MC-B04", response.getData().code());
    }

    @Test
    @DisplayName("E5.1: Lấy mã QR với ID không tồn tại trả về ApiException 404")
    void testGetQrCodeByIdNotFound() {
        UUID nonExistent = UUID.randomUUID();
        ApiException ex = assertThrows(ApiException.class, () -> controller.getQrCodeById(nonExistent));
        assertEquals("QR_NOT_FOUND", ex.getCode());
    }

    @Test
    @DisplayName("E5.1: Tạo mã QR mới cho chi nhánh với thông tin tùy chỉnh")
    void testCreateQrCodeCustom() {
        QrCodeRequestDto request = new QrCodeRequestDto(
                existingBranchId,
                "MC-QUAY01",
                "COUNTER",
                "Quầy thu ngân chính"
        );

        ApiResponse<QrCodeResponseDto> response = controller.createQrCode(request);

        assertTrue(response.isSuccess());
        assertEquals("MC-QUAY01", response.getData().code());
        assertEquals("COUNTER", response.getData().type());
        assertEquals("Quầy thu ngân chính", response.getData().name());
        assertEquals("ACTIVE", response.getData().status());
        assertTrue(response.getData().targetUrl().endsWith("MC-QUAY01"));
    }

    @Test
    @DisplayName("E5.1: Tạo mã QR tự động sinh code khi để trống")
    void testCreateQrCodeAutoGeneratesCode() {
        QrCodeRequestDto request = new QrCodeRequestDto(
                existingBranchId,
                null,
                "TABLE",
                "Bàn VIP 01"
        );

        ApiResponse<QrCodeResponseDto> response = controller.createQrCode(request);

        assertTrue(response.isSuccess());
        assertNotNull(response.getData().code());
        assertTrue(response.getData().code().startsWith("MC-BAN"));
        assertEquals("Bàn VIP 01", response.getData().name());
    }

    @Test
    @DisplayName("E5.1: Tạo mã QR với branchId null ném IllegalArgumentException")
    void testCreateQrCodeNullBranchThrows() {
        QrCodeRequestDto request = new QrCodeRequestDto(
                null,
                "MC-01",
                "TABLE",
                "Bàn 01"
        );

        assertThrows(IllegalArgumentException.class, () -> controller.createQrCode(request));
    }

    @Test
    @DisplayName("E5.1: Đảm bảo mã QR mặc định trả về mã hiện có nếu chi nhánh đã có QR")
    void testEnsureDefaultQrCodeWhenExisting() {
        ApiResponse<QrCodeResponseDto> response = controller.ensureDefaultQrCode(existingBranchId);

        assertTrue(response.isSuccess());
        assertEquals("MC-B04", response.getData().code());
    }

    @Test
    @DisplayName("E5.1: Đảm bảo mã QR mặc định tạo mới nếu chi nhánh chưa có bất kỳ mã QR nào")
    void testEnsureDefaultQrCodeWhenNone() {
        UUID newBranchId = UUID.randomUUID();
        ApiResponse<QrCodeResponseDto> response = controller.ensureDefaultQrCode(newBranchId);

        assertTrue(response.isSuccess());
        assertNotNull(response.getData().id());
        assertEquals(newBranchId, response.getData().branchId());
        assertEquals("MC-B04", response.getData().code());

        // Kiểm tra sau khi gọi thì chi nhánh đã có mã
        List<QrCodeResponseDto> branchQrs = controller.getQrCodes(newBranchId).getData();
        assertEquals(1, branchQrs.size());
    }
}
