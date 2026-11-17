# SCRUM-249 — Test cases: quản trị thuê bao và hóa đơn

## Môi trường và phạm vi

- Nhánh: `feature/SCRUM-217-subscription-invoices`.
- Frontend widget tests và backend unit tests sử dụng mock; không gọi cổng thanh toán hay database production.
- Thời điểm cố định của các test ngày: 2026-11-06 theo Asia/Ho_Chi_Minh.

| ID | Test case | Bước / dữ liệu | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| TC-249-01 | Tính ngày còn lại của thuê bao đang hoạt động | Subscription end date 2026-12-06 | `daysRemaining = 30`; không bật overdue/sắp hết hạn | PASS — BillingServiceTest |
| TC-249-02 | Banner khi còn 3 ngày | Render D5-12 với `isExpiringSoon=true`, `daysRemaining=3` | Hiện banner sắp hết hạn và nút gia hạn | PASS — subscription_page_test.dart |
| TC-249-03 | Ranh giới cảnh báo đúng 7 ngày | end date 2026-11-13 | `daysRemaining=7`, `isExpiringSoon=true` | PASS — BillingManagementE83Test |
| TC-249-04 | Không cảnh báo khi còn 8 ngày | end date 2026-11-14 | `daysRemaining=8`, `isExpiringSoon=false` | PASS — BillingManagementE83Test |
| TC-249-05 | Thuê bao quá hạn | end date 2026-11-01, status OVERDUE | `daysRemaining=-5`, cờ overdue bật; UI hiện banner quá hạn | PASS — BillingServiceTest + widget test |
| TC-249-06 | Giữ nguyên metadata trial và grace | Status TRIAL, có `trialEndDate`/`graceUntil` | API trả đúng trạng thái, ngày trial, grace và autoRenew | PASS — BillingManagementE83Test |
| TC-249-07 | Gói trọn đời không tính ngày hết hạn | Billing cycle LIFETIME, không có end date | `daysRemaining=null`, không banner expiry/overdue | PASS — BillingManagementE83Test |
| TC-249-08 | Tắt tự động gia hạn | OWNER gửi `autoRenew=false` | Lưu false và trả subscription với `autoRenew=false` | PASS — backend service + frontend widget |
| TC-249-09 | Lịch sử giao dịch gắn thông tin hóa đơn | Payment SUCCESS có invoice | Lịch sử trả đúng transaction, trạng thái và invoice number | PASS — BillingServiceTest + widget test |
| TC-249-10 | Tải hóa đơn PDF và XML | Chọn invoice hợp lệ | Backend trả file; UI mở đúng PDF/XML URL theo business và invoice | PASS — BillingServiceTest + widget test |
| TC-249-11 | Chặn role không phải OWNER | BRANCH_MANAGER gọi history/invoices | Backend trả FORBIDDEN trước khi đọc dữ liệu; UI khóa điều khiển quản lý | PASS — BillingManagementE83Test + widget test |
| TC-249-12 | Hóa đơn không thuộc cơ sở / không tìm thấy | Tra cứu invoice ID không có trong business | API trả `INVOICE_NOT_FOUND`; không xuất hóa đơn | PASS — BillingManagementE83Test |
| TC-249-13 | Trạng thái CANCELLED có thể được lấy để kiểm tra | Gọi current subscription sau khi hủy | Kỳ vọng trả được trạng thái CANCELLED để hiển thị; query hiện loại trạng thái này | FAIL — BillingRepository lọc `status != CANCELLED` |
| TC-249-14 | Chuyển trạng thái theo vòng đời sau khi hết hạn | Cho ngày hiện tại vượt qua end date/trial/grace | Kỳ vọng có cập nhật trạng thái overdue/expired/cancelled theo rule | FAIL — không tìm thấy job/service cập nhật các trạng thái này; backend chỉ tính cờ `isOverdue` từ ngày |

## Ghi chú phát hiện

- Payment success RPC trong `database/n5_thanh_toan.sql` tạo/cập nhật subscription thành ACTIVE và xóa `trial_end_date`/`grace_until`.
- Trong phạm vi source kiểm tra, chưa thấy automation chuyển ACTIVE/OVERDUE sang EXPIRED/CANCELLED. Đây là gap cần xử lý/xác nhận ở SCRUM-217.
- Hai case FAIL là sai khác giữa yêu cầu kiểm thử và implementation tìm thấy trong nhánh; các lệnh unit/widget test đều chạy thành công.
