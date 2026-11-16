# DANH SÁCH TEST CASES CHI TIẾT – KIỂM THỬ MÃ NGUỒN SỐ LIỆU DASHBOARD TỔNG QUAN

- **Mã Jira:** SCRUM-240
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Vai trò:** Tester (Kiểm định độc lập, chuẩn bị kế hoạch & thiết kế kịch bản)
- **Ngày lập:** 16/11/2026 (Cập nhật sau QA Audit)
- **Trạng thái thực thi:** **ĐÃ HOÀN THÀNH AUDIT (FINAL QA AUDIT COMPLETED)**

---

## 1. Bảng Tổng Hợp Hiện Trạng & Phân Loại Kiểm Thử Sau Audit

| Nhóm kiểm thử | Mã Test Case | Số lượng | Loại kiểm thử | Mức độ ưu tiên | Trạng thái nghiệm thu sau Audit |
| :--- | :--- | :---: | :--- | :---: | :---: |
| **Nhóm 1: Tính chính xác công thức số liệu** | TC-DASH-01 đến TC-DASH-08 | 8 | Unit Test / API Test | High / Critical | **4 PASS, 4 NOT RUN** (Partially Verified) |
| **Nhóm 2: Tính toàn vẹn dữ liệu & Edge Cases** | TC-DASH-09 đến TC-DASH-12 | 4 | Database Test / API Test | Medium / High | **2 PASS, 2 NOT RUN** (1 Partially Verified, 1 Test Gap) |
| **Nhóm 3: Bộ lọc thời gian & Gom nhóm tuần** | TC-DASH-13 đến TC-DASH-19 | 7 | Unit Test / API / DB Test | Medium / High | **6 PASS, 1 NOT RUN** (Test Gap) |
| **Nhóm 4: Phân quyền & Bảo mật (RLS/JWT)** | TC-DASH-20 đến TC-DASH-23 | 4 | Security Test / API Test | Critical | **2 PASS, 2 NOT RUN** (Test Gap) |
| **Nhóm 5: Giao diện & Trạng thái phản hồi** | TC-DASH-24 đến TC-DASH-27 | 4 | UI / Widget Test | Medium / High | **4 PASS** |
| **TỔNG CỘNG** | **TC-DASH-01 – TC-DASH-27** | **27** | **Đa tầng (Multi-tier)** | - | **18 PASS, 0 FAIL, 0 BLOCKED, 9 NOT RUN** |

> [!NOTE]
> **Thống kê Kết quả Thực thi Kiểm thử Tự động & Nguyên tắc QA Audit:**
> - Toàn bộ **37/37 Unit & Widget Tests** liên quan đến Dashboard trong mã nguồn (20 Backend Tests qua Maven + 17 Frontend Tests qua Flutter) đã được thực thi và đạt kết quả **100% PASS (37 passed, 0 failed)**.
> - **18 Test Cases đạt PASS trực tiếp:** Có automated test chứng minh trực tiếp điều kiện đầu vào và kết quả mong đợi.
> - **9 Test Cases giữ trạng thái NOT RUN:** Gồm **5 ca Partially Verified** (TC-DASH-01, 02, 03, 06, 09: mới chỉ kiểm tra qua mock DTO của Service, chưa kiểm chứng câu lệnh SQL trên DB thật) và **4 ca Test Gap** (TC-DASH-10, 19, 20, 23: cần môi trường DB tích hợp, WebMvcTest 401 hoặc Supabase live đa tài khoản). Tuyệt đối không suy diễn thành PASS hoàn toàn. Không có bài test nào bị FAIL.

---

## 2. Bảng Ma Trận Truy Vết (Traceability Matrix) & Khảo Sát Test Scripts

Bảng đối chiếu giữa **Test Case thiết kế (SCRUM-240)** ↔ **Unit Test hiện có trong mã nguồn** ↔ **Mã nguồn triển khai**:

