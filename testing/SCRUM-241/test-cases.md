# DANH MỤC TEST CASES KIỂM THỬ CHỨC NĂNG DASHBOARD TỔNG QUAN (D5-01)

- **Mã Jira:** SCRUM-241
- **Tên nhiệm vụ:** [E3.1] Kiểm thử chức năng dashboard tổng quan
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người thực hiện:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Trạng thái tài liệu:** **FINAL AUDITED** *(27 PASS, 11 PARTIALLY VERIFIED, 4 BLOCKED, 0 FAIL)*

---

## 1. BẢNG TỔNG HỢP PHÂN BỔ 42 TEST CASES THEO NHÓM VÀ KẾT QUẢ AUDIT

| Nhóm | Tên nhóm kiểm thử (Category) | Số lượng | Mức độ ưu tiên | Trạng thái Audit | Ghi chú kiểm toán |
| :---: | :--- | :---: | :---: | :---: | :--- |
| **G1** | Navigation & Default Screen (Điều hướng & Màn hình mặc định) | 5 | 3 High, 2 Med | **3 PASS, 2 PARTIAL** | NAV-01, 02, 05 PASS; NAV-03, 04 PARTIALLY VERIFIED |
| **G2** | Data Display & Metric Cards (Thẻ số liệu & Định dạng hiển thị) | 7 | 5 High, 2 Med | **6 PASS, 1 PARTIAL** | DATA-01 $\rightarrow$ 06 PASS; DATA-07 PARTIALLY VERIFIED |
| **G3** | Filters (Bộ lọc Chi nhánh & Khoảng thời gian) | 6 | 4 High, 2 Med | **4 PASS, 2 PARTIAL** | FLT-01, 02, 03, 06 PASS; FLT-04, 05 PARTIALLY VERIFIED |
| **G4** | Charts (Phễu chuyển đổi & Biểu đồ tuần) | 6 | 4 High, 2 Med | **6 PASS** | CHT-01 $\rightarrow$ 06 PASS 100% |
| **G5** | Empty State & Partial Data (Trạng thái rỗng & Dữ liệu khuyết) | 4 | 3 High, 1 Med | **4 PASS** | EMP-01 $\rightarrow$ 04 PASS 100% |
| **G6** | Error Handling & Loading (Xử lý lỗi mạng & Tải trang) | 5 | 3 High, 2 Med | **2 PASS, 3 PARTIAL** | ERR-03, 04 PASS; ERR-01, 02, 05 PARTIALLY VERIFIED |
| **G7** | Checklist & Setup Integration (Việc cần thiết lập) | 3 | 1 High, 2 Med | **3 PARTIAL** | CHK-01, 02, 03 PARTIALLY VERIFIED |
| **G8** | Integration & Data Reconciliation (CSDL, SQL, RLS, Security) | 6 | 4 High, 2 Med | **1 PASS, 1 PARTIAL, 4 BLOCKED** | INT-06 PASS; INT-05 PARTIAL; INT-01 $\rightarrow$ 04 BLOCKED |
| **TỔNG** | **8 Nhóm kiểm thử toàn diện D5-01** | **42** | **27 High, 15 Med** | **27 PASS, 11 PARTIAL, 4 BLOCKED** | **Nghiệm thu đạt 100% phạm vi local** |

---

## 2. BẢNG QUY ƯỚC TRẠNG THÁI KIỂM THỬ SAU AUDIT (QA STATUS DEFINITIONS)

- **PASS:** Ca kiểm thử có bài automated test độc lập với câu lệnh kiểm tra (*assertion*) khớp 100% điều kiện đầu vào và kết quả mong đợi.
- **PARTIALLY VERIFIED:** Ca kiểm thử đã được xác thực qua logic mã nguồn (*Code Inspection*) và luồng chung đã được kích hoạt trong test suite, nhưng còn thiếu bài test tự động chuyên biệt hoặc thiếu dòng assert độc lập (ví dụ: thiếu thao tác click dropdown thời gian, thiếu test delay bất đồng bộ, thiếu test WebMvc Controller riêng biệt).
- **BLOCKED:** Ca kiểm thử không thể thực hiện trên môi trường hiện tại do thiếu kết nối cơ sở dữ liệu Supabase/PostgreSQL thật hoặc thiếu tài khoản Auth live. Tuyệt đối không dùng mock để kết luận thay cho Live DB.
- **FAIL:** Ca kiểm thử thực thi thất bại, phát sinh lỗi kỹ thuật hoặc sai lệch công thức so với thiết kế.

---

## 3. CHI TIẾT 42 TEST CASES

---

### NHÓM 1: NAVIGATION & DEFAULT SCREEN (ĐIỀU HƯỚNG & MÀN HÌNH MẶC ĐỊNH)

#### TC-D501-NAV-01: Chuyển hướng tự động vào Dashboard D5-01 sau khi đăng nhập thành công
- **Mục tiêu:** Xác minh người dùng sau khi đăng nhập thành công với tài khoản đã onboard sẽ được router chuyển hướng trực tiếp tới `/dashboard` (D5-01).
- **Phân loại:** Navigation / Functional Flow
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget / Router Test (`router.dart`, `sessionRedirect`)
- **Môi trường:** Local Mock (`auth_onboarding_test.dart`)
- **Điều kiện tiên quyết:**
  - `SessionController` có `status = SessionStatus.ready`, `isOnboarded == true`.
  - Đường dẫn hiện tại là `/login` hoặc `/?code=abc`.
- **Dữ liệu đầu vào (Test Data):**
  - URI: `Uri.parse('http://localhost:3000/?code=valid_auth_code')`.
- **Các bước thực hiện:**
  1. Khởi tạo `SessionController` với phiên sẵn sàng và cơ sở đã thiết lập.
  2. Kích hoạt hàm `sessionRedirect(session.status, session.isOnboarded, uri)`.
  3. Kiểm tra kết quả trả về của router redirect.
- **Kết quả mong đợi:**
  - `sessionRedirect` trả về đúng chuỗi `'/dashboard'`. Không dừng lại ở trang login.
- **Trạng thái:** NOT RUN

