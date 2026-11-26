# SCRUM-250 — Test cases quản lý thuê bao, gia hạn và hóa đơn

## Phạm vi và môi trường

- Nhánh kiểm thử: `feature/SCRUM-217-subscription-invoices`.
- Phạm vi: màn D5-12 và banner thuê bao trên dashboard quản trị.
- Kiểm thử tự động Flutter Widget Test, API được giả lập bằng mock; không đăng nhập môi trường thật, không kết nối database production, không phát sinh thanh toán.
- Các nút hóa đơn được xác minh qua URL gửi tới handler mở liên kết; không tải file PDF/XML thật từ môi trường triển khai.

| ID | Test case | Kết quả mong đợi | Kết quả thực tế |
|---|---|---|---|
| TC-250-01 | Xem gói hiện tại, trạng thái và số ngày còn lại | Hiện đúng gói Nâng cao, trạng thái đang hoạt động, còn 22 ngày | PASS — `subscription_page_test.dart` |
| TC-250-02 | D5-12 cảnh báo khi thuê bao còn 3 ngày | Hiện banner sắp hết hạn, số ngày và nút gia hạn | PASS — `subscription_page_test.dart` |
| TC-250-03 | Thuê bao quá hạn | Hiện banner quá hạn, số ngày quá hạn và trạng thái tương ứng | PASS — `subscription_page_test.dart` |
| TC-250-04 | Tắt tự động gia hạn | Gửi `autoRenew=false`, cập nhật giao diện và thông báo thành công | PASS — `subscription_page_test.dart` |
| TC-250-05 | Bật lại tự động gia hạn | Gửi `autoRenew=true`, cập nhật giao diện và thông báo thành công | PASS — test bổ sung `subscription_page_test.dart` |
| TC-250-06 | Xem lịch sử giao dịch thành công và thất bại | Hiện mã giao dịch, số tiền và trạng thái của từng giao dịch | PASS — `subscription_page_test.dart` |
| TC-250-07 | Chọn tải hóa đơn PDF | Mở đúng URL hóa đơn PDF theo cơ sở và mã hóa đơn | PASS — `subscription_page_test.dart`; xác minh URL mock |
| TC-250-08 | Chọn tải hóa đơn XML | Mở đúng URL hóa đơn XML theo cơ sở và mã hóa đơn | PASS — `subscription_page_test.dart`; xác minh URL mock |
| TC-250-09 | Người không phải OWNER truy cập trang thuê bao | Hiện cảnh báo quyền hạn và khóa thao tác gia hạn | PASS — `subscription_page_test.dart` |
| TC-250-10 | Dashboard có thuê bao còn 3 ngày | Hiện banner cảnh báo; nút “Gia hạn ngay” điều hướng tới D5-12 | PASS — test bổ sung `admin_pages_test.dart` |
| TC-250-11 | Dashboard có thuê bao còn 8 ngày | Không hiện banner sắp hết hạn hoặc banner quá hạn | PASS — test bổ sung `admin_pages_test.dart` |

## Tệp automation

- [subscription_page_test.dart](../../frontend/test/subscription_page_test.dart)
- [admin_pages_test.dart](../../frontend/test/admin_pages_test.dart)
