# BÁO CÁO PHÂN TÍCH MÃ NGUỒN KHẢO SÁT CẢM XÚC QR (E1.1)

- **Mã Jira:** SCRUM-188
- **Tên nhiệm vụ:** [E1.1] Kiểm thử mã nguồn khảo sát cảm xúc QR
- **Phân hệ:** Review Funnel (Phễu đánh giá & Khảo sát cảm xúc siêu tốc < 1s)
- **Tài liệu tham chiếu:** User Story Epic E1.1, Epic E1.3, Epic E1.4
- **Ngày lập:** 05/11/2026
- **Trạng thái:** Giai đoạn 1 – Phân tích kỹ thuật mã nguồn (Read-only)

---

## 1. Kiến trúc hệ thống liên quan đến khảo sát QR

Hệ thống backend của CX-SHIELD được xây dựng trên nền tảng **Spring Boot 4.0.0 (Java 21)**. Phân hệ khảo sát QR bao gồm 4 tầng chính:

```
[HTTP Request]
      │
      ▼
Controller Layer (SurveyController, FeedbackController)
      │
      ▼
Service Layer (SurveyServiceImpl, FeedbackServiceImpl)
      │
      ▼
Repository Layer (SurveySessionRepository, SurveyResponseRepository, QrCodeRepository...)
      │
      ▼
Storage (In-Memory ConcurrentHashMap Store trên RAM)
```

### 1.1. Controller Layer
- **`SurveyController.java`** (`com.cxshield.backend.controller`):
  - Định tuyến gốc: `@RequestMapping("/api/v1/surveys")`
  - Đóng vai trò là REST API controller công khai tiếp nhận các yêu cầu từ khách quét mã QR tại bàn/khu vực.
  - Các hàm phụ trách:
    - `scanQr(code, request)`: Nhận diện mã QR, lấy IP (`request.getRemoteAddr()`) và `User-Agent`.
    - `submitRating(requestDto)`: Tiếp nhận số sao đánh giá (1–5) và `sessionId`.
    - `recordPublicBypass(requestDto)`: Tiếp nhận chuyển hướng đánh giá công khai (chống review gating).
    - `getSession(sessionId)`: Trả về thông tin phiên khảo sát.

### 1.2. Service Layer
- **`SurveyService.java`** & **`SurveyServiceImpl.java`** (`com.cxshield.backend.service.impl`):
  - Thực thi toàn bộ quy tắc nghiệp vụ (Business Logic):
    - Nhận diện hoặc tự động tạo mã QR fallback nếu chưa tồn tại (nhằm bảo đảm thời gian tải tức thì < 1s).
    - Tạo phiên khảo sát mới với trạng thái ban đầu `STARTED`.
    - Kiểm tra tính hợp lệ của số sao (từ 1 đến 5 sao) và `sessionId`.
    - Cập nhật phiên sang `COMPLETED`, lưu kết quả đánh giá vào `SurveyResponse`.
    - Phân luồng cảm xúc:
      - 4–5 sao: Nhóm `POSITIVE`, điều hướng sang màn hình `M1-02` (Google Maps).
      - 2–3 sao: Nhóm `NEGATIVE`, điều hướng sang màn hình `M1-04` (Form góp ý riêng nội bộ).
      - 1 sao: Nhóm `NEGATIVE`, điều hướng sang `M1-04` kèm cờ `allowUrgentCall = true` và số hotline để kích hoạt hỗ trợ khẩn tại bàn hoặc yêu cầu quản lý gọi lại (`M1-05`).

### 1.3. Repository Layer
- **`SurveySessionRepository.java`**: Lưu trữ và truy xuất các đối tượng `SurveySession`.
- **`SurveyResponseRepository.java`**: Lưu trữ và truy xuất các đối tượng `SurveyResponse`.
- **`QrCodeRepository.java`**: Quản lý dữ liệu mã QR (đã nạp sẵn mã mẫu `MC-B04` cho Bàn 04).
- **`BranchRepository.java`**: Quản lý thông tin chi nhánh (nạp sẵn Chi nhánh Quận 1 - Đồng Khởi).
- **`BusinessRepository.java`**: Quản lý thông tin cơ sở (nạp sẵn Maison Coffee & Bistro).
- **`ReviewPlatformRepository.java`**: Quản lý thông tin nền tảng đánh giá (nạp sẵn Google Maps của cơ sở).

