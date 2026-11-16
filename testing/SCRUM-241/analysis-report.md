# BÁO CÁO PHÂN TÍCH MÃ NGUỒN VÀ KIẾN TRÚC KIỂM THỬ (ANALYSIS REPORT)

- **Mã Jira:** SCRUM-241
- **Tên nhiệm vụ:** [E3.1] Kiểm thử chức năng dashboard tổng quan
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người thực hiện:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Phiên bản nền tảng:** CX-SHIELD (Spring Boot 4.0.0, Java 21, Flutter 3.47.2, Dart 3.13.2, Supabase PostgreSQL 15+)
- **Trạng thái:** **HOÀN TẤT ĐÁNH GIÁ KIẾN TRÚC VÀ ĐỐI CHIẾU THỰC THI**

---

## 1. Mục Tiêu và Phạm Vi Khảo Sát Kiến Trúc

Báo cáo phân tích chuyên sâu toàn bộ kiến trúc mã nguồn và luồng dữ liệu của phân hệ Dashboard tổng quan (E3.1 / D5-01), phục vụ nghiệm thu kỹ thuật và thiết lập chuẩn mực kiểm định chất lượng:
1. **Kiến trúc phân tầng toàn diện (End-to-End Pipeline):** Truy vết từ câu lệnh SQL trong migration CSDL đến xử lý tầng Service Backend và hiển thị Widget trên Flutter UI.
2. **Đối chiếu chính xác các công thức thống kê & quy tắc làm tròn:** Phân tích sự nhất quán giữa `satisfactionRate` và `FunnelChart`.
3. **Cơ chế xác thực và bảo mật phân quyền Row-Level Security (Supabase RLS):** Phân tích cơ chế chuyển tiếp User JWT và thuộc tính `security invoker`.
4. **Kiến trúc điều hướng & Màn hình xuất phát mặc định:** Phân tích `router.dart`, `SessionController`, `AdminShell` và `admin_menu.dart`.
5. **Đánh giá kiểm kê 65 automated tests hiện có:** Đo lường độ bao phủ thực tế và giải trình nguyên nhân 4 Test Cases bị nghẽn (BLOCKED).

---

## 2. Kiến Trúc Phân Tầng và Luồng Dữ Liệu Toàn Diện (End-to-End Architecture)

Sơ đồ dưới đây mô tả chi tiết luồng xử lý dữ liệu từ thao tác của người dùng đến các bảng CSDL:

```
[Người dùng / Trình duyệt / Ứng dụng Quản trị]
       │
       │  (1) HTTP GET /api/v1/businesses/{businessId}/dashboard?branchId=...&from=...&to=...
       │      Header: Authorization: Bearer <USER_JWT>
       ▼
[Spring Boot Backend]
  ├── SecurityConfig.java (Dòng 39: Yêu cầu JWT xác thực cho mọi route /api/**)
  ├── DashboardController.java (Dòng 25–31: Tiếp nhận JWT, businessId, branchId, from, to)
  ├── DashboardService.java (Dòng 53–140: Xử lý nghiệp vụ phân quyền, thống kê, làm tròn)
  │     ├── requireAccess(): Kiểm tra User có quyền truy cập cơ sở/chi nhánh hay không
  │     ├── validateRange(): Kiểm tra khoảng thời gian (from <= to và <= 366 ngày)
  │     ├── percent(): Tính tỷ lệ %, làm tròn bán phần lên 1 số thập phân, fallback null
  │     └── groupByWeek(): Ghép nối tuần giữa số liệu khảo sát và snapshot Google Places
  ├── DashboardRepository.java (Dòng 32–51: Truy vấn qua SupabaseDataClient)
  └── GoogleMetricsSnapshotJob.java (Dòng 31–83: Job nền lấy snapshot Google Places định kỳ)
       │
       │  (2) PostgREST API Call (Header apikey: PublishableKey + Bearer: USER_JWT)
       ▼
[Supabase / PostgreSQL Database]
  ├── Function: public.get_dashboard_stats(p_business_id, p_branch_id, p_from, p_to)
  │     └── Thuộc tính cốt lõi: security invoker (chạy dưới ngữ cảnh quyền của USER_JWT)
  ├── Tables: survey_sessions & survey_responses
  │     └── RLS Policy: private.has_branch_access(branch_id)
  └── Table: metrics (Lưu trữ snapshot lịch sử của Google review_count & avg_rating)
```

