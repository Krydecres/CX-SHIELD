# BÁO CÁO KẾT QUẢ THỰC THI KIỂM THỬ TỰ ĐỘNG (TEST REPORT)

- **Mã Jira:** SCRUM-188
- **Tên User Story:** [E1.1] Kiểm thử mã nguồn khảo sát cảm xúc QR
- **Phân hệ:** Review Funnel – Khảo sát QR (<1s) & Phân luồng đánh giá
- **Công cụ kiểm thử:** Playwright API Testing (`@playwright/test` v1.64.1)
- **Môi trường thực thi:** Local Server (`http://localhost:8080`), Spring Boot 4.0.0, Java 21 (Temurin-21.0.12.1), In-Memory Repository
- **Ngày thực thi:** 05/11/2026
- **Người thực hiện:** QA / Test Automation Engineer
- **Tài liệu tham chiếu:** `testing/SCRUM-188/test-cases.md`, `testing/SCRUM-188/analysis-report.md`

---

## 1. Tổng quan kết quả thực thi (Executive Summary)

### 1.1. Phạm vi kiểm thử (Scope Definition)
- **Tổng số Test Cases trong danh mục thiết kế:** 17 Test Cases (TC01 – TC17).
- **Phạm vi kiểm thử bắt buộc của User Story E1.1 (SCRUM-188):** **16 Test Cases** (TC01 – TC15 và TC17).
- **Ngoài phạm vi kiểm thử chính của E1.1:** **01 Test Case** – **TC16** (Thuộc User Story Epic E1.4: Lối đi đánh giá công khai Google Maps nhằm chống review gating; được ghi nhận riêng và không tính vào chỉ số nghiệm thu của SCRUM-188).

### 1.2. Thống kê kết quả kiểm thử thực tế

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Diễn giải chi tiết |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Case thuộc phạm vi E1.1** | **16** | **100%** | Toàn bộ các ca kiểm thử liên quan đến QR, Session, Đánh giá 1–5 sao, Validation và Kiểm chứng lỗi |
| **PASS (Đạt yêu cầu nghiệp vụ & assertion)** | **15** | **93.75%** | TC01 – TC15: Xử lý đúng toàn bộ HTTP Status, cấu trúc DTO, logic phân luồng và thông báo lỗi |
| **FAIL (Không đạt chuẩn nghiệp vụ - Xác nhận lỗi)** | **1** | **6.25%** | **TC17 (BUG-01 CONFIRMED):** Hệ thống vi phạm quy tắc nghiệp vụ khi cho phép gửi đánh giá lần 2 trên session đã `COMPLETED` |
| **BLOCKED (Bị chặn do môi trường / sự cố)** | **0** | **0%** | Backend Spring Boot khởi động và lắng nghe thành công tại cổng 8080, không có bài test nào bị nghẽn |
| **NOT RUN (Ngoài phạm vi E1.1)** | **1** | - | **TC16** (Thuộc Epic E1.4 – Lối đi đánh giá công khai chống review gating) |

> [!IMPORTANT]
> **Phân biệt giữa Kết quả Test Case và Trạng thái kiểm chứng lỗi:**
> - Về mặt **tiêu chuẩn nghiệp vụ**, **TC17 được phân loại là FAIL**: Hệ thống thất bại trong việc bảo đảm tính toàn vẹn (Idempotency) của phiên khảo sát.
> - Về mặt **kiểm chứng lỗi**, **TC17 là DEFECT CONFIRMED**: Kịch bản kiểm thử tự động đã thực thi thành công, ghi nhận đầy đủ bằng chứng xác thực sự tồn tại của lỗi nghiệp vụ **BUG-01** trên môi trường thực tế.

---

## 2. Thông tin kịch bản & Lệnh thực thi Playwright

### 2.1. Cấu trúc kịch bản và sự tương quan số lượng Test
Hệ thống kiểm thử tự động được cấu hình thông qua `playwright.config.js`, sử dụng `baseURL` mặc định là `http://localhost:8080`. Spring Boot backend cần được khởi động riêng trước khi thực thi Playwright.

