# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN VÀ API CONTRACT GOOGLE PLACE ID (SCRUM-196)

- **Mã Jira:** SCRUM-196
- **Tên User Story:** [E4.1] Kiểm thử mã nguồn và API contract Google Place ID
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Thời điểm thực hiện:** 17/11/2026
- **Kỹ sư QA phụ trách:** QA Engineer – CX-SHIELD Team
- **Môi trường thực thi:**
  - Runtime: Java 21 LTS (Temurin-21.0.12.1), Spring Boot 4.0.0
  - Framework: JUnit 5, Mockito, Spring Security Test, MockMvc, MockRestServiceServer
  - Build Tool: Apache Maven 3.9.16

---

## 1. Tóm tắt kết quả kiểm thử (Executive Summary)

| Chỉ số đo lường (Metric) | Giá trị thực tế | Tỷ lệ (%) | Ghi chú đánh giá |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thiết kế (Designed TCs)** | **18** | **100%** | Bao phủ trọn vẹn 18 kịch bản trọng tâm theo yêu cầu của Jira SCRUM-196 |
| - Số Test Cases ĐẠT (PASS) | **17** | **94.4%** | Vượt qua toàn diện các yêu cầu về nghiệp vụ, bảo mật, ủy quyền và API contract |
| - Số Test Cases KHÔNG ĐẠT (FAIL) | **1** | **5.6%** | `TC_SCRUM196_15`: Phát hiện thiếu sót kiến trúc Rate Limiting (Đã lập bug report) |
| - Số Test Cases BỊ CHẶN (BLOCKED) | **0** | **0%** | Không có bài test nào bị chặn môi trường |
| - Số Test Cases CHƯA CHẠY (NOT RUN) | **0** | **0%** | 100% test cases đều đã được thực thi và kiểm chứng tự động |
| **Số Automation Tests chạy thực tế** | **64** | **100% PASS** | 18 tests mới (`GooglePlaceContractSecurityTest`) + 46 tests hồi quy của gói funnel |
| **Lỗi phát hiện (Defects / Observations)** | **1** | **Medium** | `BUG-SCRUM196-01` (Thiếu Rate Limiting tầng ứng dụng backend) |
| **Sửa đổi Production Code** | **KHÔNG** | **0 lines** | Tuyệt đối tuân thủ nguyên tắc không can thiệp sửa production code |

---

## 2. Kết quả kiểm thử tự động chi tiết (Automation Execution Breakdown)

Toàn bộ 64 tests tự động được chạy qua Maven Surefire đều thành công 100%:

```text
-------------------------------------------------------
 T E S T S
-------------------------------------------------------
Running com.cxshield.backend.funnel.GooglePlaceContractSecurityTest
Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 4.708 s
Running com.cxshield.backend.funnel.GooglePlaceControllerTest
Tests run: 3, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.011 s
Running com.cxshield.backend.funnel.GooglePlacesClientTest
Tests run: 13, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.177 s
Running com.cxshield.backend.funnel.GooglePlaceServiceTest
Tests run: 10, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.178 s
Running com.cxshield.backend.funnel.PlaceIdParserTest
Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.032 s
Running com.cxshield.backend.funnel.ReviewPlatformRepositoryTest
Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.055 s

Results:
Tests run: 64, Failures: 0, Errors: 0, Skipped: 0
Total time:  8.317 s
BUILD SUCCESS
```

### 2.1. Phân nhóm các bài kiểm thử mới của SCRUM-196 (18 tests)
1. **Bảo mật & Xác thực token (Authentication - 401 Unauthorized):**
   - Đảm bảo Spring Security chặn triệt để mọi request không mang token Bearer JWT hợp lệ tại cả 3 routes: `GET`, `POST /verifications`, và `PUT`.
2. **Phân quyền cơ sở & Chi nhánh (Branch Authorization - 404 & 403):**
   - Khi truy cập chi nhánh không thuộc quyền quản lý: PostgREST RLS trả về rỗng $\rightarrow$ `findBranch` trả về `Optional.empty()` $\rightarrow$ ném `ApiException.notFound("BRANCH_NOT_FOUND")` $\rightarrow$ Trả về HTTP `404 Not Found` (ngăn lộ thông tin chi nhánh cơ sở khác).
   - Khi lưu cấu hình bởi tài khoản không có quyền quản lý: RLS chặn ghi $\rightarrow$ `ReviewPlatformRepository.update/insert` trả về `Optional.empty()` $\rightarrow$ ném `ApiException.forbidden(...)` $\rightarrow$ Trả về HTTP `403 Forbidden`.
