# BÁO CÁO KẾT QUẢ THỰC THI KIỂM THỬ (TEST EXECUTION REPORT)
*(Đã qua thẩm định chất lượng QA Audit & Final Correction)*

- **Mã Jira:** SCRUM-240
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người thực hiện:** QA Engineer / Tester
- **Ngày thực thi & Audit:** 16/11/2026
- **Trạng thái đợt test:** **HOÀN THÀNH KIỂM THỬ TRONG PHẠM VI MÔI TRƯỜNG HIỆN CÓ**
- **Tài liệu tham chiếu:** `testing/SCRUM-240/test-cases.md`, `testing/SCRUM-240/test-scripts.md`, `testing/SCRUM-240/bug-reports.md`, `testing/SCRUM-240/analysis-report.md`

---

## 1. Tóm Tắt Kết Quả Thực Thi Sau Thẩm Định (Executive Summary)

### 1.1. Thống kê Kết quả 27 Test Cases của SCRUM-240

> [!IMPORTANT]
> **Nguyên tắc phân loại sau thẩm định (QA Audit Principle):**
> - **Chỉ đánh dấu PASS** khi có automated test hoặc bằng chứng thực thi trực tiếp chứng minh đúng điều kiện đầu vào và kết quả mong đợi (*Expected Result*) của Test Case đó.
> - **9 Test Cases chưa thực hiện KHÔNG ĐỒNG NGHĨA VỚI PASS.** Các Test Case chỉ mới kiểm tra gián tiếp qua tầng Mock DTO Service (chưa chạy câu lệnh SQL trên PostgreSQL thật) được xếp vào trạng thái **NOT RUN** (phân loại phụ: *Partially Verified at Unit level*), tuyệt đối không suy diễn thành PASS hoàn toàn.
> - Tổng số luôn đảm bảo đủ **27 Test Cases**.

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Diễn giải chi tiết sau Audit |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thuộc phạm vi SCRUM-240** | **27** | **100%** | Toàn bộ 27 Test Cases thiết kế cho nhiệm vụ |
| **• PASS (Chứng minh trực tiếp bằng automated test)** | **18** | **66.67%** | TC-DASH-04, 05, 07, 08, 11, 12, 13, 14, 15, 16, 17, 18, 21, 22, 24, 25, 26, 27 |
| **• FAIL (Nghiệm thu thất bại / Phát sinh Bug)** | **0** | **0%** | **0 Bug xác nhận** (Không có bài test tự động nào bị fail) |
| **• BLOCKED (Bị nghẽn do môi trường)** | **0** | **0%** | Không có bài test nào bị nghẽn |
| **• NOT RUN (Chưa đủ bằng chứng trực tiếp)** | **9** | **33.33%** | • **5 ca Partially Verified:** TC-DASH-01, 02, 03, 06, 09 (Mới mock Service DTO, cần DB integration test cho SQL)<br>• **4 ca Test Gap:** TC-DASH-10, 19, 20, 23 (Cần CSDL thật / WebMvcTest / RLS live) |

### 1.2. Thống kê Kết quả Thực thi 37 Automated Tests
Đã thực thi thành công toàn bộ **37/37 tests** hiện có trong source code:
- **Backend Tests (Maven Wrapper – 20 tests):**
  - `DashboardRepositoryTest`: **3/3 passed** (1.764s)
  - `DashboardServiceTest`: **13/13 passed** (0.395s)
  - `GoogleMetricsSnapshotJobTest`: **4/4 passed** (0.226s)
  - *Kết quả:* `Tests run: 20, Failures: 0, Errors: 0, Skipped: 0` – **BUILD SUCCESS** (21.406s).
- **Frontend Tests (Flutter Test – 17 tests):**
  - `frontend/test/dashboard_test.dart`: **14/14 passed**
  - `frontend/test/admin_pages_test.dart` (nhóm D5-01): **3/3 passed**
  - *Kết quả:* `All tests passed!`.

---

