package com.cxshield.backend.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.util.UUID;

public record NfcOrderRequestDto(
        UUID businessId,

        @NotNull(message = "Mẫu thiết kế liên kết không được để trống")
        UUID designId,

        @NotBlank(message = "Loại phôi thẻ (WOOD/MICA) không được để trống")
        String material,

        @Min(value = 1, message = "Số lượng phôi thẻ phải tối thiểu là 1")
        int quantity,

        @NotBlank(message = "Tên người nhận không được để trống")
        String shipName,

        @NotBlank(message = "Số điện thoại nhận hàng không được để trống")
        @Pattern(regexp = "^(0|\\+84)(3|5|7|8|9)[0-9]{8}$", message = "Số điện thoại nhận hàng không đúng định dạng Việt Nam")
        String shipPhone,

        @NotBlank(message = "Địa chỉ nhận hàng không được để trống")
        String shipAddress
) {}

