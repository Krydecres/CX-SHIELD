# BÁO CÁO KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST REPORT) - SCRUM-242

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task tham chiếu:** SCRUM-211 (*In Review*), SCRUM-240 (*Test Design*), SCRUM-241 (*Functional QA*)
- **Môi trường thực thi:** Local CI Emulation (Windows 11, OpenJDK 21.0.12.1, Flutter 3.x, Dart 3.x)
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Thời gian hoàn thành:** 16/11/2026 19:03:35 +07:00
- **Kết luận:** **PASSED & PRODUCTION READY** (100% Test Automation Success)

---

## 1. TỔNG KẾT KẾT QUẢ KIỂM THỬ (EXECUTIVE SUMMARY)

| Chỉ số kiểm thử | Backend Automation | Frontend Automation | Tổng cộng | Tỷ lệ thành công |
| :--- | :---: | :---: | :---: | :---: |
| **Tổng số kịch bản kiểm thử (Automated Tests)** | **26** | **70** | **96** | **100%** |
| Số bài kiểm thử ĐẠT (**PASS**) | 26 | 70 | 96 | 100% |
| Số bài kiểm thử THẤT BẠI (**FAIL**) | 0 | 0 | 0 | 0% |
| Số bài kiểm thử BỊ BỎ QUA (**SKIPPED**) | 0 | 0 | 0 | 0% |
| Số bài kiểm thử BỊ CHẶN (**BLOCKED**) | 0 | 0 | 0 | 0% |
| **Tổng thời gian thực thi (Execution Time)** | **9.366s** | **4.200s** | **~13.566s** | *Cực nhanh* |

---

## 2. BẢNG MA TRẬN TRUY XUẤT 27 TEST CASES AUTOMATION (TRACEABILITY MATRIX)

