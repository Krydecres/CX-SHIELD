# SCRUM-248 — Báo cáo kiểm thử tự động

- Branch: `feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan`
- Ngày chạy: 2026-11-17 (Asia/Bangkok)
- Môi trường: backend unit tests với mocks; không gọi gateway hoặc database thật.
- Secrets: không dùng hoặc thêm secret vào source/test.

## Kết quả

| Lần chạy | Lệnh | Tests run | Pass | Fail | Errors | Skipped |
|---|---|---:|---:|---:|---:|---:|
| Smoke billing/webhook | `-Dtest=BillingServiceTest,VnpayCallbackServiceTest,VnpayGatewayTest,PaymentAdminRepositoryTest test` | 48 | 48 | 0 | 0 | 0 |
| Hồi quy backend | `mvnw.cmd test` | 289 | 289 | 0 | 0 | 0 |

- Test case SCRUM-248 được liệt kê: 12.
- Pass: 12; fail: 0; bug runtime phát hiện: 0.
- Build smoke và hồi quy: `BUILD SUCCESS`.

## Giới hạn/bằng chứng

- Test callback success xác nhận service gọi RPC `confirm_payment_success`; test repository xác nhận đúng tên RPC và tham số. Cả hai dùng mock, không chứng minh PostgreSQL RPC đã tạo/cập nhật subscription trên database chạy thật.
- Test webhook lỗi, hủy, sai chữ ký, sai số tiền và gửi lặp đều kiểm tra rằng đường kích hoạt không bị gọi thêm khi không hợp lệ.
- Chưa chạy sandbox E2E hoặc smoke test trên môi trường được deploy; không dùng tiền thật.
- Có sẵn diff chưa commit trong `VnpayCallbackServiceTest.java` trước khi bắt đầu SCRUM-248; diff đó được giữ nguyên và đã được chạy cùng bộ kiểm thử. Không commit/push/comment Jira.
- Kịch bản chạy nằm trong [test-scripts.md](test-scripts.md); danh sách chi tiết nằm trong [test-cases.md](test-cases.md).
