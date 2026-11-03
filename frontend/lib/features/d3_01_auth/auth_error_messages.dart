import 'package:supabase_flutter/supabase_flutter.dart';

/// Đổi lỗi Supabase Auth thành thông báo tiếng Việt rõ ràng (E7.1).
String authErrorMessage(Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'Email hoặc mật khẩu không đúng.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng "Quên mật khẩu?".';
      case 'email_not_confirmed':
        return 'Email chưa được xác nhận. Vui lòng mở hộp thư và bấm vào liên kết xác nhận.';
      case 'weak_password':
        return 'Mật khẩu quá yếu. Hãy dùng ít nhất 8 ký tự gồm chữ và số.';
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau ít phút.';
      case 'validation_failed':
      case 'email_address_invalid':
        return 'Email không hợp lệ.';
      case 'signup_disabled':
        return 'Hệ thống đang tạm khoá đăng ký mới.';
      case 'provider_disabled':
        return 'Đăng nhập bằng Google chưa được bật trên hệ thống.';
    }
    if (error.message.toLowerCase().contains('invalid login credentials')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (error.message.toLowerCase().contains('already registered')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập hoặc dùng "Quên mật khẩu?".';
    }
    return error.message;
  }
  return 'Không kết nối được máy chủ xác thực. Vui lòng thử lại.';
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Vui lòng nhập email.';
  if (!_emailPattern.hasMatch(email)) return 'Email không hợp lệ.';
  return null;
}

String? validatePassword(String? value, {required bool isRegister}) {
  final password = value ?? '';
  if (password.isEmpty) return 'Vui lòng nhập mật khẩu.';
  if (isRegister) {
    if (password.length < 8) return 'Mật khẩu tối thiểu 8 ký tự.';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) || !RegExp(r'[0-9]').hasMatch(password)) {
      return 'Mật khẩu cần có cả chữ và số.';
    }
  }
  return null;
}
