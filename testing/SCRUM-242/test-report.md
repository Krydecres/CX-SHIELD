# BÁO CÁO KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST REPORT) - SCRUM-242

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task tham chiếu:** SCRUM-211 (*In Review*), SCRUM-240 (*Test Design*), SCRUM-241 (*Functional QA*)
- **Môi trường thực thi:** Local CI Emulation (Windows 11, OpenJDK 21.0.12.1, Flutter 3.x, Dart 3.x)
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Thời gian hoàn thành:** 16/11/2026 19:15:00 +07:00
- **Kết luận:** **PASSED IN LOCAL TEST ENVIRONMENT** *(17 New Automation TCs PASS, 4 Live Integration TCs BLOCKED, 79 Regression Methods PASS)*

---

## 1. TỔNG KẾT KẾT QUẢ KIỂM THỬ SAU AUDIT (EXECUTIVE SUMMARY)

### 1.1. Bảng số liệu tổng hợp kiểm thử

| Phân nhóm kiểm thử | Kịch bản mới (New) | Hồi quy có sẵn (Regression) | Tổng bài test thực thi | Đạt (PASS) | Lỗi (FAIL) | Bị chặn (BLOCKED) |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Backend Test Methods (Maven)** | 6 | 20 | **26** | 26 | 0 | 0 |
| **Frontend Test Methods (Flutter)** | 11 | 59 | **70** | 70 | 0 | 0 |
| **TỔNG AUTOMATED TEST METHODS** | **17** | **79** | **96** | **96 (100%)** | **0** | **0** |
| **Phạm vi Live / Database Thật (TCs)** | — | — | **4** | 0 | 0 | **4 (BLOCKED)** |

> [!IMPORTANT]
> **Quy tắc kết luận chính xác:**
> - Con số **96/96 Automated Tests PASS** thể hiện toàn bộ các phương thức kiểm thử tự động độc lập chạy trong môi trường cục bộ (Spring Boot MockMvc và Flutter WidgetTester/MockClient) đều vượt qua thành công với 0 lỗi hồi quy.
> - Kết quả này **không suy diễn** rằng hệ thống production đã hoàn toàn không còn lỗi hoặc đã được kiểm chứng với cơ sở dữ liệu thật.
> - **4 ca kiểm thử tích hợp Live Database / Live Auth** được ghi nhận minh bạch là **BLOCKED** do môi trường local CI offline không có kết nối cơ sở dữ liệu Supabase thật.

---

## 2. BẢNG MA TRẬN TRUY XUẤT TEST CASES AUTOMATION (TRACEABILITY MATRIX)

### 2.1. Nhóm 17 Test Cases Tự động hóa Mới (17 PASS)

