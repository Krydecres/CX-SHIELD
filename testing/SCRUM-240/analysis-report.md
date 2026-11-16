# BÁO CÁO PHÂN TÍCH MÃ NGUỒN VÀ KIẾN TRÚC KIỂM THỬ (ANALYSIS REPORT)

- **Mã Jira:** SCRUM-240
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người thực hiện:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Phiên bản mã nguồn:** CX-SHIELD (Spring Boot 4.0.0, Java 21, Flutter 3.x, Supabase PostgreSQL)
- **Trạng thái:** Hoàn tất khảo sát kỹ thuật sâu (Chỉ đọc mã nguồn, không can thiệp code và database)

---

## 1. Mục Tiêu và Phạm Vi Khảo Sát

Báo cáo phân tích chuyên sâu mã nguồn của phân hệ Dashboard tổng quan (E3.1) phục vụ chuẩn bị toàn diện cho hoạt động kiểm thử phần mềm. Phạm vi bao gồm:
1. Kiến trúc phân tầng và luồng dữ liệu của Dashboard.
2. Xác minh cơ chế xác thực và phân quyền Row-Level Security (Supabase RLS).
3. Đánh giá tính chính xác của các công thức thống kê và nguy cơ đếm trùng dữ liệu (`scanCount`).
4. Kiểm kê chi tiết 37 unit tests hiện có trong dự án và xác định các khoảng trống kiểm thử (Test Gaps).
5. Đề xuất kế hoạch kiểm thử tự động (Automation Test Plan).

---

## 2. Kiến Trúc Phân Tầng và Luồng Dữ Liệu Dashboard E3.1

```
[Client / Browser / App]
       │
       │  HTTP GET /api/v1/businesses/{businessId}/dashboard?branchId=...&from=...&to=...
       │  Header: Authorization: Bearer <USER_JWT>
       ▼
[Spring Boot Backend]
  ├── SecurityConfig.java (L39: Yêu cầu JWT xác thực cho /api/**)
  ├── DashboardController.java (L25-31: Tiếp nhận JWT, businessId, branchId, from, to)
  ├── DashboardService.java (L53-83: Nghiệp vụ tính %, validate date, phân quyền)
  │     ├── requireAccess(): Kiểm tra quyền sở hữu cơ sở/chi nhánh qua token
  │     ├── percent(): Tính tỷ lệ %, làm tròn 1 số thập phân, xử lý mẫu số 0
  │     └── groupByWeek(): Tính bình quân gia quyền điểm Google đa chi nhánh
  ├── DashboardRepository.java (L32-51: Data access qua SupabaseDataClient)
  └── GoogleMetricsSnapshotJob.java (L31-83: Job nền 01:00 AM lấy snapshot Google Place)
       │
       │  PostgREST API Call (Header apikey: PublishableKey + Bearer: USER_JWT)
       ▼
[Supabase / PostgreSQL Database]
  ├── Function: public.get_dashboard_stats(p_business_id, p_branch_id, p_from, p_to)
  │     └── Thuộc tính: security invoker (chạy bằng quyền người dùng)
  ├── Table: survey_sessions & survey_responses
  │     └── RLS Policy: has_branch_access(branch_id)
  └── Table: metrics (Chứa snapshot Google review_count & avg_rating)
```

---

## 3. Xác Minh Chuyên Sâu 3 Vấn Đề Trọng Tâm

### 3.1. Xác minh Cơ chế Phân quyền Supabase RLS

#### A. Những điểm ĐÃ ĐƯỢC XÁC MINH từ mã nguồn (Source Code Verification):
1. **Phân biệt Credentials:**
   - `SUPABASE_PUBLISHABLE_KEY`: Dùng làm `apikey` header trong `SupabaseDataClient.java` (dòng 46).
   - `USER_JWT`: Lấy trực tiếp từ `@AuthenticationPrincipal Jwt jwt` (`DashboardController.java` dòng 25) và truyền sang Supabase qua `headers.setBearerAuth(accessToken)` (`SupabaseDataClient.java` dòng 58, 105).
   - `SUPABASE_SERVICE_ROLE_KEY`: Chỉ được dùng trong `SupabaseAdminClient.java` (dòng 45–53) cho job nền, hoàn toàn không được dùng cho luồng Dashboard.
2. **Ủy quyền và chuyển tiếp Token:**
   - `DashboardService.java` (dòng 92–99) thực hiện phương thức `requireAccess(token, businessId, branchId)` để kiểm tra quyền ở tầng application logic trước khi gọi xuống repository.
   - `DashboardRepository.java` (dòng 32–39) sử dụng `SupabaseDataClient` để gọi hàm RPC `get_dashboard_stats` kèm access token của người dùng.
