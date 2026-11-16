# TÀI LIỆU KỊCH BẢN KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST SCRIPTS) - SCRUM-242

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Repository:** `https://github.com/Krydecres/CX-SHIELD`
- **Thư mục dự án:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT`
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Ngày hoàn thành:** 16/11/2026

---

## 1. TỔNG QUAN HẠ TẦNG VÀ CÔNG NGHỆ AUTOMATION

Hệ thống kiểm thử tự động của CX-SHIELD cho phân hệ Dashboard được triển khai trên hai tầng công nghệ:

```
+-----------------------------------------------------------------------------------------+
|                               CX-SHIELD AUTOMATION TEST STACK                           |
+-----------------------------------------------------------------------------------------+
|  BACKEND AUTOMATION (Spring Boot 4.0.0 / Java 21)                                        |
|  - Framework: JUnit 5 (Jupiter), Spring Boot Test, Spring Security Test                  |
|  - Web Testing: MockMvc, MockitoBean (Mocking tầng Service & Repository)                |
|  - Maven Wrapper: .\mvnw.cmd test                                                       |
|                                                                                         |
|  FRONTEND AUTOMATION (Flutter 3.x / Dart 3.x)                                           |
|  - Framework: flutter_test (WidgetTester, TestWidgetsFlutterBinding)                    |
|  - HTTP Mocking: package:http/testing.dart (MockClient)                                 |
|  - Router Testing: GoRouter, sessionRedirect Guards                                     |
|  - Flutter CLI: flutter test                                                            |
+-----------------------------------------------------------------------------------------+
```

---

## 2. ĐẶC TẢ TẬP DỮ LIỆU KHẢO SÁT MẪU (SYNTHETIC TEST DATA SPECIFICATION)

Để kiểm tra tính toàn vẹn của thuật toán tính toán và đối chiếu số liệu (`Data Reconciliation`), một tập dữ liệu khảo sát mẫu gồm **15 lượt quét QR** đã được thiết kế trên 3 chi nhánh của doanh nghiệp **Maison** (`businessId: biz`):

### 2.1. Phân bổ dữ liệu theo chi nhánh

| Chi nhánh | Mã | Tên | Lượt quét (`scanCount`) | Lượt đánh giá (`ratedCount`) | Hài lòng 4-5 sao (`satisfiedCount`) | Chuyển tiếp Google (`googleRedirectCount`) | Tỷ lệ hài lòng (`satisfactionRate`) | Đánh giá Google (`googleReviewCount`) | Điểm Google (`googleAvgRating`) |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Chi nhánh 1** | `c1` | Quận 1 | 10 | 8 | 5 | 4 | $5/8 = 62.5\%$ | 300 | 4.5★ |
| **Chi nhánh 2** | `c2` | Quận 3 | 5 | 5 | 5 | 3 | $5/5 = 100.0\%$ | 150 | 4.9★ |
| **Chi nhánh 3** | `c3` | Thủ Đức | 0 | 0 | 0 | 0 | `null` (chưa có) | `null` | `null` |
| **TOÀN HỆ THỐNG** | `all` | **Tất cả** | **15** | **13** | **10** | **7** | **$10/13 = 76.9\%$** | **450** | **4.7★** |

### 2.2. Chi tiết 15 lượt khảo sát mẫu

| Khảo sát ID | Chi nhánh | Sao đánh giá | Trạng thái hài lòng | Ý kiến phản hồi | Chuyển sang Google? | Tuần ghi nhận |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: |
| `SRV-01` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Không gian rất đẹp, phục vụ nhanh" | Có | Tuần 1 (26/10) |
| `SRV-02` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Cà phê ngon, view thoáng" | Có | Tuần 1 (26/10) |
| `SRV-03` | Quận 1 (`c1`) | 4 sao | Hài lòng | "Hài lòng, nhân viên nhiệt tình" | Có | Tuần 1 (26/10) |
| `SRV-04` | Quận 1 (`c1`) | 3 sao | Không hài lòng | "Máy lạnh hơi nóng, đợi nước lâu" | Không | Tuần 1 (26/10) |
| `SRV-05` | Quận 1 (`c1`) | 2 sao | Không hài lòng | "Nhạc hơi to, bàn chưa dọn" | Không | Tuần 1 (26/10) |
| `SRV-06` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Mọi thứ tuyệt vời" | Có | Tuần 2 (02/11) |
| `SRV-07` | Quận 1 (`c1`) | 4 sao | Hài lòng | "Bánh ngọt ngon" | Không | Tuần 2 (02/11) |
| `SRV-08` | Quận 1 (`c1`) | 1 sao | Không hài lòng | "Nhân viên thái độ không tốt" | Không | Tuần 2 (02/11) |
| `SRV-09` | Quận 1 (`c1`) | — (Chỉ quét) | — (Chưa rate) | Bỏ dở form | Không | Tuần 2 (02/11) |
| `SRV-10` | Quận 1 (`c1`) | — (Chỉ quét) | — (Chưa rate) | Bỏ dở form | Không | Tuần 2 (02/11) |
| `SRV-11` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Cực kỳ ưng ý dịch vụ Quận 3" | Có | Tuần 1 (26/10) |
| `SRV-12` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Quán yên tĩnh để làm việc" | Có | Tuần 1 (26/10) |
| `SRV-13` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Chất lượng ổn định" | Có | Tuần 2 (02/11) |
| `SRV-14` | Quận 3 (`c2`) | 4 sao | Hài lòng | "Nước uống ngon" | Không | Tuần 2 (02/11) |
| `SRV-15` | Quận 3 (`c2`) | 4 sao | Hài lòng | "Giá hợp lý" | Không | Tuần 2 (02/11) |

---

## 3. CHI TIẾT CÁC KỊCH BẢN AUTOMATION MỚI PHÁT TRIỂN

### 3.1. Backend Automation Script: `DashboardControllerSecurityTest.java`

- **Đường dẫn:** [DashboardControllerSecurityTest.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java)
- **Mục tiêu:** Kiểm tra tích hợp tầng Controller, xác thực bảo mật Bearer token, serialization DTO, và validation tham số.
- **Kỹ thuật áp dụng:**
  - `@SpringBootTest` + `@AutoConfigureMockMvc`
  - `@MockitoBean private DashboardService dashboardService;`
  - Spring Security Test annotations / headers.

#### Mã nguồn tóm tắt:
```java
@SpringBootTest
@AutoConfigureMockMvc
class DashboardControllerSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DashboardService dashboardService;

    private static final UUID BUSINESS_ID = UUID.fromString("00000000-0000-0000-0000-000000000001");
    private static final UUID BRANCH_ID = UUID.fromString("00000000-0000-0000-0000-000000000002");

    @Test
    void returns401WhenUnauthenticated() throws Exception {
        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void returns200WithDashboardDtoWhenAuthorized() throws Exception {
        DashboardDto dto = new DashboardDto(
                15, 13, 10, new BigDecimal("76.9"), 7, 450, new BigDecimal("4.7"),
                List.of(new DashboardWeeklyDto(LocalDate.parse("2026-10-26"), 10, new BigDecimal("75.0"), 5, 400, new BigDecimal("4.6")))
        );
        when(dashboardService.getDashboard(eq(BUSINESS_ID), isNull(), isNull(), isNull())).thenReturn(dto);

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .header(HttpHeaders.AUTHORIZATION, "Bearer mock-jwt-token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.scanCount").value(15))
                .andExpect(jsonPath("$.ratedCount").value(13))
                .andExpect(jsonPath("$.satisfiedCount").value(10))
                .andExpect(jsonPath("$.satisfactionRate").value(76.9))
                .andExpect(jsonPath("$.googleRedirectCount").value(7))
                .andExpect(jsonPath("$.googleReviewCount").value(450))
                .andExpect(jsonPath("$.googleAvgRating").value(4.7));
    }

    @Test
    void passesBranchAndDateRangeParametersToService() throws Exception {
        LocalDate from = LocalDate.parse("2026-10-01");
        LocalDate to = LocalDate.parse("2026-11-01");
        DashboardDto emptyDto = new DashboardDto(0, 0, 0, null, 0, null, null, List.of());
        when(dashboardService.getDashboard(BUSINESS_ID, BRANCH_ID, from, to)).thenReturn(emptyDto);

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .header(HttpHeaders.AUTHORIZATION, "Bearer mock-jwt-token")
                .param("branchId", BRANCH_ID.toString())
                .param("from", "2026-10-01")
                .param("to", "2026-11-01"))
                .andExpect(status().isOk());

        verify(dashboardService).getDashboard(BUSINESS_ID, BRANCH_ID, from, to);
    }
}
```

---

### 3.2. Frontend Automation Script: `dashboard_automation_reconciliation_test.dart`

- **Đường dẫn:** [dashboard_automation_reconciliation_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/dashboard_automation_reconciliation_test.dart)
- **Mục tiêu:** Kiểm thử tự động đối chiếu số liệu khảo sát mẫu trên giao diện người dùng, tỷ lệ phễu chuyển đổi, chuyển đổi bộ lọc chi nhánh và bộ lọc thời gian, kiểm tra router guards.
- **Kỹ thuật áp dụng:**
  - `flutter_test`: `testWidgets`, `WidgetTester`, `pumpAndSettle`, `find.text`, `find.byKey`.
  - HTTP `MockClient` mô phỏng đầy đủ endpoint `/dashboard` và `/google-place`.
  - Fake GoTrueClient cho `SessionController`.

#### Mã nguồn tóm tắt:
```dart
void main() {
  // Setup MockClient routing & SessionController
  // Test 1: TC-D501-REC-01: Đối chiếu số liệu hiển thị trên thẻ và phễu với tập khảo sát mẫu
  // Test 2: TC-D501-REC-02: Phễu chuyển đổi tính đúng tỷ lệ trên mẫu số lượt quét 15
  // Test 3: TC-D501-FLT-AUT-01: Lọc chi nhánh Quận 1 cập nhật số liệu và note chính xác
  // Test 4: TC-D501-FLT-AUT-02: Lọc chi nhánh Quận 3 (100% hài lòng) và quay lại Tất cả
  // Test 5: TC-D501-FLT-AUT-03: Lọc chi nhánh Thủ Đức (chưa có dữ liệu) hiển thị banner rỗng và ẩn biểu đồ
  // Test 6: TC-D501-DATE-AUT-01: Đổi khoảng thời gian 4 tuần cập nhật subtitle và query params
  // Test 7: TC-D501-DATE-AUT-02: Đổi khoảng thời gian 12 tuần cập nhật subtitle và query params
  // Test 8: TC-D501-NAV-AUT-01: Chặn vào /dashboard khi chưa đăng nhập (signedOut -> /login)
  // Test 9: TC-D501-NAV-AUT-02: Chặn vào /dashboard khi chưa hoàn tất cơ sở (onboarded=false -> /onboarding)
  // Test 10: TC-D501-NAV-AUT-03: Mở root / tự động chuyển hướng vào /dashboard khi đã onboarded
  // Test 11: TC-D501-NAV-AUT-04: Nút "Mở cấu hình Google" chuyển hướng tới /funnel/google-place
}
```

---

## 4. HƯỚNG DẪN THỰC THI KIỂM THỬ (TEST EXECUTION MANUAL)

### 4.1. Điều kiện tiên quyết (Prerequisites)
1. **Java Development Kit:** Java 21 LTS (`java -version`).
2. **Flutter SDK:** Flutter 3.x / Dart 3.x (`flutter --version`).
3. **Môi trường:** Windows PowerShell hoặc Linux Bash.

### 4.2. Lệnh thực thi Smoke Test tự động

#### Chạy Backend Smoke Test:
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'
```
*Thời gian chạy dự kiến: ~4.7 giây (6 tests passed).*