| Test Case ID | Test Method Tương ứng | Test File | Trọng tâm Assertion | Kết quả | Trạng thái |
| :---: | :--- | :--- | :--- | :---: | :---: |
| **TC-D501-AUT-API-01** | `unauthenticatedRequestReturns401` | `DashboardControllerSecurityTest.java` | `status().isUnauthorized()` khi thiếu Bearer token | PASS | **PASS** |
| **TC-D501-AUT-API-02** | `authenticatedRequestReturns200WithFullData` | `DashboardControllerSecurityTest.java` | `status().isOk()`, `jsonPath("$.scanCount").value(1248)` | PASS | **PASS** |
| **TC-D501-AUT-API-03** | `authenticatedRequestWithBranchAndDateFilters` | `DashboardControllerSecurityTest.java` | `verify(dashboardService).getDashboard(...)` đúng params | PASS | **PASS** |
| **TC-D501-AUT-API-04** | `authenticatedRequestWithoutBusinessAccessReturns404` | `DashboardControllerSecurityTest.java` | `status().isNotFound()`, `code == BUSINESS_NOT_FOUND` | PASS | **PASS** |
| **TC-D501-AUT-API-05** | `authenticatedRequestWithReversedDateRangeReturns400` | `DashboardControllerSecurityTest.java` | `status().isBadRequest()`, `code == INVALID_DATE_RANGE` | PASS | **PASS** |
| **TC-D501-AUT-API-06** | `authenticatedRequestWithMalformedUuidReturns400` | `DashboardControllerSecurityTest.java` | `status().isBadRequest()` khi path variable sai UUID | PASS | **PASS** |
| **TC-D501-REC-01** | `TC-D501-REC-01` | `dashboard_automation_reconciliation_test.dart` | `find.text('15')`, `find.text('76,9%')`, `find.text('450')` | PASS | **PASS** |
| **TC-D501-REC-02** | `TC-D501-REC-02` | `dashboard_automation_reconciliation_test.dart` | `closeTo(7 / 15, 0.001)`, `closeTo(10 / 15, 0.001)` | PASS | **PASS** |
| **TC-D501-FLT-AUT-01** | `TC-D501-FLT-AUT-01` | `dashboard_automation_reconciliation_test.dart` | `queryParameters['branchId'] == 'c1'`, `find.text('62,5%')` | PASS | **PASS** |
| **TC-D501-FLT-AUT-02** | `TC-D501-FLT-AUT-02` | `dashboard_automation_reconciliation_test.dart` | `find.text('100%')` (c2 điểm 5.0★), reset về `76,9%` | PASS | **PASS** |
| **TC-D501-FLT-AUT-03** | `TC-D501-FLT-AUT-03` | `dashboard_automation_reconciliation_test.dart` | `find.text('Chưa có lượt quét nào...')`, biểu đồ ẩn | PASS | **PASS** |
| **TC-D501-DATE-AUT-01** | `TC-D501-DATE-AUT-01` | `dashboard_automation_reconciliation_test.dart` | `subtitle == 'Maison · 4 tuần gần nhất'`, `delta == 28` | PASS | **PASS** |
| **TC-D501-DATE-AUT-02** | `TC-D501-DATE-AUT-02` | `dashboard_automation_reconciliation_test.dart` | `subtitle == 'Maison · 12 tuần gần nhất'`, `delta == 84` | PASS | **PASS** |
| **TC-D501-NAV-AUT-01** | `TC-D501-NAV-AUT-01` | `dashboard_automation_reconciliation_test.dart` | `sessionRedirect(signedOut, ...) == '/login'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-02** | `TC-D501-NAV-AUT-02` | `dashboard_automation_reconciliation_test.dart` | `sessionRedirect(ready, onboarded: false, ...) == '/onboarding'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-03** | `TC-D501-NAV-AUT-03` | `dashboard_automation_reconciliation_test.dart` | `sessionRedirect(ready, onboarded: true, '/') == '/dashboard'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-04** | `TC-D501-NAV-AUT-04` | `dashboard_automation_reconciliation_test.dart` | `tap('Mở cấu hình Google')` điều hướng `/funnel/google-place` | PASS | **PASS** |

---

### 2.2. Nhóm 4 Test Cases Tích hợp Live Chưa Thực Hiện (4 BLOCKED)

| Test Case ID | Tên ca kiểm thử | Lý do phân loại BLOCKED | Kế hoạch thực hiện |
| :---: | :--- | :--- | :--- |
| **TC-D501-LIVE-01** | Đối chiếu số liệu trực tiếp trên Live PostgreSQL/Supabase | Không có kết nối mạng tới live cloud database trong môi trường CI cục bộ offline. | Thực hiện trên Staging Environment có PostgreSQL instance. |
| **TC-D501-LIVE-02** | Xác thực chữ ký cryptographic của JWT thật với GoTrue Auth | MockMvc dùng mock JWT security context, chưa kiểm tra bắt tay mạng với auth server. | Thực hiện trong đợt kiểm thử End-to-End với tài khoản thật. |
| **TC-D501-LIVE-03** | Kiểm tra đa người thuê (Multi-tenant RLS Isolation) giữa hai tài khoản thật | MockMvc giả lập phản hồi service, không truy vấn database thật có chính sách RLS. | Thực hiện kiểm thử RLS chuyên biệt trên database staging. |
| **TC-D501-LIVE-04** | Tạo 15 bản ghi khảo sát thực tế và lưu vào bảng `survey_responses` | Test dùng dữ liệu mock trong MockClient, chưa thực hiện ghi/đọc CSDL thật. | Thực hiện trong kịch bản API Integration Test có live DB. |

---

## 3. BÁO CÁO SMOKE TEST EXECUTION PROFILE

Smoke test được cấu hình như một Execution Profile chạy nhanh tập con gồm **17 kịch bản automation mới** nhằm thẩm định nhanh sức khỏe của hệ thống:

| Thành phần Smoke Test | Kịch bản thực thi | Số bài test | Thời gian chạy | Kết quả | Trạng thái |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **Backend API Health & Security** | `DashboardControllerSecurityTest.java` | 6 | 4.625s | 6/6 passed | **PASS** |
| **Frontend UI Rendering & Data Flow** | `dashboard_automation_reconciliation_test.dart` | 11 | 2.100s | 11/11 passed | **PASS** |
| **TỔNG HỢP SMOKE TEST PROFILE** | **Tập kịch bản kiểm thử tự động mới** | **17** | **~6.725s** | **17/17 passed** | **PASS 100%** |

---

## 4. BÁO CÁO REGRESSION TEST EXECUTION PROFILE

Toàn bộ **96 automated test methods** (17 mới + 79 hồi quy) đã được thực thi thành công không phát sinh bất kỳ lỗi hồi quy nào:

### 4.1. Phân hệ Backend (Spring Boot 4.0.0 / Java 21)
- Lệnh: `.\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest,DashboardControllerSecurityTest'`
- **Kết quả:** `Tests run: 26, Failures: 0, Errors: 0, Skipped: 0`
- **Thời gian:** 9.366s.
- **Trạng thái:** `BUILD SUCCESS`.

