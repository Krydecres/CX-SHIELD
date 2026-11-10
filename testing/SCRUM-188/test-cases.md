# DANH SÁCH TEST CASES CHI TIẾT – KHẢO SÁT CẢM XÚC QR (E1.1)

- **Mã Jira:** SCRUM-188
- **Tên nhiệm vụ:** [E1.1] Kiểm thử mã nguồn khảo sát cảm xúc QR
- **Phân hệ:** Review Funnel (QR Survey Funnel & Star Rating Routing)
- **Công cụ áp dụng:** Playwright API Testing (`@playwright/test`)
- **Trạng thái thực thi:** Chưa thực hiện chạy test (Chờ thực thi trên môi trường runtime ở Giai đoạn 2)
- **Lần cập nhật:** Đã rà soát và đối chiếu 100% với mã nguồn thực tế

---

## 1. Bảng tổng hợp hiện trạng kiểm thử (Coverage Overview)

Bảng phân loại dưới đây áp dụng nguyên tắc **phân loại độc lập, không đếm trùng** (Mutually Exclusive, Collectively Exhaustive):

| Nhóm kiểm thử chính | Mã Test Case | Tổng số | Đã có kịch bản trong Playwright (`e2e/survey_qr_smoke.spec.js`) | Chưa có kịch bản tự động hóa | Khả năng tự động hóa bằng Playwright API |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Positive Tests** (Luồng tích cực) | TC01, TC02, TC03, TC04, TC05, TC06, TC07, TC08, TC16 | **9** | **5** (TC01, TC02, TC04, TC06, TC08) | **4** (TC03, TC05, TC07, TC16) | 100% (9/9) |
| **Boundary Tests** (Kiểm thử giá trị biên) | TC09, TC10 | **2** | **0** | **2** (TC09, TC10) | 100% (2/2) |
| **Negative Tests** (Kiểm thử lỗi & ngoại lệ) | TC11, TC12, TC13, TC14, TC15 | **5** | **0** | **5** (TC11, TC12, TC13, TC14, TC15) | 100% (5/5) |
| **Defect Verification** (Kiểm chứng lỗi BUG-01) | TC17 | **1** | **0** | **1** (TC17) | 100% (1/1) |
| **TỔNG CỘNG** | **TC01 – TC17** | **17** | **5** | **12** | **100% (17/17)** |

> [!NOTE]
> - Cột **"Đã có kịch bản trong Playwright"** chỉ xác nhận việc mã kịch bản test đã được viết sẵn trong file `e2e/survey_qr_smoke.spec.js`.
> - Tuyệt đối **không tự ý đánh dấu PASS hoặc FAIL** khi chưa thực hiện chạy test trực tiếp trên server backend đang chạy.

---

## 2. Chi tiết từng Test Case (TC01 – TC17)

### TC01: Quét mã QR có sẵn, nhận diện chi nhánh và tạo phiên khảo sát
- **Mã Test Case:** TC01
- **Loại kiểm thử:** Positive
- **Mục tiêu:** Xác minh hệ thống nhận diện đúng mã QR có sẵn của Bàn 04, xác định đúng cơ sở, chi nhánh và khởi tạo một `SurveySession` mới ở trạng thái `STARTED`.
- **Đối chiếu mã nguồn:** `SurveyController.scanQr` -> `SurveyServiceImpl.getOrInitSession` -> `QrCodeRepository.findByCode("MC-B04")`.
- **Điều kiện trước:** Backend Spring Boot đang chạy tại cổng `8080`.
- **Dữ liệu đầu vào:** Path param `code = "MC-B04"`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `GET /api/v1/surveys/qr/MC-B04`.
  2. Đọc mã trạng thái HTTP (Status code).
  3. Kiểm tra cấu trúc và giá trị trong trường `data` của phản hồi JSON.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Khởi tạo khảo sát thành công"`.
  - `data.sessionId` là chuỗi định dạng UUID hợp lệ.
  - `data.businessName == "Maison Coffee & Bistro"`.
  - `data.branchName == "Chi nhánh Quận 1 - Đồng Khởi"`.
  - `data.tableOrAreaCode == "Bàn 04"`.
  - `data.hotline == "02838221122"`.
- **Tình trạng:** **Đã có kịch bản** trong `e2e/survey_qr_smoke.spec.js`.

