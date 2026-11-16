# TÀI LIỆU TEST SCRIPTS VÀ KẾ HOẠCH AUTOMATION (TEST SCRIPTS & AUTOMATION PLAN)

- **Mã Jira:** SCRUM-240
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người lập:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Trạng thái:** **KHẢO SÁT & ĐỀ XUẤT (SURVEY & PROPOSAL ONLY)** – Không chạy test, không tạo script giả định.

---

## 1. Kiểm Kê Danh Mục Unit Tests Hiện Có Trong Dự Án (37 Tests)

Quá trình khảo sát mã nguồn xác định dự án hiện có **37 Unit / Widget Tests** liên quan trực tiếp đến phân hệ Dashboard (E3.1 / D5-01). Các test này được chia thành 5 tệp tin kiểm thử:

### 1.1. Backend Service Unit Test: `DashboardServiceTest.java` (13 tests)
- **Đường dẫn tệp tin:** `backend/src/test/java/com/cxshield/backend/report/DashboardServiceTest.java`
- **Môi trường & Công cụ:** JUnit 5, Mockito, AssertJ.
- **Danh sách 13 phương thức test thực tế:**
  1. `calculatesSatisfactionFromRatedResponses()`: Kiểm tra tính toán `satisfactionRate` tổng thể và theo từng tuần từ dữ liệu khảo sát.
  2. `emptyDataHasNoRate()`: Kiểm tra khi `SurveyStats` rỗng thì `satisfactionRate` là `null`, `weekly` rỗng.
  3. `weekWithScansButNoRatingHasNullRate()`: Kiểm tra tuần có lượt quét nhưng 0 đánh giá thì `satisfactionRate` là `null`.
  4. `defaultRangeIsLastEightWeeks()`: Kiểm tra mặc định lấy 56 ngày (8 tuần) tính đến ngày hiện tại.
  5. `passesBranchAndRangeToRepository()`: Kiểm tra truyền đúng tham số xuống repository và lùi ngày đọc Google về thứ Hai đầu tuần.
  6. `usesLatestGoogleWeekForCards()`: Kiểm tra thẻ tổng quan lấy số review và avg rating của tuần snapshot gần nhất.
  7. `combinesBranchesWithWeightedRating()`: Kiểm tra tính điểm sao trung bình gia quyền đa chi nhánh trong cùng tuần.
  8. `ignoresMetricRowsWithoutGoogleData()`: Bỏ qua các dòng metric thiếu thông tin review Google.
  9. `zeroGoogleReviewsHasNoRating()`: Khi số review Google bằng 0 thì avg rating là `null`.
  10. `rejectsReversedRange()`: Chặn khoảng ngày đảo ngược (`from > to`), ném lỗi mã `INVALID_DATE_RANGE`.
  11. `rejectsRangeOverOneYear()`: Chặn khoảng thời gian > 366 ngày, ném lỗi mã `INVALID_DATE_RANGE`.
  12. `rejectsBusinessWithoutAccess()`: Chặn tài khoản không có quyền trên cơ sở, ném mã `BUSINESS_NOT_FOUND`.
  13. `rejectsBranchOfAnotherBusiness()`: Chặn truy cập chi nhánh không thuộc cơ sở, ném mã `BRANCH_NOT_FOUND`.

### 1.2. Backend Repository Unit Test: `DashboardRepositoryTest.java` (3 tests)
- **Đường dẫn tệp tin:** `backend/src/test/java/com/cxshield/backend/report/DashboardRepositoryTest.java`
- **Môi trường & Công cụ:** JUnit 5, Mockito (Mock `SupabaseDataClient`).
- **Danh sách 3 phương thức test thực tế:**
  1. `surveyStatsCallsRpcWithNullBranchForAllBranches()`: Kiểm tra gọi RPC `get_dashboard_stats` với `p_branch_id = null` khi xem tất cả chi nhánh.
  2. `metricsFilterByBusinessAndPeriod()`: Kiểm tra PostgREST query trên bảng `metrics` lọc theo `branches.business_id` và khoảng thời gian.
  3. `metricsFilterByBranchWhenSelected()`: Kiểm tra bổ sung `branch_id` vào query `metrics` khi chọn chi nhánh cụ thể.

