# BỘ TEST CASES KIỂM THỬ MÃ NGUỒN VÀ API CONTRACT GOOGLE PLACE ID (SCRUM-196)

- **Mã Jira:** SCRUM-196
- **Tên User Story:** [E4.1] Kiểm thử mã nguồn và API contract Google Place ID
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Công cụ kiểm thử:** JUnit 5, Mockito, Spring Boot Test (`@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc`, `MockRestServiceServer`)
- **Tệp thực thi chính:** `GooglePlaceContractSecurityTest.java` (18 automation tests)
- **Phạm vi kiểm thử:**
  - Backend source code: `GooglePlaceController`, `GooglePlaceService`, `PlaceIdParser`, `GooglePlacesClient`, `ReviewPlatformRepository`
  - Unit test nhánh thành công và thất bại
  - Mock Google Places API (New) upstream
  - Branch-level Authorization & Security response (Supabase JWT / MockMvc)
  - API Contract (HTTP method, endpoint, request/response schema, status code, error format)
  - Rate Limiting verification
  - Branch ID / Place ID mapping integrity
- **Phân định ranh giới nghiệp vụ:**
  - **SCRUM-194:** Đã kiểm thử API qua Postman Mock Server (`127.0.0.1:8089`).
  - **SCRUM-195:** Đã kiểm thử chức năng giao diện người dùng Flutter (Widget Test trên màn hình D3-05).
  - **SCRUM-196:** Tập trung 100% vào source code Java backend, kiểm thử đơn vị, kiểm thử tích hợp nội bộ với MockMvc và xác thực API Contract. Không lặp lại Postman hay Flutter Widget test.

---

## I. Bảng tổng hợp hiện trạng kiểm thử (Coverage & Execution Matrix)

> [!IMPORTANT]
> **LƯU Ý VỀ PHÂN QUYỀN CƠ SỞ (BRANCH AUTHORIZATION):**
> Các test phân quyền chi nhánh (`TC-196-04`, `TC-196-05`) được thực hiện bằng cách mock `GooglePlaceService` trả lỗi `ApiException.notFound` (404) và `ApiException.forbidden` (403), nhằm kiểm định hợp đồng API và phản hồi bảo mật của controller/filter. Cơ chế **Live Supabase PostgreSQL RLS thật chưa được kiểm chứng trực tiếp** trên database sản xuất (Live RLS: **NOT RUN**).

