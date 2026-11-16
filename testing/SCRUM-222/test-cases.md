# TEST CASES: SCRUM-222 – Kiểm thử mã nguồn phân luồng 4–5 sao và ghi nhận lượt chuyển Google

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-222 (Story cha: SCRUM-123 – E1.2)
- **Đối tượng kiểm thử:**
  - Backend: `SurveyController.java`, `SurveyServiceImpl.java`, `PlaceIdParser.java`, `SurveyControllerTest.java`
  - Frontend (rà soát tuân thủ quy tắc nghiệp vụ): `m1_01_rating_screen.dart`, `m1_02_google_review_screen.dart`

## Danh sách Kịch bản Kiểm thử Mã nguồn (White-box & Unit Test)

| Mã TC | Tên kịch bản | Cách thức kiểm tra & Điểm rà soát | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-222-01** | Nhánh phân luồng 4–5 sao sang `M1-02` | Rà soát `SurveyServiceImpl.java` (L117, L152–155) và chạy `SurveyControllerTest#testSubmitRatingPositive`, `testSubmitRatingFourStars` | `stars >= 4` gán `sentimentGroup = "POSITIVE"`, `targetScreen = "M1-02"`, `allowUrgentCall = false` | **PASS** |
| **TC-222-02** | Tạo link viết đánh giá Google từ Place ID | Rà soát `PlaceIdParser.reviewUrl()` (L46–48) và `SurveyServiceImpl.recordPublicBypass()` (L197–211) | Tạo đúng URL chuẩn `https://search.google.com/local/writereview?placeid=<PLACE_ID>`, không kèm tham số điền sẵn sao hay chữ | **PASS** |
| **TC-222-03** | Ghi nhận dấu thời gian `redirect_clicked_at` | Rà soát `SurveyServiceImpl.java` (L178–194) và chạy `SurveyControllerTest#testRecordPublicBypass` | Khi gọi `POST /api/v1/surveys/public-review`, hệ thống gán `isPublicBypass = true`, `redirectClickedAt = Instant.now()`, gắn `reviewPlatformId` và lưu vào `SurveyResponseRepository` | **PASS** |
| **TC-222-04** | Xử lý lỗi & fallback khi thiếu Place ID / thiếu `responseId` | Rà soát `SurveyServiceImpl.java` (L169–171, L197–211) và `PlaceIdParser.normalize()` (L28–31) | Thiếu `responseId` ném `IllegalArgumentException`; thiếu Place ID theo chi nhánh tự fallback sang Place ID mặc định để không đứt luồng khách | **PASS** |
| **TC-222-05** | Tuân thủ chống Review Gating (không chọn sẵn sao, không điền sẵn chữ, không gắn voucher 5 sao) | Rà soát `RateResultDto.java`, `m1_01_rating_screen.dart` (L29, L111) và `m1_02_google_review_screen.dart` (L23–44) | `_selectedStar` khởi tạo `null` (không chọn sẵn sao); câu gợi ý chỉ copy vào Clipboard để khách tự dán; `RateResultDto` không có trường voucher/quà tặng | **PASS** |
| **TC-222-06** | Rà soát cơ chế lấy câu gợi ý từ bộ từ khóa & kiểm tra biên rating | Rà soát `m1_02_google_review_screen.dart` (L23–24) và chạy `SurveyControllerTest#testInvalidRating` | Chặn rating ngoài khoảng `1..5` (0 sao và 6 sao ném `IllegalArgumentException`); ghi nhận quan sát kỹ thuật `OBS-222-01` về câu gợi ý đang đặt tĩnh | **PASS** |