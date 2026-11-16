# DANH SÁCH TEST CASES CHI TIẾT – KIỂM THỬ CHỨC NĂNG VÀ GIAO DIỆN KHẢO SÁT QR

- **Mã Jira:** SCRUM-189
- **Tên User Story:** [E1.1] Kiểm thử chức năng và giao diện khảo sát QR
- **Phân hệ:** Review Funnel (Màn hình M1-01, M1-02, M1-04, M1-05, M1-06)
- **Thiết bị thử nghiệm:** Samsung Galaxy A07, Android 16
- **Công cụ áp dụng:** Flutter Widget Testing (`flutter_test`) & Kiểm thử thực tế trên thiết bị di động thật
- **Lần cập nhật:** Điều chỉnh theo xác nhận từ Developer (chức năng đánh giá 4–5 sao chưa được phân công triển khai; luồng 1–3 sao giữ nguyên kết quả có bằng chứng thực tế)

---

## 1. Bảng tổng hợp hiện trạng kiểm thử (Coverage Overview)

Bảng phân loại dưới đây áp dụng nguyên tắc **phân loại độc lập, số liệu minh bạch, phản ánh đúng tiến độ triển khai thực tế của đội ngũ phát triển**:

| Nhóm kiểm thử | Mã Test Case | Tổng số | PASS | FAIL | BLOCKED | NOT RUN | Ghi chú thực tế theo tiến độ phát triển |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Khởi tạo & Nhận diện QR** | TC01, TC02, TC03 | 3 | 2 | 0 | 0 | 1 | TC01, TC02 PASS. TC03 NOT RUN (chưa đo định lượng <1s) |
| **Đánh giá 1–3 sao (Luồng tiêu cực)** | TC06, TC07, TC08 | 3 | 3 | 0 | 0 | 0 | Đã kiểm thử hoàn tất; TC08 có widget test xác minh khối khẩn cấp |
| **Đánh giá 4–5 sao (Luồng tích cực)** | TC04, TC05 | 2 | 0 | 0 | 0 | 2 | **NOT RUN** (Developer xác nhận chức năng chưa được phân công triển khai) |
| **Validation Form góp ý M1-04** | TC09, TC10 | 2 | 2 | 0 | 0 | 0 | Bỏ trống; nội dung < 3 ký tự (TC10 có widget test) |
| **Xác nhận Backend tiếp nhận** | TC11, TC12 | 2 | 2 | 0 | 0 | 0 | Phản hồi 1 sao (ID: `592d0d60-...`) và 3 sao (lúc `01:16:39`) đã lưu CSDL |
| **Xử lý ngoại tuyến / Mất mạng** | TC13 | 1 | 0 | 0 | 0 | 1 | **NOT RUN** (Chưa có bằng chứng ngắt mạng thực nghiệm) |
| **Điều hướng Back (Luồng 4–5 sao)** | TC14, TC15 | 2 | 0 | 0 | 0 | 2 | **NOT RUN** (Phụ thuộc màn M1-02 chưa triển khai; ghi nhận vấn đề quan sát để re-test) |
| **Ngoài phạm vi SCRUM-189** | TC16, TC17 | 2 | 0 | 0 | 0 | 2 | Thuộc Epic E1.4 (Bypass Maps) và Epic E6/E9 (M2-01) |
| **TỔNG CỘNG (Toàn bộ danh mục)** | **TC01 – TC17** | **17** | **9** | **0** | **0** | **8** | **15 in-scope (9 PASS, 0 FAIL, 6 NOT RUN) + 2 out-of-scope (NOT RUN)** |

> [!NOTE]
> **Thống kê Kết quả Kiểm thử Tự động:**
> - Kịch bản kiểm thử riêng của SCRUM-189 (`frontend/test/scrum_189_survey_widget_test.dart`): **3 tests passed, 0 failed**.
> - Chỉ số 91 tests passed trước đó là baseline của toàn bộ dự án frontend, không gộp vào số test riêng của SCRUM-189.