### 4.2. Phân hệ Frontend (Flutter 3.x / Dart 3.x)
- Lệnh: `flutter test test/dashboard_test.dart test/admin_pages_test.dart test/admin_shell_pages_test.dart test/auth_onboarding_test.dart test/dashboard_automation_reconciliation_test.dart`
- **Kết quả:** `00:04 +70: All tests passed!` (70 tests passed, 0 failures, 0 errors).
- **Thời gian:** 4.200s.

---

## 5. BẰNG CHỨNG THỰC THI (VERBATIM EXECUTION LOGS)

### 5.1. Log thực thi Backend (26 tests):
```text
[INFO] Running com.cxshield.backend.report.DashboardControllerSecurityTest
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.625 s -- in com.cxshield.backend.report.DashboardControllerSecurityTest
[INFO] Running com.cxshield.backend.report.DashboardRepositoryTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.177 s -- in com.cxshield.backend.report.DashboardRepositoryTest
[INFO] Running com.cxshield.backend.report.DashboardServiceTest
[INFO] Tests run: 13, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.164 s -- in com.cxshield.backend.report.DashboardServiceTest
[INFO] Running com.cxshield.backend.report.GoogleMetricsSnapshotJobTest
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.104 s -- in com.cxshield.backend.report.GoogleMetricsSnapshotJobTest
[INFO] 
[INFO] Results:
[INFO] Tests run: 26, Failures: 0, Errors: 0, Skipped: 0
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] Total time:  9.366 s
```

### 5.2. Log thực thi Frontend (70 tests):
```text
00:00 +0: loading C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/dashboard_test.dart
...
00:02 +10: SCRUM-242: Automation Data Reconciliation & Formulas TC-D501-REC-01: Đối chiếu số liệu hiển thị trên thẻ và phễu với tập khảo sát mẫu
00:02 +11: SCRUM-242: Automation Data Reconciliation & Formulas TC-D501-REC-02: Phễu chuyển đổi tính đúng tỷ lệ trên mẫu số lượt quét 15
00:02 +12: SCRUM-242: Automation Branch Filter TC-D501-FLT-AUT-01: Lọc chi nhánh Quận 1 cập nhật số liệu và note chính xác
00:02 +13: SCRUM-242: Automation Branch Filter TC-D501-FLT-AUT-02: Lọc chi nhánh Quận 3 (100% hài lòng) và quay lại Tất cả
00:02 +14: SCRUM-242: Automation Branch Filter TC-D501-FLT-AUT-03: Lọc chi nhánh Thủ Đức (chưa có dữ liệu) hiển thị banner rỗng và ẩn biểu đồ
00:02 +15: SCRUM-242: Automation Date Range Filter TC-D501-DATE-AUT-01: Đổi khoảng thời gian 4 tuần cập nhật subtitle và query params
00:02 +16: SCRUM-242: Automation Date Range Filter TC-D501-DATE-AUT-02: Đổi khoảng thời gian 12 tuần cập nhật subtitle và query params
00:02 +17: SCRUM-242: Automation Navigation & Guards TC-D501-NAV-AUT-01: Chặn vào /dashboard khi chưa đăng nhập (signedOut -> /login)
00:02 +18: SCRUM-242: Automation Navigation & Guards TC-D501-NAV-AUT-02: Chặn vào /dashboard khi chưa hoàn tất cơ sở (onboarded=false -> /onboarding)
00:02 +19: SCRUM-242: Automation Navigation & Guards TC-D501-NAV-AUT-03: Mở root / tự động chuyển hướng vào /dashboard khi đã onboarded
00:02 +20: SCRUM-242: Automation Navigation & Guards TC-D501-NAV-AUT-04: Nút "Mở cấu hình Google" chuyển hướng tới /funnel/google-place
...
00:04 +70: All tests passed!
```
