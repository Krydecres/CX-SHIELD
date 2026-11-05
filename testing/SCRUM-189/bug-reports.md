# BÁO CÁO LỖI VÀ GHI NHẬN KỸ THUẬT (BUG REPORTS)

- **Mã Jira:** SCRUM-189
- **Tên User Story:** [E1.1] Kiểm thử chức năng và giao diện khảo sát QR
- **Phân hệ:** Review Funnel (Màn hình M1-01, M1-02, M1-04, M1-05, M1-06)
- **Thiết bị thử nghiệm:** Samsung Galaxy A07, Android 16 (Samsung One UI)
- **Ngày ghi nhận:** 06/11/2026
- **Trạng thái:** Mới (Open) – Chờ Developer thẩm tra và khắc phục

---

## 1. Danh sách Lỗi chính thức phát hiện trong SCRUM-189

> [!IMPORTANT]
> **Quy tắc thống kê lỗi:** Hiện tượng lỗi điều hướng Back khi nhấn nút Back trong ứng dụng và khi dùng phím/cử chỉ Back của Android là **hai cách tái hiện của cùng một lỗi kiến trúc điều hướng duy nhất**, do đó được quy về **01 Defect duy nhất: BUG-SCRUM-189-01**.

| Mã Bug | Tóm tắt lỗi | Hai cách tái hiện (Trường hợp A & B) | Mức độ nghiêm trọng | Trạng thái |
| :--- | :--- | :--- | :---: | :---: |
| **BUG-SCRUM-189-01** | Ứng dụng bị đứng / không phản hồi khi điều hướng Back sau khi gửi đánh giá trên Samsung A07 (Android 16) | **Cách 1:** Nhấn nút in-app `"← Trở lại khảo sát"` trên M1-02 (TC14).<br>**Cách 2:** Nhấn phím Back hoặc vuốt cử chỉ Back Android 16 trên M1-02/M1-04 (TC15). | **Major (Nghiêm trọng)** | **CONFIRMED & REPRODUCED** |

---

## 2. Chi tiết Báo cáo Lỗi BUG-SCRUM-189-01

### 2.1. Thông tin chung
- **Mã lỗi theo dõi:** `BUG-SCRUM-189-01`
- **Tiêu đề lỗi:** `[Frontend-Mobile] Ứng dụng bị đứng / đóng băng khi nhấn nút Back in-app ('← Trở lại khảo sát') hoặc phím Back Android sau khi chuyển màn hình đánh giá trên thiết bị Samsung A07 (Android 16)`
- **Mức độ ưu tiên (Priority):** High
- **Mức độ nghiêm trọng (Severity):** Major (Làm gián đoạn hành trình người dùng, chặn khách hàng quay lại sửa đánh giá)
- **Môi trường ghi nhận (Environment):**
  - Thiết bị: Samsung Galaxy A07 (SM-A07x)
  - Hệ điều hành: Android 16 (Samsung One UI)
  - Nền tảng: Flutter 3.x (Engine Dart 3.x)
  - Môi trường Backend: Tái hiện cả khi Backend Spring Boot đang chạy (`http://localhost:8080`) và khi Backend tắt (Offline mode).

---

### 2.2. Hai cách tái hiện lỗi (Steps to Reproduce)

#### Cách 1: Tái hiện qua nút Back in-app trên M1-02 (Liên kết TC14)
1. Mở ứng dụng khảo sát với mã QR mặc định `MC-B04` trên điện thoại Samsung A07.
2. Tại màn hình chọn sao M1-01, chạm vào 5 sao (hoặc 4 sao).
3. Ứng dụng hiển thị spinner loading và điều hướng sang màn hình cảm ơn M1-02 (`M102GoogleReviewScreen`).
4. Cuộn xuống cuối màn hình M1-02 và chạm vào nút `"← Trở lại khảo sát"`.
5. **Hiện tượng:** Màn hình không phản hồi, ứng dụng bị đứng hình, không đóng màn M1-02 và không quay về M1-01.

#### Cách 2: Tái hiện qua phím / cử chỉ Back hệ điều hành Android 16 (Liên kết TC15)
1. Thực hiện các bước 1–3 như trên để vào màn hình M1-02 (hoặc chọn 1–3 sao để vào M1-04).
2. Vuốt cử chỉ Back từ cạnh màn hình hoặc nhấn phím Back phần mềm trên thanh điều hướng Android 16.
3. **Hiện tượng:** Cử chỉ Back bị khựng lại, hệ điều hành không lùi về màn M1-01, màn hình giữ nguyên ở trạng thái đơ cứng.

---

### 2.3. Kết quả mong đợi (Expected Result)
- Ứng dụng đóng màn hình M1-02 / M1-04 và quay trở lại màn hình đánh giá M1-01 ban đầu một cách mượt mà. Màn hình M1-01 hiển thị ở trạng thái sẵn sàng để người dùng có thể thay đổi số sao hoặc đánh giá lại, không bị treo giao diện hay kẹt loading.

---

