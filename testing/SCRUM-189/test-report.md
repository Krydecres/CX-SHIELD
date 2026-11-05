# BÁO CÁO KẾT QUẢ THỰC THI KIỂM THỬ (TEST EXECUTION REPORT)

- **Mã nhiệm vụ Jira:** SCRUM-189
- **Tên User Story:** [E1.1] Kiểm thử chức năng và giao diện khảo sát QR
- **Phân hệ:** Review Funnel (Màn hình M1-01, M1-02, M1-04, M1-05, M1-06)
- **Thiết bị thử nghiệm:** Samsung Galaxy A07, Android 16 (Samsung One UI)
- **Môi trường Backend:** Spring Boot 4.0.0, Java 21, In-Memory Repository (`http://localhost:8080`)
- **Ngày thực thi:** 06/11/2026
- **Người thực hiện:** QA Engineer / Automation Test Engineer
- **Tài liệu tham chiếu:** `testing/SCRUM-189/test-cases.md`, `testing/SCRUM-189/bug-reports.md`, `testing/SCRUM-189/analysis-report.md`

---

## 1. Tóm tắt Kết quả Thực thi (Executive Summary)

### 1.1. Thống kê Kết quả Kiểm thử Toàn diện

Toàn bộ danh mục gồm **17 Test Cases** (15 Test Cases thuộc phạm vi bắt buộc của SCRUM-189 và 2 Test Cases thuộc các Epic liên quan ngoài phạm vi):

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Diễn giải chi tiết |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thuộc phạm vi SCRUM-189** | **15** | **100%** | Toàn bộ các ca kiểm thử thuộc 9 nhóm phạm vi của nhiệm vụ |
| **PASS (Đạt yêu cầu nghiệm thu)** | **11** | **73.33%** | TC01, TC02, TC04–TC12: QR, nhận diện chi nhánh, đánh giá 1–5 sao, validation, backend tiếp nhận |
| **FAIL (Không đạt chuẩn - Xác nhận lỗi)** | **2** | **13.33%** | **TC14 & TC15: Lỗi điều hướng Back trên Samsung A07 Android 16 (Quy về 01 Defect duy nhất: BUG-SCRUM-189-01)** |
| **NOT RUN (Thuộc phạm vi nhưng chưa đo kiểm)** | **2** | **13.33%** | **TC03** (Chưa đo định lượng tải < 1s trên thiết bị) & **TC13** (Chưa có bằng chứng ngắt mạng thực tế) |
| **BLOCKED (Bị nghẽn môi trường)** | **0** | **0%** | Môi trường test trên thiết bị thật và kết nối ADB hoạt động ổn định |
| **NOT RUN (Ngoài phạm vi SCRUM-189)** | **2** | - | **TC16** (Thuộc Epic E1.4) và **TC17** (Thuộc Epic E6/E9 - M2-01) |

> [!IMPORTANT]
> **Thống kê Kết quả Kiểm thử Tự động (Automation Suites):**
> 1. **Kịch bản kiểm thử riêng của SCRUM-189 (`frontend/test/scrum_189_survey_widget_test.dart`):**
>    - Lệnh thực thi: `flutter test test/scrum_189_survey_widget_test.dart`
>    - Kết quả: **3 tests passed, 0 failed** (100% PASS).
>    - Bao phủ: Cờ khẩn cấp khi đánh giá 1 sao (TC08), validation biên dưới < 3 ký tự (TC10), và kiểm chứng assertion điểm bất thường điều hướng Back `canPop() == false` (TC14).
> 2. **Chỉ số Baseline 91 tests passed:**
>    - Là baseline toàn dự án Flutter, **không cộng dồn** vào số test riêng của SCRUM-189.

---

## 2. Bằng chứng Kiểm thử Thực tế Theo Từng Phạm vi (Actual Evidence)

### 2.1. Phạm vi 1 & 2: Mở QR không cần đăng nhập & Nhận diện chi nhánh (TC01, TC02)
- **Kết quả:** **PASS**.
- **Bằng chứng:**
  - Khởi chạy app với param QR `MC-B04`, hệ thống mở thẳng `SurveyStandaloneApp`, bỏ qua login và Supabase.
  - Giao diện hiển thị chính xác tên cơ sở: `Maison Coffee & Bistro` và huy hiệu: `Chi nhánh Quận 1 - Đồng Khởi • Bàn 04`. Người kiểm thử đã xác nhận nhận diện chi nhánh hoạt động chính xác.

### 2.2. Phạm vi 8: Trải nghiệm tải màn hình siêu tốc (< 1s) (TC03)
- **Kết quả:** **NOT RUN**.
- **Lý do điều chỉnh:**
  - Về mặt lý thuyết mã nguồn, giao diện M1-01 được nạp mô hình fallback đồng bộ trong `initState()`.
  - Tuy nhiên, do **chưa thực hiện đo đạc định lượng chính thức bằng công cụ Profiler/DevTools trên thiết bị Samsung A07**, chỉ số này được chuyển sang trạng thái **NOT RUN** để đảm bảo tính khách quan và nghiêm ngặt của báo cáo.

