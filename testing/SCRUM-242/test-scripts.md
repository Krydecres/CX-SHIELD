# TÀI LIỆU KỊCH BẢN KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST SCRIPTS) - SCRUM-242

- **Mã Jira:** SCRUM-242
- **Tên nhiệm vụ:** [E3.1] Kiểm thử tự động dashboard tổng quan
- **Epic cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Repository:** `https://github.com/Krydecres/CX-SHIELD`
- **Thư mục dự án:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT`
- **Kỹ sư thực hiện:** Senior QA Automation Engineer
- **Ngày hoàn thành:** 16/11/2026
- **Trạng thái tài liệu:** **AUDITED & HARMONIZED WITH SOURCE CODE**

---

## 1. TỔNG QUAN HẠ TẦNG VÀ PHẠM VI KỸ THUẬT CỦA TEST SCRIPTS

```
+---------------------------------------------------------------------------------------------------------+
|                                    CX-SHIELD AUTOMATION TEST ARCHITECTURE                               |
+---------------------------------------------------------------------------------------------------------+
|  BACKEND AUTOMATION (Spring Boot 4.0.0 / Java 21)                                                       |
|  - Phạm vi thực tế: Spring Boot MockMvc Integration Test với Mocked Service và Test Security Context   |
|  - Mocking: @MockitoBean private DashboardService dashboardService;                                     |
|  - Security: Spring Security Test RequestPostProcessor (jwt().jwt(...))                                 |
|  - Giới hạn: Không xác thực cryptographic signature của JWT từ live Supabase Auth;                      |
|              Không truy vấn trực tiếp bảng database PostgreSQL thật có bật RLS.                         |
|                                                                                                         |
|  FRONTEND AUTOMATION (Flutter 3.x / Dart 3.x)                                                           |
|  - Phạm vi thực tế: Flutter Widget Test với package:http/testing.dart (MockClient)                     |
|  - Mocking: MockClient định tuyến theo URL path và query parameters (branchId)                          |
|  - Dữ liệu: Bộ mock responses mô phỏng 15 lượt quét QR và khảo sát                                      |
|  - Giới hạn: Không tạo hoặc đọc bản ghi trực tiếp từ live Supabase backend.                              |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. ĐẶC TẢ BỘ DỮ LIỆU MÔ PHỎNG KHẢO SÁT (SYNTHETIC TEST DATA SPECIFICATION)

Để phục vụ đối chiếu số liệu (`Data Reconciliation`) trên giao diện người dùng, tập dữ liệu mock trong `dashboard_automation_reconciliation_test.dart` được thiết lập mô phỏng **15 lượt quét mã QR** phân bổ trên 3 chi nhánh của doanh nghiệp **Maison** (`businessId: biz`):

### 2.1. Bảng số liệu phân bổ theo chi nhánh (Đối chiếu mã nguồn)

| Chi nhánh | Mã ID | Tên chi nhánh | Lượt quét (`scanCount`) | Đã đánh giá (`ratedCount`) | Hài lòng (`satisfiedCount`) | Chuyển Google (`googleRedirectCount`) | Tỷ lệ hài lòng (`satisfactionRate`) | Đánh giá Google (`googleReviewCount`) | Điểm Google (`googleAvgRating`) |
| :--- | :---: | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Chi nhánh 1** | `c1` | Quận 1 | 10 | 8 | 5 | 4 | $5/8 = 62.5\%$ | 300 | 4.5★ |
| **Chi nhánh 2** | `c2` | Quận 3 | 5 | 5 | 5 | 3 | $5/5 = 100.0\%$ | 150 | **5.0★** |
| **Chi nhánh 3** | `c3` | Thủ Đức | 0 | 0 | 0 | 0 | `null` (hiển thị `—`) | `null` | `null` |
| **TOÀN HỆ THỐNG** | `all` | **Tất cả** | **15** | **13** | **10** | **7** | **$10/13 = 76.9\%$** | **450** | **4.7★** |

