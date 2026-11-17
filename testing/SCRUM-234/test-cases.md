# BỘ TEST CASES KIỂM THỬ MÃ NGUỒN STUDIO THIẾT KẾ ẤN PHẨM QR (SCRUM-234)

- **Mã Jira:** SCRUM-234
- **Tên User Story:** [E5.1] Kiểm thử mã nguồn studio thiết kế ấn phẩm QR
- **Phân hệ:** QR & NFC Management (Studio thiết kế ấn phẩm QR để bàn & dán quầy thu ngân D3-09 · E5.1)
- **Công cụ kiểm thử:** JUnit 5, Mockito, Spring Boot Test (`@Test`, `Mockito`)
- **Tệp thực thi chính:** `backend/src/test/java/com/cxshield/backend/QrStudioSourceTest.java` (14 automation tests)
- **Phạm vi kiểm thử mã nguồn:**
  - `QrCodeController.java` (`/api/v1/qr-codes`, `/ensure-default`)
  - `PrintDesignController.java` (`/api/v1/print-designs`, `/{id}`, `/{id}/export`)
  - `QrCodeRepository.java` & `PrintDesignRepository.java`
  - `PrintExportService.java` (Xuất file vector PDF & raster PNG ≥ 300 DPI)
  - DTOs: `QrCodeRequestDto`, `QrCodeResponseDto`, `PrintDesignRequestDto`, `PrintDesignResponseDto`
- **Phân định phạm vi nghiệp vụ:**
  - **SCRUM-213:** Mã nguồn tính năng đã hoàn thiện và merge vào `main` (commit `33220b1`, `5441b03`).
  - **SCRUM-234:** Tập trung kiểm thử mã nguồn Java backend: tạo QR chi nhánh, chống trùng QR, CRUD `print_designs`, kiểm tra logo/CTA, phân quyền cơ sở/chi nhánh, xử lý lỗi đầu vào và hệ thống.
  - **SCRUM-235 / SCRUM-236:** Phụ trách kiểm thử UI D3-09 và E2E flow. Không thực hiện lại tại đây.

---

## I. Bảng tổng hợp hiện trạng kiểm thử (Execution & Coverage Matrix)

> [!IMPORTANT]
> **LƯU Ý VỀ PHÂN QUYỀN VÀ POSTGRESQL RLS:**
> Kiểm thử phân quyền chi nhánh và cơ sở (`TC-234-11`, `TC-234-12`) được thực hiện bằng cô lập dữ liệu theo `businessId`/`branchId` và mock `SupabaseAdminClient`. Cơ chế **Live Supabase PostgreSQL RLS thật trên production database chưa được kiểm chứng trực tiếp** (Live RLS: **NOT RUN**).

