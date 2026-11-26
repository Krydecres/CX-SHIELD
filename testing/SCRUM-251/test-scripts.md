# SCRUM-251 — Test scripts automation

## Điều kiện chạy

- Flutter SDK, Java 21+ và Maven Wrapper của dự án.
- Mọi request UI dùng mock; backend service test dùng mock repository/clock.
- Không cần credentials gateway, Supabase secret, tài khoản thật hay dữ liệu production.

## Smoke test giao diện D5-12 và fixture trạng thái thuê bao

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\frontend
flutter test test/subscription_page_test.dart
```

Bao gồm mẫu trạng thái ACTIVE, TRIAL, OVERDUE, EXPIRED, CANCELLED; ngày hết hạn/số ngày còn lại; bật/tắt gia hạn; lịch sử giao dịch; URL PDF và banner sắp hết hạn.

## Smoke test backend quản lý thuê bao/hóa đơn

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\backend
.\mvnw.cmd "-Dtest=BillingServiceTest,BillingControllerTest,BillingApiSecurityTest,BillingManagementE83Test" test
```

## Hồi quy đầy đủ

```powershell
cd D:\Learn\CX-SHIELD-SCRUM-217\frontend
flutter test

cd D:\Learn\CX-SHIELD-SCRUM-217\backend
.\mvnw.cmd test
```

## Nguồn automation

- [subscription_page_test.dart](../../frontend/test/subscription_page_test.dart)
- [admin_pages_test.dart](../../frontend/test/admin_pages_test.dart)
- [BillingServiceTest.java](../../backend/src/test/java/com/cxshield/backend/billing/BillingServiceTest.java)
- [BillingManagementE83Test.java](../../backend/src/test/java/com/cxshield/backend/billing/BillingManagementE83Test.java)
