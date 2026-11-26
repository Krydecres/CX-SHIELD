# SCRUM-249 — Báo cáo kiểm thử

- Nhánh: `feature/SCRUM-217-subscription-invoices`
- Ngày: 2026-11-17 (Asia/Bangkok)
- Thực thi: backend unit tests + frontend widget tests; backend dùng mock, không kết nối database production.

## Kết quả chạy

| Lần chạy | Test chạy | Pass | Fail | Errors | Skipped |
|---|---:|---:|---:|---:|---:|
| Backend smoke (BillingService, Controller, API security, E83) | 48 | 48 | 0 | 0 | 0 |
| Frontend `subscription_page_test.dart` | 8 | 8 | 0 | 0 | 0 |
| Backend hồi quy đầy đủ | 307 | 307 | 0 | 0 | 0 |

## Tổng hợp test case SCRUM-249

- Test case được liệt kê: 14.
- PASS theo kết quả case: 12.
- FAIL theo kiểm tra implementation: 2.
- Bug/gap tìm thấy: 2.
- Mọi lệnh test tự động đã chạy đều kết thúc thành công (`BUILD SUCCESS` / `All tests passed!`). Các case FAIL dưới đây là gap chức năng trong source, không phải test runner thất bại.

### Bug/gap

1. **Không có xử lý chuyển trạng thái quá hạn/hết hạn tự động.** Trong nhánh chỉ thấy thanh toán thành công đặt trạng thái ACTIVE; `BillingService` tính `isOverdue` dựa trên ngày nhưng không cập nhật status. Không tìm thấy scheduled job/service đổi sang EXPIRED hoặc CANCELLED khi hết grace period.
2. **Subscription bị hủy bị loại khỏi truy vấn current subscription.** `BillingRepository.findCurrentSubscription` lọc `status != CANCELLED`, nên API không thể trả trạng thái CANCELLED để giao diện/kiểm thử xác nhận vòng đời hủy.

### Giới hạn

- Quyền database/RLS được rà soát từ migration; test backend xác minh owner authorization trong service bằng mock, không chạy RLS trên database thật.
- Hóa đơn PDF/XML được tạo trong unit test và URL tải được xác minh trong widget test; chưa kiểm thử file tải từ môi trường deploy.
- Chi tiết case và lệnh chạy: [test-cases.md](test-cases.md), [test-scripts.md](test-scripts.md).
