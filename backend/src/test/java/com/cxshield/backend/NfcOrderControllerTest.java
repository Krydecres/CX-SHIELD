package com.cxshield.backend;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.NfcOrderController;
import com.cxshield.backend.dto.NfcOrderRequestDto;
import com.cxshield.backend.dto.NfcOrderResponseDto;
import com.cxshield.backend.repository.NfcOrderRepository;
import com.cxshield.backend.repository.PrintDesignRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class NfcOrderControllerTest {

    private NfcOrderRepository nfcOrderRepository;
    private PrintDesignRepository printDesignRepository;
    private NfcOrderController controller;

    private UUID existingDesignId;
    private UUID existingOrderId;

    @BeforeEach
    void setUp() {
        nfcOrderRepository = new NfcOrderRepository();
        printDesignRepository = new PrintDesignRepository();
        controller = new NfcOrderController(nfcOrderRepository, printDesignRepository);

        existingDesignId = UUID.fromString("e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55");
        existingOrderId = UUID.fromString("f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66");
    }

    @Test
    @DisplayName("E5.3: Lấy danh sách đơn đặt thẻ NFC")
    void testGetOrders() {
        ApiResponse<List<NfcOrderResponseDto>> res = controller.getOrders(null);
        assertTrue(res.isSuccess());
        assertFalse(res.getData().isEmpty());
        assertEquals("WOOD", res.getData().get(0).material());
    }

    @Test
    @DisplayName("E5.3: Xem chi tiết đơn đặt thẻ NFC theo ID")
    void testGetOrderById() {
        ApiResponse<NfcOrderResponseDto> res = controller.getOrderById(existingOrderId);
        assertTrue(res.isSuccess());
        assertEquals("PENDING", res.getData().status());
        assertEquals(450000L, res.getData().totalAmount());
        assertEquals("2-3 ngày làm việc", res.getData().estimatedDelivery());
    }

    @Test
    @DisplayName("E5.3: Đặt phôi thẻ Gỗ thành công - lưu nfc_orders trạng thái PENDING")
    void testCreateWoodOrderSuccess() {
        NfcOrderRequestDto req = new NfcOrderRequestDto(
                UUID.randomUUID(),
                existingDesignId,
                "WOOD",
                5,
                "Trần Văn Chủ",
                "0987654321",
                "456 Lê Lợi, Phường Bến Thành, Quận 1, TP. HCM"
        );

        ApiResponse<NfcOrderResponseDto> res = controller.createOrder(req);
        assertTrue(res.isSuccess());
        assertNotNull(res.getData().id());
        assertEquals("WOOD", res.getData().material());
        assertEquals("Thẻ gỗ Walnut sang trọng", res.getData().materialLabel());
        assertEquals(5, res.getData().quantity());
        assertEquals(NfcOrderController.WOOD_PRICE_VND, res.getData().unitPrice());
        assertEquals(NfcOrderController.WOOD_PRICE_VND * 5, res.getData().totalAmount());
        assertEquals("PENDING", res.getData().status());
        assertEquals("Mới tiếp nhận", res.getData().statusLabel());
    }

    @Test
    @DisplayName("E5.3: Đặt phôi thẻ Mica thành công - tính đúng giá và tổng tiền")
    void testCreateMicaOrderSuccess() {
        NfcOrderRequestDto req = new NfcOrderRequestDto(
                UUID.randomUUID(),
                existingDesignId,
                "MICA",
                20,
                "Lê Thị Thu",
                "0912345678",
                "789 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM"
        );

        ApiResponse<NfcOrderResponseDto> res = controller.createOrder(req);
        assertTrue(res.isSuccess());
        assertEquals("MICA", res.getData().material());
        assertEquals("Thẻ Mica Acrylic trong suốt", res.getData().materialLabel());
        assertEquals(20, res.getData().quantity());
        assertEquals(NfcOrderController.MICA_PRICE_VND, res.getData().unitPrice());
        assertEquals(NfcOrderController.MICA_PRICE_VND * 20, res.getData().totalAmount());
        assertEquals("PENDING", res.getData().status());
    }

    @Test
    @DisplayName("E5.3: Đặt hàng thất bại khi SĐT sai định dạng Việt Nam")
    void testCreateOrderInvalidPhone() {
        NfcOrderRequestDto req = new NfcOrderRequestDto(
                UUID.randomUUID(), existingDesignId, "WOOD", 5, "Trần Văn A", "1234567", "123 Đường ABC"
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrder(req));
    }

    @Test
    @DisplayName("E5.3: Đặt hàng thất bại khi số lượng <= 0")
    void testCreateOrderInvalidQuantity() {
        NfcOrderRequestDto req = new NfcOrderRequestDto(
                UUID.randomUUID(), existingDesignId, "WOOD", 0, "Trần Văn A", "0901234567", "123 Đường ABC"
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrder(req));
    }

    @Test
    @DisplayName("E5.3: Đặt hàng thất bại khi mẫu thiết kế không tồn tại")
    void testCreateOrderNonExistentDesign() {
        NfcOrderRequestDto req = new NfcOrderRequestDto(
                UUID.randomUUID(), UUID.randomUUID(), "WOOD", 5, "Trần Văn A", "0901234567", "123 Đường ABC"
        );
        assertThrows(ApiException.class, () -> controller.createOrder(req));
    }

    @Test
    @DisplayName("E5.3: Đặt hàng thất bại khi tên hoặc địa chỉ để trống")
    void testCreateOrderEmptyNameOrAddress() {
        NfcOrderRequestDto emptyName = new NfcOrderRequestDto(
                UUID.randomUUID(), existingDesignId, "WOOD", 5, "   ", "0901234567", "123 Đường ABC"
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrder(emptyName));

        NfcOrderRequestDto emptyAddress = new NfcOrderRequestDto(
                UUID.randomUUID(), existingDesignId, "WOOD", 5, "Trần A", "0901234567", "   "
        );
        assertThrows(IllegalArgumentException.class, () -> controller.createOrder(emptyAddress));
    }
}

