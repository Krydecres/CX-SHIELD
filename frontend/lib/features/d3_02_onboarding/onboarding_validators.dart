import 'package:flutter/painting.dart';

const industries = [
  'Nhà hàng / Quán ăn',
  'Cà phê & đồ uống',
  'Spa & làm đẹp',
  'Nha khoa',
  'Phòng khám',
  'Khách sạn & lưu trú',
  'Bán lẻ',
  'Khác',
];

const defaultBrandColor = '#1E40AF';
const brandColorPresets = ['#1E40AF', '#0F766E', '#B91C1C', '#7C3AED', '#C2410C', '#333333'];

const maxLogoBytes = 2 * 1024 * 1024;
const logoContentTypes = {'png': 'image/png', 'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'webp': 'image/webp'};

final _hexColor = RegExp(r'^#[0-9A-Fa-f]{6}$');
final _phone = RegExp(r'^(\+84|0)[0-9]{9,10}$');

String? validateBrandName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Vui lòng nhập tên thương hiệu.';
  if (text.length > 120) return 'Tên thương hiệu tối đa 120 ký tự.';
  return null;
}

String? validateBranchName(String? value) {
  if ((value?.trim().length ?? 0) > 120) return 'Tên cơ sở / chi nhánh tối đa 120 ký tự.';
  return null;
}

String? validatePhone(String? value) {
  final text = (value ?? '').replaceAll(RegExp(r'[\s.-]'), '');
  if (text.isEmpty) return null;
  if (!_phone.hasMatch(text)) return 'Số điện thoại không hợp lệ (ví dụ 0901234567).';
  return null;
}

String normalizePhone(String value) => value.replaceAll(RegExp(r'[\s.-]'), '');

String? validateHexColor(String? value) {
  if (!_hexColor.hasMatch(value?.trim() ?? '')) return 'Mã màu phải có dạng #RRGGBB.';
  return null;
}

Color? parseHexColor(String value) {
  if (validateHexColor(value) != null) return null;
  return Color(int.parse('FF${value.trim().substring(1)}', radix: 16));
}

/// Trả về content type của logo, hoặc null nếu định dạng không được hỗ trợ.
String? logoContentType(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return null;
  return logoContentTypes[fileName.substring(dot + 1).toLowerCase()];
}
