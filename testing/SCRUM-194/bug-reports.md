# BÁO CÁO PHÁT HIỆN LỖI VÀ QUAN SÁT KỸ THUẬT – SCRUM-194

- **Mã Jira:** SCRUM-194
- **Tên User Story:** [E4.1] Kiểm thử API Google Place ID bằng Postman
- **Phân hệ:** Review Funnel (Màn hình thiết lập D3-05 · Quản lý Google Place ID theo chi nhánh)
- **Ngày lập báo cáo:** 2026-11-16
- **Nguyên tắc tuân thủ:** Đây là báo cáo kiểm thử; **tuyệt đối không tự ý sửa đổi production source code**.

---

## 1. Bảng tổng hợp Lỗi và Quan sát Kỹ thuật

| Mã định danh | Phân loại | Mức độ nghiêm trọng | Đối tượng ảnh hưởng | Trạng thái | Tóm tắt nội dung |
| :--- | :--- | :---: | :--- | :---: | :--- |
| **DEFECT-GPLACE-01** | Defect / Requirement Gap | Provisional: Medium *(Chờ PO/BA xác nhận)* | `POST /verifications` | Open | Backend chưa triển khai Rate Limiter tầng ứng dụng để giới hạn tần suất gọi API xác minh địa điểm. |
| **OBS-GPLACE-01** | Design Consistency | Low *(UX Alignment)* | `POST /verifications` vs `PUT /google-place` | Open | Khác biệt mã HTTP khi Google báo NOT_FOUND (200 ERROR vs 422 PLACE_NOT_FOUND). |
| **OBS-GPLACE-02** | Authorization UX | Low *(UX Alignment)* | Frontend D3-05 & `PUT /google-place` | Open | Tài khoản vai trò `CS_STAFF` bị RLS chặn 403 khi lưu; cần ẩn nút Lưu trên UI. |

---

## 2. Chi tiết Lỗi và Quan sát Kỹ thuật

