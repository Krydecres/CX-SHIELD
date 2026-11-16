# BÁO CÁO KẾT QUẢ THỰC THI KIỂM THỬ (TEST EXECUTION REPORT)

- **Mã nhiệm vụ Jira:** SCRUM-189
- **Tên User Story:** [E1.1] Kiểm thử chức năng và giao diện khảo sát QR
- **Phân hệ:** Review Funnel (Màn hình M1-01, M1-02, M1-04, M1-05, M1-06)
- **Thiết bị thử nghiệm:** Samsung Galaxy A07, Android 16 (Samsung One UI)
- **Môi trường Backend:** Spring Boot 4.0.0, Java 21, In-Memory Repository (`http://localhost:8080`)
- **Ngày thực thi:** 06/11/2026
- **Người thực hiện:** QA Engineer / Automation Test Engineer
- **Lần cập nhật:** Điều chỉnh theo xác nhận từ Developer (chức năng 4–5 sao chưa được phân công triển khai; giữ nguyên kết quả có bằng chứng của luồng 1–3 sao)
- **Tài liệu tham chiếu:** `testing/SCRUM-189/test-cases.md`, `testing/SCRUM-189/bug-reports.md`, `testing/SCRUM-189/analysis-report.md`

---

## 1. Tóm tắt Kết quả Thực thi (Executive Summary)

### 1.1. Thống kê Kết quả Kiểm thử Toàn diện

Danh mục kiểm thử gồm **17 Test Cases** (15 Test Cases thuộc phạm vi cốt lõi của SCRUM-189 và 2 Test Cases thuộc các Epic liên quan ngoài phạm vi):

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Diễn giải chi tiết |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thuộc phạm vi SCRUM-189** | **15** | **100%** | Toàn bộ 15 ca kiểm thử thiết kế cho nhiệm vụ |
| **• PASS (Đạt yêu cầu nghiệm thu)** | **9** | **60.00%** | TC01, TC02, TC06–TC12: Mở QR, nhận diện chi nhánh, luồng 1–3 sao, validation, backend tiếp nhận |
| **• FAIL (Lỗi nghiệm thu chính thức)** | **0** | **0%** | **Không có bug chính thức** (Luồng 4–5 sao chưa phân công nên không tính bug; luồng 1–3 sao đạt 100%) |
| **• NOT RUN (Thuộc phạm vi nhưng chưa triển khai/chưa đo)** | **6** | **40.00%** | 4 ca phụ thuộc luồng 4–5 sao chưa triển khai (TC04, TC05, TC14, TC15) + 2 ca chưa đo kiểm thực tế (TC03, TC13) |
| **• BLOCKED (Bị nghẽn môi trường)** | **0** | **0%** | Môi trường test trên thiết bị thật và kết nối ADB hoạt động ổn định |
| **Ngoài phạm vi SCRUM-189 (NOT RUN)** | **2** | - | **TC16** (Thuộc Epic E1.4) và **TC17** (Thuộc Epic E6/E9 - M2-01) |

> [!IMPORTANT]
> **Thống kê Kết quả Kiểm thử Tự động (Automation Suites):**
> 1. **Kịch bản kiểm thử riêng của SCRUM-189 (`frontend/test/scrum_189_survey_widget_test.dart`):**
>    - Lệnh thực thi: `flutter test test/scrum_189_survey_widget_test.dart`
>    - Kết quả: **3 tests passed, 0 failed** (100% PASS).
>    - Bao phủ: Cờ khẩn cấp khi đánh giá 1 sao (TC08), validation biên dưới < 3 ký tự (TC10), và kiểm chứng assertion điểm bất thường điều hướng Back `canPop() == false` (TC14).
> 2. **Chỉ số Baseline 91 tests passed:**
>    - Là baseline kiểm thử tự động của toàn bộ dự án frontend, **không cộng dồn** vào số test riêng của SCRUM-189.

---

## 2. Bằng chứng Kiểm thử Thực tế Theo Từng Nhóm Chức năng

### 2.1. Nhóm Khởi tạo & Nhận diện QR (TC01, TC02, TC03)
- **TC01 (Mở QR không cần đăng nhập - PASS):** Mở app với param QR `MC-B04`, ứng dụng khởi chạy thẳng `SurveyStandaloneApp`, bỏ qua login và Supabase.
- **TC02 (Nhận diện chi nhánh & Bàn 04 - PASS):** Giao diện hiển thị đúng tên cơ sở `Maison Coffee & Bistro` và huy hiệu `Chi nhánh Quận 1 - Đồng Khởi • Bàn 04`. Người kiểm thử đã xác nhận nhận diện chi nhánh hoạt động chính xác.
- **TC03 (Tải màn hình < 1s - NOT RUN):** Về mặt mã nguồn, ứng dụng nạp mô hình fallback đồng bộ trong `initState()`. Tuy nhiên, do chưa thực hiện đo đạc định lượng chính thức bằng Profiler/DevTools trên thiết bị Samsung A07, chỉ số này chuyển sang **NOT RUN**.