---

## 3. Phân Tích Chuyên Sâu Các Trọng Tâm Kỹ Thuật

### 3.1. Đối Chiếu Công Thức Tính Toán `satisfactionRate` và Quy Tắc Làm Tròn

Quá trình truy vết mã nguồn xác nhận công thức tính tỷ lệ hài lòng được phân tách trách nhiệm rõ ràng qua 3 tầng:

1. **Tầng CSDL (`database/n5_dashboard.sql` dòng 52–54):**
   ```sql
   count(star_rating)::int as rated_count,
   (count(*) filter (where star_rating >= 4))::int as satisfied_count
   ```
   - SQL **chỉ làm nhiệm vụ đếm số nguyên thô**, tuyệt đối không thực hiện phép chia hay tính phần trăm nhằm tránh sai số dấu phẩy động ở tầng CSDL.
2. **Tầng Backend Service (`DashboardService.java` dòng 125–131):**
   ```java
   private Double percent(long count, long total) {
       if (total <= 0) {
           return null;
       }
       double value = count * 100.0 / total;
       return Math.round(value * 10) / 10.0;
   }
   ```
   - **Mẫu số quy định:** Là `ratedCount` (Tổng số lượt khách đã thực sự đánh giá sao), **hoàn toàn KHÔNG PHẢI là `scanCount`**.
   - **Quy tắc làm tròn:** `Math.round(value * 10) / 10.0` thực hiện làm tròn bán phần lên (*Round half-up*) tới đúng **1 chữ số thập phân**.
   - **Xử lý mẫu số bằng 0:** Nếu `total <= 0`, hàm lập tức trả về `null` an toàn, ngăn chặn triệt để ngoại lệ `ArithmeticException` (chia cho 0).
3. **Tầng Giao diện Flutter (`dashboard_models.dart` & `dashboard_page.dart`):**
   ```dart
   String formatPercent(double? value) {
     if (value == null) return '—';
     if (value % 1 == 0) return '${value.toInt()}%';
     return '${value.toStringAsFixed(1).replaceAll('.', ',')}%';
   }
   ```
   - Nếu `satisfactionRate == null` $\rightarrow$ hiển thị ký tự gạch ngang `'—'`.
   - Nếu là số nguyên (ví dụ `75.0`) $\rightarrow$ hiển thị `"75%"`.
   - Nếu có phần thập phân (ví dụ `82.5`) $\rightarrow$ định dạng chuẩn tiếng Việt với dấu phẩy: `"82,5%"`.
   - Thẻ số liệu 2 hiển thị ghi chú phụ rõ ràng: `"${ratedCount} lượt đánh giá"`.

### 3.2. Đối Chiếu Công Thức Phễu Chuyển Đổi (`FunnelChart`)

Có sự phân định nghiệp vụ rõ ràng giữa Thẻ số liệu 2 và Bước 3 của Phễu chuyển đổi:

| Thành phần | Công thức mẫu số | Ý nghĩa nghiệp vụ | Ví dụ thực tế |
| :--- | :---: | :--- | :--- |
| **Thẻ số liệu 2** (Hài lòng 4–5 sao) | $\text{Mẫu số} = \text{ratedCount}$ | Đo lường mức độ hài lòng của **những khách hàng đã tham gia đánh giá sao**. | $560 / 684 \times 100\% = \mathbf{81{,}9\%}$ |
| **Bước 3 của Phễu** (`FunnelChart`) | $\text{Mẫu số} = \text{scanCount}$ | Đo lường tỷ lệ chuyển đổi từ **tổng số khách quét mã QR ban đầu** đạt đến bước hài lòng. | $560 / 1248 \times 100\% = \mathbf{44{,}9\%}$ |