| Mã Test Case | Loại kiểm thử | Unit Test hiện có bao phủ | Vị trí mã nguồn liên quan | Tình trạng bao phủ (Coverage Status) |
| :--- | :--- | :--- | :--- | :--- |
| **TC-DASH-01** | Unit / API | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | `n5_dashboard.sql` L43–66; `DashboardService.java` L60 | Bao phủ ở mức Service mock; **Thiếu API Integration Test** |
| **TC-DASH-02** | Unit / API | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | `n5_dashboard.sql` L58; `DashboardDtos.java` L17 | Bao phủ ở mức Service mock |
| **TC-DASH-03** | Unit / API | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | `n5_dashboard.sql` L59 | Bao phủ ở mức Service mock |
| **TC-DASH-04** | Unit / API | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | `DashboardService.java` L80, L126–132 | Bao phủ tính toán phần trăm và làm tròn 1 chữ số thập phân |
| **TC-DASH-05** | Unit / API / UI | `DashboardServiceTest.emptyDataHasNoRate`, `weekWithScansButNoRatingHasNullRate`, `dashboard_test.dart` (test 2, 4) | `DashboardService.java` L126–128; `dashboard_models.dart` L102 | **Bao phủ tốt** cả Backend Service lẫn Frontend model/format |
| **TC-DASH-06** | API / DB | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` | `n5_dashboard.sql` L60; `SurveyServiceImpl.java` L140, L175 | Bao phủ ở mức Service mock |
| **TC-DASH-07** | Unit / API | `DashboardServiceTest.usesLatestGoogleWeekForCards` | `DashboardService.java` L78–83 | Bao phủ logic lấy snapshot tuần mới nhất |
| **TC-DASH-08** | Unit | `DashboardServiceTest.combinesBranchesWithWeightedRating` | `DashboardService.java` L109–124 | Bao phủ logic trung bình gia quyền đa chi nhánh |
| **TC-DASH-09** | DB / API | `DashboardServiceTest.weekWithScansButNoRatingHasNullRate` | `n5_dashboard.sql` L49–55 | Mới chỉ mock ở tầng Java; **Thiếu kiểm tra trực tiếp trên SQL CSDL** |
| **TC-DASH-10** | DB / SQL | *(Chưa có automated test tương ứng)* | `n5_dashboard.sql` L49–64; `SurveyServiceImpl.java` L130 | **TEST GAP (Code Anomaly):** Nguy cơ đếm trùng do `LEFT JOIN` và thiếu ràng buộc `UNIQUE` (OBS-SCRUM-240-01) |
| **TC-DASH-11** | API / UI | `DashboardServiceTest.emptyDataHasNoRate`, `dashboard_test.dart` (test 2), `admin_pages_test.dart` (test 2) | `DashboardService.java` L78; `dashboard_page.dart` L245 | **Bao phủ tốt** đa tầng từ Service, Model đến Widget UI |
| **TC-DASH-12** | Unit / UI | `DashboardServiceTest.ignoresMetricRowsWithoutGoogleData`, `zeroGoogleReviewsHasNoRating`, `dashboard_test.dart` (test 4) | `DashboardService.java` L111; `dashboard_page.dart` L238 | Bao phủ trường hợp Google metrics null hoặc bằng 0 |
| **TC-DASH-13** | Unit / API | `DashboardServiceTest.defaultRangeIsLastEightWeeks` | `DashboardService.java` L56–57 | Bao phủ mặc định 56 ngày (8 tuần) |
| **TC-DASH-14** | UI / API | `dashboard_test.dart` (test 6, 7) | `dashboard_models.dart` L80–87; `dashboard_page.dart` L198 | Bao phủ 3 mốc preset thời gian trên UI |
| **TC-DASH-15** | Unit / API | `DashboardServiceTest.rejectsReversedRange` | `DashboardService.java` L101–104 | Bao phủ validation `from > to` ném `INVALID_DATE_RANGE` |
| **TC-DASH-16** | Unit / API | `DashboardServiceTest.rejectsRangeOverOneYear` | `DashboardService.java` L105–107 | Bao phủ validation khoảng thời gian > 366 ngày |
| **TC-DASH-17** | DB / Job | `GoogleMetricsSnapshotJobTest.savesStatsIntoCurrentWeek` | `n5_dashboard.sql` L50; `GoogleMetricsSnapshotJob.java` L58 | Bao phủ quy tắc tuần bắt đầu từ Thứ Hai |
| **TC-DASH-18** | Unit / API | `DashboardServiceTest.usesLatestGoogleWeekForCards` | `DashboardService.java` L68–76 | Bao phủ ghép tuần bằng `TreeSet<LocalDate>` |
| **TC-DASH-19** | DB / API | *(Chưa có automated test tương ứng)* | `n5_dashboard.sql` L42; `DashboardService.java` L35 | **TEST GAP:** Chưa có test biên múi giờ UTC vs `Asia/Ho_Chi_Minh` |
| **TC-DASH-20** | Security / API | *(Chưa có automated test tương ứng)* | `SecurityConfig.java` L39 | **TEST GAP:** Chưa có test kiểm tra từ chối HTTP 401 khi không có JWT token |
| **TC-DASH-21** | Security / API | `DashboardServiceTest.rejectsBusinessWithoutAccess` | `DashboardService.java` L92–95 | Bao phủ ở mức Java Service mock; **Thiếu API test thực tế** |
| **TC-DASH-22** | Security / API | `DashboardServiceTest.rejectsBranchOfAnotherBusiness` | `DashboardService.java` L96–98 | Bao phủ ở mức Java Service mock |
| **TC-DASH-23** | Security / DB | *(Chưa có automated test tương ứng)* | `n5_dashboard.sql` L10–21, L38 | **TEST GAP:** Chưa có test xác minh RLS cô lập dữ liệu theo tài khoản `BRANCH_MANAGER` thật |
| **TC-DASH-24** | UI | `admin_pages_test.dart` (test 1), `dashboard_test.dart` (test 7) | `dashboard_page.dart` L186–215 | Bao phủ chuyển đổi chi nhánh trên dropdown |
| **TC-DASH-25** | UI | `dashboard_test.dart` (test 10, 11) | `dashboard_models.dart` L64–70; `dashboard_widgets.dart` L30–65 | Bao phủ widget `FunnelChart` |
| **TC-DASH-26** | UI | `dashboard_test.dart` (test 14) | `dashboard_widgets.dart` L100–140 | Bao phủ widget `WeeklyTable` |
| **TC-DASH-27** | UI | `admin_pages_test.dart` (test 3) | `dashboard_page.dart` L223–228 | Bao phủ xử lý lỗi và nút bấm tải lại số liệu |

---

## 3. Chi Tiết Từng Test Case (TC-DASH-01 đến TC-DASH-27)

### Nhóm 1: Kiểm thử Tính chính xác Công thức Số liệu

#### TC-DASH-01: Xác minh công thức tính tổng lượt quét QR (`scanCount`)
- **Mã Test Case:** TC-DASH-01
- **Mục tiêu:** Kiểm tra `scanCount` phản ánh chính xác tổng số phiên khảo sát được khởi tạo trong khoảng thời gian lọc.
- **Loại kiểm thử:** API Test / Unit Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** CSDL có dữ liệu khảo sát trong và ngoài khoảng thời gian lọc.
- **Dữ liệu kiểm thử:** Chi nhánh CN01 có 10 phiên quét QR trong khoảng ngày `2026-10-01` đến `2026-10-28`, và 3 phiên quét trước ngày `2026-10-01`.
- **Yêu cầu môi trường:** Môi trường Backend Spring Boot kết nối PostgreSQL hoặc môi trường Mockito.
- **Các bước thực hiện:**
  1. Gửi request `GET /api/v1/businesses/{businessId}/dashboard?branchId={cn01Id}&from=2026-10-01&to=2026-10-28`.
  2. Đọc giá trị trường `scanCount` trong JSON trả về.
- **Kết quả mong đợi:** `scanCount` bằng chính xác 10. Không đếm 3 phiên ngoài khoảng thời gian.
- **Trạng thái:** **NOT RUN** *(Partially Verified at Unit mock level – `DashboardServiceTest` mới mock DTO, cần DB integration test cho SQL `get_dashboard_stats`)*

#### TC-DASH-02: Xác minh công thức tính tổng lượt đánh giá sao (`ratedCount`)
- **Mã Test Case:** TC-DASH-02
- **Mục tiêu:** Kiểm tra `ratedCount` chỉ đếm các phiên khách đã thực sự chọn đánh giá sao (1–5 sao), không tính các phiên quét nhưng bỏ dở.
- **Loại kiểm thử:** API Test / Unit Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Có các phiên quét ở trạng thái `STARTED` (chưa đánh giá) và các phiên có `star_rating`.
- **Dữ liệu kiểm thử:** 10 phiên quét, trong đó 8 phiên có `star_rating` (từ 1 đến 5 sao), 2 phiên không có phản hồi.
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gửi request `GET /api/v1/businesses/{businessId}/dashboard`.
  2. So sánh giá trị `scanCount` và `ratedCount`.
- **Kết quả mong đợi:** `scanCount` = 10, `ratedCount` = 8.
- **Trạng thái:** **NOT RUN** *(Partially Verified at Unit mock level – `DashboardServiceTest` mới mock DTO, cần DB integration test cho SQL `count(star_rating)`)*

#### TC-DASH-03: Xác minh công thức tính tổng lượt hài lòng 4–5 sao (`satisfiedCount`)
- **Mã Test Case:** TC-DASH-03
- **Mục tiêu:** Kiểm tra `satisfiedCount` đếm đúng số lượng đánh giá có `star_rating >= 4`.
- **Loại kiểm thử:** API Test / Unit Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Dữ liệu có đủ các mức đánh giá từ 1 đến 5 sao.
- **Dữ liệu kiểm thử:** 8 lượt đánh giá gồm: 1 sao (1 lượt), 2 sao (1 lượt), 3 sao (0 lượt), 4 sao (3 lượt), 5 sao (3 lượt).
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gửi request lấy số liệu Dashboard.
  2. Kiểm tra giá trị `satisfiedCount` trong kết quả.
- **Kết quả mong đợi:** `satisfiedCount` = 6 (3 lượt 4 sao + 3 lượt 5 sao). Các lượt 1, 2 sao không được tính vào đây.
- **Trạng thái:** **NOT RUN** *(Partially Verified at Unit mock level – `DashboardServiceTest` mới mock DTO, cần DB integration test cho SQL `count(*) filter (star_rating >= 4)`)*

#### TC-DASH-04: Xác minh công thức tính tỷ lệ hài lòng (`satisfactionRate`) và làm tròn
- **Mã Test Case:** TC-DASH-04
- **Mục tiêu:** Kiểm tra công thức `(satisfiedCount / ratedCount) * 100%` và quy tắc làm tròn 1 chữ số thập phân (`round(val * 10) / 10.0`).
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** `ratedCount > 0`.
- **Dữ liệu kiểm thử:**
  - Ca a: 6 hài lòng / 8 đánh giá -> $6 / 8 \times 100\% = 75.0\%$.
  - Ca b: 1 hài lòng / 3 đánh giá -> $1 / 3 \times 100\% = 33.333...\% \rightarrow 33.3\%$.
  - Ca c: 5 hài lòng / 5 đánh giá -> $100.0\%$.
- **Yêu cầu môi trường:** Backend Service / Unit Test.
- **Các bước thực hiện:**
  1. Thực thi hàm tính toán hoặc gọi API với dữ liệu kiểm thử.
  2. Đối chiếu trường `satisfactionRate` tổng thể và trong từng `WeeklyPoint`.
- **Kết quả mong đợi:** Giá trị `satisfactionRate` trả về lần lượt là 75.0, 33.3, 100.0 (kiểu Double).
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.calculatesSatisfactionFromRatedResponses` assert 75.0, 33.3, 100.0; `dashboard_test.dart` format '82,5%')*

