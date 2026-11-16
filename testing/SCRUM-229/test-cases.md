# TEST CASES: SCRUM-229 - Kiểm thử chức năng cài kênh cảnh báo Telegram, Zalo và Email

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-229
- **Đối tượng kiểm thử:** Giao diện Admin Màn D4-01 (Cấu hình Webhook)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-229-01** | Cấu hình Bot Telegram (Token & Chat ID) | Nhập Bot Token và Chat ID hợp lệ tại màn D4-01 | Lưu cấu hình thành công, hiển thị trạng thái "Đã kết nối" | **PASS** |
| **TC-229-02** | Nút "Gửi thử" (Test Connection) | Bấm nút "Gửi thử" tin nhắn Telegram/Zalo | Nhận được tin nhắn mẫu tức thì trong group test | **PASS** |
| **TC-229-03** | Validation Webhook URL Zalo / Email | Nhập URL Zalo Webhook hoặc Email sai định dạng | Hiển thị thông báo lỗi ngay tại trường nhập liệu | **PASS** |
| **TC-229-04** | Kiểm tra hiển thị Token sau khi lưu | Tải lại trang D4-01 sau khi lưu thành công | Bot Token tự động chuyển thành dạng ẩn `********` | **PASS** |