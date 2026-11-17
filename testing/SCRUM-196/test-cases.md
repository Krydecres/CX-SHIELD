# BỘ TEST CASES KIỂM THỬ MÃ NGUỒN VÀ API CONTRACT GOOGLE PLACE ID (SCRUM-196)

- **Mã Jira:** SCRUM-196
- **Tên User Story:** [E4.1] Kiểm thử mã nguồn và API contract Google Place ID
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Công cụ kiểm thử:** JUnit 5, Mockito, Spring Boot Test (`@SpringBootTest`, `@AutoConfigureMockMvc`, `MockMvc`, `MockRestServiceServer`)
- **Phạm vi kiểm thử:**
  - Backend source code: `GooglePlaceController`, `GooglePlaceService`, `PlaceIdParser`, `GooglePlacesClient`, `ReviewPlatformRepository`
  - Unit test nhánh thành công và thất bại
  - Mock Google Places API (New) upstream
  - Branch-level Authorization & Security (Supabase JWT / PostgREST RLS)
  - API Contract (HTTP method, endpoint, request/response schema, status code, error format)
  - Rate Limiting verification
  - Branch ID / Place ID mapping integrity
- **Phân định ranh giới nghiệp vụ:**
  - **SCRUM-194:** Đã kiểm thử API qua Postman Mock Server (`127.0.0.1:8089`).
  - **SCRUM-195:** Đã kiểm thử chức năng giao diện người dùng Flutter (Widget Test trên màn hình D3-05).
  - **SCRUM-196:** Tập trung 100% vào source code Java backend, kiểm thử đơn vị, kiểm thử tích hợp nội bộ với MockMvc và xác thực API Contract. Không lặp lại Postman hay Flutter Widget test.

---

## I. Bảng tổng hợp hiện trạng kiểm thử (Coverage & Execution Matrix)