---

### TC02: Kiểm tra trạng thái phiên khảo sát ngay sau khi tạo
- **Mã Test Case:** TC02
- **Loại kiểm thử:** Positive
- **Mục tiêu:** Xác minh phiên khảo sát vừa tạo được lưu trữ chính xác trong bộ nhớ hệ thống và mang trạng thái `STARTED`.
- **Đối chiếu mã nguồn:** `SurveyController.getSession` -> `SurveyServiceImpl.getSession` -> `SurveySessionRepository.findById`.
- **Điều kiện trước:** Đã thực thi TC01 và thu được `sessionId` hợp lệ.
- **Dữ liệu đầu vào:** Path param `sessionId = "<sessionId_thu_duoc_tu_TC01>"`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `GET /api/v1/surveys/session/{sessionId}`.
  2. Đọc dữ liệu chi tiết của phiên.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Thành công"`.
  - `data.id == sessionId`.
  - `data.status == "STARTED"`.
  - `data.startedAt` có giá trị thời gian (không null).
  - `data.completedAt == null`.
- **Tình trạng:** **Đã có kịch bản** trong `e2e/survey_qr_smoke.spec.js`.

---

### TC03: Quét mã QR chưa có sẵn trong CSDL (Cơ chế tự động Fallback)
- **Mã Test Case:** TC03
- **Loại kiểm thử:** Positive
- **Mục tiêu:** Xác minh khi khách quét mã QR chưa được đăng ký trước, hệ thống tự động kích hoạt cơ chế fallback tạo `QrCode` mới gắn với chi nhánh mẫu mặc định (Quận 1), đảm bảo phản hồi tức thì cho khách (<1s).
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 58–71): `qrCodeRepository.findByCode(code).orElseGet(...)`.
- **Điều kiện trước:** Backend Spring Boot đang chạy.
- **Dữ liệu đầu vào:** Path param `code = "TABLE-UNKNOWN-99"`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `GET /api/v1/surveys/qr/TABLE-UNKNOWN-99`.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Khởi tạo khảo sát thành công"`.
  - `data.sessionId` được tạo mới thành công dạng UUID.
  - `data.branchName == "Chi nhánh Quận 1 - Đồng Khởi"` (chi nhánh mặc định).
  - `data.businessName == "Maison Coffee & Bistro"`.
  - `data.tableOrAreaCode == "Vị trí TABLE-UNKNOWN-99"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC04: Gửi đánh giá 5 sao (Hài lòng tối đa - Phân luồng POSITIVE)
- **Mã Test Case:** TC04
- **Loại kiểm thử:** Positive (Biên trên của thang điểm)
- **Mục tiêu:** Xác minh đánh giá 5 sao phân luồng đúng sang nhóm cảm xúc tích cực, điều hướng sang màn hình Google Maps (`M1-02`), cập nhật session sang `COMPLETED` và lưu `SurveyResponse`.
- **Đối chiếu mã nguồn:** `SurveyController.submitRating` -> `SurveyServiceImpl.submitRating` (stars >= 4 -> `POSITIVE`, `M1-02`).
- **Điều kiện trước:** Có một `sessionId` hợp lệ đang ở trạng thái `STARTED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_STARTED>", "starRating": 5}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Đọc phản hồi trả về từ API.
  3. Gửi tiếp `GET /api/v1/surveys/session/{sessionId}` để kiểm tra cập nhật phiên.
- **Kết quả mong đợi:**
  - Bước 1: HTTP Status `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận đánh giá thành công"`.
  - `data.responseId` là chuỗi UUID hợp lệ.
  - `data.starRating == 5`.
  - `data.sentimentGroup == "POSITIVE"`.
  - `data.targetScreen == "M1-02"`.
  - `data.allowUrgentCall == false`.
  - `data.message == "Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps."`.
  - Bước 3: Session đổi sang `status == "COMPLETED"`, `data.completedAt != null`.
- **Tình trạng:** **Đã có kịch bản** trong `e2e/survey_qr_smoke.spec.js`.

---