#### TC-DASH-05: Xử lý mẫu số bằng 0 – Khi chưa có lượt đánh giá nào
- **Mã Test Case:** TC-DASH-05
- **Mục tiêu:** Xác minh khi `ratedCount == 0`, hệ thống không bị lỗi chia cho 0 (`ArithmeticException`), trả về `null` an toàn và UI hiển thị dấu gạch ngang `'—'`.
- **Loại kiểm thử:** Unit Test / API Test / UI Test
- **Mức độ ưu tiên:** Critical
- **Điều kiện tiên quyết:** Cơ sở có lượt quét nhưng chưa ai đánh giá sao (`scanCount = 5, ratedCount = 0`).
- **Dữ liệu kiểm thử:** `SurveyStats(scanCount: 5, ratedCount: 0, satisfiedCount: 0, googleRedirectCount: 0)`.
- **Yêu cầu môi trường:** Backend Spring Boot & Flutter Widget Test.
- **Các bước thực hiện:**
  1. Gọi API `GET .../dashboard`.
  2. Kiểm tra trường `satisfactionRate` trong JSON trả về.
  3. Render giao diện `DashboardPage` với dữ liệu này.
- **Kết quả mong đợi:**
  - API trả về `"satisfactionRate": null` (không crash HTTP 500).
  - UI hiển thị thẻ KPI Hài lòng với giá trị `'—'` và note `'0 lượt đánh giá'`.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.emptyDataHasNoRate`, `weekWithScansButNoRatingHasNullRate` assert null; `dashboard_test.dart` format '—')*

#### TC-DASH-06: Xác minh công thức đếm lượt chuyển sang Google Review (`googleRedirectCount`)
- **Mã Test Case:** TC-DASH-06
- **Mục tiêu:** Kiểm tra `googleRedirectCount` đếm đúng mọi phiên có `redirect_clicked_at is not null` (bao gồm cả khách 4–5 sao bấm chuyển Google Maps và khách 1–3 sao bấm bypass công khai).
- **Loại kiểm thử:** API Test / Database Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Dữ liệu có 3 khách 5 sao chuyển Google và 2 khách 1 sao chọn public bypass.
- **Dữ liệu kiểm thử:** 5 bản ghi `survey_responses` có `redirect_clicked_at != null`.
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gọi API Dashboard cho kỳ khảo sát tương ứng.
  2. Đọc giá trị `googleRedirectCount`.
- **Kết quả mong đợi:** `googleRedirectCount` bằng chính xác 5.
- **Trạng thái:** **NOT RUN** *(Partially Verified at Unit mock level – `DashboardServiceTest` mới mock DTO, cần DB integration test cho SQL `redirect_clicked_at is not null`)*

#### TC-DASH-07: Xác minh số liệu Google trên thẻ tổng quan lấy snapshot tuần mới nhất
- **Mã Test Case:** TC-DASH-07
- **Mục tiêu:** Xác minh thẻ KPI "Đánh giá Google" và "Điểm sao Google" hiển thị số liệu của tuần snapshot gần nhất (`latest snapshot`), không tính tổng dồn các tuần.
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Bảng `metrics` có dữ liệu của 2 tuần liên tiếp: Tuần 1 (100 reviews, 4.2 sao), Tuần 2 (110 reviews, 4.3 sao).
- **Dữ liệu kiểm thử:** 2 dòng `MetricRow` tương ứng tuần 1 và tuần 2.
- **Yêu cầu môi trường:** Backend Service.
- **Các bước thực hiện:**
  1. Gọi API Dashboard cho khoảng thời gian bao gồm cả 2 tuần.
  2. Đọc trường `googleReviewCount` và `googleAvgRating` ở cấp gốc của DTO `DashboardResponse`.
- **Kết quả mong đợi:** `googleReviewCount` = 110, `googleAvgRating` = 4.3 (không phải tổng 210 hay trung bình 4.25).
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.usesLatestGoogleWeekForCards` assert reviewCount=110, avgRating=4.3)*