3. **Khai báo trên CSDL:**
   - Hàm `get_dashboard_stats` (`database/n5_dashboard.sql` dòng 38) sử dụng cờ **`security invoker`**, đảm bảo câu truy vấn SQL thực thi dưới quyền của User JWT đăng nhập (không chạy với quyền superuser hay bypass RLS).
   - Các chính sách RLS trên bảng `survey_sessions` và `survey_responses` (`n5_dashboard.sql` dòng 10–21) được khai báo rõ ràng, gọi hàm `private.has_branch_access(branch_id)`.

#### B. Những điểm CHƯA ĐƯỢC KIỂM CHỨNG bằng Integration Test (Pending Verification):
1. **Chưa có Integration Test trên môi trường Supabase thật:** Các unit test hiện tại (`DashboardRepositoryTest` và `DashboardServiceTest`) đều mock đối tượng `SupabaseDataClient`. Chưa có bài test nào kết nối đến CSDL PostgreSQL/Supabase thật để chứng thực việc PostgreSQL tự động áp dụng RLS trong hàm `security invoker`.
2. **Chưa kiểm chứng hàm nội bộ `private.has_branch_access`:** Logic phân quyền chi tiết bên trong hàm `private.has_branch_access(branch_id)` (kiểm tra bảng `memberships`, `roles`) chưa được kiểm tra với các vai trò thực tế (`OWNER`, `BRANCH_MANAGER`, `STAFF`).
3. **Chưa kiểm chứng thực nghiệm tính cách ly chéo giữa hai tài khoản:** Chưa có kịch bản chạy thử nghiệm thực tế với 2 tài khoản thuộc 2 chi nhánh khác nhau để chứng minh người này không thể đọc trộm dữ liệu của người kia.
4. **Kết luận chuyên môn của Tester:**  
   > [!IMPORTANT]
   > **Không kết luận RLS đã cách ly dữ liệu 100% trong thực tế.**  
   > Mã nguồn hiện tại chỉ chứng minh **có thiết kế chuyển tiếp User JWT và có khai báo chính sách bảo mật `security invoker`**. Mức độ cách ly dữ liệu thực tế chỉ có thể được kết luận sau khi thực thi bài kiểm thử tích hợp bảo mật đa tài khoản.

#### C. Kịch bản Kiểm thử Tích hợp Bắt buộc để Xác minh Quyền Truy Cập (Cross-Branch Security Test):
Để chứng minh dứt khoát tính cách ly của RLS, Tester thiết kế bài test bắt buộc với 2 tài khoản độc lập (được đưa vào **TC-DASH-23**):
- **Chuẩn bị dữ liệu:**
  - Cơ sở kinh doanh gồm 2 chi nhánh: Chi nhánh 1 (CN01) và Chi nhánh 2 (CN02).
  - Tài khoản A (User A) có vai trò `BRANCH_MANAGER` tại CN01.
  - Tài khoản B (User B) có vai trò `BRANCH_MANAGER` tại CN02.
  - Mỗi chi nhánh có sẵn 5 phiên khảo sát trong kỳ lọc.
- **Thực nghiệm 1 (Truy cập trực tiếp chi nhánh khác):**
  - User A gửi request `GET .../dashboard?branchId={CN02_ID}`.
  - *Kỳ vọng:* Backend ném lỗi HTTP 404 `BRANCH_NOT_FOUND` tại tầng `requireAccess`.
- **Thực nghiệm 2 (Truy cập tổng hợp để kiểm chứng RLS):**
  - User A gửi request `GET .../dashboard` (không truyền `branchId`, tức chọn "Tất cả chi nhánh").
  - *Kỳ vọng:* Hàm `get_dashboard_stats` thực thi trên CSDL chỉ trả về đúng 5 lượt quét của CN01. Toàn bộ 5 lượt quét của CN02 phải bị RLS lọc bỏ hoàn toàn (`scanCount = 5`, không phải `10`). Dữ liệu CN02 không được rò rỉ.