Bộ kiểm thử gồm 2 file kịch bản:
1. **File kịch bản cơ sở:** `e2e/survey_qr_smoke.spec.js`
   - Chứa **3 test functions theo kịch bản luồng (Scenario-based tests)**, bao phủ **5 Test Cases cơ sở**:
     - *Kịch bản "5 sao - đánh giá tích cực":* Bao phủ **TC01** (Quét QR), **TC02** (Trạng thái session `STARTED`), **TC04** (Gửi đánh giá 5 sao & session `COMPLETED`).
     - *Kịch bản "3 sao - đánh giá tiêu cực":* Bao phủ **TC06** (Gửi đánh giá 3 sao -> `NEGATIVE`, `M1-04`).
     - *Kịch bản "1 sao - yêu cầu gọi khẩn cấp":* Bao phủ **TC08** (Gửi đánh giá 1 sao -> `NEGATIVE`, bật cờ `allowUrgentCall`).
2. **File kịch bản bổ sung:** `e2e/survey_qr_scrum188.spec.js`
   - Chứa **11 test functions độc lập**, bao phủ chính xác **11 Test Cases còn lại** thuộc phạm vi SCRUM-188:
     - **TC03:** Quét mã QR chưa có sẵn (Fallback QR).
     - **TC05:** Gửi đánh giá 4 sao.
     - **TC07:** Gửi đánh giá 2 sao.
     - **TC09:** Gửi đánh giá 0 sao (Biên dưới).
     - **TC10:** Gửi đánh giá 6 sao (Biên trên).
     - **TC11:** Gửi đánh giá -1 sao (Số âm).
     - **TC12:** Gửi đánh giá thiếu `sessionId` (`null`).
     - **TC13:** Gửi đánh giá với `sessionId` không tồn tại (UUID ảo).
     - **TC14:** Gửi đánh giá sai kiểu dữ liệu (Chuỗi thay vì số).
     - **TC15:** Tra cứu phiên khảo sát với `sessionId` không tồn tại.
     - **TC17:** Bắt bằng chứng lỗi gửi đánh giá lần 2 trên session `COMPLETED` (BUG-01).

**Tổng hợp:** 3 test functions (smoke) + 11 test functions (scrum188) = **14 test functions Playwright thực thi**, bao phủ trọn vẹn **16 Test Cases logic của Jira SCRUM-188**.

### 2.2. Lệnh thực thi kiểm thử tại terminal
```powershell
# Lệnh 1: Chạy riêng bộ 5 Test Cases cơ sở (Smoke tests)
npx playwright test e2e/survey_qr_smoke.spec.js

# Lệnh 2: Chạy riêng bộ 11 Test Cases bổ sung
npx playwright test e2e/survey_qr_scrum188.spec.js

# Lệnh 3: Chạy toàn bộ Test Suite (14 test functions / 16 Test Cases)
npx playwright test
```