### 2.3. Phạm vi 3 & 4: Đánh giá 1 đến 5 sao & Phân luồng điều hướng (TC04 – TC08)
- **Kết quả:** **PASS**.
- **Bằng chứng:**
  - **4 và 5 sao:** Phân luồng tích cực, hiển thị nhãn cảm xúc xanh (`😊 Hài lòng` / `🤩 Tuyệt vời`) và chuyển sang M1-02 (`M102GoogleReviewScreen`).
  - **2 và 3 sao:** Phân luồng chưa hài lòng, hiển thị nhãn cảm xúc đỏ và chuyển sang form M1-04 (`M104FeedbackScreen`) kèm banner xin lỗi của Ban Quản lý.
  - **1 sao:** Chuyển sang M1-04 và kích hoạt hiển thị thanh cảnh báo khẩn cấp màu vàng cam: *"Cần giải quyết nóng tại bàn? Bấm vào đây để gọi Quản lý"*. Đã xác minh qua widget test `TC08` trong `scrum_189_survey_widget_test.dart` (**PASS**).

### 2.4. Phạm vi 5: Validation nội dung góp ý trên Form M1-04 (TC09, TC10)
- **Kết quả:** **PASS**.
- **Bằng chứng:**
  - Để trống: Bị chặn gửi, hiển thị thông báo lỗi màu đỏ: *"Vui lòng nhập nội dung góp ý để cơ sở cải thiện"*. Người kiểm thử đã xác nhận yêu cầu nhập nội dung khi gửi trống.
  - Nhập < 3 ký tự (ví dụ: `"Ko"`): Form báo lỗi *"Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)"*. Đã xác minh qua widget test `TC10` (**PASS**).

### 2.5. Phạm vi 6: Gửi phản hồi và xác nhận Backend tiếp nhận (TC11, TC12)
- **Kết quả:** **PASS**.
- **Bằng chứng từ nhật ký máy chủ Backend Spring Boot:**
  1. **Bằng chứng phản hồi 1 sao (TC11):**
     - **Feedback ID:** `592d0d60-be33-41f9-9a8c-73b030e9db37`
     - **Response ID:** `ec56520b-c453-4888-8a8c-73b030e9db11`
     - **Thuộc tính ghi nhận:** `Star: 1, Urgent: true, HasPhone: false`
     - Backend lưu thành công bản ghi với HTTP 200 OK.
  2. **Bằng chứng phản hồi 3 sao (TC12):**
     - Đã được Backend tiếp nhận và ghi nhận thành công tại mốc thời gian: **`01:16:39`**.

### 2.6. Phạm vi 7: Xử lý ngoại tuyến khi Backend hoặc mạng không hoạt động (TC13)
- **Kết quả:** **NOT RUN**.
- **Lý do điều chỉnh:**
  - Mặc dù mã nguồn có khối `catch (_)` hỗ trợ fallback, nhưng **chưa có phiên kiểm thử thực nghiệm ngắt mạng thực tế có ghi nhận log và bằng chứng đầy đủ trên thiết bị**. Theo nguyên tắc kiểm thử, ca này được chuyển thành **NOT RUN**.

### 2.7. Phạm vi 9: Điều hướng Back trên Samsung A07, Android 16 (TC14, TC15)
- **Kết quả:** **FAIL – BUG-SCRUM-189-01 CONFIRMED**.
- **Bằng chứng lỗi thực tế (Hai cách tái hiện của 1 Bug duy nhất):**
  - **Cách 1 (Nút in-app M1-02 - TC14):** Nhấn nút `"← Trở lại khảo sát"` -> **Ứng dụng bị đứng hình, không phản hồi và không quay lại M1-01**.
    *(Lưu ý: Widget test TC14 PASS ở tầng kiểm chứng assertion vì xác nhận đúng `canPop() == false`, nhưng trải nghiệm nghiệp vụ thực tế trên điện thoại là FAIL).*
  - **Cách 2 (Nút/cử chỉ Back Android 16 - TC15):** Nhấn phím Back hoặc vuốt cử chỉ Back Android -> **Ứng dụng bị đứng, kẹt cử chỉ**.
  - Hiện tượng xảy ra tương tự bất kể Backend bật hay tắt.

---

## 3. Bảng Kết quả Chi tiết Toàn bộ 17 Test Cases

