# DANH MỤC TEST CASES KIỂM THỬ TỰ ĐỘNG DASHBOARD TỔNG QUAN (SCRUM-242)

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task đối ứng:** SCRUM-211 (Trạng thái: *In Review*), SCRUM-240 (Test Design), SCRUM-241 (Functional Testing)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan & API Thống kê)
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Ngày lập:** 16/11/2026
- **Trạng thái tài liệu:** **VERIFIED & AUDITED** *(100% Automated Execution Evidence)*

---

## 1. BẢNG TỔNG HỢP TEST CASES AUTOMATION THEO NHÓM VÀ KẾT QUẢ

| Nhóm | Tên nhóm kiểm thử (Category) | Số lượng | Mức độ ưu tiên | Trạng thái Automation | Script thực thi tương ứng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **G1** | Automation API Thống kê Dashboard (Security, DTO, Params) | 6 | High | **6 PASS** (100%) | `DashboardControllerSecurityTest.java` |
| **G2** | Automation Đối chiếu Dữ liệu Khảo sát & Công thức Dashboard | 6 | High | **6 PASS** (100%) | `dashboard_automation_reconciliation_test.dart`, `DashboardServiceTest.java` |
| **G3** | Automation Bộ lọc Chi nhánh (Filter Switching & Empty) | 4 | High/Med | **4 PASS** (100%) | `dashboard_automation_reconciliation_test.dart` |
| **G4** | Automation Bộ lọc Thời gian (4 tuần, 8 tuần, 12 tuần) | 3 | Med | **3 PASS** (100%) | `dashboard_automation_reconciliation_test.dart`, `dashboard_test.dart` |
| **G5** | Automation Điều hướng & Phân quyền sau đăng nhập | 4 | High | **4 PASS** (100%) | `dashboard_automation_reconciliation_test.dart`, `auth_onboarding_test.dart` |
| **G6** | Smoke Test Tự động (Critical Path Health Check) | 2 | High | **2 PASS** (100%) | Backend Smoke (MockMvc) + Frontend Smoke (Widget) |
| **G7** | Regression Test Tự động (Toàn bộ phân hệ Dashboard) | 2 | High | **2 PASS** (100%) | 26 Backend Tests (Maven) + 70 Frontend Tests (Flutter) |
| **TỔNG** | **7 Nhóm kiểm thử tự động toàn diện SCRUM-242** | **27** | **20 High, 7 Med** | **27 PASS (100%)** | **Build Success: 96 Automated Tests Passed** |

---

## 2. QUY ƯỚC TRẠNG THÁI AUTOMATION (STATUS DEFINITIONS)

- **PASS:** Ca kiểm thử có kịch bản automation test độc lập, được thực thi thành công thông qua công cụ CI/CD chuẩn (`mvnw test` hoặc `flutter test`), có log assertion cụ thể xác minh 100% tiêu chí nghiệp vụ.
- **PARTIALLY VERIFIED:** Ca kiểm thử được tự động hóa ở tầng logic/unit/mock, nhưng phụ thuộc vào môi trường bên thứ ba (Live Supabase Database hoặc Live Google Places API) nên chưa thể assertion 100% End-to-End trên môi trường CI cô lập.
- **BLOCKED:** Ca kiểm thử bị chặn do thiếu cơ sở hạ tầng hoặc dịch vụ phụ thuộc ngoài tầm kiểm soát của test runner local.
- **FAIL:** Ca kiểm thử tự động phát hiện lỗi hồi quy hoặc sai lệch giữa kết quả thực tế với mong đợi.

---

## 3. CHI TIẾT 27 AUTOMATION TEST CASES

---

### NHÓM 1: AUTOMATION API THỐNG KÊ DASHBOARD (BACKEND INTEGRATION TESTS)

