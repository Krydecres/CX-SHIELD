# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN – SCRUM-222

- **Nhiệm vụ:** [E1.2] Kiểm thử mã nguồn phân luồng 4–5 sao và ghi nhận lượt chuyển Google
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Unit Test Script:** `backend/src/test/java/com/cxshield/backend/SurveyControllerTest.java`

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 6
- **Số case PASS:** 6 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0 (Có 01 ghi nhận kỹ thuật `OBS-222-01`)

## 2. KẾT QUẢ RÀ SOÁT MÃ NGUỒN CHI TIẾT (WHITE-BOX INSPECTION)
1. **Logic phân luồng 4–5 sao:** Tại `SurveyServiceImpl.java` (dòng 117 và 152–155), điều kiện `boolean isPositive = stars >= 4;` định tuyến chính xác mức 4 sao và 5 sao sang `targetScreen = "M1-02"` với `allowUrgentCall = false`.
2. **Tạo link Google Review & ghi nhận `redirect_clicked_at`:**
   - `PlaceIdParser.java` (dòng 46–48) sinh link chuẩn `https://search.google.com/local/writereview?placeid=` sau khi chuẩn hóa định dạng Place ID (`^[A-Za-z0-9_-]{20,512}$`).
   - `SurveyServiceImpl.java` (dòng 178–194) cập nhật `response.setPublicBypass(true)` và `response.setRedirectClickedAt(Instant.now())` khi khách mở link đánh giá Google.
3. **Tuân thủ chính sách nền tảng (Anti-Review Gating):**
   - `m1_01_rating_screen.dart` (dòng 29, 111): Biến `int? _selectedStar;` khởi tạo `null`, đảm bảo không chọn sẵn số sao.
   - `m1_02_google_review_screen.dart` (dòng 23–44): Câu gợi ý chỉ được sao chép vào bộ nhớ tạm (`Clipboard.setData`) để khách chủ động dán, không tự điền vào URL Google Maps.
   - `RateResultDto.java`: Không chứa trường tặng voucher hay phần thưởng gắn với đánh giá 5 sao.

## 3. GHI NHẬN KỸ THUẬT (TECHNICAL OBSERVATION)
- **Mã theo dõi:** `OBS-222-01`
- **Nội dung:** Hiện tại chức năng quản lý bộ từ khóa gợi ý theo ngành (`E4.3 / SCRUM-212`) chưa được merge vào nhánh làm việc, nên câu gợi ý tại `m1_02_google_review_screen.dart` (dòng 23–24) đang sử dụng chuỗi mẫu cố định cho `Maison Coffee & Bistro`. Khi `SCRUM-212` hoàn tất, cần kiểm thử lại việc nạp động câu gợi ý từ API.

## 4. BẰNG CHỨNG CHẠY UNIT TEST THỰC TẾ (`./mvnw test -Dtest=SurveyControllerTest`)
```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.cxshield.backend.SurveyControllerTest
06:55:49.760 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.857 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.869 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.882 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.899 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.915 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
06:55:49.919 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách chọn lối đi đánh giá công khai Google Maps (Response ID: 285707c8-317e-48e6-9db9-da06e10a213d)
06:55:49.933 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.427 s -- in com.cxshield.backend.SurveyControllerTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------