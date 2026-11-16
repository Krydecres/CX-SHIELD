# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN – SCRUM-231

- **Nhiệm vụ:** [E2.2] Kiểm thử mã nguồn gửi cảnh báo và lưu trạng thái gửi
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Unit Test Script:** `backend/src/test/java/com/cxshield/backend/alert/AlertDispatcherTest.java`

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 5 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0

## 2. KẾT QUẢ RÀ SOÁT MÃ NGUỒN CHI TIẾT (WHITE-BOX INSPECTION)
1. **Kích hoạt sự kiện & chọn kênh (`FeedbackAlertEventListener.java` & `AlertDispatcher.java`):**
   - Sau khi lưu `Feedback`, `FeedbackServiceImpl` phát `FeedbackCreatedEvent` và `FeedbackAlertEventListener` gọi `alertDispatcher.dispatchAsync(event)` trên `alertExecutor` (Virtual Thread).
   - Hệ thống kiểm tra ngưỡng theo chi nhánh (mặc định `DEFAULT_THRESHOLD_STAR = 4`), chỉ gửi tới các kênh có `is_enabled = true` và bỏ qua các đánh giá từ 4 sao trở lên.
2. **Định dạng tin nhắn `X4-02` & quyền riêng tư (`AlertMessages.java` & `AlertDispatcher.java`):**
   - Tin cảnh báo chứa đầy đủ: Chi nhánh, Bàn, Đánh giá (`X/5 sao`), Nội dung góp ý, Thời gian (`HH:mm dd/MM/yyyy`, múi giờ `Asia/Ho_Chi_Minh`) và nhãn `[KHẨN]` khi khách yêu cầu gọi gấp / chấm 1 sao.
   - Điều kiện `feedback.getConsentAt() != null` đảm bảo số điện thoại khách chỉ được đính kèm khi khách đã đồng ý cho phép liên hệ.
3. **Lưu trữ `notifications`, cô lập lỗi & SLA dưới 10 giây (`AlertHttpClients.java`):**
   - Mỗi kênh gửi độc lập trên một luồng riêng; kết quả lưu vào `notifications` với `status = "SENT"` (kèm `sent_at`) hoặc `status = "FAILED"` (kèm `error_message` giới hạn 300 ký tự).
   - `AlertHttpClients` cấu hình `connectTimeout = 3s`, `readTimeout = 5s` (tổng tối đa 8 giây) và tắt auto-redirect để đảm bảo tin đến trong vòng 10 giây và chống SSRF.

## 3. BẰNG CHỨNG CHẠY UNIT TEST THỰC TẾ (`./mvnw test -Dtest=AlertDispatcherTest`)
```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.cxshield.backend.alert.AlertDispatcherTest
09:09:04.087 [main] ERROR com.cxshield.backend.alert.AlertDispatcher -- Không lưu được notifications cho góp ý db1c9c40-a564-4d2f-bb6c-286068571de1: IllegalStateException
09:09:04.192 [main] ERROR com.cxshield.backend.alert.AlertDispatcher -- Lỗi không mong đợi khi gửi qua TELEGRAM cho góp ý b1e33dd7-2673-4706-87d3-0616b707a8eb: IllegalStateException
09:09:04.308 [main] WARN com.cxshield.backend.alert.AlertDispatcher -- Gửi cảnh báo qua TELEGRAM thất bại cho góp ý 897fdb29-ca22-4af1-bc1b-19c2e655595d
09:09:04.325 [main] ERROR com.cxshield.backend.alert.AlertDispatcher -- Không xử lý được cảnh báo cho góp ý 8f1b76b5-159b-404c-8157-350e2d184bb2: IllegalStateException
09:09:04.363 [main] INFO com.cxshield.backend.alert.AlertDispatcher -- Chi nhánh 4bc95915-dcba-4e5f-bd70-de13c8611f5b chưa bật kênh cảnh báo nào
09:09:04.380 [main] WARN com.cxshield.backend.alert.AlertDispatcher -- Bỏ qua cảnh báo cho góp ý e4bce258-9855-466e-86c1-25ef5b004770: chưa cấu hình SUPABASE_SERVICE_ROLE_KEY
09:09:04.403 [main] WARN com.cxshield.backend.alert.AlertDispatcher -- Gửi cảnh báo qua TELEGRAM thất bại cho góp ý ed7a1e8f-7f66-40a2-986d-84b459eed02f
09:09:04.444 [main] WARN com.cxshield.backend.alert.AlertDispatcher -- Bỏ qua cảnh báo cho góp ý 6ad464bf-862e-4eb0-a5a3-783eab8d0db2: không có chi nhánh 4bc95915-dcba-4e5f-bd70-de13c8611f5b trên CSDL
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.305 s -- in com.cxshield.backend.alert.AlertDispatcherTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------