#### Chạy Frontend Smoke Test:
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/dashboard_automation_reconciliation_test.dart
```
*Thời gian chạy dự kiến: ~2.5 giây (11 tests passed).*

---

### 4.3. Lệnh thực thi Regression Test tự động toàn diện

#### Chạy Toàn bộ Backend Dashboard Regression Suite (26 tests):
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
.\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest,DashboardControllerSecurityTest'
```
*Kết quả mong đợi: `Tests run: 26, Failures: 0, Errors: 0, Skipped: 0 - BUILD SUCCESS`.*

#### Chạy Toàn bộ Frontend Dashboard Regression Suite (70 tests):
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/dashboard_test.dart test/admin_pages_test.dart test/admin_shell_pages_test.dart test/auth_onboarding_test.dart test/dashboard_automation_reconciliation_test.dart
```
*Kết quả mong đợi: `00:04 +70: All tests passed!`.*

---

## 5. CẤU HÌNH TÍCH HỢP CI/CD (GITHUB ACTIONS SNIPPET)

Để tự động kích hoạt bộ test này trên mỗi Pull Request hoặc Push vào `main`:

```yaml
name: Dashboard QA Automation Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  backend-automation:
    name: Backend Dashboard Security & Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
      - name: Run Backend Tests
        run: |
          cd backend
          ./mvnw test -Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest,DashboardControllerSecurityTest

  frontend-automation:
    name: Frontend Dashboard Reconciliation & Widget Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      - name: Install dependencies
        run: |
          cd frontend
          flutter pub get
      - name: Run Frontend Tests
        run: |
          cd frontend
          flutter test test/dashboard_test.dart test/admin_pages_test.dart test/admin_shell_pages_test.dart test/auth_onboarding_test.dart test/dashboard_automation_reconciliation_test.dart
```
