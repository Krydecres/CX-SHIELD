package com.cxshield.backend.dto;

import java.util.UUID;

public class SurveyInitResponseDto {
    private UUID sessionId;
    private String qrCode;
    private String businessName;
    private String branchName;
    private String branchAddress;
    private String tableOrAreaCode;
    private String logoUrl;
    private String primaryColor;
    private String hotline;

    public SurveyInitResponseDto() {}

    public UUID getSessionId() { return sessionId; }
    public void setSessionId(UUID sessionId) { this.sessionId = sessionId; }
    public String getQrCode() { return qrCode; }
    public void setQrCode(String qrCode) { this.qrCode = qrCode; }
    public String getBusinessName() { return businessName; }
    public void setBusinessName(String businessName) { this.businessName = businessName; }
    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }
    public String getBranchAddress() { return branchAddress; }
    public void setBranchAddress(String branchAddress) { this.branchAddress = branchAddress; }
    public String getTableOrAreaCode() { return tableOrAreaCode; }
    public void setTableOrAreaCode(String tableOrAreaCode) { this.tableOrAreaCode = tableOrAreaCode; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
    public String getPrimaryColor() { return primaryColor; }
    public void setPrimaryColor(String primaryColor) { this.primaryColor = primaryColor; }
    public String getHotline() { return hotline; }
    public void setHotline(String hotline) { this.hotline = hotline; }
}