> [!IMPORTANT]
> **Điểm hiệu chỉnh sau Audit:** Giá trị `googleAvgRating` của Chi nhánh 2 (`c2`) trong mã nguồn `sampleBranch2Data` là **5.0** (không phải 4.9). Tài liệu đã được đối chiếu và chuẩn hóa khớp 100% với giá trị thực tế trong source test.

### 2.2. Chi tiết 15 lượt khảo sát mô phỏng

| Khảo sát ID | Chi nhánh | Sao đánh giá | Trạng thái hài lòng | Ý kiến phản hồi mô phỏng | Chuyển Google? | Tuần ghi nhận |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: |
| `SRV-01` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Không gian rất đẹp, phục vụ nhanh" | Có | Tuần 1 (26/10) |
| `SRV-02` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Cà phê ngon, view thoáng" | Có | Tuần 1 (26/10) |
| `SRV-03` | Quận 1 (`c1`) | 4 sao | Hài lòng | "Hài lòng, nhân viên nhiệt tình" | Có | Tuần 1 (26/10) |
| `SRV-04` | Quận 1 (`c1`) | 3 sao | Không hài lòng | "Máy lạnh hơi nóng, đợi nước lâu" | Không | Tuần 1 (26/10) |
| `SRV-05` | Quận 1 (`c1`) | 2 sao | Không hài lòng | "Nhạc hơi to, bàn chưa dọn" | Không | Tuần 1 (26/10) |
| `SRV-06` | Quận 1 (`c1`) | 5 sao | Hài lòng | "Mọi thứ tuyệt vời" | Có | Tuần 2 (02/11) |
| `SRV-07` | Quận 1 (`c1`) | 4 sao | Hài lòng | "Bánh ngọt ngon" | Không | Tuần 2 (02/11) |
| `SRV-08` | Quận 1 (`c1`) | 1 sao | Không hài lòng | "Nhân viên thái độ không tốt" | Không | Tuần 2 (02/11) |
| `SRV-09` | Quận 1 (`c1`) | — (Chỉ quét) | — (Chưa rate) | Bỏ dở form quét mã | Không | Tuần 2 (02/11) |
| `SRV-10` | Quận 1 (`c1`) | — (Chỉ quét) | — (Chưa rate) | Bỏ dở form quét mã | Không | Tuần 2 (02/11) |
| `SRV-11` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Cực kỳ ưng ý dịch vụ Quận 3" | Có | Tuần 1 (26/10) |
| `SRV-12` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Quán yên tĩnh để làm việc" | Có | Tuần 1 (26/10) |
| `SRV-13` | Quận 3 (`c2`) | 5 sao | Hài lòng | "Chất lượng ổn định" | Có | Tuần 2 (02/11) |
| `SRV-14` | Quận 3 (`c2`) | 4 sao | Hài lòng | "Nước uống ngon" | Không | Tuần 2 (02/11) |
| `SRV-15` | Quận 3 (`c2`) | 4 sao | Hài lòng | "Giá hợp lý" | Không | Tuần 2 (02/11) |

---

## 3. CHI TIẾT CÁC KỊCH BẢN AUTOMATION MỚI PHÁT TRIỂN

### 3.1. Backend Automation Script: `DashboardControllerSecurityTest.java`

- **Đường dẫn tệp:** [DashboardControllerSecurityTest.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/test/java/com/cxshield/backend/report/DashboardControllerSecurityTest.java)
- **Framework:** Spring Boot Test, Spring Security Test, MockMvc, Mockito.
- **Bản chất kiểm thử:** Kiểm thử tích hợp tầng Web MVC và Security Filter Chain trong môi trường Spring Test context cô lập, service được mock bằng `@MockitoBean`.

