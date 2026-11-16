# TEST CASES: SCRUM-229 – Kiểm thử chức năng cài kênh cảnh báo Telegram, Zalo và Email

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-229 (Story cha: SCRUM-126 – E2.1)
- **Đối tượng kiểm thử:** Màn hình Admin `D4-01` (`frontend/lib/features/d4_01_alert_channels/alert_channels_page.dart`)
- **Test Script hỗ trợ:** `frontend/test/alert_channels_test.dart`

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box & UI Verification)

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-229-01** | Thêm / sửa kênh Telegram, Zalo Webhook và Email theo chi nhánh | 1. Mở màn `D4-01` (`/alerts/channels`) với tài khoản Chủ cơ sở / Quản lý chi nhánh.<br>2. Nhập hợp lệ `Bot Token` + `Chat ID` (Telegram Bot), `Webhook URL` `https://...` (Zalo Webhook), `Email nhận cảnh báo` (Email) và nhấn `"Lưu kênh"`. | Hiển thị thông báo `"Đã lưu cấu hình kênh."`, trạng thái thẻ chuyển từ `"Chưa cấu hình"` sang `"Đang bật"` và lưu đúng theo chi nhánh đang chọn. | **PASS** |
| **TC-229-02** | Che giấu Bot Token & Webhook URL sau khi lưu | Sau khi lưu thành công kênh Telegram và Zalo trên `D4-01`, quan sát lại ô nhập liệu và tải lại trang. | Ô nhập `Bot Token` / `Webhook URL` tự động xóa trắng, placeholder hiển thị giá trị đã che (`••••••<4 ký tự cuối>` / `https://host/••••••`) kèm dòng nhắc `"Đã lưu và được che. Để trống nếu không đổi."`. | **PASS** |
| **TC-229-03** | Kiểm tra bắt lỗi nhập dữ liệu sai (Validation) | 1. Để trống các trường bắt buộc hoặc nhập `Bot Token` sai định dạng, `Chat ID` chứa khoảng trắng, `Webhook URL` dùng `http://`, `Email` thiếu tên miền.<br>2. Nhấn `"Lưu kênh"`. | Giao diện chặn gửi API và hiển thị đúng thông báo lỗi tại từng ô (`"Bot Token không đúng định dạng."`, `"Chat ID không đúng định dạng."`, `"Webhook URL phải là địa chỉ https hợp lệ."`, `"Email không đúng định dạng."`). | **PASS** |
| **TC-229-04** | Thao tác nút `"Gửi tin thử"` và ghi nhận thời gian gửi thử | 1. Kiểm tra trạng thái nút `"Gửi tin thử"` khi kênh chưa lưu.<br>2. Lưu kênh hợp lệ rồi nhấn `"Gửi tin thử"` (và thử thêm trường hợp token/email lỗi). | Khi chưa lưu: nút `"Gửi tin thử"` bị vô hiệu hóa. Khi đã lưu: gửi thành công hiển thị `"Đã gửi tin thử thành công."` và cập nhật `"Gửi thử gần nhất: dd/MM/yyyy HH:mm"`; nếu gửi thất bại hiển thị banner nêu rõ lý do lỗi. | **PASS** |
| **TC-229-05** | Bật / tắt từng kênh cảnh báo & kiểm tra phân quyền chỉ xem | 1. Gạt công tắc `Switch` trên từng thẻ kênh (`Đang bật` ↔ `Đang tắt`) và nhấn `"Lưu kênh"`.<br>2. Đăng nhập bằng tài khoản nhân viên không có quyền quản lý vào `D4-01`. | Gạt công tắc và lưu cập nhật đúng trạng thái `"Đang bật"` / `"Đang tắt"` độc lập từng kênh; tài khoản chỉ xem thấy banner cảnh báo quyền và toàn bộ nút `"Lưu kênh"`, `"Gửi tin thử"`, công tắc đều bị khóa. | **PASS** |