- **Kết luận:** Cả hai công thức đều được lập trình chính xác theo đúng mục tiêu thiết kế. Tỷ lệ % của Bước 3 trong phễu luôn nhỏ hơn hoặc bằng tỷ lệ trên Thẻ số liệu 2, phản ánh độ rơi rụng tự nhiên qua từng nấc thang chuyển đổi.

### 3.3. Xác Minh Kiến Trúc Điều Hướng & Màn Hình Dashboard Mặc Định

Kiến trúc điều hướng của CX-SHIELD đảm bảo người dùng quản trị luôn được đưa về Dashboard D5-01 sau khi xác thực thành công:
1. **Router Guards (`router.dart`):**
   - Khi `session.status == SessionStatus.ready` và `session.isOnboarded == true`, bất kỳ nỗ lực truy cập vào `/` hoặc `/login` đều được `sessionRedirect` điều hướng sang `'/dashboard'`.
   - Nếu chưa đăng nhập (`SessionStatus.signedOut`), mọi truy cập vào `/dashboard` bị chặn và đẩy về `'/login'`.
   - Nếu đăng nhập nhưng chưa hoàn tất thiết lập cơ sở (`isOnboarded == false`), người dùng bị đẩy về `'/onboarding'`.
2. **Cấu trúc Menu Quản trị (`admin_menu.dart`):**
   - Danh mục menu admin định nghĩa phần tử đầu tiên `#0` là "Tổng quan" (`/dashboard`, screenCode `D5-01`).
3. **Khung giao diện thích ứng (`AdminShell`):**
   - Tự động mở menu `#0` khi khởi động.
   - Thích ứng hoàn hảo trên Desktop (NavigationRail / Row $\ge 760\text{px}$) và Mobile (BottomNavigationBar / Column $< 760\text{px}$), hoàn toàn không xảy ra lỗi tràn layout.

### 3.4. Đánh Giá Cơ Chế Phân Quyền Row-Level Security (Supabase RLS)

1. **Những điểm ĐÃ ĐƯỢC XÁC MINH trong mã nguồn:**
   - Token người dùng (`USER_JWT`) được trích xuất từ Spring Security và chuyển tiếp nguyên vẹn sang Supabase PostgREST qua header `Authorization: Bearer <USER_JWT>`.
   - Header `apikey` sử dụng `SUPABASE_PUBLISHABLE_KEY`. Quyền `SUPABASE_SERVICE_ROLE_KEY` tuyệt đối không được dùng cho luồng Dashboard, loại bỏ nguy cơ vô tình bypass RLS.
   - Hàm `public.get_dashboard_stats` được khai báo rõ ràng với thuộc tính **`security invoker`**, đảm bảo SQL chạy dưới đặc quyền của user gửi token.
   - Các bảng `survey_sessions` và `survey_responses` cài đặt RLS policy gọi hàm kiểm tra `private.has_branch_access(branch_id)`.
2. **Những điểm CHƯA THỂ KIỂM CHỨNG và lý do ca test TC-D501-INT-03 bị BLOCKED:**
   - Bộ test tự động hiện tại (`DashboardRepositoryTest`) sử dụng Mockito để mock toàn bộ đối tượng `SupabaseDataClient`.
   - Để khẳng định 100% RLS cách ly an toàn dữ liệu giữa 2 người dùng của 2 chi nhánh khác nhau, bắt buộc phải có môi trường Supabase Auth live với 2 token thật. Do đó, QA xếp ca kiểm thử này vào nhóm **BLOCKED** thay vì suy đoán PASS.

### 3.5. Phân Tích Bất Thường Mã Nguồn Tiềm Ẩn Rủi Ro Cao (`OBS-SCRUM-241-01`)