## 2. Bảng Nhật Ký Thực Thi Sau Audit (Audited Test Execution Log)

| Mã Test Case | Tên Test Case & Nội dung kiểm tra | Loại kiểm thử | Trạng thái Audit | Bằng chứng thực thi (Evidence Log) | Mức độ xác minh & Ghi chú |
| :--- | :--- | :--- | :---: | :--- | :--- |
| **TC-DASH-01** | Tính đúng tổng lượt quét QR (`scanCount`) | API / Unit | **NOT RUN** | `DashboardServiceTest`: Mới mock `SurveyStats(10, ...)`. Chưa có test thực thi SQL `get_dashboard_stats` trên DB thật | *Partially Verified (Mock)* – Cần DB integration test |
| **TC-DASH-02** | Tính đúng tổng lượt đánh giá sao (`ratedCount`) | API / Unit | **NOT RUN** | `DashboardServiceTest`: Mới mock `SurveyStats(..., 8, ...)`. Chưa đo đạc SQL `count(star_rating)` trên DB thật | *Partially Verified (Mock)* – Cần DB integration test |
| **TC-DASH-03** | Tính đúng lượt hài lòng 4–5 sao (`satisfiedCount`) | API / Unit | **NOT RUN** | `DashboardServiceTest`: Mới mock `SurveyStats(..., 6, ...)`. Chưa đo đạc SQL `count(*) filter (star_rating >= 4)` | *Partially Verified (Mock)* – Cần DB integration test |
| **TC-DASH-04** | Tính đúng tỷ lệ hài lòng % và làm tròn 1 số thập phân | Unit / API | **PASS** | `DashboardServiceTest.calculatesSatisfactionFromRatedResponses`: Assert 75.0%, 33.3%, 100.0%; `dashboard_test.dart`: Format '82,5%' | **Direct Evidence** |
| **TC-DASH-05** | Xử lý mẫu số bằng 0 (`ratedCount = 0` trả về null) | Unit / API / UI | **PASS** | `DashboardServiceTest.emptyDataHasNoRate`, `weekWithScansButNoRatingHasNullRate`: Assert `null`; `dashboard_test.dart`: Format '—' | **Direct Evidence** |
| **TC-DASH-06** | Đếm đúng lượt chuyển Google (`googleRedirectCount`) | API / DB | **NOT RUN** | `DashboardServiceTest`: Mới mock `SurveyStats(..., 5, ...)`. Chưa test SQL `redirect_clicked_at is not null` | *Partially Verified (Mock)* – Cần DB integration test |
| **TC-DASH-07** | Thẻ tổng quan lấy snapshot Google của tuần mới nhất | Unit / API | **PASS** | `DashboardServiceTest.usesLatestGoogleWeekForCards`: Assert `googleReviewCount = 110`, `googleAvgRating = 4.3` (lấy Tuần 2) | **Direct Evidence** |
| **TC-DASH-08** | Trung bình gia quyền điểm Google đa chi nhánh | Unit | **PASS** | `DashboardServiceTest.combinesBranchesWithWeightedRating`: Assert $(100 \times 5.0 + 300 \times 4.0)/400 = 4.25 \rightarrow 4.3$ | **Direct Evidence** |
| **TC-DASH-09** | Phiên quét bỏ dở không được tính vào `ratedCount` | DB / API | **NOT RUN** | `DashboardServiceTest`: Mới mock `SurveyStats(3, 0, 0, 0)`. Chưa kiểm thử SQL `LEFT JOIN` với session rỗng trên DB | *Partially Verified (Mock)* – Cần DB integration test |
| **TC-DASH-10** | Nguy cơ đếm trùng `scanCount` và các KPI khi có nhiều response | DB / SQL | **NOT RUN** | *(Chưa có automated test tương ứng)* – Cần DB integration test trên PostgreSQL | **Test Gap (Code Anomaly OBS-SCRUM-240-01)** |
| **TC-DASH-11** | Phản hồi khi cơ sở hoàn toàn chưa có dữ liệu | API / UI | **PASS** | `DashboardServiceTest.emptyDataHasNoRate`: scanCount=0; `admin_pages_test.dart`: Hiện banner "Chưa có lượt quét nào..." | **Direct Evidence** |
| **TC-DASH-12** | Chi nhánh chưa liên kết Google Place ID (`metrics` rỗng) | Unit / UI | **PASS** | `DashboardServiceTest.ignoresMetricRowsWithoutGoogleData`, `zeroGoogleReviewsHasNoRating`: null review/rating; UI format `'—'` | **Direct Evidence** |
| **TC-DASH-13** | Bộ lọc thời gian mặc định 8 tuần (56 ngày) | Unit / API | **PASS** | `DashboardServiceTest.defaultRangeIsLastEightWeeks`: Assert `to = 2026-11-06`, `from = 2026-09-11` (56 ngày) | **Direct Evidence** |
| **TC-DASH-14** | Các preset khoảng thời gian trên UI (4, 8, 12 tuần) | UI / API | **PASS** | `dashboard_test.dart` ("khoảng thời gian có sẵn", "lọc theo chi nhánh và thời gian"): Assert 28 ngày, 56 ngày | **Direct Evidence** |
| **TC-DASH-15** | Chặn khoảng ngày đảo ngược (`from > to`) báo lỗi 400 | Unit / API | **PASS** | `DashboardServiceTest.rejectsReversedRange`: Assert ném `ApiException` mã `INVALID_DATE_RANGE` | **Direct Evidence** |
| **TC-DASH-16** | Chặn khoảng ngày quá 1 năm (> 366 ngày) báo lỗi 400 | Unit / API | **PASS** | `DashboardServiceTest.rejectsRangeOverOneYear`: Assert ném `ApiException` mã `INVALID_DATE_RANGE` | **Direct Evidence** |
| **TC-DASH-17** | Mốc đầu tuần `weekStart` luôn là Thứ Hai theo ISO 8601 | DB / Job | **PASS** | `GoogleMetricsSnapshotJobTest.savesStatsIntoCurrentWeek`: Assert `period_start = 2026-11-02` (Thứ Hai), `period_end = 2026-11-08` | **Direct Evidence** |
| **TC-DASH-18** | Khớp nối tuần khi một trong hai nguồn dữ liệu bị khuyết | Unit / API | **PASS** | `DashboardServiceTest.usesLatestGoogleWeekForCards`: Assert tuần khuyết vẫn hiển thị với scanCount=0 hoặc reviewCount=null | **Direct Evidence** |
| **TC-DASH-19** | Nhất quán múi giờ `Asia/Ho_Chi_Minh` tại các mốc biên | DB / API | **NOT RUN** | *(Chưa có automated test tương ứng)* – Cần CSDL kiểm thử với timestamp UTC sát nửa đêm (23:59 và 00:01) | **Test Gap** |
| **TC-DASH-20** | Endpoint yêu cầu bắt buộc Bearer JWT (chặn 401) | Security / API | **NOT RUN** | *(Chưa có automated test tương ứng)* – Cần WebMvcTest Controller hoặc live server API test | **Test Gap** |
| **TC-DASH-21** | Chặn xem Dashboard của doanh nghiệp khác (404) | Security / API | **PASS** | `DashboardServiceTest.rejectsBusinessWithoutAccess`: Assert ném `ApiException` mã `BUSINESS_NOT_FOUND` | **Direct Evidence** |
| **TC-DASH-22** | Chặn xem chi nhánh không thuộc cơ sở (404) | Security / API | **PASS** | `DashboardServiceTest.rejectsBranchOfAnotherBusiness`: Assert ném `ApiException` mã `BRANCH_NOT_FOUND` | **Direct Evidence** |
| **TC-DASH-23** | Thực thi RLS: Cách ly dữ liệu giữa 2 tài khoản 2 chi nhánh | Security / DB | **NOT RUN** | *(Chưa có automated test tương ứng)* – Cần môi trường Supabase Auth live với 2 tài khoản phân quyền thật | **Test Gap** |
| **TC-DASH-24** | Đổi chi nhánh trên dropdown kích hoạt gọi lại API | UI | **PASS** | `admin_pages_test.dart` ("hiện số liệu và đổi bộ lọc gọi lại API"): Assert phát sinh 2 call, call sau có `branchId = c1` | **Direct Evidence** |
| **TC-DASH-25** | Hiển thị Phễu chuyển đổi 4 bước và % chính xác | UI | **PASS** | `dashboard_test.dart` ("phễu hiện số lượt và tỷ lệ so với lượt quét"): Assert 4 bước, 1248 (100%), 684 (54.8%), value = 684/1248 | **Direct Evidence** |
| **TC-DASH-26** | Bảng chi tiết tuần xếp tuần mới nhất lên trên cùng | UI | **PASS** | `dashboard_test.dart` ("bảng hiện tuần mới nhất trước..."): Assert dy(02/11) < dy(26/10) | **Direct Evidence** |
| **TC-DASH-27** | Xử lý lỗi kết nối và nút tải lại số liệu hoạt động | UI | **PASS** | `admin_pages_test.dart` ("lỗi tải số liệu có nút thử lại"): Assert hiển thị nút "Tải lại số liệu" và tap được | **Direct Evidence** |

