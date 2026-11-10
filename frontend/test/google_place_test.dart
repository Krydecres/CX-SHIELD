import 'dart:convert';

import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/theme/app_colors.dart';
import 'package:cx_shield/features/d3_02_onboarding/onboarding_api.dart';
import 'package:cx_shield/features/d3_05_google_place/google_place_api.dart';
import 'package:cx_shield/features/d3_05_google_place/google_place_models.dart';
import 'package:cx_shield/features/d3_05_google_place/place_id_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';
  const configJson = {
    'branchId': 'c1',
    'branchName': 'Quận 1',
    'placeId': placeId,
    'placeName': 'Maison',
    'placeAddress': '1 Lê Lợi',
    'reviewUrl': 'https://search.google.com/local/writereview?placeid=$placeId',
    'connectionStatus': 'CONNECTED',
    'updatedAt': '2026-11-05T10:00:00Z',
    'googleVerificationEnabled': true,
  };

  group('trạng thái kết nối', () {
    test('đổi từ mã API', () {
      expect(PlaceConnectionStatus.fromApi('PENDING'), PlaceConnectionStatus.pending);
      expect(PlaceConnectionStatus.fromApi('CONNECTED'), PlaceConnectionStatus.connected);
      expect(PlaceConnectionStatus.fromApi('ERROR'), PlaceConnectionStatus.error);
      expect(PlaceConnectionStatus.fromApi('NOT_CONNECTED'), PlaceConnectionStatus.notConnected);
      expect(PlaceConnectionStatus.fromApi(null), PlaceConnectionStatus.notConnected);
    });

    test('màu nhãn theo theme đang dùng', () {
      expect(PlaceConnectionStatus.connected.colorsIn(AppColors.light), (AppColors.light.success, AppColors.light.successSoft));
      expect(PlaceConnectionStatus.error.colorsIn(AppColors.dark), (AppColors.dark.error, AppColors.dark.errorSoft));
      expect(PlaceConnectionStatus.pending.colorsIn(AppColors.dark), (AppColors.dark.warning, AppColors.dark.warningSoft));
      expect(
        PlaceConnectionStatus.notConnected.colorsIn(AppColors.light),
        (AppColors.light.textSecondary, AppColors.light.background),
      );
    });
  });

  group('đọc dữ liệu API', () {
    test('cấu hình đã lưu', () {
      final config = GooglePlaceConfig.fromJson(configJson);

      expect(config.placeId, placeId);
      expect(config.status, PlaceConnectionStatus.connected);
      expect(config.updatedAt, DateTime.utc(2026, 11, 5, 10).toLocal());
      expect(config.googleVerificationEnabled, isTrue);
    });

    test('chi nhánh chưa cấu hình', () {
      final config = GooglePlaceConfig.fromJson({'branchId': 'c1', 'connectionStatus': 'NOT_CONNECTED'});

      expect(config.branchName, '');
      expect(config.placeId, isNull);
      expect(config.updatedAt, isNull);
      expect(config.status, PlaceConnectionStatus.notConnected);
      expect(config.googleVerificationEnabled, isFalse);
    });

    test('kết quả xác minh', () {
      final verification = PlaceVerification.fromJson({
        'placeId': placeId,
        'connectionStatus': 'PENDING',
        'message': 'Chưa xác minh với Google.',
      });

      expect(verification.status, PlaceConnectionStatus.pending);
      expect(verification.verifiedWithGoogle, isFalse);
      expect(verification.message, 'Chưa xác minh với Google.');
    });
  });

  group('Place ID và link đánh giá', () {
    test('lấy Place ID từ chuỗi có khoảng trắng hoặc place_id', () {
      expect(extractPlaceId('  $placeId  '), placeId);
      expect(extractPlaceId('place_id:$placeId'), placeId);
      expect(extractPlaceId('https://x.test/?PLACEID=$placeId&a=1'), placeId);
    });

    test('chấp nhận độ dài trong giới hạn', () {
      expect(validatePlaceId('a' * 20), isNull);
      expect(validatePlaceId('a' * 512), isNull);
      expect(validatePlaceId('a' * 19), isNotNull);
      expect(validatePlaceId('a' * 513), isNotNull);
      expect(validatePlaceId(null), 'Vui lòng nhập Google Place ID.');
    });

    test('link nhập thủ công có thể bỏ trống và nhận tên miền con', () {
      expect(validateReviewUrl(null), isNull);
      expect(validateReviewUrl('  '), isNull);
      expect(validateReviewUrl('https://search.google.com/local/writereview?placeid=abc'), isNull);
      expect(validateReviewUrl('https://goo.gl/abc'), isNull);
      expect(validateReviewUrl('không phải link'), isNotNull);
    });
  });

  group('gọi API', () {
    late List<http.Request> sent;

    ApiClient clientReturning(Object body) {
      sent = [];
      return ApiClient(
        baseUrl: 'http://api.test',
        accessToken: () => 'token',
        httpClient: MockClient((request) async {
          sent.add(request);
          return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
        }),
      );
    }

    test('tải cấu hình theo chi nhánh', () async {
      final config = await GooglePlaceApi(clientReturning(configJson)).load('c1');

      expect(sent.single.method, 'GET');
      expect(sent.single.url.path, '/api/v1/branches/c1/google-place');
      expect(config.status, PlaceConnectionStatus.connected);
    });

    test('xác minh gửi Place ID', () async {
      final api = GooglePlaceApi(clientReturning({'placeId': placeId, 'connectionStatus': 'CONNECTED'}));

      final result = await api.verify('c1', placeId);

      expect(sent.single.method, 'POST');
      expect(sent.single.url.path, '/api/v1/branches/c1/google-place/verifications');
      expect(jsonDecode(sent.single.body), {'placeId': placeId});
      expect(result.status, PlaceConnectionStatus.connected);
    });

    test('lưu gửi Place ID và link đánh giá', () async {
      await GooglePlaceApi(clientReturning(configJson)).save('c1', placeId: placeId, reviewUrl: 'https://g.page/r/abc');

      expect(sent.single.method, 'PUT');
      expect(jsonDecode(sent.single.body), {'placeId': placeId, 'reviewUrl': 'https://g.page/r/abc'});
    });

    test('onboarding gửi null khi không nhập số điện thoại', () async {
      await OnboardingApi(clientReturning({})).submit(
        brandName: 'Maison',
        branchName: 'Quận 1',
        industry: 'Bán lẻ',
        phone: '',
        primaryColor: '#1E40AF',
      );

      expect(sent.single.url.path, '/api/v1/onboarding');
      expect(jsonDecode(sent.single.body), {
        'brandName': 'Maison',
        'branchName': 'Quận 1',
        'industry': 'Bán lẻ',
        'phone': null,
        'primaryColor': '#1E40AF',
        'logoUrl': null,
      });
    });
  });
}
