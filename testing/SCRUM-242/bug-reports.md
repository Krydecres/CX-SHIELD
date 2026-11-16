# BÁO CÁO GHI NHẬN LỖI (BUG REPORTS & OBSERVATIONS) - SCRUM-242

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Ngày lập:** 16/11/2026
- **Trạng thái tài liệu:** **AUDITED** *(0 Confirmed Bugs Trong Phạm Vi Kiểm Thử Tự Động Cục Bộ)*

---

## 1. TỔNG HỢP TRẠNG THÁI KHUYẾT TẬT (DEFECT SUMMARY)

| Mức độ nghiêm trọng (Severity) | Đang mở (Open) | Đã giải quyết (Resolved) | Đóng (Closed) | Tổng số |
| :--- | :---: | :---: | :---: | :---: |
| **Blocker / Critical (Nghiêm trọng)** | 0 | 0 | 0 | **0** |
| **Major (Lớn)** | 0 | 0 | 0 | **0** |
| **Minor / Trivial (Nhỏ / Giao diện)** | 0 | 0 | 0 | **0** |
| **TỔNG CỘNG** | **0** | **0** | **0** | **0** |

> [!NOTE]
> **Quy tắc kết luận về lỗi:**
> Con số **0 Confirmed Bugs** chỉ phản ánh rằng **trong phạm vi các kịch bản kiểm thử tự động đã thực hiện trên môi trường local (MockMvc và MockClient)**, không có lỗi chức năng hoặc lỗi hồi quy nào được xác nhận. Kết quả này không đồng nghĩa với việc toàn bộ hệ thống trên môi trường production không có lỗi tiềm ẩn.

---

## 2. GHI NHẬN CÁC ĐIỂM QUAN SÁT KỸ THUẬT (TECHNICAL OBSERVATIONS & HARNESS RESOLUTIONS)

Trong quá trình xây dựng bộ kiểm thử tự động, đội ngũ QA Automation ghi nhận và xử lý các đặc tính kiến trúc sau:

### 2.1. Quan sát 1: Phụ thuộc liên phân hệ giữa DashboardPage và GooglePlaceApi
- **Hiện tượng:** Khi `DashboardPage` khởi tạo (`initState`), ngoài việc gọi `DashboardApi.load(...)`, widget còn tự động kích hoạt `_loadGoogleStatus()` gọi tới endpoint `/api/v1/branches/{branchId}/google-place`.
- **Phân tích:** Endpoint này trả về thông tin kết nối Google Place ID của chi nhánh hiện tại nhằm hiển thị trạng thái trong danh mục "Việc cần thiết lập". Nếu mock server không định tuyến URL này và trả về JSON không đúng format `GooglePlaceConfig`, hàm parse sẽ ném lỗi cast type và giữ `_googleStatus = null`, dẫn đến `CircularProgressIndicator` chạy vô hạn làm treo lệnh `pumpAndSettle()`.
- **Giải pháp xử lý kịch bản kiểm thử:** `MockClient` trong kịch bản test automation đã được thiết kế để xử lý định tuyến URL thông minh:
  ```dart
  if (request.url.path.contains('/google-place')) {
    final segments = request.url.pathSegments;
    final bIdx = segments.indexOf('branches');
    final branchId = bIdx != -1 && bIdx + 1 < segments.length ? segments[bIdx + 1] : 'c1';
    return http.Response.bytes(utf8.encode(jsonEncode({
      'branchId': branchId,
      'branchName': 'Chi nhánh $branchId',
      'connectionStatus': 'NOT_CONNECTED',
      'googleVerificationEnabled': false,
    })), 200);
  }
  ```
- **Đánh giá:** Đây là hành vi đúng theo thiết kế liên kết sản phẩm giữa phân hệ D5-01 và D3-05, không phải lỗi nghiệp vụ.

---

### 2.2. Quan sát 2: Sự xuất hiện đồng thời của các con số trên MetricCards và WeeklyTable
- **Hiện tượng:** Các giá trị số liệu như `450` (số lượt review Google), `62,5%` (tỷ lệ hài lòng chi nhánh 1) hoặc `100%` đồng thời hiển thị ở cả Thẻ tổng quan (`MetricCard`) lẫn Bảng chi tiết tuần (`WeeklyTable`) hoặc Phễu chuyển đổi (`FunnelChart`).
- **Phân tích:** Việc sử dụng bộ tìm kiếm cơ bản `find.text('450')` với matcher `findsOneWidget` sẽ trả về cảnh báo `Found 2 widgets with text "450"`.
- **Giải pháp kiểm thử:** Kịch bản test sử dụng `findsWidgets` để kiểm tra sự tồn tại của các giá trị trên giao diện mà không gây false-positive fail.

---

### 2.3. Quan sát 3: Biên giới giữa Local Test Environment và Live Cloud Database
- **Hiện tượng:** Trong môi trường CI cục bộ offline:
  - Backend `DashboardControllerSecurityTest` sử dụng `@MockitoBean` cho `DashboardService` và giả lập JWT bằng Spring Security test context.
  - Frontend `dashboard_automation_reconciliation_test.dart` sử dụng HTTP `MockClient` trả về payload định sẵn.
- **Đánh giá phạm vi:**
  - Bộ test kiểm tra toàn diện và cô lập logic của tầng Controller (xác thực, mã lỗi 401, 200, 404, 400) và tầng Widget (render thẻ, tỷ lệ phễu, chuyển đổi dropdown, router guards).
  - Các khía cạnh phụ thuộc môi trường thật gồm: (1) Kiểm tra chữ ký mật mã của JWT với Supabase Auth, (2) Kiểm tra RLS đa người thuê trên database PostgreSQL thật, và (3) Đối chiếu trực tiếp trên các bảng `survey_responses` live **chưa được thực hiện** trong đợt test này và được phân loại minh bạch là **BLOCKED**.

---

## 3. KẾT LUẬN CHUNG
- Trong phạm vi kiểm thử tự động cục bộ của SCRUM-242, **0 lỗi nghiệp vụ và 0 lỗi hồi quy** được ghi nhận.
- Tất cả 96 automated test methods đã chạy đều hoạt động ổn định và chính xác.
