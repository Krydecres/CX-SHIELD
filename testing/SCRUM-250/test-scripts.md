# SCRUM-250 — Test scripts automation

## Điều kiện chạy

- Flutter SDK và dependency của frontend đã cài đặt.
- Chạy trong `D:\Learn\CX-SHIELD-SCRUM-217\frontend`.
- Test sử dụng `MockClient` và dữ liệu fixture, không cần secret, tài khoản người dùng, gateway thanh toán hoặc dữ liệu production.

## Chạy bộ test chức năng SCRUM-250

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\frontend
flutter test test/admin_pages_test.dart test/subscription_page_test.dart
```

Bộ test gồm kiểm thử dashboard D5-01 (banner thuê bao), D5-12 (gói hiện tại, cảnh báo/quá hạn, bật/tắt gia hạn, lịch sử, URL tải hóa đơn và quyền truy cập) cùng các test khác đang có trong hai file.

## Chạy hồi quy frontend

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\frontend
flutter test
```

## Nguồn test

- [subscription_page_test.dart](../../frontend/test/subscription_page_test.dart)
- [admin_pages_test.dart](../../frontend/test/admin_pages_test.dart)

Không xóa hoặc thay thế test cũ. SCRUM-250 bổ sung test bật lại tự động gia hạn trong `subscription_page_test.dart` và hai test banner dashboard trong `admin_pages_test.dart`.