---

## 3. Xác Minh Chi Tiết Bằng Chứng Thực Thi Thô (Raw Execution Evidence)

### 3.1. Phân biệt Lệnh Chạy Maven Lần 1 và Lần 2
- **Lần 1 (Exit Code 1):**
  - *Lệnh:* `.\mvnw.cmd test -Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest`
  - *Hiện tượng:* Exit Code 1 ngay lập tức (`ParserError: Missing argument in parameter list`).
  - *Nguyên nhân:* Trong PowerShell, dấu phẩy `,` được hiểu là toán tử mảng, khiến PowerShell tách chuỗi tham số thành mảng không hợp lệ. Lệnh này **chưa hề khởi động tiến trình Maven/Java**, không phải là lỗi test thất bại.
- **Lần 2 (Exit Code 0 – Thành công):**
  - *Lệnh:* `.\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest'`
  - *Kết quả:* Toàn bộ chuỗi property được bọc trong nháy đơn, Maven khởi động và thực thi thành công:
    `Tests run: 20, Failures: 0, Errors: 0, Skipped: 0` – **BUILD SUCCESS** (Thời gian: 21.406s).

### 3.2. Bằng chứng kiểm thử Flutter Test
- Lệnh 1 (`dashboard_test.dart`): 14/14 passed trong ~11s.
- Lệnh 2 (`admin_pages_test.dart --plain-name "D5-01"`): 3/3 passed trong ~15s.
- Toàn bộ 17 widget/unit tests của Flutter chạy thành công, không có exception nào phát sinh.

