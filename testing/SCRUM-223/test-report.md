# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG – SCRUM-223

- **Nhiệm vụ:** [E1.2] Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Thiết bị & Môi trường:** Samsung Galaxy A07 (Android 16) + Flutter Test Runner
- **Test Script:** `frontend/test/m1_02_google_review_screen_test.dart`

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 4 (80%)
- **Số case FAIL:** 1 (20%)
- **Số Bug phát hiện:** 1 (Tái hiện lỗi điều hướng **`BUG-SCRUM-189-01`** đã ghi nhận tại `testing/SCRUM-189/bug-reports.md`, không phát sinh bug logic mới ở E1.2)

## 2. CHI TIẾT LỖI & GHI NHẬN KỸ THUẬT
1. **Lỗi tái hiện (`BUG-SCRUM-189-01` – Liên kết `TC-223-05`):**
   - **Mô tả:** Khi người dùng vào màn `M1-02` từ `M1-01` và nhấn nút `"← Trở lại khảo sát"` (`m1_02_google_review_screen.dart` dòng 217 gọi `Navigator.of(context).pop()`), ứng dụng bị đứng tại màn `M1-02` và không quay về `M1-01` do trước đó `M1-01` sử dụng `pushReplacement` làm ngăn xếp điều hướng chỉ còn 1 route (`canPop() == false`).
   - **Tham chiếu chi tiết:** Xem đầy đủ các bước tái hiện và đề xuất sửa lỗi tại `testing/SCRUM-189/bug-reports.md`.
2. **Quan sát kỹ thuật (`OBS-223-01` – Liên kết `TC-223-04`):**
   - Trên bản build hiện tại, phương thức `_openGoogleReview()` (`m1_02_google_review_screen.dart` dòng 38–69) đã thực hiện tự động copy câu gợi ý và bật hộp thoại hướng dẫn dán nhận xét, nhưng chưa tích hợp `url_launcher` để mở trình duyệt ngoài tới `reviewDirectUrl` và chưa gọi kèm endpoint `POST /api/v1/surveys/public-review` từ giao diện. Đề xuất Dev bổ sung kết nối ở sprint tiếp theo.

## 3. BẰNG CHỨNG THỰC THI WIDGET TEST (`flutter test test/m1_02_google_review_screen_test.dart`)
```text
h-22259841:~/h/CX-SHIELD/frontend{cuong}$ flutter test test/m1_02_google_review_screen_test.dart
00:05 +2: All tests passed!