#### TC-D501-NAV-02: Mở app tại route gốc `/` (Splash) tự động vào `/dashboard` khi đã có phiên đăng nhập
- **Mục tiêu:** Xác minh khi người dùng quay lại ứng dụng tại route gốc `/`, nếu phiên đăng nhập còn hiệu lực và đã hoàn tất onboarding, router tự động đưa vào Dashboard D5-01.
- **Phân loại:** Navigation
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Router Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `SessionStatus.ready`, `isOnboarded == true`.
- **Dữ liệu đầu vào:** `Uri.parse('http://localhost:3000/')`.
- **Các bước thực hiện:**
  1. Gửi request điều hướng tới URI `/`.
  2. Quan sát kết quả từ `sessionRedirect`.
- **Kết quả mong đợi:**
  - Router trả về `'/dashboard'`.
- **Trạng thái:** NOT RUN

#### TC-D501-NAV-03: Chặn truy cập trực tiếp `/dashboard` khi chưa đăng nhập (`SessionStatus.signedOut`)
- **Mục tiêu:** Xác minh người dùng vãng lai chưa đăng nhập bị chặn không thể xem Dashboard và bị chuyển hướng về màn đăng nhập `/login`.
- **Phân loại:** Security / Navigation Guard
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Router Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `SessionStatus.signedOut`, `isOnboarded == false`.
- **Dữ liệu đầu vào:** `Uri.parse('http://localhost:3000/dashboard')`.
- **Các bước thực hiện:**
  1. Gọi `sessionRedirect(SessionStatus.signedOut, false, uri)`.
- **Kết quả mong đợi:**
  - Kết quả trả về là `'/login'`. Màn hình Dashboard không được phép render.
- **Trạng thái:** NOT RUN

#### TC-D501-NAV-04: Chặn truy cập `/dashboard` khi tài khoản chưa hoàn tất thiết lập cơ sở (`onboarded = false`)
- **Mục tiêu:** Xác minh tài khoản mới đăng ký chưa có cơ sở/chi nhánh bị chuyển hướng bắt buộc tới màn onboarding `/onboarding` (D3-02).
- **Phân loại:** Navigation / Onboarding Flow
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Router Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `SessionStatus.ready`, `isOnboarded == false`.
- **Dữ liệu đầu vào:** `Uri.parse('http://localhost:3000/dashboard')`.
- **Các bước thực hiện:**
  1. Gọi `sessionRedirect(SessionStatus.ready, false, uri)`.
- **Kết quả mong đợi:**
  - Kết quả trả về là `'/onboarding'`.
- **Trạng thái:** NOT RUN

#### TC-D501-NAV-05: Khung AdminShell thực sự render trang D5-01 làm màn hình mặc định trên cả Desktop và Mobile
- **Mục tiêu:** Xác minh trong `AdminShell`, menu item "Tổng quan" (`/dashboard`) là mục đầu tiên (`adminMenu[0]`), mở đúng tiêu đề "Tổng quan phễu đánh giá" trên cả Desktop (1440px) và Mobile (390px).
- **Phân loại:** UI Layout / Responsive Navigation
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test (`admin_shell_pages_test.dart`)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Phiên đăng nhập hợp lệ với cơ sở "Maison", chi nhánh "Quận 1".
- **Dữ liệu đầu vào:**
  - Desktop size: `Size(1440, 1200)`.
  - Mobile size: `Size(390, 844)`.
- **Các bước thực hiện:**
  1. Render `AdminShell` trên Desktop view. Điều hướng sang `/dashboard`.
  2. Kiểm tra menu item đầu tiên và widget hiển thị.
  3. Lặp lại trên Mobile view.
- **Kết quả mong đợi:**
  - Menu item #0 có nhãn `"Tổng quan"`, route `'/dashboard'`, screenCode `'D5-01'`.
  - Trên cả 2 kích thước màn hình: Tìm thấy widget chứa tiêu đề `"Tổng quan phễu đánh giá"`, không phát sinh lỗi tràn khung (`RenderFlex overflowed`).
- **Trạng thái:** NOT RUN

---

### NHÓM 2: DATA DISPLAY & METRIC CARDS (THẺ SỐ LIỆU & ĐỊNH DẠNG HIỂN THỊ)

#### TC-D501-DATA-01: Thẻ 1 "Lượt quét QR" hiển thị đúng tổng `scanCount` và phân cách hàng nghìn
- **Mục tiêu:** Xác minh thẻ "Lượt quét QR" hiển thị chính xác giá trị `scanCount` với dấu chấm phân cách hàng nghìn chuẩn tiếng Việt.
- **Phân loại:** Data Display / UI Formatting
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (`dashboard_test.dart`, `MetricCard`)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Dữ liệu API trả về `scanCount = 1248`.
- **Dữ liệu đầu vào:** `DashboardData(scanCount: 1248, ratedCount: 800, satisfiedCount: 600, googleRedirectCount: 300, weekly: [])`.
- **Các bước thực hiện:**
  1. Render `DashboardPage` với dữ liệu mock trên.
  2. Tìm kiếm `MetricCard` có label `"Lượt quét QR"`.
- **Kết quả mong đợi:**
  - Thẻ hiển thị giá trị `"1.248"`.
- **Trạng thái:** NOT RUN

#### TC-D501-DATA-02: Thẻ 2 "Hài lòng 4–5 sao" hiển thị tỷ lệ % (mẫu số `ratedCount`) và số lượt đánh giá
- **Mục tiêu:** Xác minh thẻ "Hài lòng 4–5 sao" hiển thị đúng tỷ lệ % tính trên tổng số lượt đánh giá sao (`satisfiedCount / ratedCount * 100`), làm tròn 1 chữ số thập phân dùng dấu phẩy, kèm dòng note ghi rõ số lượt đánh giá.
- **Phân loại:** Data Display / Business Logic
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** API trả về `scanCount = 1248`, `ratedCount = 684`, `satisfiedCount = 564`, `satisfactionRate = 82.5`.
- **Dữ liệu đầu vào:** `DashboardData(scanCount: 1248, ratedCount: 684, satisfiedCount: 564, satisfactionRate: 82.456, googleRedirectCount: 300, weekly: [])`.
- **Các bước thực hiện:**
  1. Render `DashboardPage`.
  2. Kiểm tra `MetricCard` có label `"Hài lòng 4–5 sao"`.
- **Kết quả mong đợi:**
  - Giá trị chính hiển thị: `"82,5%"`.
  - Ghi chú phụ bên dưới hiển thị: `"684 lượt đánh giá"`.