### 3.2. Xác minh Nguy Cơ Đếm Trùng Số Liệu do `LEFT JOIN` (Code Anomaly / High Risk)
- **Vấn đề cấu trúc câu lệnh SQL:**
  - Trong `database/n5_dashboard.sql` (dòng 48–64):
    ```sql
    rows_by_session as (
      select date_trunc('week', ss.scan_date)::date as week_start, r.star_rating, r.redirect_clicked_at
      from sessions ss left join public.survey_responses r on r.session_id = ss.id
    ),
    weekly as (
      select
        week_start,
        count(*)::int as scan_count,
        count(star_rating)::int as rated_count,
        (count(*) filter (where star_rating >= 4))::int as satisfied_count,
        (count(*) filter (where redirect_clicked_at is not null))::int as google_redirect_count
      from rows_by_session group by week_start
    )
    ```
- **Bằng chứng từ Database Schema & Backend:**
  - Bảng `survey_responses` (`database/n1_khao_sat.sql` dòng 25–39) **hoàn toàn không có ràng buộc `UNIQUE(session_id)`**.
  - Phương thức `submitRating` (`SurveyServiceImpl.java` dòng 127–145) thực hiện insert mới `SurveyResponse` mà không kiểm tra trùng lặp session.
- **Phân tích tác động toán học riêng lên từng KPI khi 1 session có $N$ response ($N \ge 2$):**
  - **`scanCount`:** Đang dùng `count(*)::int` sau JOIN. Bị nhân lên $N$ lần. Lưu ý: giải pháp `count(distinct session_id)` **chỉ xử lý được duy nhất `scanCount`**, không giải quyết được các chỉ số còn lại.
  - **`ratedCount`:** Đang dùng `count(star_rating)::int`. Bị nhân lên $N$ lần đối với phiên có rating. `count(distinct ...)` không thể giải quyết được nếu 2 response có dữ liệu khác nhau.
  - **`satisfiedCount`:** Đang dùng `(count(*) filter (where star_rating >= 4))::int`. Bị đếm lặp $N$ lần nếu các response đều $\ge 4$ sao.
  - **`satisfactionRate`:** Tỷ lệ $(\text{satisfiedCount} / \text{ratedCount}) \times 100\%$ bị méo mó, phụ thuộc vào điểm số của các response dư thừa.
  - **`googleRedirectCount`:** Bị nhân lên $N$ lần nếu các response dư thừa đều có cờ chuyển hướng Google.
- **Đề xuất hướng xử lý theo yêu cầu nghiệp vụ:**
  - Cần xác định rõ bài toán nghiệp vụ từ PO/BA: Một phiên khảo sát (`survey_sessions`) theo thiết kế được phép có một (`1:1`) hay nhiều (`1:N`) phản hồi (`survey_responses`)?
  - *Nếu là 1:1:* Cân nhắc bổ sung `CONSTRAINT uq_survey_responses_session UNIQUE (session_id)` trên bảng `survey_responses` ở CSDL và bổ sung cơ chế idempotent / kiểm tra trùng lặp ở tầng backend (`SurveyServiceImpl`) trước khi insert.
  - *Nếu cho phép 1:N:* Backend/SQL cần định nghĩa rõ quy tắc tính toán lấy theo phản hồi nào (ví dụ: chỉ lấy bản ghi mới nhất thông qua `DISTINCT ON (session_id) ORDER BY session_id, created_at DESC`).
- **Phân loại kiểm định:** Ghi nhận là **Điểm bất thường mã nguồn (Code Anomaly / High Risk)**, chưa phải Confirmed Bug vì chưa tái hiện bằng integration test trên PostgreSQL thật. Đưa vào kịch bản kiểm thử **TC-DASH-10** (hiện ở trạng thái *NOT RUN*).

### 3.3. Kiểm Kê và Phân Tích 37 Unit Tests Hiện Có
- **Tổng số tests khảo sát được:** **37 tests** (20 Backend Tests + 17 Frontend Tests):
  1. `DashboardServiceTest.java`: **13 tests** (Bao phủ: tính tỷ lệ %, dữ liệu rỗng, mẫu số 0, mặc định 8 tuần, trung bình gia quyền Google, chặn ngày đảo ngược, chặn khoảng thời gian > 1 năm, chặn truy cập cơ sở/chi nhánh lạ).
  2. `DashboardRepositoryTest.java`: **3 tests** (Bao phủ: gọi RPC `get_dashboard_stats`, query bảng `metrics` theo business và branch).
  3. `GoogleMetricsSnapshotJobTest.java`: **4 tests** (Bao phủ: tính tuần thứ Hai - Chủ Nhật, lưu số liệu Google, bỏ qua khi thiếu API key).
  4. `dashboard_test.dart`: **14 tests** (8 unit tests về parse model, format số/%, query API + 6 widget tests về `MetricCard`, `FunnelChart`, `WeeklyBarChart`, `WeeklyTable`).
  5. `admin_pages_test.dart` (nhóm D5-01): **3 widget tests** (Bao phủ: render màn hình, đổi dropdown chi nhánh, hiển thị khi 0 lượt quét, xử lý nút tải lại khi lỗi).

