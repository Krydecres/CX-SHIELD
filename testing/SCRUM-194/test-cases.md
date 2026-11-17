# DANH SÁCH TEST CASES CHI TIẾT – KIỂM THỬ API GOOGLE PLACE ID BẰNG POSTMAN

- **Mã Jira:** SCRUM-194
- **Tên User Story:** [E4.1] Kiểm thử API Google Place ID bằng Postman
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Công cụ kiểm thử:** Postman v11 & Newman v6.2.3 CLI Runner
- **Phạm vi thực thi thực tế:** **Postman Mock Contract Testing** thực thi trên Node.js Mock Server (`http://127.0.0.1:8089`) & **Backend Unit/Regression Testing** qua Maven Surefire.
- **Đối tượng kiểm thử theo thiết kế:**
  - `GET /api/v1/branches/{branchId}/google-place`: Lấy thông tin cấu hình Google Place ID của chi nhánh
  - `POST /api/v1/branches/{branchId}/google-place/verifications`: Kiểm tra và xác minh Place ID với Google Places API
  - `PUT /api/v1/branches/{branchId}/google-place`: Lưu/cập nhật cấu hình Google Place ID và link đánh giá của chi nhánh

---

> [!WARNING]
> **LƯU Ý VỀ MÔI TRƯỜNG THỰC THI (TRANSPARENCY NOTICE):**
> - Toàn bộ 41 requests trong Postman Collection đã được thực thi bằng Newman nhắm vào **Node.js Mock Server (`127.0.0.1:8089`)**, mô phỏng các hợp đồng dữ liệu và kịch bản phản hồi của API.
> - **KHÔNG CÓ REQUEST NÀO ĐƯỢC GỬI ĐẾN LIVE SPRING BOOT BACKEND (`localhost:8080`) HOẶC LIVE DATABASE/GOOGLE API TRONG LẦN CHẠY NEWMAN NÀY.**
> - Bảng dưới đây phân định rạch ròi giữa kết quả thực thi trên **Mock Server** và kết quả xác minh trên **Backend Thật (Real Backend Verification)**.

---

## 1. Bảng tổng hợp hiện trạng kiểm thử (Coverage & Execution Matrix)

| Nhóm kiểm thử | Dải mã Test Case | Tổng số TC | Mock Execution Result | Real Backend Verification | Đánh giá hiện trạng kỹ thuật |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **01. Positive Tests** | `TC-GPLACE-POS-01` – `POS-08` | 8 | 8 MOCK PASS | 8 NOT RUN | Khớp contract trên mock; logic đã có Java Unit test (`GooglePlaceServiceTest`, `PlaceIdParserTest`). |
| **02. Validation & Negative** | `TC-GPLACE-VAL-01` – `VAL-11` | 11 | 11 MOCK PASS | 11 NOT RUN | Khớp contract lỗi trên mock; regex/whitelist đã có unit test Java (`PlaceIdParserTest`). |
| **03. Auth & Security** | `TC-GPLACE-AUTH-01` – `AUTH-04` | 4 | 4 MOCK PASS | 4 NOT RUN | Khớp contract 401 trên mock; chưa xác thực chữ ký qua Spring Security / Supabase JWKS thật. |
| **04. Multi-tenant & RLS** | `TC-GPLACE-PERM-01` – `PERM-05` | 5 | 5 MOCK PASS | 5 NOT RUN | Khớp contract 404/403 trên mock; chưa kích hoạt Supabase PostgreSQL RLS thật. |
| **05. Google Upstream** | `TC-GPLACE-EXT-01` – `EXT-06` | 6 | 6 MOCK PASS | 6 NOT RUN | Khớp kịch bản lỗi Google trên mock; tầng Java test qua `MockRestServiceServer`. |
| **06. Rate Limiting** | `TC-GPLACE-RATE-01` | 1 | **FAIL – Missing Implementation** | **NOT RUN** | **Backend hoàn toàn chưa hiện thực Rate Limiter tầng ứng dụng.** Cần PO/BA xác nhận ngưỡng. |
| | `TC-GPLACE-RATE-02` | 1 | 1 MOCK PASS | 1 NOT RUN | Xử lý HTTP 429 upstream từ Google; đã có unit test Java mapping sang `PENDING`. |
| **07. Boundary & Contract** | `TC-GPLACE-BND-01` – `BND-05` | 5 | 5 MOCK PASS | 5 NOT RUN | Khớp contract biên độ dài (20, 512, 513 chars) và UUID trên mock server. |
| **TỔNG CỘNG** | **41 Test Cases** | **41** | **40 MOCK PASS<br>1 FAIL (Gap)** | **0 VERIFIED LIVE<br>41 NOT RUN** | **Chưa đủ căn cứ tuyên bố hoàn thành Live API Integration Testing.** |