---

## 2. Chi tiết từng Test Case (TC01 – TC17)

### TC01: Mở khảo sát qua liên kết QR không yêu cầu đăng nhập
- **Mã Test Case:** TC01
- **Phạm vi kiểm thử:** Phạm vi 1 – Mở khảo sát QR không cần đăng nhập
- **Mục tiêu:** Xác minh người dùng mở app qua đường dẫn QR có thể truy cập thẳng vào màn hình khảo sát M1-01 mà không bị chặn bởi màn hình đăng nhập hoặc cấu hình Supabase.
- **Điều kiện trước:** Ứng dụng đã được cài đặt trên thiết bị Samsung A07 hoặc chạy qua Flutter tools.
- **Dữ liệu đầu vào:** URL / tham số: `?qr=MC-B04`.
- **Các bước thực hiện:**
  1. Khởi chạy ứng dụng với tham số QR `MC-B04`.
  2. Quan sát màn hình đầu tiên hiển thị.
- **Kết quả mong đợi:** Ứng dụng khởi động thẳng vào màn hình M1-01 (`M101RatingScreen`), hiển thị giao diện khảo sát ngay lập tức, không xuất hiện màn hình đăng nhập Auth hay Onboarding.
- **Kết quả thực tế:** Ứng dụng mở thẳng màn hình M1-01 thông qua `SurveyStandaloneApp`, hoàn toàn không yêu cầu đăng nhập.
- **Trạng thái:** **PASS**

---

### TC02: Nhận diện cơ sở, chi nhánh và vị trí bàn
- **Mã Test Case:** TC02
- **Phạm vi kiểm thử:** Phạm vi 2 – Nhận diện chi nhánh
- **Mục tiêu:** Xác minh hệ thống đọc đúng mã QR và hiển thị chính xác tên quán, chi nhánh và số bàn tương ứng.
- **Điều kiện trước:** Backend Spring Boot đang hoạt động, đã ánh xạ mã `MC-B04`.
- **Dữ liệu đầu vào:** Mã QR `MC-B04`.
- **Các bước thực hiện:**
  1. Mở màn hình M1-01 với mã `MC-B04`.
  2. Kiểm tra thông tin hiển thị tại thanh tiêu đề và huy hiệu địa điểm (Branch Badge).
- **Kết quả mong đợi:**
  - Tên cơ sở: `Maison Coffee & Bistro`.
  - Huy hiệu địa điểm: `Chi nhánh Quận 1 - Đồng Khởi • Bàn 04`.
- **Kết quả thực tế:** Giao diện hiển thị đúng tên cơ sở `Maison Coffee & Bistro` và huy hiệu `Chi nhánh Quận 1 - Đồng Khởi • Bàn 04`. Người kiểm thử đã xác nhận nhận diện chi nhánh hoạt động chính xác.
- **Trạng thái:** **PASS**

---

### TC03: Trải nghiệm tải màn hình siêu tốc (< 1s)
- **Mã Test Case:** TC03
- **Phạm vi kiểm thử:** Phạm vi 8 – Trải nghiệm tải màn hình
- **Mục tiêu:** Xác minh thời gian tải và hiển thị hoàn chỉnh màn hình M1-01 trên thiết bị Android đạt dưới 1 giây (< 1000ms).
- **Điều kiện trước:** Thiết bị Samsung A07 kết nối sẵn sàng.
- **Dữ liệu đầu vào:** Thao tác mở ứng dụng khảo sát.
- **Các bước thực hiện:**
  1. Kích hoạt ứng dụng từ màn hình chính.
  2. Đo đạc chính xác thời gian hiển thị khung hình đầu tiên (First Frame Render / First Contentful Paint) bằng công cụ Profiler/DevTools trên thiết bị thật.