### 1.4. Entity & DTO Layer
- **Entity**:
  - `SurveySession`: POJO đại diện phiên khảo sát (`id`, `qrCodeId`, `branchId`, `tableOrAreaCode`, `status`, `startedAt`, `completedAt`...).
  - `SurveyResponse`: POJO đại diện kết quả đánh giá (`id`, `sessionId`, `starRating`, `sentimentGroup`, `isPublicBypass`, `ratedAt`...).
  - *Lưu ý:* Cả hai Entity đều là Java Class thuần túy, không có JPA annotation (`@Entity`, `@Table`, `@Id`).
- **DTO**:
  - `RateRequestDto`: Dữ liệu gửi đánh giá (`sessionId`, `starRating`).
  - `RateResultDto`: Kết quả trả về sau đánh giá (`responseId`, `sessionId`, `starRating`, `sentimentGroup`, `targetScreen`, `allowUrgentCall`, `hotline`).
  - `SurveyInitResponseDto`: Dữ liệu khởi tạo hiển thị cho khách (`sessionId`, `qrCode`, `businessName`, `branchName`, `tableOrAreaCode`, `hotline`...).
  - `ApiResponse<T>`: Cấu trúc bọc JSON chuẩn (`success`, `message`, `data`, `timestamp`).

### 1.5. Security Layer
- **`SecurityConfig.java`**:
  - Cấu hình bảo mật phân quyền:
    ```java
    .requestMatchers("/api/v1/surveys/**", "/api/v1/feedbacks/**").permitAll()
    .requestMatchers("/api/**").authenticated()
    ```
  - Mọi API khảo sát khách hàng mở qua QR đều là **Public**, cho phép gọi trực tiếp mà không cần cung cấp token xác thực (JWT).

---

## 2. Luồng xử lý dữ liệu: QR → Survey Session → Rating → Survey Response

1. **Khách quét mã QR (`GET /api/v1/surveys/qr/{code}`):**
   - Client gửi mã QR trên URL (ví dụ: `MC-B04`).
   - `SurveyServiceImpl.getOrInitSession()` tìm kiếm mã trong `QrCodeRepository`.
     - *Nếu tìm thấy:* Lấy thông tin `branchId`.
     - *Nếu không tìm thấy (mã mới):* Tự động khởi tạo một `QrCode` mới gắn với chi nhánh mẫu mặc định (`b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22`) và lưu lại vào repository.
   - Service truy vấn thông tin Chi nhánh từ `BranchRepository` và Cơ sở từ `BusinessRepository`.
   - Service tạo mới một `SurveySession` với `status = "STARTED"`, gán `startedAt = now()`, lưu vào `SurveySessionRepository`.
   - Trả về payload chứa `sessionId`, tên thương hiệu, tên chi nhánh, vị trí bàn để hiển thị màn hình chọn sao `M1-01`.

2. **Khách chọn sao và gửi đánh giá (`POST /api/v1/surveys/rate`):**
   - Client gửi payload JSON gồm `sessionId` và `starRating` (từ 1 đến 5).
   - `SurveyServiceImpl.submitRating()` tiến hành kiểm tra:
     - `sessionId != null` (nếu null ném `IllegalArgumentException`).
     - `1 <= starRating <= 5` (nếu ngoài khoảng ném `IllegalArgumentException`).
     - `sessionId` có tồn tại trong `SurveySessionRepository` hay không (nếu không ném `IllegalArgumentException`).
   - Cập nhật phiên khảo sát: `status = "COMPLETED"`, `completedAt = now()`, cập nhật vào `SurveySessionRepository`.
   - Khởi tạo thực thể `SurveyResponse`:
     - Gán `sessionId`, `starRating`, `ratedAt = now()`.
     - Phân loại `sentimentGroup = (starRating >= 4) ? "POSITIVE" : "NEGATIVE"`.
     - Lưu đối tượng vào `SurveyResponseRepository`.
   - Xác định màn hình điều hướng tiếp theo:
     - 4 hoặc 5 sao: `targetScreen = "M1-02"`, `allowUrgentCall = false`.
     - 2 hoặc 3 sao: `targetScreen = "M1-04"`, `allowUrgentCall = false`.
     - 1 sao: `targetScreen = "M1-04"`, `allowUrgentCall = true` kèm số `hotline`.
   - Trả về `RateResultDto` cho client.

