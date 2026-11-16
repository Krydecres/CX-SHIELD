# TÀI LIỆU TEST SCRIPTS VÀ KẾ HOẠCH AUTOMATION (TEST SCRIPTS & AUTOMATION PLAN)

- **Mã Jira:** SCRUM-241
- **Tên nhiệm vụ:** [E3.1] Kiểm thử chức năng dashboard tổng quan
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người lập:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Trạng thái:** **EXECUTED & VERIFIED** – Đã thực thi toàn bộ test scripts tự động trên môi trường local, thu thập đầy đủ log và xác định chi tiết các Test Gaps.

---

## 1. Kiểm Kê Danh Mục Automated Tests Thực Tế Trong Dự Án (65 Tests)

Để phục vụ kiểm thử cho phân hệ Dashboard tổng quan (E3.1 / D5-01), đội ngũ QA đã rà soát toàn bộ kho mã nguồn và xác định **65 Automated Tests** (Backend & Frontend) tham gia bảo chứng cho luồng nghiệp vụ của Dashboard:

### 1.1. Backend Service Unit Tests: `DashboardServiceTest.java` (13 tests)
- **Đường dẫn tệp tin:** [DashboardServiceTest.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/test/java/com/cxshield/backend/report/DashboardServiceTest.java)
- **Môi trường & Công nghệ:** Java 21, JUnit 5, Mockito, AssertJ.
- **Danh sách 13 test methods thực tế:**
  1. `calculatesSatisfactionFromRatedResponses()`: Kiểm tra tính toán `satisfactionRate = (satisfiedCount * 100.0 / ratedCount)` làm tròn 1 số thập phân và phân nhóm theo tuần.
  2. `emptyDataHasNoRate()`: Kiểm tra khi `SurveyStats` rỗng thì `satisfactionRate` là `null`, `weekly` rỗng.
  3. `weekWithScansButNoRatingHasNullRate()`: Kiểm tra tuần có lượt quét nhưng 0 đánh giá thì `satisfactionRate` là `null`.
  4. `defaultRangeIsLastEightWeeks()`: Kiểm tra mặc định lấy 56 ngày (8 tuần) tính đến ngày hiện tại.
  5. `passesBranchAndRangeToRepository()`: Kiểm tra truyền đúng tham số `branchId`, `from`, `to` xuống repository và chuẩn hoá ngày đọc Google về thứ Hai đầu tuần.
  6. `usesLatestGoogleWeekForCards()`: Kiểm tra thẻ tổng quan lấy số review và điểm sao trung bình của tuần snapshot gần nhất.
  7. `combinesBranchesWithWeightedRating()`: Kiểm tra tính điểm sao trung bình gia quyền đa chi nhánh trong cùng một tuần: $\sum (\text{reviewCount} \times \text{avgRating}) / \sum \text{reviewCount}$.
  8. `ignoresMetricRowsWithoutGoogleData()`: Bỏ qua các dòng metric thiếu thông tin review Google.
  9. `zeroGoogleReviewsHasNoRating()`: Khi số review Google bằng 0 thì avg rating là `null`.
  10. `rejectsReversedRange()`: Chặn khoảng ngày đảo ngược (`from > to`), ném `ApiException` mã `INVALID_DATE_RANGE`.
  11. `rejectsRangeOverOneYear()`: Chặn khoảng thời gian > 366 ngày, ném `ApiException` mã `INVALID_DATE_RANGE`.
  12. `rejectsBusinessWithoutAccess()`: Chặn tài khoản không có quyền trên cơ sở, ném mã `BUSINESS_NOT_FOUND`.
  13. `rejectsBranchOfAnotherBusiness()`: Chặn truy cập chi nhánh không thuộc cơ sở, ném mã `BRANCH_NOT_FOUND`.