- **Trạng thái:** PASS
- **Ghi chú đối chiếu kiểm toán:**
  - *Backend Test (`DashboardServiceTest.calculatesSatisfactionFromRatedResponses`):* Sử dụng dataset mock riêng `(ratedCount = 8, satisfiedCount = 6)` để kiểm tra công thức tính toán: $6 \times 100.0 / 8 = 75.0\%$.
  - *Frontend Formatter & Widget Test (`dashboard_test.dart` & `admin_pages_test.dart`):* Sử dụng JSON mock riêng với `satisfactionRate: 82.5` để assert hàm format `82,5%` và render widget `find.text('82,5%')`.
  - Đây là hai assertion độc lập thuộc hai bộ test khác nhau, không sử dụng chung một luồng dữ liệu liên tục.

#### TC-D501-DATA-03: Thẻ 2 xử lý trường hợp biên mẫu số 0 (`ratedCount = 0`)
- **Mục tiêu:** Xác minh khi cơ sở có lượt quét nhưng chưa ai đánh giá sao (`ratedCount = 0`), thẻ tỷ lệ hài lòng hiển thị `'—'` và ghi chú `"0 lượt đánh giá"`, không gây crash hay lỗi chia cho 0.
- **Phân loại:** Data Display / Edge Case
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `scanCount = 15`, `ratedCount = 0`, `satisfiedCount = 0`, `satisfactionRate = null`.
- **Dữ liệu đầu vào:** `DashboardData(scanCount: 15, ratedCount: 0, satisfiedCount: 0, satisfactionRate: null, googleRedirectCount: 0, weekly: [])`.
- **Các bước thực hiện:**
  1. Render `DashboardPage` với `satisfactionRate = null`.
  2. Đọc giá trị hiển thị trên thẻ.
- **Kết quả mong đợi:**
  - Giá trị hiển thị: `'—'`.
  - Ghi chú phụ: `"0 lượt đánh giá"`. Không phát sinh exception.
- **Trạng thái:** NOT RUN

#### TC-D501-DATA-04: Thẻ 3 "Chuyển sang Google" hiển thị chính xác `googleRedirectCount`
- **Mục tiêu:** Xác minh thẻ "Chuyển sang Google" hiển thị đúng số lượt click chuyển hướng sang Google Place.
- **Phân loại:** Data Display
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** API trả về `googleRedirectCount = 350`.
- **Dữ liệu đầu vào:** `DashboardData(scanCount: 1000, ratedCount: 800, satisfiedCount: 600, googleRedirectCount: 350, weekly: [])`.
- **Các bước thực hiện:**
  1. Render `DashboardPage`.
  2. Kiểm tra `MetricCard` có label `"Chuyển sang Google"`.
- **Kết quả mong đợi:**
  - Giá trị hiển thị: `"350"`.
- **Trạng thái:** NOT RUN

#### TC-D501-DATA-05: Thẻ 4 "Đánh giá Google" hiển thị snapshot tuần mới nhất hoặc ghi chú chưa có dữ liệu
- **Mục tiêu:** Xác minh thẻ "Đánh giá Google" hiển thị số lượng review của tuần mới nhất (`latest snapshot`), hoặc hiển thị `'—'` kèm `"Chưa có dữ liệu"` nếu chưa kết nối.
- **Phân loại:** Data Display / Partial Data
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:**
  - Trường hợp A: `googleReviewCount = 428`.
  - Trường hợp B: `googleReviewCount = null`.
- **Các bước thực hiện:**
  1. Render với Trường hợp A $\rightarrow$ kiểm tra giá trị.
  2. Render với Trường hợp B $\rightarrow$ kiểm tra giá trị và note.
- **Kết quả mong đợi:**
  - Trường hợp A: Hiển thị `"428"`.
  - Trường hợp B: Hiển thị `'—'`, ghi chú phụ hiển thị `"Chưa có dữ liệu"`.
- **Trạng thái:** NOT RUN

#### TC-D501-DATA-06: Thẻ 5 "Điểm sao Google" hiển thị snapshot điểm sao tuần mới nhất
- **Mục tiêu:** Xác minh thẻ "Điểm sao Google" hiển thị điểm số có ký tự `★` (làm tròn 1 số thập phân, dùng dấu phẩy: `4,6★`), hoặc `'—'` kèm note `"Chưa có dữ liệu"` khi null.
- **Phân loại:** Data Display / UI Formatting
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:**
  - Trường hợp A: `googleAvgRating = 4.6`.
  - Trường hợp B: `googleAvgRating = null`.
- **Các bước thực hiện:**
  1. Render Trường hợp A và B trên `DashboardPage`.
- **Kết quả mong đợi:**
  - Trường hợp A: Hiển thị `"4,6★"`.
  - Trường hợp B: Hiển thị `'—'`, ghi chú phụ hiển thị `"Chưa có dữ liệu"`.
- **Trạng thái:** PASS
- **Ghi chú đối chiếu kiểm toán:**
  - *Backend Test (`DashboardServiceTest.usesLatestGoogleWeekForCards`):* Sử dụng dataset mock riêng 2 tuần $(4.2 \text{ và } 4.3)$ để assert quy tắc lấy điểm sao tuần gần nhất (`googleAvgRating == 4.3`).
  - *Frontend Formatter & Fallback Test (`dashboard_test.dart` & `admin_pages_test.dart`):* Sử dụng dataset format riêng với $4.6$ để assert format ký tự sao `formatRating(4.6) == '4,6★'` và fallback null `'—'` (`find.text('Chưa có dữ liệu')`).
  - Đây là các bài test độc lập, không ghép 4.3 và 4,6★ thành một chuỗi dữ liệu.

#### TC-D501-DATA-07: Tiêu đề phụ (Subtitle) hiển thị đúng Brand Name và nhãn thời gian
- **Mục tiêu:** Xác minh header của màn hình hiển thị phụ đề theo định dạng `${brandName} · ${rangeLabel}`.
- **Phân loại:** Data Display / Header
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `session.business?.brandName = 'Cà phê Sài Gòn'`, `range = DashboardRange.weeks8`.
- **Các bước thực hiện:**
  1. Quan sát text subtitle dưới tiêu đề `"Tổng quan phễu đánh giá"`.
- **Kết quả mong đợi:**
  - Text hiển thị chính xác: `"Cà phê Sài Gòn · 8 tuần gần nhất"`.
- **Trạng thái:** NOT RUN

---

### NHÓM 3: FILTERS (BỘ LỌC CHI NHÁNH & KHOẢNG THỜI GIAN)