---

## 3. Danh sách các API Endpoint liên quan

| Method | Endpoint đầy đủ | Tham số | Dữ liệu trả về (Data) | Authentication |
| :--- | :--- | :--- | :--- | :--- |
| `GET` | `/api/v1/surveys/qr/{code}` | Path: `code` | `SurveyInitResponseDto` (`sessionId`, `branchName`...) | Public (`permitAll`) |
| `POST` | `/api/v1/surveys/rate` | Body: `RateRequestDto` | `RateResultDto` (`responseId`, `targetScreen`...) | Public (`permitAll`) |
| `GET` | `/api/v1/surveys/session/{sessionId}` | Path: `sessionId` | `SurveySession` chi tiết | Public (`permitAll`) |
| `POST` | `/api/v1/surveys/public-review` | Body: `PublicBypassRequestDto` | `PublicBypassResponseDto` (Link Google Maps) | Public (`permitAll`) |
| `POST` | `/api/v1/feedbacks` | Body: `FeedbackRequestDto` | `FeedbackResponseDto` (`feedbackId`, `targetScreen: M1-06`) | Public (`permitAll`) |
| `GET` | `/api/v1/feedbacks/topics` | Không | Danh sách chủ đề góp ý | Public (`permitAll`) |

---

## 4. Cơ chế lưu trữ dữ liệu thực tế: In-Memory hay Database?

### 4.1. Hiện trạng thực tế trong mã nguồn
Qua kiểm tra chi tiết các lớp Repository:
- Trong `SurveySessionRepository.java`:
  ```java
  private final Map<UUID, SurveySession> store = new ConcurrentHashMap<>();
  ```
- Trong `SurveyResponseRepository.java`:
  ```java
  private final Map<UUID, SurveyResponse> store = new ConcurrentHashMap<>();
  ```
- Trong `pom.xml`: Dự án không có Spring Data JPA starter hay Hibernate.
- **KẾT LUẬN:** Toàn bộ dữ liệu của `SurveySession` và `SurveyResponse` hiện tại **được lưu trong bộ nhớ RAM (In-Memory)** thông qua biến `ConcurrentHashMap` trong Spring Singleton Bean.

### 4.2. So sánh với kịch bản CSDL SQL
Trong thư mục `database/n1_khao_sat.sql`, định nghĩa bảng `survey_sessions` và `survey_responses` đã được chuẩn bị đầy đủ bằng câu lệnh PostgreSQL DDL. Tuy nhiên, backend Java hiện tại chưa kết nối hay gọi lệnh INSERT/UPDATE xuống cơ sở dữ liệu Supabase/PostgreSQL cho 2 bảng này.

### 4.3. Đánh giá ưu nhược điểm kỹ thuật
- **Ưu điểm:** Tốc độ phản hồi cực nhanh (dưới vài chục mili-giây), đáp ứng vượt trội chỉ tiêu tải trang khảo sát < 1 giây của User Story E1.1.
- **Nhược điểm:** Dữ liệu hoàn toàn biến mất khi server Spring Boot khởi động lại (restart/redeploy). Không thể scale ngang đa instance nếu không có cơ chế chia sẻ session tập trung.

---

## 5. Phân tích lỗi BUG-01 và các rủi ro kỹ thuật

### 5.1. BUG-01: Thiếu cơ chế chống gửi đánh giá trùng lặp (Idempotency Flaw)
- **Vị trí mã nguồn:** `backend/src/main/java/com/cxshield/backend/service/impl/SurveyServiceImpl.java` (dòng 113–133).
- **Phân tích:**
  - Khi phương thức `submitRating` được gọi, nó tìm kiếm session bằng `surveySessionRepository.findById(requestDto.getSessionId())`.
  - Nếu tìm thấy, service lập tức gán `session.setStatus("COMPLETED")` và tạo mới một đối tượng `SurveyResponse` rồi lưu vào repository.
  - **Lỗ hổng:** Service **hoàn toàn không kiểm tra** trạng thái hiện tại của session. Nếu session vốn đã ở trạng thái `COMPLETED` từ trước, service vẫn cho phép ghi nhận và tạo thêm một bản ghi `SurveyResponse` mới.