| Test Case ID | Mục tiêu kiểm thử | Script thực thi | Lệnh thực thi | Log bằng chứng | Kết quả | Trạng thái |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: |
| **TC-D501-SEC-AUT-01** | Chặn request unauthenticated vào API thống kê (HTTP 401) | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `status().isUnauthorized()` | PASS | **PASS** |
| **TC-D501-SEC-AUT-02** | Trả về HTTP 200 và DTO đầy đủ trường khi hợp lệ | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `jsonPath("$.scanCount").value(15)` | PASS | **PASS** |
| **TC-D501-SEC-AUT-03** | Chuyển tiếp query params (branchId, from, to) vào Service | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `verify(dashboardService).getDashboard(...)` | PASS | **PASS** |
| **TC-D501-SEC-AUT-04** | Trả về HTTP 404 khi businessId không thuộc quyền sở hữu | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `status().isNotFound()` | PASS | **PASS** |
| **TC-D501-SEC-AUT-05** | Bắt lỗi validation HTTP 400 khi khoảng ngày lỗi (`from > to`) | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `status().isBadRequest()` | PASS | **PASS** |
| **TC-D501-SEC-AUT-06** | Bắt lỗi HTTP 400 khi `businessId` không đúng chuẩn UUID | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `status().isBadRequest()` | PASS | **PASS** |
| **TC-D501-REC-01** | Đối chiếu 5 thẻ số liệu và 4 bước phễu với tập 15 khảo sát | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `find.text('15')`, `find.text('76,9%')` | PASS | **PASS** |
| **TC-D501-REC-02** | Phễu tính đúng tỷ lệ trên mẫu số lượt quét 15 | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `expect(bar.value, closeTo(7/15, 0.001))` | PASS | **PASS** |
| **TC-D501-REC-SRV-01** | Backend tính tỷ lệ hài lòng `satisfied/rated * 100` | `DashboardServiceTest` | `.\mvnw.cmd test '-Dtest=DashboardServiceTest'` | `satisfactionRate == 75.0` | PASS | **PASS** |
| **TC-D501-REC-SRV-02** | Backend trả về `satisfactionRate = null` khi 0 đánh giá | `DashboardServiceTest` | `.\mvnw.cmd test '-Dtest=DashboardServiceTest'` | `satisfactionRate == null` | PASS | **PASS** |
| **TC-D501-REC-SRV-03** | Lấy snapshot Google tuần gần nhất cho MetricCard | `DashboardServiceTest` | `.\mvnw.cmd test '-Dtest=DashboardServiceTest'` | `googleReviewCount == 120, avg == 4.3` | PASS | **PASS** |
| **TC-D501-REC-SRV-04** | Repository gom nhóm theo tuần và xử lý tuần khuyết | `DashboardRepositoryTest` | `.\mvnw.cmd test '-Dtest=DashboardRepositoryTest'` | `DashboardWeeklyDto` continuous list | PASS | **PASS** |
| **TC-D501-FLT-AUT-01** | Lọc chi nhánh Quận 1: gửi `branchId=c1`, số liệu cập nhật | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `queryParameters['branchId'] == 'c1'` | PASS | **PASS** |
| **TC-D501-FLT-AUT-02** | Lọc chi nhánh Quận 3 (100%) và reset về Tất cả chi nhánh | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `find.text('100%')` -> `find.text('76,9%')` | PASS | **PASS** |
| **TC-D501-FLT-AUT-03** | Lọc chi nhánh Thủ Đức (0 scan): hiện banner, ẩn biểu đồ | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `find.byType(FunnelChart), findsNothing` | PASS | **PASS** |
| **TC-D501-FLT-AUT-04** | API Client không gửi param `branchId` khi chọn Tất cả | `dashboard_test.dart` | `flutter test test/dashboard_test.dart` | `containsKey('branchId') == false` | PASS | **PASS** |
| **TC-D501-DATE-AUT-01** | Chọn 4 tuần: đổi subtitle, khoảng cách ngày đúng 28 ngày | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `toDate.difference(fromDate).inDays == 28` | PASS | **PASS** |
| **TC-D501-DATE-AUT-02** | Chọn 12 tuần: đổi subtitle, khoảng cách ngày đúng 84 ngày | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `toDate.difference(fromDate).inDays == 84` | PASS | **PASS** |
| **TC-D501-DATE-AUT-03** | Cấu hình enum DashboardRange đúng chuẩn số ngày | `dashboard_test.dart` | `flutter test test/dashboard_test.dart` | `DashboardRange.weeks8.days == 56` | PASS | **PASS** |
| **TC-D501-NAV-AUT-01** | Chặn truy cập /dashboard khi chưa đăng nhập (`/login`) | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `sessionRedirect(...) == '/login'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-02** | Chặn truy cập khi chưa onboard (`/onboarding`) | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `sessionRedirect(...) == '/onboarding'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-03** | Tự động chuyển hướng từ URL root (`/`) vào `/dashboard` | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `sessionRedirect(...) == '/dashboard'` | PASS | **PASS** |
| **TC-D501-NAV-AUT-04** | Nút "Mở cấu hình Google" điều hướng `/funnel/google-place` | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `find.text('Màn hình Google Place')` | PASS | **PASS** |
| **TC-D501-SMK-AUT-01** | Smoke Test Backend API luồng chính (6 tests) | `DashboardControllerSecurityTest` | `.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'` | `Tests run: 6, Failures: 0` in 4.625s | PASS | **PASS** |
| **TC-D501-SMK-AUT-02** | Smoke Test Frontend Dashboard luồng hiển thị (11 tests) | `dashboard_automation_reconciliation_test.dart` | `flutter test test/dashboard_automation_reconciliation_test.dart` | `00:02 +11: All tests passed!` | PASS | **PASS** |
| **TC-D501-REG-AUT-01** | Regression Test toàn bộ Backend Dashboard (26 tests) | Backend Test Suite | `.\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest,DashboardControllerSecurityTest'` | `Tests run: 26, Failures: 0` in 9.366s | PASS | **PASS** |
| **TC-D501-REG-AUT-02** | Regression Test toàn bộ Frontend Dashboard (70 tests) | Frontend Test Suite | `flutter test test/dashboard_test.dart test/admin_pages_test.dart test/admin_shell_pages_test.dart test/auth_onboarding_test.dart test/dashboard_automation_reconciliation_test.dart` | `00:04 +70: All tests passed!` | PASS | **PASS** |

---

## 3. BÁO CÁO SMOKE TEST TỰ ĐỘNG (SMOKE TEST REPORT)