#### Trích đoạn mã nguồn thực tế (khớp 100% source file):
```java
package com.cxshield.backend.report;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.report.dto.DashboardDtos.DashboardResponse;
import com.cxshield.backend.report.dto.DashboardDtos.WeeklyPoint;

@SpringBootTest
@AutoConfigureMockMvc
class DashboardControllerSecurityTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private DashboardService dashboardService;

    private static final UUID BUSINESS_ID = UUID.fromString("11111111-1111-1111-1111-111111111111");
    private static final UUID BRANCH_ID = UUID.fromString("22222222-2222-2222-2222-222222222222");
    private static final LocalDate FROM = LocalDate.of(2026, 9, 11);
    private static final LocalDate TO = LocalDate.of(2026, 11, 6);

    @Test
    @DisplayName("TC-D501-AUT-API-01: Chặn 401 khi thiếu Bearer Token")
    void unauthenticatedRequestReturns401() throws Exception {
        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("TC-D501-AUT-API-02: Trả về 200 và đầy đủ dữ liệu khi có JWT hợp lệ")
    void authenticatedRequestReturns200WithFullData() throws Exception {
        DashboardResponse mockResponse = new DashboardResponse(
            null, FROM, TO, 1248, 1000, 825, 82.5, 684, 1032, 4.6,
            List.of(new WeeklyPoint(LocalDate.of(2026, 11, 2), 1248, 82.5, 684, 1032, 4.6))
        );

        when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), isNull(), isNull(), isNull()))
            .thenReturn(mockResponse);

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.scanCount").value(1248))
            .andExpect(jsonPath("$.ratedCount").value(1000))
            .andExpect(jsonPath("$.satisfiedCount").value(825))
            .andExpect(jsonPath("$.satisfactionRate").value(82.5))
            .andExpect(jsonPath("$.googleRedirectCount").value(684))
            .andExpect(jsonPath("$.googleReviewCount").value(1032))
            .andExpect(jsonPath("$.googleAvgRating").value(4.6))
            .andExpect(jsonPath("$.weekly[0].scanCount").value(1248));
    }

    @Test
    @DisplayName("TC-D501-AUT-API-03: Truyền đúng branchId và khoảng ngày vào service")
    void authenticatedRequestWithBranchAndDateFilters() throws Exception {
        DashboardResponse mockResponse = new DashboardResponse(
            BRANCH_ID, FROM, TO, 500, 400, 320, 80.0, 200, 500, 4.5, List.of()
        );

        when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), eq(BRANCH_ID), eq(FROM), eq(TO)))
            .thenReturn(mockResponse);

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .param("branchId", BRANCH_ID.toString())
                .param("from", FROM.toString())
                .param("to", TO.toString())
                .with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.branchId").value(BRANCH_ID.toString()))
            .andExpect(jsonPath("$.scanCount").value(500))
            .andExpect(jsonPath("$.satisfactionRate").value(80.0));

        verify(dashboardService).getDashboard(any(), eq(BUSINESS_ID), eq(BRANCH_ID), eq(FROM), eq(TO));
    }

    @Test
    @DisplayName("TC-D501-AUT-API-04: Xử lý 404 khi người dùng không có quyền trên cơ sở")
    void authenticatedRequestWithoutBusinessAccessReturns404() throws Exception {
        when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), any(), any(), any()))
            .thenThrow(ApiException.notFound("BUSINESS_NOT_FOUND", "Không tìm thấy cơ sở hoặc bạn không có quyền"));

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .with(jwt().jwt(token -> token.tokenValue("unauthorized-jwt").subject("user-other"))))
            .andExpect(status().isNotFound())
            .andExpect(jsonPath("$.code").value("BUSINESS_NOT_FOUND"));
    }

    @Test
    @DisplayName("TC-D501-AUT-API-05: Xử lý 400 khi khoảng ngày đảo ngược")
    void authenticatedRequestWithReversedDateRangeReturns400() throws Exception {
        when(dashboardService.getDashboard(any(), eq(BUSINESS_ID), any(), eq(TO), eq(FROM)))
            .thenThrow(ApiException.badRequest("INVALID_DATE_RANGE", "Ngày bắt đầu phải trước ngày kết thúc"));

        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", BUSINESS_ID)
                .param("from", TO.toString())
                .param("to", FROM.toString())
                .with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.code").value("INVALID_DATE_RANGE"));
    }

    @Test
    @DisplayName("TC-D501-AUT-API-06: Chặn 400 khi businessId sai định dạng UUID")
    void authenticatedRequestWithMalformedUuidReturns400() throws Exception {
        mockMvc.perform(get("/api/v1/businesses/{businessId}/dashboard", "invalid-uuid-format")
                .with(jwt().jwt(token -> token.tokenValue("valid-jwt-token").subject("user-1"))))
            .andExpect(status().isBadRequest());
    }
}
```

