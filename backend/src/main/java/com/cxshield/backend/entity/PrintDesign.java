package com.cxshield.backend.entity;

import java.time.Instant;
import java.util.UUID;

public class PrintDesign {
    private UUID id;
    private UUID businessId;
    private UUID qrCodeId;
    private PrintTemplate template;
    private String brandName;
    private String ctaText;
    private String color;
    private String logoUrl;
    private String exportFormat;
    private String size;
    private String fileUrl;
    private Instant createdAt;
    private Instant updatedAt;

    public PrintDesign() {
        this.id = UUID.randomUUID();
        this.template = PrintTemplate.TABLE_TENT;
        this.ctaText = "Quét mã để đánh giá & nhận ưu đãi";
        this.color = "#1E3A8A";
        this.exportFormat = "PDF";
        this.size = "A6";
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public PrintDesign(UUID id, UUID businessId, UUID qrCodeId, PrintTemplate template,
                       String brandName, String ctaText, String color, String logoUrl,
                       String exportFormat, String size, String fileUrl) {
        this.id = id != null ? id : UUID.randomUUID();
        this.businessId = businessId;
        this.qrCodeId = qrCodeId;
        this.template = template != null ? template : PrintTemplate.TABLE_TENT;
        this.brandName = brandName;
        this.ctaText = ctaText != null ? ctaText : "Quét mã để đánh giá & nhận ưu đãi";
        this.color = color != null ? color : "#1E3A8A";
        this.logoUrl = logoUrl;
        this.exportFormat = exportFormat != null ? exportFormat : "PDF";
        this.size = size != null ? size : "A6";
        this.fileUrl = fileUrl;
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }

    public UUID getBusinessId() { return businessId; }
    public void setBusinessId(UUID businessId) { this.businessId = businessId; }

    public UUID getQrCodeId() { return qrCodeId; }
    public void setQrCodeId(UUID qrCodeId) { this.qrCodeId = qrCodeId; }

    public PrintTemplate getTemplate() { return template; }
    public void setTemplate(PrintTemplate template) { this.template = template; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public String getCtaText() { return ctaText; }
    public void setCtaText(String ctaText) { this.ctaText = ctaText; }

    public String getColor() { return color; }
    public void setColor(String color) { this.color = color; }

    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }

    public String getExportFormat() { return exportFormat; }
    public void setExportFormat(String exportFormat) { this.exportFormat = exportFormat; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }

    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }

    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}