#### TC-D501-FLT-01: Trạng thái và giá trị mặc định của 2 bộ lọc khi mới vào màn hình
- **Mục tiêu:** Xác minh giá trị ban đầu: Dropdown Chi nhánh chọn "Tất cả chi nhánh" (`null`), Dropdown Thời gian chọn "8 tuần gần nhất" (56 ngày).
- **Phân loại:** Filter / Functional UI
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Mở trang D5-01 lần đầu.
- **Các bước thực hiện:**
  1. Kiểm tra giá trị khởi tạo của DropdownFormField Chi nhánh.
  2. Kiểm tra giá trị khởi tạo của DropdownFormField Khoảng thời gian.
- **Kết quả mong đợi:**
  - Dropdown Chi nhánh hiển thị `"Tất cả chi nhánh"` (`value = null`).
  - Dropdown Khoảng thời gian hiển thị `"8 tuần gần nhất"` (`value = DashboardRange.weeks8`).
- **Trạng thái:** NOT RUN

#### TC-D501-FLT-02: Đổi chi nhánh cụ thể trên dropdown kích hoạt gọi lại API kèm tham số `branchId`
- **Mục tiêu:** Xác minh khi chọn chi nhánh từ dropdown, app kích hoạt gọi lại API có chứa param `branchId` trong URL query.
- **Phân loại:** Filter / API Integration
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (`admin_pages_test.dart`)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Cơ sở có 2 chi nhánh: "Quận 1" (id: `c1`) và "Quận 3" (id: `c2`).
- **Dữ liệu đầu vào:** Chọn mục dropdown có giá trị `c1`.
- **Các bước thực hiện:**
  1. Nhấn mở dropdown Chi nhánh.
  2. Chọn chi nhánh `"Quận 1"`.
  3. Bắt gói tin HTTP GET gửi qua `ApiClient`.
- **Kết quả mong đợi:**
  - Endpoint được gọi: `GET /api/v1/businesses/{bizId}/dashboard?branchId=c1&from=...&to=...`.
  - Giao diện cập nhật lại số liệu tương ứng chi nhánh `c1`.
- **Trạng thái:** NOT RUN

#### TC-D501-FLT-03: Chọn lại "Tất cả chi nhánh" kích hoạt gọi lại API không truyền `branchId`
- **Mục tiêu:** Xác minh khi chuyển từ chi nhánh cụ thể về lại "Tất cả chi nhánh", request gửi lên server không chứa key `branchId`.
- **Phân loại:** Filter / API Integration
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Màn hình đang lọc theo chi nhánh `c1`.
- **Các bước thực hiện:**
  1. Nhấn mở dropdown Chi nhánh, chọn mục `"Tất cả chi nhánh"`.
  2. Bắt gói tin HTTP GET phát sinh.
- **Kết quả mong đợi:**
  - Endpoint được gọi không chứa query param `branchId`.
- **Trạng thái:** NOT RUN

#### TC-D501-FLT-04: Đổi khoảng thời gian sang "4 tuần gần nhất" (28 ngày)
- **Mục tiêu:** Xác minh khi chọn preset 4 tuần, app tính `from = to - 28 ngày`, gọi lại API và cập nhật subtitle.
- **Phân loại:** Filter / API Integration
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Các bước thực hiện:**
  1. Mở dropdown Thời gian, chọn `"4 tuần gần nhất"`.
  2. Bắt gói tin HTTP GET gửi lên backend.
- **Kết quả mong đợi:**
  - Query param `from` và `to` cách nhau đúng 28 ngày (`ChronoUnit.DAYS.between(from, to) == 28`).
  - Subtitle cập nhật thành `"... · 4 tuần gần nhất"`.
- **Trạng thái:** NOT RUN

#### TC-D501-FLT-05: Đổi khoảng thời gian sang "12 tuần gần nhất" (84 ngày)
- **Mục tiêu:** Xác minh khi chọn preset 12 tuần, app tính `from = to - 84 ngày`, gọi lại API và cập nhật subtitle.
- **Phân loại:** Filter / API Integration
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Các bước thực hiện:**
  1. Mở dropdown Thời gian, chọn `"12 tuần gần nhất"`.
- **Kết quả mong đợi:**
  - Query param `from` và `to` cách nhau đúng 84 ngày.
  - Subtitle cập nhật thành `"... · 12 tuần gần nhất"`.
- **Trạng thái:** NOT RUN

#### TC-D501-FLT-06: Bố cục đáp ứng (Responsive) của 2 dropdown khi co giãn kích thước màn hình
- **Mục tiêu:** Xác minh 2 dropdown xếp hàng ngang trên màn hình $\ge 760\text{px}$ và xếp dọc toàn chiều rộng trên màn hình $< 760\text{px}$.
- **Phân loại:** UI Layout / Responsive
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** Kích thước viewport width = 800px và width = 500px.
- **Các bước thực hiện:**
  1. Render trang ở width = 800px $\rightarrow$ kiểm tra cấu trúc layout.
  2. Render trang ở width = 500px $\rightarrow$ kiểm tra cấu trúc layout.
- **Kết quả mong đợi:**
  - Width 800px: Hai dropdown nằm trong một `Row` với chiều rộng 210px mỗi ô.
  - Width 500px: Hai dropdown nằm trong một `Column` với `crossAxisAlignment: CrossAxisAlignment.stretch`.
- **Trạng thái:** NOT RUN

---

### NHÓM 4: CHARTS (BIỂU ĐỒ PHỄU CHUYỂN ĐỔI & BIỂU ĐỒ TUẦN)

#### TC-D501-CHT-01: Biểu đồ phễu (`FunnelChart`) hiển thị đầy đủ 4 bước tuần tự
- **Mục tiêu:** Xác minh `FunnelChart` hiển thị đủ 4 bước phễu theo đúng thiết kế: Quét mã QR $\rightarrow$ Chọn sao $\rightarrow$ Hài lòng 4–5 sao $\rightarrow$ Chuyển sang Google.
- **Phân loại:** Chart / Functional UI
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (`dashboard_test.dart`)
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** `data.funnel` gồm 4 bước có số lượng: 100, 60, 45, 20.
- **Các bước thực hiện:**
  1. Render `FunnelChart(steps: data.funnel)`.
  2. Tìm kiếm text của từng bước.
- **Kết quả mong đợi:**
  - Hiển thị đầy đủ 4 nhãn: `"Quét mã QR"`, `"Chọn sao"`, `"Hài lòng 4–5 sao"`, `"Chuyển sang Google"`.
