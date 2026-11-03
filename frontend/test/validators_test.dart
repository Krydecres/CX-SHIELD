import 'package:cx_shield/app/router.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/features/d3_01_auth/auth_error_messages.dart';
import 'package:cx_shield/features/d3_02_onboarding/onboarding_validators.dart';
import 'package:cx_shield/features/d3_05_google_place/place_id_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('D3-01 đăng nhập', () {
    test('kiểm tra email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('abc'), isNotNull);
      expect(validateEmail('chu.co.so@example.com'), isNull);
    });

    test('mật khẩu đăng ký cần 8 ký tự gồm chữ và số', () {
      expect(validatePassword('abc123', isRegister: true), isNotNull);
      expect(validatePassword('abcdefgh', isRegister: true), isNotNull);
      expect(validatePassword('abcd1234', isRegister: true), isNull);
      expect(validatePassword('abc', isRegister: false), isNull);
    });

    test('báo lỗi rõ ràng khi email đã tồn tại / sai mật khẩu', () {
      expect(
        authErrorMessage(const AuthException('User already registered', code: 'user_already_exists')),
        contains('đã được đăng ký'),
      );
      expect(
        authErrorMessage(const AuthException('Invalid login credentials', code: 'invalid_credentials')),
        'Email hoặc mật khẩu không đúng.',
      );
    });
  });

  group('D3-02 onboarding', () {
    test('kiểm tra tên thương hiệu, số điện thoại, mã màu', () {
      expect(validateBrandName('  '), isNotNull);
      expect(validateBrandName('Maison Coffee'), isNull);
      expect(validatePhone(''), isNull);
      expect(validatePhone('090 123 4567'), isNull);
      expect(validatePhone('+84901234567'), isNull);
      expect(validatePhone('12345'), isNotNull);
      expect(validateHexColor('#1E40AF'), isNull);
      expect(validateHexColor('1E40AF'), isNotNull);
      expect(parseHexColor('#333333')?.toARGB32(), 0xFF333333);
    });

    test('chỉ nhận logo PNG, JPG, WEBP', () {
      expect(logoContentType('logo.PNG'), 'image/png');
      expect(logoContentType('logo.jpeg'), 'image/jpeg');
      expect(logoContentType('logo.gif'), isNull);
    });
  });

  group('D3-05 Google Place ID', () {
    const placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';

    test('nhận Place ID hoặc link chứa Place ID', () {
      expect(validatePlaceId(placeId), isNull);
      expect(extractPlaceId('https://search.google.com/local/writereview?placeid=$placeId'), placeId);
    });

    test('báo lỗi khi Place ID sai định dạng', () {
      expect(validatePlaceId(''), isNotNull);
      expect(validatePlaceId('ChIJ123'), isNotNull);
      expect(validatePlaceId('Quán cà phê Maison'), isNotNull);
    });

    test('tạo link viết đánh giá Google', () {
      expect(buildReviewUrl(placeId), 'https://search.google.com/local/writereview?placeid=$placeId');
    });

    test('link nhập thủ công phải là https của Google', () {
      expect(validateReviewUrl('https://g.page/r/abc/review'), isNull);
      expect(validateReviewUrl('http://g.page/r/abc/review'), isNotNull);
      expect(validateReviewUrl('https://evil-google.com/x'), isNotNull);
    });
  });

  group('Điều hướng', () {
    Uri u(String path) => Uri.parse(path);

    test('chưa đăng nhập không vào được trang quản trị', () {
      expect(sessionRedirect(SessionStatus.signedOut, false, u('/dashboard')), '/login');
      expect(sessionRedirect(SessionStatus.signedOut, false, u('/funnel/google-place')), '/login');
      expect(sessionRedirect(SessionStatus.signedOut, false, u('/login')), isNull);
    });

    test('đăng nhập nhưng chưa có cơ sở thì vào onboarding', () {
      expect(sessionRedirect(SessionStatus.ready, false, u('/dashboard')), '/onboarding');
    });

    test('đăng nhập xong vào thẳng Dashboard', () {
      expect(sessionRedirect(SessionStatus.ready, true, u('/login')), '/dashboard');
      expect(sessionRedirect(SessionStatus.ready, true, u('/')), '/dashboard');
      expect(sessionRedirect(SessionStatus.ready, true, u('/funnel/google-place')), isNull);
    });

    test('hoàn tất bước 1 onboarding chuyển sang bước 2 (D3-05)', () {
      // Trong lúc làm mới hồ sơ vẫn ở lại trang onboarding, không bị đẩy về splash.
      expect(sessionRedirect(SessionStatus.loadingProfile, false, u('/onboarding'), hasProfile: true), isNull);
      expect(sessionRedirect(SessionStatus.ready, true, u('/onboarding')), '/funnel/google-place?step=onboarding');
    });

    test('lần đầu tải hồ sơ thì hiện splash', () {
      expect(sessionRedirect(SessionStatus.loadingProfile, false, u('/dashboard')), '/');
    });
  });
}
