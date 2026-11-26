# SCRUM-250 — Báo cáo kiểm thử

- Ngày chạy: 2026-11-17 (Asia/Bangkok).
- Nhánh: `feature/SCRUM-217-subscription-invoices`.
- Hình thức: Flutter Widget Test; API dùng mock/fixture.

## Kết quả thực thi

| Lệnh | Test chạy | Pass | Fail | Kết quả |
|---|---:|---:|---:|---|
| `flutter test test/admin_pages_test.dart test/subscription_page_test.dart` | 28 | 28 | 0 | Thành công |
| `flutter test` (toàn bộ frontend) | 210 | 210 | 0 | Thành công |

## Tổng hợp test case SCRUM-250

- Test case được liệt kê: 11.
- PASS: 11.
- FAIL: 0.
- Bug phát hiện trong phạm vi các case đã kiểm tra: 0.

Kết quả trên xác nhận hành vi giao diện và request/URL dựa trên mock. Đây chưa phải kiểm thử end-to-end với dịch vụ thật.

## Giới hạn kiểm thử

- Không chạy backend test trong lượt SCRUM-250; các kiểm tra tập trung vào giao diện D5-12 và dashboard quản trị.
- Tải hóa đơn được kiểm tra bằng URL chuyển tới hàm mở liên kết; chưa tải hoặc xác thực nội dung file PDF/XML thực từ server.
- Chưa kiểm tra thủ công trên môi trường triển khai, database thật hoặc tài khoản có dữ liệu thuê bao thật.

## Tài liệu

- [Test cases](test-cases.md)
- [Test scripts](test-scripts.md)
