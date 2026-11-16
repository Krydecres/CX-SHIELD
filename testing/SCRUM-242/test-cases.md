# DANH MỤC TEST CASES KIỂM THỬ TỰ ĐỘNG DASHBOARD TỔNG QUAN (SCRUM-242)

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task đối ứng:** SCRUM-211 (*In Review*), SCRUM-240 (*Test Design*), SCRUM-241 (*Functional QA*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan & API Thống kê)
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Ngày lập:** 16/11/2026
- **Trạng thái tài liệu:** **AUDITED & ALIGNED WITH TEST CODE** *(17 New Automation Test Cases PASS, 4 Live Integration BLOCKED, 79 Regression Methods PASS)*

---

## 1. BẢNG TỔNG HỢP TEST CASES VÀ PHÂN LOẠI SAU AUDIT

Sau khi thực hiện rà soát độc lập đối chiếu giữa tài liệu và mã nguồn kiểm thử thực tế, cơ cấu ca kiểm thử của SCRUM-242 được chuẩn hóa chính xác như sau:

| Nhóm | Tên nhóm kiểm thử (Category) | Số TC | Mức độ | Trạng thái Audit | Script / Method thực thi tương ứng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **G1** | Automation API Thống kê Dashboard (Spring Boot MockMvc) | 6 | High | **6 PASS** | `DashboardControllerSecurityTest.java` (6 methods) |
| **G2** | Automation Đối chiếu Dữ liệu Khảo sát Mô phỏng & Công thức | 2 | High | **2 PASS** | `dashboard_automation_reconciliation_test.dart` (TC-REC-01, 02) |
| **G3** | Automation Bộ lọc Chi nhánh (Branch Switching & Empty) | 3 | High/Med | **3 PASS** | `dashboard_automation_reconciliation_test.dart` (TC-FLT-01, 02, 03) |
| **G4** | Automation Bộ lọc Thời gian (4 tuần, 12 tuần) | 2 | Med | **2 PASS** | `dashboard_automation_reconciliation_test.dart` (TC-DATE-01, 02) |
| **G5** | Automation Điều hướng & Router Guards sau đăng nhập | 4 | High | **4 PASS** | `dashboard_automation_reconciliation_test.dart` (TC-NAV-01 $\rightarrow$ 04) |
| **G6** | Phạm vi Live Integration / CSDL thật (Chưa thể chạy CI offline) | 4 | High | **4 BLOCKED** | Live Supabase / PostgreSQL / Live GoTrue Auth |
| **TỔNG** | **Tổng số Test Cases được thiết kế & thẩm định** | **21** | **17 High, 4 Med** | **17 PASS, 4 BLOCKED** | **17 Test Cases mới đạt 100% trên Local CI** |

> [!NOTE]
> **Làm rõ số liệu sau audit:**
> 1. Trong báo cáo sơ bộ ban đầu, số lượng Test Cases được ghi nhận là 27 do đã cộng gộp 4 lần chạy Smoke/Regression suite (G6, G7) và 6 unit tests kế thừa từ trước. Sau audit độc lập, các lần chạy suite được tách riêng thành Execution Profiles; 6 unit tests cũ được đưa về đúng danh mục Regression; số lượng Test Cases mới độc lập được xác định chính xác là **17 Test Cases** (tương ứng 1:1 với 17 automated test methods mới được viết trong 2 file code mới).
> 2. Ngoài ra, có **4 Test Cases tích hợp Live Database/Live Auth** được ghi nhận minh bạch là **BLOCKED** do môi trường local CI offline không có kết nối cơ sở dữ liệu Supabase thật.
> 3. Toàn bộ **79 automated test methods hồi quy có sẵn** (20 backend + 59 frontend) đều được chạy lại và đạt **79/79 PASS (100%)**.

---

## 2. QUY ƯỚC TRẠNG THÁI KIỂM THỬ (STATUS DEFINITIONS)

- **PASS:** Ca kiểm thử có kịch bản automation test độc lập, được thực thi thành công thông qua test runner chuẩn (`mvnw test` hoặc `flutter test`), có câu lệnh assertion kiểm tra khớp với tiêu chí mong đợi trong môi trường local test.
- **BLOCKED:** Ca kiểm thử đòi hỏi hạ tầng môi trường thật bên thứ ba (Live Supabase Cloud Database, Live Google Places API, Live GoTrue Auth) không khả dụng trong môi trường CI cục bộ offline.
- **FAIL:** Ca kiểm thử tự động phát hiện lỗi sai lệch so với thiết kế.
- **NOT RUN:** Ca kiểm thử chưa được kích hoạt trong đợt kiểm thử hiện tại.