- **Kết quả mong đợi:** Thời gian tải và hiển thị đầy đủ màn hình M1-01 < 1000ms.
- **Kết quả thực tế:** Về mặt mã nguồn, ứng dụng nạp mô hình fallback đồng bộ trong `initState()`. Tuy nhiên, chưa có số liệu đo đạc định lượng chính thức bằng công cụ Profiler/DevTools trên thiết bị Samsung A07.
- **Trạng thái:** **NOT RUN** *(Chờ đo kiểm định lượng trên thiết bị thật ở đợt sau)*

---

### TC04: Gửi đánh giá 5 sao và phân luồng sang màn hình M1-02
- **Mã Test Case:** TC04
- **Phạm vi kiểm thử:** Phạm vi 3 & 4 – Đánh giá từ 1 đến 5 sao & Điều hướng (Luồng 4–5 sao)
- **Mục tiêu:** Xác minh khi khách chọn 5 sao, hệ thống phân loại cảm xúc tích cực (`POSITIVE`) và tự động chuyển sang màn hình cảm ơn M1-02.
- **Điều kiện trước:** Đang ở màn hình M1-01.
- **Dữ liệu đầu vào:** Chạm vào ngôi sao thứ 5 (5 sao).
- **Các bước thực hiện:**
  1. Chạm vào ngôi sao thứ 5 trên màn hình M1-01.
  2. Quan sát hiệu ứng và màn hình chuyển tiếp.
- **Kết quả mong đợi:** Nhãn cảm xúc hiển thị `🤩 Tuyệt vời`; chuyển sang M1-02 hoàn thiện.
- **Kết quả thực tế:** **Developer xác nhận chức năng đánh giá 4–5 sao và màn hình M1-02 chưa được phân công thực hiện trong phạm vi nhiệm vụ này**. Giao diện M1-02 hiện tại chỉ là bản nháp giao diện tạm thời, chưa hoàn thiện tích hợp nghiệp vụ.
- **Trạng thái:** **NOT RUN** *(Chức năng chưa được Developer triển khai)*

---

### TC05: Gửi đánh giá 4 sao và phân luồng sang màn hình M1-02
- **Mã Test Case:** TC05
- **Phạm vi kiểm thử:** Phạm vi 3 & 4 – Đánh giá từ 1 đến 5 sao & Điều hướng (Luồng 4–5 sao)
- **Mục tiêu:** Xác minh khi khách chọn 4 sao, hệ thống phân loại cảm xúc tích cực (`POSITIVE`) và điều hướng sang M1-02.
- **Điều kiện trước:** Đang ở màn hình M1-01.
- **Dữ liệu đầu vào:** Chạm vào ngôi sao thứ 4 (4 sao).
- **Các bước thực hiện:**
  1. Chạm vào ngôi sao thứ 4.
  2. Quan sát phản hồi của ứng dụng.
- **Kết quả mong đợi:** Nhãn cảm xúc `😊 Hài lòng`; điều hướng sang M1-02 hoàn thiện.
- **Kết quả thực tế:** **Developer xác nhận chức năng đánh giá 4–5 sao chưa được phân công thực hiện**.
- **Trạng thái:** **NOT RUN** *(Chức năng chưa được Developer triển khai)*

---

### TC06: Gửi đánh giá 3 sao và phân luồng sang màn hình M1-04
- **Mã Test Case:** TC06
- **Phạm vi kiểm thử:** Phạm vi 3 & 4 – Đánh giá từ 1 đến 5 sao & Điều hướng (Luồng 1–3 sao)
- **Mục tiêu:** Xác minh khi khách chọn 3 sao, hệ thống phân loại cảm xúc chưa hài lòng (`NEGATIVE`) và chuyển sang form góp ý nội bộ M1-04.
- **Điều kiện trước:** Đang ở màn hình M1-01.
- **Dữ liệu đầu vào:** Chạm vào ngôi sao thứ 3 (3 sao).
- **Các bước thực hiện:**
  1. Chạm vào ngôi sao thứ 3.
  2. Quan sát màn hình chuyển tiếp.
