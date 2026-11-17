# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN STUDIO THIẾT KẾ ẤN PHẨM QR (SCRUM-234)

- **Mã Jira:** SCRUM-234
- **Tên User Story:** [E5.1] Kiểm thử mã nguồn studio thiết kế ấn phẩm QR
- **Phân hệ:** QR & NFC Management (Studio thiết kế ấn phẩm QR để bàn & dán quầy thu ngân D3-09 · E5.1)
- **Thời điểm thực hiện:** 17/11/2026
- **Kỹ sư QA phụ trách:** QA Engineer – CX-SHIELD Team
- **Môi trường thực thi:**
  - Runtime: Java 21 LTS (Temurin-21.0.12.1), Spring Boot 4.0.0
  - Framework: JUnit 5, Mockito
  - Build Tool: Apache Maven 3.9.16

---

## 1. Tóm tắt kết quả kiểm thử (Executive Summary)

| Chỉ số đo lường (Metric) | Giá trị thực tế | Tỷ lệ (%) | Ghi chú đánh giá |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thiết kế (Designed TCs)** | **14** | **100%** | Đồng bộ chính xác 1:1 với 14 test methods trong `QrStudioSourceTest.java` |
| - Số Test Cases ĐẠT (PASS) | **13** | **92.9%** | Đạt yêu cầu về tạo QR, chống trùng QR mặc định, CRUD print_designs, CTA, phân quyền và validation |
| - Số Test Cases KHÔNG ĐẠT (FAIL) | **1** | **7.1%** | `TC-234-08`: Hệ thống thiếu kiểm tra định dạng và dung lượng logo (BUG-SCRUM234-01) |
| - Số Test Cases BỊ CHẶN (BLOCKED) | **0** | **0%** | Không có bài test nào bị chặn môi trường |
| - Số Test Cases CHƯA CHẠY (NOT RUN) | **0** | **0%** | 100% test cases đều được thực thi tự động |
| **Số Automation Tests mới (SCRUM-234)** | **14 / 14** | **100% PASS** | 14 tests mới trong `QrStudioSourceTest.java` (test 8 PASS vì tái hiện thành công lỗi) |
| **Số Automation Tests hồi quy (Regression)** | **30 / 30** | **100% PASS** | 24 tests Backend (`QrCodeControllerTest`: 8, `PrintDesignControllerTest`: 8, `NfcOrderControllerTest`: 8) + 6 tests Frontend (`d3_09_qr_studio_test.dart`) |
| **Tổng số Automation Tests thực thi** | **44 / 44** | **100% PASS** | Toàn bộ 44 tests (38 backend + 6 frontend) đều thành công 100% |
| **Lỗi & Kiến trúc ghi nhận (Defects & Observations)** | **2** | **1 Bug + 1 Obs** | `BUG-SCRUM234-01` (Confirmed Bug - Medium) & `OBS-SCRUM234-01` (Observation - Low) |
| **Sửa đổi Production Code** | **KHÔNG** | **0 lines** | Tuyệt đối tuân thủ nguyên tắc không can thiệp sửa production code |

---

## 2. Bảng đối chiếu chi tiết 14 Test Cases SCRUM-234