---

## 3. CHI TIẾT 17 TEST CASES AUTOMATION MỚI (PHẠM VI ĐÃ THỰC THI THÀNH CÔNG)

---

### NHÓM 1: AUTOMATION API THỐNG KÊ DASHBOARD (SPRING BOOT MOCKMVC INTEGRATION)
*Lưu ý kỹ thuật: Tầng service được thay thế bằng `@MockitoBean private DashboardService dashboardService;`. JWT được cấp bằng Spring Security Test request post processor `jwt()`. Test xác minh hành vi Controller, HTTP Status, JSON Serialization và Exception Mapping trong môi trường test cô lập, không xác minh chữ ký JWT thật hoặc RLS trên cơ sở dữ liệu live.*

#### TC-D501-AUT-API-01: Chặn 401 khi thiếu Bearer Token
- **Mã Test Case:** TC-D501-AUT-API-01
- **Phân loại:** Security / API Authentication Guard
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `unauthenticatedRequestReturns401()`
- **Mục tiêu:** Xác minh endpoint `/api/v1/businesses/{businessId}/dashboard` trả về HTTP 401 Unauthorized khi request không đính kèm Bearer token.
- **Điều kiện tiên quyết:** Spring Boot Test Context khởi tạo với MockMvc và Security Filter Chain.
- **Dữ liệu đầu vào:** `GET /api/v1/businesses/11111111-1111-1111-1111-111111111111/dashboard`, không header Authorization.
- **Assertion:** `andExpect(status().isUnauthorized())`.
- **Kết quả thực tế:** PASS (HTTP 401).

#### TC-D501-AUT-API-02: Trả về 200 và đầy đủ dữ liệu khi có JWT hợp lệ
- **Mã Test Case:** TC-D501-AUT-API-02
- **Phân loại:** API Contract / DTO Serialization
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `authenticatedRequestReturns200WithFullData()`
- **Mục tiêu:** Xác minh khi có mock JWT hợp lệ, Controller trả về HTTP 200 OK cùng toàn bộ cấu trúc JSON DTO khớp với dữ liệu mock service trả về.
- **Dữ liệu mock:** `DashboardResponse(null, FROM, TO, 1248, 1000, 825, 82.5, 684, 1032, 4.6, List.of(WeeklyPoint(...)))`.
- **Assertion:** `status().isOk()`, `jsonPath("$.scanCount").value(1248)`, `jsonPath("$.satisfactionRate").value(82.5)`.
- **Kết quả thực tế:** PASS (HTTP 200, JSON schema valid).

#### TC-D501-AUT-API-03: Truyền đúng branchId và khoảng ngày vào service
- **Mã Test Case:** TC-D501-AUT-API-03
- **Phân loại:** Controller Binding / Query Param Handling
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `authenticatedRequestWithBranchAndDateFilters()`
- **Mục tiêu:** Xác minh query params `branchId`, `from`, `to` truyền trên URL được Controller parse chính xác thành UUID và LocalDate để chuyển vào service.
- **Dữ liệu đầu vào:** `branchId = 22222222-2222-2222-2222-222222222222`, `from = 2026-09-11`, `to = 2026-11-06`.
- **Assertion:** `verify(dashboardService).getDashboard(any(), eq(BUSINESS_ID), eq(BRANCH_ID), eq(FROM), eq(TO))`.
- **Kết quả thực tế:** PASS.

#### TC-D501-AUT-API-04: Xử lý 404 khi người dùng không có quyền trên cơ sở
- **Mã Test Case:** TC-D501-AUT-API-04
- **Phân loại:** Security / Business Access Control Exception Mapping
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `authenticatedRequestWithoutBusinessAccessReturns404()`
- **Mục tiêu:** Xác minh khi service ném `ApiException.notFound("BUSINESS_NOT_FOUND", ...)`, Controller bắt ngoại lệ và trả về HTTP 404 NOT_FOUND.
- **Assertion:** `status().isNotFound()`, `jsonPath("$.code").value("BUSINESS_NOT_FOUND")`.
- **Kết quả thực tế:** PASS (HTTP 404).