### TC05: Gửi đánh giá 4 sao (Hài lòng - Phân luồng POSITIVE)
- **Mã Test Case:** TC05
- **Loại kiểm thử:** Positive (Cận dưới của nhóm tích cực)
- **Mục tiêu:** Xác minh đánh giá 4 sao vẫn thuộc nhóm cảm xúc tích cực và điều hướng sang màn hình Google Maps (`M1-02`).
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 117–118 & dòng 152–156).
- **Điều kiện trước:** Có một `sessionId` hợp lệ đang ở trạng thái `STARTED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_STARTED>", "starRating": 4}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận đánh giá thành công"`.
  - `data.starRating == 4`.
  - `data.sentimentGroup == "POSITIVE"`.
  - `data.targetScreen == "M1-02"`.
  - `data.allowUrgentCall == false`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC06: Gửi đánh giá 3 sao (Chưa hài lòng - Phân luồng NEGATIVE)
- **Mã Test Case:** TC06
- **Loại kiểm thử:** Positive (Cận trên của nhóm tiêu cực)
- **Mục tiêu:** Xác minh đánh giá 3 sao phân luồng sang nhóm tiêu cực, điều hướng sang form góp ý nội bộ (`M1-04`), không kích hoạt gọi khẩn cấp.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 117–118 & dòng 157–162).
- **Điều kiện trước:** Có một `sessionId` hợp lệ đang ở trạng thái `STARTED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_STARTED>", "starRating": 3}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận đánh giá thành công"`.
  - `data.starRating == 3`.
  - `data.sentimentGroup == "NEGATIVE"`.
  - `data.targetScreen == "M1-04"`.
  - `data.allowUrgentCall == false`.
  - `data.message == "Rất tiếc vì trải nghiệm chưa trọn vẹn. Hãy góp ý để chúng tôi cải thiện ngay nhé."`.
- **Tình trạng:** **Đã có kịch bản** trong `e2e/survey_qr_smoke.spec.js`.

---

### TC07: Gửi đánh giá 2 sao (Không hài lòng - Phân luồng NEGATIVE)
- **Mã Test Case:** TC07
- **Loại kiểm thử:** Positive
- **Mục tiêu:** Xác minh đánh giá 2 sao phân luồng sang form góp ý nội bộ (`M1-04`), không kích hoạt gọi khẩn cấp.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 117–118 & dòng 157–162).
- **Điều kiện trước:** Có một `sessionId` hợp lệ đang ở trạng thái `STARTED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_STARTED>", "starRating": 2}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận đánh giá thành công"`.
  - `data.starRating == 2`.
  - `data.sentimentGroup == "NEGATIVE"`.
  - `data.targetScreen == "M1-04"`.
  - `data.allowUrgentCall == false`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC08: Gửi đánh giá 1 sao (Rất thất vọng, chuyển màn M1-04)
- **Mã Test Case:** TC08
- **Loại kiểm thử:** Positive (Cận dưới của thang điểm)
- **Mục tiêu:** Xác minh đánh giá 1 sao điều hướng sang form góp ý `M1-04`, đồng thời bật cờ `allowUrgentCall = true` kèm số hotline để hỗ trợ khẩn cấp.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 158: `stars == 1 -> allowUrgentCall = true`).
- **Điều kiện trước:** Có một `sessionId` hợp lệ đang ở trạng thái `STARTED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_STARTED>", "starRating": 1}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận đánh giá thành công"`.
  - `data.starRating == 1`.
  - `data.sentimentGroup == "NEGATIVE"`.
  - `data.targetScreen == "M1-04"`.
  - `data.allowUrgentCall == true`.
  - `data.hotline == "02838221122"`.
  - `data.message == "Rất tiếc vì bạn chưa hài lòng. Bạn có thể gửi góp ý riêng hoặc gọi trực tiếp quản lý để được hỗ trợ ngay tại bàn."`.
- **Tình trạng:** **Đã có kịch bản** trong `e2e/survey_qr_smoke.spec.js`.

---

