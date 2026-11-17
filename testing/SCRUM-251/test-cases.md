# SCRUM-251 — Test cases tự động quản trị thuê bao và hóa đơn

## Phạm vi và môi trường

- Nhánh: `feature/SCRUM-217-subscription-invoices`.
- Dữ liệu thuê bao được tạo trong test bằng fixture; không dùng tài khoản production hoặc secret.
- Giao diện/API dùng mock. Unit test backend dùng mock repository và clock cố định; không kết nối database production hay cổng thanh toán.

| ID | Test case | Kết quả mong đợi | Kết quả |
|---|---|---|---|
| TC-251-01 | Hiển thị gói hiện tại, ngày hết hạn và số ngày còn lại | Hiện tên gói, trạng thái ACTIVE và số ngày theo dữ liệu mẫu | PASS — widget D5-12 |
| TC-251-02 | Trạng thái ACTIVE | Hiện nhãn “Đang hoạt động” | PASS — ma trận trạng thái fixture |
| TC-251-03 | Trạng thái TRIAL | Hiện nhãn “Dùng thử”; backend trả ngày trial/grace | PASS — widget + `BillingManagementE83Test` |
| TC-251-04 | Trạng thái OVERDUE | Hiện nhãn/banner quá hạn và số ngày âm | PASS — widget + `BillingServiceTest` |
| TC-251-05 | Trạng thái EXPIRED | Hiện nhãn “Hết hạn” trên giao diện | PASS — ma trận trạng thái fixture |
| TC-251-06 | Trạng thái CANCELLED | Giao diện hiển thị nhãn “Đã huỷ” khi nhận fixture trạng thái | PASS — kiểm tra hiển thị UI bằng fixture |
| TC-251-07 | Banner sắp hết hạn trên D5-12 | Khi còn 3 ngày, hiện banner và nút gia hạn | PASS — widget D5-12 |
| TC-251-08 | Tắt tự động gia hạn | Gửi `autoRenew=false` và hiện xác nhận | PASS — widget + backend smoke |
| TC-251-09 | Bật lại tự động gia hạn | Gửi `autoRenew=true` và hiện xác nhận | PASS — widget |
| TC-251-10 | Lịch sử giao dịch | Hiện giao dịch SUCCESS và FAILED với mã, số tiền, trạng thái | PASS — widget D5-12 |
| TC-251-11 | Xuất hóa đơn PDF | Backend tạo dữ liệu PDF không rỗng | PASS — `BillingServiceTest` |
| TC-251-12 | Chọn tải hóa đơn PDF | Giao diện chuyển đúng URL PDF của hóa đơn | PASS — widget; URL được xác minh qua mock handler |
| TC-251-13 | Banner dashboard khi thuê bao gần hết hạn | Còn 3 ngày thì hiện cảnh báo; nút gia hạn điều hướng D5-12 | PASS — `admin_pages_test.dart` |
| TC-251-14 | Không cảnh báo dashboard khi còn trên 7 ngày | Còn 8 ngày thì không hiện cảnh báo sắp hết hạn/quá hạn | PASS — `admin_pages_test.dart` |

## Phát hiện khi rà soát source

- **1 vấn đề đã được ghi nhận ở SCRUM-249 vẫn còn:** `BillingRepository.findCurrentSubscription` lọc `status != CANCELLED`, nên API thuê bao hiện tại không thể trả bản ghi CANCELLED. Test ở TC-251-06 chỉ xác minh nhãn UI với fixture; nó không chứng minh API production trả trạng thái này. Tham chiếu: `backend/src/main/java/com/cxshield/backend/billing/BillingRepository.java`.
- Đây là phát hiện qua rà soát implementation; không tính là test runner thất bại.

## Tệp automation

- [Widget test D5-12 và ma trận trạng thái](../../frontend/test/subscription_page_test.dart)
- [Widget test banner dashboard](../../frontend/test/admin_pages_test.dart)
- [Backend test thuê bao/hóa đơn](../../backend/src/test/java/com/cxshield/backend/billing/BillingServiceTest.java)
- [Backend test mốc ngày và quyền](../../backend/src/test/java/com/cxshield/backend/billing/BillingManagementE83Test.java)
