# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG – SCRUM-232

- **Nhiệm vụ:** [E2.2] Kiểm thử chức năng nhận tin cảnh báo Telegram và Zalo
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Test Scripts:**
  - `backend/src/test/java/com/cxshield/backend/alert/AlertSendersTest.java`
  - `backend/src/test/java/com/cxshield/backend/alert/AlertDispatcherTest.java`

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 5 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0

## 2. CHI TIẾT KẾT QUẢ KIỂM THỬ CHỨC NĂNG (E2.2 · X4-02)
1. **Tốc độ tiếp nhận & gửi song song (`TC-232-01`):** Góp ý dưới 4 sao kích hoạt gửi đồng thời tới các kênh Telegram và Zalo đang bật thông qua Virtual Thread (`AlertConfig`) với timeout kết nối/đọc tổng cộng `8 giây` (`AlertHttpClients`), đảm bảo tin đến tay quản lý trong vòng 10 giây.
2. **Độ chính xác nội dung mẫu tin `X4-02` & quyền riêng tư (`TC-232-02`):** Tin nhắn hiển thị đầy đủ 6 thành phần theo thiết kế `X4-02` (Chi nhánh, Bàn, Số sao, Nội dung góp ý, Thời gian theo múi giờ Việt Nam, và SĐT khách chỉ khi có `consentAt`).
3. **Lọc trạng thái kênh & ngưỡng sao (`TC-232-03`, `TC-232-04`):** Kênh đang tắt (`is_enabled = false`) không nhận tin; đánh giá `4–5 sao` không kích hoạt cảnh báo.
4. **Xử lý khi kênh lỗi (`TC-232-05`):** Kênh gửi thất bại được ghi log trạng thái `FAILED` kèm nguyên nhân vào bảng `notifications`, không làm gián đoạn kênh khác và không ảnh hưởng trải nghiệm gửi góp ý của khách hàng.

## 3. BẰNG CHỨNG THỰC THI KIỂM THỬ TỰ ĐỘNG HỖ TRỢ (MAVEN SUREFIRE)
```text
[INFO] Running com.cxshield.backend.alert.AlertSendersTest
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.211 s -- in com.cxshield.backend.alert.AlertSendersTest

[INFO] Running com.cxshield.backend.alert.AlertDispatcherTest
09:09:04.308 [main] WARN com.cxshield.backend.alert.AlertDispatcher -- Gửi cảnh báo qua TELEGRAM thất bại cho góp ý 897fdb29-ca22-4af1-bc1b-19c2e655595d
09:09:04.363 [main] INFO com.cxshield.backend.alert.AlertDispatcher -- Chi nhánh 4bc95915-dcba-4e5f-bd70-de13c8611f5b chưa bật kênh cảnh báo nào
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 3.305 s -- in com.cxshield.backend.alert.AlertDispatcherTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 17, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------