---

## 2. Chi tiết 41 Test Cases Kiểm thử API

### Nhóm 01: Positive Tests (Luồng nghiệp vụ thành công)

#### TC-GPLACE-POS-01: Lấy cấu hình Google Place ID của chi nhánh đã cài đặt
- **Mục tiêu:** Xác minh endpoint GET trả về đúng thông tin địa điểm và trạng thái kết nối khi chi nhánh đã được cấu hình trước đó.
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{branchId}}/google-place`
- **Headers:** `Authorization: Bearer {{accessToken}}`, `Accept: application/json`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "CONNECTED"`, `googleVerificationEnabled: true`.
- **Mock Execution Result:** **MOCK PASS** (Phản hồi 200 OK từ Node.js Mock Server sau 33ms).
- **Real Backend Verification:** **NOT RUN** (Chưa gửi HTTP request đến Spring Boot backend thật).
- **Căn cứ Unit Test Backend:** Logic method `getConfig` được kiểm thử với mock repository trong `GooglePlaceServiceTest.java`.

#### TC-GPLACE-POS-02: Lấy cấu hình của chi nhánh chưa từng cài đặt
- **Mục tiêu:** Xác minh endpoint GET trả về `connectionStatus: "NOT_CONNECTED"` và các trường địa điểm là null.
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{unconfiguredBranchId}}/google-place`
- **Headers:** `Authorization: Bearer {{accessToken}}`, `Accept: application/json`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "NOT_CONNECTED"`, `placeId: null`.
- **Mock Execution Result:** **MOCK PASS** (Phản hồi 200 OK từ Mock Server sau 5ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.getConfigReturnsNotConnectedWhenNothingSaved()` (Pass).

#### TC-GPLACE-POS-03: Xác minh Google Place ID hợp lệ khi Google tìm thấy địa điểm
- **Mục tiêu:** Xác minh gửi Place ID chuẩn (27 ký tự base64url, `ChIJ...`) trả về `CONNECTED` và tên/địa chỉ.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{validPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "CONNECTED"`, `verifiedWithGoogle: true`.
- **Mock Execution Result:** **MOCK PASS** (Phản hồi 200 OK từ Mock Server sau 6ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.verifyReturnsPlaceInfoWhenGoogleFindsPlace()` (Pass).

#### TC-GPLACE-POS-04: Xác minh Place ID trích xuất tự động từ đường dẫn Google Maps
- **Mục tiêu:** Xác minh trích xuất Place ID khi dán link `https://search.google.com/local/writereview?placeid=ChIJ...`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "https://search.google.com/local/writereview?placeid={{validPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `placeId` chuẩn hóa thành `ChIJN1t_tDeuEmsRUsoyG83frY4`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trích xuất và trả 200 OK sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.normalizeExtractsPlaceIdFromPastedLink()` (Pass).

#### TC-GPLACE-POS-05: Xác minh Place ID trích xuất từ chuỗi định dạng `place_id:...`
- **Mục tiêu:** Xác minh trích xuất Place ID từ chuỗi `place_id:ChIJ...`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "place_id:{{validPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `placeId: "{{validPlaceId}}"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server bóc tách và trả 200 OK sau 5ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.normalizeExtractsPlaceIdFromPastedLink()` (Pass).

#### TC-GPLACE-POS-06: Lưu cấu hình Google Place ID mới với reviewUrl tự động
- **Mục tiêu:** Xác minh khi không truyền `reviewUrl`, hệ thống tự sinh link `writereview?placeid=...` và lưu thành công.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `reviewUrl` chứa link chuẩn Google writereview.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 2ms).
- **Real Backend Verification:** **NOT RUN** (Chưa lưu bản ghi vào CSDL Supabase thật).
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveInsertsConnectedGooglePlatform()` (Pass).

#### TC-GPLACE-POS-07: Lưu cấu hình Google Place ID với Custom Review URL hợp lệ
- **Mục tiêu:** Xác minh khi truyền link `https://g.page/r/...`, hệ thống lưu đúng link tùy biến này.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}", "reviewUrl": "{{validCustomReviewUrl}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `reviewUrl: "https://g.page/r/Cb_example/review"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 4ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.manualReviewUrlAcceptsGoogleHttpsLinks()` (Pass).

#### TC-GPLACE-POS-08: Cập nhật cấu hình trên bản ghi đã tồn tại
- **Mục tiêu:** Xác minh cập nhật Place ID trên chi nhánh đã có bản ghi thực hiện UPDATE thay vì duplicate.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}", "reviewUrl": "https://maps.app.goo.gl/customReviewLink"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, bản ghi được cập nhật.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveUpdatesExistingRow()` (Pass).