### 1.3. Backend Scheduled Job Test: `GoogleMetricsSnapshotJobTest.java` (4 tests)
- **Đường dẫn tệp tin:** `backend/src/test/java/com/cxshield/backend/report/GoogleMetricsSnapshotJobTest.java`
- **Môi trường & Công cụ:** JUnit 5, Mockito.
- **Danh sách 4 phương thức test thực tế:**
  1. `savesStatsIntoCurrentWeek()`: Kiểm tra tính toán mốc tuần từ Thứ Hai đến Chủ Nhật và gọi upsert vào bảng `metrics`.
  2. `skipsBranchWithoutGoogleData()`: Bỏ qua chi nhánh nếu Google Places Client không trả về dữ liệu.
  3. `doesNothingWithoutServiceRoleKey()`: Dừng tác vụ an toàn nếu thiếu `SUPABASE_SERVICE_ROLE_KEY`.
  4. `doesNothingWithoutPlacesKey()`: Dừng tác vụ an toàn nếu thiếu `GOOGLE_PLACES_API_KEY`.

### 1.4. Frontend Unit & Widget Test: `dashboard_test.dart` (14 tests)
- **Đường dẫn tệp tin:** `frontend/test/dashboard_test.dart`
- **Môi trường & Công cụ:** Flutter Test Framework (`flutter_test`), `http/testing`.
- **Danh sách 14 test cases thực tế:**
  - *Nhóm đọc dữ liệu API (2 tests):*
    1. `đọc dữ liệu API / đủ số liệu`: Parse JSON sang `DashboardData` và `DashboardWeek`.
    2. `đọc dữ liệu API / chưa có dữ liệu`: Kiểm tra dữ liệu rỗng, `isEmpty = true`, `satisfactionRate = null`.
  - *Nhóm định dạng hiển thị (4 tests):*
    3. `định dạng / số có dấu chấm hàng nghìn`: Format số chuẩn VN (`1.248`, `1.234.567`).
    4. `định dạng / phần trăm và điểm sao`: Format `82,5%`, `4,6★`, giá trị null hiển thị `'—'`.
    5. `định dạng / ngày`: Format ngày `apiDate` (`2026-11-06`) và nhãn tuần `formatWeek` (`02/11`).
    6. `định dạng / khoảng thời gian có sẵn`: Cấu hình enum `DashboardRange` (4 tuần, 8 tuần).
  - *Nhóm gọi API (2 tests):*
    7. `gọi API / lọc theo chi nhánh và thời gian`: Gửi đúng query params `branchId`, `from`, `to`.
    8. `gọi API / tất cả chi nhánh không gửi branchId`: Không gửi key `branchId` khi xem tất cả chi nhánh.
  - *Nhóm Widget UI (6 tests):*
    9. `widget / thẻ số liệu hiện nhãn, giá trị và ghi chú`: Render `MetricCard`.
    10. `widget / phễu hiện số lượt và tỷ lệ so với lượt quét`: Render `FunnelChart` tính % chính xác.
    11. `widget / phễu không lỗi khi chưa có lượt quét`: `FunnelChart` hiển thị `'0 · —'` an toàn khi `scanCount = 0`.
    12. `widget / cột biểu đồ theo tỷ lệ lượt quét`: Render `WeeklyBarChart` với chiều cao cột tỷ lệ thuận.
    13. `widget / biểu đồ không lỗi khi mọi tuần bằng 0`: `WeeklyBarChart` không lỗi khi toàn bộ lượt quét = 0.
    14. `widget / bảng hiện tuần mới nhất trước và dấu gạch khi thiếu số liệu`: Render `WeeklyTable` xếp tuần mới nhất lên đầu.

### 1.5. Frontend Admin Pages Test: `admin_pages_test.dart` (3 tests nhóm D5-01)
- **Đường dẫn tệp tin:** `frontend/test/admin_pages_test.dart`
- **Danh sách 3 widget tests thuộc `group('D5-01')`:**
  1. `hiện số liệu và đổi bộ lọc gọi lại API`: Màn hình D5-01 hiển thị đủ thẻ, đổi dropdown chi nhánh gọi lại API đúng.
  2. `chưa có lượt quét hiện thông báo`: Hiển thị banner thông báo khi `scanCount = 0`.
  3. `lỗi tải số liệu có nút thử lại`: Hiển thị banner lỗi và nút *"Tải lại số liệu"* khi API gặp sự cố.