- **Kết quả mong đợi:**
  - Nhãn cảm xúc: `😐 Bình thường` (màu đỏ).
  - Điều hướng sang M1-04 (`M104FeedbackScreen`), hiển thị banner xin lỗi từ Ban Quản lý.
- **Kết quả thực tế:** Màn hình chuyển đúng sang M1-04, hiển thị thông điệp *"Chúng tôi thành thật xin lỗi! Bạn đã đánh giá 3 sao"*.
- **Trạng thái:** **PASS**

---

### TC07: Gửi đánh giá 2 sao và phân luồng sang màn hình M1-04
- **Mã Test Case:** TC07
- **Phạm vi kiểm thử:** Phạm vi 3 & 4 – Đánh giá từ 1 đến 5 sao & Điều hướng (Luồng 1–3 sao)
- **Mục tiêu:** Xác minh khi khách chọn 2 sao, hệ thống phân luồng sang form góp ý nội bộ M1-04.
- **Điều kiện trước:** Đang ở màn hình M1-01.
- **Dữ liệu đầu vào:** Chạm vào ngôi sao thứ 2 (2 sao).
- **Các bước thực hiện:**
  1. Chạm vào ngôi sao thứ 2.
  2. Kiểm tra giao diện đích.
- **Kết quả mong đợi:** Điều hướng sang M1-04, hiển thị banner xin lỗi cho mức 2 sao, không xuất hiện khối hỗ trợ khẩn cấp tại bàn.
- **Kết quả thực tế:** Điều hướng chính xác sang M1-04, các chủ đề góp ý và form nhập liệu sẵn sàng.
- **Trạng thái:** **PASS**

---

### TC08: Gửi đánh giá 1 sao, phân luồng M1-04 và kích hoạt cờ khẩn cấp
- **Mã Test Case:** TC08
- **Phạm vi kiểm thử:** Phạm vi 3 & 4 – Đánh giá từ 1 đến 5 sao & Cờ khẩn cấp (Luồng 1–3 sao)
- **Mục tiêu:** Xác minh khi khách chọn 1 sao, hệ thống phân luồng sang M1-04 đồng thời kích hoạt thanh cảnh báo khẩn cấp màu vàng cam kết nối tới hotline quản lý.
- **Điều kiện trước:** Đang ở màn hình M1-01.
- **Dữ liệu đầu vào:** Chạm vào ngôi sao thứ 1 (1 sao).
- **Các bước thực hiện:**
  1. Chạm vào ngôi sao thứ 1 (`😡 Rất thất vọng`).
  2. Quan sát giao diện M1-04 xuất hiện.
- **Kết quả mong đợi:**
  - Điều hướng sang M1-04.
  - Xuất hiện khối màu vàng cam: *"Cần giải quyết nóng tại bàn? Bấm vào đây để gọi Quản lý"*.
- **Kết quả thực tế:**
  - Trên điện thoại thật: Giao diện M1-04 xuất hiện khối vàng cam hỗ trợ khẩn cấp.
  - Trong bộ test tự động: Test script `TC08` trong `scrum_189_survey_widget_test.dart` đã chạy **PASS** (tìm thấy widget text cảnh báo và icon `Icons.flash_on_rounded`).
- **Trạng thái:** **PASS**

---

### TC09: Validation Form góp ý M1-04 khi gửi nội dung trống
- **Mã Test Case:** TC09
- **Phạm vi kiểm thử:** Phạm vi 5 – Validation nội dung góp ý
- **Mục tiêu:** Xác minh form M1-04 bắt buộc người dùng phải nhập nội dung góp ý trước khi gửi, ngăn chặn gửi form rỗng.
- **Điều kiện trước:** Đang ở màn hình M1-04, ô nhập "Chi tiết góp ý" đang để trống.
- **Dữ liệu đầu vào:** `commentText = ""`.
- **Các bước thực hiện:**
  1. Giữ nguyên ô nội dung góp ý trống.
  2. Nhấn nút *"Gửi Góp Ý Riêng Tới Quản Lý"*.