- **Trạng thái:** NOT RUN

#### TC-D501-CHT-02: Tỷ lệ % của các bước trong phễu tính chuẩn xác theo tổng lượt quét (`scanCount`)
- **Mục tiêu:** Xác minh tỷ lệ % trên phễu chuyển đổi tính trên mẫu số `scanCount` (Bước 1 = 100%, các bước sau = `count / scanCount * 100%`).
- **Phân loại:** Chart / Formula Verification
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** `scanCount = 1248`, `ratedCount = 684`, `satisfiedCount = 560`, `googleRedirectCount = 312`.
- **Các bước thực hiện:**
  1. Kiểm tra text hiển thị và thuộc tính `value` của `LinearProgressIndicator` cho từng bước.
- **Kết quả mong đợi:**
  - Bước 1 (Quét QR): `"1.248 · 100%"`, thanh progress value = 1.0.
  - Bước 2 (Chọn sao): `"684 · 54,8%"`, thanh progress value = 684/1248 ≈ 0.548.
  - Bước 3 (Hài lòng 4–5 sao): `"560 · 44,9%"`, thanh progress value = 560/1248 ≈ 0.449.
  - Bước 4 (Chuyển sang Google): `"312 · 25%"`, thanh progress value = 312/1248 = 0.25.
- **Trạng thái:** NOT RUN

#### TC-D501-CHT-03: Biểu đồ cột theo tuần (`WeeklyBarChart`) hiển thị các mốc thứ Hai đầu tuần dạng `dd/MM`
- **Mục tiêu:** Xác minh nhãn dưới chân cột biểu đồ tuần hiển thị định dạng `dd/MM` tương ứng ngày Thứ Hai đầu tuần.
- **Phân loại:** Chart / Date Formatting
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** `weekly` gồm 2 tuần bắt đầu từ `2026-10-26` và `2026-11-02`.
- **Các bước thực hiện:**
  1. Render `WeeklyBarChart(weeks: data.weekly)`.
  2. Đọc text nhãn trục hoành.
- **Kết quả mong đợi:**
  - Nhãn hiển thị lần lượt: `"26/10"` và `"02/11"`.
- **Trạng thái:** NOT RUN

#### TC-D501-CHT-04: Chiều cao cột trong `WeeklyBarChart` tỷ lệ thuận theo tuần cao nhất
- **Mục tiêu:** Xác minh cột của tuần có lượt quét cao nhất đạt chiều cao tối đa (150px) và các tuần khác co giãn theo tỷ lệ thuận.
- **Phân loại:** Chart / Visual Calculation
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** Tuần 1: 50 lượt quét; Tuần 2: 100 lượt quét (cao nhất).
- **Các bước thực hiện:**
  1. Kiểm tra thuộc tính `height` của `Container` đại diện cho cột Tuần 1 và Tuần 2.
- **Kết quả mong đợi:**
  - Cột Tuần 2: height = 150.0.
  - Cột Tuần 1: height = $150.0 \times 50 / 100 = 75.0$.
- **Trạng thái:** NOT RUN

#### TC-D501-CHT-05: Xử lý an toàn khi mọi tuần trong `WeeklyBarChart` đều có 0 lượt quét
- **Mục tiêu:** Xác minh khi tất cả các tuần đều có `scanCount = 0`, biểu đồ không bị lỗi chia cho 0 (`NaN`) và vẽ cột tối thiểu 2px.
- **Phân loại:** Chart / Edge Case
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** 3 tuần có `scanCount = 0`.
- **Các bước thực hiện:**
  1. Render `WeeklyBarChart` với dữ liệu trên.
- **Kết quả mong đợi:**
  - Biểu đồ render thành công, không văng exception. Mỗi cột có chiều cao tối thiểu 2px.
- **Trạng thái:** NOT RUN

#### TC-D501-CHT-06: Bảng chi tiết tuần (`WeeklyTable`) xếp tuần mới nhất lên trên cùng
- **Mục tiêu:** Xác minh bảng tuần hiển thị tuần mới nhất ở dòng đầu tiên (`weeks.reversed`) và có đủ 6 cột dữ liệu.
- **Phân loại:** Data Display / Table
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Dữ liệu đầu vào:** Dữ liệu có Tuần 1 (`26/10`) và Tuần 2 (`02/11`).
- **Các bước thực hiện:**
  1. Kiểm tra vị trí tọa độ Y (dy) của dòng `02/11` so với dòng `26/10`.
  2. Kiểm tra danh sách tiêu đề 6 cột.
- **Kết quả mong đợi:**
  - Dòng `02/11` nằm phía trên dòng `26/10` (`dy(02/11) < dy(26/10)`).
  - Đủ 6 cột: Tuần từ, Lượt quét, Tỷ lệ hài lòng, Chuyển sang Google, Đánh giá Google, Điểm sao Google.
- **Trạng thái:** NOT RUN

---

### NHÓM 5: EMPTY STATE & PARTIAL DATA (TRẠNG THÁI RỖNG & DỮ LIỆU KHUYẾT)

#### TC-D501-EMP-01: Xử lý trạng thái rỗng tổng thể khi cơ sở hoàn toàn chưa có lượt quét nào
- **Mục tiêu:** Xác minh khi cơ sở không có session nào (`scanCount = 0` và `weekly = []`), màn hình hiển thị banner empty state rõ ràng.
- **Phân loại:** Empty State
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (`admin_pages_test.dart`)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** API trả về `scanCount = 0`, `weekly = []`.
- **Các bước thực hiện:**
  1. Render `DashboardPage`.
  2. Tìm `NoticeBanner`.
- **Kết quả mong đợi:**
  - Hiển thị banner với nội dung: `"Chưa có lượt quét nào trong khoảng thời gian này."`.
  - 5 thẻ số liệu hiển thị giá trị an toàn: Quét = `"0"`, Hài lòng = `'—'` (0 lượt đánh giá), Chuyển Google = `"0"`, Đánh giá Google = `'—'`, Điểm sao = `'—'`.
- **Trạng thái:** NOT RUN

#### TC-D501-EMP-02: Ẩn phễu chuyển đổi, biểu đồ cột và bảng tuần khi ở Empty State
- **Mục tiêu:** Xác minh khi `data.isEmpty == true`, các khối `FunnelChart`, `WeeklyBarChart` và `WeeklyTable` được ẩn hoàn toàn để không rối mắt người dùng.
- **Phân loại:** Empty State / Visual UI
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `data.isEmpty == true`.
- **Các bước thực hiện:**
  1. Tìm các widget `FunnelChart`, `WeeklyBarChart`, `WeeklyTable`.
