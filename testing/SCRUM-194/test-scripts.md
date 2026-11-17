# TÀI LIỆU KỊCH BẢN KIỂM THỬ TỰ ĐỘNG POSTMAN / NEWMAN – SCRUM-194

- **Mã Jira:** SCRUM-194
- **Tên User Story:** [E4.1] Kiểm thử API Google Place ID bằng Postman
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Cài đặt Google Place ID theo chi nhánh)
- **Tập tin kịch bản:**
  - Collection: `testing/SCRUM-194/cx_shield_scrum194_collection.json` (Postman Collection v2.1.0)
  - Environment: `testing/SCRUM-194/cx_shield_scrum194_environment.json` (Postman Environment)
  - Công cụ chạy tự động: Newman CLI v6.2.3 (`npx --yes newman run ...`)

---

> [!WARNING]
> **CẢNH BÁO QUAN TRỌNG VỀ ĐIỀU KIỆN MÔI TRƯỜNG (ENVIRONMENT USAGE WARNING):**
> 1. Bộ sưu tập Postman Collection hiện tại được thiết kế và kiểm chứng trên **Node.js Mock Server chạy tại cổng 8089 (`http://127.0.0.1:8089`)**.
> 2. **Bộ sưu tập này KHÔNG THỂ dùng ngay để xác nhận Live Backend Spring Boot (`localhost:8080`) nếu chưa được chuẩn bị môi trường phù hợp**, bao gồm:
>    - JWT Token hợp lệ được ký bởi Supabase Auth (ES256 JWKS) có claim phù hợp.
>    - Dữ liệu chi nhánh mẫu và phân quyền RLS đã được seed vào CSDL Supabase PostgreSQL.
>    - Cấu hình khóa Google Places API hợp lệ trong backend.
> 3. **TUYỆT ĐỐI KHÔNG TỰ Ý ĐỔI `baseUrl` sang cổng Backend thật khi chưa có các điều kiện tiên quyết trên**, vì Spring Security sẽ từ chối toàn bộ request với mã 401 Unauthorized và có nguy cơ làm ô nhiễm dữ liệu CSDL.

---

## 1. Cấu trúc Bộ Kịch bản Kiểm thử (Test Suite Architecture)

Bộ kiểm thử gồm **41 Requests** có gắn các đoạn mã kiểm tra tự động bằng thư viện **Chai BDD** (`pm.test`, `pm.expect`), phân bổ trong 7 thư mục chức năng:

```
testing/SCRUM-194/
├── cx_shield_scrum194_collection.json      # 41 requests Postman kèm 77 assertions
├── cx_shield_scrum194_environment.json     # 21 biến môi trường giả lập (baseUrl = 127.0.0.1:8089)
├── test-cases.md                           # Danh sách 41 Test Cases chi tiết
├── test-scripts.md                         # Hướng dẫn thực thi & cảnh báo (file này)
├── test-report.md                          # Báo cáo kết quả kiểm thử tách biệt 3 tầng
├── bug-reports.md                          # Ghi nhận DEFECT-GPLACE-01 và các quan sát
└── analysis-report.md                      # Báo cáo phân tích chuyên sâu có gắn nhãn bằng chứng
```

### Phân bổ 41 Requests theo nhóm nghiệp vụ:
1. `01. Positive Tests (Happy Path)` (8 requests): GET config chi nhánh đã cấu hình / chưa cấu hình; POST verify Place ID chuẩn, dán link Maps, dán format `place_id:`; PUT lưu mới và cập nhật cấu hình.
2. `02. Validation & Negative Tests` (11 requests): Body rỗng, chuỗi khoảng trắng, ký tự đặc biệt, độ dài < 20 hoặc > 2048 ký tự, reviewUrl không phải https, domain ngoài Google, JSON hỏng cú pháp.
3. `03. Authentication & Security` (4 requests): Thiếu Bearer Token, token rác / sai chữ ký (mô phỏng mã lỗi 401).
4. `04. Authorization & Multi-tenant RLS` (5 requests): Chi nhánh không tồn tại (404), chi nhánh của tenant khác (404 Information Hiding), tài khoản `CS_STAFF` bị chặn ghi (403 Forbidden).
5. `05. Google Places API Upstream Resilience` (6 requests): Google trả về NOT_FOUND (200 ERROR khi verify, 422 khi save), Google UNAVAILABLE (PENDING), Chưa cấu hình API key (PENDING).
6. `06. Rate Limiting & Throttling` (2 requests): Kiểm tra tần suất request từ client (`TC-GPLACE-RATE-01`) và phản hồi khi Google trả về HTTP 429 (`TC-GPLACE-RATE-02`).
7. `07. Boundary & API Contract` (5 requests): Path variable UUID sai định dạng (400), Place ID biên 20 chars, 512 chars, 513 chars (>512) và Content-Type negotiation.

---

## 2. Danh mục Biến Môi trường (Environment Variables)

Toàn bộ các biến trong tập tin [cx_shield_scrum194_environment.json](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/testing/SCRUM-194/cx_shield_scrum194_environment.json) đều là dữ liệu giả lập (synthetic data), **tuyệt đối không chứa credentials hay API keys thật**:

