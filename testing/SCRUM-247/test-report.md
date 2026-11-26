# SCRUM-247 — Báo cáo kiểm thử

- Branch: `feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan`
- Thời điểm chạy: 2026-11-17 (Asia/Bangkok)
- Phạm vi chạy: Flutter billing unit test và backend billing service/callback/gateway unit test; tất cả dùng mock.
- Sandbox / tiền thật: không chạy giao dịch sandbox E2E; không dùng tiền thật.

## Kết quả chạy tự động

| Bộ kiểm thử | Kết quả | Pass | Fail | Bỏ qua |
|---|---:|---:|---:|---:|
| `flutter test test/billing_test.dart` | PASS | 30 | 0 | 0 |
| Maven: `BillingServiceTest,VnpayCallbackServiceTest,VnpayGatewayTest` | PASS | 45 | 0 | 0 |
| **Tổng số test tự động** | **PASS** | **75** | **0** | **0** |

## Kết quả theo test case

- 12 test case được ghi trong [test-cases.md](test-cases.md).
- 10 case được kiểm tra bằng unit test/mock: PASS.
- 1 case VietQR sandbox E2E: chưa chạy.
- 1 case PayOS: bị chặn vì source hiện tại không có tích hợp PayOS.
- Bug được xác nhận trong lần chạy tự động: 0. Sai khác phạm vi nhà cung cấp (mô tả Jira yêu cầu VietQR/PayOS, source hiện triển khai VNPAY với QR) cần xác nhận trước nghiệm thu; chưa kết luận là lỗi runtime.

## Bằng chứng và giới hạn

- Frontend: lệnh kết thúc `All tests passed!`.
- Backend: Maven `BUILD SUCCESS`, 45 tests, 0 failures/errors/skipped.
- Callback success/cancel/failure chỉ được xác minh bằng test mock; không xác minh giao dịch, callback hoặc kích hoạt thuê bao trên môi trường sandbox thật.
- Chưa có ảnh bằng chứng từ cổng sandbox vì chưa chạy E2E. Không ghi nhận PASS cho các luồng E2E chưa chạy.
- Kịch bản và lệnh chạy nằm trong [test-scripts.md](test-scripts.md).