| Test ID | Tên kịch bản kiểm thử | Nhóm mục tiêu | Mức độ ưu tiên | Kết quả thiết kế | Kết quả Automation | Ghi chú kỹ thuật |
| :--- | :--- | :--- | :---: | :---: | :---: | :--- |
| `TC_SCRUM196_01` | Xác thực Place ID hợp lệ và địa điểm tồn tại | Happy Path | High | **PASS** | **PASS** | 200 OK, `CONNECTED`, trả về tên, địa chỉ và reviewUrl |
| `TC_SCRUM196_02` | Kiểm tra Place ID rỗng hoặc chỉ có khoảng trắng | Input Validation | High | **PASS** | **PASS** | 400 Bad Request, code `VALIDATION_ERROR` |
| `TC_SCRUM196_03` | Kiểm tra Place ID sai định dạng (<20 ký tự, ký tự lạ) | Format Validation | High | **PASS** | **PASS** | 400 Bad Request, code `INVALID_PLACE_ID`, không gọi Google API |
| `TC_SCRUM196_04` | Xử lý khi Google Places API trả về NOT_FOUND (404/400) | Upstream Error | High | **PASS** | **PASS** | 200 OK, `ERROR`, `verifiedWithGoogle=true`, reviewUrl=null |
| `TC_SCRUM196_05` | Xử lý khi Google Places API trả về lỗi client 4xx (403/429) | Upstream Error | Medium | **PASS** | **PASS** | 200 OK, fallback `PENDING`, `verifiedWithGoogle=false` |
| `TC_SCRUM196_06` | Xử lý khi Google Places API trả về lỗi server 5xx (500/503) | Upstream Error | Medium | **PASS** | **PASS** | 200 OK, fallback `PENDING`, `verifiedWithGoogle=false` |
| `TC_SCRUM196_07` | Xử lý khi kết nối Google Places API bị timeout hoặc lỗi mạng | Network Resilience | Medium | **PASS** | **PASS** | 200 OK, `PENDING`, `verifiedWithGoogle=false` |
| `TC_SCRUM196_08` | Phản hồi từ Google Places API thiếu dữ liệu (displayName null) | Data Handling | Low | **PASS** | **PASS** | Xử lý an toàn không phát sinh NullPointerException |
| `TC_SCRUM196_09` | Xử lý ngoại lệ không mong muốn tầng backend | Exception Handling | Medium | **PASS** | **PASS** | 500 Internal Server Error, ApiResponse định dạng chuẩn |
| `TC_SCRUM196_10` | Lưu cấu hình Place ID thành công và đồng bộ dữ liệu | Data Persistence | High | **PASS** | **PASS** | 200 OK, lưu `review_platforms` với đúng thông tin chi nhánh |
| `TC_SCRUM196_11` | Chặn lưu cấu hình khi địa điểm không tồn tại trên Google | Business Rule | High | **PASS** | **PASS** | 422 Unprocessable Content (`PLACE_NOT_FOUND`), không ghi DB |
| `TC_SCRUM196_12` | Chặn request không có Bearer Authentication token | Security / AuthN | Critical | **PASS** | **PASS** | 401 Unauthorized trên cả 3 endpoints GET/POST/PUT |
| `TC_SCRUM196_13` | Người dùng không có quyền quản trị cơ sở (Staff/Read-only) | Authorization (RBAC) | High | **PASS** | **PASS** | 403 Forbidden (`FORBIDDEN`) khi RLS chặn thao tác ghi |
| `TC_SCRUM196_14` | Người dùng truy cập cơ sở ngoài phạm vi cho phép | Branch Scope (RLS) | Critical | **PASS** | **PASS** | 404 Not Found (`BRANCH_NOT_FOUND`) ngăn rò rỉ dữ liệu chéo |
| `TC_SCRUM196_15` | Giới hạn tần suất request (Rate Limiting) | Security / Abuse | Medium | **FAIL (Gap)** | **PASS (Proof)** | **Backend CHƯA hiện thực Rate Limiting** (Gửi 10 req liên tiếp đều 200) |
| `TC_SCRUM196_16` | Kiểm định API Contract chi tiết (Methods, Routes, Schemas) | API Contract | High | **PASS** | **PASS** | Khớp chính xác contract đặc tả trong GooglePlaceDtos |
| `TC_SCRUM196_17` | Kiểm tra toàn vẹn mapping giữa branchId và Place ID | Data Integrity | High | **PASS** | **PASS** | branchId trên URL path được liên kết chuẩn xác, không tráo đổi |
| `TC_SCRUM196_18` | Kiểm thử hồi quy toàn bộ luồng tích hợp Google Place | Regression Testing | High | **PASS** | **PASS** | Toàn bộ 64 tests của gói funnel đều PASS 100% |

- **Tổng số Test Cases thiết kế:** 18
- **Số Test Cases Đạt yêu cầu nghiệp vụ hiện có:** 17 PASS
- **Số Test Cases Phát hiện thiếu sót (Gap / Bug):** 1 FAIL (`TC_SCRUM196_15` - Thiếu Rate Limiting)
- **Blocked:** 0 | **Not Run:** 0

---

## II. Chi tiết 18 Test Cases

### TC_SCRUM196_01: Xác thực Place ID hợp lệ và địa điểm tồn tại trên Google Places API
- **Mục tiêu:** Xác minh luồng xác minh (verifications) khi Place ID đúng định dạng base64url và Google Places API tìm thấy địa điểm (`FOUND`).
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Headers:** `Authorization: Bearer <valid_jwt>`, `Content-Type: application/json`
- **Request Body:**
  ```json
  {
    "placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"
  }
  ```
- **Các bước thực hiện:**
  1. Mock `GooglePlacesClient` trả về kết quả `PlaceLookup.found("Maison Central", "1 Lê Lợi, Q1")`.
  2. Gửi request POST xác minh với `branchId` hợp lệ.
  3. Kiểm tra mã phản hồi HTTP và dữ liệu JSON trả về.
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - JSON Schema:
    - `placeId`: `"ChIJN1t_tDeuEmsRUsoyG83frY4"`.
    - `placeName`: `"Maison Central"`.
    - `placeAddress`: `"1 Lê Lợi, Q1"`.
    - `reviewUrl`: `"https://search.google.com/local/writereview?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4"`.
    - `connectionStatus`: `"CONNECTED"`.
    - `verifiedWithGoogle`: `true`.
    - `message`: `"Đã xác minh địa điểm với Google."`.