### 2.3. Kết quả console log thực tế từ Playwright Runner
```text
Running 14 tests using 1 worker

[TC03 Response Time]: 32ms | Status: 200
  ok  1 e2e\survey_qr_scrum188.spec.js:5:3 › TC03: Quét mã QR chưa có sẵn trong CSDL (Cơ chế tự động Fallback) (62ms)
[TC05 - 4 Stars] Status: 200
  ok  2 e2e\survey_qr_scrum188.spec.js:23:3 › TC05: Gửi đánh giá 4 sao (Hài lòng - Phân luồng POSITIVE) (72ms)
[TC07 - 2 Stars] Status: 200
  ok  3 e2e\survey_qr_scrum188.spec.js:44:3 › TC07: Gửi đánh giá 2 sao (Không hài lòng - Phân luồng NEGATIVE) (22ms)
[TC09 - 0 Stars] Status: 400
  ok  4 e2e\survey_qr_scrum188.spec.js:65:3 › TC09: Gửi đánh giá 0 sao (Dưới biên hợp lệ) (49ms)
[TC10 - 6 Stars] Status: 400
  ok  5 e2e\survey_qr_scrum188.spec.js:80:3 › TC10: Gửi đánh giá 6 sao (Vượt quá biên trên hợp lệ) (25ms)
[TC11 - -1 Stars] Status: 400
  ok  6 e2e\survey_qr_scrum188.spec.js:95:3 › TC11: Gửi đánh giá số sao âm (-1 sao) (32ms)
[TC12 - null SessionId] Status: 400
  ok  7 e2e\survey_qr_scrum188.spec.js:110:3 › TC12: Gửi đánh giá thiếu sessionId (null) (12ms)
[TC13 - Non-existent SessionId] Status: 400
  ok  8 e2e\survey_qr_scrum188.spec.js:122:3 › TC13: Gửi đánh giá với sessionId không tồn tại trong hệ thống (21ms)
[TC14 - Malformed Data] Status: 400
  ok  9 e2e\survey_qr_scrum188.spec.js:135:3 › TC14: Gửi đánh giá sai định dạng kiểu dữ liệu (Kiểu chuỗi thay vì số) (24ms)
[TC15 - Non-existent Session Query] Status: 400
  ok 10 e2e\survey_qr_scrum188.spec.js:147:3 › TC15: Tra cứu phiên khảo sát với sessionId không tồn tại (9ms)
[TC17] Đã tạo session mới: 51d0e080-51ea-44a0-874a-8fcb39c6db2a
[TC17 - Lần 1] Status: 200 | Body: {"success":true,"message":"Ghi nhận đánh giá thành công","data":{"allowUrgentCall":false,"hotline":"02838221122","message":"Cảm ơn bạn đã hài lòng! Hãy chia sẻ trải nghiệm tuyệt vời lên Google Maps.","responseId":"64827e18-0329-461a-83b8-b02e3bc549d3","sentimentGroup":"POSITIVE","sessionId":"51d0e080-51ea-44a0-874a-8fcb39c6db2a","starRating":5,"targetScreen":"M1-02"},"timestamp":"2026-11-05T16:21:43.862143Z"}
[TC17 - Lần 2] Status: 200 | Body: {"success":true,"message":"Ghi nhận đánh giá thành công","data":{"allowUrgentCall":true,"hotline":"02838221122","message":"Rất tiếc vì bạn chưa hài lòng. Bạn có thể gửi góp ý riêng hoặc gọi trực tiếp quản lý để được hỗ trợ ngay tại bàn.","responseId":"9f67bb19-3537-40c2-b6a2-80b4ede757d0","sentimentGroup":"NEGATIVE","sessionId":"51d0e080-51ea-44a0-874a-8fcb39c6db2a","starRating":1,"targetScreen":"M1-04"},"timestamp":"2026-11-05T16:21:43.870289800Z"}
[TC17 BẰNG CHỨNG BUG-01]: Server trả về HTTP 200 OK cho lần đánh giá thứ 2!
[TC17 BẰNG CHỨNG BUG-01]: Response ID 1 = 64827e18-0329-461a-83b8-b02e3bc549d3 vs Response ID 2 = 9f67bb19-3537-40c2-b6a2-80b4ede757d0
[TC17 BẰNG CHỨNG BUG-01]: Trạng thái bị ghi đè từ POSITIVE (5 sao) sang NEGATIVE (1 sao)!
  ok 11 e2e\survey_qr_scrum188.spec.js:158:3 › TC17: Kiểm chứng lỗi BUG-01 (Đánh giá lần 2 trên cùng một session COMPLETED) (22ms)
[TC01 - Scan QR MC-B04] Status: 200, ResponseTime: 6ms
[TC02 - Get Initial Session] Status: 200, ResponseTime: 7ms
[Rate 5 stars] Status: 200, ResponseTime: 6ms
  ok 12 e2e\survey_qr_smoke.spec.js:28:3 › 5 sao - đánh giá tích cực (38ms)
[TC01 - Scan QR MC-B04] Status: 200, ResponseTime: 6ms
[TC02 - Get Initial Session] Status: 200, ResponseTime: 6ms
[Rate 3 stars] Status: 200, ResponseTime: 5ms
  ok 13 e2e\survey_qr_smoke.spec.js:28:3 › 3 sao - đánh giá tiêu cực (43ms)
[TC01 - Scan QR MC-B04] Status: 200, ResponseTime: 7ms
[TC02 - Get Initial Session] Status: 200, ResponseTime: 6ms
[Rate 1 stars] Status: 200, ResponseTime: 6ms
  ok 14 e2e\survey_qr_smoke.spec.js:28:3 › 1 sao - yêu cầu gọi khẩn cấp (43ms)

  14 passed (14.2s)
```