### DEFECT-GPLACE-01: Backend chưa triển khai Rate Limiter tầng ứng dụng để bảo vệ endpoint xác minh Google Place
- **Mức độ nghiêm trọng:** Provisional: Medium (Đề xuất tạm thời, chờ Product Owner / Business Analyst xác nhận mức độ ưu tiên theo yêu cầu phi chức năng).
- **Endpoint bị ảnh hưởng:** `POST /api/v1/branches/{branchId}/google-place/verifications`
- **Bằng chứng kiểm tra mã nguồn (Source Code Evidence):**
  1. Kiểm tra tập tin [pom.xml](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/pom.xml): Hoàn toàn không có bất kỳ thư viện hỗ trợ Rate Limiting nào (như `com.bucket4j:bucket4j-core`, `resilience4j-ratelimiter`, hay Redis client).
  2. Kiểm tra tập tin [SecurityConfig.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/main/java/com/cxshield/backend/config/SecurityConfig.java): Bộ lọc bảo mật chỉ cấu hình OAuth2 Resource Server với JWT, không có bất kỳ custom filter nào đếm tần suất request theo IP hoặc theo `branchId`/`userId`.
  3. Kiểm tra controller [GooglePlaceController.java](file:///C:/Users/dnccr/OneDrive/Desktop/New%20folder/CX-SHIELD-GIT/backend/src/main/java/com/cxshield/backend/funnel/GooglePlaceController.java): Endpoint `POST /verifications` chuyển thẳng request vào `googlePlaceService.verify()`, từ đó gọi outbound HTTP tới Google Places API (`https://places.googleapis.com/v1/places/{placeId}`).
- **Mô tả vấn đề & Rủi ro:**
  - Bất kỳ người dùng nào có JWT token hợp lệ đều có thể gửi số lượng request không hạn chế trong thời gian ngắn (Burst Request / DoS).
  - Vì mỗi request xác minh hợp lệ về định dạng đều gọi sang Google Places API (New), việc thiếu Rate Limiter tầng ứng dụng dẫn tới nguy cơ làm cạn kiệt hạn ngạch Google Cloud (Quota Exhaustion) và phát sinh chi phí tính cước (Billing Spikes) đột ngột cho dự án.
- **Điểm cần PO / BA xác nhận (Need PO/BA Confirmation):**
  - Cần BA/PO đưa ra đặc tả chính thức về ngưỡng Rate Limit: Ví dụ tối đa bao nhiêu request trong một khoảng thời gian (chưa có quy định cụ thể trong tài liệu hiện hành).
  - Xác nhận cơ chế Rate Limiting sẽ được triển khai tại tầng ứng dụng Spring Boot (dùng Bucket4j/In-memory Cache) hay tại tầng hạ tầng (Reverse Proxy / Cloudflare API Gateway).

---

### OBS-GPLACE-01: Khác biệt mã trạng thái HTTP khi Google báo địa điểm không tồn tại (NOT_FOUND)
- **Mức độ nghiêm trọng:** Thấp (Phù hợp thiết kế nhưng cần đồng bộ với Frontend).
- **Endpoints liên quan:**
  - `POST /api/v1/branches/{branchId}/google-place/verifications`
  - `PUT /api/v1/branches/{branchId}/google-place`
- **Hiện trạng xác minh qua Code & Unit Test:**
  - *Đã xác minh qua mã nguồn:*
    - Khi `lookup.result() == NOT_FOUND`:
      - `POST /verifications` trả về: **HTTP 200 OK** với JSON `{ "connectionStatus": "ERROR", "verifiedWithGoogle": true, "message": "Google không tìm thấy địa điểm với Place ID này." }` (Được kiểm chứng qua unit test `GooglePlaceServiceTest.verifyReturnsErrorStatusWhenGoogleCannotFindPlace()`).
      - `PUT /google-place` ném ngoại lệ: **HTTP 422 Unprocessable Entity** với JSON `{ "code": "PLACE_NOT_FOUND", "message": "Google không tìm thấy địa điểm với Place ID này." }` (Được kiểm chứng qua unit test `GooglePlaceServiceTest.saveRejectsPlaceThatGoogleCannotFind()`).
  - *Chưa xác minh trên Live Backend:* Chưa chạy end-to-end với Google Places API thật do chưa cấu hình API key có quota trong môi trường test.
- **Điểm cần PO / BA xác nhận:**
  - Xác nhận tính nhất quán về UX: Frontend Flutter (màn hình D3-05) cần xử lý mã 200 (nhưng có cờ `status == ERROR`) khi bấm nút "Kiểm tra địa điểm", và xử lý mã 422 khi bấm nút "Lưu cấu hình" để hiển thị thông báo lỗi màu đỏ đồng nhất cho người dùng.

---

### OBS-GPLACE-02: Phân quyền vai trò CS_STAFF khi lưu cấu hình Place ID
- **Mức độ nghiêm trọng:** Thấp (Trải nghiệm người dùng giao diện).
- **Endpoint bị ảnh hưởng:** `PUT /api/v1/branches/{branchId}/google-place`
- **Hiện trạng xác minh qua Code & Unit Test:**
  - *Đã xác minh qua mã nguồn:* Chính sách RLS trong `database/n3_onboarding_google_place.sql` (`review_platforms_insert_managers`, `review_platforms_update_managers`) quy định chỉ `OWNER` hoặc `BRANCH_MANAGER` mới có quyền INSERT/UPDATE. Trong `GooglePlaceService.java`, nếu repository trả về empty (do RLS chặn), backend sẽ ném `403 Forbidden` (`"Chỉ Chủ cơ sở hoặc Quản lý chi nhánh được lưu cấu hình."`).
  - Unit test `GooglePlaceServiceTest.saveFailsWhenRlsBlocksUpdate()` đã chứng minh service ném mã `FORBIDDEN` khi repo update trả về empty.
  - *Chưa xác minh trên Live Backend:* Chưa chạy trực tiếp qua CSDL Supabase PostgreSQL với tài khoản auth thật mang role `CS_STAFF`.
- **Điểm cần PO / BA xác nhận:**
  - Màn hình D3-05 trên client nên ẩn nút "Lưu cấu hình" hoặc disable toàn bộ form đối với người dùng đăng nhập bằng vai trò Nhân viên CSKH (`CS_STAFF`), thay vì để nhân viên nhấn nút rồi nhận thông báo lỗi 403 từ server.

---

## 3. Kết luận Kiểm thử

- **Về mặt Logic nghiệp vụ:** Backend đáp ứng tốt các quy tắc nghiệp vụ cốt lõi theo đặc tả E4.1, được bảo chứng bởi 44 tests unit/regression Java.
- **Về mặt Hạn chế triển khai:** Phát hiện 1 Defect/Gap kiến trúc về việc thiếu Rate Limiter tầng ứng dụng (`DEFECT-GPLACE-01`).
- Các đề xuất khắc phục sẽ được chuyển giao cho đội ngũ phát triển và PO/BA xem xét đưa vào kế hoạch sprint tiếp theo mà không can thiệp vào production code trong task kiểm thử này.
