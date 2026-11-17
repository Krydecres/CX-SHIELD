# TÀI LIỆU KỊCH BẢN THỰC THI KIỂM THỬ TỰ ĐỘNG (SCRUM-196)

- **Mã Jira:** SCRUM-196
- **Tên User Story:** [E4.1] Kiểm thử mã nguồn và API contract Google Place ID
- **Ngôn ngữ & Framework:** Java 21 LTS, Spring Boot 4.0.0, JUnit 5 Jupiter, Mockito, Spring Security Test, MockMvc, MockRestServiceServer
- **Build tool:** Apache Maven 3.9+
- **Thư mục mã nguồn test:** `backend/src/test/java/com/cxshield/backend/funnel/`

---

## 1. Danh sách các tệp kiểm thử tự động (Automation Test Files)

| STT | Tệp kiểm thử | Đường dẫn tệp | Loại kiểm thử | Số lượng test | Phạm vi & Trách nhiệm kiểm thử |
| :---: | :--- | :--- | :---: | :---: | :--- |
| **1** | `GooglePlaceContractSecurityTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/GooglePlaceContractSecurityTest.java` | **Integration & Contract Test (MockMvc)** | **18** | **Tệp test mới được phát triển cho SCRUM-196:**<br>- Xác thực Bearer JWT token (401)<br>- Phân quyền chi nhánh & RLS (404/403 mock contract)<br>- API Contract toàn bộ 3 endpoints GET/POST/PUT<br>- Input validation (400 `VALIDATION_ERROR`, `INVALID_PLACE_ID`, `INVALID_REVIEW_URL`)<br>- Xử lý kết quả Google API (`CONNECTED`, `ERROR`, `PENDING`)<br>- Xử lý lỗi 422 `PLACE_NOT_FOUND`<br>- Xử lý ngoại lệ 500 unhandled exception<br>- Kiểm chứng hiện trạng Rate Limiting (chứng minh chưa có) |
| **2** | `GooglePlaceServiceTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/GooglePlaceServiceTest.java` | Unit Test (Mockito) | 10 | Kiểm thử nghiệp vụ tầng Service: `getConfig`, `verify`, `save`, mapping data, xử lý RLS block. |
| **3** | `GooglePlacesClientTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/GooglePlacesClientTest.java` | Unit Test (MockRestServiceServer) | 13 | Mock lệnh gọi HTTP ra Google Places API New: 200 OK, 400/404 NOT_FOUND, 403/429/500 UNAVAILABLE, timeout/I/O exception. |
| **4** | `PlaceIdParserTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/PlaceIdParserTest.java` | Unit Test (Parameterized) | 18 | Kiểm thử regex chuẩn hoá Place ID, trích xuất ID từ link Google Maps dán vào, kiểm tra URL đánh giá hợp lệ. |
| **5** | `GooglePlaceControllerTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/GooglePlaceControllerTest.java` | Unit Test (Mockito) | 3 | Kiểm thử ủy quyền phương thức Controller sang Service với token và tham số. |
| **6** | `ReviewPlatformRepositoryTest.java` | `backend/src/test/java/com/cxshield/backend/funnel/ReviewPlatformRepositoryTest.java` | Unit Test (Mockito) | 2 | Kiểm thử tầng Repository tương tác bảng `review_platforms` qua Supabase Data Client. |

- **Tổng số tests trong bộ kiểm thử Funnel:** **64 tests**
- **Số tests mới phục vụ trọng tâm SCRUM-196:** **18 tests** (nằm trong `GooglePlaceContractSecurityTest.java`)
- **Số tests hồi quy (Regression tests):** **46 tests**

---

## 2. Danh mục 18 Automation Tests trong `GooglePlaceContractSecurityTest.java`

Đồng bộ chính xác 1:1 với 18 test cases thiết kế:

