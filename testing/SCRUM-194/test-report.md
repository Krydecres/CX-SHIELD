# BÁO CÁO KẾT QUẢ KIỂM THỬ API GOOGLE PLACE ID (SCRUM-194)

- **Mã Jira:** SCRUM-194
- **Tên User Story:** [E4.1] Kiểm thử API Google Place ID bằng Postman
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Cài đặt Google Place ID theo chi nhánh)
- **Thời gian thực hiện:** 2026-11-16
- **Kỹ sư thực hiện:** QA Automation Engineer (CX-SHIELD Team)
- **Cấu hình môi trường thử nghiệm thực tế:**
  - Newman CLI v6.2.3 / Postman Runtime v11.0.0
  - Node.js v24.19.0 chạy Mock Server tại: `http://127.0.0.1:8089`
  - Java 21 LTS / Maven Surefire 3.5.4 (Backend Unit/Regression Test Suite)

---

> [!IMPORTANT]
> **TUYÊN BỐ PHẠM VI VÀ RANH GIỚI KIỂM THỬ (TESTING BOUNDARY DECLARATION):**
> 1. Toàn bộ 41 requests của bộ Postman Collection đã được thực thi bằng Newman trên **Node.js Mock Server (`http://127.0.0.1:8089`)**. Kết quả này chỉ đại diện cho mức **Kiểm thử Hợp đồng API Giả lập (Mock Contract & Scenario Testing)**.
> 2. **0 / 41 test cases** được xác minh trực tiếp bằng Newman trên Spring Boot backend thật (`localhost:8080`).
> 3. Không có JWT token thật của Supabase, không có kết nối cơ sở dữ liệu Supabase PostgreSQL thật, và không có cuộc gọi trực tiếp đến Google Places API thật trong lần chạy Newman này.
> 4. **Báo cáo này KHÔNG tuyên bố SCRUM-194 đã hoàn thành Live API Integration Testing.**

---

## 1. Tách biệt Ba Nhóm Kết quả Kiểm thử

Báo cáo phân tách rạch ròi 3 tầng bằng chứng độc lập, tuyệt đối không gộp chung số liệu:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│ A. Postman Mock Contract Testing (Newman CLI -> Node.js Mock Server: 8089)     │
│    • 41 requests executed | 77 assertions executed (log kỹ thuật ghi nhận)     │
│    • 40 kịch bản Mock Scenario PASS                                             │
│    • 1 kịch bản TC-GPLACE-RATE-01 FAIL (Thiếu Rate Limiter ở Backend source)    │
├─────────────────────────────────────────────────────────────────────────────────┤
│ B. Backend Java Unit & Regression Tests (Maven Surefire -> JVM Test Runner)      │
│    • 44 / 44 tests PASS (100% logic nội bộ, mockito repo, mock HTTP client)     │
│    • Tách riêng 4 test classes, hoàn toàn độc lập với Postman requests         │
├─────────────────────────────────────────────────────────────────────────────────┤
│ C. Live Backend API Integration Testing (Newman CLI -> Live Spring Boot: 8080)  │
│    • 0 / 41 test cases đã xác minh trực tiếp trên Backend thật                  │
│    • 41 / 41 test cases ở trạng thái NOT RUN / BLOCKED (cần môi trường live)    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Kết quả Chi tiết Từng Nhóm Kiểm thử

### A. Postman Mock Contract Testing (Thực thi qua Newman CLI)

- **Mục đích:** Xác minh tính đầy đủ của bộ sưu tập Postman (`cx_shield_scrum194_collection.json`), tính tương thích của các schema JSON, logic assertion bằng Chai BDD, và các luồng nghiệp vụ giả lập.
- **Môi trường:** `http://127.0.0.1:8089` (chạy qua `scratch/mock_server.js`).
- **Số liệu Newman CLI thực tế:**
  - Requests thực thi: **41 / 41**
  - Assertions thực thi: **77 / 77** (tất cả assertions định nghĩa trong script đều pass đối với response từ Mock Server).
  - Thời gian thực thi toàn bộ: **3.6 giây** (trung bình 3 ms/request).