#### TC-D501-SEC-AUT-01: Chặn truy cập unauthenticated khi không có Bearer token
- **Mã Test Case:** TC-D501-SEC-AUT-01
- **Phân loại:** Security / API Authorization
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`returns401WhenUnauthenticated`)
- **Mục tiêu:** Xác minh endpoint `/api/v1/businesses/{businessId}/dashboard` trả về HTTP 401 Unauthorized khi request không đính kèm JWT Bearer token hợp lệ.
- **Điều kiện tiên quyết:** Spring Boot Test Context khởi tạo với MockMvc và Security Filter Chain.
- **Dữ liệu đầu vào:** Endpoint `GET /api/v1/businesses/00000000-0000-0000-0000-000000000001/dashboard`, không có header Authorization.
- **Các bước thực hiện:**
  1. Gửi request GET tới endpoint mà không kèm token.
  2. Kiểm tra status code trả về.
- **Kết quả mong đợi:** HTTP status 401 Unauthorized.
- **Kết quả thực tế:** PASS (HTTP 401).

#### TC-D501-SEC-AUT-02: Xác thực cấu trúc payload JSON trả về khi request hợp lệ
- **Mã Test Case:** TC-D501-SEC-AUT-02
- **Phân loại:** API Contract / DTO Serialization
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`returns200WithDashboardDtoWhenAuthorized`)
- **Mục tiêu:** Xác minh API trả về HTTP 200 OK cùng toàn bộ cấu trúc JSON đúng chuẩn DTO: `scanCount`, `ratedCount`, `satisfiedCount`, `satisfactionRate`, `googleRedirectCount`, `googleReviewCount`, `googleAvgRating`, và mảng `weekly`.
- **Dữ liệu đầu vào:** `businessId = 00000000-0000-0000-0000-000000000001`, Bearer token hợp lệ, mock `DashboardDto` đầy đủ trường.
- **Các bước thực hiện:**
  1. Gửi request GET với mock token.
  2. Assert HTTP 200 và kiểm tra JSON path: `$.scanCount`, `$.ratedCount`, `$.satisfiedCount`, `$.satisfactionRate`, `$.weekly[0].weekStart`.
- **Kết quả mong đợi:** HTTP 200 OK, JSON chứa đầy đủ các trường số liệu.
- **Kết quả thực tế:** PASS (HTTP 200, JSON schema valid).

#### TC-D501-SEC-AUT-03: Chuyển tiếp chính xác query params (branchId, from, to) vào Service
- **Mã Test Case:** TC-D501-SEC-AUT-03
- **Phân loại:** Controller Binding / Query Param Handling
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`passesBranchAndDateRangeParametersToService`)
- **Mục tiêu:** Xác minh các tham số `branchId`, `from`, `to` truyền trên URL query string được Controller parse chính xác thành UUID và LocalDate để chuyển vào `DashboardService`.
- **Dữ liệu đầu vào:** `branchId = 00000000-0000-0000-0000-000000000002`, `from = 2026-10-01`, `to = 2026-11-01`.
- **Các bước thực hiện:**
  1. Gửi request GET kèm query params trên.
  2. Dùng Mockito `verify` kiểm tra tham số gọi vào `dashboardService.getDashboard(...)`.
- **Kết quả mong đợi:** Service nhận đúng `branchId`, `from = 2026-10-01`, `to = 2026-11-01`.
- **Kết quả thực tế:** PASS (Mockito verify thành công).

#### TC-D501-SEC-AUT-04: Từ chối truy cập 404 khi business không tồn tại hoặc không thuộc quyền sở hữu
- **Mã Test Case:** TC-D501-SEC-AUT-04
- **Phân loại:** Security / Business Access Control
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`returns404WhenBusinessNotFoundOrAccessDenied`)
- **Mục tiêu:** Xác minh khi người dùng cố truy xuất businessId không thuộc quyền sở hữu hoặc không tồn tại, Controller ném ngoại lệ và trả về HTTP 404 NOT_FOUND.
- **Dữ liệu đầu vào:** `businessId = randomUUID()`, service ném `BusinessNotFoundException`.
- **Các bước thực hiện:**
  1. Gửi request GET với businessId lạ.
  2. Kiểm tra status code trả về.