| Tên biến | Kiểu dữ liệu | Giá trị mẫu / Mô tả | Mục đích kiểm thử |
| :--- | :--- | :--- | :--- |
| `baseUrl` | default | `http://127.0.0.1:8089` | Địa chỉ trỏ tới Mock Server chạy test contract |
| `accessToken` | secret | `eyJhbGci...mock-jwt-owner-token` | Token giả lập vai trò Quản lý / Chủ cơ sở |
| `staffAccessToken` | secret | `eyJhbGci...mock-jwt-staff-token` | Token giả lập vai trò Nhân viên CSKH (`CS_STAFF`) |
| `invalidToken` | default | `invalid-or-expired-token-string` | Chuỗi token sai định dạng để kiểm tra mã 401 |
| `branchId` | default | `22222222-2222-2222-2222-222222222222` | UUID chi nhánh mẫu đã cấu hình Place ID |
| `unconfiguredBranchId` | default | `33333333-3333-3333-3333-333333333333` | UUID chi nhánh mẫu chưa từng cấu hình Place ID |
| `inaccessibleBranchId` | default | `44444444-4444-4444-4444-444444444444` | UUID chi nhánh thuộc tenant khác (kiểm tra Information Hiding) |
| `nonExistentBranchId` | default | `99999999-9999-9999-9999-999999999999` | UUID chi nhánh không tồn tại |
| `malformedBranchId` | default | `invalid-branch-uuid-xyz` | Chuỗi không phải định dạng UUID (kiểm tra 400 Bad Request) |
| `validPlaceId` | default | `ChIJN1t_tDeuEmsRUsoyG83frY4` | Place ID chuẩn Google 27 ký tự |
| `validPlaceIdMin` | default | `ChIJ1234567890abcdef` | Place ID 20 ký tự (cận dưới biên hợp lệ) |
| `validPlaceIdMax` | default | `ChIJ_` + 507 ký tự 'A' (đúng 512 ký tự) | Place ID 512 ký tự (cận trên biên regex) |
| `tooLongPlaceId` | default | `ChIJ_` + 508 ký tự 'A' (đúng 513 ký tự) | Place ID 513 ký tự (vượt ngưỡng regex) |
| `notFoundPlaceId` | default | `ChIJ00000000000000000000000` | Place ID hợp lệ nhưng Google không tìm thấy |
| `unavailablePlaceId` | default | `ChIJ_UNAVAILABLE_MOCK_TEST_500` | Place ID mô phỏng Google 500 / Timeout |
| `disabledKeyPlaceId` | default | `ChIJ_DISABLED_KEY_MOCK_TEST` | Place ID mô phỏng khi chưa bật API key |
| `invalidFormatPlaceId`| default | `ChIJ!@#Invalid_Format$` | Place ID chứa ký tự đặc biệt sai regex |
| `tooShortPlaceId` | default | `ChIJ123` | Place ID quá ngắn (< 20 ký tự) |
| `validReviewUrl` | default | `https://search.google.com/local/writereview?placeid=...` | Đường dẫn đánh giá chuẩn |
| `validCustomReviewUrl`| default | `https://g.page/r/Cb_example/review` | URL đánh giá rút gọn hợp lệ |
| `invalidHttpReviewUrl`| default | `http://g.page/r/Cb_example/review` | URL giao thức không an toàn (HTTP) |
| `invalidDomainReviewUrl`| default | `https://evil-google.com/review` | URL tên miền giả mạo / ngoài Google |

---

## 3. Hướng dẫn Thực thi Kịch bản Kiểm thử Mock Contract

### Bước 1: Khởi động Mock Server phục vụ Test Contract
Mock server bằng Node.js được thiết lập để phản hồi các kịch bản của bộ sưu tập tại cổng `8089`:
```powershell
node "scratch/mock_server.js"
```
*(Khi console hiển thị: `Mock server running at http://127.0.0.1:8089` là sẵn sàng nhận request).*

### Bước 2: Chạy Newman CLI
Mở một cửa sổ PowerShell khác và thực thi:
```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT"

npx --yes newman run "testing/SCRUM-194/cx_shield_scrum194_collection.json" `
  -e "testing/SCRUM-194/cx_shield_scrum194_environment.json" `
  --reporters cli
```

### Bước 3: Đóng Mock Server
Sau khi Newman hoàn tất, nhấn `Ctrl + C` tại cửa sổ Node.js để dừng tiến trình mock server.

---

## 4. Hướng dẫn Chạy Kiểm thử Hồi quy Backend Java (Unit/Regression Tests)

Để kiểm chứng toàn bộ logic xử lý nội bộ của phân hệ `funnel` (Controller, Service, Parser, Client) trên JVM:
```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"

.\mvnw.cmd test "-Dtest=GooglePlaceControllerTest,GooglePlacesClientTest,GooglePlaceServiceTest,PlaceIdParserTest"
```
Kết quả kỳ vọng: **44 tests run, 0 failures, 0 errors, BUILD SUCCESS**.