- **Đánh giá nghiệp vụ:**
  - **40 Scenarios MOCK PASS:** Cấu trúc dữ liệu GET/POST/PUT, chuẩn hóa Place ID, validation đầu vào, mã lỗi HTTP giả lập (400, 401, 403, 404, 422) hoạt động đúng hợp đồng.
  - **1 Scenario FAIL – Missing Implementation (`TC-GPLACE-RATE-01`):** Mặc dù assertion của Newman nhận status 200 từ mock server, nhưng qua kiểm tra mã nguồn backend, **Spring Boot hoàn toàn chưa triển khai Rate Limiter tầng ứng dụng**. Do đó, về mặt nghiệp vụ kiểm thử chức năng, test case này được đánh giá là **FAIL (Lỗ hổng tính năng / Requirement Gap)**.

### B. Backend Java Unit & Regression Testing (Maven Surefire)

- **Mục đích:** Kiểm thử logic nghiệp vụ nội bộ của tầng Controller, Service, Parser và Client trong mã nguồn Spring Boot.
- **Lệnh thực thi:**
  ```bash
  mvn test -Dtest="GooglePlaceControllerTest,GooglePlacesClientTest,GooglePlaceServiceTest,PlaceIdParserTest"
  ```
- **Kết quả Surefire (44/44 PASS):**
  1. `GooglePlaceControllerTest`: **3 / 3 passed** (Kiểm tra Controller chuyển đúng token, branchId và DTO sang Service).
  2. `GooglePlacesClientTest`: **13 / 13 passed** (Kiểm tra client gọi REST với `MockRestServiceServer`, xử lý timeout, 403, 404, 429, 500 và PlaceStats).
  3. `GooglePlaceServiceTest`: **10 / 10 passed** (Kiểm tra logic nghiệp vụ với Mockito mock `AccountRepository` và `ReviewPlatformRepository`).
  4. `PlaceIdParserTest`: **18 / 18 passed** (Kiểm tra regex base64url, trích xuất `placeid=`, `place_id:`, và whitelist URL).
- **Lưu ý:** Đây là các Unit/Regression Tests chạy trên JVM với mock beans, **không phải là 44 Postman API tests**.

### C. Live Backend API Integration Testing (Spring Boot + Live DB)

- **Hiện trạng:** **0 / 41 Test Cases được thực thi trực tiếp trên Backend thật.**
- **Lý do chưa thực hiện (Prerequisites / Blockers):**
  1. **Authentication:** Backend cấu hình `NimbusJwtDecoder` với Supabase JWKS ES256 thật. Việc kiểm thử live đòi hỏi JWT token hợp lệ cấp từ Supabase Auth; token synthetic trong collection sẽ bị chặn 401 ngay từ tầng gateway.
  2. **Database & RLS:** Kiểm thử live yêu cầu chi nhánh mẫu và tài khoản mẫu có quyền tương ứng trong CSDL PostgreSQL để kiểm tra hàm `private.has_branch_access`.
  3. **Google API Key:** Backend để trống `cxshield.google.places-api-key`; việc kiểm thử live với Google yêu cầu cấu hình API key có quota hợp lệ.
- **Trạng thái ghi nhận:** **41 / 41 Test Cases ở trạng thái NOT RUN đối với Live Backend Verification.**

---

## 3. Bảng Đối chiếu Chi tiết 41 Test Cases