- **Kết quả mong đợi:** Form không được gửi đi; hiển thị thông báo lỗi màu đỏ ngay dưới ô nhập: *"Vui lòng nhập nội dung góp ý để cơ sở cải thiện"*.
- **Kết quả thực tế:** Form bị chặn; xuất hiện dòng chữ cảnh báo lỗi đỏ đúng như kỳ vọng. Người kiểm thử đã xác nhận form yêu cầu nhập nội dung khi gửi trống.
- **Trạng thái:** **PASS**

---

### TC10: Validation Form góp ý M1-04 khi nội dung quá ngắn (< 3 ký tự)
- **Mã Test Case:** TC10
- **Phạm vi kiểm thử:** Phạm vi 5 – Validation nội dung góp ý (Biên dưới)
- **Mục tiêu:** Xác minh form M1-04 kiểm tra độ dài tối thiểu của nội dung góp ý (tối thiểu 3 ký tự).
- **Điều kiện trước:** Đang ở màn hình M1-04.
- **Dữ liệu đầu vào:** `commentText = "Ko"`.
- **Các bước thực hiện:**
  1. Nhập `"Ko"` (2 ký tự) vào ô chi tiết góp ý.
  2. Nhấn nút *"Gửi Góp Ý Riêng Tới Quản Lý"*.
- **Kết quả mong đợi:** Form bị chặn; hiển thị thông báo lỗi: *"Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)"*.
- **Kết quả thực tế:**
  - Hệ thống hiển thị đúng thông báo lỗi validation biên dưới.
  - Test script `TC10` trong `scrum_189_survey_widget_test.dart` đã chạy **PASS** (xác nhận hiển thị đúng text lỗi khi nhập 2 ký tự).
- **Trạng thái:** **PASS**

---

### TC11: Gửi phản hồi 1 sao và xác nhận Backend tiếp nhận thành công
- **Mã Test Case:** TC11
- **Phạm vi kiểm thử:** Phạm vi 6 – Gửi phản hồi và xác nhận Backend tiếp nhận
- **Mục tiêu:** Xác minh khi khách gửi phản hồi 1 sao từ điện thoại thật, Backend Spring Boot tiếp nhận và lưu trữ đầy đủ thông tin vào cơ sở dữ liệu.
- **Điều kiện trước:** Thiết bị Samsung A07 kết nối với Backend máy tính qua ADB reverse.
- **Dữ liệu đầu vào:** Đánh giá 1 sao, nội dung góp ý hợp lệ, không nhập số điện thoại.
- **Các bước thực hiện:**
  1. Đánh giá 1 sao trên M1-01 -> chuyển M1-04.
  2. Nhập nội dung góp ý -> Nhấn gửi.
  3. Kiểm tra bản ghi tiếp nhận trên Backend console log / CSDL.
- **Kết quả mong đợi:** Backend trả về HTTP 200, lưu trữ thành công bản ghi feedback kèm cờ `isUrgentCallback = true`.
- **Kết quả thực tế:** Backend đã tiếp nhận và ghi nhận thành công:
  - **Feedback ID:** `592d0d60-be33-41f9-9a8c-73b030e9db37`
  - **Response ID:** `ec56520b-c453-4888-8a8c-73b030e9db11`
  - **Dữ liệu ghi nhận:** `Star: 1, Urgent: true, HasPhone: false`.
- **Trạng thái:** **PASS**

---