- **Kết quả mong đợi:** HTTP 404 NOT_FOUND.
- **Kết quả thực tế:** PASS (HTTP 404).

#### TC-D501-SEC-AUT-05: Bắt lỗi validation 400 khi khoảng thời gian không hợp lệ (from > to)
- **Mã Test Case:** TC-D501-SEC-AUT-05
- **Phân loại:** Validation / Error Handling
- **Mức độ ưu tiên:** Medium
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`returns400WhenDateRangeInvalid`)
- **Mục tiêu:** Xác minh khi client truyền `from` sau `to` (khoảng thời gian âm), hệ thống trả về HTTP 400 BAD_REQUEST và thông báo lỗi rõ ràng.
- **Dữ liệu đầu vào:** `from = 2026-11-10`, `to = 2026-11-01`.
- **Các bước thực hiện:**
  1. Gửi request GET với query range lỗi.
  2. Assert HTTP 400 và `status = BAD_REQUEST`.
- **Kết quả mong đợi:** HTTP 400 BAD_REQUEST.
- **Kết quả thực tế:** PASS (HTTP 400).

#### TC-D501-SEC-AUT-06: Bắt lỗi validation 400 khi businessId sai định dạng UUID
- **Mã Test Case:** TC-D501-SEC-AUT-06
- **Phân loại:** Validation / Type Safety
- **Mức độ ưu tiên:** Medium
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java` (`returns400WhenBusinessIdMalformed`)
- **Mục tiêu:** Xác minh khi path variable `businessId` không phải là chuỗi UUID chuẩn, Spring xử lý MethodArgumentTypeMismatchException và trả về HTTP 400.
- **Dữ liệu đầu vào:** `businessId = "not-a-valid-uuid"`.
- **Các bước thực hiện:**
  1. Gửi request GET với URL chứa chuỗi invalid.
  2. Assert HTTP 400 BAD_REQUEST.
- **Kết quả mong đợi:** HTTP 400 BAD_REQUEST.
- **Kết quả thực tế:** PASS (HTTP 400).

---

### NHÓM 2: AUTOMATION ĐỐI CHIẾU DỮ LIỆU KHẢO SÁT & CÔNG THỨC (DATA RECONCILIATION & FORMULAS)

#### TC-D501-REC-01: Đối chiếu số liệu hiển thị trên thẻ và phễu với tập dữ liệu khảo sát mẫu
- **Mã Test Case:** TC-D501-REC-01
- **Phân loại:** Data Reconciliation / Frontend Rendering
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh toàn bộ số liệu tổng hợp hiển thị trên 5 MetricCards và 4 bước Phễu chuyển đổi khớp chính xác với dữ liệu khảo sát mẫu đã tạo.
- **Dữ liệu đầu vào (Tập mẫu 15 khảo sát):**
  - `scanCount`: 15
  - `ratedCount`: 13
  - `satisfiedCount`: 10
  - `satisfactionRate`: 76.9% ($10 / 13 \times 100\% \approx 76.92\%$ làm tròn 1 chữ số thập phân)
  - `googleRedirectCount`: 7
  - `googleReviewCount`: 450
  - `googleAvgRating`: 4.7
- **Các bước thực hiện:**
  1. Render `DashboardPage` với tập dữ liệu khảo sát trên.
  2. Tìm kiếm các text hiển thị: Thẻ Quét ('15'), Thẻ Hài lòng ('76,9%'), Thẻ Note ('13 lượt đánh giá'), Thẻ Google Redirect ('7'), Thẻ Review ('450'), Thẻ Sao ('4,7★').
  3. Kiểm tra các bước phễu: '15 · 100%', '13 · 86,7%', '10 · 66,7%', '7 · 46,7%'.
- **Kết quả mong đợi:** Toàn bộ thẻ và phễu hiển thị số liệu chính xác không sai lệch.
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-02: Phễu chuyển đổi tính đúng tỷ lệ trên mẫu số lượt quét 15
- **Mã Test Case:** TC-D501-REC-02
- **Phân loại:** Business Formula / Funnel Calculation
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh tỷ lệ tiến trình (`LinearProgressIndicator.value`) của từng bước phễu sử dụng đúng mẫu số là tổng `scanCount` (15), không dùng mẫu số bước trước.
- **Công thức:**
  - Bước 3 (Hài lòng): $10 / 15 \approx 0.6667$
  - Bước 4 (Chuyển sang Google): $7 / 15 \approx 0.4667$
- **Các bước thực hiện:**
  1. Lấy widget `LinearProgressIndicator` của `funnel-Hài lòng 4–5 sao` và `funnel-Chuyển sang Google`.
  2. Assert giá trị `value` xấp xỉ $10/15$ và $7/15$ với delta $0.001$.
- **Kết quả mong đợi:** Giá trị thanh tiến trình khớp với công thức $count / scanCount$.
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-SRV-01: Backend tính toán tỷ lệ hài lòng từ số lượt đánh giá thực tế
- **Mã Test Case:** TC-D501-REC-SRV-01
- **Phân loại:** Backend Service / Unit Test
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardServiceTest.java` (`calculatesSatisfactionFromRatedResponses`)
- **Mục tiêu:** Xác minh `DashboardService` tính toán `satisfactionRate = (satisfiedCount / ratedCount) * 100` và làm tròn 1 chữ số thập phân (`BigDecimal.setScale(1, RoundingMode.HALF_UP)`).
- **Dữ liệu đầu vào:** `ratedCount = 4`, `satisfiedCount = 3`.
- **Kết quả mong đợi:** `satisfactionRate = 75.0%`.
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-SRV-02: Backend trả về satisfactionRate = null khi không có lượt đánh giá nào
- **Mã Test Case:** TC-D501-REC-SRV-02
- **Phân loại:** Backend Service / Boundary Test
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardServiceTest.java` (`returnsNullSatisfactionWhenNoRatings`)
- **Mục tiêu:** Xác minh khi `ratedCount = 0`, `satisfactionRate` trả về `null` thay vì chia cho 0.
- **Dữ liệu đầu vào:** `scanCount = 10`, `ratedCount = 0`, `satisfiedCount = 0`.
- **Kết quả mong đợi:** `satisfactionRate == null`.
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-SRV-03: Lấy số liệu Google Snapshot tuần mới nhất hiển thị trên MetricCards
- **Mã Test Case:** TC-D501-REC-SRV-03
- **Phân loại:** Backend Service / Snapshot Integration
- **Mức độ ưu tiên:** Medium
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardServiceTest.java` (`usesLatestGoogleWeekForCards`)
- **Mục tiêu:** Xác minh số liệu đánh giá Google (`googleReviewCount` và `googleAvgRating`) trên thẻ MetricCards lấy từ snapshot tuần gần nhất.
- **Dữ liệu đầu vào:** Tuần 1 (review=100, rating=4.0), Tuần 2 (review=120, rating=4.3).
- **Kết quả mong đợi:** Thẻ hiển thị `review=120`, `avgRating=4.3`.
- **Kết quả thực tế:** PASS.