- **Kết quả thực tế:** Khớp 100% kết quả kỳ vọng.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_02: Kiểm tra Place ID rỗng hoặc chỉ có khoảng trắng
- **Mục tiêu:** Xác minh validation tầng controller từ chối dữ liệu đầu vào rỗng trước khi xử lý nghiệp vụ.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Request Body:**
  ```json
  {
    "placeId": ""
  }
  ```
- **Các bước thực hiện:**
  1. Gửi request xác minh với trường `placeId` rỗng chuỗi.
  2. Quan sát phản hồi và xác minh `googlePlaceService.verify` không bao giờ được gọi.
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Mã lỗi nghiệp vụ: `"VALIDATION_ERROR"`.
  - Chi tiết lỗi trường: `fieldErrors.placeId` = `"Vui lòng nhập Google Place ID."`.
- **Kết quả thực tế:** Controller chặn với HTTP 400 và format lỗi chuẩn.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_03: Kiểm tra Place ID sai định dạng (<20 ký tự hoặc chứa ký tự đặc biệt)
- **Mục tiêu:** Xác minh `PlaceIdParser.normalize()` từ chối các chuỗi không khớp mẫu Regex `^[A-Za-z0-9_-]{20,512}$` mà không gọi Google API.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Request Body:** `{"placeId": "invalid_short_id"}`
- **Các bước thực hiện:**
  1. Gửi request với Place ID chỉ có 16 ký tự.
  2. Xác minh parser ném ngoại lệ `ApiException.badRequest("INVALID_PLACE_ID", ...)`.
  3. Đảm bảo Google Places Client không nhận bất kỳ lệnh gọi API nào.
- **Kết quả kỳ vọng:**
  - HTTP Status: `400 Bad Request`.
  - Mã lỗi nghiệp vụ: `"INVALID_PLACE_ID"`.
  - Google API call count: `0`.
