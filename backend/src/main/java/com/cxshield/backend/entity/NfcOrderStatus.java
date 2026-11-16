package com.cxshield.backend.entity;

public enum NfcOrderStatus {
    PENDING("Mới tiếp nhận"),
    PROCESSING("Đang nạp phôi & in ấn"),
    SHIPPED("Đang giao hàng"),
    DELIVERED("Đã giao thành công"),
    CANCELLED("Đã hủy");

    private final String displayName;

    NfcOrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}