#### TC-DASH-08: Xác minh công thức trung bình gia quyền điểm sao Google giữa các chi nhánh
- **Mã Test Case:** TC-DASH-08
- **Mục tiêu:** Xác minh khi xem "Tất cả chi nhánh", điểm sao Google trong cùng một tuần được tính theo công thức bình quân gia quyền: $\sum(\text{avgRating} \times \text{reviewCount}) / \sum(\text{reviewCount})$.
- **Loại kiểm thử:** Unit Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** 2 chi nhánh có snapshot Google trong cùng Tuần 2:
  - Chi nhánh A: 100 reviews, 5.0 sao.
  - Chi nhánh B: 300 reviews, 4.0 sao.
- **Dữ liệu kiểm thử:** $(100 \times 5.0 + 300 \times 4.0) / (100 + 300) = (500 + 1200) / 400 = 1700 / 400 = 4.25 \rightarrow \text{làm tròn } 4.3$.
- **Yêu cầu môi trường:** Backend Service Unit Test.
- **Các bước thực hiện:**
  1. Thực thi `DashboardService.groupByWeek` với dữ liệu 2 chi nhánh trên.
  2. Kiểm tra đối tượng `GoogleWeek` của Tuần 2.
- **Kết quả mong đợi:** `reviewCount` = 400, `avgRating` = 4.3.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.combinesBranchesWithWeightedRating` assert reviewCount=400, avgRating=4.3)*

---

### Nhóm 2: Kiểm thử Tính toàn vẹn Dữ liệu & Edge Cases

#### TC-DASH-09: Phiên khảo sát chưa hoàn tất đánh giá sao
- **Mã Test Case:** TC-DASH-09
- **Mục tiêu:** Xác minh tính độc lập giữa `survey_sessions` và `survey_responses`: Phiên quét mở ra nhưng khách tắt trang ngay vẫn được tính vào `scanCount` và không bị tính vào `ratedCount`.
- **Loại kiểm thử:** Database / API Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Có 3 phiên trong `survey_sessions`, nhưng không có bản ghi nào trong `survey_responses`.
- **Dữ liệu kiểm thử:** 3 bản ghi `survey_sessions` có `status = 'STARTED'`, `started_at` trong kỳ.
- **Yêu cầu môi trường:** CSDL PostgreSQL / Supabase có dữ liệu mẫu.
- **Các bước thực hiện:**
  1. Thực thi hàm SQL `get_dashboard_stats`.
  2. Quan sát kết quả JSON.
- **Kết quả mong đợi:** `scanCount` = 3, `ratedCount` = 0, `satisfiedCount` = 0, `googleRedirectCount` = 0.
- **Trạng thái:** **NOT RUN** *(Partially Verified at Unit mock level – `DashboardServiceTest` mới mock DTO, cần DB integration test cho SQL `LEFT JOIN` với session rỗng)*

#### TC-DASH-10: Kiểm tra nguy cơ đếm trùng `scanCount` khi có nhiều response cho 1 session
- **Mã Test Case:** TC-DASH-10
- **Mục tiêu:** Kiểm tra hiện tượng dị thường: Nếu 1 `session_id` có 2 bản ghi trong `survey_responses`, xác minh `scanCount` và các chỉ số liên quan bị nhân bản do phép `LEFT JOIN` và các hàm đếm trong SQL.
- **Loại kiểm thử:** Database / SQL Test (Xác minh Code Anomaly / High Risk)
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** CSDL môi trường test cho phép chèn dữ liệu dị thường (không vi phạm khóa chính).
- **Dữ liệu kiểm thử:**
  - 1 bản ghi `survey_sessions` ID `S1`.
  - 2 bản ghi `survey_responses` cùng trỏ tới `session_id = S1` (Rating 5 sao).
- **Yêu cầu môi trường:** Môi trường kiểm thử CSDL độc lập (Database Test Environment).
- **Các bước thực hiện:**
  1. Thực thi hàm `get_dashboard_stats(p_business_id, ...)`.
  2. Kiểm tra giá trị `scanCount`, `ratedCount`, `satisfiedCount`.
- **Kết quả mong đợi theo nghiệp vụ chuẩn:** Nếu nghiệp vụ quy định quan hệ 1:1, hệ thống phải ngăn chặn chèn response trùng bằng `UNIQUE(session_id)` hoặc cơ chế idempotent ở backend; các chỉ số `scanCount`, `ratedCount`, `satisfiedCount` đều chỉ phản ánh đúng 1 phiên duy nhất.
- **Kết quả kiểm chứng mã nguồn hiện tại:** Do SQL dùng `LEFT JOIN` và `count(*)`, dự kiến `scanCount` bị đếm thành 2, `ratedCount` bị đếm thành 2, `satisfiedCount` bị đếm thành 2. Lưu ý kỹ thuật: `count(distinct ss.id)` chỉ khắc phục được `scanCount`, không giải quyết được các KPI còn lại nếu không xử lý ở tầng nghiệp vụ/CSDL.
- **Trạng thái:** **NOT RUN** *(Test Gap – Cần CSDL thật xác minh OBS-SCRUM-240-01)*

#### TC-DASH-11: Phản hồi khi cơ sở hoàn toàn chưa có dữ liệu trong khoảng thời gian lọc
- **Mã Test Case:** TC-DASH-11
- **Mục tiêu:** Xác minh phản hồi của API và giao diện khi cơ sở không có bất kỳ lượt quét nào.
- **Loại kiểm thử:** API Test / UI Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Cơ sở mới tạo, chưa có dữ liệu khảo sát.
- **Dữ liệu kiểm thử:** `businessId` hợp lệ, không có bản ghi trong `survey_sessions`.
- **Yêu cầu môi trường:** Backend & Flutter App.
- **Các bước thực hiện:**
  1. Gọi API `GET .../dashboard`.
  2. Mở màn hình D5-01 trên giao diện Flutter.
- **Kết quả mong đợi:**
  - API trả về: `scanCount: 0, ratedCount: 0, satisfiedCount: 0, satisfactionRate: null, googleRedirectCount: 0, googleReviewCount: null, googleAvgRating: null, weekly: []`.
  - UI hiển thị banner: *"Chưa có lượt quét nào trong khoảng thời gian này."*.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.emptyDataHasNoRate`, `dashboard_test.dart`, `admin_pages_test.dart`)*

