import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Trạng thái kết nối hiển thị trên D3-05: chưa kết nối / chưa xác minh / đã kết nối / lỗi Place ID.
enum PlaceConnectionStatus {
  notConnected('Chưa kết nối'),
  pending('Chưa xác minh'),
  connected('Đã kết nối'),
  error('Lỗi Place ID');

  const PlaceConnectionStatus(this.label);

  final String label;

  /// Màu chữ và màu nền của nhãn trạng thái theo theme hiện tại.
  (Color, Color) colorsIn(AppColors c) => switch (this) {
        notConnected => (c.textSecondary, c.background),
        pending => (c.warning, c.warningSoft),
        connected => (c.success, c.successSoft),
        error => (c.error, c.errorSoft),
      };

  static PlaceConnectionStatus fromApi(String? value) => switch (value) {
        'PENDING' => pending,
        'CONNECTED' => connected,
        'ERROR' => error,
        _ => notConnected,
      };
}

class GooglePlaceConfig {
  const GooglePlaceConfig({
    required this.branchId,
    required this.branchName,
    this.placeId,
    this.placeName,
    this.placeAddress,
    this.reviewUrl,
    required this.status,
    this.updatedAt,
    required this.googleVerificationEnabled,
  });

  factory GooglePlaceConfig.fromJson(Map<String, dynamic> json) => GooglePlaceConfig(
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String? ?? '',
        placeId: json['placeId'] as String?,
        placeName: json['placeName'] as String?,
        placeAddress: json['placeAddress'] as String?,
        reviewUrl: json['reviewUrl'] as String?,
        status: PlaceConnectionStatus.fromApi(json['connectionStatus'] as String?),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String).toLocal(),
        googleVerificationEnabled: json['googleVerificationEnabled'] as bool? ?? false,
      );

  final String branchId;
  final String branchName;
  final String? placeId;
  final String? placeName;
  final String? placeAddress;
  final String? reviewUrl;
  final PlaceConnectionStatus status;
  final DateTime? updatedAt;
  final bool googleVerificationEnabled;
}

class PlaceVerification {
  const PlaceVerification({
    required this.placeId,
    this.placeName,
    this.placeAddress,
    this.reviewUrl,
    required this.status,
    required this.verifiedWithGoogle,
    required this.message,
  });

  factory PlaceVerification.fromJson(Map<String, dynamic> json) => PlaceVerification(
        placeId: json['placeId'] as String,
        placeName: json['placeName'] as String?,
        placeAddress: json['placeAddress'] as String?,
        reviewUrl: json['reviewUrl'] as String?,
        status: PlaceConnectionStatus.fromApi(json['connectionStatus'] as String?),
        verifiedWithGoogle: json['verifiedWithGoogle'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );

  final String placeId;
  final String? placeName;
  final String? placeAddress;
  final String? reviewUrl;
  final PlaceConnectionStatus status;
  final bool verifiedWithGoogle;
  final String message;
}