- **Bản chất khiếm khuyết:**
  - Bảng `survey_responses` thiếu ràng buộc toàn vẹn `UNIQUE(session_id)`.
  - Hàm SQL `get_dashboard_stats` thực hiện phép nối:
    `sessions ss LEFT JOIN public.survey_responses r ON r.session_id = ss.id`
  - Sau đó tính:
    `count(*)::int as scan_count`
- **Tác động:** Khi 1 phiên quét phát sinh $N \ge 2$ responses, phép JOIN sẽ nhân số dòng của phiên quét đó lên $N$ lần, dẫn tới việc toàn bộ các chỉ số `scan_count`, `rated_count`, `satisfied_count`, `google_redirect_count` bị nhân bản $N$ lần.
- **Giải pháp:** Cần bổ sung ràng buộc duy nhất ở CSDL hoặc dùng cú pháp `DISTINCT ON (session_id) ORDER BY session_id, created_at DESC` trước khi thực hiện tính tổng KPI.

---

## 4. Kiểm Kê & Đánh Giá Độ Bao Phủ Của 65 Automated Tests

Toàn bộ 65 bài automated tests đã được thực thi và xác minh kết quả trực tiếp:

| Bộ test / Tệp tin | Số bài test | Kết quả chạy | Thời gian chạy | Chức năng bảo chứng |
| :--- | :---: | :---: | :---: | :--- |
| `DashboardServiceTest.java` | 13 | **13/13 PASS** | 0.185s | Nghiệp vụ tính %, làm tròn, validate khoảng ngày, phân quyền |
| `DashboardRepositoryTest.java` | 3 | **3/3 PASS** | 0.993s | Chuyển tiếp RPC param `branchId`, query `metrics` PostgREST |
| `GoogleMetricsSnapshotJobTest.java` | 4 | **4/4 PASS** | 0.154s | Job nền 01:00 AM, tính tuần Thứ Hai - Chủ Nhật, an toàn API key |
| `dashboard_test.dart` | 14 | **14/14 PASS** | ~3s | Format số VN, MetricCard, FunnelChart, WeeklyBarChart, WeeklyTable |
| `admin_pages_test.dart` (D5-01) | 3 | **3/3 PASS** | ~1s | Đổi filter dropdown gọi API, Empty banner, Error banner & retry |
| `admin_shell_pages_test.dart` | 8 | **8/8 PASS** | ~2s | Menu item #0 mở `/dashboard` trên Desktop và Mobile |
| `auth_onboarding_test.dart` | 20 | **20/20 PASS** | ~1s | Router redirect sau login/onboard, menu admin paths |
| **TỔNG CỘNG** | **65** | **65/65 PASS** | **~8.3s** | **Bao phủ 100% các luồng Unit/Widget/Router khả thi** |

---

## 5. Đánh Giá Khung Nghiệm Thu & Khuyến Nghị QA Sign-off

1. **Mức độ hoàn thiện:**
   - **Giao diện & Trải nghiệm (Frontend):** Vượt qua 100% các tiêu chí nghiệm thu về bố cục, tính toán phần trăm, định dạng số/ngày tiếng Việt, xử lý trạng thái rỗng và xử lý lỗi mạng.
   - **Tầng Dịch vụ (Backend Service):** Vượt qua 100% các ràng buộc về logic tính toán, phân quyền truy cập cơ sở và chuẩn hoá dữ liệu theo tuần.
2. **Điều kiện bàn giao Staging/Production:**
   - Đội ngũ phát triển cần xử lý dứt điểm điểm bất thường `OBS-SCRUM-241-01` (xác định quan hệ 1:1 hay 1:N cho phản hồi khảo sát).
   - Thực thi 4 bài kiểm thử tích hợp CSDL thật (`TC-D501-INT-01` đến `INT-04`) trên môi trường Staging có kết nối PostgreSQL / Supabase trước khi kích hoạt tính năng cho người dùng cuối.
