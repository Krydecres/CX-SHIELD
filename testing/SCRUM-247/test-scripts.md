# SCRUM-247 — Test scripts (automation)

## Tiền điều kiện

- Mở PowerShell tại repo `D:\Learn\CX-SHIELD`, branch `feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan`.
- Unit tests dùng mock, không kết nối cổng thanh toán và không dùng tiền thật.
- Cần Flutter SDK cho frontend; Java/Maven Wrapper cho backend.

## Frontend: validation, payload và hiển thị trạng thái thanh toán

```powershell
cd D:\Learn\CX-SHIELD\frontend
flutter test test/billing_test.dart
```

## Backend: checkout, hóa đơn, callback VNPAY, lỗi và hủy

```powershell
cd D:\Learn\CX-SHIELD\backend
.\mvnw.cmd "-Dtest=BillingServiceTest,VnpayCallbackServiceTest,VnpayGatewayTest" test
```

## Kịch bản sandbox thủ công — chưa tự động hóa / chưa chạy

Chỉ thực hiện khi môi trường được cấu hình rõ là sandbox và dùng dữ liệu sandbox do dự án cung cấp. Không dùng tài khoản/công cụ thanh toán thật.

1. Mở D5-11, bật xuất hóa đơn, kiểm tra mã số thuế, tên công ty và email hợp lệ; thử từng trường rỗng/sai định dạng.
2. Tắt xuất hóa đơn, xác nhận checkout không gửi hồ sơ hóa đơn.
3. Trên sandbox của nhà cung cấp được xác nhận, chạy QR success, failure và cancel; kiểm tra trạng thái payment và subscription sau mỗi lần quay về.
4. Lưu ảnh màn hình đã che dữ liệu cá nhân và mã giao dịch nhạy cảm; ghi nhận lỗi kèm môi trường, bước tái hiện và kết quả mong đợi/thực tế.

Không đánh dấu kịch bản thủ công PASS nếu chưa chạy trực tiếp trên sandbox. Source hiện chuyển sang VNPAY; chưa thấy PayOS, nên cần xác nhận phạm vi nhà cung cấp trước khi chạy E2E.