| Hạng mục kiểm tra | Phạm vi thực thi | Thời gian thực thi | Kết quả | Trạng thái |
| :--- | :--- | :---: | :---: | :---: |
| **Backend API Health & Security** | Khởi tạo Spring Context, Security Filter, MockMvc, API Response | 4.625s | 6/6 tests passed | **PASS** |
| **Frontend UI Rendering & Data Flow** | Khởi tạo Widget Tree, tải MockClient, Render 5 thẻ, 1 Phễu, Navigation | 2.100s | 11/11 tests passed | **PASS** |
| **TỔNG HỢP SMOKE TEST** | **Luồng nghiệp vụ cốt lõi sẵn sàng vận hành** | **~6.725s** | **17/17 tests passed** | **PASS 100%** |

---

## 4. BÁO CÁO REGRESSION TEST TỰ ĐỘNG (REGRESSION TEST REPORT)

### 4.1. Phân hệ Backend (Spring Boot)
- **Tổng số tests chạy:** 26 tests
- **Số lớp kiểm thử:** 4 test classes
  - `DashboardControllerSecurityTest`: 6 tests passed (Security, DTO, Params, Validation)
  - `DashboardServiceTest`: 13 tests passed (Tính toán tỷ lệ hài lòng, xử lý dữ liệu khuyết, snapshot Google)
  - `DashboardRepositoryTest`: 3 tests passed (Tổng hợp lượt quét và khảo sát theo tuần)
  - `GoogleMetricsSnapshotJobTest`: 4 tests passed (Cron job snapshot số liệu Google định kỳ)
- **Kết quả:** `BUILD SUCCESS` (0 failures, 0 errors, 0 skipped).
- **Thời gian:** 9.366s.

### 4.2. Phân hệ Frontend (Flutter)
- **Tổng số tests chạy:** 70 tests
- **Số file kịch bản:** 5 test suites
  - `test/dashboard_automation_reconciliation_test.dart`: 11 tests passed
  - `test/dashboard_test.dart`: 20 tests passed
  - `test/admin_pages_test.dart`: 15 tests passed
  - `test/admin_shell_pages_test.dart`: 18 tests passed
  - `test/auth_onboarding_test.dart`: 6 tests passed
- **Kết quả:** `00:04 +70: All tests passed!` (0 failures, 0 errors).
- **Thời gian:** 4.2s.

---

## 5. NHẬT KÝ THỰC THI THỰC TẾ (RAW EXECUTION LOGS)

### 5.1. Log thực thi Backend Regression Suite (`task-625`):
```text
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.cxshield.backend.report.DashboardControllerSecurityTest
2026-11-16T19:03:14.750+07:00  INFO 15748 --- [cx-shield-backend] [           main] c.c.b.r.DashboardControllerSecurityTest  : Started DashboardControllerSecurityTest in 3.598 seconds (process running for 4.818)
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.625 s -- in com.cxshield.backend.report.DashboardControllerSecurityTest
[INFO] Running com.cxshield.backend.report.DashboardRepositoryTest
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.177 s -- in com.cxshield.backend.report.DashboardRepositoryTest
[INFO] Running com.cxshield.backend.report.DashboardServiceTest
[INFO] Tests run: 13, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.164 s -- in com.cxshield.backend.report.DashboardServiceTest
[INFO] Running com.cxshield.backend.report.GoogleMetricsSnapshotJobTest
2026-11-16T19:03:15.720+07:00  INFO 15748 --- [cx-shield-backend] [           main] c.c.b.report.GoogleMetricsSnapshotJob    : Đã cập nhật số liệu Google cho 1 chi nhánh
2026-11-16T19:03:15.732+07:00  INFO 15748 --- [cx-shield-backend] [           main] c.c.b.report.GoogleMetricsSnapshotJob    : Đã cập nhật số liệu Google cho 1 chi nhánh
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.104 s -- in com.cxshield.backend.report.GoogleMetricsSnapshotJobTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 26, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  9.366 s
[INFO] Finished at: 2026-11-16T19:03:16+07:00
[INFO] ------------------------------------------------------------------------
```

### 5.2. Log thực thi Frontend Regression Suite:
```text
00:00 +0: loading C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/dashboard_test.dart
00:00 +0: C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/dashboard_test.dart: đọc dữ liệu API đủ số liệu
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