| Mã TC | Tên kịch bản kiểm thử | Trọng tâm | Test Method trong code | Kết quả TC | Kết quả Auto | Ghi chú đánh giá |
| :--- | :--- | :---: | :--- | :---: | :---: | :--- |
| `TC-234-01` | Tạo mã QR cho chi nhánh với các loại vị trí tự sinh đúng tiền tố mã | 1 | `testCreateQrCodeWithVariousTypesGeneratesCorrectPrefix()` | **PASS** | **PASS** | Tiền tố MC-BAN, MC-QUAY, MC-KHU, MC-NV chuẩn xác |
| `TC-234-02` | Đảm bảo mã QR tạo ra có targetUrl đúng chuẩn khảo sát và status mặc định ACTIVE | 1 | `testCreateQrCodeDefaultValuesAndTargetUrlFormat()` | **PASS** | **PASS** | targetUrl đúng format, status ACTIVE |
| `TC-234-03` | ensureDefaultQrCode không tạo mã trùng nếu chi nhánh đã có ít nhất một mã QR | 2 | `testEnsureDefaultQrCodeWhenBranchAlreadyHasQr()` | **PASS** | **PASS** | Idempotent, không sinh thêm QR khi chi nhánh đã có mã |
| `TC-234-04` | Lưu và tra cứu mã QR theo code tùy chỉnh (Ghi nhận tính duy nhất của mã) | 2 | `testCreateQrCodeCustomCodeIndexAndUniquenessObservation()` | **PASS** | **PASS** | Tra cứu code thành công; ghi nhận Observation OBS-SCRUM234-01 |
| `TC-234-05` | Lưu và đọc dữ liệu print_designs đầy đủ thuộc tính mẫu, màu sắc, khổ in | 3 | `testSaveAndLoadPrintDesignFullLifecycle()` | **PASS** | **PASS** | CRUD print_designs chuẩn xác 100% dữ liệu |
| `TC-234-06` | Xóa mẫu thiết kế ấn phẩm thành công và trả về 404 khi truy vấn lại hoặc xóa tiếp | 3 | `testDeletePrintDesignLifecycle()` | **PASS** | **PASS** | Xóa bản ghi thành công, 404 DESIGN_NOT_FOUND khi xóa lần 2 |
| `TC-234-07` | Lưu mẫu thiết kế với logoUrl hợp lệ dạng HTTPS URL được lưu trữ đầy đủ | 4 | `testSavePrintDesignWithValidLogoUrl()` | **PASS** | **PASS** | URL HTTPS hợp lệ được lưu và trả về chính xác trong DTO |
| `TC-234-08` | Kiểm tra giới hạn kiểm soát logo: Backend thiếu tầng validate định dạng file và kích thước | 4 | `testLogoValidationBackendLacksFormatAndSizeEnforcementObservation()` | **FAIL (Bug)** | **PASS (Proof)** | Hệ thống không validate định dạng (.png/.jpg/.svg) và size logo (BUG-SCRUM234-01) |
| `TC-234-09` | Tự động trim khoảng trắng và gán nội dung CTA mặc định chuẩn khi để trống | 5 | `testCtaTextTrimWhitespaceAndDefaultFallback()` | **PASS** | **PASS** | Tự động trim whitespace và fallback text mặc định chuẩn |
| `TC-234-10` | Nội dung CTA hỗ trợ ký tự tiếng Việt có dấu và ký tự đặc biệt, xuất ấn phẩm thành công | 5 | `testCtaTextSupportsVietnameseUnicodeAndExport()` | **PASS** | **PASS** | Hỗ trợ tiếng Việt đầy đủ, xuất file PDF 300 DPI không lỗi font |
| `TC-234-11` | Cô lập dữ liệu thiết kế print_designs theo cơ sở (businessId) ngăn ngừa rò rỉ dữ liệu | 6 | `testTenantIsolationPrintDesignsByBusinessId()` | **PASS** | **PASS** | Tenant isolation theo businessId không rò rỉ dữ liệu |
| `TC-234-12` | Cô lập dữ liệu mã QR theo chi nhánh qua mock Supabase PostgREST client | 6 | `testBranchIsolationQrCodesFilteredByBranchIdMockSupabase()` | **PASS** | **PASS** | Gọi mock Supabase với branch_id filter chuẩn (Live RLS: NOT RUN) |
| `TC-234-13` | Từ chối lưu thiết kế ấn phẩm khi qrCodeId không tồn tại trả về 400 QR_NOT_FOUND | 7 | `testCreateDesignWithNonExistentQrCodeThrows400()` | **PASS** | **PASS** | 400 Bad Request, code QR_NOT_FOUND khi qrCodeId ảo |
| `TC-234-14` | Xử lý lỗi đầu vào: Từ chối branchId null hoặc brandName rỗng với IllegalArgumentException | 7 | `testInputValidationThrowsIllegalArgumentException()` | **PASS** | **PASS** | Bắt buộc tham số branchId, qrCodeId, brandName hợp lệ |

