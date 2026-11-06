import 'package:flutter/material.dart';

class AdminMenuItem {
  const AdminMenuItem({required this.label, required this.path, required this.icon, this.screenCode});

  final String label;
  final String path;
  final IconData icon;

  /// Mã màn hình trong sheet "Màn Hình"; null khi chưa có màn chính thức.
  final String? screenCode;
}

/// Menu bên của khung admin dùng chung D3-00 (theo wireframe D3-03 / D3-05).
const adminMenu = [
  AdminMenuItem(label: 'Tổng quan', path: '/dashboard', icon: Icons.dashboard_outlined, screenCode: 'D5-01'),
  AdminMenuItem(label: 'Chi nhánh', path: '/branches', icon: Icons.store_outlined, screenCode: 'D3-03'),
  AdminMenuItem(label: 'Nhân sự & phân quyền', path: '/staff', icon: Icons.groups_outlined, screenCode: 'D3-04'),
  AdminMenuItem(label: 'Cài đặt phễu', path: '/funnel/google-place', icon: Icons.filter_alt_outlined, screenCode: 'D3-05'),
  AdminMenuItem(label: 'Kênh cảnh báo', path: '/alerts/channels', icon: Icons.notifications_active_outlined, screenCode: 'D4-01'),
  AdminMenuItem(label: 'Ấn phẩm QR / NFC', path: '/print-materials', icon: Icons.qr_code_2_outlined, screenCode: 'D3-09'),
  AdminMenuItem(label: 'Khuyến mãi & quà', path: '/promotions', icon: Icons.card_giftcard_outlined),
  AdminMenuItem(label: 'Thành viên', path: '/members', icon: Icons.loyalty_outlined),
  AdminMenuItem(label: 'Chống gian lận', path: '/fraud', icon: Icons.gpp_maybe_outlined, screenCode: 'D3-14'),
  AdminMenuItem(label: 'Cài đặt hệ thống', path: '/settings', icon: Icons.settings_outlined),
];

AdminMenuItem? menuItemFor(String location) {
  for (final item in adminMenu) {
    if (location == item.path || location.startsWith('${item.path}/') || location.startsWith('${item.path}?')) {
      return item;
    }
  }
  return null;
}