---

## 4. Bất Thường Mã Nguồn và Quan Sát Kỹ Thuật

### 4.1. `OBS-SCRUM-240-01` (Code Anomaly / High Risk) – Nguy cơ đếm trùng số liệu do phép `LEFT JOIN` và thiếu ràng buộc `UNIQUE`
- **Vị trí mã nguồn:** `database/n5_dashboard.sql` (lines 48–64), `database/n1_khao_sat.sql` (lines 25–39), `SurveyServiceImpl.java` (lines 127–145).
- **Phân tích tác động riêng lên từng KPI khi 1 session có $N$ response ($N \ge 2$):**
  - `scanCount`: Bị nhân lên $N$ lần do `count(*)` trên bảng sau JOIN. Giải pháp `count(distinct session_id)` **chỉ xử lý được duy nhất `scanCount`**, không giải quyết được các KPI còn lại.
  - `ratedCount`: Dùng `count(star_rating)`. Nếu có $N$ responses mang sao, hàm sẽ đếm thành $N$ lượt đánh giá. `count(distinct ...)` không áp dụng được cho trường hợp này.
  - `satisfiedCount`: Dùng `(count(*) filter (where star_rating >= 4))::int`. Bị đếm lặp nếu các responses đều $\ge 4$ sao. Nếu có sao khác nhau, gây méo mó tỷ lệ.
  - `satisfactionRate`: Bị sai lệch tỷ lệ phần trăm tùy theo điểm số của các response dư thừa.
  - `googleRedirectCount`: Dùng `(count(*) filter (where redirect_clicked_at is not null))::int`. Bị nhân $N$ lần nếu các response đều có cờ redirect.