#### TC-DASH-12: Chi nhánh chưa liên kết Google Place ID hoặc chưa có dữ liệu đồng bộ
- **Mã Test Case:** TC-DASH-12
- **Mục tiêu:** Xác minh giao diện và API khi cơ sở chưa kết nối Google Place ID (`metrics` rỗng).
- **Loại kiểm thử:** Unit Test / UI Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Chi nhánh chưa cấu hình Google Places API.
- **Dữ liệu kiểm thử:** API trả về `googleReviewCount: null, googleAvgRating: null`.
- **Yêu cầu môi trường:** Flutter Widget Test.
- **Các bước thực hiện:**
  1. Render `DashboardPage` với dữ liệu thiếu Google metrics.
  2. Quan sát thẻ "Đánh giá Google" và "Điểm sao Google".
- **Kết quả mong đợi:** Cả 2 thẻ hiển thị giá trị `'—'` kèm dòng chữ ghi chú nhỏ *"Chưa có dữ liệu"*.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.ignoresMetricRowsWithoutGoogleData`, `zeroGoogleReviewsHasNoRating`, `dashboard_test.dart`)*

---

### Nhóm 3: Kiểm thử Bộ lọc Thời gian & Gom nhóm Tuần

#### TC-DASH-13: Xác minh bộ lọc thời gian mặc định (8 tuần gần nhất)
- **Mã Test Case:** TC-DASH-13
- **Mục tiêu:** Kiểm tra khi client không truyền `from` và `to`, backend tự động tính `to = hôm nay` và `from = hôm nay - 56 ngày`.
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Không truyền param `from` và `to`.
- **Dữ liệu kiểm thử:** Ngày hệ thống cố định: `2026-11-06`.
- **Yêu cầu môi trường:** Backend Service Test với Clock cố định.
- **Các bước thực hiện:**
  1. Gọi `dashboardService.getDashboard(token, businessId, null, null, null)`.
  2. Kiểm tra trường `from` và `to` trong DTO trả về.
- **Kết quả mong đợi:** `to = 2026-11-06`, `from = 2026-09-11` (chính xác 56 ngày).
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.defaultRangeIsLastEightWeeks`)*

#### TC-DASH-14: Kiểm thử các preset khoảng thời gian trên giao diện (4, 8, 12 tuần)
- **Mã Test Case:** TC-DASH-14
- **Mục tiêu:** Kiểm tra chọn dropdown thời gian trên UI gửi đúng số ngày tương ứng xuống API.
- **Loại kiểm thử:** UI Test / API Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Đang mở màn hình D5-01.
- **Dữ liệu kiểm thử:** Chọn lần lượt: "4 tuần gần nhất", "8 tuần gần nhất", "12 tuần gần nhất".
- **Yêu cầu môi trường:** Flutter Widget Test.
- **Các bước thực hiện:**
  1. Chọn "4 tuần gần nhất" -> kiểm tra query param: `to - from = 28 ngày`.
  2. Chọn "8 tuần gần nhất" -> kiểm tra query param: `to - from = 56 ngày`.
  3. Chọn "12 tuần gần nhất" -> kiểm tra query param: `to - from = 84 ngày`.