- **Hành vi lý thuyết:** Khách hàng hoặc công cụ tự động có thể gửi đánh giá nhiều lần liên tiếp trên cùng một phiên quét mã QR, làm sai lệch kết quả báo cáo và số liệu đánh giá.
- **Tình trạng:** Phát hiện thông qua rà soát mã nguồn (Code Review). Cần thực hiện kiểm thử tự động trên môi trường chạy thực tế để xác nhận hành vi phản hồi của hệ thống.

### 5.2. RỦI RO 01 (RISK-01): Thiếu cơ chế kiểm tra thời gian hết hạn phiên (Session Expiration)
- **Vị trí mã nguồn:** `SurveyServiceImpl.java` (dòng 114).
- **Phân tích:** Thông báo ngoại lệ hiển thị: `"Phiên khảo sát không tồn tại hoặc đã hết hạn"`. Tuy nhiên, trong mã nguồn không hề có thuộc tính hoặc logic kiểm tra TTL (Time-To-Live). Một phiên được tạo ra bao lâu cũng có thể gửi đánh giá mà không bị từ chối do hết hạn.

### 5.3. RỦI RO 02 (RISK-02): Nguy cơ rò rỉ bộ nhớ (Memory Leak / Resource Exhaustion)
- **Vị trí mã nguồn:** `SurveyServiceImpl.java` (dòng 58–71), `SurveySessionRepository.java`, `QrCodeRepository.java`.
- **Phân tích:**
  - Mỗi lần quét mã QR lạ, hệ thống tự động sinh một đối tượng `QrCode` mới và đưa vào `codeIndex`/`store`.
  - Mỗi lần truy cập hợp lệ, một `SurveySession` mới được nạp vào RAM.
  - Do không có cơ chế dọn dẹp bộ nhớ (eviction policy, TTL cache, hay giới hạn dung lượng Map), nếu hệ thống nhận lượng lớn request quét QR (hoặc bị crawl bot quét), dung lượng RAM của backend sẽ tăng dần và có nguy cơ gây lỗi `OutOfMemoryError`.

### 5.4. LỖI BỔ SUNG: Xử lý ngoại lệ 404 bị chuyển thành HTTP 500
- **Vị trí mã nguồn:** `backend/src/main/java/com/cxshield/backend/common/GlobalExceptionHandler.java` (dòng 64–69).
- **Phân tích:**
  - `GlobalExceptionHandler` bắt ngoại lệ tổng quát `@ExceptionHandler(Exception.class)` và trả về mã lỗi `HttpStatus.INTERNAL_SERVER_ERROR` (500).
  - Khi người dùng gọi vào một URL không tồn tại (ví dụ: `GET /api/v1/surveys`), Spring Boot 4.0 ném `NoResourceFoundException`. Do không có handler riêng cho lỗi 404 và không kế thừa `ResponseEntityExceptionHandler`, lỗi này bị handler tổng bắt lấy và chuyển thành HTTP 500.

---

## 6. Những điểm cần xác minh thêm trong quá trình kiểm thử

1. **Kiểm chứng thực tế BUG-01:** Cần chạy kịch bản gửi request `POST /api/v1/surveys/rate` lần thứ 2 với cùng một `sessionId` đã `COMPLETED` trên backend đang chạy để ghi nhận mã phản hồi và xác minh xem có tạo thêm bản ghi hay không.
2. **Đo đạc hiệu năng thời gian đáp ứng (< 1s):** Đo thời gian phản hồi thực tế từ khi gửi `GET /api/v1/surveys/qr/{code}` đến khi nhận được dữ liệu hoàn tất trên mạng cục bộ và qua môi trường CI.
3. **Kế hoạch đồng bộ CSDL:** Xác nhận với đội ngũ phát triển về lộ trình chuyển đổi từ lưu trữ RAM sang lưu trữ CSDL Supabase/PostgreSQL để chuẩn bị kế hoạch kiểm thử cho các sprint tiếp theo.