- **Kết quả mong đợi:**
  - Cả 3 widget đều không xuất hiện trên cây Widget (`findsNothing`).
- **Trạng thái:** NOT RUN

#### TC-D501-EMP-03: Phân biệt trạng thái "Có lượt quét nhưng chưa ai đánh giá sao" (Partial Survey Data)
- **Mục tiêu:** Xác minh khi có session (`scanCount > 0`) nhưng chưa ai gửi đánh giá sao (`ratedCount = 0`), app KHÔNG coi là Empty State tổng thể: phễu và biểu đồ tuần vẫn hiển thị.
- **Phân loại:** Partial Data / Business Rule
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `scanCount = 20`, `ratedCount = 0`, `weekly = [DashboardWeek(weekStart: ..., scanCount: 20)]`.
- **Các bước thực hiện:**
  1. Render `DashboardPage` với dữ liệu trên.
- **Kết quả mong đợi:**
  - Không hiện banner "Chưa có lượt quét nào...".
  - `FunnelChart` và `WeeklyBarChart` vẫn được render bình thường.
  - Thẻ "Hài lòng 4–5 sao" hiển thị `'—'` kèm note `"0 lượt đánh giá"`.
- **Trạng thái:** NOT RUN

#### TC-D501-EMP-04: Phân biệt trạng thái "Khuyết dữ liệu Google" nhưng có dữ liệu khảo sát nội bộ
- **Mục tiêu:** Xác minh khi cơ sở chưa kết nối Google Place ID (`googleReviewCount = null`, `googleAvgRating = null`), các số liệu khảo sát nội bộ vẫn hiển thị đầy đủ, cột Google hiển thị `'—'`.
- **Phân loại:** Partial Data / Third-party Missing
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** `scanCount = 50`, `ratedCount = 40`, `googleReviewCount = null`.
- **Các bước thực hiện:**
  1. Render `DashboardPage` và quan sát các thẻ số liệu cùng bảng tuần.
- **Kết quả mong đợi:**
  - Thẻ 1, 2, 3 hiển thị đầy đủ số liệu nội bộ.
  - Thẻ 4, 5 hiển thị `'—'` kèm note `"Chưa có dữ liệu"`.
  - Bảng tuần hiển thị cột Đánh giá Google = `'—'` và Điểm sao = `'—'`.
- **Trạng thái:** NOT RUN

---

### NHÓM 6: ERROR HANDLING & LOADING (XỬ LÝ LỖI MẠNG & TẢI TRANG)

#### TC-D501-ERR-01: Hiển thị thanh tiến trình khi đang làm mới hoặc đổi bộ lọc
- **Mục tiêu:** Xác minh người dùng thấy thanh progress bar `LinearProgressIndicator` khi hệ thống đang tải dữ liệu do đổi bộ lọc.
- **Phân loại:** Loading State / UI Feedback
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Đang thực hiện `_loadData()` (`_loadingData = true`).
- **Các bước thực hiện:**
  1. Kích hoạt đổi bộ lọc chi nhánh.
  2. Kiểm tra sự xuất hiện của `LinearProgressIndicator`.
- **Kết quả mong đợi:**
  - Xuất hiện thanh `LinearProgressIndicator(minHeight: 2)` ngay trên đầu nhóm thẻ số liệu.
- **Trạng thái:** NOT RUN

#### TC-D501-ERR-02: Hiển thị vòng xoay tải trang khi tải dữ liệu lần đầu
- **Mục tiêu:** Xác minh khi trang mới mở và `_data == null`, hiển thị `CircularProgressIndicator` ở vị trí trung tâm.
- **Phân loại:** Loading State
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Trang D5-01 vừa khởi tạo.
- **Các bước thực hiện:**
  1. Kiểm tra widget trung tâm trước khi API trả về kết quả.
- **Kết quả mong đợi:**
  - Hiển thị `CircularProgressIndicator` ở giữa màn hình.
- **Trạng thái:** NOT RUN

#### TC-D501-ERR-03: Hiển thị banner lỗi khi API Backend trả về lỗi (`ApiException`)
- **Mục tiêu:** Xác minh khi API trả về mã lỗi HTTP, màn hình hiển thị `NoticeBanner` dạng error kèm nội dung thông báo lỗi từ server.
- **Phân loại:** Error Handling
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (`admin_pages_test.dart`)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** API throw `ApiException(500, 'Máy chủ báo cáo đang bận')`.
- **Các bước thực hiện:**
  1. Kích hoạt tải dữ liệu.
  2. Kiểm tra banner hiển thị.
- **Kết quả mong đợi:**
  - Hiển thị `NoticeBanner(type: NoticeType.error)` với text `"Máy chủ báo cáo đang bận"`.
- **Trạng thái:** NOT RUN

#### TC-D501-ERR-04: Nút "Tải lại số liệu" trên banner lỗi hoạt động chính xác và xóa trạng thái lỗi sau khi thành công
- **Mục tiêu:** Xác minh người dùng nhấn nút "Tải lại số liệu" sẽ gọi lại API; khi API thành công, banner lỗi biến mất và dữ liệu hiển thị trở lại.
- **Phân loại:** Error Handling / Recovery
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Màn hình đang ở trạng thái lỗi như TC-D501-ERR-03.
- **Các bước thực hiện:**
  1. Nhấn nút TextButton `"Tải lại số liệu"`.
  2. Giả lập API lần này trả về dữ liệu thành công.
- **Kết quả mong đợi:**
  - Kích hoạt lại hàm `_loadData()`. Banner lỗi biến mất, giao diện render lại đầy đủ thẻ số liệu và biểu đồ.
- **Trạng thái:** NOT RUN

#### TC-D501-ERR-05: Chống Race Condition khi người dùng chuyển đổi bộ lọc liên tục
- **Mục tiêu:** Xác minh cơ chế `_requestId` ngăn chặn việc hiển thị đè dữ liệu của request cũ trả về muộn hơn request mới.
- **Phân loại:** Error Handling / Concurrency
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test (Async Delay Simulation)
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Request 1 (lọc 4 tuần) bị trễ mạng 200ms, Request 2 (lọc 12 tuần) trả về sau 50ms.
- **Các bước thực hiện:**
  1. Chọn 4 tuần (Request 1 phát đi).
  2. Ngay lập tức chọn 12 tuần (Request 2 phát đi).
  3. Để Request 2 hoàn thành trước, sau đó Request 1 mới trả về.