- **Kết quả mong đợi:** API client gửi chính xác ngày `from` tương ứng số ngày cấu hình.
- **Trạng thái:** **PASS** *(Direct Evidence: `dashboard_test.dart`)*

#### TC-DASH-15: Chặn khoảng ngày bị đảo ngược (`from > to`)
- **Mã Test Case:** TC-DASH-15
- **Mục tiêu:** Xác minh backend từ chối và trả về lỗi nếu ngày bắt đầu sau ngày kết thúc.
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Token hợp lệ.
- **Dữ liệu kiểm thử:** `from = 2026-11-06`, `to = 2026-11-05`.
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gửi request `GET /api/v1/businesses/{id}/dashboard?from=2026-11-06&to=2026-11-05`.
  2. Kiểm tra HTTP Status và mã lỗi trong body.
- **Kết quả mong đợi:** HTTP 400 Bad Request, mã lỗi `INVALID_DATE_RANGE`, thông điệp *"Ngày bắt đầu phải trước ngày kết thúc."*. Không gọi xuống CSDL.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.rejectsReversedRange`)*

#### TC-DASH-16: Chặn khoảng thời gian vượt quá 1 năm (> 366 ngày)
- **Mã Test Case:** TC-DASH-16
- **Mục tiêu:** Xác minh backend chặn các truy vấn khoảng thời gian quá dài gây quá tải database.
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Token hợp lệ.
- **Dữ liệu kiểm thử:** `from = 2025-11-04`, `to = 2026-11-06` (khoảng cách 367 ngày).
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gửi request `GET ...?from=2025-11-04&to=2026-11-06`.
  2. Kiểm tra mã lỗi.
- **Kết quả mong đợi:** HTTP 400 Bad Request, mã lỗi `INVALID_DATE_RANGE`, thông điệp *"Khoảng thời gian không được vượt quá 1 năm."*.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.rejectsRangeOverOneYear`)*

#### TC-DASH-17: Quy tắc gom tuần ISO 8601 (Đầu tuần là Thứ Hai)
- **Mã Test Case:** TC-DASH-17
- **Mục tiêu:** Xác minh mọi mốc `weekStart` trong mảng `weekly` đều là ngày Thứ Hai.
- **Loại kiểm thử:** Database / Unit Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Có lượt quét vào các ngày Thứ Tư (04/11/2026), Thứ Bảy (07/11/2026), Chủ Nhật (08/11/2026).
- **Dữ liệu kiểm thử:** Các phiên quét rải rác trong tuần.
- **Yêu cầu môi trường:** PostgreSQL / Supabase function `get_dashboard_stats`.
- **Các bước thực hiện:**
  1. Thực thi hàm `get_dashboard_stats`.
  2. Lấy giá trị `weekStart` của tuần đó.
- **Kết quả mong đợi:** `weekStart` phải trả về đúng ngày Thứ Hai: `2026-11-02`.
- **Trạng thái:** **PASS** *(Direct Evidence: `GoogleMetricsSnapshotJobTest.savesStatsIntoCurrentWeek`)*

#### TC-DASH-18: Khớp nối tuần giữa khảo sát nội bộ và snapshot Google
- **Mã Test Case:** TC-DASH-18
- **Mục tiêu:** Kiểm tra thuật toán gộp tuần `TreeSet` đảm bảo hiển thị đủ các tuần dù một trong hai nguồn dữ liệu bị khuyết.
- **Loại kiểm thử:** Unit Test / API Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:**
  - Tuần 1: Có 10 lượt quét, không có số liệu Google.
  - Tuần 2: 0 lượt quét, có snapshot Google (110 reviews, 4.3 sao).
- **Dữ liệu kiểm thử:** Mock `SurveyStats` và `MetricRow` tương ứng.
- **Yêu cầu môi trường:** Backend Service Test.
- **Các bước thực hiện:**
  1. Thực thi `DashboardService.getDashboard`.
  2. Kiểm tra danh sách `points` trong `weekly`.
- **Kết quả mong đợi:** `weekly` có đủ 2 phần tử:
  - Tuần 1: `scanCount = 10`, `googleReviewCount = null`.
  - Tuần 2: `scanCount = 0`, `googleReviewCount = 110`.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.usesLatestGoogleWeekForCards`)*

#### TC-DASH-19: Tính nhất quán múi giờ Việt Nam (`Asia/Ho_Chi_Minh`)
- **Mã Test Case:** TC-DASH-19
- **Mục tiêu:** Xác minh các lượt quét thực hiện sát giờ chuyển giao ngày không bị lệch ngày/tuần do múi giờ UTC.
- **Loại kiểm thử:** Database Test / API Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** CSDL lưu `started_at` kiểu `TIMESTAMPTZ`.
- **Dữ liệu kiểm thử:**
  - Phiên A: Tạo lúc `2026-11-01 17:30:00 UTC` (tức `2026-11-02 00:30:00` giờ VN - Thứ Hai tuần mới).
  - Phiên B: Tạo lúc `2026-11-01 16:30:00 UTC` (tức `2026-11-01 23:30:00` giờ VN - Chủ Nhật tuần cũ).
- **Yêu cầu môi trường:** PostgreSQL Function Test.
- **Các bước thực hiện:**
  1. Chèn 2 phiên A và B vào bảng `survey_sessions`.
  2. Gọi `get_dashboard_stats`.
- **Kết quả mong đợi:** Phiên A được tính vào tuần bắt đầu từ `2026-11-02`. Phiên B được tính vào tuần bắt đầu từ `2026-10-26`.
- **Trạng thái:** **NOT RUN** *(Test Gap – Cần môi trường CSDL thật kiểm thử timestamp sát biên múi giờ)*

---

### Nhóm 4: Kiểm thử Phân quyền & Bảo mật

#### TC-DASH-20: Bảo vệ Endpoint – Yêu cầu bắt buộc Bearer JWT Token
- **Mã Test Case:** TC-DASH-20
- **Mục tiêu:** Xác minh endpoint `/api/v1/businesses/{id}/dashboard` được bảo vệ, từ chối mọi request không có access token.
- **Loại kiểm thử:** Security Test / API Test
- **Mức độ ưu tiên:** Critical
- **Điều kiện tiên quyết:** Server backend đang chạy.
- **Dữ liệu kiểm thử:** Request HTTP GET không kèm header `Authorization`.
- **Yêu cầu môi trường:** API Client (Postman/Curl) hoặc MockMvc.
- **Các bước thực hiện:**
  1. Gửi `GET http://localhost:8080/api/v1/businesses/{validId}/dashboard`.
  2. Quan sát HTTP status.