#### TC-D501-AUT-API-05: Xử lý 400 khi khoảng ngày đảo ngược
- **Mã Test Case:** TC-D501-AUT-API-05
- **Phân loại:** Validation / Date Range Exception Mapping
- **Mức độ ưu tiên:** Medium
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `authenticatedRequestWithReversedDateRangeReturns400()`
- **Mục tiêu:** Xác minh khi service ném `ApiException.badRequest("INVALID_DATE_RANGE", ...)`, Controller trả về HTTP 400 BAD_REQUEST.
- **Assertion:** `status().isBadRequest()`, `jsonPath("$.code").value("INVALID_DATE_RANGE")`.
- **Kết quả thực tế:** PASS (HTTP 400).

#### TC-D501-AUT-API-06: Chặn 400 khi businessId sai định dạng UUID
- **Mã Test Case:** TC-D501-AUT-API-06
- **Phân loại:** Validation / Type Safety
- **Mức độ ưu tiên:** Medium
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Tên Test Method:** `authenticatedRequestWithMalformedUuidReturns400()`
- **Mục tiêu:** Xác minh Spring MVC xử lý `MethodArgumentTypeMismatchException` khi path variable `businessId` không phải là UUID chuẩn và trả về HTTP 400.
- **Assertion:** `status().isBadRequest()`.
- **Kết quả thực tế:** PASS (HTTP 400).

---

### NHÓM 2: AUTOMATION ĐỐI CHIẾU DỮ LIỆU KHẢO SÁT MÔ PHỎNG & CÔNG THỨC (FLUTTER WIDGET & MOCKCLIENT)
*Lưu ý kỹ thuật: Dữ liệu được dựng sẵn trong các đối tượng mock API response (`sampleAllBranchesData`, `sampleBranch1Data`, `sampleBranch2Data`, `sampleEmptyBranchData`) mô phỏng tập dữ liệu khảo sát 15 lượt quét. Không phải ghi/đọc trực tiếp từ cơ sở dữ liệu PostgreSQL live.*

#### TC-D501-REC-01: Đối chiếu số liệu hiển thị trên thẻ và phễu với tập phản hồi mẫu
- **Mã Test Case:** TC-D501-REC-01
- **Phân loại:** UI Reconciliation / Widget Rendering
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Tên Test:** `SCRUM-242: Automation Data Reconciliation & Formulas TC-D501-REC-01`
- **Mục tiêu:** Xác minh toàn bộ số liệu tổng hợp hiển thị trên 5 MetricCards và 4 bước Phễu chuyển đổi khớp chính xác với tập dữ liệu mock mô phỏng 15 lượt quét.
- **Dữ liệu mock đầu vào:**
  - `scanCount`: 15
  - `ratedCount`: 13
  - `satisfiedCount`: 10
  - `satisfactionRate`: 76.9%
  - `googleRedirectCount`: 7
  - `googleReviewCount`: 450
  - `googleAvgRating`: 4.7
- **Assertions:**
  - `expect(find.text('15'), findsOneWidget)` (Lượt quét QR)
  - `expect(find.text('76,9%'), findsOneWidget)` (Tỷ lệ hài lòng)
  - `expect(find.text('13 lượt đánh giá'), findsOneWidget)` (Ghi chú số lượt đánh giá)
  - `expect(find.text('7'), findsWidgets)` (Chuyển sang Google)
  - `expect(find.text('450'), findsWidgets)` (Đánh giá Google)
  - `expect(find.text('4,7★'), findsWidgets)` (Điểm sao Google)
  - `expect(find.text('15 · 100%'), findsOneWidget)` (Phễu bước 1)
  - `expect(find.text('13 · 86,7%'), findsOneWidget)` (Phễu bước 2)
  - `expect(find.text('10 · 66,7%'), findsOneWidget)` (Phễu bước 3)
  - `expect(find.text('7 · 46,7%'), findsOneWidget)` (Phễu bước 4)
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-02: Phễu chuyển đổi tính đúng tỷ lệ trên mẫu số lượt quét 15
- **Mã Test Case:** TC-D501-REC-02
- **Phân loại:** Business Formula / Funnel Calculation
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Tên Test:** `SCRUM-242: Automation Data Reconciliation & Formulas TC-D501-REC-02`
- **Mục tiêu:** Xác minh tỷ lệ tiến trình (`LinearProgressIndicator.value`) của các bước phễu sử dụng đúng mẫu số là tổng `scanCount` (15).
- **Assertions:**
  - `expect(barStep4.value, closeTo(7 / 15, 0.001))`
  - `expect(barStep3.value, closeTo(10 / 15, 0.001))`
- **Kết quả thực tế:** PASS.

---

### NHÓM 3: AUTOMATION BỘ LỌC CHI NHÁNH (BRANCH FILTER)