### TC09: Gửi đánh giá 0 sao (Dưới biên hợp lệ)
- **Mã Test Case:** TC09
- **Loại kiểm thử:** Boundary
- **Mục tiêu:** Xác minh hệ thống từ chối đánh giá có số sao nhỏ hơn 1.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 109–111) -> ném `IllegalArgumentException` -> `GlobalExceptionHandler.handleIllegalArgument`.
- **Điều kiện trước:** Có một `sessionId` hợp lệ.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_hop_le>", "starRating": 0}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Đọc mã lỗi và thông báo lỗi.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Đánh giá sao phải từ 1 đến 5"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC10: Gửi đánh giá 6 sao (Vượt quá biên trên hợp lệ)
- **Mã Test Case:** TC10
- **Loại kiểm thử:** Boundary
- **Mục tiêu:** Xác minh hệ thống từ chối đánh giá có số sao lớn hơn 5.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 109–111) -> ném `IllegalArgumentException`.
- **Điều kiện trước:** Có một `sessionId` hợp lệ.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_hop_le>", "starRating": 6}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
  2. Đọc mã lỗi và thông báo lỗi.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Đánh giá sao phải từ 1 đến 5"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC11: Gửi đánh giá số sao âm (-1 sao)
- **Mã Test Case:** TC11
- **Loại kiểm thử:** Negative
- **Mục tiêu:** Xác minh hệ thống từ chối xử lý giá trị sao là số nguyên âm.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 109: `requestDto.getStarRating() < 1`).
- **Điều kiện trước:** Có một `sessionId` hợp lệ.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_hop_le>", "starRating": -1}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Đánh giá sao phải từ 1 đến 5"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC12: Gửi đánh giá thiếu sessionId (sessionId là null)
- **Mã Test Case:** TC12
- **Loại kiểm thử:** Negative
- **Mục tiêu:** Xác minh hệ thống bắt lỗi khi trường `sessionId` bị bỏ trống hoặc mang giá trị null.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 106–108: `if (requestDto.getSessionId() == null)`).
- **Điều kiện trước:** Backend Spring Boot đang chạy.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": null, "starRating": 5}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Session ID không được để trống"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC13: Gửi đánh giá với sessionId không tồn tại trong hệ thống
- **Mã Test Case:** TC13
- **Loại kiểm thử:** Negative
- **Mục tiêu:** Xác minh hệ thống từ chối khi client truyền mã phiên ngẫu nhiên chưa từng được tạo qua mã QR.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 113–114: `surveySessionRepository.findById(...).orElseThrow(...)`).
- **Điều kiện trước:** Backend Spring Boot đang chạy.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "00000000-0000-0000-0000-000000000000", "starRating": 5}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Phiên khảo sát không tồn tại hoặc đã hết hạn"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC14: Gửi đánh giá sai định dạng kiểu dữ liệu (Kiểu chuỗi thay vì số / UUID sai)
- **Mã Test Case:** TC14
- **Loại kiểm thử:** Negative
- **Mục tiêu:** Xác minh tầng Deserializer của Spring MVC bắt lỗi khi client gửi dữ liệu không đúng kiểu định dạng.
- **Đối chiếu mã nguồn:** `GlobalExceptionHandler.java` (dòng 44–47: bắt `HttpMessageNotReadableException` và trả về `ApiErrorResponse`).
- **Điều kiện trước:** Backend Spring Boot đang chạy.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "invalid-uuid-format", "starRating": "nam-sao"}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/rate` với payload trên.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body phản hồi định dạng lỗi theo đối tượng `ApiErrorResponse`:
    - `code == "BAD_REQUEST"`.
    - `message == "Yêu cầu không hợp lệ."`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC15: Tra cứu phiên khảo sát với sessionId không tồn tại
- **Mã Test Case:** TC15
- **Loại kiểm thử:** Negative
- **Mục tiêu:** Xác minh endpoint tra cứu chi tiết phiên xử lý đúng khi ID không có trong bộ nhớ RAM.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 225–228: `surveySessionRepository.findById(sessionId).orElseThrow(...)`).
- **Điều kiện trước:** Backend Spring Boot đang chạy.
- **Dữ liệu đầu vào:** Path param `sessionId = "00000000-0000-0000-0000-000000000000"`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `GET /api/v1/surveys/session/00000000-0000-0000-0000-000000000000`.
- **Kết quả mong đợi:**
  - HTTP Status: `400 Bad Request`.
  - Body: `success == false`, `data == null`.
  - `message == "Không tìm thấy phiên khảo sát"`.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC16: Thực hiện lối đi đánh giá công khai (Chống Review Gating - E1.4)
- **Mã Test Case:** TC16
- **Loại kiểm thử:** Positive (Test mở rộng tích hợp phân hệ)
- **Mục tiêu:** Xác minh khi khách chọn lối đi đánh giá công khai Google Maps sau khi đánh giá 1–3 sao, hệ thống ghi nhận `is_public_bypass = true` và trả về đường link viết review trực tiếp.
- **Đối chiếu mã nguồn:** `SurveyController.recordPublicBypass` -> `SurveyServiceImpl.recordPublicBypass`.
- **Điều kiện trước:** Đã thực thi gửi đánh giá và nhận được `responseId` hợp lệ.
- **Dữ liệu đầu vào:** Payload JSON: `{"responseId": "<responseId_hop_le>"}`.
- **Các bước thực hiện:**
  1. Gửi HTTP Request: `POST /api/v1/surveys/public-review` với payload trên.
- **Kết quả mong đợi:**
  - HTTP Status: `200 OK`.
  - Body: `success == true`, `message == "Ghi nhận chuyển hướng đánh giá công khai thành công"`.
  - `data.publicBypass == true`.
  - `data.redirectClickedAt` có giá trị thời gian.
  - `data.reviewDirectUrl` chứa đường dẫn `writereview` của Google Maps.
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API).

---

### TC17: Gửi đánh giá lần 2 trên cùng một phiên đã hoàn tất (Kiểm chứng BUG-01)
- **Mã Test Case:** TC17
- **Loại kiểm thử:** Defect Verification
- **Mục tiêu:** Xác minh cách hệ thống phản ứng khi client cố tình gửi đánh giá lần thứ 2 trên cùng một `sessionId` đã có trạng thái `COMPLETED`.
- **Đối chiếu mã nguồn:** `SurveyServiceImpl.java` (dòng 113–133): Service chỉ gọi `findById` mà không kiểm tra `if ("COMPLETED".equals(session.getStatus()))`.
- **Điều kiện trước:** Đã thực thi TC04 hoặc TC06 thành công, phiên đã đổi sang trạng thái `COMPLETED`.
- **Dữ liệu đầu vào:** Payload JSON: `{"sessionId": "<sessionId_da_COMPLETED>", "starRating": 1}`.
- **Các bước thực hiện:**
  1. Gửi lại HTTP Request: `POST /api/v1/surveys/rate` với `sessionId` cũ và số sao mới.
  2. Đọc HTTP Status và dữ liệu phản hồi của server.
- **Kết quả mong đợi theo chuẩn nghiệp vụ:**
  - Hệ thống phải từ chối (HTTP `400 Bad Request` hoặc `409 Conflict`) với thông báo: *"Phiên khảo sát đã được hoàn thành trước đó"*.
- **Hành vi thực tế suy ra từ mã nguồn:**
  - Do thiếu điều kiện chặn trong code, hệ thống hiện tại trả về `200 OK`, cập nhật lại `completedAt` và tạo thêm một `SurveyResponse` mới trong RAM (BUG-01).
- **Tình trạng:** **Chưa có kịch bản** trong Playwright (Có thể tự động hóa 100% bằng Playwright API để ghi nhận bằng chứng lỗi).

---

## 3. Review Notes (Ghi chú đánh giá và phân loại Test Cases)

Phần ghi chú này ghi nhận kết quả rà soát độc lập đối chiếu từng Test Case với mã nguồn thực tế của dự án CX-SHIELD:

### 3.1. Các Test Case được xác nhận ĐÚNG 100% theo source code
- **TC01, TC02:** Ánh xạ chính xác vào `@GetMapping("/qr/{code}")` và `@GetMapping("/session/{sessionId}")` trong `SurveyController.java`. Các trường dữ liệu, mã trạng thái HTTP 200 và thông báo `message` hoàn toàn khớp.
- **TC04, TC05, TC06, TC07, TC08:** Toàn bộ thang điểm từ 1 đến 5 sao đều được ánh xạ chính xác vào phương thức `submitRating` trong `SurveyServiceImpl.java`:
  - 4 và 5 sao: Gán đúng `targetScreen = "M1-02"`, `sentimentGroup = "POSITIVE"`, `allowUrgentCall = false`.
  - 2 và 3 sao: Gán đúng `targetScreen = "M1-04"`, `sentimentGroup = "NEGATIVE"`, `allowUrgentCall = false`.
  - 1 sao: Gán đúng `targetScreen = "M1-04"`, `sentimentGroup = "NEGATIVE"`, `allowUrgentCall = true` kèm số `hotline`.
- **TC09, TC10, TC11, TC12, TC13, TC15:** Các nhánh lỗi ném ngoại lệ `IllegalArgumentException` trong Service và được bắt tập trung tại `GlobalExceptionHandler.handleIllegalArgument`, trả về đúng mã HTTP 400 và nội dung thông báo tiếng Việt khớp từng chữ với mã nguồn.

### 3.2. Các Test Case đã được điều chỉnh chi tiết
- **TC03 (QR Fallback):**
  - *Xác nhận:* Mã nguồn tại `SurveyServiceImpl.java` (dòng 58–71) **THỰC SỰ CÓ HỖ TRỢ** cơ chế QR Fallback. Khi không tìm thấy mã trong kho lưu trữ, service tự động tạo `QrCode` mới và gắn với chi nhánh mẫu mặc định (ID `b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22` - Chi nhánh Quận 1).
  - *Điều chỉnh:* Đã cập nhật chính xác giá trị `tableOrAreaCode` mong đợi trả về là `"Vị trí TABLE-UNKNOWN-99"` (thay vì cố định là Bàn 04).
- **TC14 (Validation sai kiểu dữ liệu):**
  - *Điều chỉnh:* Khi gửi sai định dạng JSON (chuỗi thay vì số, sai định dạng UUID), lỗi không đi qua tầng Service mà bị chặn ngay ở tầng Deserializer của Spring MVC (`HttpMessageNotReadableException`). Do đó, cấu trúc phản hồi trả về là `ApiErrorResponse` (`{"code": "BAD_REQUEST", "message": "Yêu cầu không hợp lệ."}`) thay vì cấu trúc `ApiResponse` của tầng nghiệp vụ.
- **TC17 (Kiểm chứng BUG-01 - Đánh giá trùng lặp):**
  - *Xác nhận từ code:* Phương thức `submitRating` (dòng 113–133) **hoàn toàn cho phép** đánh giá nhiều lần trên cùng một session đã `COMPLETED`.
  - *Điều chỉnh:* Tách bạch rõ ràng giữa "Kết quả mong đợi theo chuẩn nghiệp vụ" (phải từ chối) và "Hành vi thực tế suy ra từ mã nguồn" (trả về 200 OK và tạo thêm response).

### 3.3. Test Case không thuộc phạm vi trực tiếp hoặc không có chức năng tương ứng
- **TC16 (Lối đi đánh giá công khai - Public Review Bypass):**
  - *Hiện trạng endpoint:* Endpoint `POST /api/v1/surveys/public-review` **có tồn tại** trong `SurveyController.java` (dòng 60–64) và hoạt động bình thường.
  - *Đánh giá phạm vi:* Chức năng này thuộc User Story **Epic E1.4 (Chống review gating)**, không nằm trong phạm vi nghiệp vụ trực tiếp của **Epic E1.1 (SCRUM-188: Khảo sát cảm xúc QR < 1s)**. Tuy nhiên, nó được giữ lại trong danh mục như một **Test Case mở rộng (Integration Flow)** để phục vụ kiểm thử liên thông phân hệ.
- **Lưu ý về API lấy Response:** Trong source code **hoàn toàn không có** endpoint dạng `GET /api/v1/surveys/response/{id}`. Do đó, tester không tạo test case kiểm tra endpoint này; việc xác nhận `responseId` được thực hiện thông qua payload của `POST /rate` hoặc thông qua các API kế tiếp như `POST /public-review` và `POST /feedbacks`.

### 3.4. Các vấn đề chưa thể xác minh trên mã nguồn tĩnh (Cần chạy kiểm thử thực tế)
1. **Thời gian tải trang khảo sát < 1 giây:** Tiêu chí Epic E1.1 yêu cầu mở trang khảo sát qua QR dưới 1s. Trên code tĩnh, việc dùng RAM cho thấy tiềm năng đạt tốc độ cao, nhưng chỉ có thể xác minh chính xác thông qua việc đo thời gian phản hồi (Response Time) khi chạy test script Playwright trên môi trường mạng thực tế.
2. **Hành vi thực tế của TC17:** Cần chạy kịch bản tự động hóa gửi 2 request liên tiếp để lấy bằng chứng HTTP response log thực tế phục vụ tạo Bug ticket trên Jira.
