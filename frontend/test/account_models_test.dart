import 'package:cx_shield/core/models/account_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const businessJson = {
    'id': 'b1',
    'brandName': 'Maison',
    'displayName': 'Maison Q1',
    'industry': 'Bán lẻ',
    'phone': '0901234567',
    'logoUrl': 'https://example.com/logo.png',
    'primaryColor': '#1E40AF',
  };

  Membership membership(String role) => Membership.fromJson({
        'membershipId': 'm1',
        'role': role,
        'business': businessJson,
      });

  test('đọc Me kèm membership và cơ sở', () {
    final me = Me.fromJson({
      'userId': 'u1',
      'email': 'chu@example.com',
      'fullName': 'Chủ cơ sở',
      'onboarded': true,
      'memberships': [
        {'membershipId': 'm1', 'role': 'OWNER', 'business': businessJson},
      ],
    });

    expect(me.userId, 'u1');
    expect(me.onboarded, isTrue);
    expect(me.memberships.single.role, 'OWNER');
    expect(me.memberships.single.business.brandName, 'Maison');
    expect(me.memberships.single.business.primaryColor, '#1E40AF');
  });

  test('Me thiếu dữ liệu dùng giá trị mặc định', () {
    final me = Me.fromJson({'userId': 'u1'});

    expect(me.onboarded, isFalse);
    expect(me.memberships, isEmpty);
  });

  test('tên hiển thị ưu tiên họ tên, rồi email', () {
    expect(const Me(userId: 'u', fullName: 'An', email: 'a@b.c', onboarded: true, memberships: []).displayName, 'An');
    expect(const Me(userId: 'u', fullName: '  ', email: 'a@b.c', onboarded: true, memberships: []).displayName, 'a@b.c');
    expect(const Me(userId: 'u', onboarded: true, memberships: []).displayName, 'Người dùng');
  });

  test('chỉ Chủ cơ sở và Quản lý chi nhánh được cấu hình phễu', () {
    expect(membership('OWNER').canManageFunnel, isTrue);
    expect(membership('BRANCH_MANAGER').canManageFunnel, isTrue);
    expect(membership('CASHIER').canManageFunnel, isFalse);
    expect(membership('SERVER').canManageFunnel, isFalse);
  });

  test('đọc chi nhánh', () {
    final branch = Branch.fromJson({
      'id': 'c1',
      'businessId': 'b1',
      'code': 'CN01',
      'name': 'Maison Q1',
      'status': 'ACTIVE',
    });

    expect(branch.code, 'CN01');
    expect(branch.status, 'ACTIVE');
  });

  test('nhãn vai trò theo sheet Thuật ngữ', () {
    expect(roleLabel('OWNER'), 'Chủ cơ sở');
    expect(roleLabel('OWNER', branchCount: 2), 'Chủ chuỗi');
    expect(roleLabel('BRANCH_MANAGER'), 'Quản lý chi nhánh');
    expect(roleLabel('SHIFT_MANAGER'), 'Quản lý ca');
    expect(roleLabel('CS_STAFF'), 'Nhân viên CSKH');
    expect(roleLabel('CASHIER'), 'Thu ngân');
    expect(roleLabel('SERVER'), 'Nhân viên phục vụ');
    expect(roleLabel('KHAC'), 'KHAC');
  });
}
