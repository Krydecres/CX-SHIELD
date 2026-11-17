# BÁO CÁO PHÂN TÍCH CHUYÊN SÂU API GOOGLE PLACE ID – SCRUM-194

- **Mã Jira:** SCRUM-194
- **Tên User Story:** [E4.1] Kiểm thử API Google Place ID bằng Postman
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Thời gian lập báo cáo:** 2026-11-16
- **Kỹ sư phân tích:** Senior QA Engineer / Solution Architect Auditor

---

> [!NOTE]
> **QUY ƯỚC PHÂN ĐỊNH NGUỒN BẰNG CHỨNG (EVIDENCE TRACEABILITY CONVENTION):**
> Nhằm đảm bảo tính trung thực và minh bạch tuyệt đối, mỗi phân tích kỹ thuật trong báo cáo này được gắn nhãn nguồn gốc bằng chứng:
> - `[MÃ NGUỒN]`: Xác minh trực tiếp qua mã nguồn Java/SQL của dự án (`src/main/` và `database/`).
> - `[UNIT TEST]`: Xác minh qua bộ 44 kịch bản kiểm thử tự động nội bộ bằng Maven Surefire.
> - `[MOCK POSTMAN]`: Xác minh qua 41 kịch bản Postman Collection thực thi trên Node.js Mock Server (`127.0.0.1:8089`).
> - `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa được chạy kiểm thử trực tiếp trên môi trường tích hợp thực tế (Spring Boot live + Supabase DB live + Google API thật).

---

## 1. Bối cảnh Nghiệp vụ & Kiến trúc Hệ thống

### 1.1. Vai trò của Google Place ID trong Phễu Đánh giá (Review Funnel)
- `[MÃ NGUỒN]`: Tính năng cấu hình Google Place ID (D3-05 · Epic E4.1) phục vụ lưu trữ thông tin nhận diện cơ sở trên Google Maps (`google_place_id`) và đường dẫn đánh giá trực tiếp (`review_direct_url`) vào bảng `review_platforms`.
- `[MÃ NGUỒN]`: Khách hàng khi tham gia khảo sát QR (màn hình M1-01) đánh giá từ 4–5 sao sẽ được hệ thống chuyển tiếp sang màn hình viết đánh giá trên Google Maps (màn hình M1-02), sử dụng liên kết `review_direct_url` đã được cấu hình tại đây.

### 1.2. Kiến trúc Luồng Dữ liệu (End-to-End Architecture)
```
[Flutter UI (D3-05)]
        │
        │ HTTP REST (Bearer JWT)
        ▼
[Spring Boot Backend]
 ├── GooglePlaceController (Routing & Request Validation)
 ├── PlaceIdParser (Chuẩn hóa Base64url & Whitelist URL)
 ├── GooglePlaceService (Điều phối nghiệp vụ & Chuyển đổi trạng thái)
 ├── GooglePlacesClient (REST Client gọi Google Places API New)
 └── ReviewPlatformRepository (Truy vấn CSDL qua Supabase PostgREST Client)
        │                               │
        │ HTTPS REST                    │ PostgREST (RLS Authenticated)
        ▼                               ▼
[Google Places API (New)]      [Supabase Postgres DB]
 - GET /v1/places/{placeId}     - Bảng `review_platforms`
 - X-Goog-Api-Key               - Bảng `branches` & `businesses`
 - FieldMask: displayName,...   - Hàm RLS `private.has_branch_access`