| Test ID | Tên kịch bản kiểm thử | Automation Test Method tương ứng | Kết quả Test Case | Kết quả Automation | Ghi chú kỹ thuật |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `TC-196-01` | Chặn 401 khi GET cấu hình mà không có JWT token | `getWithoutTokenReturns401()` | **PASS** | **PASS** | 401 Unauthorized khi thiếu header Authorization |
| `TC-196-02` | Chặn 401 khi POST xác minh mà không có JWT token | `verifyWithoutTokenReturns401()` | **PASS** | **PASS** | 401 Unauthorized khi thiếu header Authorization |
| `TC-196-03` | Chặn 401 khi PUT lưu cấu hình mà không có JWT token | `saveWithoutTokenReturns401()` | **PASS** | **PASS** | 401 Unauthorized khi thiếu header Authorization |
| `TC-196-04` | Trả về 404 BRANCH_NOT_FOUND khi truy cập chi nhánh ngoài phạm vi | `getForInaccessibleBranchReturns404()` | **PASS** | **PASS** | API contract/security response test (Live RLS: NOT RUN) |
| `TC-196-05` | Trả về 403 FORBIDDEN khi user không có quyền quản trị chi nhánh | `saveForbiddenWhenUserLacksManagementPermission()` | **PASS** | **PASS** | API contract/security response test (Live RLS: NOT RUN) |
| `TC-196-06` | API Contract GET cấu hình trả về đúng schema và HTTP 200 | `getConfigReturnsValidSchemaAnd200()` | **PASS** | **PASS** | 200 OK, khớp schema `GooglePlaceConfigResponse` |
| `TC-196-07` | Trả về 400 BAD_REQUEST khi branchId không phải UUID hợp lệ | `getWithInvalidUuidReturns400()` | **PASS** | **PASS** | 400 Bad Request, code `BAD_REQUEST` |
| `TC-196-08` | Xác minh Place ID rỗng trả về 400 VALIDATION_ERROR | `verifyWithEmptyPlaceIdReturnsValidationError()` | **PASS** | **PASS** | 400 Bad Request, code `VALIDATION_ERROR`, `@Valid` chặn |
| `TC-196-09` | Xác minh Place ID sai định dạng trả về 400 INVALID_PLACE_ID | `verifyWithInvalidFormatReturnsInvalidPlaceId()` | **PASS** | **PASS** | 400 Bad Request, code `INVALID_PLACE_ID`, không gọi Google API |
| `TC-196-10` | Xác minh thành công khi Google API trả về địa điểm tồn tại | `verifyPlaceFoundReturnsConnected()` | **PASS** | **PASS** | 200 OK, `CONNECTED`, `verifiedWithGoogle=true`, đủ name/address |
| `TC-196-11` | Xác minh trả về ERROR khi Google API không tìm thấy địa điểm | `verifyPlaceNotFoundReturnsErrorStatus()` | **PASS** | **PASS** | 200 OK, `ERROR`, `verifiedWithGoogle=true`, reviewUrl=null |
| `TC-196-12` | Xác minh trả về PENDING khi Google API lỗi mạng/timeout/5xx | `verifyPlaceUnavailableReturnsPendingStatus()` | **PASS** | **PASS** | 200 OK, `PENDING`, `verifiedWithGoogle=false`, fallback URL |
| `TC-196-13` | Lưu cấu hình thành công trả về HTTP 200 và cấu hình đã đồng bộ | `saveConfigurationSuccess()` | **PASS** | **PASS** | 200 OK, `connectionStatus=CONNECTED`, cập nhật DB |
| `TC-196-14` | Từ chối lưu và trả về 422 PLACE_NOT_FOUND khi Google không thấy | `saveRejectsNotFoundPlaceWith422()` | **PASS** | **PASS** | 422 Unprocessable Content, không ghi dữ liệu vào DB |
| `TC-196-15` | Từ chối lưu và trả về 400 INVALID_REVIEW_URL khi link sai domain | `saveRejectsInvalidManualReviewUrlWith400()` | **PASS** | **PASS** | 400 Bad Request, code `INVALID_REVIEW_URL` (không thuộc Google) |
| `TC-196-16` | Đảm bảo branchId trên URL path được gán chính xác vào service | `verifyBranchIdDataIntegrity()` | **PASS** | **PASS** | Branch mapping chính xác, ngăn ngừa tráo đổi chi nhánh |
| `TC-196-17` | Xử lý exception không mong muốn trả về HTTP 500 format chuẩn | `unexpectedExceptionReturns500WithStandardFormat()` | **PASS** | **PASS** | 500 Internal Server Error, ApiResponse định dạng chuẩn |
| `TC-196-18` | Kiểm tra Rate Limiting trên các endpoint Google Place | `rateLimitingVerificationShowsNotImplemented()` | **FAIL (Gap)** | **PASS (Proof)** | Gửi 10 request tuần tự đều 200 OK; backend CHƯA có Rate Limiter |

- **Tổng số Test Cases thiết kế:** **18**
- **Test Case PASS:** **17** (94.4%)
- **Test Case FAIL:** **1** (`TC-196-18` – Rate Limiting chưa triển khai trong mã nguồn backend)
- **Automation mới:** **18/18 PASS** (test số 18 PASS vì đã kiểm chứng và tái hiện được hiện trạng thiếu Rate Limiter)
- **Regression tests:** **46/46 PASS**
- **Tổng automation tests trong gói Funnel:** **64/64 PASS**
- **BLOCKED:** **0** | **NOT RUN:** **0**

---

## II. Chi tiết 18 Test Cases đồng bộ 1:1 với Automation Test Suite