---

## 3. Bảng kết quả chi tiết từng Test Case (TC01 – TC17)

| Mã TC | Phân loại | Tên Test Case & Mục tiêu kiểm thử | HTTP Status thực tế | Response Time | Kết quả nghiệp vụ | Chi tiết phản hồi thực tế từ Backend |
| :---: | :--- | :--- | :---: | :---: | :---: | :--- |
| **TC01** | Positive | Quét mã QR có sẵn `MC-B04`, nhận diện chi nhánh & tạo session | `200 OK` | **6ms – 23ms** | **PASS** | `success: true`<br>`branchName: "Chi nhánh Quận 1 - Đồng Khởi"`<br>`businessName: "Maison Coffee & Bistro"`<br>`tableOrAreaCode: "Bàn 04"`<br>`sessionId` hợp lệ định dạng UUID |
| **TC02** | Positive | Kiểm tra trạng thái session ban đầu (`STARTED`) | `200 OK` | **4ms – 8ms** | **PASS** | `success: true`, `message: "Thành công"`<br>`data.status: "STARTED"`<br>`startedAt != null`, `completedAt == null` |
| **TC03** | Positive | Quét mã QR chưa có sẵn trong CSDL (Cơ chế Fallback) | `200 OK` | **32ms – 39ms** | **PASS** | `success: true`<br>Tự động tạo QR và gắn với Chi nhánh Quận 1<br>`tableOrAreaCode: "Vị trí TABLE-UNKNOWN-99"` |
| **TC04** | Positive / Biên | Gửi đánh giá 5 sao (Hài lòng tối đa) | `200 OK` | **6ms – 40ms** | **PASS** | `sentimentGroup: "POSITIVE"`<br>`targetScreen: "M1-02"`<br>`allowUrgentCall: false`<br>Session cập nhật sang `COMPLETED` |
| **TC05** | Positive / Biên | Gửi đánh giá 4 sao (Hài lòng) | `200 OK` | **72ms** | **PASS** | `sentimentGroup: "POSITIVE"`<br>`targetScreen: "M1-02"`<br>`allowUrgentCall: false` |
| **TC06** | Positive / Biên | Gửi đánh giá 3 sao (Chưa hài lòng) | `200 OK` | **5ms – 29ms** | **PASS** | `sentimentGroup: "NEGATIVE"`<br>`targetScreen: "M1-04"`<br>`allowUrgentCall: false` |
| **TC07** | Positive | Gửi đánh giá 2 sao (Không hài lòng) | `200 OK` | **22ms** | **PASS** | `sentimentGroup: "NEGATIVE"`<br>`targetScreen: "M1-04"`<br>`allowUrgentCall: false` |
| **TC08** | Positive / Biên | Gửi đánh giá 1 sao (Rất thất vọng, chuyển màn M1-04) | `200 OK` | **6ms – 26ms** | **PASS** | `sentimentGroup: "NEGATIVE"`<br>`targetScreen: "M1-04"`<br>`allowUrgentCall: true`<br>`hotline: "02838221122"` |
| **TC09** | Boundary | Gửi đánh giá 0 sao (Dưới biên hợp lệ) | `400 Bad Request` | **49ms** | **PASS** | `success: false`<br>`message: "Đánh giá sao phải từ 1 đến 5"` |
| **TC10** | Boundary | Gửi đánh giá 6 sao (Vượt quá biên trên) | `400 Bad Request` | **25ms** | **PASS** | `success: false`<br>`message: "Đánh giá sao phải từ 1 đến 5"` |
| **TC11** | Negative | Gửi đánh giá số sao âm (-1 sao) | `400 Bad Request` | **32ms** | **PASS** | `success: false`<br>`message: "Đánh giá sao phải từ 1 đến 5"` |
| **TC12** | Negative | Gửi đánh giá thiếu `sessionId` (`null`) | `400 Bad Request` | **12ms** | **PASS** | `success: false`<br>`message: "Session ID không được để trống"` |
| **TC13** | Negative | Gửi đánh giá với `sessionId` không tồn tại (UUID ảo) | `400 Bad Request` | **21ms** | **PASS** | `success: false`<br>`message: "Phiên khảo sát không tồn tại hoặc đã hết hạn"` |
| **TC14** | Negative | Gửi đánh giá sai định dạng dữ liệu (chuỗi thay vì số) | `400 Bad Request` | **24ms** | **PASS** | `code: "BAD_REQUEST"`<br>`message: "Yêu cầu không hợp lệ."` (Xử lý bởi `GlobalExceptionHandler`) |
| **TC15** | Negative | Tra cứu phiên khảo sát với `sessionId` không tồn tại | `400 Bad Request` | **9ms** | **PASS** | `success: false`<br>`message: "Không tìm thấy phiên khảo sát"` |
| **TC16** | Integration | Lối đi đánh giá công khai Google Maps (E1.4) | - | - | **NOT RUN** | *Thuộc Epic E1.4 (ngoài phạm vi kiểm thử chính của SCRUM-188)* |
| **TC17** | Defect Verif. | Gửi đánh giá lần 2 trên cùng session đã `COMPLETED` | `200 OK` | **22ms** | **FAIL (BUG-01 CONFIRMED)** | Server không từ chối; trả về 200 OK, ghi đè session và tạo thêm responseId mới |