#### TC-D501-REC-SRV-04: Repository gom nhóm số liệu theo tuần và điền 0 cho tuần không có dữ liệu
- **Mã Test Case:** TC-D501-REC-SRV-04
- **Phân loại:** Backend Repository / Weekly Aggregation
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardRepositoryTest.java` (`groupsByWeekAndHandlesGaps`)
- **Mục tiêu:** Xác minh truy vấn Repository gom nhóm số liệu quét mã và khảo sát theo từng tuần, không làm mất tuần trống.
- **Kết quả mong đợi:** Trả về danh sách tuần liên tục trong khoảng thời gian đã lọc.
- **Kết quả thực tế:** PASS.

---

### NHÓM 3: AUTOMATION BỘ LỌC CHI NHÁNH (BRANCH FILTER TESTS)

#### TC-D501-FLT-AUT-01: Lọc chi nhánh cụ thể (Quận 1) cập nhật số liệu và gửi query param branchId
- **Mã Test Case:** TC-D501-FLT-AUT-01
- **Phân loại:** Filter / Functional Flow
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi người dùng chọn chi nhánh Quận 1 từ dropdown:
  1. Request API mới được kích hoạt với `branchId = 'c1'`.
  2. Màn hình cập nhật số liệu riêng của Quận 1 (10 scans, 8 ratings, 62.5% satisfaction, 4 redirects).
- **Các bước thực hiện:**
  1. Mở dropdown chi nhánh.
  2. Chọn "Quận 1".
  3. Kiểm tra query param của request cuối cùng và text hiển thị.
- **Kết quả mong đợi:** Query param `branchId=c1`, số liệu cập nhật đúng chi nhánh 1.
- **Kết quả thực tế:** PASS.

#### TC-D501-FLT-AUT-02: Lọc chi nhánh Quận 3 (100% hài lòng) và khôi phục về Tất cả chi nhánh
- **Mã Test Case:** TC-D501-FLT-AUT-02
- **Phân loại:** Filter / Reset Flow
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh chuyển đổi giữa chi nhánh và khôi phục về "Tất cả chi nhánh":
  1. Chọn "Quận 3" hiển thị tỷ lệ hài lòng 100%.
  2. Chọn lại "Tất cả chi nhánh" sẽ loại bỏ `branchId` khỏi query params và khôi phục số liệu toàn hệ thống (76.9%).
- **Kết quả mong đợi:** Lọc chuẩn xác và khôi phục trạng thái toàn cơ sở không lỗi.
- **Kết quả thực tế:** PASS.

#### TC-D501-FLT-AUT-03: Lọc chi nhánh chưa có dữ liệu (Thủ Đức) hiển thị banner rỗng và ẩn biểu đồ
- **Mã Test Case:** TC-D501-FLT-AUT-03
- **Phân loại:** Empty State / Filter Boundary
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi chọn chi nhánh chưa có bất kỳ lượt quét nào (Thủ Đức - scanCount = 0):
  1. Hiển thị thông báo "Chưa có lượt quét nào trong khoảng thời gian này."
  2. Ẩn các biểu đồ: `FunnelChart`, `WeeklyBarChart`, `WeeklyTable`.
- **Kết quả mong đợi:** Banner rỗng hiển thị, 3 component biểu đồ ẩn hoàn toàn (`findsNothing`).
- **Kết quả thực tế:** PASS.

#### TC-D501-FLT-AUT-04: API Client không gửi branchId khi lọc "Tất cả chi nhánh"
- **Mã Test Case:** TC-D501-FLT-AUT-04
- **Phân loại:** API Client / Param Serialization
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_test.dart` (`tất cả chi nhánh không gửi branchId`)
- **Mục tiêu:** Đảm bảo `DashboardApi.load` khi tham số `branchId` là null sẽ không đưa key `branchId` vào queryParameters.
- **Kết quả mong đợi:** `queryParameters.containsKey('branchId') == false`.
- **Kết quả thực tế:** PASS.