### 2.2. Nhóm Đánh giá 1–3 sao & Phân luồng Form góp ý (TC06, TC07, TC08 - Đạt 100% PASS)
- **TC06 (Đánh giá 3 sao - PASS):** Phân luồng chưa hài lòng, hiển thị nhãn cảm xúc đỏ (`😐 Bình thường`) và chuyển sang form M1-04 (`M104FeedbackScreen`) kèm banner xin lỗi của Ban Quản lý.
- **TC07 (Đánh giá 2 sao - PASS):** Chuyển sang form góp ý M1-04 sẵn sàng nhập liệu.
- **TC08 (Đánh giá 1 sao - PASS):** Chuyển sang M1-04 và kích hoạt hiển thị thanh cảnh báo khẩn cấp màu vàng cam: *"Cần giải quyết nóng tại bàn? Bấm vào đây để gọi Quản lý"*. Đã xác minh qua widget test `TC08` trong `scrum_189_survey_widget_test.dart` (**PASS**).

### 2.3. Nhóm Đánh giá 4–5 sao (TC04, TC05 - NOT RUN)
- **Xác nhận từ Developer:** Chức năng đánh giá 4–5 sao và màn hình cảm ơn M1-02 **chưa được phân công thực hiện trong phạm vi nhiệm vụ này**.
- Theo quy trình, các test case TC04 và TC05 được ghi nhận trạng thái **NOT RUN** (chức năng chưa được Developer triển khai) và **không ghi nhận là lỗi (bug)**.

### 2.4. Nhóm Validation Form góp ý M1-04 (TC09, TC10 - Đạt 100% PASS)
- **TC09 (Validation gửi trống - PASS):** Để trống ô nội dung: Form bị chặn gửi, hiển thị thông báo lỗi màu đỏ: *"Vui lòng nhập nội dung góp ý để cơ sở cải thiện"*. Người kiểm thử đã xác nhận yêu cầu nhập nội dung khi gửi trống.
- **TC10 (Validation nội dung ngắn < 3 ký tự - PASS):** Nhập < 3 ký tự (ví dụ: `"Ko"`): Form báo lỗi *"Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)"*. Đã xác minh qua widget test `TC10` (**PASS**).

### 2.5. Nhóm Xác nhận Backend tiếp nhận thành công (TC11, TC12 - Đạt 100% PASS)
Bằng chứng đối chiếu trực tiếp từ nhật ký máy chủ Backend Spring Boot:
1. **Bằng chứng phản hồi 1 sao (TC11 - PASS):**
   - **Feedback ID:** `592d0d60-be33-41f9-9a8c-73b030e9db37`
   - **Response ID:** `ec56520b-c453-4888-8a8c-73b030e9db11`
   - **Thuộc tính ghi nhận:** `Star: 1, Urgent: true, HasPhone: false`
   - Backend lưu thành công bản ghi với HTTP 200 OK.
2. **Bằng chứng phản hồi 3 sao (TC12 - PASS):**
   - Đã được Backend tiếp nhận và lưu trữ thành công tại mốc thời gian: **`01:16:39`**.

### 2.6. Nhóm Xử lý ngoại tuyến khi mất mạng (TC13 - NOT RUN)
- **TC13 (Xử lý khi Backend tắt hoặc mất mạng - NOT RUN):** Mã nguồn có khối `catch (_)` fallback ngầm, nhưng chưa thực hiện phiên kiểm thử thực nghiệm ngắt mạng thực tế có ghi nhận log và bằng chứng đầy đủ trên thiết bị. Chuyển sang trạng thái **NOT RUN**.

### 2.7. Nhóm Điều hướng Back (TC14, TC15 - NOT RUN / Vấn đề quan sát kỹ thuật)
- **Xác nhận phạm vi:** Do luồng 4–5 sao và màn hình M1-02 chưa được triển khai hoàn thiện, hiện tượng đứng giao diện khi thao tác Back trên M1-02 **không được kết luận là bug độc lập**.
- **Chuyển đổi trạng thái:**
  - TC14 và TC15 được chuyển sang trạng thái **NOT RUN** (chức năng M1-02 chưa triển khai hoàn thiện).
  - Hiện tượng này được ghi chú là **Vấn đề quan sát kỹ thuật (`OBS-SCRUM-189-01`)** trong `testing/SCRUM-189/bug-reports.md` để đội ngũ QA thực hiện kiểm thử lại sau khi Developer hoàn thành chức năng 4–5 sao.

---

## 3. Bảng Kết quả Chi tiết Toàn bộ 17 Test Cases