- **Tổng số Test Cases thiết kế:** **14**
- **Test Case PASS:** **13 / 14** (92.9%)
- **Test Case FAIL:** **1 / 14** (7.1%) (`TC-234-08` – Vi phạm yêu cầu kiểm tra định dạng và dung lượng logo)
- **Test Case BLOCKED:** **0**
- **Test Case NOT RUN:** **0**
- **Automation Tests mới (SCRUM-234):** **14 / 14 PASS** (Trong đó test 8 PASS với vai trò kiểm chứng và tái hiện lỗi hệ thống)
- **Regression Tests (Backend):** **24 / 24 PASS** (`QrCodeControllerTest`: 8, `PrintDesignControllerTest`: 8, `NfcOrderControllerTest`: 8)
- **Tổng số Automation Tests thực thi:** **38 / 38 PASS** (100%)
- **Phân loại vấn đề ghi nhận:**
  - **1 BUG (Defect):** `BUG-SCRUM234-01` (Thiếu kiểm tra định dạng tập tin và kích thước logo, vi phạm yêu cầu số 4)
  - **1 OBSERVATION:** `OBS-SCRUM234-01` (Chưa kiểm tra trùng mã QR khi tạo mã tùy chỉnh, rủi ro toàn vẹn dữ liệu)

---

## II. Chi tiết 14 Test Cases

### TC-234-01: Tạo mã QR cho chi nhánh với các loại vị trí tự sinh đúng tiền tố mã
- **Mục tiêu:** Kiểm tra hàm sinh mã QR tự động khi người dùng không truyền `code`, mã sinh ra phải mang tiền tố tương ứng với từng loại vị trí:
  - `TABLE` -> bắt đầu bằng `MC-BAN`
  - `COUNTER` -> bắt đầu bằng `MC-QUAY`
  - `AREA` -> bắt đầu bằng `MC-KHU`
  - `STAFF` -> bắt đầu bằng `MC-NV`
- **Dữ liệu đầu vào:**`branchId = randomUUID()`, `code = null`, `name = tùy chỉnh`, `type in [TABLE, COUNTER, AREA, STAFF]`.
- **Kết quả mong đợi:** Mã sinh tự động có tiền tố chính xác, DTO trả về chứa type và name tương ứng, HTTP 200 OK.
- **Kết quả thực tế:** **PASS**.

### TC-234-02: Đảm bảo mã QR tạo ra có targetUrl đúng chuẩn khảo sát và status mặc định ACTIVE
- **Mục tiêu:** Xác nhận mã QR tạo mới có cấu trúc URL đích khảo sát khách hàng hợp lệ và trạng thái hoạt động tức thì.
- **Dữ liệu đầu vào:**`branchId = existingBranchId`, `code = "MC-BAN99"`, `type = "TABLE"`, `name = "Bàn 99"`.
- **Kết quả mong đợi:** `targetUrl` bằng `"https://cxshield.vn/survey?qr=MC-BAN99"`, `status = "ACTIVE"`, `id` và `createdAt` không null.
- **Kết quả thực tế:** **PASS**.

### TC-234-03: ensureDefaultQrCode không tạo mã trùng nếu chi nhánh đã có ít nhất một mã QR
- **Mục tiêu:** Đảm bảo tính bất biến (idempotency) của endpoint `/ensure-default`, không sinh thêm mã QR rác khi chi nhánh đã có sẵn mã.
- **Dữ liệu đầu vào:**`branchId = existingBranchId` (đã có mã `MC-B04`).
- **Kết quả mong đợi:** Trả về mã `MC-B04` hiện có, message `"Chi nhánh đã có mã QR"`, số lượng mã QR của chi nhánh không tăng.
- **Kết quả thực tế:** **PASS**.

### TC-234-04: Lưu và tra cứu mã QR theo code tùy chỉnh (Ghi nhận tính duy nhất của mã)
- **Mục tiêu:** Kiểm tra lưu mã QR theo code chỉ định và tra cứu qua `findByCode`. Ghi nhận hiện trạng backend khi tạo trùng code.
- **Dữ liệu đầu vào:**`code = "MC-VIP-SPECIAL"`. Sau đó tạo thêm 1 mã cùng code trong cùng chi nhánh.
- **Kết quả mong đợi:** Tra cứu `findByCode` tìm thấy đúng bản ghi. Ghi nhận quan sát: Repository ghi đè chỉ mục `codeIndex` mà chưa ném lỗi 409 Conflict.
- **Kết quả thực tế:** **PASS (Chức năng tạo và tra cứu đạt; ghi nhận Observation OBS-SCRUM234-01)**.

