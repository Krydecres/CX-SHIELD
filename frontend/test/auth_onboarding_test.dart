import 'package:cx_shield/app/router.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/features/d3_00_admin_shell/admin_menu.dart';
import 'package:cx_shield/features/d3_01_auth/auth_error_messages.dart';
import 'package:cx_shield/features/d3_02_onboarding/onboarding_validators.dart';
import 'package:cx_shield/main.dart' show extractQrCode;
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('thông báo lỗi đăng nhập', () {
    String messageFor(String code) => authErrorMessage(AuthException('error', code: code));

    test('đổi mã lỗi Supabase sang tiếng Việt', () {
      expect(messageFor('email_exists'), contains('đã được đăng ký'));
      expect(messageFor('email_not_confirmed'), contains('chưa được xác nhận'));
      expect(messageFor('weak_password'), contains('quá yếu'));
      expect(messageFor('over_email_send_rate_limit'), contains('quá nhanh'));
      expect(messageFor('over_request_rate_limit'), contains('quá nhanh'));
      expect(messageFor('validation_failed'), 'Email không hợp lệ.');
      expect(messageFor('email_address_invalid'), 'Email không hợp lệ.');
      expect(messageFor('signup_disabled'), contains('khoá đăng ký'));
      expect(messageFor('provider_disabled'), contains('Google'));
    });

    test('lỗi không có mã vẫn nhận ra qua nội dung', () {
      expect(authErrorMessage(const AuthException('Invalid login credentials')), 'Email hoặc mật khẩu không đúng.');
      expect(authErrorMessage(const AuthException('User already registered')), contains('đã được đăng ký'));
    });

    test('lỗi lạ giữ nguyên nội dung từ Supabase', () {
      expect(authErrorMessage(const AuthException('Lỗi khác')), 'Lỗi khác');
    });

    test('lỗi mạng có thông báo riêng', () {
      expect(authErrorMessage(Exception('offline')), contains('Không kết nối được'));
    });
  });

  group('kiểm tra đăng nhập', () {
    test('email bỏ khoảng trắng hai đầu', () {
      expect(validateEmail(' chu@example.com '), isNull);
      expect(validateEmail(null), 'Vui lòng nhập email.');
      expect(validateEmail('chu@example'), 'Email không hợp lệ.');
    });

    test('mật khẩu bắt buộc nhập', () {
      expect(validatePassword('', isRegister: false), 'Vui lòng nhập mật khẩu.');
      expect(validatePassword(null, isRegister: true), 'Vui lòng nhập mật khẩu.');
    });

    test('mật khẩu đăng ký cần cả chữ và số', () {
      expect(validatePassword('12345678', isRegister: true), 'Mật khẩu cần có cả chữ và số.');
      expect(validatePassword('abcdefgh', isRegister: true), 'Mật khẩu cần có cả chữ và số.');
      expect(validatePassword('abc123', isRegister: true), 'Mật khẩu tối thiểu 8 ký tự.');
    });
  });

  group('kiểm tra onboarding', () {
    test('giới hạn độ dài tên', () {
      expect(validateBrandName('a' * 120), isNull);
      expect(validateBrandName('a' * 121), isNotNull);
      expect(validateBranchName(null), isNull);
      expect(validateBranchName('a' * 120), isNull);
      expect(validateBranchName('a' * 121), isNotNull);
    });

    test('chuẩn hoá số điện thoại', () {
      expect(normalizePhone('090 123.45-67'), '0901234567');
      expect(validatePhone('090.123.4567'), isNull);
      expect(validatePhone('84901234567'), isNotNull);
    });

    test('mã màu sai không đổi được thành màu', () {
      expect(parseHexColor('blue'), isNull);
      expect(parseHexColor(' #1E40AF ')?.toARGB32(), 0xFF1E40AF);
    });

    test('tên file logo không có đuôi bị từ chối', () {
      expect(logoContentType('logo'), isNull);
      expect(logoContentType('logo.final.webp'), 'image/webp');
      expect(logoContentType('anh.JPG'), 'image/jpeg');
    });

    test('màu mặc định nằm trong bảng màu gợi ý và đều hợp lệ', () {
      expect(brandColorPresets, contains(defaultBrandColor));
      expect(brandColorPresets.map(validateHexColor), everyElement(isNull));
    });
  });

  group('điều hướng', () {
    Uri u(String path) => Uri.parse(path);

    test('đang khởi động hoặc lỗi hồ sơ thì ở splash', () {
      expect(sessionRedirect(SessionStatus.initializing, false, u('/dashboard')), '/');
      expect(sessionRedirect(SessionStatus.initializing, false, u('/')), isNull);
      expect(sessionRedirect(SessionStatus.profileError, false, u('/dashboard')), '/');
    });

    test('chưa có cơ sở không vào được khung admin', () {
      expect(sessionRedirect(SessionStatus.ready, false, u('/funnel/google-place')), '/onboarding');
      expect(sessionRedirect(SessionStatus.ready, false, u('/onboarding')), isNull);
    });

    test('đã có cơ sở vào lại onboarding thì sang bước 2', () {
      expect(sessionRedirect(SessionStatus.ready, true, u('/onboarding')), '/funnel/google-place?step=onboarding');
    });

    test('làm mới hồ sơ không làm mất trang đang xem', () {
      expect(sessionRedirect(SessionStatus.loadingProfile, true, u('/funnel/google-place'), hasProfile: true), isNull);
    });

    test('URL /?code=abc phải vào luồng đăng nhập, không mở khảo sát', () {
      final codeUri = Uri.parse('http://localhost:3000/?code=abc');
      expect(extractQrCode(codeUri), isNull);
      expect(sessionRedirect(SessionStatus.signedOut, false, codeUri), '/login');
      expect(sessionRedirect(SessionStatus.ready, true, codeUri), '/dashboard');
    });

    test('URL /?qr=MC-B04 và /s/MC-B04 vẫn mở khảo sát', () {
      final qrParamUri = Uri.parse('http://localhost:3000/?qr=MC-B04');
      final pathUri = Uri.parse('http://localhost:3000/s/MC-B04');
      final surveyUri = Uri.parse('http://localhost:3000/survey?qr=MC-B04');

      expect(extractQrCode(qrParamUri), 'MC-B04');
      expect(extractQrCode(pathUri), 'MC-B04');

      expect(sessionRedirect(SessionStatus.signedOut, false, pathUri), isNull);
      expect(sessionRedirect(SessionStatus.signedOut, false, surveyUri), isNull);
    });
  });

  group('menu admin', () {
    test('tìm mục menu theo đường dẫn', () {
      expect(menuItemFor('/dashboard')?.screenCode, 'D5-01');
      expect(menuItemFor('/funnel/google-place')?.screenCode, 'D3-05');
      expect(menuItemFor('/funnel/google-place/abc')?.label, 'Cài đặt phễu');
      expect(menuItemFor('/khong-co'), isNull);
    });

    test('đường dẫn menu không trùng nhau', () {
      expect(adminMenu.map((item) => item.path).toSet(), hasLength(adminMenu.length));
    });
  });
}
