# TEST CASES: SCRUM-233 – Kiểm thử tự động luồng gửi cảnh báo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-233 (Story cha: SCRUM-127 – E2.2)
- **Test Script:** `e2e/alert_dispatch_e22.spec.js`
- **Đối tượng kiểm thử:** Luồng tự động E2E góp ý dưới 4 sao (`POST /api/v1/feedbacks`) → kích hoạt gửi cảnh báo (`AlertDispatcher`) → lưu `notifications`, kết hợp smoke test và kiểm thử hồi quy luồng góp ý `E1.3`

## Danh sách Kịch bản Kiểm thử Tự động (Automation E2E & Regression)

| Mã TC | Tên kịch bản | Luồng thực thi tự động | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-233-01** | Gửi góp ý 2 sao kích hoạt luồng cảnh báo trong vòng 10 giây (`SLA < 10s`) | Quét QR `MC-B04` → chấm `2 sao` → gửi góp ý nội bộ kèm SĐT và `consentToContact = true` qua `POST /api/v1/feedbacks`, đo tổng thời gian phản hồi | HTTP `200 OK`, `status = "NEW"`, `targetScreen = "M1-06"`, thời gian xử lý dưới `10.000ms` (thực tế: `125ms`) | **PASS** |
| **TC-233-02** | Gửi góp ý khẩn cấp 1 sao & xác minh hợp đồng lưu `notifications` (`SENT` / `FAILED` mock) | Chấm `1 sao` (`allowUrgentCall = true`) → gửi góp ý khẩn cấp `urgentCallback = true`, đo thời gian kích hoạt và đối chiếu schema bản ghi `notifications` (dùng dữ liệu giả lập, không hardcode secrets) | HTTP `200 OK` trong `15ms` (`< 10.000ms`); cấu trúc bản ghi `SENT` có `sent_at`, nhánh `FAILED` ghi `error_message <= 300` ký tự | **PASS** |
| **TC-233-03** | Kiểm thử hồi quy `E1.3` – Gửi góp ý 3 sao không để lại SĐT | Chấm `3 sao` (`NEGATIVE` → `M1-04`) → gửi góp ý với `consentToContact = false` và không nhập SĐT | HTTP `200 OK`, hệ thống lưu góp ý thành công và điều hướng sang `M1-06` | **PASS** |
| **TC-233-04** | Kiểm thử hồi quy `E1.3` – Chặn nội dung quá ngắn (`< 3` ký tự) và SĐT sai định dạng | Gửi `commentText = "Tệ"` (2 ký tự) và gửi SĐT `"12345"` sai định dạng số Việt Nam tới `POST /api/v1/feedbacks` | Server từ chối cả hai yêu cầu với mã HTTP `400 Bad Request` | **PASS** |
| **TC-233-05** | Smoke test hồi quy – Đánh giá 5 sao điều hướng `M1-02` (`POSITIVE`) | Quét QR `MC-B04` và gửi đánh giá `5 sao` qua `POST /api/v1/surveys/rate` | HTTP `200 OK`, `sentimentGroup = "POSITIVE"`, `targetScreen = "M1-02"`, `allowUrgentCall = false` | **PASS** |