### TC-234-05: Lưu và đọc dữ liệu print_designs đầy đủ thuộc tính mẫu, màu sắc, khổ in
- **Mục tiêu:** Kiểm tra chu trình tạo và đọc lại mẫu thiết kế ấn phẩm vào `print_designs` với đầy đủ các trường dữ liệu: template, brandName, ctaText, color, logoUrl, exportFormat, size.
- **Dữ liệu đầu vào:**`PrintDesignRequestDto` với template `COUNTER_STAND`, khổ `A5`, format `PNG`, màu `#047857`.
- **Kết quả mong đợi:** Lưu thành công, đọc lại qua `getDesignById` khớp 100% dữ liệu đã lưu.
- **Kết quả thực tế:** **PASS**.

### TC-234-06: Xóa mẫu thiết kế ấn phẩm thành công và trả về 404 khi truy vấn lại hoặc xóa tiếp
- **Mục tiêu:** Kiểm tra chức năng xóa mẫu thiết kế khỏi cơ sở dữ liệu `print_designs` và xử lý ngoại lệ khi xóa ID không tồn tại.
- **Dữ liệu đầu vào:**`designId = existingDesignId`.
- **Kết quả mong đợi:** Lần 1 xóa thành công trả về 200 OK. Lần 2 truy vấn hoặc xóa tiếp ném `ApiException(HttpStatus.NOT_FOUND, "DESIGN_NOT_FOUND")`.
- **Kết quả thực tế:** **PASS**.

### TC-234-07: Lưu mẫu thiết kế với logoUrl hợp lệ dạng HTTPS URL được lưu trữ đầy đủ
- **Mục tiêu:** Kiểm tra mẫu thiết kế chứa đường dẫn URL hình ảnh logo hợp lệ được lưu trữ và phản hồi đầy đủ qua DTO.
- **Dữ liệu đầu vào:**`logoUrl = "https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400&format=png"`.
- **Kết quả mong đợi:** Lưu thành công, trường `logoUrl` trong response DTO khớp chính xác.
- **Kết quả thực tế:** **PASS**.

### TC-234-08: Kiểm tra giới hạn kiểm soát logo: Backend thiếu tầng validate định dạng file và kích thước
- **Mục tiêu:** Kiểm chứng hiện trạng mã nguồn: backend có kiểm tra định dạng file ảnh (.png, .jpg, .svg) hay giới hạn kích thước logo theo yêu cầu số 4 không.
- **Dữ liệu đầu vào:**`logoUrl = "https://malicious.example.com/payload.exe"`.
- **Kết quả mong đợi:** Backend phải từ chối URL không phải hình ảnh hoặc file thực thi nguy hiểm.
- **Kết quả thực tế:** **FAIL (Bug)** (Hệ thống chấp nhận lưu chuỗi `payload.exe` mà không có validation, vi phạm yêu cầu kiểm tra định dạng/kích thước logo; Automation test PASS vì đã kiểm chứng và tái hiện lỗi BUG-SCRUM234-01).

### TC-234-09: Tự động trim khoảng trắng và gán nội dung CTA mặc định chuẩn khi để trống
- **Mục tiêu:** Kiểm tra logic xử lý nội dung câu kêu gọi hành động (CTA): tự động trim khoảng trắng thừa và fallback về câu CTA chuẩn nếu để trống.
- **Dữ liệu đầu vào:**
  1. `ctaText = null` -> Mong đợi: `"Quét mã để đánh giá & nhận ưu đãi"`
  2. `ctaText = "   Góp ý ngay nhận quà liền tay   "` -> Mong đợi: `"Góp ý ngay nhận quà liền tay"`
