# TEST CASES: SCRUM-197 - Kiểm thử mã nguồn form góp ý và xử lý dữ liệu

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-197
- **Đối tượng kiểm thử:** Backend (`FeedbackController.java`, `FeedbackServiceImpl.java`)

## Danh sách Kịch bản Kiểm thử (White-box & API)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-197-01** | Validation nội dung góp ý | Gửi POST `/api/v1/feedback` với `content = ""` | Server trả về `400 Bad Request` kèm thông báo bắt buộc | **PASS** |
| **TC-197-02** | Validation SĐT hợp lệ | Gửi `phone = "1234"` (sai định dạng) | Server trả về `400 Bad Request` | **PASS** |
| **TC-197-03** | Lưu trạng thái đồng ý liên hệ | Gửi `allowContact = true` kèm SĐT chuẩn | DB lưu đúng `allow_contact = 1` và lưu SĐT | **PASS** |
| **TC-197-04** | Phát Event Cảnh báo khi có góp ý mới | Gửi góp ý 1-3 sao hợp lệ | Backend kích hoạt `FeedbackAlertEvent` để chuẩn bị gửi Telegram/Zalo | **PASS** |
| **TC-197-05** | Chặn Spam / Gửi trùng lặp | Gửi 2 góp ý liên tiếp trên cùng 1 `sessionId` | Lần 2 trả về lỗi hoặc ghi nhận hợp lệ theo nghiệp vụ | **PASS** |