```java
// Package: com.cxshield.backend.funnel
// Class: GooglePlaceContractSecurityTest

1. getWithoutTokenReturns401()
   -> GET /api/v1/branches/{branchId}/google-place không token trả về HTTP 401 Unauthorized.

2. verifyWithoutTokenReturns401()
   -> POST /api/v1/branches/{branchId}/google-place/verifications không token trả về HTTP 401 Unauthorized.

3. saveWithoutTokenReturns401()
   -> PUT /api/v1/branches/{branchId}/google-place không token trả về HTTP 401 Unauthorized.

4. getForInaccessibleBranchReturns404()
   -> GET với branchId không có quyền hoặc không tồn tại trả về HTTP 404 mã "BRANCH_NOT_FOUND" (API contract/response test; Live RLS: NOT RUN).

5. saveForbiddenWhenUserLacksManagementPermission()
   -> PUT lưu cấu hình bởi user không có quyền quản lý trả về HTTP 403 mã "FORBIDDEN" (API contract/response test; Live RLS: NOT RUN).

6. getConfigReturnsValidSchemaAnd200()
   -> GET cấu hình thành công trả về HTTP 200 và JSON Schema khớp toàn bộ các trường của GooglePlaceConfigResponse.

7. getWithInvalidUuidReturns400()
   -> GET với branchId sai định dạng UUID trả về HTTP 400 Bad Request với mã "BAD_REQUEST".

8. verifyWithEmptyPlaceIdReturnsValidationError()
   -> POST xác minh với placeId rỗng bị chặn bởi @Valid, trả về HTTP 400 với mã "VALIDATION_ERROR".

9. verifyWithInvalidFormatReturnsInvalidPlaceId()
   -> POST xác minh với placeId sai format bị chặn bởi PlaceIdParser, trả về HTTP 400 với mã "INVALID_PLACE_ID".

10. verifyPlaceFoundReturnsConnected()
    -> POST xác minh khi Google tìm thấy địa điểm trả về HTTP 200, connectionStatus = "CONNECTED", verifiedWithGoogle = true.

11. verifyPlaceNotFoundReturnsErrorStatus()
    -> POST xác minh khi Google không tìm thấy địa điểm trả về HTTP 200, connectionStatus = "ERROR", reviewUrl = null.

12. verifyPlaceUnavailableReturnsPendingStatus()
    -> POST xác minh khi Google gặp lỗi 5xx/429/timeout trả về HTTP 200, connectionStatus = "PENDING", verifiedWithGoogle = false.

13. saveConfigurationSuccess()
    -> PUT lưu cấu hình hợp lệ trả về HTTP 200 và dữ liệu chi nhánh đã được cập nhật trạng thái "CONNECTED".

14. saveRejectsNotFoundPlaceWith422()
    -> PUT lưu cấu hình bị từ chối nếu địa điểm không tồn tại trên Google, trả về HTTP 422 Unprocessable Content mã "PLACE_NOT_FOUND".

15. saveRejectsInvalidManualReviewUrlWith400()
    -> PUT với đường dẫn reviewUrl thủ công không thuộc tên miền Google bị từ chối với HTTP 400 mã "INVALID_REVIEW_URL".

16. verifyBranchIdDataIntegrity()
    -> Xác minh branchId từ Path Variable được chuyển giao chính xác vào service, không bị tráo đổi dữ liệu đa cơ sở.

17. unexpectedExceptionReturns500WithStandardFormat()
    -> Ngoại lệ máy chủ chưa kiểm soát được bắt bởi GlobalExceptionHandler, trả về HTTP 500 theo schema ApiResponse chuẩn.

18. rateLimitingVerificationShowsNotImplemented()
    -> Gửi 10 request xác minh tuần tự trong vòng lặp kiểm thử (không đo thời gian thực chính xác); 10/10 đều nhận 200 OK, 0 request bị chặn 429 -> Bằng chứng tự động xác nhận backend chưa triển khai Rate Limiting.
```

---

## 3. Hướng dẫn chạy kiểm thử tự động (Execution Guide)

### 3.1. Yêu cầu môi trường
- JDK: OpenJDK / Temurin 21.0+
- Maven: 3.9+
- Biến môi trường: Không yêu cầu kết nối cơ sở dữ liệu thật hay API key Google thật (tất cả các client bên ngoài đều được cách ly và mock tự động qua `MockMvc`, `Mockito`, và `MockRestServiceServer`).

### 3.2. Lệnh chạy các bài kiểm thử mới của SCRUM-196
Để thực thi riêng 18 tests về Security, Authorization và API Contract:
```bash
mvn -f backend/pom.xml test "-Dtest=GooglePlaceContractSecurityTest"
```

### 3.3. Lệnh chạy toàn bộ 64 tests của phân hệ Google Place (Bao gồm Regression)
Để xác nhận tính toàn vẹn và không xảy ra lỗi hồi quy:
```bash
mvn -f backend/pom.xml test "-Dtest=GooglePlaceContractSecurityTest,GooglePlaceServiceTest,GooglePlacesClientTest,PlaceIdParserTest,GooglePlaceControllerTest,ReviewPlatformRepositoryTest"
```

### 3.4. Kết quả thực thi thực tế ghi nhận
```text
[INFO] Running com.cxshield.backend.funnel.GooglePlaceContractSecurityTest
[INFO] Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.708 s
[INFO] Running com.cxshield.backend.funnel.GooglePlaceControllerTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.011 s
[INFO] Running com.cxshield.backend.funnel.GooglePlacesClientTest
[INFO] Tests run: 13, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.177 s
[INFO] Running com.cxshield.backend.funnel.GooglePlaceServiceTest
[INFO] Tests run: 10, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.178 s
[INFO] Running com.cxshield.backend.funnel.PlaceIdParserTest
[INFO] Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.032 s
[INFO] Running com.cxshield.backend.funnel.ReviewPlatformRepositoryTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.055 s
[INFO] Results:
[INFO] Tests run: 64, Failures: 0, Errors: 0, Skipped: 0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  8.317 s
```
