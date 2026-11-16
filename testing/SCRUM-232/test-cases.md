# TEST CASES: SCRUM-232 – Kiểm thử chức năng nhận tin cảnh báo Telegram và Zalo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-232 (Story cha: SCRUM-127 – E2.2)
- **Đối tượng kiểm thử:** Luồng gửi góp ý `M1-04` (`POST /api/v1/feedbacks`) → Mẫu tin cảnh báo `X4-02` qua kênh Telegram Bot & Zalo Webhook
- **Test Scripts hỗ trợ:**
  - `backend/src/test/java/com/cxshield/backend/alert/AlertSendersTest.java` (11 tests)
  - `backend/src/test/java/com/cxshield/backend/alert/AlertDispatcherTest.java` (17 tests)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box & Functional Verification)

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-232-01** | Nhận tin cảnh báo qua Telegram & Zalo đang bật trong vòng 10 giây | 1. Bật đồng thời kênh Telegram Bot và Zalo Webhook tại `D4-01`.<br>2. Quét QR `MC-B04`, chọn `2 sao` và gửi góp ý nội bộ trên `M1-04`.<br>3. Đo thời gian từ lúc bấm gửi đến khi tin xuất hiện trên kênh. | Cả hai kênh đang bật đều nhận được tin cảnh báo trong vòng `<= 10 giây` (cấu hình timeout mạng tối đa `8 giây`, gửi song song qua Virtual Thread). | **PASS** |
| **TC-232-02** | Đối chiếu đầy đủ nội dung mẫu tin `X4-02` & điều kiện hiển thị SĐT | 1. Gửi góp ý có tích chọn đồng ý liên hệ và nhập SĐT hợp lệ.<br>2. Gửi góp ý khác nhưng không tích đồng ý liên hệ.<br>3. Đối chiếu từng dòng nội dung tin nhận được với mẫu `X4-02`. | Tin hiển thị đúng: tiêu đề `CẢNH BÁO GÓP Ý MỚI` (hoặc `[KHẨN]` với 1 sao / gọi gấp), `Chi nhánh`, `Bàn`, `Đánh giá: X/5 sao`, `Góp ý`, `Thời gian` (`HH:mm dd/MM/yyyy` giờ VN); dòng `SĐT khách` chỉ hiển thị khi khách đồng ý liên hệ. | **PASS** |
| **TC-232-03** | Kênh đang tắt (`enabled = false`) không nhận tin cảnh báo | 1. Tắt kênh Zalo Webhook (`Đang tắt`) và giữ bật kênh Telegram Bot (`Đang bật`) tại `D4-01`.<br>2. Gửi góp ý `2 sao` từ màn `M1-04`. | Chỉ kênh Telegram đang bật nhận được tin cảnh báo; kênh Zalo đang tắt hoàn toàn không nhận tin và không phát sinh bản ghi gửi cho Zalo. | **PASS** |
| **TC-232-04** | Đánh giá từ 4 sao trở lên không gửi tin cảnh báo | Chọn `4 sao` và `5 sao` tại màn `M1-01` (ngưỡng mặc định `< 4` sao). | Hệ thống điều hướng sang `M1-02` (Google Maps), không kích hoạt gửi tin cảnh báo tới Telegram hay Zalo. | **PASS** |
| **TC-232-05** | Ghi nhận lỗi khi kênh gặp sự cố & không ảnh hưởng kênh khác | 1. Cấu hình sai Token/Webhook ở kênh Telegram trong khi kênh Zalo vẫn hợp lệ.<br>2. Gửi góp ý `1 sao` từ màn `M1-04`. | Khách vẫn gửi góp ý thành công sang màn cảm ơn `M1-06`; kênh Zalo vẫn nhận được tin cảnh báo; kênh Telegram lỗi được ghi vào bảng `notifications` với `status = "FAILED"` và `error_message` cụ thể. | **PASS** |