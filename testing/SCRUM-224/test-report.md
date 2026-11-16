# BÁO CÁO KẾT QUẢ KIỂM THỬ TỰ ĐỘNG – SCRUM-224

- **Nhiệm vụ:** [E1.2] Kiểm thử tự động luồng 4–5 sao sang Google Maps
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Test Scripts:**
  - `e2e/survey_positive_e12.spec.js` (Playwright API E2E)
  - `frontend/test/m1_02_google_review_screen_test.dart` (Flutter Widget Test)

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 6
- **Số case PASS:** 6 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0

## 2. BẰNG CHỨNG THỰC THI THỰC TẾ (RAW CONSOLE LOG)

### 2.1. Playwright E2E (`npx playwright test e2e/survey_positive_e12.spec.js`)
```text
Running 4 tests using 1 worker

  ✓  1 …-5 sao sang Google Maps & ghi nhận lượt chuyển › TC-224-01: Đánh giá 5 sao điều hướng M1-02, không gắn voucher/quà tặng (203ms)
[TC-224-01] 5-star response: {"allowUrgentCall":false,"hotline":"02838221122","message":"Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps.","responseId":"cb165384-0e06-496c-b44c-befc3272d07e","sentimentGroup":"POSITIVE","sessionId":"c32a4dd1-7469-4c17-9737-828cc4972e42","starRating":5,"targetScreen":"M1-02"}
  ✓  2 …hử tự động luồng 4-5 sao sang Google Maps & ghi nhận lượt chuyển › TC-224-02: Đánh giá 4 sao điều hướng M1-02 (POSITIVE) (41ms)
[TC-224-02] 4-star response: {"allowUrgentCall":false,"hotline":"02838221122","message":"Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps.","responseId":"7232cb3f-ab03-4a2b-98b6-c34aee6eb841","sentimentGroup":"POSITIVE","sessionId":"7eba5ea2-23e8-4f15-9c5b-e15a4ed6ded3","starRating":4,"targetScreen":"M1-02"}
  ✓  3 …gle Maps & ghi nhận lượt chuyển › TC-224-03: Ghi nhận lượt chuyển Google Maps (redirect_clicked_at) và kiểm tra Place ID (55ms)
[TC-224-03] Public review redirect: {"responseId":"d11e0e01-c643-4249-92e5-879236c6deb4","redirectClickedAt":"2026-11-16T06:56:11.112012445Z","reviewPlatformId":"d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a44","platformName":"Google Maps","reviewDirectUrl":"[https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef](https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef)","placeName":"Maison Coffee & Bistro - Đồng Khởi","message":"Chuyển tiếp tới trang đánh giá công khai Google Maps của cơ sở","publicBypass":true}
  ✓  4 …ng 4-5 sao sang Google Maps & ghi nhận lượt chuyển › TC-224-04: Từ chối ghi nhận lượt chuyển Google khi thiếu responseId (34ms)

  4 passed (1.3s)