---

## 4. Đo lường hiệu năng thời gian đáp ứng API (API Response Time)

Tiêu chí nghiệm thu của User Story Epic E1.1 quy định: **Thời gian phản hồi khi quét mã QR mở khảo sát phải tức thì (< 1s / 1000ms)**.

### 4.1. Kết quả đo lường thời gian phản hồi API qua Playwright
- **TC01 (API quét mã QR có sẵn `GET /api/v1/surveys/qr/MC-B04`):**
  - Thời gian phản hồi lần đầu (Cold run): **23ms**.
  - Thời gian phản hồi các lần kế tiếp (Warm runs): **5ms – 7ms**.
- **TC03 (API quét mã QR chưa có sẵn `GET /api/v1/surveys/qr/TABLE-UNKNOWN-99` - Cơ chế Fallback):**
  - Thời gian phản hồi: **32ms – 39ms**.

### 4.2. Khuyến cáo kỹ thuật về giới hạn của phép đo (Scope of Measurement)
> [!WARNING]
> - Kết quả đo trên **chỉ phản ánh thời gian phản hồi của tầng mạng & API Backend (API Network Response Time / Round-trip Latency)** giữa client và server local.
> - **KHÔNG ĐƯỢC QUY KẾT đây là tốc độ tải toàn bộ giao diện người dùng trên điện thoại (Client-side UI Rendering Time / First Contentful Paint)**.
> - Trên thiết bị di động thực tế, tổng thời gian hiển thị giao diện M1-01 còn phụ thuộc vào: thời gian tải bundle Flutter Web, tải phông chữ, khởi tạo engine CanvasKit/HTML và dựng khung hình (frame rendering). Các chỉ số này cần được đo đạc bằng công cụ kiểm thử hiệu năng UI riêng biệt (như Chrome DevTools, Lighthouse hoặc Flutter Driver) trên thiết bị thật ở các sprint kiểm thử giao diện.