---

### Nhóm 02: Validation & Negative Tests (Kiểm tra dữ liệu đầu vào)

#### TC-GPLACE-VAL-01: Xác minh thiếu trường placeId (Body rỗng `{}`)
- **Mục tiêu:** Kiểm tra bắt lỗi `@NotBlank` khi body không có trường `placeId`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "VALIDATION_ERROR"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 5ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-02: Xác minh trường placeId là chuỗi khoảng trắng
- **Mục tiêu:** Kiểm tra từ chối chuỗi chỉ gồm khoảng trắng `"   "`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "   "}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 3ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.normalizeRejectsInvalidFormat()` (Pass).

#### TC-GPLACE-VAL-03: Xác minh placeId chứa ký tự đặc biệt không hợp lệ
- **Mục tiêu:** Kiểm tra regex `^[A-Za-z0-9_-]{20,512}$` chặn ký tự không hợp lệ (`!`, `@`, `#`).
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "ChIJ!@#Invalid_Format$"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_PLACE_ID"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest` (Pass).

#### TC-GPLACE-VAL-04: Xác minh placeId có độ dài quá ngắn (< 20 ký tự)
- **Mục tiêu:** Chặn chuỗi Place ID không đủ độ dài tối thiểu (ví dụ `"ChIJ123"`).
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "ChIJ123"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_PLACE_ID"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-05: Xác minh placeId vượt quá độ dài tối đa cho phép (> 2048 ký tự)
- **Mục tiêu:** Kiểm tra giới hạn payload bean validation `@Size(max = 2048)`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "ChIJ_" + "x".repeat(2050)}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 3ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-06: Lưu cấu hình thiếu trường bắt buộc placeId
- **Mục tiêu:** Kiểm tra endpoint PUT bắt buộc phải có trường `placeId`.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"reviewUrl": "https://g.page/r/abc"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "VALIDATION_ERROR"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-07: Lưu cấu hình với placeId sai định dạng regex
- **Mục tiêu:** Kiểm tra endpoint PUT gọi `PlaceIdParser.normalize` và từ chối placeId sai regex.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "ChIJ_invalid_char!"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_PLACE_ID"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-08: Lưu cấu hình với reviewUrl không phải HTTPS (dùng HTTP)
- **Mục tiêu:** Xác minh hệ thống từ chối các URL dùng giao thức `http://`.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}", "reviewUrl": "http://g.page/r/Cb_example/review"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_REVIEW_URL"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.manualReviewUrlRejectsOtherLinks()` (Pass).

#### TC-GPLACE-VAL-09: Lưu cấu hình với reviewUrl thuộc tên miền ngoài Google
- **Mục tiêu:** Ngăn chặn tấn công Open Redirect hoặc chuyển hướng sang domain độc hại.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}", "reviewUrl": "https://evil-google.com/review"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_REVIEW_URL"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest.manualReviewUrlRejectsOtherLinks()` (Pass).