```

---

## 2. Đối chiếu Hợp đồng API (API Contract) và Hiện thực Mã nguồn

### 2.1. Endpoint Lấy Cấu hình: `GET /api/v1/branches/{branchId}/google-place`
- **Phương thức & Định tuyến:** `GET`, đường dẫn có biến `{branchId}` (UUID).
- **Request DTO:** Không có body. Header yêu cầu `Authorization: Bearer <token>`.
- **Response DTO (`GooglePlaceConfigResponse`):**
  - Gồm các trường: `branchId`, `branchName`, `placeId`, `placeName`, `placeAddress`, `reviewUrl`, `connectionStatus`, `updatedAt`, `googleVerificationEnabled`.
- **Hiện thực mã nguồn:**
  - `[MÃ NGUỒN]`: `GooglePlaceService.getConfig()` gọi `requireBranch(token, branchId)` để kiểm tra quyền truy cập chi nhánh. Sau đó gọi `reviewPlatformRepository.findGoogle(token, branchId)`.
  - `[UNIT TEST]`: `GooglePlaceServiceTest.getConfigReturnsNotConnectedWhenNothingSaved()` xác minh khi chưa có bản ghi, trả về `connectionStatus: "NOT_CONNECTED"` và các trường địa điểm bằng `null`.
  - `[MOCK POSTMAN]`: Kịch bản `TC-GPLACE-POS-01` và `POS-02` khớp 100% cấu trúc JSON response trên mock server.
  - `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa có bài test gửi HTTP request thật vào Spring Boot đang chạy để truy vấn bảng `branches` trên Supabase thật.

### 2.2. Endpoint Xác minh Địa điểm: `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Request DTO (`VerifyPlaceRequest`):** Body JSON chứa trường `placeId` (`@NotBlank`, `@Size(max = 2048)`).
- **Response DTO (`VerifyPlaceResponse`):** Gồm: `placeId`, `placeName`, `placeAddress`, `reviewUrl`, `connectionStatus`, `verifiedWithGoogle`, `message`.
- **Hiện thực mã nguồn & Xử lý Chuẩn hóa:**
  - `[MÃ NGUỒN]`: `PlaceIdParser.normalize()` thực hiện cắt tỉa khoảng trắng, sử dụng regex `place_?id[=:]([A-Za-z0-9_-]+)` để trích xuất Place ID nếu người dùng dán cả URL, sau đó kiểm tra regex chuẩn `^[A-Za-z0-9_-]{20,512}$`.
  - `[UNIT TEST]`: `PlaceIdParserTest` (18 test cases) xác minh trích xuất chuẩn xác từ link Google Maps, link `place_id:...`, từ chối chuỗi chứa ký tự cấm, chuỗi < 20 ký tự, chuỗi khoảng trắng.
  - `[MOCK POSTMAN]`: Kịch bản `TC-GPLACE-POS-03`, `POS-04`, `POS-05` và các kịch bản Validation `VAL-01` đến `VAL-05` đều pass trên Mock Server.
  - `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa gửi payload tới backend thật để kích hoạt bộ lọc `@Valid` của Spring WebMVC trên môi trường live.

### 2.3. Endpoint Lưu Cấu hình: `PUT /api/v1/branches/{branchId}/google-place`
- **Request DTO (`SaveGooglePlaceRequest`):** Body JSON chứa `placeId` (bắt buộc) và `reviewUrl` (tùy chọn, tối đa 2048 ký tự).
- **Response DTO:** Trả về `GooglePlaceConfigResponse`.
- **Hiện thực mã nguồn:**
  - `[MÃ NGUỒN]`:
    - Nếu `reviewUrl` rỗng hoặc null, tự sinh đường dẫn: `https://search.google.com/local/writereview?placeid={placeId}`.
    - Nếu người dùng tự nhập `reviewUrl`, gọi `PlaceIdParser.validateManualReviewUrl()` để kiểm tra giao thức `https` và tên miền nằm trong whitelist: `google.com`, `g.page`, `goo.gl`.
    - Nếu Google tra cứu trả về `NOT_FOUND`, ném ngoại lệ `ApiException.unprocessable("PLACE_NOT_FOUND", ...)` -> HTTP 422.
    - Nếu Google trả về `FOUND`, lưu với `connection_status: "CONNECTED"`.
    - Nếu Google trả về `UNAVAILABLE` hoặc `NOT_CONFIGURED`, vẫn lưu với `connection_status: "PENDING"`.
  - `[UNIT TEST]`: `GooglePlaceServiceTest` (10 test cases) xác minh: lưu mới thành công, cập nhật thành công, chặn lưu khi Google báo NOT_FOUND (ném `PLACE_NOT_FOUND`), lưu trạng thái PENDING khi không bật API key.
  - `[MOCK POSTMAN]`: Kịch bản `TC-GPLACE-POS-06`, `POS-07`, `POS-08`, `VAL-06` đến `VAL-10`, `EXT-02` đều pass trên Mock Server.
  - `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa thực hiện ghi dữ liệu thật vào cơ sở dữ liệu Supabase thông qua HTTP request từ client.

---

## 3. Phân tích Khả năng Chịu lỗi khi Google Places API Gặp sự cố (Upstream Resilience)

Hệ thống kết nối Google Places API (New) thông qua `GooglePlacesClient`:
- `[MÃ NGUỒN]`:
  - `GooglePlacesClient` sử dụng `RestClient` gọi tới `https://places.googleapis.com/v1/places/{placeId}?languageCode=vi`.
  - Đính kèm headers: `X-Goog-Api-Key` và `X-Goog-FieldMask: id,displayName,formattedAddress`.
  - Bắt các mã phản hồi HTTP từ Google:
    - 2xx: Parse JSON sang `PlaceLookup.found(...)`.
    - 404 / 400: Ánh xạ thành `PlaceLookup.notFound()`.
    - 403 / 429 / 500 / Khác: Ghi warn log và ánh xạ thành `PlaceLookup.unavailable()`.
    - `RestClientException` (Timeout / Lỗi mạng): Ghi warn log và ánh xạ thành `PlaceLookup.unavailable()`.
