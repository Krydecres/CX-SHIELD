package com.cxshield.backend.entity;

public enum PrintTemplate {
    TABLE_TENT("Biển để bàn tam giác (A6)"),
    COUNTER_STAND("Đế mica quầy thu ngân (A5)"),
    WINDOW_STICKER("Decal dán cửa kính / quầy"),
    CARD_NFC("Thẻ chạm NFC để bàn");

    private final String displayName;

    PrintTemplate(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}