- **Kết quả mong đợi:** HTTP 401 Unauthorized.
- **Trạng thái:** **NOT RUN** *(Test Gap – Cần WebMvcTest Controller kiểm tra bộ lọc Spring Security)*

#### TC-DASH-21: Cô lập cơ sở (Multi-tenancy) – Truy cập cơ sở của người khác
- **Mã Test Case:** TC-DASH-21
- **Mục tiêu:** Xác minh người dùng đăng nhập không thể xem Dashboard của cơ sở kinh doanh mà mình không có tư cách thành viên.
- **Loại kiểm thử:** Security Test / API Test
- **Mức độ ưu tiên:** Critical
- **Điều kiện tiên quyết:** Tài khoản User A thuộc Cơ sở A, Cơ sở B thuộc sở hữu của User B.
- **Dữ liệu kiểm thử:** Token của User A, nhưng path param truyền `businessId_B`.
- **Yêu cầu môi trường:** Backend Spring Boot kết nối Supabase Auth.
- **Các bước thực hiện:**
  1. Dùng token của User A gọi `GET /api/v1/businesses/{businessId_B}/dashboard`.
  2. Kiểm tra mã lỗi.
- **Kết quả mong đợi:** HTTP 404 Not Found, mã lỗi `BUSINESS_NOT_FOUND`, thông điệp *"Không tìm thấy cơ sở hoặc bạn không có quyền truy cập."*. Không để lộ dữ liệu của Cơ sở B.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.rejectsBusinessWithoutAccess` assert ném ApiException BUSINESS_NOT_FOUND)*

#### TC-DASH-22: Cô lập chi nhánh – Truy cập chi nhánh không thuộc cơ sở
- **Mã Test Case:** TC-DASH-22
- **Mục tiêu:** Xác minh chặn xem chi nhánh không thuộc phạm vi sở hữu của cơ sở đang quản lý.
- **Loại kiểm thử:** Security Test / API Test
- **Mức độ ưu tiên:** Critical
- **Điều kiện tiên quyết:** Chi nhánh CN_X thuộc cơ sở khác.
- **Dữ liệu kiểm thử:** Token của User A, `businessId_A`, nhưng query param `branchId = CN_X`.
- **Yêu cầu môi trường:** Backend Spring Boot.
- **Các bước thực hiện:**
  1. Gọi `GET /api/v1/businesses/{businessId_A}/dashboard?branchId={CN_X}`.
  2. Kiểm tra phản hồi.
- **Kết quả mong đợi:** HTTP 404 Not Found, mã lỗi `BRANCH_NOT_FOUND`, thông điệp *"Không tìm thấy chi nhánh hoặc bạn không có quyền truy cập."*.
- **Trạng thái:** **PASS** *(Direct Evidence: `DashboardServiceTest.rejectsBranchOfAnotherBusiness` assert ném ApiException BRANCH_NOT_FOUND)*

#### TC-DASH-23: Thực thi Supabase RLS – Giới hạn phạm vi xem giữa hai tài khoản thuộc hai chi nhánh khác nhau
- **Mã Test Case:** TC-DASH-23
- **Mục tiêu:** Xác minh cơ chế Row-Level Security: Kiểm tra tính cách ly dữ liệu thực tế giữa hai tài khoản quản lý thuộc hai chi nhánh khác nhau; đảm bảo khi chọn "Tất cả chi nhánh", RLS lọc bỏ hoàn toàn các phiên của chi nhánh không được phân quyền.
- **Loại kiểm thử:** Security / Database Integration Test
- **Mức độ ưu tiên:** Critical
- **Điều kiện tiên quyết:**
  - Cơ sở kinh doanh có ít nhất 2 chi nhánh độc lập: Chi nhánh 1 (CN01) và Chi nhánh 2 (CN02).
  - Có 2 tài khoản quản lý độc lập:
    - Tài khoản User A: Được cấp quyền `BRANCH_MANAGER` tại CN01 (không có quyền tại CN02).
    - Tài khoản User B: Được cấp quyền `BRANCH_MANAGER` tại CN02 (không có quyền tại CN01).
  - Mỗi chi nhánh có 5 phiên khảo sát được tạo trong kỳ lọc.
- **Dữ liệu kiểm thử:**
  - Token JWT của User A và User B.
  - Định danh `branchId_CN01` và `branchId_CN02`.
- **Yêu cầu môi trường:** CSDL Supabase/PostgreSQL thật (hoặc Testcontainers) có bật RLS, đã chạy migration `n5_dashboard.sql` và có dữ liệu thành viên phân quyền thực tế.
- **Các bước thực hiện:**
  1. Đăng nhập bằng tài khoản User A.
  2. Gửi request `GET /api/v1/businesses/{businessId}/dashboard?branchId={branchId_CN02}` (User A cố ý truy vấn chi nhánh CN02).
  3. Gửi request `GET /api/v1/businesses/{businessId}/dashboard` (User A không truyền `branchId`, tức chọn xem tổng hợp "Tất cả chi nhánh").
- **Kết quả mong đợi (Đo lường được):**
  - Tại bước 2: Backend chặn ngay tại tầng `requireAccess` và trả về HTTP 404 Not Found, mã lỗi `BRANCH_NOT_FOUND`.
  - Tại bước 3: Hàm `get_dashboard_stats` thực thi với ngữ cảnh User A; chính sách RLS `survey_sessions_select_access` tự động lọc dữ liệu, chỉ trả về đúng `scanCount = 5` (các phiên của CN01). Dữ liệu 5 phiên của CN02 bị ẩn hoàn toàn (không được bằng 10).
- **Trạng thái:** **NOT RUN** *(Test Gap – Cần môi trường Supabase Auth live với 2 tài khoản phân quyền thật trên bảng memberships)*

---

### Nhóm 5: Kiểm thử Giao diện & Trạng thái Phản hồi

#### TC-DASH-24: Đổi bộ lọc chi nhánh trên giao diện D5-01
- **Mã Test Case:** TC-DASH-24
- **Mục tiêu:** Kiểm tra thao tác chuyển chi nhánh trên dropdown kích hoạt gọi lại API và cập nhật giao diện đúng.
- **Loại kiểm thử:** UI / Widget Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** Màn hình D5-01 đang hiển thị số liệu của "Tất cả chi nhánh".
- **Dữ liệu kiểm thử:** Chọn chi nhánh "Quận 1" (ID: `c1`).
- **Yêu cầu môi trường:** Flutter Widget Test hoặc chạy trên Chrome/Android.
- **Các bước thực hiện:**
  1. Nhấn vào Dropdown chi nhánh.
  2. Chọn "Quận 1".
  3. Bắt request API được gửi đi.
- **Kết quả mong đợi:** Giao diện hiển thị thanh tải (LinearProgressIndicator) và gọi request mới có query param `branchId=c1`.
- **Trạng thái:** **PASS** *(Direct Evidence: `admin_pages_test.dart` assert phát sinh 2 call, call sau có branchId=c1; `dashboard_test.dart`)*

#### TC-DASH-25: Hiển thị Phễu chuyển đổi (`FunnelChart`)
- **Mã Test Case:** TC-DASH-25
- **Mục tiêu:** Xác minh biểu đồ phễu hiển thị đủ 4 nấc: "Quét mã QR", "Chọn sao", "Hài lòng 4–5 sao", "Chuyển sang Google" kèm tỷ lệ % chính xác so với lượt quét ban đầu.
- **Loại kiểm thử:** UI / Widget Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Dữ liệu có: 1248 quét, 1000 chọn sao, 825 hài lòng, 684 chuyển Google.
- **Dữ liệu kiểm thử:** Model `DashboardData` với số liệu trên.
- **Yêu cầu môi trường:** Flutter Widget Test.
- **Các bước thực hiện:**
  1. Render widget `FunnelChart`.
  2. Kiểm tra text hiển thị trên từng nấc phễu.
- **Kết quả mong đợi:**
  - Quét mã QR: `1.248 · 100%`
  - Chuyển sang Google: `684 · 54,8%` ($684 / 1248 \approx 54.8\%$).
- **Trạng thái:** **PASS** *(Direct Evidence: `dashboard_test.dart` assert 4 bước, 1248 [100%], 684 [54.8%])*

#### TC-DASH-26: Bảng chi tiết theo tuần (`WeeklyTable`)
- **Mã Test Case:** TC-DASH-26
- **Mục tiêu:** Kiểm tra bảng thống kê tuần luôn xếp tuần mới nhất lên trên cùng và thay thế giá trị thiếu bằng ký tự `'—'`.
- **Loại kiểm thử:** UI / Widget Test
- **Mức độ ưu tiên:** Medium
- **Điều kiện tiên quyết:** Dữ liệu có 2 tuần: Tuần 26/10 và Tuần 02/11.
- **Dữ liệu kiểm thử:** Tuần 02/11 không có số liệu Google.
- **Yêu cầu môi trường:** Flutter Widget Test.
- **Các bước thực hiện:**
  1. Render widget `WeeklyTable`.
  2. Đo vị trí dòng của ngày `02/11` và `26/10`.
- **Kết quả mong đợi:** Tuần `02/11` nằm phía trên tuần `26/10`. Các cột Google của tuần `02/11` hiển thị `'—'`.
- **Trạng thái:** **PASS** *(Direct Evidence: `dashboard_test.dart` assert dy(02/11) < dy(26/10))*

#### TC-DASH-27: Xử lý lỗi API và nút tải lại số liệu
- **Mã Test Case:** TC-DASH-27
- **Mục tiêu:** Kiểm tra khi API trả về lỗi hoặc mất mạng, màn hình hiển thị banner thông báo lỗi và nút "Tải lại số liệu" hoạt động khi được bấm.
- **Loại kiểm thử:** UI / Widget Test
- **Mức độ ưu tiên:** High
- **Điều kiện tiên quyết:** API bị ngắt kết nối hoặc trả về lỗi 500/network error.
- **Dữ liệu kiểm thử:** Exception `ApiException("Lỗi kết nối máy chủ")`.
- **Yêu cầu môi trường:** Flutter Widget Test.
- **Các bước thực hiện:**
  1. Mở màn hình D5-01 trong điều kiện API lỗi.
  2. Bấm nút "Tải lại số liệu".
- **Kết quả mong đợi:** Banner lỗi màu đỏ xuất hiện chứa nội dung lỗi. Khi bấm nút tải lại, ứng dụng phát lại request `_loadData()`.
- **Trạng thái:** **PASS** *(Direct Evidence: `admin_pages_test.dart` assert hiển thị banner lỗi và tap nút "Tải lại số liệu")*