### TC12: Gửi phản hồi 3 sao và xác nhận Backend tiếp nhận thành công
- **Mã Test Case:** TC12
- **Phạm vi kiểm thử:** Phạm vi 6 – Gửi phản hồi và xác nhận Backend tiếp nhận
- **Mục tiêu:** Xác minh khi khách gửi phản hồi 3 sao, Backend tiếp nhận thành công với cờ `isUrgentCallback = false`.
- **Điều kiện trước:** Kết nối thông suốt giữa thiết bị Android và Backend.
- **Dữ liệu đầu vào:** Đánh giá 3 sao, nội dung góp ý hợp lệ.
- **Các bước thực hiện:**
  1. Đánh giá 3 sao trên M1-01 -> chuyển M1-04.
  2. Nhập nội dung góp ý chi tiết -> Nhấn gửi lúc 01:16:39.
  3. Đối chiếu nhật ký ghi nhận trên máy chủ Backend.
- **Kết quả mong đợi:** Backend ghi nhận phản hồi 3 sao thành công lúc 01:16:39.
- **Kết quả thực tế:** Backend xác nhận đã tiếp nhận bản ghi phản hồi 3 sao thành công đúng mốc thời gian 01:16:39.
- **Trạng thái:** **PASS**

---

### TC13: Xử lý ngoại tuyến khi Backend hoặc mạng không hoạt động
- **Mã Test Case:** TC13
- **Phạm vi kiểm thử:** Phạm vi 7 – Xử lý khi Backend hoặc mạng không hoạt động
- **Mục tiêu:** Xác minh hành vi thực tế của ứng dụng khi ngắt mạng hoàn toàn (Chế độ máy bay) hoặc Backend tắt: ứng dụng không crash, hiển thị fallback và có thông báo phù hợp.
- **Điều kiện trước:** Thiết bị Samsung A07 bật Chế độ máy bay (ngắt hoàn toàn Wi-Fi/4G).
- **Dữ liệu đầu vào:** Thao tác mở ứng dụng và gửi đánh giá trong môi trường offline.
- **Các bước thực hiện:**
  1. Ngắt kết nối mạng trên thiết bị.
  2. Mở ứng dụng và thực hiện đánh giá.
  3. Ghi lại log và bằng chứng thực nghiệm.
- **Kết quả mong đợi:** Ứng dụng không bị crash; hiển thị cảnh báo offline rõ ràng hoặc duy trì trải nghiệm fallback an toàn.
- **Kết quả thực tế:** Mã nguồn có khối `catch (_)` fallback ngầm. Tuy nhiên, chưa thực hiện phiên test ngắt mạng thực tế có ghi nhận bằng chứng đầy đủ trên thiết bị.
- **Trạng thái:** **NOT RUN** *(Chưa có bằng chứng đo kiểm thực nghiệm tương ứng)*

---

### TC14: Điều hướng Back bằng nút in-app trên màn hình M1-02
- **Mã Test Case:** TC14
- **Phạm vi kiểm thử:** Phạm vi 9 – Điều hướng Back in-app (Luồng 4–5 sao M1-02)
- **Mục tiêu:** Xác minh khi người dùng đang ở màn hình M1-02 và nhấn nút `"← Trở lại khảo sát"`, ứng dụng quay trở lại màn hình M1-01 để có thể chọn lại số sao.
- **Điều kiện trước:** Đang ở màn hình M1-02 sau khi chọn 5 sao hoặc 4 sao.
- **Dữ liệu đầu vào:** Nhấn nút `"← Trở lại khảo sát"` (dòng 216–219 trong `m1_02_google_review_screen.dart`).
- **Các bước thực hiện:**
  1. Trên màn hình M1-02, cuộn xuống cuối màn hình.
  2. Chạm vào nút `"← Trở lại khảo sát"`.
  3. Quan sát phản hồi của ứng dụng.
