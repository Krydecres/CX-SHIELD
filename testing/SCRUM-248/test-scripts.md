# SCRUM-248 — Test scripts automation

## Tiền điều kiện

- Chạy trong `D:\Learn\CX-SHIELD\backend`.
- Dùng Maven Wrapper và test doubles/mocks; không cần API key, secret, tài khoản gateway hay service role key thật.
- Bộ smoke test không gọi VietQR/PayOS/VNPAY sandbox và không tạo giao dịch tiền thật.

## Smoke test billing / webhook / activation

```powershell
cd D:\Learn\CX-SHIELD\backend
.\mvnw.cmd "-Dtest=BillingServiceTest,VnpayCallbackServiceTest,VnpayGatewayTest,PaymentAdminRepositoryTest" test
```

Bao gồm tạo lệnh thanh toán, thông tin hóa đơn, callback success/failure/cancel, gửi lặp, chữ ký và số tiền sai, cùng ánh xạ RPC `confirm_payment_success`.

## Hồi quy toàn backend

```powershell
cd D:\Learn\CX-SHIELD\backend
.\mvnw.cmd test
```

## Sandbox E2E

Chưa chạy. Chỉ thực hiện sau khi xác nhận cấu hình sandbox và thông tin test do dự án cấp. Không thay secret trong file cấu hình/mã nguồn; dùng secret qua biến môi trường hoặc secret store của môi trường test. Không dùng tài khoản production/tiền thật.