### 2.4. Kết quả thực tế (Actual Result)
- **Ứng dụng bị đứng hình, không phản hồi và không quay lại màn hình M1-01:**
  - Nhấn vào nút `"← Trở lại khảo sát"`: Giao diện trơ ra, không có hiệu ứng chuyển màn, không đóng màn M1-02.
  - Vuốt cử chỉ Back / bấm nút Back Android: Cử chỉ bị nuốt, hệ thống không lùi về màn M1-01.
  - Ứng dụng không nhất thiết bị văng (crash) ra màn hình chính của điện thoại ngay lập tức mà bị đóng băng ở màn hình hiện tại.

---

### 2.5. Bằng chứng thực nghiệm (Actual Evidence)
1. **Kiểm thử thực tế trên thiết bị Samsung A07:** Người kiểm thử và trợ lý AI đã xác nhận hiện tượng lỗi tái hiện trên cả hai cách thao tác với thiết bị thật chạy Android 16.
2. **Kiểm thử tự động Widget Test (`frontend/test/scrum_189_survey_widget_test.dart`):**
   - Đã chạy: `flutter test test/scrum_189_survey_widget_test.dart` -> **3 passed, 0 failed**.
   - Trong đó test case `TC14` đã **PASS** ở góc độ tự động hóa vì nó kiểm tra và xác nhận assertion `Navigator.of(m102Context).canPop() == false`, chứng minh bằng chứng kỹ thuật rằng sau `pushReplacement`, M1-02 là Route gốc duy nhất và không thể pop.
3. **Đối chiếu mã nguồn (Code Inspection):**
   - Tại `frontend/lib/screens/m1_01_rating_screen.dart` (dòng 79, 88): Dùng `pushReplacement()` thay vì `push()`.
   - Tại `frontend/lib/screens/m1_02_google_review_screen.dart` (dòng 217): Nút in-app gọi `Navigator.of(context).pop()` khi `canPop() == false`.

---

### 2.6. Điểm bất thường trong mã nguồn cần Developer xác minh (Code Anomaly Analysis)
> [!NOTE]
> Báo cáo ghi nhận điểm bất thường này từ sự đối chiếu logic giữa các dòng code để làm căn cứ kỹ thuật hỗ trợ đội phát triển, không khẳng định tuyệt đối là nguyên nhân duy nhất cho đến khi Developer thẩm tra hoàn tất.

1. **Sự bất đối xứng trong điều hướng (Navigation Mismatch):**
   - M1-01 chuyển sang M1-02 bằng `pushReplacement` (xóa màn trước).
   - Nhưng M1-02 lại bố trí nút quay lại và gọi `Navigator.pop()` (kỳ vọng màn trước vẫn còn).
   - Khi `pop()` được gọi trên một Navigator chỉ có 1 màn hình duy nhất (`canPop == false`), Flutter ném ngoại lệ ngầm `Failed assertion: 'canPop()': is not true` ở chế độ debug hoặc pop rỗng Navigator, dẫn tới hiện tượng đứng app.
2. **Tương thích với Android 16 Predictive Back:**
   - Khi Android 16 gửi sự kiện Back, Flutter kiểm tra `canPop()`. Vì `pushReplacement` làm `canPop()` bằng `false` và không có `PopScope` bọc ngoài, hệ điều hành từ chối xử lý pop và kẹt cử chỉ.
3. **Hiện tượng treo cờ `_isSubmitting`:**
   - Tại `M101RatingScreen` (dòng 63), `_isSubmitting = true` được bật lên khi bấm sao và không có logic reset về `false`. Nếu khắc phục điều hướng quay lại mà không reset biến này, M1-01 vẫn sẽ bị treo vòng xoay loading vĩnh viễn.

---

### 2.7. Đề xuất giải pháp kỹ thuật (Dành cho Developer)
1. Trong `frontend/lib/screens/m1_01_rating_screen.dart` (dòng 78–96):
   - Đổi `Navigator.of(context).pushReplacement(...)` thành `await Navigator.of(context).push(...)`.
   - Bổ sung `if (mounted) setState(() { _isSubmitting = false; });` ngay sau lệnh await để giải phóng trạng thái loading khi người dùng quay lại M1-01.
2. Trên `M102GoogleReviewScreen` và `M104FeedbackScreen`:
   - Bọc Scaffold bằng `PopScope(canPop: true, ...)` để tương thích tối đa với cử chỉ Predictive Back của Android 14–16.

---

## 3. Ghi nhận Kỹ thuật Bổ sung (Technical Observation)

- **Mã theo dõi:** `OBS-SCRUM-189-01`
- **Tiêu đề:** `Cơ chế Silent Fallback tự sinh dữ liệu cục bộ khi mất mạng mà không thông báo lỗi cho người dùng`
- **Phân loại:** Quan sát rủi ro kỹ thuật (Technical Risk)
- **Mô tả:** Lớp `SurveyApiService` bọc toàn bộ gọi mạng bằng `catch (_)`. Khi backend mất kết nối, hệ thống tự động sinh `responseId` giả lập dạng `local-timestamp` và vẫn cho phép điều hướng bình thường trên điện thoại.
- **Rủi ro kiểm thử:** Người dùng và tester có thể nhầm lẫn rằng đánh giá đã được gửi lên server thành công trong khi dữ liệu chỉ lưu tạm trên RAM thiết bị.
- **Khuyến nghị:** Cần bổ sung SnackBar hoặc Banner cảnh báo chế độ ngoại tuyến (Offline Mode) để người dùng nắm rõ tình trạng kết nối.