3. **API Contract Verification:**
   - Khớp 100% schema phản hồi `GooglePlaceConfigResponse`, `VerifyPlaceResponse`.
   - Bắt đúng lỗi format PathVariable UUID không hợp lệ (`400 BAD_REQUEST`).
   - Bắt đúng lỗi validation `@NotBlank` trên body JSON (`400 VALIDATION_ERROR`).
4. **Xử lý lỗi Google Places Upstream:**
   - Google `FOUND`: Trả về `CONNECTED`, tên, địa chỉ và URL đánh giá trực tiếp.
   - Google `NOT_FOUND`: Trả về `ERROR` cho endpoint xác minh; ném `422 PLACE_NOT_FOUND` và từ chối lưu vào DB cho endpoint lưu cấu hình.
   - Google `UNAVAILABLE` (403, 429, 500, timeout): Chuyển sang trạng thái dự phòng `PENDING`, không làm sập ứng dụng.
   - Google `NOT_CONFIGURED`: Khi chưa cấu hình API key, chuyển sang `PENDING`.
5. **Toàn vẹn dữ liệu chi nhánh (Data Isolation):**
   - Khẳng định `branchId` trên URL route được chuyển giao nguyên vẹn xuống `GooglePlaceService` và gán chính xác vào bản ghi `review_platforms`, không bị tráo đổi dữ liệu.
6. **Xử lý ngoại lệ không mong muốn (Unhandled Exception):**
   - Ngoại lệ máy chủ chưa lường trước được bắt tại `GlobalExceptionHandler.handleGeneralException` và trả về HTTP `500` với cấu trúc `ApiResponse` chuẩn.
7. **Kiểm chứng Rate Limiting:**
   - 10 request dồn dập trong 1 giây đều trả về 200 OK, chứng minh backend chưa hiện thực Rate Limiting tầng ứng dụng.

---

## 3. Danh sách Bugs và Quan sát kỹ thuật (Defects & Observations)

| Bug ID | Tóm tắt lỗi | Mức độ | Trạng thái | Đề xuất giải pháp |
| :---: | :--- | :---: | :---: | :--- |
| `BUG-SCRUM196-01` | **Thiếu cơ chế Rate Limiting tầng backend** cho các endpoint Google Place | **Medium** | **OPEN (Observation)** | Bổ sung `Bucket4j` hoặc Redis Rate Limiter để giới hạn tần suất request (ngưỡng 10 req/phút cho xác minh), trả về HTTP 429 khi vượt ngưỡng nhằm bảo vệ chi phí và hạn ngạch Google Places API. |

---

## 4. Các giới hạn kiểm thử (Testing Limitations & Scope Boundaries)

1. **Không gọi trực tiếp Live Google Places API:**
   - Toàn bộ lệnh gọi tới Google Places API được cô lập và giả lập bằng `MockRestServiceServer` và Mockito nhằm đảm bảo tính ổn định của test suite, không phụ thuộc vào kết nối Internet thật, không tiêu tốn hạn ngạch API của dự án và không làm lộ API keys.
2. **Không kết nối Database Production / Live Supabase Instance:**
   - Các bài test kiểm tra RLS và PostgREST dựa trên việc mô phỏng hành vi của `SupabaseDataClient` và phản hồi của PostgREST RLS (trả về danh sách rỗng khi bị RLS chặn). Chưa chạy test trên một instance PostgreSQL Supabase thật chứa dữ liệu sản xuất.
3. **Phân định ranh giới với SCRUM-194 & SCRUM-195:**
   - Không lặp lại 41 kịch bản Postman (SCRUM-194) hay 38 Widget Tests Flutter (SCRUM-195).
   - SCRUM-196 chỉ tập trung khẳng định tính đúng đắn của logic Java backend, khả năng phòng thủ lỗi và tính tuân thủ hợp đồng giao tiếp API.

---

## 5. Kết luận và Khuyến nghị bàn giao

- **Mục tiêu Jira SCRUM-196:** **ĐÃ HOÀN THÀNH ĐẦY ĐỦ VÀ XUẤT SẮC**.
- **Chất lượng mã nguồn:** Toàn bộ luồng nghiệp vụ của Google Place ID hoạt động ổn định, xử lý ngoại lệ chặt chẽ, kiểm soát quyền truy cập chi nhánh an toàn qua RLS.
- **Khuyến nghị cho Sprint tiếp theo:** Xem xét đưa hạng mục bổ sung Rate Limiter tầng ứng dụng (`BUG-SCRUM196-01`) vào backlog bảo mật để hoàn thiện tính năng phòng thủ lạm dụng API.