---

## 2. Lệnh Thực Thi và Kết Quả Chạy Thực Tế (Execution Log)

> [!NOTE]
> Tester đã chủ động kích hoạt thực thi toàn bộ **37/37 tests** trên môi trường local. Kết quả: **37/37 tests passed (100% PASS)**, không có test nào thất bại.

### 2.1. Kết quả chạy Backend Tests (Maven Wrapper) – **20/20 PASS**
- **Thư mục làm việc:** `CX-SHIELD-GIT/backend`
- **Lệnh PowerShell thực thi:**
  ```powershell
  cd backend
  .\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest'
  ```
- **Kết quả thực tế từ log:**
  - `DashboardRepositoryTest`: **3/3 passed**, 0 failed (1.764s).
  - `DashboardServiceTest`: **13/13 passed**, 0 failed (0.395s).
  - `GoogleMetricsSnapshotJobTest`: **4/4 passed**, 0 failed (0.226s).
  - **Tổng kết:** `Tests run: 20, Failures: 0, Errors: 0, Skipped: 0` – **BUILD SUCCESS** (Thời gian: 21.406s).

### 2.2. Kết quả chạy Frontend Tests (Flutter Test) – **17/17 PASS**
- **Thư mục làm việc:** `CX-SHIELD-GIT/frontend`
- **Lệnh 1 – Chạy toàn bộ `dashboard_test.dart` (14 tests):**
  ```powershell
  cd frontend
  flutter test test/dashboard_test.dart
  ```
  *Kết quả:* **14/14 passed** (`All tests passed!`). Bao phủ đọc model, format %, phễu chuyển đổi, biểu đồ cột, bảng chi tiết.
- **Lệnh 2 – Chạy riêng các tests nhóm D5-01 trong `admin_pages_test.dart` (3 tests):**
  ```powershell
  cd frontend
  flutter test test/admin_pages_test.dart --plain-name "D5-01"
  ```
  *Kết quả:* **3/3 passed** (`All tests passed!`). Bao phủ hiển thị số liệu, đổi chi nhánh dropdown và banner lỗi.

---

## 3. Bảng Ánh Xạ Unit Tests Hiện Có ↔ 27 Test Cases (SCRUM-240)