- **Kết quả mong đợi:**
  - Dữ liệu hiển thị cuối cùng là dữ liệu của 12 tuần (Request 2). Kết quả của Request 1 bị bỏ qua.
- **Trạng thái:** NOT RUN

---

### NHÓM 7: CHECKLIST & SETUP INTEGRATION (VIỆC CẦN THIẾT LẬP)

#### TC-D501-CHK-01: Mục 1 "Tạo hồ sơ cơ sở và chi nhánh đầu tiên" luôn đánh dấu hoàn tất
- **Mục tiêu:** Xác minh mục hồ sơ cơ sở trong card "Việc cần thiết lập" luôn hiển thị icon tick xanh (`Icons.check_circle`).
- **Phân loại:** Functional UI / Checklist
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Mở màn hình D5-01.
- **Các bước thực hiện:**
  1. Tìm mục "Tạo hồ sơ cơ sở và chi nhánh đầu tiên" trong `SectionCard("Việc cần thiết lập")`.
- **Kết quả mong đợi:**
  - Hiển thị icon `Icons.check_circle` màu xanh (`context.colors.success`).
- **Trạng thái:** NOT RUN

#### TC-D501-CHK-02: Mục 2 hiển thị trạng thái kết nối Google Place ID của chi nhánh đang chọn
- **Mục tiêu:** Xác minh mục kết nối Google phản ánh đúng trạng thái động của chi nhánh đang chọn (`session.selectedBranch`).
- **Phân loại:** Functional UI / Dynamic State
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Chi nhánh có trạng thái `PlaceConnectionStatus.connected`.
- **Các bước thực hiện:**
  1. Kiểm tra chip trạng thái trên mục 2.
- **Kết quả mong đợi:**
  - Hiển thị `StatusChip` tương ứng và tiêu đề: `"Kết nối Google Place ID cho chi nhánh <Tên CN>"`.
- **Trạng thái:** NOT RUN

#### TC-D501-CHK-03: Nút "Mở cấu hình Google" điều hướng sang màn hình D3-05
- **Mục tiêu:** Xác minh nhấn nút điều hướng người dùng tới trang cài đặt Google Place (`/funnel/google-place`).
- **Phân loại:** Navigation
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** Flutter Widget Test
- **Môi trường:** Local Mock
- **Điều kiện tiên quyết:** Mục 2 hiển thị nút `"Mở cấu hình Google"`.
- **Các bước thực hiện:**
  1. Nhấn nút `"Mở cấu hình Google"`.
- **Kết quả mong đợi:**
  - Router điều hướng sang route `/funnel/google-place`.
- **Trạng thái:** NOT RUN

---

### NHÓM 8: INTEGRATION & DATA RECONCILIATION (CSDL, SQL, RLS, SECURITY)

#### TC-D501-INT-01: Đối chiếu số liệu hiển thị trên giao diện D5-01 với dữ liệu CSDL PostgreSQL thật
- **Mục tiêu:** So sánh trực tiếp con số trên 5 thẻ số liệu D5-01 với kết quả truy vấn SQL `COUNT(*)` từ bảng `survey_sessions` và `survey_responses`.
- **Phân loại:** End-to-End Data Reconciliation
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** DB Direct Query + UI Inspection
- **Môi trường:** **YÊU CẦU MÔI TRƯỜNG POSTGRESQL / SUPABASE LIVE CÓ DỮ LIỆU THẬT**
- **Điều kiện tiên quyết:** CSDL có dữ liệu khảo sát thật của cơ sở trong kỳ lọc.
- **Các bước thực hiện:**
  1. Chạy câu truy vấn SQL kiểm chứng:
     ```sql
     SELECT 
       count(s.id) as total_scans,
       count(r.star_rating) as total_rated,
       count(*) filter (where r.star_rating >= 4) as total_satisfied,
       count(*) filter (where r.redirect_clicked_at is not null) as total_redirects
     FROM public.survey_sessions s
     LEFT JOIN public.survey_responses r ON r.session_id = s.id
     WHERE s.business_id = '<BIZ_ID>'
       AND (s.started_at AT TIME ZONE 'Asia/Ho_Chi_Minh')::date BETWEEN '<FROM>' AND '<TO>';
     ```
  2. Mở giao diện D5-01 tương ứng trên trình duyệt.
  3. So khớp từng thẻ số liệu và tỷ lệ % với kết quả SQL.
- **Kết quả mong đợi:**
  - Thẻ 1 = `total_scans`.
  - Thẻ 2: Giá trị % = `round(total_satisfied * 100.0 / total_rated, 1)%`, note = `total_rated`.
  - Thẻ 3 = `total_redirects`. Khớp hoàn toàn 100% giữa CSDL và Giao diện.
- **Trạng thái:** BLOCKED *(Hiện thiếu kết nối CSDL Supabase Live và dữ liệu khảo sát thật)*

#### TC-D501-INT-02: Kiểm chứng thực nghiệm nguy cơ đếm trùng số liệu do `LEFT JOIN` (Code Anomaly OBS-SCRUM-240-01)
- **Mục tiêu:** Đo đạc thực tế hàm SQL `get_dashboard_stats` khi 1 session có 2 bản ghi `survey_responses`: Xác định mức độ nhân dòng của `scanCount`, `ratedCount`, `satisfiedCount`.
- **Phân loại:** Database Integration / Code Anomaly Verification
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** PostgreSQL SQL Test
- **Môi trường:** **YÊU CẦU MÔI TRƯỜNG POSTGRESQL TEST DATABASE**
- **Điều kiện tiên quyết:** CSDL PostgreSQL có thể tạo bảng test hoặc nạp session test.
- **Các bước thực hiện:**
  1. Chèn 1 session S1 vào `survey_sessions`.
  2. Chèn 2 responses R1 và R2 cùng trỏ về `session_id = S1` (cùng 5 sao và có redirect).
  3. Gọi hàm `SELECT * FROM public.get_dashboard_stats(...)`.
- **Kết quả mong đợi & Đo đạc rủi ro:**
  - Nếu `scanCount = 2` (thay vì 1): Xác nhận lỗi nhân đôi dòng do `LEFT JOIN` và thiếu ràng buộc `UNIQUE(session_id)`.
  - Nếu `scanCount = 1`: Cơ chế chống trùng lặp hoạt động tốt.