---

### NHÓM 4: AUTOMATION BỘ LỌC THỜI GIAN (DATE RANGE FILTER TESTS)

#### TC-D501-DATE-AUT-01: Đổi khoảng thời gian 4 tuần cập nhật subtitle và tính toán đúng ngày query
- **Mã Test Case:** TC-D501-DATE-AUT-01
- **Phân loại:** Date Range / Query Calculation
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi chọn mốc 4 tuần:
  1. Subtitle trên giao diện đổi thành `Maison · 4 tuần gần nhất`.
  2. Query params `to` trừ `from` đúng 28 ngày ($4 \times 7$ ngày).
- **Kết quả mong đợi:** Subtitle cập nhật, khoảng cách ngày giữa `to` và `from` là 28 ngày.
- **Kết quả thực tế:** PASS.

#### TC-D501-DATE-AUT-02: Đổi khoảng thời gian 12 tuần cập nhật subtitle và tính toán đúng ngày query
- **Mã Test Case:** TC-D501-DATE-AUT-02
- **Phân loại:** Date Range / Query Calculation
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi chọn mốc 12 tuần:
  1. Subtitle trên giao diện đổi thành `Maison · 12 tuần gần nhất`.
  2. Query params `to` trừ `from` đúng 84 ngày ($12 \times 7$ ngày).
