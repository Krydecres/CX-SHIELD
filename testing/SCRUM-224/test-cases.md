# TEST CASES: SCRUM-224 – Kiểm thử tự động luồng 4–5 sao sang Google Maps

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-224 (Story cha: SCRUM-123 – E1.2)
- **Test Scripts:**
  - API E2E (Playwright): `e2e/survey_positive_e12.spec.js`
  - UI Widget Test (Flutter): `frontend/test/m1_02_google_review_screen_test.dart`

## Danh sách Kịch bản Kiểm thử Tự động

| Mã TC | Lớp kiểm thử | Tên kịch bản | Kết quả mong đợi | Trạng thái |
| :---: | :---: | :--- | :--- | :---: |
| **TC-224-01** | Playwright API | Đánh giá 5 sao điều hướng `M1-02`, không gắn voucher/quà tặng | HTTP 200, `sentimentGroup = POSITIVE`, `targetScreen = M1-02`, `allowUrgentCall = false`, không có `voucherCode` | **PASS** |
| **TC-224-02** | Playwright API | Đánh giá 4 sao điều hướng `M1-02` (`POSITIVE`) | HTTP 200, `starRating = 4`, `sentimentGroup = POSITIVE`, `targetScreen = M1-02` | **PASS** |
| **TC-224-03** | Playwright API | Ghi nhận lượt chuyển Google Maps (`redirectClickedAt`) & kiểm tra Place ID | HTTP 200, `publicBypass = true`, `redirectClickedAt != null`, `reviewDirectUrl` chứa `writereview?placeid=`, không điền sẵn `rating=` hay `review=` | **PASS** |
| **TC-224-04** | Playwright API | Từ chối ghi nhận lượt chuyển Google khi thiếu `responseId` | HTTP 400, `success = false`, `message = "Response ID không được để trống"` | **PASS** |
| **TC-224-05** | Flutter Widget | M1-02 hiển thị lời cảm ơn 5 sao, câu gợi ý & sao chép vào Clipboard | Hiển thị đúng tiêu đề, không có chữ `Voucher`, bấm `Sao chép` lưu đúng nội dung vào Clipboard và đổi nhãn thành `Đã chép` | **PASS** |
| **TC-224-06** | Flutter Widget | M1-02 bấm `Đăng Đánh Giá Lên Google Maps` tự copy & mở hộp thoại xác nhận | Tự động copy câu gợi ý và mở dialog `Mở Google Maps` với nút `Đã hiểu & Tiếp tục` | **PASS** |