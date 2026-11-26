# SCRUM-249 — Test scripts automation

## Tiền điều kiện

- Nhánh: `feature/SCRUM-217-subscription-invoices`.
- Chạy test mock/local; không cần credentials gateway, production data hay secret.
- Ngày kiểm thử backend được cố định trong test để kết quả tính ngày ổn định.

## Smoke test backend quản trị thuê bao/hóa đơn

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\backend
.\mvnw.cmd "-Dtest=BillingServiceTest,BillingControllerTest,BillingApiSecurityTest,BillingManagementE83Test" test
```

## Smoke test giao diện D5-12

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\frontend
flutter test test/subscription_page_test.dart
```

## Hồi quy backend đầy đủ

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\backend
.\mvnw.cmd test
```

Nếu chạy thủ công trên sandbox, dùng dữ liệu test đã cấp; không dùng tài khoản production hoặc tiền thật. Chụp bằng chứng đã ẩn dữ liệu cá nhân trước khi đính kèm.
