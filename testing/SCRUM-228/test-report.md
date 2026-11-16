# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN – SCRUM-228

- **Nhiệm vụ:** [E2.1] Kiểm thử mã nguồn cấu hình kênh cảnh báo
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Unit Test Scripts:**
  - `backend/src/test/java/com/cxshield/backend/alert/AlertChannelControllerTest.java` (4 tests)
  - `backend/src/test/java/com/cxshield/backend/alert/AlertChannelServiceTest.java` (19 tests)
  - `backend/src/test/java/com/cxshield/backend/alert/AlertMaskingTest.java` (5 tests)
  - `backend/src/test/java/com/cxshield/backend/alert/WebhookUrlValidatorTest.java` (17 tests)
  - `backend/src/test/java/com/cxshield/backend/alert/AlertSendersTest.java` (11 tests)

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 6
- **Số case PASS:** 6 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0

## 2. KẾT QUẢ RÀ SOÁT MÃ NGUỒN CHI TIẾT (WHITE-BOX & SECURITY)
1. **Bảo mật dữ liệu nhạy cảm (`AlertMasking.java` & `AlertDtos.java`):**
   - `AlertMasking.maskToken()` chỉ giữ lại 4 ký tự cuối (`••••••1234`), `maskUrl()` ẩn toàn bộ đường dẫn/query webhook (`https://host/••••••`).
   - Record `SaveAlertChannelRequest` ghi đè `toString()` để ẩn `botToken` và `webhookUrl`, ngăn rò rỉ bí mật vào application log.
2. **Kiểm tra hợp lệ & chống SSRF (`AlertChannelService.java` & `WebhookUrlValidator.java`):**
   - Kiểm tra chặt định dạng `BOT_TOKEN`, `CHAT_ID`, `EMAIL`; `WebhookUrlValidator` bắt buộc giao thức `https` và phân giải DNS để chặn toàn bộ dải IP loopback, link-local, site-local, carrier-grade NAT.
3. **Ngưỡng mặc định & gửi thử (`AlertChannelService.java`):**
   - Hằng số `DEFAULT_THRESHOLD_STAR = 4` áp dụng mặc định cho chi nhánh chưa tùy chỉnh `alert_rules`.
   - `sendTest()` lưu `last_tested_at` khi gửi thành công và bắt `AlertSendException` trả về `success = false` khi lỗi kết nối ngoài.
4. **Phân quyền đa chi nhánh (`n4_canh_bao.sql` & `AlertChannelService.java`):**
   - Tầng service kiểm tra quyền truy cập chi nhánh qua `requireBranch(token, branchId)` và tầng PostgreSQL RLS (`alert_channels_all_managers`) giới hạn quyền ghi cho `OWNER` và `BRANCH_MANAGER`.

## 3. BẰNG CHỨNG CHẠY UNIT TEST THỰC TẾ (MAVEN SUREFIRE)
```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.cxshield.backend.alert.AlertSendersTest
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.211 s -- in com.cxshield.backend.alert.AlertSendersTest
[INFO] Running com.cxshield.backend.alert.AlertMaskingTest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.037 s -- in com.cxshield.backend.alert.AlertMaskingTest
[INFO] Running com.cxshield.backend.alert.WebhookUrlValidatorTest
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.319 s -- in com.cxshield.backend.alert.WebhookUrlValidatorTest
[INFO] Running com.cxshield.backend.alert.AlertChannelControllerTest
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.147 s -- in com.cxshield.backend.alert.AlertChannelControllerTest
[INFO] Running com.cxshield.backend.alert.AlertChannelServiceTest
[INFO] Tests run: 19, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.499 s -- in com.cxshield.backend.alert.AlertChannelServiceTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 56, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------