| STT | Mã Test Case | Endpoint & Phương thức | HTTP Kỳ vọng | Mock Result (Port 8089) | Real Backend (Port 8080) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 1 | `TC-GPLACE-POS-01` | `GET /api/v1/branches/{id}/google-place` | 200 OK | **MOCK PASS** (33ms) | **NOT RUN** |
| 2 | `TC-GPLACE-POS-02` | `GET /api/v1/branches/{unconfiguredId}/google-place` | 200 OK | **MOCK PASS** (5ms) | **NOT RUN** |
| 3 | `TC-GPLACE-POS-03` | `POST /api/v1/branches/{id}/.../verifications` | 200 OK | **MOCK PASS** (6ms) | **NOT RUN** |
| 4 | `TC-GPLACE-POS-04` | `POST /api/v1/branches/{id}/.../verifications` | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 5 | `TC-GPLACE-POS-05` | `POST /api/v1/branches/{id}/.../verifications` | 200 OK | **MOCK PASS** (5ms) | **NOT RUN** |
| 6 | `TC-GPLACE-POS-06` | `PUT /api/v1/branches/{id}/google-place` | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 7 | `TC-GPLACE-POS-07` | `PUT /api/v1/branches/{id}/google-place` | 200 OK | **MOCK PASS** (4ms) | **NOT RUN** |
| 8 | `TC-GPLACE-POS-08` | `PUT /api/v1/branches/{id}/google-place` | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 9 | `TC-GPLACE-VAL-01` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (5ms) | **NOT RUN** |
| 10 | `TC-GPLACE-VAL-02` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (3ms) | **NOT RUN** |
| 11 | `TC-GPLACE-VAL-03` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 12 | `TC-GPLACE-VAL-04` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 13 | `TC-GPLACE-VAL-05` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (3ms) | **NOT RUN** |
| 14 | `TC-GPLACE-VAL-06` | `PUT /api/v1/branches/{id}/google-place` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 15 | `TC-GPLACE-VAL-07` | `PUT /api/v1/branches/{id}/google-place` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 16 | `TC-GPLACE-VAL-08` | `PUT /api/v1/branches/{id}/google-place` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 17 | `TC-GPLACE-VAL-09` | `PUT /api/v1/branches/{id}/google-place` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 18 | `TC-GPLACE-VAL-10` | `PUT /api/v1/branches/{id}/google-place` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 19 | `TC-GPLACE-VAL-11` | `POST /api/v1/branches/{id}/.../verifications` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 20 | `TC-GPLACE-AUTH-01` | `GET /api/v1/branches/{id}/google-place` | 401 Unauthorized | **MOCK PASS** (1ms) | **NOT RUN** |
| 21 | `TC-GPLACE-AUTH-02` | `POST /api/v1/branches/{id}/.../verifications` | 401 Unauthorized | **MOCK PASS** (1ms) | **NOT RUN** |
| 22 | `TC-GPLACE-AUTH-03` | `PUT /api/v1/branches/{id}/google-place` | 401 Unauthorized | **MOCK PASS** (1ms) | **NOT RUN** |
| 23 | `TC-GPLACE-AUTH-04` | `GET /api/v1/branches/{id}/google-place` | 401 Unauthorized | **MOCK PASS** (1ms) | **NOT RUN** |
| 24 | `TC-GPLACE-PERM-01` | `GET /api/v1/branches/{nonExistentId}/...` | 404 Not Found | **MOCK PASS** (2ms) | **NOT RUN** |
| 25 | `TC-GPLACE-PERM-02` | `GET /api/v1/branches/{inaccessibleId}/...` | 404 Not Found | **MOCK PASS** (2ms) | **NOT RUN** |
| 26 | `TC-GPLACE-PERM-03` | `POST /api/v1/branches/{inaccessibleId}/...` | 404 Not Found | **MOCK PASS** (2ms) | **NOT RUN** |
| 27 | `TC-GPLACE-PERM-04` | `PUT /api/v1/branches/{inaccessibleId}/...` | 404 Not Found | **MOCK PASS** (2ms) | **NOT RUN** |
| 28 | `TC-GPLACE-PERM-05` | `PUT /api/v1/branches/{id}/google-place` (Staff) | 403 Forbidden | **MOCK PASS** (3ms) | **NOT RUN** |
| 29 | `TC-GPLACE-EXT-01` | `POST /api/v1/branches/{id}/...` (Google 404) | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 30 | `TC-GPLACE-EXT-02` | `PUT /api/v1/branches/{id}/google-place` (Google 404) | 422 Unprocessable | **MOCK PASS** (3ms) | **NOT RUN** |
| 31 | `TC-GPLACE-EXT-03` | `POST /api/v1/branches/{id}/...` (Google 500) | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 32 | `TC-GPLACE-EXT-04` | `PUT /api/v1/branches/{id}/google-place` (Google 500) | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 33 | `TC-GPLACE-EXT-05` | `POST /api/v1/branches/{id}/...` (No Key) | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 34 | `TC-GPLACE-EXT-06` | `PUT /api/v1/branches/{id}/google-place` (No Key) | 200 OK | **MOCK PASS** (1ms) | **NOT RUN** |
| 35 | `TC-GPLACE-RATE-01` | `POST /api/v1/branches/{id}/...` (Client Rate Limit) | 200 OK / 429 | **FAIL – Missing Impl** | **NOT RUN** |
| 36 | `TC-GPLACE-RATE-02` | `POST /api/v1/branches/{id}/...` (Google 429) | 200 OK | **MOCK PASS** (2ms) | **NOT RUN** |
| 37 | `TC-GPLACE-BND-01` | `GET /api/v1/branches/invalid-uuid/...` | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 38 | `TC-GPLACE-BND-02` | `POST /api/v1/branches/{id}/...` (20 chars) | 200 OK | **MOCK PASS** (3ms) | **NOT RUN** |
| 39 | `TC-GPLACE-BND-03` | `POST /api/v1/branches/{id}/...` (512 chars) | 200 OK | **MOCK PASS** (1ms) | **NOT RUN** |
| 40 | `TC-GPLACE-BND-04` | `POST /api/v1/branches/{id}/...` (513 chars) | 400 Bad Request | **MOCK PASS** (2ms) | **NOT RUN** |
| 41 | `TC-GPLACE-BND-05` | `POST /api/v1/branches/{id}/...` (No CType) | 200/400/415 | **MOCK PASS** (2ms) | **NOT RUN** |