---

## 4. Xác Định Các Khoảng Trống Kiểm Thử (Test Gaps)

1. **Thiếu WebMvcTest cho `DashboardController`:** Chưa có bài test mock MVC kiểm tra mã phản hồi HTTP 401 khi thiếu JWT, kiểm tra parse `@PathVariable UUID businessId` và `@RequestParam @DateTimeFormat LocalDate from/to`.
2. **Thiếu Database Integration Test:** Toàn bộ test của `DashboardRepositoryTest` và `DashboardServiceTest` đều mock đối tượng `SupabaseDataClient`. Chưa có bài test nào thực thi trực tiếp câu lệnh SQL của hàm `get_dashboard_stats` trên PostgreSQL để phát hiện lỗi logic `LEFT JOIN` và kiểm chứng RLS thực tế.
3. **Thiếu kiểm thử biên múi giờ:** Chưa có test case kiểm tra việc chuyển giao múi giờ giữa UTC và `Asia/Ho_Chi_Minh` cho các phiên quét lúc 23:59 và 00:01.

---

## 5. Đề Xuất Kế Hoạch Kiểm Thử Tự Động (Automation Test Plan)

Để nâng cao độ bao phủ mà không làm thay đổi dữ liệu thật, Tester đề xuất các script kiểm thử tự động sau:
1. **API Integration Smoke Test (Playwright / REST Assured):**
   - Script gọi `GET /api/v1/businesses/{id}/dashboard` với các tổ hợp query param: không param, có `branchId`, có `from` & `to`.
   - Script kiểm tra các ca lỗi: thiếu token (401), ngày đảo ngược (400), cơ sở không tồn tại (404).
2. **Spring Boot MockMvc Controller Test (`DashboardControllerTest.java`):**
   - Viết test độc lập cho tầng web sử dụng `@WebMvcTest(DashboardController.class)` để kiểm tra bảo mật Spring Security và format JSON trả về.
3. **Database Integration Test (`DashboardSqlIntegrationTest.java`):**
   - Chạy trên container PostgreSQL test (Testcontainers) thực thi migration `n5_dashboard.sql` để xác thực:
     - Tính đúng khi có 0 session, 1 session 0 response.
     - Kiểm chứng trường hợp 1 session 2 responses để xác nhận nguy cơ đếm trùng `scanCount`.

---

## 6. Những Thông Tin Cần Hỏi Developer / Product Owner

| STT | Câu hỏi | Đối tượng | Mục đích |
| :---: | :--- | :---: | :--- |
| 1 | Nghiệp vụ quy định 1 phiên khảo sát có tối đa 1 phản hồi (1:1) hay cho phép gửi nhiều phản hồi (1:N)? Nếu 1:1, có thể thêm ràng buộc `UNIQUE(session_id)` trên CSDL và cơ chế idempotent ở backend không? | PO & Developer | Giải quyết triệt để rủi ro kiến trúc `OBS-SCRUM-240-01` |
| 2 | Trong SQL `n5_dashboard.sql`, `count(distinct ss.id)` chỉ giải quyết được `scanCount`. Nếu nghiệp vụ cho phép 1:N thì các KPI `ratedCount`, `satisfiedCount` cần quy tắc tổng hợp cụ thể nào? | PO & Developer | Đảm bảo tính toán nhất quán giữa các KPI |
| 3 | Thẻ "Đánh giá Google" hiện hiển thị số lượng của tuần gần nhất (`latest`), trong khi các thẻ khác là tổng tích lũy trong kỳ (`sum`). PO có muốn bổ sung nhãn/ghi chú làm rõ không? | Product Owner | Tránh hiểu lầm nghiệp vụ cho người dùng phân tích phễu |
| 4 | Có kế hoạch hỗ trợ bộ chọn ngày tùy chỉnh (Custom DateRangePicker) trên giao diện D5-01 trong tương lai không? | Product Owner | Thiết kế mở rộng cho các bài test giao diện sau này |
| 5 | Khi tài khoản Quản lý chi nhánh (`BRANCH_MANAGER`) chỉ quản lý 1 chi nhánh, giao diện có nên ẩn tùy chọn "Tất cả chi nhánh" không? | Product Owner | Tối ưu trải nghiệm và phân quyền giao diện |