- **Kết quả thực tế:** Ném đúng mã lỗi `INVALID_PLACE_ID` và chặn request thành công.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_04: Xử lý khi Google Places API trả về NOT_FOUND (404/400)
- **Mục tiêu:** Xác minh phản hồi khi Google thông báo không tìm thấy địa điểm tương ứng với Place ID.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Các bước thực hiện:**
  1. Mock Google Places API trả về HTTP 404 Not Found hoặc 400 Bad Request.
  2. `GooglePlacesClient` chuyển đổi thành `PlaceLookup.notFound()`.
  3. Kiểm tra phản hồi nghiệp vụ trả về cho client.
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK` (endpoint xác minh trả về trạng thái kiểm tra, không ném HTTP 404 của REST).
  - `connectionStatus`: `"ERROR"`.
  - `verifiedWithGoogle`: `true`.
  - `placeName`: `null`.
  - `reviewUrl`: `null`.
  - `message`: `"Google không tìm thấy địa điểm với Place ID này."`.
- **Kết quả thực tế:** Trả về HTTP 200 với trạng thái ERROR và thông báo rõ ràng.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_05: Xử lý khi Google Places API trả về lỗi client 4xx (403 Forbidden / 429 Too Many Requests)
- **Mục tiêu:** Xác minh cơ chế graceful degradation khi Google API từ chối phục vụ do sai API key, hết hạn mức hoặc bị rate limit từ Google.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Các bước thực hiện:**
  1. Mock Google Places API phản hồi HTTP 403 hoặc 429.
  2. `GooglePlacesClient` ghi log cảnh báo và trả về `PlaceLookup.unavailable()`.
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - `connectionStatus`: `"PENDING"`.
  - `verifiedWithGoogle`: `false`.
  - `reviewUrl`: Vẫn tự sinh link trực tiếp dựa trên Place ID đã nhập.
  - `message`: Chứa nội dung hướng dẫn thử lại sau.
- **Kết quả thực tế:** Hệ thống chuyển sang trạng thái chờ PENDING, không làm đứt đoạn quy trình cấu hình.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_06: Xử lý khi Google Places API trả về lỗi server 5xx (500 / 503)
- **Mục tiêu:** Xác minh hệ thống không bị crash khi máy chủ Google gặp sự cố nội bộ.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Các bước thực hiện:**
  1. Mock Google Places API phản hồi HTTP 500 Internal Server Error.
  2. Đánh giá cách xử lý ngoại lệ trong `GooglePlacesClient.lookup()`.
- **Kết quả kỳ vọng:**
  - `PlaceLookup.result()` nhận giá trị `UNAVAILABLE`.
  - Controller trả về HTTP 200 với `connectionStatus`: `"PENDING"`, `verifiedWithGoogle`: `false`.
- **Kết quả thực tế:** Hoạt động đúng thiết kế dự phòng.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_07: Xử lý khi kết nối Google Places API bị timeout hoặc lỗi mạng
- **Mục tiêu:** Kiểm tra khả năng chịu lỗi mạng (network resilience) khi gọi ra ngoài Internet.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Các bước thực hiện:**
  1. Mock RestClient ném `java.io.IOException: timeout` hoặc `ResourceAccessException`.
  2. Đảm bảo catch `RestClientException` bắt được lỗi và không để lỗi lan truyền lên client.
- **Kết quả kỳ vọng:**
  - `GooglePlacesClient` log cảnh báo `Không gọi được Google Places API: ...`.
  - Trả về `PlaceLookup.unavailable()`. Phản hồi cho client là 200 OK với trạng thái `PENDING`.
- **Kết quả thực tế:** Bắt ngoại lệ trơn tru, client nhận được trạng thái `PENDING`.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_08: Phản hồi từ Google Places API thiếu dữ liệu (displayName null hoặc thiếu text)
- **Mục tiêu:** Kiểm tra parser phản hồi Google Places xử lý an toàn các đối tượng JSON thiếu trường.
- **Thực thi:** Unit test trong `GooglePlacesClientTest.toleratesPlaceWithoutDisplayName()`.
- **Các bước thực hiện:**
  1. Mock phản hồi JSON từ Google: `{"id": "x"}` (không có `displayName`).
  2. Gọi `client.lookup(PLACE_ID)`.
- **Kết quả kỳ vọng:**
  - Lookup thành công với `Result.FOUND`.
  - `lookup.name()` là `null`, không văng `NullPointerException`.
- **Kết quả thực tế:** Null-safe check hoạt động chuẩn xác.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_09: Xử lý ngoại lệ không mong muốn tầng backend (Unhandled Exception)
- **Mục tiêu:** Đảm bảo khi phát sinh lỗi hệ thống không lường trước (như lỗi database kết nối đột ngột), `GlobalExceptionHandler` trả về JSON ApiResponse thống nhất.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Các bước thực hiện:**
  1. Mock `googlePlaceService.getConfig` ném `RuntimeException("Kết nối cơ sở dữ liệu bị gián đoạn đột ngột")`.
  2. Gửi request có token hợp lệ.
- **Kết quả kỳ vọng:**
  - HTTP Status: `500 Internal Server Error`.
  - JSON Body:
    ```json
    {
      "success": false,
      "message": "Đã xảy ra lỗi máy chủ: Kết nối cơ sở dữ liệu bị gián đoạn đột ngột"
    }
    ```
- **Kết quả thực tế:** Format lỗi chuẩn xác theo ApiResponse của dự án.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_10: Lưu cấu hình Place ID thành công và đồng bộ dữ liệu vào cơ sở dữ liệu
- **Mục tiêu:** Kiểm tra luồng lưu cấu hình chi nhánh qua endpoint PUT.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Request Body:**
  ```json
  {
    "placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4",
    "reviewUrl": null
  }
  ```
- **Các bước thực hiện:**
  1. Gửi request PUT với Place ID hợp lệ.
  2. Mock service thực hiện lưu thành công và trả về `GooglePlaceConfigResponse`.
- **Kết quả kỳ vọng:**
  - HTTP Status: `200 OK`.
  - Thông tin cấu hình trả về có `connectionStatus: "CONNECTED"`, `placeId` đúng giá trị gửi lên.
- **Kết quả thực tế:** Cấu hình được lưu và trả về thành công.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_11: Chặn lưu cấu hình khi địa điểm không tồn tại trên Google Places API
- **Mục tiêu:** Đảm bảo hệ thống không lưu dữ liệu rác/sai vào cơ sở dữ liệu nếu Google xác nhận địa điểm không tồn tại.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Request Body:** `{"placeId": "ChIJN1t_tDeuEmsRUsoyG83frY4"}`
- **Các bước thực hiện:**
  1. Mock Google Places Client trả về `NOT_FOUND`.
  2. Gửi request PUT lưu cấu hình.
  3. Xác minh repository `insert` và `update` không được gọi.
- **Kết quả kỳ vọng:**
  - HTTP Status: `422 Unprocessable Content`.
  - Mã lỗi nghiệp vụ: `"PLACE_NOT_FOUND"`.
  - Thông báo: `"Google không tìm thấy địa điểm với Place ID này."`.
  - Cơ sở dữ liệu: Không có bản ghi nào được ghi hay cập nhật.
- **Kết quả thực tế:** Trả về HTTP 422 và không có thao tác ghi DB nào diễn ra.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_12: Kiểm soát bảo mật: Request không có Authentication token
- **Mục tiêu:** Xác minh Spring Security chặn tất cả request không mang Supabase Bearer token trên toàn bộ các route của Google Place.
- **Endpoints kiểm thử:**
  - `GET /api/v1/branches/{branchId}/google-place`
  - `POST /api/v1/branches/{branchId}/google-place/verifications`
  - `PUT /api/v1/branches/{branchId}/google-place`
- **Các bước thực hiện:**
  1. Gửi request tới từng endpoint mà không đính kèm header `Authorization`.
  2. Kiểm tra phản hồi HTTP status code.
- **Kết quả kỳ vọng:** Cả 3 endpoint đều trả về HTTP `401 Unauthorized`.
- **Kết quả thực tế:** Spring Security chặn tại bộ lọc OAuth2 Resource Server, trả về 401.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_13: Phân quyền người dùng: User không có quyền quản lý chi nhánh (Staff/Read-only)
- **Mục tiêu:** Xác minh chính sách Row Level Security (RLS) chặn thao tác cập nhật bảng `review_platforms` khi user không có role OWNER hoặc BRANCH_MANAGER.
- **Endpoint & Method:** `PUT /api/v1/branches/{branchId}/google-place`
- **Các bước thực hiện:**
  1. Mock token của user có role Nhân viên (Staff).
  2. PostgREST áp dụng RLS chặn cập nhật và trả về danh sách rỗng (`List.of()`).
  3. `ReviewPlatformRepository.update()` trả về `Optional.empty()`.
  4. Service ném `ApiException.forbidden(...)`.
- **Kết quả kỳ vọng:**
  - HTTP Status: `403 Forbidden`.
  - Mã lỗi nghiệp vụ: `"FORBIDDEN"`.
  - Thông báo: `"Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."`.
- **Kết quả thực tế:** Chặn quyền chính xác với HTTP 403.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_14: Phân quyền cơ sở: User truy cập chi nhánh ngoài phạm vi cho phép
- **Mục tiêu:** Đảm bảo người dùng chỉ được xem và cấu hình chi nhánh thuộc quyền quản lý của cơ sở mình (ngăn chặn tấn công IDOR / multi-tenant cross-branch leakage).
- **Endpoint & Method:** `GET /api/v1/branches/{otherBranchId}/google-place`
- **Các bước thực hiện:**
  1. Người dùng cơ sở A gửi request với `branchId` của cơ sở B.
  2. PostgREST RLS lọc theo `business_id` và trả về rỗng.
  3. `AccountRepository.findBranch()` trả về `Optional.empty()`.
  4. Service ném `ApiException.notFound("BRANCH_NOT_FOUND", ...)`.
- **Kết quả kỳ vọng:**
  - HTTP Status: `404 Not Found`.
  - Mã lỗi nghiệp vụ: `"BRANCH_NOT_FOUND"`.
  - Thông báo: `"Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."`.
- **Kết quả thực tế:** Trả về 404, bảo vệ triệt để tính riêng tư dữ liệu đa cơ sở.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_15: Giới hạn tần suất request (Rate Limiting) trên các endpoint Google Place
- **Mục tiêu:** Kiểm tra xem backend có áp dụng cơ chế giới hạn tần suất request (Rate Limiting / Throttling) để chống spam xác minh và bảo vệ hạn ngạch Google Places API hay không.
- **Endpoint & Method:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Các bước thực hiện:**
  1. Gửi dồn dập 10 request xác minh liên tiếp với cùng một token trong vòng < 1 giây.
  2. Đếm số lượng request trả về 200 OK và số lượng request bị chặn HTTP 429 Too Many Requests.
- **Kết quả kỳ vọng theo tiêu chuẩn an ninh:**
  - Sau ngưỡng cho phép (ví dụ: > 5 req/phút), các request tiếp theo phải bị từ chối với HTTP `429 Too Many Requests`.
- **Kết quả thực tế ghi nhận:**
  - Cả 10 request đều được xử lý và trả về HTTP `200 OK`.
  - Số lượng request bị chặn 429: `0`.
  - **Kết luận:** Backend hoàn toàn **CHƯA TRIỂN KHAI RATE LIMITING** tầng ứng dụng.
- **Trạng thái:** **FAIL (Architecture Gap / Observation)** – Đã ghi nhận bug/observation, tuân thủ nguyên tắc không tự ý sửa code sản phẩm.

---

### TC_SCRUM196_16: Kiểm định API Contract chi tiết (Methods, Routes, Schemas, Status Codes)
- **Mục tiêu:** Xác minh tính tuân thủ hợp đồng giao tiếp API của toàn bộ 3 endpoints cấu hình Google Place.
- **Kiểm thử chi tiết:**
  1. `GET /api/v1/branches/{branchId}/google-place`: Trả về đúng `GooglePlaceConfigResponse` (9 trường dữ liệu).
  2. Route với `branchId` sai định dạng UUID (`"not-a-valid-uuid"`): Trả về HTTP `400 Bad Request` với mã `"BAD_REQUEST"`.
  3. `PUT /api/v1/branches/{branchId}/google-place` với `reviewUrl` không thuộc whitelist Google: Trả về HTTP `400 Bad Request` với mã `"INVALID_REVIEW_URL"`.
- **Kết quả kỳ vọng:** Tất cả endpoint phản hồi đúng kiểu dữ liệu, đúng tên trường và HTTP status code tương ứng.
- **Kết quả thực tế:** Khớp 100% đặc tả contract.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_17: Kiểm tra toàn vẹn mapping giữa branchId và Place ID
- **Mục tiêu:** Đảm bảo giá trị `branchId` lấy từ Path Variable của URL không bị gán nhầm sang chi nhánh khác trong quá trình truy vấn và lưu trữ.
- **Endpoint & Method:** `GET /api/v1/branches/{branchId}/google-place`
- **Các bước thực hiện:**
  1. Gửi request với `BRANCH_ID`.
  2. Dùng ArgumentCaptor và `Mockito.verify` để kiểm tra tham số truyền vào `GooglePlaceService.getConfig`.
  3. Xác minh service chỉ nhận đúng `BRANCH_ID` và không bao giờ nhận `OTHER_BRANCH_ID`.
- **Kết quả kỳ vọng:** Dữ liệu chi nhánh được cô lập tuyệt đối, không tráo đổi.
- **Kết quả thực tế:** `BRANCH_ID` được truyền chính xác.
- **Trạng thái:** **PASS**.

---

### TC_SCRUM196_18: Kiểm thử hồi quy toàn bộ luồng tích hợp Google Place (Regression Full Suite)
- **Mục tiêu:** Đảm bảo toàn bộ các thành phần unit/integration tests liên quan đến Google Place ID hoạt động hài hòa và không phát sinh hồi quy.
- **Phạm vi chạy test:**
  - `GooglePlaceContractSecurityTest`: 18 tests
  - `GooglePlaceControllerTest`: 3 tests
  - `GooglePlacesClientTest`: 13 tests
  - `GooglePlaceServiceTest`: 10 tests
  - `PlaceIdParserTest`: 18 tests
  - `ReviewPlatformRepositoryTest`: 2 tests
- **Kết quả kỳ vọng:** Toàn bộ 64 tests đều hoàn thành thành công với 0 Failures, 0 Errors, 0 Skipped.
- **Kết quả thực tế:** `Tests run: 64, Failures: 0, Errors: 0, Skipped: 0`. Thời gian thực thi 8.3 giây.
- **Trạng thái:** **PASS**.