---

## 4. Nhật ký Thực thi Newman CLI gốc trên Mock Server

```text
newman

CX-SHIELD - SCRUM-194: Google Place ID API Test Suite

□ 01. Positive Tests (Happy Path)
└ [TC-GPLACE-POS-01] GET Google Place Config - Chi nhánh đã có cấu hình
  GET http://127.0.0.1:8089/api/v1/branches/22222222-2222-2222-2222-222222222222/google-place [200 OK, 564B, 33ms]
  √  Status code is 200 OK
  √  Response has expected structure for configured branch

... [Các request 02 đến 40 thực thi trên Mock Server] ...

└ [TC-GPLACE-BND-05] POST Verify - Request Content-Type negotiation
  POST http://127.0.0.1:8089/api/v1/branches/22222222-2222-2222-2222-222222222222/google-place/verifications [200 OK, 503B, 2ms]
  √  Handles request properly (200 OK or 415/400)

┌─────────────────────────┬─────────────────┬─────────────────┐
│                         │        executed │          failed │
├─────────────────────────┼─────────────────┼─────────────────┤
│              iterations │               1 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│                requests │              41 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│            test-scripts │              41 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│      prerequest-scripts │               0 │               0 │
├─────────────────────────┼─────────────────┼─────────────────┤
│              assertions │              77 │               0 │
├─────────────────────────┴─────────────────┴─────────────────┤
│ total run duration: 3.6s                                    │
├─────────────────────────────────────────────────────────────┤
│ total data received: 9.87kB (approx)                        │
├─────────────────────────────────────────────────────────────┤
│ average response time: 3ms [min: 1ms, max: 33ms, s.d.: 4ms] │
└─────────────────────────────────────────────────────────────┘
Newman process finished with code 0 (Target: Mock Server at 127.0.0.1:8089)
```

---

## 5. Kết luận Về Hiện Trạng SCRUM-194

1. **Bộ sưu tập Postman Collection và Environment:** Đã được hoàn thiện đầy đủ, đạt chuẩn contract, có assertion Chai BDD chi tiết, sẵn sàng cho việc kiểm thử live khi có môi trường.
2. **Xác minh mã nguồn và Unit test:** Đã hoàn thành 44/44 tests Surefire cho các lớp xử lý nghiệp vụ nội bộ của Spring Boot.
3. **Khoảng cách triển khai (Implementation Gap):** Phát hiện endpoint xác minh Google Place ID chưa có Rate Limiter tầng ứng dụng để bảo vệ quota Google Cloud.
4. **Điều kiện để hoàn thành Live Integration:** Cần môi trường backend thật được khởi chạy kết nối với Supabase Auth (cấp JWT hợp lệ), Supabase DB (seed dữ liệu chi nhánh và RLS), và Google API Key test.
