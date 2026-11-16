# TEST CASES: SCRUM-231 – Kiểm thử mã nguồn gửi cảnh báo và lưu trạng thái gửi

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-231 (Story cha: SCRUM-127 – E2.2)
- **Đối tượng kiểm thử:**
  - Backend: `FeedbackAlertEventListener.java`, `AlertDispatcher.java`, `AlertMessages.java`, `AlertHttpClients.java`, `AlertConfig.java`, `FeedbackServiceImpl.java`
  - Unit Test Script: `backend/src/test/java/com/cxshield/backend/alert/AlertDispatcherTest.java`

## Danh sách Kịch bản Kiểm thử Mã nguồn (White-box, Fault Isolation & Unit Test)

| Mã TC | Tên kịch bản | Cách thức kiểm tra & Điểm rà soát | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-231-01** | Kích hoạt gửi cảnh báo qua các kênh đang bật khi góp ý `< 4` sao | Rà soát `FeedbackServiceImpl.submitFeedback()` (L111–118), `FeedbackAlertEventListener` (L18–20), `AlertDispatcher.dispatch()` (L92–118) và chạy `AlertDispatcherTest#sendsToEveryEnabledChannel`, `ratingAtDefaultThresholdIsNotAlerted` | Góp ý `< 4` sao (hoặc `< thresholdStar` theo quy tắc chi nhánh) gửi tin song song tới tất cả kênh có `is_enabled = true`; góp ý `>= 4` sao bị bỏ qua | **PASS** |
| **TC-231-02** | Dựng đúng mẫu tin `X4-02` & chỉ kèm SĐT khi khách đồng ý | Rà soát `AlertMessages.feedbackMessage()` (L31–48), `AlertDispatcher.dispatch()` (L104) và chạy `AlertDispatcherTest#sendsFullMessageAndStoresSentNotification`, `hidesPhoneWithoutConsent`, `urgentFeedbackIsMarked` | Tin nhắn có đủ: Chi nhánh, Bàn, Số sao, Nội dung góp ý, Thời gian (`Asia/Ho_Chi_Minh`), tiền tố `[KHẨN]` khi khẩn cấp; chỉ thêm dòng `SĐT khách` khi `feedback.getConsentAt() != null` | **PASS** |
| **TC-231-03** | Lưu bảng `notifications` kèm trạng thái `SENT` & `sent_at` | Rà soát `AlertDispatcher.sendToChannel()` (L120–136) và chạy `AlertDispatcherTest#sendsFullMessageAndStoresSentNotification` | Tạo bản ghi trong `notifications` đủ các trường `business_id`, `branch_id`, `channel_id`, `feedback_id`, `recipient`, `content`, `table_code`, `severity`, `status = "SENT"`, `sent_at` | **PASS** |
| **TC-231-04** | Cô lập lỗi kênh gửi & lưu trạng thái `FAILED` không ảnh hưởng lưu góp ý | Rà soát `AlertDispatcher.dispatchAsync()` (L68–77), `sendToChannel()` (L137–156) và chạy `AlertDispatcherTest#failedChannelIsRecordedAndOthersStillSend`, `asyncDispatchSwallowsErrorsSoFeedbackIsNotAffected` | Khi 1 kênh lỗi (`AlertSendException` / `RuntimeException`), hệ thống ghi `status = "FAILED"`, `error_message` (cắt tối đa 300 ký tự), kênh khác vẫn gửi bình thường và góp ý của khách đã lưu không bị rollback | **PASS** |
| **TC-231-05** | Giới hạn timeout dưới 10 giây, bảo mật log & chạy bộ Unit Test | Rà soát `AlertHttpClients.java` (L24–25: connect 3s, read 5s), `AlertConfig.java` (Virtual Thread) và chạy toàn bộ 17 unit tests trong `AlertDispatcherTest` | Tổng thời gian chờ kết nối/đọc `<= 8s` (đảm bảo SLA `< 10s`); log hệ thống không ghi SĐT, nội dung góp ý hay Bot Token; 17/17 unit tests chạy xanh | **PASS** |