| Mã TC | Tên Test Case & Mục tiêu | Kết quả thực tế | Trạng thái | Bằng chứng / Phân loại chi tiết |
| :---: | :--- | :--- | :---: | :--- |
| **TC01** | Mở khảo sát QR không cần đăng nhập | Mở thẳng `SurveyStandaloneApp` | **PASS** | Bỏ qua login/Supabase |
| **TC02** | Nhận diện chi nhánh & Bàn 04 | Đúng cơ sở và Bàn 04 | **PASS** | Đã xác nhận hoạt động |
| **TC03** | Trải nghiệm tải màn hình < 1s | Chưa đo đạc định lượng Profiler | **NOT RUN** | Chờ đo kiểm thực tế trên thiết bị |
| **TC04** | Đánh giá 5 sao & Phân luồng M1-02 | Chuyển M1-02 cảm ơn 5 sao | **PASS** | Nhãn `🤩 Tuyệt vời` |
| **TC05** | Đánh giá 4 sao & Phân luồng M1-02 | Chuyển M1-02 cảm ơn 4 sao | **PASS** | Nhãn `😊 Hài lòng` |
| **TC06** | Đánh giá 3 sao & Phân luồng M1-04 | Chuyển M1-04 banner xin lỗi | **PASS** | Nhãn `😐 Bình thường` |
| **TC07** | Đánh giá 2 sao & Phân luồng M1-04 | Chuyển M1-04 form góp ý | **PASS** | Form sẵn sàng nhập |
| **TC08** | Đánh giá 1 sao & Cờ hotline khẩn cấp | Chuyển M1-04, hiện banner cam | **PASS** | Widget test PASS (TC08) |
| **TC09** | Validation nội dung góp ý khi gửi trống | Chặn gửi, báo lỗi đỏ | **PASS** | Đã xác nhận yêu cầu nhập |
| **TC10** | Validation nội dung ngắn (< 3 ký tự) | Báo lỗi tối thiểu 3 ký tự | **PASS** | Widget test PASS (TC10) |
| **TC11** | Backend tiếp nhận phản hồi 1 sao | Lưu thành công vào CSDL | **PASS** | Feedback ID: `592d0d60-...` |
| **TC12** | Backend tiếp nhận phản hồi 3 sao | Lưu thành công vào CSDL | **PASS** | Tiếp nhận lúc `01:16:39` |
| **TC13** | Xử lý khi Backend tắt hoặc mất mạng | Chưa có bằng chứng ngắt mạng | **NOT RUN** | Cần đo kiểm độc lập |
| **TC14** | Điều hướng Back bằng nút in-app M1-02 | **App đứng hình trên Samsung A07** | **FAIL** | **BUG-SCRUM-189-01 (Cách 1)**<br>*(Widget test PASS assertion)* |
| **TC15** | Điều hướng Back bằng phím Back Android 16 | **App đứng hình, kẹt cử chỉ** | **FAIL** | **BUG-SCRUM-189-01 (Cách 2)** |
| **TC16** | Lối đi Google Maps công khai (E1.4) | Chưa kiểm thử trong SCRUM-189 | **NOT RUN** | Ngoài phạm vi E1.1 |
| **TC17** | Màn nhận ưu đãi Voucher (M2-01) | Chưa kiểm thử trong SCRUM-189 | **NOT RUN** | Ngoài phạm vi E1.1 |

---

## 4. Điểm Bất thường trong Mã nguồn Cần Developer Xác minh (Navigation Anomaly)

Anti đã đối chiếu mã nguồn và phát hiện điểm bất thường gây xung đột điều hướng:
1. `m1_01_rating_screen.dart` (dòng 79, 88): Dùng `Navigator.of(context).pushReplacement(...)` loại bỏ hoàn toàn M1-01 khỏi ngăn xếp Navigator, khiến `Navigator.canPop(context)` trả về `false`.
2. `m1_02_google_review_screen.dart` (dòng 217): Nút in-app `"← Trở lại khảo sát"` lại gọi `Navigator.of(context).pop()`. Do stack bên dưới đã rỗng, lệnh gọi gây lỗi assertion ngầm hoặc rỗng Navigator, làm đứng giao diện.
3. Cờ `_isSubmitting`: Chưa có cơ chế reset về `false` khi quay lại màn hình chọn sao.

> **Khuyến cáo:** Đội kiểm thử đã ghi nhận toàn bộ chi tiết này vào `testing/SCRUM-189/bug-reports.md` để Developer xác minh và đưa ra bản vá chính thức.

---

## 5. Kết luận Nghiệm thu Jira Task SCRUM-189

- **Các chức năng cốt lõi (Core Flows):** Mở QR, nhận diện chi nhánh, đánh giá 1–5 sao, phân luồng cảm xúc, validation và ghi nhận backend đều hoạt động chính xác và đạt yêu cầu.
- **Lỗi tồn đọng cần giải quyết (1 Blocking Defect duy nhất):** Lỗi điều hướng Back (**BUG-SCRUM-189-01**, bao gồm cả nút Back in-app và nút Back Android) là lỗi nghiêm trọng ảnh hưởng trực tiếp đến trải nghiệm khách hàng tại bàn. Task Jira SCRUM-189 cần được bàn giao cho Developer kèm theo Bug Report để xử lý dứt điểm trước khi đóng User Story E1.1.