### 1.2. Backend Repository Unit Tests: `DashboardRepositoryTest.java` (3 tests)
- **Đường dẫn tệp tin:** [DashboardRepositoryTest.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/test/java/com/cxshield/backend/report/DashboardRepositoryTest.java)
- **Môi trường & Công nghệ:** Java 21, JUnit 5, Mockito (Mock `SupabaseDataClient`).
- **Danh sách 3 test methods thực tế:**
  1. `surveyStatsCallsRpcWithNullBranchForAllBranches()`: Kiểm tra gọi RPC `get_dashboard_stats` với `p_branch_id = null` khi xem tất cả chi nhánh.
  2. `metricsFilterByBusinessAndPeriod()`: Kiểm tra PostgREST query trên bảng `metrics` lọc theo `branches.business_id` và khoảng thời gian.
  3. `metricsFilterByBranchWhenSelected()`: Kiểm tra bổ sung `branch_id` vào query `metrics` khi chọn chi nhánh cụ thể.

### 1.3. Backend Scheduled Job Tests: `GoogleMetricsSnapshotJobTest.java` (4 tests)
- **Đường dẫn tệp tin:** [GoogleMetricsSnapshotJobTest.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/test/java/com/cxshield/backend/report/GoogleMetricsSnapshotJobTest.java)
- **Môi trường & Công nghệ:** Java 21, JUnit 5, Mockito.
- **Danh sách 4 test methods thực tế:**
  1. `savesStatsIntoCurrentWeek()`: Kiểm tra tính toán mốc tuần từ Thứ Hai đến Chủ Nhật (`period_start` và `period_end`) và gọi upsert vào bảng `metrics`.
  2. `skipsBranchWithoutGoogleData()`: Bỏ qua chi nhánh nếu Google Places Client không trả về dữ liệu.
  3. `doesNothingWithoutServiceRoleKey()`: Dừng tác vụ an toàn nếu thiếu `SUPABASE_SERVICE_ROLE_KEY`.
  4. `doesNothingWithoutPlacesKey()`: Dừng tác vụ an toàn nếu thiếu `GOOGLE_PLACES_API_KEY`.

### 1.4. Frontend Unit & Widget Tests: `dashboard_test.dart` (14 tests)
- **Đường dẫn tệp tin:** [dashboard_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/dashboard_test.dart)
- **Môi trường & Công nghệ:** Flutter 3.47.2, Dart 3.13.2, `flutter_test`, `http/testing`.
- **Danh sách 14 test cases thực tế:**
  - *Nhóm đọc dữ liệu API (2 tests):*
    1. `đọc dữ liệu API / đủ số liệu`: Parse JSON response đầy đủ sang `DashboardData` và danh sách `DashboardWeek`.
    2. `đọc dữ liệu API / chưa có dữ liệu`: Kiểm tra trường hợp dữ liệu rỗng, `isEmpty = true`, `satisfactionRate = null`.
  - *Nhóm định dạng hiển thị (4 tests):*
    3. `định dạng / số có dấu chấm hàng nghìn`: Format số chuẩn VN (`1.248`, `1.234.567`).
    4. `định dạng / phần trăm và điểm sao`: Format `82,5%`, `4,6★`, giá trị null hiển thị `'—'`.
    5. `định dạng / ngày`: Format ngày API `apiDate` (`2026-11-06`) và nhãn tuần `formatWeek` (`02/11`).
    6. `định dạng / khoảng thời gian có sẵn`: Cấu hình enum `DashboardRange` (4 tuần: 28 ngày, 8 tuần: 56 ngày, 12 tuần: 84 ngày).
  - *Nhóm gọi API (2 tests):*
    7. `gọi API / lọc theo chi nhánh và thời gian`: Gửi đúng query params `branchId`, `from`, `to`.
    8. `gọi API / tất cả chi nhánh không gửi branchId`: Không gửi key `branchId` khi xem tất cả chi nhánh.
  - *Nhóm Widget UI (6 tests):*
    9. `widget / thẻ số liệu hiện nhãn, giá trị và ghi chú`: Render `MetricCard` hiển thị đúng label, value và subtitle note.
    10. `widget / phễu hiện số lượt và tỷ lệ so với lượt quét`: Render `FunnelChart` tính tỷ lệ % 4 bước dựa trên mẫu số `scanCount`.
    11. `widget / phễu không lỗi khi chưa có lượt quét`: `FunnelChart` hiển thị `'0 · —'` an toàn khi `scanCount = 0`.
    12. `widget / cột biểu đồ theo tỷ lệ lượt quét`: Render `WeeklyBarChart` với chiều cao cột tỷ lệ thuận theo tuần cao nhất.
    13. `widget / biểu đồ không lỗi khi mọi tuần bằng 0`: `WeeklyBarChart` không lỗi khi toàn bộ lượt quét = 0 (chiều cao tối thiểu 2px).
    14. `widget / bảng hiện tuần mới nhất trước và dấu gạch khi thiếu số liệu`: Render `WeeklyTable` xếp tuần mới nhất lên đầu (`weeks.reversed`).