#### TC-D501-FLT-AUT-01: Lọc chi nhánh Quận 1 cập nhật số liệu và note chính xác
- **Mã Test Case:** TC-D501-FLT-AUT-01
- **Phân loại:** Filter / Branch Switching
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh chọn "Quận 1" kích hoạt request có query param `branchId=c1` và cập nhật số liệu riêng của Quận 1 (10 scans, 8 ratings, 62.5% hài lòng, Google Review 300, Điểm Google 4.5★).
- **Assertions:**
  - `expect(calls.last.url.queryParameters['branchId'], 'c1')`
  - `expect(find.text('62,5%'), findsWidgets)`
  - `expect(find.text('8 lượt đánh giá'), findsOneWidget)`
  - `expect(find.text('4,5★'), findsWidgets)`
- **Kết quả thực tế:** PASS.

#### TC-D501-FLT-AUT-02: Lọc chi nhánh Quận 3 (100% hài lòng, Google 5.0★) và quay lại Tất cả
- **Mã Test Case:** TC-D501-FLT-AUT-02
- **Phân loại:** Filter / Reset State
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh chọn "Quận 3" hiển thị tỷ lệ 100% hài lòng (Điểm Google 5.0★ trong `sampleBranch2Data`). Chọn lại "Tất cả chi nhánh" loại bỏ `branchId` và khôi phục số liệu toàn hệ thống (76.9%).
- **Assertions:**
  - `expect(find.text('100%'), findsWidgets)`
  - `expect(find.text('5 lượt đánh giá'), findsOneWidget)`
  - Sau khi chọn lại Tất cả: `expect(calls.last.url.queryParameters.containsKey('branchId'), isFalse)`, `expect(find.text('76,9%'), findsWidgets)`
- **Kết quả thực tế:** PASS.

#### TC-D501-FLT-AUT-03: Lọc chi nhánh Thủ Đức (chưa có dữ liệu) hiển thị banner rỗng và ẩn biểu đồ
- **Mã Test Case:** TC-D501-FLT-AUT-03
- **Phân loại:** Empty State / Boundary
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh chọn chi nhánh có `scanCount = 0` (Thủ Đức) hiển thị thông báo rỗng và ẩn các component biểu đồ.
- **Assertions:**
  - `expect(find.text('Chưa có lượt quét nào trong khoảng thời gian này.'), findsOneWidget)`
  - `expect(find.byType(FunnelChart), findsNothing)`
  - `expect(find.byType(WeeklyBarChart), findsNothing)`
  - `expect(find.byType(WeeklyTable), findsNothing)`
- **Kết quả thực tế:** PASS.

---

### NHÓM 4: AUTOMATION BỘ LỌC THỜI GIAN (DATE RANGE FILTER)

#### TC-D501-DATE-AUT-01: Đổi khoảng thời gian 4 tuần cập nhật subtitle và query params
- **Mã Test Case:** TC-D501-DATE-AUT-01
- **Phân loại:** Date Range / Query Calculation
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Chọn 4 tuần cập nhật subtitle thành `Maison · 4 tuần gần nhất` và query params `to - from = 28` ngày.
- **Assertions:**
  - `expect(find.text('Maison · 4 tuần gần nhất'), findsOneWidget)`
  - `expect(toDate.difference(fromDate).inDays, 28)`
- **Kết quả thực tế:** PASS.

#### TC-D501-DATE-AUT-02: Đổi khoảng thời gian 12 tuần cập nhật subtitle và query params
- **Mã Test Case:** TC-D501-DATE-AUT-02
- **Phân loại:** Date Range / Query Calculation
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Chọn 12 tuần cập nhật subtitle thành `Maison · 12 tuần gần nhất` và query params `to - from = 84` ngày.
- **Assertions:**
  - `expect(find.text('Maison · 12 tuần gần nhất'), findsOneWidget)`
  - `expect(toDate.difference(fromDate).inDays, 84)`
- **Kết quả thực tế:** PASS.

---

### NHÓM 5: AUTOMATION ĐIỀU HƯỚNG & ROUTER GUARDS SAU ĐĂNG NHẬP (NAVIGATION & GUARDS)