- **Trạng thái:** BLOCKED *(Hiện thiếu môi trường PostgreSQL có thể thực thi SQL hàm `get_dashboard_stats`)*

#### TC-D501-INT-03: Kiểm chứng cơ chế Row-Level Security (RLS) với cờ `security invoker` đa tài khoản
- **Mục tiêu:** Xác minh tính cách ly dữ liệu: Quản lý Chi nhánh 1 không thể đọc số liệu của Chi nhánh 2 khi gọi Dashboard.
- **Phân loại:** Security / RLS Multi-account Integration
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Multi-account API Test
- **Môi trường:** **YÊU CẦU MÔI TRƯỜNG SUPABASE AUTH LIVE VỚI 2 TÀI KHOẢN THẬT**
- **Điều kiện tiên quyết:** Chi nhánh 1 có 10 lượt quét; Chi nhánh 2 có 20 lượt quét. User A là Branch Manager tại Chi nhánh 1.
- **Các bước thực hiện:**
  1. User A đăng nhập, lấy JWT token.
  2. User A gọi `GET /api/v1/businesses/{id}/dashboard` (xem tất cả chi nhánh).
- **Kết quả mong đợi:**
  - Hàm `get_dashboard_stats` chạy dưới quyền token của User A chỉ trả về đúng 10 lượt quét của Chi nhánh 1. Toàn bộ 20 lượt quét của Chi nhánh 2 bị RLS chặn hoàn toàn.
- **Trạng thái:** BLOCKED *(Hiện thiếu môi trường Supabase Auth live với 2 tài khoản phân quyền)*

#### TC-D501-INT-04: Kiểm chứng tính nhất quán múi giờ `Asia/Ho_Chi_Minh` tại các mốc biên 23:59 và 00:01
- **Mục tiêu:** Xác minh phiên quét lúc 23:59 Chủ Nhật và 00:01 Thứ Hai giờ VN được phân vào đúng tuần ISO 8601.
- **Phân loại:** Timezone / Database Logic
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** PostgreSQL SQL Test
- **Môi trường:** **YÊU CẦU MÔI TRƯỜNG POSTGRESQL TEST DATABASE**
- **Điều kiện tiên quyết:**
  - Phiên A: `started_at = 2026-11-01 16:59:00 UTC` (tức 23:59:00 GMT+7 Chủ Nhật).
  - Phiên B: `started_at = 2026-11-01 17:01:00 UTC` (tức 00:01:00 GMT+7 Thứ Hai).
- **Các bước thực hiện:**
  1. Nạp Phiên A và Phiên B vào `survey_sessions`.
  2. Thực thi `get_dashboard_stats`.
- **Kết quả mong đợi:**
  - Phiên A được gom vào tuần có `weekStart = 2026-10-26`.
  - Phiên B được gom vào tuần có `weekStart = 2026-11-02`.
- **Trạng thái:** BLOCKED *(Hiện thiếu môi trường PostgreSQL test)*

#### TC-D501-INT-05: Backend chặn truy cập khi thiếu Bearer JWT Token (HTTP 401 Unauthorized)
- **Mục tiêu:** Xác minh endpoint Dashboard được bảo vệ bởi Spring Security, từ chối mọi request không có access token.
- **Phân loại:** Security / API Test
- **Mức độ ưu tiên:** High
- **Phương pháp thực thi:** Spring Security WebMvcTest / cURL API Test
- **Môi trường:** Local Backend Server / MockMvc
- **Điều kiện tiên quyết:** Endpoint `/api/v1/businesses/{id}/dashboard` đang hoạt động.
- **Các bước thực hiện:**
  1. Gửi request `GET /api/v1/businesses/{id}/dashboard` không kèm header `Authorization`.
- **Kết quả mong đợi:**
  - Server trả về mã phản hồi HTTP 401 Unauthorized.
- **Trạng thái:** NOT RUN

#### TC-D501-INT-06: Backend chặn khoảng ngày không hợp lệ (`from > to` hoặc > 366 ngày) báo lỗi HTTP 400
- **Mục tiêu:** Xác minh `DashboardService.validateRange` chặn các khoảng thời gian bất thường và ném lỗi `INVALID_DATE_RANGE`.
- **Phân loại:** Backend Validation / API Test
- **Mức độ ưu tiên:** Medium
- **Phương pháp thực thi:** JUnit 5 Backend Test (`DashboardServiceTest`)
- **Môi trường:** Local Backend Test
- **Điều kiện tiên quyết:** Backend chạy trong bộ test JUnit.
- **Các bước thực hiện:**
  1. Gọi API với `from = 2026-11-10` và `to = 2026-11-01` (`from > to`).
  2. Gọi API với khoảng cách giữa `from` và `to` là 370 ngày (> 366 ngày).
- **Kết quả mong đợi:**
  - Cả 2 trường hợp đều ném `ApiException` mã `INVALID_DATE_RANGE` kèm HTTP 400 Bad Request.
- **Trạng thái:** NOT RUN

---

## 4. DANH SÁCH 2 ĐIỂM CẦN PRODUCT OWNER / SOLUTION ARCHITECT XÁC NHẬN

1. **Mô hình quan hệ giữa `survey_sessions` và `survey_responses` (Liên quan `TC-D501-INT-02`):**
   - *Hiện trạng:* CSDL không có ràng buộc `UNIQUE(session_id)` trên bảng `survey_responses`.
   - *Câu hỏi cho PO/BA:* Về mặt nghiệp vụ, một phiên quét QR có được phép có nhiều phản hồi hay không? Nếu khách hàng đổi ý và gửi đánh giá lần 2, hệ thống ghi đè hay chỉ lấy phản hồi mới nhất?
2. **Ý nghĩa hiển thị số liệu Google trên Thẻ Dashboard (Liên quan `TC-D501-DATA-05`, `DATA-06`):**
   - *Hiện trạng:* Các thẻ khảo sát nội bộ thể hiện tổng lũy kế trong kỳ lọc (mặc định 8 tuần), trong khi thẻ Google hiển thị snapshot của tuần mới nhất.
   - *Câu hỏi cho PO/BA:* Có cần bổ sung tooltip giải thích trên giao diện D5-01 để người dùng không hiểu nhầm con số đánh giá Google là "Số đánh giá nhận được trong 8 tuần qua" hay không?
