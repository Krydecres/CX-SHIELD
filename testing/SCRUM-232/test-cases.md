# TEST CASES: SCRUM-232 - Kiểm thử chức năng nhận tin cảnh báo Telegram và Zalo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-232
- **Đối tượng kiểm thử:** Kênh thông báo thực tế (Telegram Bot & Zalo OA)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-232-01** | Kiểm tra SLA thời gian gửi tin (<= 10 giây) | Đánh giá 1 sao trên ứng dụng khảo sát | Tin nhắn cảnh báo về Telegram/Zalo trong vòng dưới 10 giây | **PASS** |
| **TC-232-02** | Đối chiếu nội dung mẫu tin X4-02 | Kiểm tra tin nhắn nhận được trong Group Telegram | Đầy đủ: Chi nhánh, Số bàn, Số sao, Nội dung góp ý, Thời gian | **PASS** |
| **TC-232-03** | Hiển thị SĐT khi khách đồng ý liên hệ | Gửi góp ý chọn `allowContact = true` kèm SĐT | Tin nhắn có hiển thị chính xác SĐT của khách | **PASS** |
| **TC-232-04** | Kiểm tra kênh đang OFF không nhận tin | Tắt kênh Zalo ở Admin rồi gửi góp ý 2 sao | Chỉ có Telegram nhận được tin nhắn, Zalo không có tin mới | **PASS** |