#### TC-GPLACE-VAL-10: Lưu cấu hình với reviewUrl là chuỗi văn bản không phải URL
- **Mục tiêu:** Kiểm tra xử lý chuỗi không tạo được URI hợp lệ.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{validPlaceId}}", "reviewUrl": "chuoi_van_ban_khong_phai_link"}`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_REVIEW_URL"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-VAL-11: Gửi request có body JSON hỏng cú pháp (Malformed JSON)
- **Mục tiêu:** Kiểm tra xử lý lỗi cú pháp JSON.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{ 'placeId': 'malformed_json_missing_brace'`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "BAD_REQUEST"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

---

### Nhóm 03: Authentication & Security (Xác thực và Token)

#### TC-GPLACE-AUTH-01: GET cấu hình khi không gửi Authorization Header
- **Mục tiêu:** Kiểm tra chặn truy cập ẩn danh vào cấu hình Google Place.
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{branchId}}/google-place`
- **Headers:** `Accept: application/json` (Không gửi Authorization)
- **Kết quả kỳ vọng:** HTTP `401 Unauthorized`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 401 sau 1ms).
- **Real Backend Verification:** **NOT RUN** (Chưa đi qua Spring Security Filter Chain thật).

#### TC-GPLACE-AUTH-02: POST xác minh khi không gửi Authorization Header
- **Mục tiêu:** Chặn truy cập ẩn danh vào endpoint xác minh.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Headers:** `Content-Type: application/json` (Không gửi Authorization)
- **Kết quả kỳ vọng:** HTTP `401 Unauthorized`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 401 sau 1ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-AUTH-03: PUT lưu cấu hình khi không gửi Authorization Header
- **Mục tiêu:** Chặn truy cập ẩn danh vào endpoint lưu cấu hình.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Headers:** `Content-Type: application/json` (Không gửi Authorization)
- **Kết quả kỳ vọng:** HTTP `401 Unauthorized`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 401 sau 1ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-AUTH-04: Gửi Bearer Token không hợp lệ hoặc đã hết hạn
- **Mục tiêu:** Kiểm tra từ chối token rác / sai chữ ký / hết hạn.
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{branchId}}/google-place`
- **Headers:** `Authorization: Bearer invalid-or-expired-token-string`
- **Kết quả kỳ vọng:** HTTP `401 Unauthorized`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server kiểm tra chuỗi và trả 401 sau 1ms).
- **Real Backend Verification:** **NOT RUN** (Chưa qua `NimbusJwtDecoder` ES256 thật).

---

### Nhóm 04: Authorization & Multi-tenant RLS (Phân quyền & Đa người thuê)

#### TC-GPLACE-PERM-01: Truy cập với branchId không tồn tại trong hệ thống
- **Mục tiêu:** Xác minh backend trả về 404 khi mã chi nhánh không có trong CSDL.
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{nonExistentBranchId}}/google-place`
- **Kết quả kỳ vọng:** HTTP `404 Not Found`, `code: "BRANCH_NOT_FOUND"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 404 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.getConfigFailsForInaccessibleBranch()` (Pass).

