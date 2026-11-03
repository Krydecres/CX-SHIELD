import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/config/app_config.dart';

class OnboardingApi {
  OnboardingApi(this._api);

  final ApiClient _api;

  /// Tải logo lên Supabase Storage vào thư mục riêng của người dùng, trả về URL công khai.
  Future<String> uploadLogo({required Uint8List bytes, required String extension, required String contentType}) async {
    final client = Supabase.instance.client;
    final path = '${client.auth.currentUser!.id}/logo-${DateTime.now().millisecondsSinceEpoch}.$extension';
    final bucket = client.storage.from(AppConfig.logoBucket);
    await bucket.uploadBinary(path, bytes, fileOptions: FileOptions(contentType: contentType));
    return bucket.getPublicUrl(path);
  }

  Future<void> submit({
    required String brandName,
    required String branchName,
    required String industry,
    required String phone,
    required String primaryColor,
    String? logoUrl,
  }) async {
    await _api.post('/onboarding', {
      'brandName': brandName,
      'branchName': branchName,
      'industry': industry,
      'phone': phone.isEmpty ? null : phone,
      'primaryColor': primaryColor,
      'logoUrl': logoUrl,
    });
  }
}