- **Kết quả mong đợi:** Sau khi màn hình M1-02 được Developer hoàn thiện, nút Back phải điều hướng mượt mà về M1-01.
- **Kết quả thực tế:**
  - **Developer xác nhận luồng 4–5 sao và màn hình M1-02 chưa được phân công thực hiện/chưa hoàn thiện**. Do đó, không kết luận hiện tượng đứng khi nhấn Back sau luồng 4–5 sao là bug độc lập.
  - Về mặt kiểm thử tự động, script `TC14` trong `scrum_189_survey_widget_test.dart` chạy PASS vì kiểm chứng đúng assertion kỹ thuật `Navigator.canPop() == false`.
  - Về mặt kiểm thử thủ công, hiện tượng ứng dụng bị đứng hình được chuyển thành **Vấn đề quan sát kỹ thuật (OBS-SCRUM-189-01)**, cần được kiểm thử lại sau khi Developer hoàn thành chức năng 4–5 sao.
- **Trạng thái:** **NOT RUN** *(Chức năng M1-02 chưa triển khai hoàn thiện; chuyển thành vấn đề quan sát)*

---

### TC15: Điều hướng Back bằng phím / cử chỉ Back của hệ điều hành Android
- **Mã Test Case:** TC15
- **Phạm vi kiểm thử:** Phạm vi 9 – Điều hướng Back hệ điều hành (Luồng 4–5 sao M1-02)
- **Mục tiêu:** Xác minh khi người dùng vuốt cử chỉ Back hoặc nhấn nút Back hệ điều hành Android trên màn hình M1-02, ứng dụng quay lại màn hình M1-01 một cách mượt mà.
- **Điều kiện trước:** Đang ở màn hình M1-02 trên thiết bị Samsung A07 (Android 16).
- **Dữ liệu đầu vào:** Thao tác vuốt cử chỉ Back từ cạnh màn hình hoặc nhấn phím Back phần mềm trên thanh điều hướng Android.
- **Các bước thực hiện:**
  1. Thực hiện vuốt Back hoặc bấm nút Back của Android.
  2. Quan sát phản hồi của màn hình.
- **Kết quả mong đợi:** Hệ thống điều hướng lùi về màn hình M1-01 mượt mà sau khi chức năng hoàn thiện.
- **Kết quả thực tế:** Do luồng 4–5 sao và màn hình M1-02 chưa hoàn thiện, cử chỉ Back bị khựng lại. Tương tự TC14, hiện tượng này được ghi chú là **vấn đề quan sát kỹ thuật (OBS-SCRUM-189-01)** để tái kiểm tra khi Developer bàn giao chức năng chính thức, không ghi nhận là bug độc lập.
- **Trạng thái:** **NOT RUN** *(Chức năng M1-02 chưa triển khai hoàn thiện; chuyển thành vấn đề quan sát)*

---

### TC16: Lối đi đánh giá công khai Google Maps (E1.4)
- **Mã Test Case:** TC16
- **Phạm vi kiểm thử:** Epic E1.4 – Lối đi đánh giá công khai chống review gating
- **Mục tiêu:** Xác minh liên kết mở Google Maps công khai cho khách 1–3 sao hoạt động độc lập không cần điền form.
- **Điều kiện trước:** N/A.
- **Trạng thái:** **NOT RUN** *(Ngoài phạm vi kiểm thử trực tiếp của User Story SCRUM-189)*.

---

### TC17: Màn hình nhận ưu đãi Voucher tri ân qua SMS/Zalo (M2-01)
- **Mã Test Case:** TC17
- **Phạm vi kiểm thử:** Epic E6/E9 – Màn hình nhận ưu đãi voucher
- **Mục tiêu:** Xác minh nút "Nhận Ưu Đãi Tri Ân (M2-01)" trên màn M1-06 mở đúng luồng nhận voucher.
- **Điều kiện trước:** N/A.
- **Trạng thái:** **NOT RUN** *(Ngoài phạm vi kiểm thử trực tiếp của User Story SCRUM-189)*.