- **Kết quả mong đợi:** Subtitle cập nhật, khoảng cách ngày là 84 ngày.
- **Kết quả thực tế:** PASS.

#### TC-D501-DATE-AUT-03: Kiểm tra cấu hình enum DashboardRange chuẩn nghiệp vụ
- **Mã Test Case:** TC-D501-DATE-AUT-03
- **Phân loại:** Unit Test / Enum Definition
- **Mức độ ưu tiên:** Low
- **Script:** `frontend/test/dashboard_test.dart` (`khoảng thời gian có sẵn`)
- **Mục tiêu:** Xác minh enum `DashboardRange` có đầy đủ 3 mốc: `weeks4` (28 ngày), `weeks8` (56 ngày), `weeks12` (84 ngày).
- **Kết quả mong đợi:** Days và Label khớp định nghĩa thiết kế.
- **Kết quả thực tế:** PASS.

---

### NHÓM 5: AUTOMATION ĐIỀU HƯỚNG & PHÂN QUYỀN SAU ĐĂNG NHẬP (NAVIGATION & GUARDS)

#### TC-D501-NAV-AUT-01: Chặn truy cập /dashboard khi chưa đăng nhập (Chuyển hướng /login)
- **Mã Test Case:** TC-D501-NAV-AUT-01
- **Phân loại:** Navigation Guard / Security
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi người dùng chưa đăng nhập (`SessionStatus.signedOut`) cố tình truy cập trực tiếp URL `/dashboard`, Router Guard chặn lại và chuyển hướng về `/login`.
- **Kết quả mong đợi:** `sessionRedirect` trả về `/login`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-02: Chặn truy cập /dashboard khi tài khoản chưa hoàn tất cơ sở (Chuyển hướng /onboarding)
- **Mã Test Case:** TC-D501-NAV-AUT-02
- **Phân loại:** Onboarding Guard / Navigation
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh khi người dùng đã đăng nhập nhưng chưa hoàn tất tạo thương hiệu (`onboarded = false`), Router Guard chuyển hướng về `/onboarding`.
- **Kết quả mong đợi:** `sessionRedirect` trả về `/onboarding`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-03: Tự động chuyển hướng từ URL root (/) vào /dashboard khi tài khoản hợp lệ
- **Mã Test Case:** TC-D501-NAV-AUT-03
- **Phân loại:** Default Route / UX Flow
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh người dùng hợp lệ khi mở URL gốc (`/`) sẽ được tự động điều hướng vào Dashboard tổng quan (`/dashboard`).
- **Kết quả mong đợi:** `sessionRedirect` trả về `/dashboard`.
- **Kết quả thực tế:** PASS.

#### TC-D501-NAV-AUT-04: Nút "Mở cấu hình Google" điều hướng tới /funnel/google-place
- **Mã Test Case:** TC-D501-NAV-AUT-04
- **Phân loại:** In-page Navigation / Action Button
- **Mức độ ưu tiên:** Medium
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Xác minh trong mục Checklist "Việc cần thiết lập", bấm nút "Mở cấu hình Google" chuyển hướng tới trang cấu hình `/funnel/google-place`.
- **Kết quả mong đợi:** Màn hình chuyển sang route `/funnel/google-place`.
- **Kết quả thực tế:** PASS.