### TC-196-01: Chặn 401 khi GET cấu hình mà không có JWT token
- **Mục tiêu:** Xác minh Spring Security chặn request không có token Bearer JWT.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.getWithoutTokenReturns401()`
- **Các bước thực hiện:**
  1. Gửi request GET không kèm header `Authorization`.
  2. Xác minh `googlePlaceService.getConfig` không được gọi.
- **Kết quả kỳ vọng:** HTTP Status `401 Unauthorized`.
- **Kết quả thực tế:** HTTP 401 Unauthorized.
- **Trạng thái:** **PASS**.

---

### TC-196-02: Chặn 401 khi POST xác minh mà không có JWT token
- **Mục tiêu:** Xác minh endpoint xác minh yêu cầu xác thực người dùng.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyWithoutTokenReturns401()`
- **Request Body:** `{"placeId":"ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Kết quả kỳ vọng:** HTTP Status `401 Unauthorized`.
- **Kết quả thực tế:** HTTP 401 Unauthorized.
- **Trạng thái:** **PASS**.

---

### TC-196-03: Chặn 401 khi PUT lưu cấu hình mà không có JWT token
- **Mục tiêu:** Xác minh endpoint lưu cấu hình bắt buộc xác thực người dùng.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.saveWithoutTokenReturns401()`
- **Request Body:** `{"placeId":"ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Kết quả kỳ vọng:** HTTP Status `401 Unauthorized`.
- **Kết quả thực tế:** HTTP 401 Unauthorized.
- **Trạng thái:** **PASS**.

---

### TC-196-04: Trả về 404 BRANCH_NOT_FOUND khi người dùng truy cập chi nhánh ngoài phạm vi cho phép
- **Mục tiêu:** Xác minh API contract và phản hồi lỗi khi truy cập chi nhánh không có quyền hoặc không tồn tại.
- **Endpoint & Method:** `GET /api/v1/branches/{otherBranchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.getForInaccessibleBranchReturns404()`
- **Phạm vi kiểm thử:** API contract / security response test tại tầng controller/mockmvc với mock service ném `ApiException.notFound("BRANCH_NOT_FOUND", ...)`. *(Cơ chế Live Supabase RLS: NOT RUN).*
- **Kết quả kỳ vọng:**
  - HTTP Status: `404 Not Found`.
  - Body JSON: `code = "BRANCH_NOT_FOUND"`, `message = "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."`.
- **Kết quả thực tế:** HTTP 404 Not Found, đúng format lỗi chuẩn.
- **Trạng thái:** **PASS**.

---

### TC-196-05: Trả về 403 FORBIDDEN khi người dùng không có quyền quản trị chi nhánh để lưu cấu hình
- **Mục tiêu:** Xác minh phản hồi lỗi khi người dùng không đủ quyền thực hiện thao tác lưu (như role Staff).
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.saveForbiddenWhenUserLacksManagementPermission()`
- **Phạm vi kiểm thử:** API contract / security response test tại tầng controller/mockmvc với mock service ném `ApiException.forbidden(...)`. *(Cơ chế Live Supabase RLS: NOT RUN).*
- **Kết quả kỳ vọng:**
  - HTTP Status: `403 Forbidden`.
  - Body JSON: `code = "FORBIDDEN"`, `message = "Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."`.
- **Kết quả thực tế:** HTTP 403 Forbidden, đúng format lỗi chuẩn.
- **Trạng thái:** **PASS**.

---

### TC-196-06: API Contract GET cấu hình trả về đúng schema và HTTP 200
- **Mục tiêu:** Xác minh cấu trúc dữ liệu JSON trả về của endpoint GET cấu hình chi nhánh.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.getConfigReturnsValidSchemaAnd200()`
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Schema đầy đủ: `branchId`, `branchName`, `placeId`, `placeName`, `placeAddress`, `reviewUrl`, `connectionStatus`, `updatedAt`, `googleVerificationEnabled`.
- **Kết quả thực tế:** Khớp 100% schema và kiểu dữ liệu.
- **Trạng thái:** **PASS**.

---

### TC-196-07: Trả về 400 BAD_REQUEST khi branchId không phải định dạng UUID hợp lệ
- **Mục tiêu:** Xác minh validation định dạng PathVariable `branchId`.
- **Endpoint & Method:** `GET /api/v1/branches/not-a-valid-uuid/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.getWithInvalidUuidReturns400()`
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Body JSON: `code = "BAD_REQUEST"`, `message = "Yêu cầu không hợp lệ."`.
- **Kết quả thực tế:** Bắt lỗi type mismatch chính xác, trả về HTTP 400.
- **Trạng thái:** **PASS**.

---

### TC-196-08: Xác minh Place ID rỗng trả về 400 VALIDATION_ERROR
- **Mục tiêu:** Kiểm tra `@Valid` và `@NotBlank` trên body của endpoint xác minh.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyWithEmptyPlaceIdReturnsValidationError()`
- **Request Body:** `{"placeId": ""}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Body JSON: `code = "VALIDATION_ERROR"`, `fieldErrors.placeId = "Vui lòng nhập Google Place ID."`.
- **Kết quả thực tế:** Controller chặn trước khi gọi service.
- **Trạng thái:** **PASS**.

---

### TC-196-09: Xác minh Place ID sai định dạng (quá ngắn/chứa ký tự lạ) trả về 400 INVALID_PLACE_ID
- **Mục tiêu:** Kiểm tra kiểm tra định dạng regex base64url trong `PlaceIdParser`.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyWithInvalidFormatReturnsInvalidPlaceId()`
- **Request Body:** `{"placeId": "invalid_short_id"}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Body JSON: `code = "INVALID_PLACE_ID"`.
- **Kết quả thực tế:** Ném đúng mã `INVALID_PLACE_ID` và chặn gọi Google API.
- **Trạng thái:** **PASS**.

---

### TC-196-10: Xác minh thành công khi Google API trả về địa điểm tồn tại (CONNECTED)
- **Mục tiêu:** Kiểm tra luồng xác minh thành công khi Google Places API trả về `FOUND`.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyPlaceFoundReturnsConnected()`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Dữ liệu: `connectionStatus = "CONNECTED"`, `verifiedWithGoogle = true`, đầy đủ `placeName`, `placeAddress`, `reviewUrl`.
- **Kết quả thực tế:** Trả về HTTP 200 trạng thái `CONNECTED`.
- **Trạng thái:** **PASS**.

---

### TC-196-11: Xác minh trả về ERROR khi Google API không tìm thấy địa điểm (NOT_FOUND)
- **Mục tiêu:** Kiểm tra phản hồi khi Google thông báo không tìm thấy địa điểm (HTTP 404/400).
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyPlaceNotFoundReturnsErrorStatus()`
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Dữ liệu: `connectionStatus = "ERROR"`, `verifiedWithGoogle = true`, `reviewUrl = null`.
- **Kết quả thực tế:** Trả về HTTP 200 trạng thái `ERROR`.
- **Trạng thái:** **PASS**.

---

### TC-196-12: Xác minh trả về PENDING khi Google API gặp lỗi mạng/timeout/5xx (UNAVAILABLE)
- **Mục tiêu:** Kiểm tra phản hồi khi Google API gặp sự cố (5xx, 429, timeout, network error).
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyPlaceUnavailableReturnsPendingStatus()`
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Dữ liệu: `connectionStatus = "PENDING"`, `verifiedWithGoogle = false`, vẫn tự sinh `reviewUrl` dựa trên Place ID.
- **Kết quả thực tế:** Chuyển sang chế độ dự phòng `PENDING` trơn tru.
- **Trạng thái:** **PASS**.

---

### TC-196-13: Lưu cấu hình thành công trả về HTTP 200 và cấu hình đã đồng bộ
- **Mục tiêu:** Kiểm tra endpoint lưu cấu hình Place ID chi nhánh.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.saveConfigurationSuccess()`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Cấu hình phản hồi có `connectionStatus = "CONNECTED"`.
- **Kết quả thực tế:** Lưu và trả về HTTP 200 thành công.
- **Trạng thái:** **PASS**.

---

### TC-196-14: Từ chối lưu và trả về 422 PLACE_NOT_FOUND khi Google xác nhận địa điểm không tồn tại
- **Mục tiêu:** Đảm bảo không lưu dữ liệu không tồn tại vào cơ sở dữ liệu.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.saveRejectsNotFoundPlaceWith422()`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `422 Unprocessable Content`.
  - Body JSON: `code = "PLACE_NOT_FOUND"`, không có bản ghi nào được lưu vào DB.
- **Kết quả thực tế:** Chặn với HTTP 422, bảo vệ toàn vẹn dữ liệu.
- **Trạng thái:** **PASS**.

---

### TC-196-15: Từ chối lưu và trả về 400 INVALID_REVIEW_URL khi link thủ công không thuộc tên miền Google
- **Mục tiêu:** Xác minh whitelist tên miền Google cho link đánh giá nhập thủ công (`google.com`, `g.page`, `goo.gl`).
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.saveRejectsInvalidManualReviewUrlWith400()`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4", "reviewUrl": "https://phishing-site.com/review"}`
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Body JSON: `code = "INVALID_REVIEW_URL"`.
- **Kết quả thực tế:** Chặn với HTTP 400, từ chối link không thuộc Google.
- **Trạng thái:** **PASS**.

---

### TC-196-16: Đảm bảo branchId trên URL path được gán chính xác vào service, không bị tráo đổi cơ sở
- **Mục tiêu:** Xác minh tính toàn vẹn và cô lập dữ liệu chi nhánh khi controller chuyển giao tham số.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.verifyBranchIdDataIntegrity()`
- **Kết quả kỳ vọng:** `branchId` từ URL path được truyền đúng và duy nhất vào service; không bị tráo sang `otherBranchId`.
- **Kết quả thực tế:** Parameter mapping chính xác tuyệt đối.
- **Trạng thái:** **PASS**.

---

### TC-196-17: Xử lý exception không mong muốn trả về HTTP 500 với format ApiResponse lỗi chuẩn
- **Mục tiêu:** Xác minh `GlobalExceptionHandler` bắt ngoại lệ máy chủ chưa kiểm soát và trả về format `ApiResponse.error`.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Automation Method:** `GooglePlaceContractSecurityTest.unexpectedExceptionReturns500WithStandardFormat()`
- **Kết quả kỳ vọng:**
  - HTTP Status: `500 Internal Server Error`.
  - Body JSON: `{"success": false, "message": "Đã xảy ra lỗi máy chủ: ..."}`.
- **Kết quả thực tế:** Format lỗi chuẩn xác theo ApiResponse của dự án.
- **Trạng thái:** **PASS**.

---

### TC-196-18: Kiểm tra Rate Limiting - ghi nhận NOT IMPLEMENTED khi gửi nhiều request tuần tự
- **Mục tiêu:** Kiểm tra xem backend có áp dụng cơ chế Rate Limiting / Throttling để chống spam xác minh hay không.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Automation Method:** `GooglePlaceContractSecurityTest.rateLimitingVerificationShowsNotImplemented()`
- **Cách thức thực thi:** Test gửi 10 request tuần tự trong vòng lặp kiểm thử (không đo thời gian thực chính xác).
- **Kết quả kỳ vọng theo tiêu chuẩn an ninh:** Các request vượt ngưỡng cho phép phải bị từ chối với HTTP `429 Too Many Requests`.
- **Kết quả thực tế ghi nhận:**
  - Toàn bộ 10/10 request tuần tự đều được xử lý thành công với HTTP `200 OK`.
  - 0 request bị chặn với HTTP 429.
  - **Kết luận:** Backend hoàn toàn **CHƯA TRIỂN KHAI RATE LIMITING** tầng ứng dụng.
- **Trạng thái Test Case:** **FAIL (Architecture Gap / Observation)**.
- **Trạng thái Automation Test:** **PASS (Proof)** – Bài test tự động pass vì đã chứng minh và tái hiện chính xác lỗ hổng thiếu Rate Limiting.
