class PrintDesignDto {
  const PrintDesignDto({
    required this.id,
    required this.businessId,
    required this.qrCodeId,
    required this.qrCodeValue,
    required this.targetUrl,
    required this.template,
    required this.templateName,
    required this.brandName,
    required this.ctaText,
    required this.color,
    this.logoUrl,
    required this.exportFormat,
    required this.size,
    required this.downloadUrl,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final String qrCodeId;
  final String qrCodeValue;
  final String targetUrl;
  final String template;
  final String templateName;
  final String brandName;
  final String ctaText;
  final String color;
  final String? logoUrl;
  final String exportFormat;
  final String size;
  final String downloadUrl;
  final DateTime? createdAt;

  factory PrintDesignDto.fromJson(Map<String, dynamic> json) {
    return PrintDesignDto(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      qrCodeId: json['qrCodeId'] as String? ?? '',
      qrCodeValue: json['qrCodeValue'] as String? ?? 'MC-B04',
      targetUrl: json['targetUrl'] as String? ?? 'https://cxshield.vn/survey?qr=MC-B04',
      template: json['template'] as String? ?? 'TABLE_TENT',
      templateName: json['templateName'] as String? ?? 'Biển để bàn tam giác (A6)',
      brandName: json['brandName'] as String? ?? 'Maison Coffee & Bistro',
      ctaText: json['ctaText'] as String? ?? 'Quét mã để đánh giá & nhận ưu đãi',
      color: json['color'] as String? ?? '#1E3A8A',
      logoUrl: json['logoUrl'] as String?,
      exportFormat: json['exportFormat'] as String? ?? 'PDF',
      size: json['size'] as String? ?? 'A6',
      downloadUrl: json['downloadUrl'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'businessId': businessId,
    'qrCodeId': qrCodeId,
    'template': template,
    'brandName': brandName,
    'ctaText': ctaText,
    'color': color,
    'logoUrl': logoUrl,
    'exportFormat': exportFormat,
    'size': size,
  };
}

class NfcOrderDto {
  const NfcOrderDto({
    required this.id,
    required this.businessId,
    required this.designId,
    required this.material,
    required this.materialLabel,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.shipName,
    required this.shipPhone,
    required this.shipAddress,
    required this.status,
    required this.statusLabel,
    required this.estimatedDelivery,
    this.createdAt,
  });

  final String id;
  final String businessId;
  final String designId;
  final String material;
  final String materialLabel;
  final int quantity;
  final int unitPrice;
  final int totalAmount;
  final String shipName;
  final String shipPhone;
  final String shipAddress;
  final String status;
  final String statusLabel;
  final String estimatedDelivery;
  final DateTime? createdAt;

  factory NfcOrderDto.fromJson(Map<String, dynamic> json) {
    return NfcOrderDto(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      designId: json['designId'] as String? ?? '',
      material: json['material'] as String? ?? 'WOOD',
      materialLabel: json['materialLabel'] as String? ?? 'Thẻ gỗ Walnut sang trọng',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unitPrice'] as int? ?? 45000,
      totalAmount: json['totalAmount'] as int? ?? 45000,
      shipName: json['shipName'] as String? ?? '',
      shipPhone: json['shipPhone'] as String? ?? '',
      shipAddress: json['shipAddress'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      statusLabel: json['statusLabel'] as String? ?? 'Mới tiếp nhận',
      estimatedDelivery: json['estimatedDelivery'] as String? ?? '2-3 ngày làm việc',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}

class NfcOrderCreateRequest {
  const NfcOrderCreateRequest({
    this.businessId,
    required this.designId,
    required this.material,
    required this.quantity,
    required this.shipName,
    required this.shipPhone,
    required this.shipAddress,
  });

  final String? businessId;
  final String designId;
  final String material;
  final int quantity;
  final String shipName;
  final String shipPhone;
  final String shipAddress;

  Map<String, dynamic> toJson() => {
    if (businessId != null) 'businessId': businessId,
    'designId': designId,
    'material': material,
    'quantity': quantity,
    'shipName': shipName,
    'shipPhone': shipPhone,
    'shipAddress': shipAddress,
  };
}