#### TC-GPLACE-PERM-02: Truy cập chi nhánh của doanh nghiệp khác (Multi-tenant Isolation)
- **Mục tiêu:** Xác minh Information Hiding: người dùng Tenant A không thể xem cấu hình của Tenant B (trả về 404).
- **Phương thức & Endpoint:** `GET /api/v1/branches/{{inaccessibleBranchId}}/google-place`
- **Kết quả kỳ vọng:** HTTP `404 Not Found`, `code: "BRANCH_NOT_FOUND"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 404 sau 2ms).
- **Real Backend Verification:** **NOT RUN** (Chưa truy vấn qua bảng `branches` thật).

#### TC-GPLACE-PERM-03: Xác minh Place ID với chi nhánh của doanh nghiệp khác
- **Mục tiêu:** Chặn xác minh địa điểm trên chi nhánh người dùng không sở hữu.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{inaccessibleBranchId}}/google-place/verifications`
- **Kết quả kỳ vọng:** HTTP `404 Not Found`, `code: "BRANCH_NOT_FOUND"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 404 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-PERM-04: Lưu cấu hình Place ID với chi nhánh của doanh nghiệp khác
- **Mục tiêu:** Chặn ghi đè cấu hình chi nhánh của doanh nghiệp khác.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{inaccessibleBranchId}}/google-place`
- **Kết quả kỳ vọng:** HTTP `404 Not Found`, `code: "BRANCH_NOT_FOUND"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 404 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-PERM-05: Lưu cấu hình bởi tài khoản Nhân viên CSKH (CS_STAFF)
- **Mục tiêu:** Kiểm tra chính sách RLS Supabase chỉ cho phép `OWNER` hoặc `BRANCH_MANAGER`. Role `CS_STAFF` bị từ chối 403 Forbidden.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Headers:** `Authorization: Bearer {{staffAccessToken}}`
- **Kết quả kỳ vọng:** HTTP `403 Forbidden`, `code: "FORBIDDEN"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server kiểm tra `token.includes('staff')` trả 403 sau 3ms).
- **Real Backend Verification:** **NOT RUN** (Chưa đi qua CSDL PostgreSQL và hàm RLS `private.has_branch_access` thật).
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveFailsWhenRlsBlocksUpdate()` (Pass với mock repo).

---

### Nhóm 05: Google Places API Upstream Resilience (Xử lý lỗi bên thứ ba)

#### TC-GPLACE-EXT-01: Xác minh khi Google trả về NOT_FOUND (Địa điểm không tồn tại)
- **Mục tiêu:** Khi Google trả về 404/400, endpoint `/verifications` trả về 200 kèm `connectionStatus: "ERROR"`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{notFoundPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "ERROR"`, `reviewUrl: null`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 ERROR sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.verifyReturnsErrorStatusWhenGoogleCannotFindPlace()`, `GooglePlacesClientTest.reportsMissingPlace()` (Pass).

#### TC-GPLACE-EXT-02: Chặn lưu cấu hình khi Google Places API báo NOT_FOUND
- **Mục tiêu:** Ngăn chặn lưu Place ID không tồn tại vào CSDL; backend ném HTTP 422 Unprocessable Entity.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{notFoundPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `422 Unprocessable Entity`, `code: "PLACE_NOT_FOUND"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 422 sau 3ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveRejectsPlaceThatGoogleCannotFind()` (Pass).

#### TC-GPLACE-EXT-03: Xác minh khi Google Places API bị gián đoạn (UNAVAILABLE)
- **Mục tiêu:** Khi Google gặp lỗi 500, 403, Timeout, endpoint xác minh vẫn phản hồi 200 kèm `connectionStatus: "PENDING"`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{unavailablePlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "PENDING"`, `verifiedWithGoogle: false`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 PENDING sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlacesClientTest.reportsUnavailableWhenGoogleFails()` (Pass).

#### TC-GPLACE-EXT-04: Lưu cấu hình thành công ở trạng thái PENDING khi Google UNAVAILABLE
- **Mục tiêu:** Đảm bảo luồng onboarding non-blocking khi Google gặp sự cố tạm thời; hệ thống lưu với trạng thái `PENDING`.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{unavailablePlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "PENDING"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 PENDING sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveUpdatesExistingRow()` (Pass).