- `[UNIT TEST]`:
  - `GooglePlacesClientTest` (13 tests) sử dụng `MockRestServiceServer` để giả lập các phản hồi từ Google: trả về tên/địa chỉ, xử lý khi thiếu displayName, xử lý HTTP 404/400 (NOT_FOUND), xử lý HTTP 403/429/500 (UNAVAILABLE), và xử lý lỗi I/O timeout.
- `[MOCK POSTMAN]`:
  - Kịch bản `TC-GPLACE-EXT-01` đến `EXT-06` và `RATE-02` mô phỏng các hành vi trên mock server.
- `[CHƯA KIỂM CHỨNG LIVE API]`:
  - Chưa kiểm chứng với dịch vụ Google Cloud Platform thật; biến `GOOGLE_PLACES_API_KEY` trong môi trường kiểm thử đang để trống.

---

## 4. Phân tích Bảo mật và Cô lập Dữ liệu Đa người thuê (Security & RLS)

### 4.1. Xác thực Danh tính (Spring Security OAuth2)
- `[MÃ NGUỒN]`: `SecurityConfig.java` cấu hình `.oauth2ResourceServer(oauth2 -> oauth2.jwt(...))` cho toàn bộ các endpoint `/api/**`. Sử dụng `NimbusJwtDecoder` với JWKS endpoint của Supabase và kiểm tra audience `authenticated`.
- `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa kiểm chứng xác thực token trực tiếp với JWKS Supabase bằng Postman Newman trên backend thật; các token trong Postman environment là chuỗi synthetic giả lập, khi gửi vào Spring Boot thật sẽ bị từ chối 401 do sai chữ ký.

### 4.2. Bảo vệ Đa người thuê và Che giấu Thông tin (Information Hiding)
- `[MÃ NGUỒN]`: Khi người dùng gọi tới chi nhánh không thuộc quyền quản lý của tổ chức mình:
  ```java
  private BranchRow requireBranch(String token, UUID branchId) {
      return accountRepository.findBranch(token, branchId)
          .orElseThrow(() -> ApiException.notFound("BRANCH_NOT_FOUND", "Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."));
  }
  ```
  Hệ thống chủ động trả về **HTTP 404 Not Found** thay vì 403 Forbidden để ngăn ngừa tấn công dò quét mã chi nhánh (ID Enumeration).
- `[UNIT TEST]`: `GooglePlaceServiceTest.getConfigFailsForInaccessibleBranch()` xác minh khi `findBranch` trả về rỗng thì ném ngoại lệ với mã `BRANCH_NOT_FOUND`.
- `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa kiểm tra truy vấn qua bảng `branches` trên CSDL thật giữa 2 tenant độc lập.