| STT / Test ID | Test Method trong code | Mục tiêu kiểm định | Kết quả TC | Kết quả Auto | Trọng tâm kiểm thử |
| :---: | :--- | :--- | :---: | :---: | :--- |
| `TC-234-01` | `testCreateQrCodeWithVariousTypesGeneratesCorrectPrefix()` | Tạo mã QR tự sinh đúng tiền tố (MC-BAN, MC-QUAY, MC-KHU, MC-NV) | **PASS** | **PASS** | 1. Tạo mã QR cho chi nhánh |
| `TC-234-02` | `testCreateQrCodeDefaultValuesAndTargetUrlFormat()` | Đảm bảo targetUrl đúng format và status mặc định ACTIVE | **PASS** | **PASS** | 1. Tạo mã QR cho chi nhánh |
| `TC-234-03` | `testEnsureDefaultQrCodeWhenBranchAlreadyHasQr()` | ensureDefaultQrCode không tạo mã trùng nếu chi nhánh đã có QR | **PASS** | **PASS** | 2. Chống tạo trùng QR |
| `TC-234-04` | `testCreateQrCodeCustomCodeIndexAndUniquenessObservation()` | Lưu và tra cứu mã QR theo code (Ghi nhận Observation trùng mã) | **PASS** | **PASS** | 2. Chống tạo trùng QR |
| `TC-234-05` | `testSaveAndLoadPrintDesignFullLifecycle()` | Lưu và đọc dữ liệu print_designs đầy đủ thuộc tính mẫu, khổ in | **PASS** | **PASS** | 3. CRUD print_designs |
| `TC-234-06` | `testDeletePrintDesignLifecycle()` | Xóa mẫu thiết kế và trả về 404 khi truy vấn lại hoặc xóa tiếp | **PASS** | **PASS** | 3. CRUD print_designs |
| `TC-234-07` | `testSavePrintDesignWithValidLogoUrl()` | Lưu mẫu thiết kế với logoUrl hợp lệ dạng HTTPS URL | **PASS** | **PASS** | 4. Kiểm tra Logo |
| `TC-234-08` | `testLogoValidationBackendLacksFormatAndSizeEnforcementObservation()` | Kiểm tra giới hạn: Backend thiếu validate định dạng/dung lượng logo | **FAIL** | **PASS** | 4. Kiểm tra Logo (BUG-SCRUM234-01) |
| `TC-234-09` | `testCtaTextTrimWhitespaceAndDefaultFallback()` | Tự động trim khoảng trắng và gán nội dung CTA mặc định chuẩn | **PASS** | **PASS** | 5. Kiểm tra nội dung CTA |
| `TC-234-10` | `testCtaTextSupportsVietnameseUnicodeAndExport()` | Nội dung CTA hỗ trợ ký tự tiếng Việt và xuất file in ấn thành công | **PASS** | **PASS** | 5. Kiểm tra nội dung CTA |
| `TC-234-11` | `testTenantIsolationPrintDesignsByBusinessId()` | Cô lập dữ liệu thiết kế print_designs theo cơ sở (businessId) | **PASS** | **PASS** | 6. Phân quyền cơ sở / chi nhánh |
| `TC-234-12` | `testBranchIsolationQrCodesFilteredByBranchIdMockSupabase()` | Cô lập dữ liệu mã QR theo chi nhánh qua mock Supabase PostgREST | **PASS** | **PASS** | 6. Phân quyền cơ sở / chi nhánh |
| `TC-234-13` | `testCreateDesignWithNonExistentQrCodeThrows400()` | Từ chối lưu thiết kế khi qrCodeId không tồn tại trả về 400 | **PASS** | **PASS** | 7. Xử lý lỗi đầu vào & hệ thống |
| `TC-234-14` | `testInputValidationThrowsIllegalArgumentException()` | Từ chối branchId null hoặc brandName rỗng với ngoại lệ | **PASS** | **PASS** | 7. Xử lý lỗi đầu vào & hệ thống |

---

## 3. Kết quả kiểm thử tự động thực tế (Execution Output)

### 3.1. Kết quả chạy bộ kiểm thử Backend (38 tests)
```text
[INFO]-------------------------------------------------------
[INFO] T E S T S
[INFO]-------------------------------------------------------
[INFO]Running com.cxshield.backend.NfcOrderControllerTest
[INFO]Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.285 s -- in com.cxshield.backend.NfcOrderControllerTest
[INFO]Running com.cxshield.backend.PrintDesignControllerTest
[INFO]Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 1.781 s -- in com.cxshield.backend.PrintDesignControllerTest
[INFO]Running com.cxshield.backend.QrCodeControllerTest
[INFO]Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.070 s -- in com.cxshield.backend.QrCodeControllerTest
[INFO]Running com.cxshield.backend.QrStudioSourceTest
[INFO]Tests run: 14, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 2.066 s -- in com.cxshield.backend.QrStudioSourceTest
[INFO]
[INFO]Results:
[INFO]
[INFO]Tests run: 38, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO]------------------------------------------------------------------------
[INFO]BUILD SUCCESS
[INFO]------------------------------------------------------------------------
```

### 3.2. Kết quả chạy bộ kiểm thử hồi quy Frontend Studio D3-09 (6 tests)
```text
00:00 +0: loading C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/d3_09_qr_studio_test.dart
00:00 +0: E5.1: Hiển thị đầy đủ Studio D3-09, tải danh sách QR và Live Preview ma trận QR
00:02 +1: E5.1: Chuyển đổi khung mẫu sang Sticker Dán Quầy và Thẻ Chạm NFC cập nhật Live Preview tương ứng
00:03 +2: E5.1: Tạo mã QR mới cho chi nhánh khi bấm nút "Tạo mã QR"
00:04 +3: E5.1: Chọn câu gợi ý CTA nhanh và cập nhật màu nhận diện thương hiệu
00:04 +4: E5.1: Lưu mẫu thiết kế ấn phẩm vào print_designs thành công
00:05 +5: E5.1: Quét QR trên bản xem trước mở đúng màn khảo sát M1-01
00:05 +6: All tests passed!
```

---

## 4. Những phạm vi chưa kiểm thử được (Out of Scope / Limitations)

1. **Live Supabase PostgreSQL RLS trên cơ sở dữ liệu thật:**
   - Được kiểm chứng qua mô hình In-Memory Repository và Mock Supabase PostgREST Client (`TC-234-12`).
   - RLS thật trên production database ghi nhận trạng thái **NOT RUN** để đảm bảo tính an toàn môi trường và thời gian thực thi.
2. **Giao diện D3-09 mở rộng và E2E flow:**
   - Các kịch bản người dùng thao tác trực tiếp trên trình duyệt thực tế thuộc phạm vi bàn giao của **SCRUM-235** (Kiểm thử chức năng D3-09) và **SCRUM-236** (E2E Test). Không lặp lại trong SCRUM-234.