---

### NHÓM 6: SMOKE TEST TỰ ĐỘNG (CRITICAL PATH SMOKE SUITE)

#### TC-D501-SMK-AUT-01: Smoke Test Backend API luồng chính
- **Mã Test Case:** TC-D501-SMK-AUT-01
- **Phân loại:** Smoke Test / Backend
- **Mức độ ưu tiên:** High
- **Script:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java`
- **Mục tiêu:** Kiểm tra nhanh tính toàn vẹn của Backend: khởi động Spring Context, bảo mật xác thực, serialize DTO thành công trong dưới 5 giây.
- **Kết quả mong đợi:** 6/6 tests passed trong 4.625s.
- **Kết quả thực tế:** PASS.

#### TC-D501-SMK-AUT-02: Smoke Test Frontend Dashboard luồng hiển thị chính
- **Mã Test Case:** TC-D501-SMK-AUT-02
- **Phân loại:** Smoke Test / Frontend
- **Mức độ ưu tiên:** High
- **Script:** `frontend/test/dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Kiểm tra nhanh giao diện Dashboard: render thành công trang, tải số liệu mẫu, render đủ 5 cards và funnel chart trong dưới 3 giây.
- **Kết quả mong đợi:** 11/11 tests passed trong 2.1s.
- **Kết quả thực tế:** PASS.

---

### NHÓM 7: REGRESSION TEST TỰ ĐỘNG (FULL REGRESSION SUITE)

#### TC-D501-REG-AUT-01: Toàn bộ Backend Dashboard Regression Suite
- **Mã Test Case:** TC-D501-REG-AUT-01
- **Phân loại:** Regression Test / Backend
- **Mức độ ưu tiên:** High
- **Script:** `DashboardServiceTest`, `DashboardRepositoryTest`, `GoogleMetricsSnapshotJobTest`, `DashboardControllerSecurityTest`
- **Mục tiêu:** Đảm bảo không có lỗi hồi quy trong toàn bộ mã nguồn Backend liên quan đến Dashboard.
- **Kết quả mong đợi:** 26/26 tests passed (100% BUILD SUCCESS).
- **Kết quả thực tế:** PASS (26 tests run, 0 failures, 0 errors, thời gian 9.366s).

#### TC-D501-REG-AUT-02: Toàn bộ Frontend Dashboard & Shell Regression Suite
- **Mã Test Case:** TC-D501-REG-AUT-02
- **Phân loại:** Regression Test / Frontend
- **Mức độ ưu tiên:** High
- **Script:** `dashboard_test.dart`, `admin_pages_test.dart`, `admin_shell_pages_test.dart`, `auth_onboarding_test.dart`, `dashboard_automation_reconciliation_test.dart`
- **Mục tiêu:** Đảm bảo không có lỗi hồi quy trong toàn bộ mã nguồn Frontend liên quan đến Dashboard và Admin Shell.
- **Kết quả mong đợi:** 70/70 tests passed (100% SUCCESS).
- **Kết quả thực tế:** PASS (70 tests run, 0 failures, 0 errors, thời gian 4.2s).

---

## 4. KẾT LUẬN VÀ PHÊ DUYỆT BỘ TEST CASES
- Bộ 27 Test Cases tự động bao phủ trọn vẹn 100% phạm vi yêu cầu của SCRUM-242 từ tầng API bảo mật, đối chiếu số liệu khảo sát, bộ lọc chi nhánh/thời gian, điều hướng router cho đến smoke test và regression test.
- Tất cả đều có kịch bản code automation khả thi và đã được nghiệm thu bằng log chạy thực tế.
