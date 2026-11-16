package com.cxshield.backend.controller;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.dto.NfcOrderRequestDto;
import com.cxshield.backend.dto.NfcOrderResponseDto;
import com.cxshield.backend.entity.NfcOrder;
import com.cxshield.backend.entity.NfcOrderStatus;
import com.cxshield.backend.entity.PrintDesign;
import com.cxshield.backend.repository.NfcOrderRepository;
import com.cxshield.backend.repository.PrintDesignRepository;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/v1/nfc-orders")
public class NfcOrderController {

    private static final Pattern VN_PHONE_REGEX = Pattern.compile("^(0|\\+84)(3|5|7|8|9)[0-9]{8}$");

    // Đơn giá niêm yết phôi thẻ NFC vật lý
    public static final long WOOD_PRICE_VND = 45000L; // Thẻ Gỗ Walnut sang trọng
    public static final long MICA_PRICE_VND = 35000L; // Thẻ Mica Acrylic trong suốt

    private final NfcOrderRepository nfcOrderRepository;
    private final PrintDesignRepository printDesignRepository;

    public NfcOrderController(NfcOrderRepository nfcOrderRepository,
                              PrintDesignRepository printDesignRepository) {
        this.nfcOrderRepository = nfcOrderRepository;
        this.printDesignRepository = printDesignRepository;
    }

    /**
     * E5.3: Lấy danh sách các đơn đặt mua phôi thẻ NFC
     */
    @GetMapping
    public ApiResponse<List<NfcOrderResponseDto>> getOrders(
            @RequestParam(required = false) UUID businessId) {
        List<NfcOrder> orders = nfcOrderRepository.findByBusinessId(businessId);
        List<NfcOrderResponseDto> dtos = orders.stream().map(this::toDto).toList();
        return ApiResponse.success("Lấy danh sách đơn đặt thẻ NFC thành công", dtos);
    }

    /**
     * E5.3: Xem chi tiết một đơn đặt phôi thẻ NFC
     */
    @GetMapping("/{id}")
    public ApiResponse<NfcOrderResponseDto> getOrderById(@PathVariable UUID id) {
        NfcOrder order = nfcOrderRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "ORDER_NOT_FOUND", "Không tìm thấy đơn đặt thẻ NFC"));
        return ApiResponse.success(toDto(order));
    }

    /**
     * E5.3: Gửi đơn đặt mua phôi thẻ gỗ/mica NFC được nạp sẵn link phễu
     * Lưu nfc_orders trạng thái mới (PENDING), kiểm tra thông tin hợp lệ
     */
    @PostMapping
    public ApiResponse<NfcOrderResponseDto> createOrder(@Valid @RequestBody NfcOrderRequestDto request) {
        if (request.designId() == null) {
            throw new IllegalArgumentException("Mẫu thiết kế liên kết không được để trống");
        }

        PrintDesign design = printDesignRepository.findById(request.designId())
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "DESIGN_NOT_FOUND", "Mẫu thiết kế không tồn tại"));

        if (request.quantity() <= 0) {
            throw new IllegalArgumentException("Số lượng phôi thẻ phải tối thiểu là 1");
        }

        if (request.shipName() == null || request.shipName().trim().isBlank()) {
            throw new IllegalArgumentException("Tên người nhận không được để trống");
        }

        if (request.shipPhone() == null || !VN_PHONE_REGEX.matcher(request.shipPhone().trim()).matches()) {
            throw new IllegalArgumentException("Số điện thoại nhận hàng không đúng định dạng Việt Nam");
        }

        if (request.shipAddress() == null || request.shipAddress().trim().length() < 5) {
            throw new IllegalArgumentException("Địa chỉ nhận hàng phải có ít nhất 5 ký tự");
        }

        String materialNorm = request.material() != null && request.material().trim().toUpperCase().contains("MICA")
                ? "MICA"
                : "WOOD";

        long unitPrice = "MICA".equals(materialNorm) ? MICA_PRICE_VND : WOOD_PRICE_VND;
        long totalAmount = unitPrice * request.quantity();

        UUID businessId = request.businessId() != null
                ? request.businessId()
                : design.getBusinessId();

        NfcOrder order = new NfcOrder(
                null,
                businessId,
                design.getId(),
                materialNorm,
                request.quantity(),
                request.shipName().trim(),
                request.shipPhone().trim(),
                request.shipAddress().trim(),
                unitPrice,
                totalAmount,
                NfcOrderStatus.PENDING // Trạng thái mới theo tiêu chí hoàn thành
        );

        NfcOrder saved = nfcOrderRepository.save(order);
        return ApiResponse.success("Đặt hàng phôi thẻ NFC thành công. Cơ sở sẽ nhận hàng sau 2-3 ngày.", toDto(saved));
    }

    private NfcOrderResponseDto toDto(NfcOrder order) {
        String materialLabel = "WOOD".equalsIgnoreCase(order.getMaterial())
                ? "Thẻ gỗ Walnut sang trọng"
                : "Thẻ Mica Acrylic trong suốt";

        return new NfcOrderResponseDto(
                order.getId(),
                order.getBusinessId(),
                order.getDesignId(),
                order.getMaterial(),
                materialLabel,
                order.getQuantity(),
                order.getUnitPrice(),
                order.getTotalAmount(),
                order.getShipName(),
                order.getShipPhone(),
                order.getShipAddress(),
                order.getStatus().name(),
                order.getStatus().getDisplayName(),
                "2-3 ngày làm việc",
                order.getCreatedAt()
        );
    }
}