- **Định hướng giải quyết theo nghiệp vụ:**
  - Cần xác định rõ bài toán nghiệp vụ từ PO/BA: Một phiên khảo sát (`survey_sessions`) theo thiết kế được phép có một (`1:1`) hay nhiều (`1:N`) phản hồi (`survey_responses`)?
  - *Nếu là quan hệ 1:1:* Cân nhắc bổ sung `CONSTRAINT uq_survey_responses_session UNIQUE (session_id)` trên bảng `survey_responses` ở CSDL và bổ sung cơ chế kiểm tra chống trùng lặp (idempotency) ở tầng backend (`SurveyServiceImpl`) trước khi insert.
  - *Nếu cho phép 1:N:* Backend/SQL cần định nghĩa rõ quy tắc tính toán lấy theo phản hồi nào (ví dụ: chỉ lấy bản ghi mới nhất thông qua `DISTINCT ON (session_id) ORDER BY session_id, created_at DESC`).
- **Phân loại:** **Code Anomaly / High Risk**, chưa phải Confirmed Bug vì chưa tái hiện bằng integration test trên PostgreSQL thật.

### 4.2. `OBS-SCRUM-240-02` (Technical Observation) – Bản chất khác biệt giữa thẻ Google Snapshot và Khảo sát nội bộ
- **Vị trí mã nguồn:** `DashboardService.java` (lines 78–82).
- **Mô tả:** Thẻ khảo sát nội bộ thể hiện tổng dồn tích lũy (`sum`) trên toàn bộ khoảng thời gian lọc (mặc định 8 tuần), trong khi thẻ Google hiển thị snapshot tuần mới nhất (`latest snapshot`).
- **Đề xuất:** Cân nhắc bổ sung tooltip/caption giải thích trên giao diện D5-01 để tránh người dùng hiểu nhầm số liệu Google là số lượng review mới nhận được trong kỳ lọc.

---

## 5. Kết Luận Đánh Giá QA

1. **Phạm vi hoàn thành:** Đã hoàn thành kiểm thử trong phạm vi môi trường hiện có (Local Unit Tests Backend qua Maven và Widget Tests Frontend qua Flutter).
2. **Số liệu nghiệm thu đợt test:**
   - **18 / 27 Test Cases đạt PASS trực tiếp** (66.67%).
   - **0 / 27 FAIL** (0%).
   - **0 / 27 BLOCKED** (0%).
   - **9 / 27 Test Cases giữ trạng thái NOT RUN** (33.33%). **Lưu ý: 9 Test Cases chưa thực hiện KHÔNG ĐỒNG NGHĨA VỚI PASS**, bao gồm 5 ca cần DB integration test và 4 ca thuộc diện Test Gap.
   - **37 / 37 automated tests chạy thực tế đạt kết quả 100% PASS.**
3. **Hiện trạng mã nguồn:**
   - Mã nguồn SCRUM-211 thực hiện đúng các công thức nghiệp vụ, cơ chế làm tròn 1 chữ số thập phân, xử lý mẫu số 0 an toàn và hiển thị giao diện đúng thiết kế đối với các luồng dữ liệu chuẩn.
   - Hai vấn đề quan sát (`OBS-SCRUM-240-01` Code Anomaly và `OBS-SCRUM-240-02` Technical Observation) đã được ghi nhận chi tiết để đội ngũ phát triển và Product Owner xem xét, đánh giá rủi ro theo quy trình của dự án.