- **Kết quả mong đợi:** Xử lý chuẩn xác cả 2 trường hợp.
- **Kết quả thực tế:** **PASS**.

### TC-234-10: Nội dung CTA hỗ trợ ký tự tiếng Việt có dấu và ký tự đặc biệt, xuất ấn phẩm thành công
- **Mục tiêu:** Đảm bảo nội dung CTA tiếng Việt có dấu và ký tự đặc biệt (`&`, `!`) không bị lỗi font hoặc hỏng đồ họa khi tạo và xuất file in ấn.
- **Dữ liệu đầu vào:**`ctaText = "Quét mã để đánh giá & nhận ngay quà tri ân từ quán!"`, xuất file PDF độ phân giải 300 DPI.
- **Kết quả mong đợi:** DTO lưu giữ nguyên vẹn chuỗi tiếng Việt Unicode, hàm xuất PDF trả về mảng bytes hợp lệ > 1000 bytes.
- **Kết quả thực tế:** **PASS**.

### TC-234-11: Cô lập dữ liệu thiết kế print_designs theo cơ sở (businessId) ngăn ngừa rò rỉ dữ liệu
- **Mục tiêu:** Kiểm tra nguyên tắc Multi-tenancy: danh sách thiết kế của cơ sở A không xuất hiện khi truy vấn cơ sở B.
- **Dữ liệu đầu vào:**Tạo 1 thiết kế thuộc `businessA`, 1 thiết kế thuộc `businessB`.
- **Kết quả mong đợi:** `getDesigns(businessA)` chỉ trả về đúng thiết kế của cơ sở A; `getDesigns(businessB)` chỉ trả về đúng thiết kế của cơ sở B.
- **Kết quả thực tế:** **PASS**.

### TC-234-12: Cô lập dữ liệu mã QR theo chi nhánh qua mock Supabase PostgREST client
- **Mục tiêu:** Kiểm tra lệnh truy vấn lấy danh sách mã QR theo chi nhánh gửi đúng điều kiện `branch_id = eq.<branchId>` tới Supabase client.
- **Dữ liệu đầu vào:**Mock `SupabaseAdminClient.select(...)` với tham số `branch_id = eq.<targetBranchId>`.
- **Kết quả mong đợi:** Client gửi đúng tham số lọc theo chi nhánh; Live PostgreSQL RLS thật trên DB production ghi nhận là NOT RUN.
- **Kết quả thực tế:** **PASS**.

### TC-234-13: Từ chối lưu thiết kế ấn phẩm khi qrCodeId không tồn tại trả về 400 QR_NOT_FOUND
- **Mục tiêu:** Kiểm tra tính toàn vẹn dữ liệu: không cho phép tạo ấn phẩm liên kết với mã QR ảo/không tồn tại.
- **Dữ liệu đầu vào:**`qrCodeId = UUID.randomUUID()` (không có trong cơ sở dữ liệu).
- **Kết quả mong đợi:** Ném ngoại lệ `ApiException` với status `400 BAD_REQUEST`, mã lỗi `"QR_NOT_FOUND"`, thông báo `"Mã QR liên kết không tồn tại"`.
- **Kết quả thực tế:** **PASS**.

### TC-234-14: Xử lý lỗi đầu vào: Từ chối branchId null hoặc brandName rỗng với IllegalArgumentException
- **Mục tiêu:** Kiểm tra cơ chế validation đầu vào tại Controller: từ chối các tham số bắt buộc bị thiếu.
- **Dữ liệu đầu vào:**
  1. `createQrCode` với `branchId = null`
  2. `createOrUpdateDesign` với `qrCodeId = null`
  3. `createOrUpdateDesign` với `brandName = "   "`
- **Kết quả mong đợi:** Ném `IllegalArgumentException` với thông điệp rõ ràng cho từng trường hợp.
- **Kết quả thực tế:** **PASS**.