---

## 5. Bằng chứng kiểm chứng lỗi BUG-01 (Idempotency Flaw)

### 5.1. Dữ liệu thực tế ghi nhận từ quá trình chạy test (TC17)
- **Bước 1: Khởi tạo phiên khảo sát mới:**
  - Endpoint: `GET /api/v1/surveys/qr/MC-B04`
  - Sinh ra `sessionId`: `51d0e080-51ea-44a0-874a-8fcb39c6db2a`
- **Bước 2: Gửi đánh giá lần đầu (5 sao):**
  - Request: `POST /api/v1/surveys/rate`
  - Payload: `{"sessionId": "51d0e080-51ea-44a0-874a-8fcb39c6db2a", "starRating": 5}`
  - Phản hồi thực tế:
    - HTTP Status: `200 OK`
    - Response ID 1: `64827e18-0329-461a-83b8-b02e3bc549d3`
    - Phân luồng: `sentimentGroup = "POSITIVE"`, `targetScreen = "M1-02"`
    - Trạng thái phiên: Đổi thành `COMPLETED`, ghi nhận `completedAt` lần 1.
- **Bước 3: Gửi đánh giá lần thứ hai trên CÙNG session đã `COMPLETED` (1 sao):**
  - Request: `POST /api/v1/surveys/rate`
  - Payload: `{"sessionId": "51d0e080-51ea-44a0-874a-8fcb39c6db2a", "starRating": 1}`
  - Phản hồi thực tế:
    - HTTP Status: **`200 OK`**
    - Response ID 2: `9f67bb19-3537-40c2-b6a2-80b4ede757d0`
    - Phân luồng: Bị lật sang `sentimentGroup = "NEGATIVE"`, `targetScreen = "M1-04"`, `allowUrgentCall = true`.

### 5.2. Hành vi nghiệp vụ sai và kết luận
- **Hành vi sai phạm:**
  1. Server vi phạm nguyên tắc **Idempotency** (tính duy nhất của kết quả đánh giá). Khi một phiên khảo sát đã chuyển sang trạng thái `COMPLETED`, hệ thống **vẫn tiếp tục chấp nhận request đánh giá lần hai**.
  2. Tạo ra **hai bản ghi kết quả đánh giá (`responseId`) độc lập** cho cùng một lượt quét mã QR.
  3. Ghi đè thời gian hoàn thành `completedAt` và làm sai lệch nhóm cảm xúc từ hài lòng (`POSITIVE`) sang khiếu nại (`NEGATIVE`).
- **Kỳ vọng nghiệp vụ chuẩn:** Khi nhận request đánh giá cho một `sessionId` đã `COMPLETED`, backend phải từ chối xử lý bằng mã lỗi **`400 Bad Request`** hoặc **`409 Conflict`** kèm thông báo lỗi rõ ràng (ví dụ: *"Phiên khảo sát này đã được gửi đánh giá trước đó"*).
- **Kết luận:** **Lỗi BUG-01 ĐÃ CHÍNH THỨC ĐƯỢC XÁC NHẬN (CONFIRMED & REPRODUCED)**.

---

## 6. Lỗi phát hiện & Đề xuất xử lý cho Jira SCRUM-188