#### TC-GPLACE-EXT-05: Xác minh khi hệ thống chưa cấu hình Google Places API Key
- **Mục tiêu:** Kiểm tra chế độ chạy offline khi chưa bật key (`placesEnabled = false`).
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{disabledKeyPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "PENDING"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 PENDING sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlacesClientTest.doesNotCallGoogleWithoutApiKey()` (Pass).

#### TC-GPLACE-EXT-06: Lưu cấu hình khi hệ thống chưa cấu hình Google Places API Key
- **Mục tiêu:** Cho phép lưu cấu hình ngoại tuyến khi chưa tích hợp Google API.
- **Phương thức & Endpoint:** `PUT /api/v1/branches/{{branchId}}/google-place`
- **Body:** `{"placeId": "{{disabledKeyPlaceId}}"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "PENDING"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 PENDING sau 1ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlaceServiceTest.saveKeepsPendingStatusWhenVerificationIsNotConfigured()` (Pass).

---

### Nhóm 06: Rate Limiting & Throttling (Tần suất & Giới hạn tải)

#### TC-GPLACE-RATE-01: Kiểm tra cơ chế giới hạn request từ client (Rate Limiting)
- **Mục tiêu:** Xác minh hệ thống có cơ chế Rate Limiting tầng ứng dụng để chặn các cuộc gọi liên tiếp gây tiêu tốn quota Google API.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{validPlaceId}}"}`
- **Kết quả phân tích Source Code Backend:** **KIỂM TRA SOURCE CODE CHO THẤY BACKEND HOÀN TOÀN CHƯA TRIỂN KHAI RATE LIMITER TẦNG ỨNG DỤNG** (Không có `Bucket4j`, không có bộ lọc giới hạn tần suất).
- **Ngưỡng Rate Limit cụ thể:** Chưa có đặc tả trong SRS/API Contract -> **NEED PO/BA CONFIRMATION**.
- **Mock Execution Result:** **FAIL – Missing Implementation / Requirement Gap** (Trên mock server trả về 200 OK do mock server không chặn; kết luận FAIL căn cứ trên việc backend chưa hiện thực tính năng).
- **Real Backend Verification:** **NOT RUN** (Chưa chạy bài thử tải trên backend thật; không gửi tải lớn làm cạn quota).

#### TC-GPLACE-RATE-02: Xử lý khi Google Places API trả về lỗi vượt quota (HTTP 429)
- **Mục tiêu:** Xác minh khi upstream Google trả về HTTP 429 Too Many Requests, client backend bắt lỗi và ánh xạ thành `UNAVAILABLE`, trả về `PENDING`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "ChIJ_GOOGLE_RATE_LIMIT_429"}`
- **Kết quả kỳ vọng:** HTTP `200 OK`, `connectionStatus: "PENDING"`, `verifiedWithGoogle: false`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 PENDING sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `GooglePlacesClientTest` dòng 86–91 xác minh `HttpStatus.TOO_MANY_REQUESTS` được map sang `Result.UNAVAILABLE` qua `MockRestServiceServer`.

---

### Nhóm 07: Boundary & API Contract (Biên dữ liệu & Hợp đồng giao tiếp)

#### TC-GPLACE-BND-01: Path variable branchId sai định dạng UUID
- **Mục tiêu:** Kiểm tra xử lý `MethodArgumentTypeMismatchException` khi path không phải UUID.
- **Phương thức & Endpoint:** `GET /api/v1/branches/invalid-branch-uuid-xyz/google-place`
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "BAD_REQUEST"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.

#### TC-GPLACE-BND-02: Place ID có độ dài biên tối thiểu hợp lệ (20 ký tự)
- **Mục tiêu:** Cận dưới của regex `^[A-Za-z0-9_-]{20,512}$` được chấp nhận.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{validPlaceIdMin}}"}` (20 ký tự: `ChIJ1234567890abcdef`)
- **Kết quả kỳ vọng:** HTTP `200 OK`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 3ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest` (Pass).

#### TC-GPLACE-BND-03: Place ID có độ dài biên tối đa hợp lệ theo regex (512 ký tự)
- **Mục tiêu:** Cận trên của regex (đúng 512 ký tự) được chấp nhận.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{validPlaceIdMax}}"}` (Chuỗi 512 ký tự)
- **Kết quả kỳ vọng:** HTTP `200 OK`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 1ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest` (Pass).

#### TC-GPLACE-BND-04: Place ID vượt quá giới hạn regex (513 ký tự)
- **Mục tiêu:** Chuỗi 513 ký tự (>512 nhưng <= 2048) bị chặn với mã `INVALID_PLACE_ID`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Body:** `{"placeId": "{{tooLongPlaceId}}"}` (513 ký tự)
- **Kết quả kỳ vọng:** HTTP `400 Bad Request`, `code: "INVALID_PLACE_ID"`.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 400 sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
- **Căn cứ Unit Test Backend:** `PlaceIdParserTest` (Pass).

#### TC-GPLACE-BND-05: Kiểm tra Content-Type Negotiation
- **Mục tiêu:** Kiểm tra request không gửi `Content-Type: application/json`.
- **Phương thức & Endpoint:** `POST /api/v1/branches/{{branchId}}/google-place/verifications`
- **Kết quả kỳ vọng:** Server xử lý an toàn (HTTP 200 hoặc 400/415), không phát sinh uncaught 500.
- **Mock Execution Result:** **MOCK PASS** (Mock Server trả 200 OK sau 2ms).
- **Real Backend Verification:** **NOT RUN**.
