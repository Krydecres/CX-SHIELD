# TEST CASES: SCRUM-231 - Kiểm thử mã nguồn gửi cảnh báo và lưu trạng thái gửi

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-231
- **Đối tượng kiểm thử:** Backend Listener `FeedbackAlertEventListener.java` & Service lưu bảng `notifications`

## Danh sách Kịch bản Kiểm thử (White-box & Integration)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-231-01** | Trigger gửi cảnh báo khi góp ý dưới 4 sao | Phát sự kiện `FeedbackAlertEvent` với rating 1-3 sao | Backend kích hoạt gửi tin qua tất cả các kênh đang ở trạng thái `ENABLED` | **PASS** |
| **TC-231-02** | Bỏ qua gửi cảnh báo khi rating 4-5 sao | Phát sự kiện `FeedbackAlertEvent` với rating 4-5 sao | Backend không kích hoạt luồng gửi tin Telegram/Zalo | **PASS** |
| **TC-231-03** | Ghi log vào bảng notifications | Kiểm tra DB sau khi gửi cảnh báo thành công | Tạo bản ghi mới trong bảng `notifications` với `status = SENT` | **PASS** |
| **TC-231-04** | Xử lý ngoại lệ khi webhook lỗi (Fault Isolation) | Giả lập Webhook Telegram trả về error 500 | Ghi nhận `status = FAILED` trong DB nhưng không làm crash ứng dụng | **PASS** |
| **TC-231-05** | Kiểm tra hiển thị Số điện thoại theo Privacy | Kiểm tra payload gửi đi khi `allowContact = false` | Số điện thoại khách không được đưa vào nội dung tin nhắn | **PASS** |