### 1.5. Frontend Admin Pages Tests: `admin_pages_test.dart` (3 tests nhóm D5-01)
- **Đường dẫn tệp tin:** [admin_pages_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/admin_pages_test.dart)
- **Danh sách 3 widget tests thuộc `group('D5-01')`:**
  1. `D5-01 hiện số liệu và đổi bộ lọc gọi lại API`: Màn hình D5-01 hiển thị đủ 5 thẻ, đổi dropdown chi nhánh kích hoạt gọi lại API chính xác.
  2. `D5-01 chưa có lượt quét hiện thông báo`: Hiển thị banner thông báo `"Chưa có lượt quét nào trong khoảng thời gian này."` khi `scanCount = 0`.
  3. `D5-01 lỗi tải số liệu có nút thử lại`: Hiển thị banner thông báo lỗi từ server và nút `"Tải lại số liệu"` khi API trả về mã lỗi.

### 1.6. Frontend Shell & Navigation Tests: `admin_shell_pages_test.dart` & `auth_onboarding_test.dart` (29 tests)
- **Đường dẫn tệp tin:**
  - [admin_shell_pages_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/admin_shell_pages_test.dart) (8 tests): Xác minh menu item đầu tiên `#0` là "Tổng quan" (`/dashboard`, screenCode `D5-01`), mở đúng màn hình trên cả Desktop và Mobile.
  - [auth_onboarding_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/auth_onboarding_test.dart) (21 tests): Xác minh router redirect tự động vào `/dashboard` khi session sẵn sàng và cơ sở đã hoàn tất onboarding.

---

## 2. Hướng Dẫn Lệnh Thực Thi Kiểm Thử (Execution Commands)

Tất cả các lệnh kiểm thử dưới đây đã được kiểm chứng hoạt động thành công trên môi trường Windows PowerShell.

### 2.1. Lệnh chạy Backend Tests (Maven Wrapper)
- **Thư mục làm việc:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend`
- **Lệnh PowerShell chuẩn:**
  ```powershell
  Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
  .\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest'
  ```
  *(Lưu ý bắt buộc: Phải bọc chuỗi `-Dtest=...` trong dấu nháy đơn để PowerShell không phân tách dấu phẩy thành mảng).*

### 2.2. Lệnh chạy Frontend Tests (Flutter Test)
- **Thư mục làm việc:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend`
- **Lệnh 1 – Chạy Unit & Component tests chuyên biệt Dashboard:**
  ```powershell
  Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
  flutter test test/dashboard_test.dart
  ```
- **Lệnh 2 – Chạy Widget tests màn hình D5-01:**
  ```powershell
  flutter test test/admin_pages_test.dart --plain-name "D5-01"
  ```
- **Lệnh 3 – Chạy Shell & Navigation tests cho Dashboard:**
  ```powershell
  flutter test test/admin_shell_pages_test.dart
  flutter test test/auth_onboarding_test.dart --plain-name "điều hướng"
  flutter test test/auth_onboarding_test.dart --plain-name "menu admin"
  ```

---

## 3. Bảng Ánh Xạ Chi Tiết 42 Test Cases (SCRUM-241) ↔ Automated Tests

Bảng dưới đây ánh xạ từng mã Test Case thuộc SCRUM-241 với phương thức kiểm thử tự động trực tiếp hoặc xác định lý do nghẽn môi trường:

| Mã Test Case | Tên Test Case | Tầng kiểm thử | Phương thức / Test Script bảo chứng | Trạng thái sau Audit |
| :--- | :--- | :---: | :--- | :---: |
| **TC-D501-NAV-01** | Redirect vào Dashboard sau login | Router / UI | `auth_onboarding_test.dart`: "điều hướng URL /?code=abc..." | **PASS** |
| **TC-D501-NAV-02** | Mở root `/` tự động vào `/dashboard` | Router / UI | `auth_onboarding_test.dart`: `codeUri.path == '/'` $\rightarrow$ `/dashboard` | **PASS** |
| **TC-D501-NAV-03** | Chặn `/dashboard` khi chưa login | Router / Security | Code review `router.dart` L50 & `auth_onboarding_test.dart` L122 | **PARTIALLY VERIFIED** |
| **TC-D501-NAV-04** | Chặn `/dashboard` khi chưa onboard | Router / Flow | Code review `router.dart` L53 & `auth_onboarding_test.dart` L112 | **PARTIALLY VERIFIED** |
| **TC-D501-NAV-05** | AdminShell render D5-01 mặc định | Shell / UI | `admin_shell_pages_test.dart`: "khung admin hiện /dashboard trên máy tính / điện thoại" | **PASS** |
| **TC-D501-DATA-01** | Thẻ 1: Lượt quét QR format chấm | UI / Format | `dashboard_test.dart`: "định dạng số có dấu chấm hàng nghìn", "widget thẻ số liệu..." | **PASS** |
| **TC-D501-DATA-02** | Thẻ 2: % hài lòng (mẫu ratedCount) | UI / Formula | • Backend mock (6/8=75%): `DashboardServiceTest.calculatesSatisfactionFromRatedResponses`<br>• Frontend mock (82.5 $\rightarrow$ '82,5%'): `dashboard_test.dart` ("phần trăm...") & `admin_pages_test.dart` | **PASS** |
| **TC-D501-DATA-03** | Thẻ 2: Mẫu số 0 hiển thị '—' | UI / Edge | `dashboard_test.dart`: "định dạng phần trăm...", `DashboardServiceTest.emptyDataHasNoRate` | **PASS** |
| **TC-D501-DATA-04** | Thẻ 3: Chuyển sang Google | UI / Data | `dashboard_test.dart`: "đọc dữ liệu API đủ số liệu", "widget thẻ số liệu..." | **PASS** |
| **TC-D501-DATA-05** | Thẻ 4: Đánh giá Google tuần mới nhất | UI / Snapshot | `dashboard_test.dart`: "widget thẻ số liệu...", `DashboardServiceTest.usesLatestGoogleWeekForCards` | **PASS** |
| **TC-D501-DATA-06** | Thẻ 5: Điểm sao Google kèm ký tự ★ | UI / Format | • Backend mock snapshot (4.3): `DashboardServiceTest.usesLatestGoogleWeekForCards`<br>• Frontend format mock (4.6 $\rightarrow$ '4,6★'): `dashboard_test.dart` | **PASS** |
| **TC-D501-DATA-07** | Subtitle hiển thị Brand + Thời gian | UI / Layout | Code inspection `dashboard_page.dart` L85 & `admin_pages_test.dart` (Rendered, thiếu assert text) | **PARTIALLY VERIFIED** |
| **TC-D501-FLT-01** | Giá trị mặc định: All branches & 8w | UI / Filter | `admin_pages_test.dart`: "D5-01 hiện số liệu...", `DashboardServiceTest.defaultRangeIsLastEightWeeks` | **PASS** |
| **TC-D501-FLT-02** | Đổi chi nhánh gọi lại API kèm `branchId` | API / Filter | `admin_pages_test.dart`: "D5-01 hiện số liệu và đổi bộ lọc gọi lại API", `dashboard_test.dart` (#7) | **PASS** |
| **TC-D501-FLT-03** | Đổi về "Tất cả chi nhánh" bỏ `branchId` | API / Filter | `dashboard_test.dart`: "gọi API tất cả chi nhánh không gửi branchId", `DashboardRepositoryTest` (#1) | **PASS** |
| **TC-D501-FLT-04** | Preset 4 tuần gần nhất (28 ngày) | API / Filter | `dashboard_test.dart`: "định dạng khoảng thời gian có sẵn", "gọi API lọc theo chi nhánh..." (Thiếu tap UI) | **PARTIALLY VERIFIED** |
| **TC-D501-FLT-05** | Preset 12 tuần gần nhất (84 ngày) | API / Filter | Model enum `dashboard_models.dart` (84 ngày) (Thiếu tap UI) | **PARTIALLY VERIFIED** |
| **TC-D501-FLT-06** | Responsive layout Row/Column $\ge 760\text{px}$ | UI / Layout | `admin_shell_pages_test.dart`: "khung admin hiện /dashboard trên máy tính" vs "trên điện thoại" | **PASS** |
| **TC-D501-CHT-01** | FunnelChart hiển thị đủ 4 bước | UI / Component | `dashboard_test.dart`: "widget phễu hiện số lượt và tỷ lệ so với lượt quét" | **PASS** |
| **TC-D501-CHT-02** | FunnelChart % tính trên `scanCount` | UI / Formula | `dashboard_test.dart`: "widget phễu hiện số lượt và tỷ lệ..." (Assert 100%, 54.8%, 44.9%, 25%) | **PASS** |
| **TC-D501-CHT-03** | WeeklyBarChart nhãn Thứ Hai `dd/MM` | UI / Date | `dashboard_test.dart`: "định dạng ngày", "widget cột biểu đồ..." | **PASS** |
| **TC-D501-CHT-04** | WeeklyBarChart cột co giãn tỷ lệ | UI / Component | `dashboard_test.dart`: "widget cột biểu đồ theo tỷ lệ lượt quét" | **PASS** |
| **TC-D501-CHT-05** | WeeklyBarChart an toàn khi scan = 0 | UI / Edge | `dashboard_test.dart`: "widget biểu đồ không lỗi khi mọi tuần bằng 0" | **PASS** |
| **TC-D501-CHT-06** | WeeklyTable xếp tuần mới nhất lên đầu | UI / Table | `dashboard_test.dart`: "widget bảng hiện tuần mới nhất trước và dấu gạch..." | **PASS** |
| **TC-D501-EMP-01** | Banner rỗng khi scanCount = 0 | UI / Empty | `admin_pages_test.dart`: "D5-01 chưa có lượt quét hiện thông báo" | **PASS** |
| **TC-D501-EMP-02** | Ẩn biểu đồ và bảng tuần khi rỗng | UI / Empty | `admin_pages_test.dart`: "D5-01 chưa có lượt quét hiện thông báo", `dashboard_test.dart` (#2) | **PASS** |
| **TC-D501-EMP-03** | Có scan nhưng 0 rating không phải empty | UI / Partial | `dashboard_test.dart`: "widget phễu không lỗi khi chưa có lượt quét", `DashboardServiceTest` (#3) | **PASS** |
| **TC-D501-EMP-04** | Khuyết Google metrics hiển thị '—' | UI / Partial | `dashboard_test.dart`: "widget bảng hiện tuần mới nhất trước và dấu gạch...", `DashboardServiceTest` (#8, #9) | **PASS** |
| **TC-D501-ERR-01** | Thanh tiến trình khi đổi bộ lọc | UI / Loading | Code inspection `dashboard_page.dart` L115 (Thiếu capture frame tải) | **PARTIALLY VERIFIED** |
| **TC-D501-ERR-02** | Loading xoay tròn khi mở lần đầu | UI / Loading | Code inspection `dashboard_page.dart` L95 (Thiếu capture frame tải) | **PARTIALLY VERIFIED** |
| **TC-D501-ERR-03** | Banner lỗi khi API ném ApiException | UI / Error | `admin_pages_test.dart`: "D5-01 lỗi tải số liệu có nút thử lại" | **PASS** |
| **TC-D501-ERR-04** | Nút "Tải lại số liệu" khôi phục trang | UI / Recovery | `admin_pages_test.dart`: "D5-01 lỗi tải số liệu có nút thử lại" | **PASS** |
| **TC-D501-ERR-05** | Chống Race Condition bằng `_requestId` | State / Async | Code inspection `dashboard_page.dart` L40–60 (Thiếu test out-of-order delay) | **PARTIALLY VERIFIED** |
| **TC-D501-CHK-01** | Checkbox hồ sơ cơ sở luôn hoàn tất | UI / Checklist | Code inspection `dashboard_page.dart` L145 (Rendered, thiếu assert icon) | **PARTIALLY VERIFIED** |
| **TC-D501-CHK-02** | Chip kết nối Google theo nhánh chọn | UI / Dynamic | Code inspection `dashboard_page.dart` L152 (Binding đúng, thiếu test dynamic switch) | **PARTIALLY VERIFIED** |
| **TC-D501-CHK-03** | Nút mở cấu hình sang `/funnel/google-place` | Router / Flow | Code inspection `dashboard_page.dart` L160 (Route đúng, thiếu tap assertion) | **PARTIALLY VERIFIED** |
| **TC-D501-INT-01** | Đối chiếu số liệu UI với SQL PostgreSQL | End-to-End | *(Yêu cầu môi trường PostgreSQL / Supabase live có dữ liệu thật)* | **BLOCKED** |
| **TC-D501-INT-02** | Thực nghiệm nguy cơ đếm trùng `LEFT JOIN` | Database / SQL | *(Yêu cầu môi trường PostgreSQL test database)* | **BLOCKED** |
| **TC-D501-INT-03** | RLS: Cách ly dữ liệu chéo giữa 2 chi nhánh | Security / DB | *(Yêu cầu môi trường Supabase Auth live với 2 tài khoản thật)* | **BLOCKED** |
| **TC-D501-INT-04** | Nhất quán múi giờ `Asia/Ho_Chi_Minh` biên | Database / SQL | *(Yêu cầu môi trường PostgreSQL test database)* | **BLOCKED** |
| **TC-D501-INT-05** | Chặn request thiếu Bearer JWT (HTTP 401) | Security / API | `SecurityConfig.java` & `DashboardServiceTest` (Thiếu WebMvcTest Controller riêng) | **PARTIALLY VERIFIED** |
| **TC-D501-INT-06** | Chặn khoảng ngày đảo ngược / >366 ngày (400) | Backend / API | `DashboardServiceTest.rejectsReversedRange`, `DashboardServiceTest.rejectsRangeOverOneYear` | **PASS** |

---

## 4. Phân Tích Khoảng Trống Kiểm Thử (Test Gaps) & Nguyên Nhân Nghẽn

Có **4 Test Cases quan trọng (TC-D501-INT-01 đến INT-04)** không thể thực thi tự động trên môi trường hiện tại và được phân loại **BLOCKED**:

### 4.1. TC-D501-INT-01 (Đối chiếu số liệu E2E giữa UI và SQL CSDL Thật)
- **Rào cản kỹ thuật:** Kho mã nguồn local không có file cấu hình `backend/.env` hoặc thông số kết nối CSDL PostgreSQL production/staging. Toàn bộ các test backend hiện tại chỉ dùng Mockito (`@Mock SupabaseDataClient`).
- **Rủi ro:** Số liệu hiển thị trên giao diện có thể khớp với DTO của Service, nhưng bản thân hàm SQL `get_dashboard_stats` trên CSDL thật có thể trả về số liệu khác nếu logic hàm SQL có khiếm khuyết.

### 4.2. TC-D501-INT-02 (Kiểm chứng thực nghiệm nguy cơ đếm trùng `LEFT JOIN` - OBS-SCRUM-241-01)
- **Rào cản kỹ thuật:** Để tái hiện nguy cơ đếm trùng khi 1 session có 2 responses, bắt buộc phải có một instance PostgreSQL thật để cài đặt migration `n5_dashboard.sql`, nạp dữ liệu vi phạm và gọi hàm `get_dashboard_stats`.
- **Rủi ro:** Đây là điểm bất thường mã nguồn mức độ High (Code Anomaly). Nếu không có bài test DB tích hợp, nguy cơ số liệu bị nhân bản âm thầm khi lên production là rất lớn.

### 4.3. TC-D501-INT-03 (Kiểm chứng RLS cách ly đa tài khoản)
- **Rào cản kỹ thuật:** Việc kiểm chứng cờ `security invoker` có thực sự ngăn người dùng Chi nhánh 1 xem dữ liệu Chi nhánh 2 hay không đòi hỏi phải có Supabase Auth engine đang chạy và nạp 2 JWT token của 2 người dùng có vai trò khác nhau.
- **Rủi ro:** Nếu hàm `private.has_branch_access` có kẽ hở logic, dữ liệu nhạy cảm giữa các chi nhánh có thể bị rò rỉ.

### 4.4. TC-D501-INT-04 (Kiểm chứng mốc biên múi giờ Việt Nam)
- **Rào cản kỹ thuật:** Cần nạp bản ghi có timestamp UTC `16:59:00` (23:59 GMT+7) và `17:01:00` (00:01 GMT+7 ngày hôm sau) vào PostgreSQL thật để đo lường hàm `date_trunc('week', ss.scan_date)`.

---

## 5. Đề Xuất Các Test Scripts Cần Bổ Sung Cho CI/CD (Proposed Scripts)

Nhằm đóng kín các khoảng trống kiểm thử trên, nhóm QA đề xuất bổ sung 3 kịch bản tự động hóa sau khi dự án thiết lập môi trường CI/CD hoặc Testcontainers:

### 5.1. Kịch bản 1: `DashboardSqlIntegrationTest.java` (PostgreSQL Testcontainers)
- **Vị trí đề xuất:** `backend/src/test/java/com/cxshield/backend/report/DashboardSqlIntegrationTest.java`
- **Công nghệ:** `@Testcontainers`, `org.testcontainers.containers.PostgreSQLContainer`, `JdbcTemplate`.
- **Nội dung kiểm tra:**
  1. Nạp migration schema `n1_khao_sat.sql`, `n5_dashboard.sql`.
  2. Tạo 1 session $S_1$, tạo 2 responses $R_1, R_2$ ($N=2$).
  3. Thực thi `SELECT * FROM get_dashboard_stats(...)`.
  4. Assert xem `scan_count` trả về 1 hay 2. Nếu trả về 2, xác nhận lỗi đếm trùng do `LEFT JOIN` và cảnh báo Dev team.
  5. Nạp timestamp sát mốc 23:59 Chủ Nhật và 00:01 Thứ Hai, kiểm tra việc phân bổ vào đúng `week_start`.

### 5.2. Kịch bản 2: `DashboardSecurityWebMvcTest.java` (Spring Security MockMvc)
- **Vị trí đề xuất:** `backend/src/test/java/com/cxshield/backend/report/DashboardSecurityWebMvcTest.java`
- **Công nghệ:** `@WebMvcTest(DashboardController.class)`, `@WithMockUser`, `MockMvc`.
- **Nội dung kiểm tra:**
  1. Gửi request `GET /api/v1/businesses/{id}/dashboard` không có Bearer token $\rightarrow$ kỳ vọng HTTP 401 Unauthorized.
  2. Gửi request kèm token của User không có quyền trên cơ sở $\rightarrow$ kỳ vọng HTTP 404 `BUSINESS_NOT_FOUND`.
  3. Gửi query param ngày sai cú pháp `from=2026-99-99` $\rightarrow$ kỳ vọng HTTP 400 Bad Request.

### 5.3. Kịch bản 3: `dashboard_cross_branch_security_test.dart` (Supabase RLS Live Mock)
- **Vị trí đề xuất:** `frontend/test/dashboard_cross_branch_security_test.dart`
- **Nội dung kiểm tra:**
  1. Giả lập đăng nhập dưới quyền Manager Chi nhánh A.
  2. Gọi API tổng hợp "Tất cả chi nhánh".
  3. Assert dữ liệu trả về chỉ gồm các phiên thuộc Chi nhánh A, hoàn toàn không xuất hiện số liệu của Chi nhánh B.