### 4.3. Kiểm soát Truy cập Cấp hàng trong CSDL (PostgreSQL RLS)
- `[MÃ NGUỒN]`: Tập tin `database/n3_onboarding_google_place.sql` định nghĩa chính sách RLS trên bảng `review_platforms`:
  ```sql
  create policy review_platforms_insert_managers on public.review_platforms
    for insert to authenticated
    with check (
      private.has_branch_access(branch_id, array['OWNER', 'BRANCH_MANAGER'])
      and business_id = (select b.business_id from public.branches b where b.id = branch_id)
    );
  ```
  Chỉ người dùng có vai trò `OWNER` hoặc `BRANCH_MANAGER` mới được phép ghi cấu hình.
  Trong `GooglePlaceService.java`, nếu repository trả về empty do RLS từ chối, backend ném `ApiException.forbidden("Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình.")` -> HTTP 403.
- `[UNIT TEST]`: `GooglePlaceServiceTest.saveFailsWhenRlsBlocksUpdate()` xác minh service ném mã `FORBIDDEN` khi repo update trả về rỗng.
- `[CHƯA KIỂM CHỨNG LIVE API]`: Chưa chạy trực tiếp qua CSDL Supabase PostgreSQL với tài khoản auth thật mang role `CS_STAFF`.

---

## 5. Phân tích Giới hạn Tần suất (Rate Limiting Analysis)

- `[MÃ NGUỒN]`: **Quét mã nguồn xác nhận: Backend Spring Boot hiện tại HOÀN TOÀN CHƯA CÓ implementation Rate Limiter tầng ứng dụng.** Không có thư viện Bucket4j, không có bộ lọc đếm request, không có cấu hình Redis limiter.
- **Rủi ro kỹ thuật:** Endpoint `POST /verifications` trực tiếp kích hoạt outbound request tới Google Places API. Nếu một tài khoản nội bộ gửi liên tục nhiều request, hệ thống có thể bị cạn kiệt quota và phát sinh chi phí Google Cloud.
- **Phân định rõ:**
  - Xử lý khi Google trả về 429: **ĐÃ CÓ** trong `GooglePlacesClient` (`[MÃ NGUỒN]`, `[UNIT TEST]`).
  - Giới hạn tần suất request từ Client: **CHƯA CÓ** (`[MÃ NGUỒN]`).

---

## 6. Các Điểm Cần PO / BA và Đội ngũ Phát triển Xác nhận

1. **Về Cơ chế Rate Limiting tầng ứng dụng (`DEFECT-GPLACE-01`):**
   - *Câu hỏi cho PO/BA:* Dự án có yêu cầu bắt buộc phải chặn tần suất request từ client tại tầng Spring Boot cho endpoint `/verifications` không? Nếu có, ngưỡng rate limit mong muốn là bao nhiêu (ví dụ: số request tối đa / phút / chi nhánh)?
2. **Về Trải nghiệm người dùng khi Google báo NOT_FOUND (`OBS-GPLACE-01`):**
   - *Câu hỏi cho PO/BA:* Xác nhận tính nhất quán giao diện: Endpoint xác minh trả về 200 (kèm cờ `ERROR`), endpoint lưu trả về 422 (`PLACE_NOT_FOUND`). Frontend Flutter (D3-05) đã xử lý hiển thị banner thông báo lỗi màu đỏ thống nhất cho cả hai trường hợp này chưa?
3. **Về Quyền hạn của tài khoản Nhân viên CSKH (`OBS-GPLACE-02`):**
   - *Câu hỏi cho PO/BA:* Đối với vai trò `CS_STAFF` (không có quyền quản lý chi nhánh), màn hình D3-05 nên được ẩn khỏi thanh điều hướng hay hiển thị ở chế độ "Chỉ xem (View-only)" và làm mờ (disable) nút "Lưu cấu hình"?