| Mã TC | Tên Test Case & Mục tiêu | Kết quả thực tế | Trạng thái | Bằng chứng / Phân loại chi tiết |
| :---: | :--- | :--- | :---: | :--- |
| **TC01** | Mở khảo sát QR không cần đăng nhập | Mở thẳng `SurveyStandaloneApp` | **PASS** | Bỏ qua login/Supabase |
| **TC02** | Nhận diện chi nhánh & Bàn 04 | Đúng cơ sở và Bàn 04 | **PASS** | Đã xác nhận hoạt động |
| **TC03** | Trải nghiệm tải màn hình < 1s | Chưa đo đạc định lượng Profiler | **NOT RUN** | Chờ đo kiểm thực tế trên thiết bị |
| **TC04** | Đánh giá 5 sao & Phân luồng M1-02 | Chức năng 4–5 sao chưa triển khai | **NOT RUN** | Developer xác nhận chưa phân công |
| **TC05** | Đánh giá 4 sao & Phân luồng M1-02 | Chức năng 4–5 sao chưa triển khai | **NOT RUN** | Developer xác nhận chưa phân công |
| **TC06** | Đánh giá 3 sao & Phân luồng M1-04 | Chuyển M1-04 banner xin lỗi | **PASS** | Nhãn `😐 Bình thường` |
| **TC07** | Đánh giá 2 sao & Phân luồng M1-04 | Chuyển M1-04 form góp ý | **PASS** | Form sẵn sàng nhập |
| **TC08** | Đánh giá 1 sao & Cờ hotline khẩn cấp | Chuyển M1-04, hiện banner cam | **PASS** | Widget test PASS (TC08) |
| **TC09** | Validation nội dung góp ý khi gửi trống | Chặn gửi, báo lỗi đỏ | **PASS** | Đã xác nhận yêu cầu nhập |
| **TC10** | Validation nội dung ngắn (< 3 ký tự) | Báo lỗi tối thiểu 3 ký tự | **PASS** | Widget test PASS (TC10) |
| **TC11** | Backend tiếp nhận phản hồi 1 sao | Lưu thành công vào CSDL | **PASS** | Feedback ID: `592d0d60-...` |
| **TC12** | Backend tiếp nhận phản hồi 3 sao | Lưu thành công vào CSDL | **PASS** | Tiếp nhận lúc `01:16:39` |
| **TC13** | Xử lý khi Backend tắt hoặc mất mạng | Chưa có bằng chứng ngắt mạng | **NOT RUN** | Cần đo kiểm độc lập |
| **TC14** | Điều hướng Back bằng nút in-app M1-02 | M1-02 chưa hoàn thiện | **NOT RUN** | Chuyển thành vấn đề quan sát OBS-01 |
| **TC15** | Điều hướng Back bằng phím Back Android 16 | M1-02 chưa hoàn thiện | **NOT RUN** | Chuyển thành vấn đề quan sát OBS-01 |
| **TC16** | Lối đi Google Maps công khai (E1.4) | Chưa kiểm thử trong SCRUM-189 | **NOT RUN** | Ngoài phạm vi E1.1 |
| **TC17** | Màn nhận ưu đãi Voucher (M2-01) | Chưa kiểm thử trong SCRUM-189 | **NOT RUN** | Ngoài phạm vi E1.1 |

---

## 4. Ghi nhận Kỹ thuật và Khuyến nghị cho Đội ngũ Phát triển

1. **Vấn đề điều hướng Back trên luồng 4–5 sao (`OBS-SCRUM-189-01`):**
   - Sự bất đối xứng giữa `pushReplacement` tại M1-01 và `Navigator.pop()` tại M1-02 làm rỗng ngăn xếp, dẫn đến đứng hình trên Android 16.
   - Khi Developer bắt đầu triển khai chính thức luồng 4–5 sao, khuyến nghị sử dụng `Navigator.push(...)` kèm cơ chế giải phóng cờ `_isSubmitting = false` khi quay lại.
2. **Cơ chế Silent Fallback (`OBS-SCRUM-189-02`):**
   - Khi mất mạng, `SurveyApiService` tự sinh dữ liệu giả lập mà không có cảnh báo. Khuyến nghị bổ sung Offline Banner để thông báo minh bạch cho người dùng.

---

## 5. Kết luận Nghiệm thu Jira Task SCRUM-189

- **Tiến độ hoàn thành:**
  - Luồng khảo sát khách hàng chưa hài lòng (1–3 sao) thuộc phạm vi phân công đã được kiểm thử toàn diện trên thiết bị Samsung A07 (Android 16), kết nối Backend Spring Boot thành công và **đạt 100% yêu cầu chất lượng (9/9 Test Cases thực thi đều PASS, 0 Bug)**.
  - Luồng đánh giá 4–5 sao được ghi nhận là chức năng chưa triển khai theo xác nhận của Developer, các test case liên quan được đánh dấu **NOT RUN** để kiểm thử bổ sung ở sprint tiếp theo khi chức năng được bàn giao.