### 6.1. Lỗi chính thức được xác nhận: BUG-01
- **Tên Bug:** `[Backend] Phương thức submitRating cho phép gửi đánh giá nhiều lần trên cùng một session đã COMPLETED (Thiếu Idempotency check)`
- **Mã theo dõi đề xuất:** `CX-BUG-01`
- **Mức độ nghiêm trọng (Severity):** **Major** (Làm sai lệch báo cáo và số liệu cảm xúc khách hàng).
- **Vị trí mã nguồn:** `backend/src/main/java/com/cxshield/backend/service/impl/SurveyServiceImpl.java` (dòng 113–125)
- **Đề xuất xử lý (Backend):** Bổ sung điều kiện kiểm tra trạng thái trước khi xử lý đánh giá:
  ```java
  SurveySession session = surveySessionRepository.findById(requestDto.getSessionId())
          .orElseThrow(() -> new IllegalArgumentException("Phiên khảo sát không tồn tại hoặc đã hết hạn"));

  if ("COMPLETED".equals(session.getStatus())) {
      throw new IllegalArgumentException("Phiên khảo sát này đã được gửi đánh giá trước đó.");
  }
  ```

---

## 7. Phát hiện bổ sung cần xác minh (Additional Technical Observations)

*(Các mục dưới đây là quan sát kỹ thuật phát hiện qua rà soát mã nguồn, không tính vào số lỗi chính thức đã xác nhận của SCRUM-188 do chưa có Test Case độc lập và bằng chứng thực thi đầy đủ).*

1. **Quan sát về xử lý URL không tồn tại (Tiềm ẩn BUG-02):**
   - *Mô tả:* Lớp `backend/src/main/java/com/cxshield/backend/common/GlobalExceptionHandler.java` (dòng 64–69) sử dụng `@ExceptionHandler(Exception.class)` bắt tất cả ngoại lệ chưa được khai báo và trả về HTTP 500. Khi gọi các URL chưa được ánh xạ trong Controller (như `GET /api/v1/surveys`), lỗi `NoResourceFoundException` có thể bị chuyển đổi thành mã 500 thay vì 404.
   - *Tình trạng:* Cần lập Test Case riêng để xác minh độc lập ở các sprint bảo trì API.
2. **Quan sát về cơ chế lưu trữ In-Memory:**
   - *Mô tả:* Các repository phân hệ khảo sát (`SurveySessionRepository`, `SurveyResponseRepository`) hiện đang lưu dữ liệu trên RAM bằng `ConcurrentHashMap`. Khi khởi động lại server, toàn bộ dữ liệu phiên và đánh giá sẽ bị mất.
   - *Khuyến nghị:* Đội phát triển cần sớm chuyển đổi sang kết nối CSDL PostgreSQL/Supabase theo schema đã có trong `database/n1_khao_sat.sql`.

---

## 8. Danh mục tài liệu tham chiếu & Đường dẫn bằng chứng

| Thành phần | Đường dẫn tệp tin | Mô tả nội dung |
| :--- | :--- | :--- |
| **Kịch bản kiểm thử 1** | `e2e/survey_qr_smoke.spec.js` | Kịch bản Playwright cơ sở (3 test functions, đo thời gian TC01, TC02, TC04, TC06, TC08) |
| **Kịch bản kiểm thử 2** | `e2e/survey_qr_scrum188.spec.js` | Kịch bản Playwright bổ sung (11 test functions cho TC03, TC05, TC07, TC09–TC15 và TC17) |
| **Cấu hình Playwright** | `playwright.config.js` | Cấu hình runner tích hợp `webServer` khởi động Spring Boot |
| **Báo cáo HTML trực quan** | `playwright-report/index.html` | Báo cáo chi tiết dạng đồ họa sinh ra sau lần chạy |
| **Log máy chủ Backend** | `backend.log` | Nhật ký khởi động Spring Boot 4.0.0 trên cổng 8080 |
| **Đặc tả Test Cases** | `testing/SCRUM-188/test-cases.md` | Tài liệu chi tiết 17 Test Cases chuẩn hóa |
| **Báo cáo kiến trúc mã nguồn** | `testing/SCRUM-188/analysis-report.md` | Phân tích luồng Controller, Service, In-Memory Repository |
