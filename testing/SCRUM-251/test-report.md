# SCRUM-251 — Báo cáo kiểm thử

- Ngày chạy: 2026-11-17 (Asia/Bangkok).
- Nhánh: `feature/SCRUM-217-subscription-invoices`.
- Thực thi bằng test tự động, dữ liệu mẫu và API mock; không dùng secret hoặc dữ liệu production.

## Kết quả chạy

| Lệnh | Test chạy | Pass | Fail | Errors/Skipped |
|---|---:|---:|---:|---:|
| Flutter smoke `test/subscription_page_test.dart` | 10 | 10 | 0 | 0 |
| Backend billing smoke | 48 | 48 | 0 | 0 |
| Hồi quy toàn frontend | 211 | 211 | 0 | 0 |
| Hồi quy toàn backend | 307 | 307 | 0 | 0 |

## Tổng hợp test case SCRUM-251

- Test case liệt kê: 14.
- PASS theo automation đã chạy: 14.
- FAIL của test runner: 0.
- Bug/gap đang tồn tại được xác nhận khi rà soát source: 1 (đã có ghi nhận ở SCRUM-249): repository lọc `CANCELLED` khỏi truy vấn thuê bao hiện tại.

TC-251-06 xác minh cách UI hiển thị trạng thái CANCELLED bằng dữ liệu fixture, không xác minh API lấy được trạng thái này. Chi tiết ở [test-cases.md](test-cases.md).

## Giới hạn

- Test giao diện dùng mock; chưa kiểm thử với tài khoản/thuê bao trên môi trường triển khai.
- PDF được kiểm tra không rỗng ở unit test service; giao diện xác minh URL mở PDF. Chưa tải file từ môi trường thật để xác nhận nội dung sau tải.
- Các test backend bảo mật dùng mock và Spring test context; không chạy database/RLS production.

## Tài liệu

- [Test cases](test-cases.md)
- [Test scripts](test-scripts.md)