#### TC-D501-NAV-AUT-01: Chặn vào /dashboard khi chưa đăng nhập (signedOut -> /login)
- **Mã Test Case:** TC-D501-NAV-AUT-01
- **Phân loại:** Navigation Guard / Security
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi `SessionStatus.signedOut`, truy cập `/dashboard` bị chuyển hướng về `/login`.
- **Assertion:** `expect(sessionRedirect(SessionStatus.signedOut, false, Uri.parse('http://localhost:3000/dashboard')), '/login')`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-02: Chặn vào /dashboard khi chưa hoàn tất cơ sở (onboarded=false -> /onboarding)
- **Mã Test Case:** TC-D501-NAV-AUT-02
- **Phân loại:** Onboarding Guard / Navigation
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi tài khoản chưa onboard (`onboarded = false`), truy cập `/dashboard` bị chuyển hướng về `/onboarding`.
- **Assertion:** `expect(sessionRedirect(SessionStatus.ready, false, Uri.parse('http://localhost:3000/dashboard')), '/onboarding')`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-03: Mở root / tự động chuyển hướng vào /dashboard khi đã onboarded
- **Mã Test Case:** TC-D501-NAV-AUT-03
- **Phân loại:** Default Route / UX
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh tài khoản hợp lệ khi truy cập root `/` được tự động chuyển hướng vào `/dashboard`.
- **Assertion:** `expect(sessionRedirect(SessionStatus.ready, true, Uri.parse('http://localhost:3000/')), '/dashboard')`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-04: Nút "Mở cấu hình Google" chuyển hướng tới /funnel/google-place
- **Mã Test Case:** TC-D501-NAV-AUT-04
- **Phân loại:** In-page Navigation / Action Button
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Bấm nút "Mở cấu hình Google" trong checklist chuyển hướng router sang `/funnel/google-place`.
- **Assertion:** `expect(find.text('Màn hình Google Place'), findsOneWidget)`.
- **Kết quả thực tế:** PASS.

---

## 4. CHI TIẾT 4 TEST CASES TÍCH HỢP LIVE CHƯA THỰC HIỆN (PHẠM VI BLOCKED)

| Mã Test Case | Tên ca kiểm thử | Lý do phân loại BLOCKED | Điều kiện cần để thực thi trong tương lai |
| :---: | :--- | :--- | :--- |
| **TC-D501-LIVE-01** | Đối chiếu số liệu trực tiếp trên cơ sở dữ liệu live PostgreSQL/Supabase | Môi trường test local CI offline không mở port ra Supabase Cloud và không cấu hình credential live database. | Cần staging environment với live PostgreSQL instance hoặc Docker Testcontainers. |
| **TC-D501-LIVE-02** | Xác thực chữ ký cryptographic của JWT thật qua Supabase GoTrue Auth | MockMvc sử dụng Spring Security test context (`jwt()`), chưa thực hiện bắt tay mạng xác thực khóa công khai RSA với Supabase Auth. | Cần GoTrue Auth server thật cấp token và public key endpoint. |
| **TC-D501-LIVE-03** | Kiểm tra đa người thuê (Multi-tenant RLS Isolation) giữa hai tài khoản thật | MockMvc giả lập phản hồi của `DashboardService`, không truy vấn bảng dữ liệu thật có gắn chính sách RLS. | Cần tạo 2 tài khoản tenant thật trên database có RLS enabled và assert query isolation. |
| **TC-D501-LIVE-04** | Tạo 15 bản ghi khảo sát thực tế và lưu vào bảng `survey_responses` | Frontend test sử dụng MockClient trả về JSON payload định sẵn, chưa qua API Gateway và tầng ghi dữ liệu PostgreSQL thật. | Cần End-to-End test suite chạy trên staging database tích hợp. |

---

## 5. DANH MỤC 79 AUTOMATED TEST METHODS HỒI QUY ĐÃ CHẠY LẠI (100% PASS)

Ngoài 17 kịch bản automation mới, toàn bộ **79 test methods có sẵn** trong hệ thống đã được tái thẩm định bằng các lệnh regression run:
- **Backend Regression (20 methods có sẵn):**
  - `DashboardServiceTest`: 13 methods (Tính toán tỷ lệ hài lòng, xử lý chia 0, gom nhóm tuần, Google snapshot).
  - `DashboardRepositoryTest`: 3 methods (SQL mapping, xử lý tuần khuyết).
  - `GoogleMetricsSnapshotJobTest`: 4 methods (Cron job đồng bộ Google snapshot định kỳ).
- **Frontend Regression (59 methods có sẵn):**
  - `test/dashboard_test.dart`: 20 methods (Model parsing, định dạng tiền tố/hậu tố, Widget rendering).
  - `test/admin_pages_test.dart`: 15 methods (Alert channels, billing, layout admin).
  - `test/admin_shell_pages_test.dart`: 18 methods (Responsive desktop/mobile layout).
  - `test/auth_onboarding_test.dart`: 6 methods (Auth flows, onboarding redirection).
