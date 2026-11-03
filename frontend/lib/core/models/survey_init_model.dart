class SurveyInitModel {
  final String sessionId;
  final String qrCode;
  final String businessName;
  final String branchName;
  final String? branchAddress;
  final String tableOrAreaCode;
  final String? logoUrl;
  final String primaryColor;
  final String? hotline;

  const SurveyInitModel({
    required this.sessionId,
    required this.qrCode,
    required this.businessName,
    required this.branchName,
    this.branchAddress,
    required this.tableOrAreaCode,
    this.logoUrl,
    required this.primaryColor,
    this.hotline,
  });

  factory SurveyInitModel.fromJson(Map<String, dynamic> json) {
    return SurveyInitModel(
      sessionId: json['sessionId'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
      businessName: json['businessName'] as String? ?? 'Maison Coffee & Bistro',
      branchName: json['branchName'] as String? ?? 'Chi nhánh Quận 1 - Đồng Khởi',
      branchAddress: json['branchAddress'] as String?,
      tableOrAreaCode: json['tableOrAreaCode'] as String? ?? 'Bàn 04',
      logoUrl: json['logoUrl'] as String?,
      primaryColor: json['primaryColor'] as String? ?? '#2C1810',
      hotline: json['hotline'] as String? ?? '02838221122',
    );
  }

  factory SurveyInitModel.fallback(String qrCode) {
    return SurveyInitModel(
      sessionId: '',
      qrCode: qrCode,
      businessName: 'Maison Coffee & Bistro',
      branchName: 'Chi nhánh Quận 1 - Đồng Khởi',
      branchAddress: '123 Đường Đồng Khởi, Bến Nghé, Quận 1, TP. HCM',
      tableOrAreaCode: 'Bàn 04',
      logoUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&auto=format&fit=crop&q=80',
      primaryColor: '#2C1810',
      hotline: '02838221122',
    );
  }
}