---

### 3.2. Frontend Automation Script: `dashboard_automation_reconciliation_test.dart`

- **Đường dẫn tệp:** [dashboard_automation_reconciliation_test.dart](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/frontend/test/dashboard_automation_reconciliation_test.dart)
- **Framework:** `flutter_test`, `package:http/testing.dart` (`MockClient`), `go_router`.
- **Bản chất kiểm thử:** Kiểm thử giao diện Flutter (`WidgetTester`) sử dụng `MockClient` cung cấp payload JSON mô phỏng, đối chiếu các phần tử trên Widget Tree và kích hoạt router redirect.

#### Trích đoạn cấu hình MockClient định tuyến thông minh:
```dart
    final client = MockClient((request) async {
      requests.add(request);
      if (request.url.path.contains('/google-place')) {
        final segments = request.url.pathSegments;
        final bIdx = segments.indexOf('branches');
        final branchId = bIdx != -1 && bIdx + 1 < segments.length ? segments[bIdx + 1] : 'c1';
        final body = {
          'branchId': branchId,
          'branchName': 'Chi nhánh $branchId',
          'connectionStatus': 'NOT_CONNECTED',
          'googleVerificationEnabled': false,
        };
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }

      final branchId = request.url.queryParameters['branchId'];
      Map<String, dynamic>? body;
      if (branchId == 'c1') {
        body = sampleBranch1Data;
      } else if (branchId == 'c2') {
        body = sampleBranch2Data; // googleAvgRating: 5.0
      } else if (branchId == 'c3') {
        body = sampleEmptyBranchData;
      } else {
        body = responsesByQuery['all'] ?? sampleAllBranchesData;
      }
      return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
    });
```

---

## 4. HƯỚNG DẪN THỰC THI KIỂM THỬ (TEST EXECUTION MANUAL)

### 4.1. Thực thi Kịch bản Kiểm thử Mới (New Automation Tests - 17 methods)

#### Chạy 6 Backend MockMvc Tests:
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
.\mvnw.cmd test '-Dtest=DashboardControllerSecurityTest'
```
*Kết quả ghi nhận: `Tests run: 6, Failures: 0, Errors: 0, Skipped: 0` trong **4.625s**.*

#### Chạy 11 Frontend Widget Tests:
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/dashboard_automation_reconciliation_test.dart
```
*Kết quả ghi nhận: `00:02 +11: All tests passed!` trong **2.100s**.*

---

### 4.2. Thực thi Toàn bộ Kịch bản Hồi quy (Regression Suite - 96 methods)

#### Chạy Toàn bộ 26 Backend Dashboard Tests (6 mới + 20 cũ):
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
.\mvnw.cmd test '-Dtest=DashboardServiceTest,DashboardRepositoryTest,GoogleMetricsSnapshotJobTest,DashboardControllerSecurityTest'
```
*Kết quả ghi nhận: `Tests run: 26, Failures: 0, Errors: 0, Skipped: 0 - BUILD SUCCESS` trong **9.366s**.*

#### Chạy Toàn bộ 70 Frontend Dashboard Tests (11 mới + 59 cũ):
```powershell
Set-Location -Path "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/dashboard_test.dart test/admin_pages_test.dart test/admin_shell_pages_test.dart test/auth_onboarding_test.dart test/dashboard_automation_reconciliation_test.dart
```
*Kết quả ghi nhận: `00:04 +70: All tests passed!` trong **4.200s**.*

> [!NOTE]
> Tổng số bài kiểm thử tự động độc lập được thực thi trong test suite là **96 test methods**. Quá trình chạy không có bài test nào bị tính trùng lặp.
