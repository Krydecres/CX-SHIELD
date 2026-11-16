# TEST CASES: SCRUM-230 – Kiểm thử tự động cấu hình kênh cảnh báo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-230 (Story cha: SCRUM-126 – E2.1)
- **Test Script:** `e2e/alert_channels_e21.spec.js`
- **Đối tượng kiểm thử:** API cấu hình kênh cảnh báo (`/api/v1/branches/{branchId}/alert-channels`) & kiểm thử hồi quy luồng khảo sát QR (`E1.1`)

## Danh sách Kịch bản Kiểm thử Tự động (Automation E2E)

| Mã TC | Tên kịch bản | Luồng thực thi tự động | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-230-01** | Chặn truy cập trái phép khi thiếu Bearer Token | Gửi các yêu cầu `GET /alert-channels`, `PUT /alert-channels/TELEGRAM`, `POST /alert-channels/EMAIL/tests` không kèm header `Authorization` | Server từ chối toàn bộ yêu cầu với mã HTTP `401 Unauthorized` | **PASS** |
| **TC-230-02** | Thêm / sửa kênh Telegram, Zalo, Email và kiểm tra che token/URL (Masking) | Xác minh cấu trúc dữ liệu cấu hình 3 loại kênh (`TELEGRAM`, `ZALO`, `EMAIL`) qua biến môi trường hoặc hợp đồng dữ liệu che dấu (`AlertMasking`), không lưu cứng secrets thật trong mã nguồn | Dữ liệu trả về có `configured = true`, `maskedBotToken` theo dạng `••••••<4 ký tự cuối>`, `maskedWebhookUrl` theo dạng `https://<host>/••••••` | **PASS** |
| **TC-230-03** | Bật / tắt trạng thái kênh và kiểm tra phản hồi gửi tin thử | Kiểm tra cập nhật cờ `enabled = false` và phản hồi của endpoint gửi thử `POST .../tests` | Cập nhật đúng trạng thái tắt kênh; phản hồi gửi thử trả về trạng thái `success`, thông báo kết quả và mốc thời gian `lastTestedAt` | **PASS** |
| **TC-230-04** | Kiểm thử hồi quy (Smoke Regression) luồng khảo sát QR E1.1 | Gọi `GET /api/v1/surveys/qr/MC-B04` tạo phiên mới và gửi đánh giá `2 sao` qua `POST /api/v1/surveys/rate` | Hệ thống khởi tạo phiên `200 OK` và phân tuyến `2 sao` về `sentimentGroup = "NEGATIVE"`, `targetScreen = "M1-04"` ổn định | **PASS** |