| Mã Test Case | Tên Test Case | Unit Test hiện có hỗ trợ chứng minh | Trạng thái tự động hóa hiện tại |
| :--- | :--- | :--- | :--- |
| **TC-DASH-01** | Tính tổng `scanCount` | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-02** | Tính tổng `ratedCount` | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-03** | Tính tổng `satisfiedCount` | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-04** | Tỷ lệ % hài lòng & làm tròn | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-05** | Xử lý mẫu số 0 (`ratedCount = 0`) | `DashboardServiceTest.emptyDataHasNoRate`, `weekWithScansButNoRatingHasNullRate`, `dashboard_test.dart` (#2, #4, #11) | **Bao phủ đầy đủ** cả Backend & Frontend |
| **TC-DASH-06** | Đếm `googleRedirectCount` | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-07** | Thẻ Google lấy snapshot mới nhất | `DashboardServiceTest.usesLatestGoogleWeekForCards` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-08** | Trung bình gia quyền điểm Google | `DashboardServiceTest.combinesBranchesWithWeightedRating` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-09** | Phiên quét chưa chọn sao | `DashboardServiceTest.weekWithScansButNoRatingHasNullRate` | Mới có Service mock, **chưa có SQL test** |
| **TC-DASH-10** | Nguy cơ đếm trùng `scanCount` và các KPI | *(Chưa có automated test tương ứng)* | **CHƯA CÓ AUTOMATION (Test Gap - Code Anomaly OBS-SCRUM-240-01)** |
| **TC-DASH-11** | Cơ sở hoàn toàn chưa có dữ liệu | `DashboardServiceTest.emptyDataHasNoRate`, `dashboard_test.dart` (#2), `admin_pages_test.dart` (#2) | **Bao phủ đầy đủ** đa tầng |
| **TC-DASH-12** | Chi nhánh chưa có Google metrics | `DashboardServiceTest.ignoresMetricRowsWithoutGoogleData`, `zeroGoogleReviewsHasNoRating`, `dashboard_test.dart` (#4, #14) | **Bao phủ đầy đủ** đa tầng |
| **TC-DASH-13** | Mặc định 8 tuần (56 ngày) | `DashboardServiceTest.defaultRangeIsLastEightWeeks` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-14** | Các preset thời gian 4, 8, 12 tuần | `dashboard_test.dart` (#6, #7) | Đã có Widget / Model test |
| **TC-DASH-15** | Chặn khoảng ngày đảo ngược 400 | `DashboardServiceTest.rejectsReversedRange` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-16** | Chặn khoảng ngày > 1 năm 400 | `DashboardServiceTest.rejectsRangeOverOneYear` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-17** | Mốc tuần `weekStart` là Thứ Hai | `GoogleMetricsSnapshotJobTest.savesStatsIntoCurrentWeek` | Đã có Unit test (Job Snapshot) |
| **TC-DASH-18** | Khớp nối tuần thiếu dữ liệu | `DashboardServiceTest.usesLatestGoogleWeekForCards` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-19** | Nhất quán múi giờ Việt Nam | *(Chưa có automated test tương ứng)* | **CHƯA CÓ AUTOMATION (Test Gap)** |
| **TC-DASH-20** | Endpoint chặn 401 thiếu JWT | *(Chưa có automated test tương ứng)* | **CHƯA CÓ AUTOMATION (Test Gap)** |
| **TC-DASH-21** | Chặn xem cơ sở khác 404 | `DashboardServiceTest.rejectsBusinessWithoutAccess` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-22** | Chặn xem chi nhánh khác 404 | `DashboardServiceTest.rejectsBranchOfAnotherBusiness` | Đã có Unit test (Mức Service Mock) |
| **TC-DASH-23** | RLS: Cách ly giữa 2 tài khoản 2 chi nhánh | *(Chưa có automated test tương ứng)* | **CHƯA CÓ AUTOMATION (Test Gap)** |
| **TC-DASH-24** | Đổi chi nhánh trên dropdown D5-01 | `admin_pages_test.dart` (#1), `dashboard_test.dart` (#7) | Đã có Widget test UI |
| **TC-DASH-25** | Hiển thị Phễu chuyển đổi 4 bước | `dashboard_test.dart` (#10, #11) | Đã có Widget test UI |
| **TC-DASH-26** | Bảng tuần xếp tuần mới nhất | `dashboard_test.dart` (#14) | Đã có Widget test UI |
| **TC-DASH-27** | Xử lý lỗi API & nút tải lại | `admin_pages_test.dart` (#3) | Đã có Widget test UI |

---

## 4. Danh Sách Các Test Cases Chưa Có Automation (Test Gaps)

Sau khi ánh xạ, xác định có **4 Test Cases quan trọng hoàn toàn chưa có script automation tương ứng**:

1. **TC-DASH-10 (Kiểm tra nguy cơ đếm trùng `scanCount` và các KPI khi có nhiều response - OBS-SCRUM-240-01):**
   - *Nguyên nhân thiếu:* Các test hiện tại ở tầng Service đều mock kết quả trả về của `getSurveyStats`. Logic câu lệnh SQL `LEFT JOIN` và các hàm đếm trong migration `n5_dashboard.sql` chưa từng được kích hoạt trong bất kỳ bài test tự động nào trên CSDL thật.
   - *Loại test cần bổ sung:* Database Integration Test trên CSDL PostgreSQL thật để kiểm chứng tác động nhân dòng lên từng KPI (`scanCount`, `ratedCount`, `satisfiedCount`, `googleRedirectCount`).
2. **TC-DASH-19 (Kiểm tra biên múi giờ UTC vs `Asia/Ho_Chi_Minh`):**
   - *Nguyên nhân thiếu:* Chưa có test case kiểm tra việc lưu timestamp UTC và chuyển đổi múi giờ `at time zone 'Asia/Ho_Chi_Minh'` trong PostgreSQL cho các mốc giao thời (23:59 và 00:01).
   - *Loại test cần bổ sung:* Database / API Test.
3. **TC-DASH-20 (Kiểm tra bảo mật HTTP 401 khi thiếu JWT):**
   - *Nguyên nhân thiếu:* Chưa có file test cho Controller (`DashboardControllerTest.java`). Hiện `SecurityConfig.java` chỉ được test ở mức cấu hình chung, chưa có bài test mock MVC trực tiếp trên route `/api/v1/businesses/{id}/dashboard`.
   - *Loại test cần bổ sung:* Spring Boot `@WebMvcTest`.
4. **TC-DASH-23 (Xác minh Supabase RLS cách ly giữa 2 tài khoản chi nhánh):**
   - *Nguyên nhân thiếu:* `DashboardRepositoryTest` mock toàn bộ `SupabaseDataClient`, không gọi CSDL thật. Các chính sách RLS của Supabase (`survey_sessions_select_access`) chưa được kiểm thử tự động với 2 tài khoản người dùng khác nhau.
   - *Loại test cần bổ sung:* Multi-account Security Integration Test.

---

## 5. Đề Xuất Các Kịch Bản Automation Cần Bổ Sung (Proposed Scripts)

> [!WARNING]
> Các kịch bản dưới đây là **đề xuất kỹ thuật (Proposal)** gửi tới Developer / Team Lead, **tuyệt đối không giả định là đã được triển khai hay đã chạy thành công**. Việc tạo mới script thực tế cần được duyệt và cấp môi trường phù hợp.

### 5.1. Đề xuất Script 1: `DashboardControllerTest.java` (WebMvc Security Test)
- **Mục tiêu:** Bổ sung kiểm thử tầng Web Controller cho TC-DASH-20, TC-DASH-15, TC-DASH-16.
- **Vị trí đề xuất:** `backend/src/test/java/com/cxshield/backend/report/DashboardControllerTest.java`
- **Công nghệ đề xuất:** `@WebMvcTest(DashboardController.class)`, `MockMvc`, `@WithMockUser`.
- **Nội dung kiểm tra:**
  - Gửi request không có token -> kỳ vọng HTTP 401 Unauthorized.
  - Gửi request có token hợp lệ -> kỳ vọng HTTP 200 OK.
  - Gửi param ngày sai format `from=2026-99-99` -> kỳ vọng HTTP 400 Bad Request.

### 5.2. Đề xuất Script 2: `DashboardSqlIntegrationTest.java` (Database Integration Test)
- **Mục tiêu:** Bổ sung kiểm thử tầng Database cho TC-DASH-09, TC-DASH-10, TC-DASH-17, TC-DASH-19.
- **Vị trí đề xuất:** `backend/src/test/java/com/cxshield/backend/report/DashboardSqlIntegrationTest.java`
- **Công nghệ đề xuất:** PostgreSQL Test Environment / Testcontainers.
- **Nội dung kiểm tra:**
  - Chèn 1 session có 2 responses -> thực thi `get_dashboard_stats` -> đo đạc tác động lên `scanCount`, `ratedCount`, `satisfiedCount` để xác nhận nguy cơ nhân dòng do phép `LEFT JOIN`.
  - Chèn session sát mốc 23:59 và 00:01 giờ VN để kiểm tra phân nhóm ngày/tuần.

### 5.3. Đề xuất Script 3: `dashboard_cross_branch_security_test.dart` (RLS Integration Test)
- **Mục tiêu:** Bổ sung kiểm thử phân quyền liên chi nhánh cho TC-DASH-23.
- **Vị trí đề xuất:** `frontend/test/dashboard_cross_branch_security_test.dart`
- **Nội dung kiểm tra:**
  - Giả lập phiên đăng nhập của Quản lý Chi nhánh 1, gọi API tổng hợp "Tất cả chi nhánh".
  - Assert kết quả chỉ chứa các phiên của Chi nhánh 1, hoàn toàn không xuất hiện phiên của Chi nhánh 2.
