# BÁO CÁO PHÁT HIỆN LỖI VÀ GHI NHẬN KIẾN TRÚC (SCRUM-196)

- **Mã Jira:** SCRUM-196
- **Tên User Story:** [E4.1] Kiểm thử mã nguồn và API contract Google Place ID
- **Thời điểm ghi nhận:** 17/11/2026
- **Môi trường:** Local Backend Spring Boot (Java 21 LTS)

---

## Danh sách lỗi và bất cập kiến trúc (Defect & Observation Summary)

| Bug ID | Tên lỗi / Vấn đề phát hiện | Phân loại | Mức độ nghiêm trọng (Severity) | Trạng thái (Status) | Thành phần bị ảnh hưởng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| `BUG-SCRUM196-01` | Thiếu cơ chế giới hạn tần suất request (Rate Limiting) trên các endpoint Google Place ID | Architecture Gap / Security | **Medium** | **OPEN (Observation)** | `GooglePlaceController` (`/api/v1/branches/{branchId}/google-place/**`) |

---

## Chi tiết lỗi BUG-SCRUM196-01

### 1. Mô tả chi tiết (Summary & Description)
Khi thực hiện kiểm thử mã nguồn và API contract cho phân hệ Google Place ID, QA kiểm tra khả năng phòng chống lạm dụng (abuse prevention) và giới hạn tần suất gọi API (Rate Limiting) tại các endpoint:
- `POST /api/v1/branches/{branchId}/google-place/verifications`
- `PUT /api/v1/branches/{branchId}/google-place`

**Hiện trạng mã nguồn:**
- Qua rà soát toàn bộ source code tầng Filter, SecurityConfig, Interceptor và Controller trong backend Spring Boot, hoàn toàn **không có bất kỳ cơ chế Rate Limiter nào** (như Bucket4j, Resilience4j, Redis Token Bucket, hoặc Servlet Filter) được cấu hình cho các route trên.
- Mọi request hợp lệ có token đều được chuyển thẳng đến `GooglePlaceService` và kích hoạt lệnh gọi outbound sang Google Places API (`https://places.googleapis.com/v1/places/{placeId}`).

### 2. Bằng chứng kiểm thử tự động (Proof of Concept / Repro Evidence)
Trong bài test tự động `GooglePlaceContractSecurityTest.rateLimitingVerificationShowsNotImplemented()`:
- Client gửi **10 request xác minh tuần tự** trong vòng lặp kiểm thử (không đo thời gian thực chính xác) tới endpoint `/api/v1/branches/{branchId}/google-place/verifications` với cùng một Bearer token.
- **Kết quả đo lường thực tế:**
  - Số request trả về HTTP 200 OK: **10/10** (100%).
  - Số request bị chặn với HTTP 429 Too Many Requests: **0/10** (0%).
  - Backend không có cơ chế làm trễ hay từ chối phục vụ khi nhận request dồn dập.

### 3. Đánh giá rủi ro và mức độ ảnh hưởng (Impact Analysis)
1. **Lãng phí chi phí & Hết hạn ngạch Google Places API:**
   Google Places API tính phí theo lượt gọi (`$17 - $20` trên 1.000 lượt tra cứu chi tiết). Khi một tài khoản người dùng hoặc bot thực hiện spam xác minh nhiều lần liên tiếp, hạn ngạch của hệ thống sẽ nhanh chóng cạn kiệt và gây phát sinh chi phí ngoài dự kiến.
2. **Nguy cơ nghẽn tài nguyên backend:**
   Gọi nhiều request HTTP outbound đồng thời tới Google mà không có pooling/rate limiting sẽ chiếm dụng connection pool của RestClient/WebClient, có thể dẫn đến nghẽn luồng xử lý của máy chủ.

### 4. Đề xuất khắc phục (Recommendation for Dev Team)
- Tích hợp thư viện Rate Limiting tầng ứng dụng (ví dụ: `Bucket4j` kết hợp Spring MVC Interceptor hoặc Caffeine Cache).
- Áp dụng cấu hình giới hạn tần suất theo người dùng hoặc theo chi nhánh: ví dụ tối đa **10 requests / phút** cho endpoint `verifications` và **5 requests / phút** cho endpoint `save`.
- Khi vượt ngưỡng, trả về mã lỗi HTTP chuẩn:
  - HTTP Status: `429 Too Many Requests`.
  - Header: `Retry-After: <seconds>`.
  - Body: `ApiErrorResponse("RATE_LIMIT_EXCEEDED", "Bạn đã thực hiện quá nhiều yêu cầu xác minh, vui lòng thử lại sau giây lát.")`.

### 5. Cam kết tuân thủ nguyên tắc QA
Tuân thủ chỉ đạo của Task SCRUM-196: *"Nếu phát hiện thiếu Rate Limiting hoặc lỗi Branch Authorization, ghi nhận bug/observation theo bằng chứng và mức độ ảnh hưởng; không tự sửa production code."* QA chỉ ghi nhận báo cáo và giữ nguyên vẹn mã nguồn production code.
