# Test Report — SCRUM-256: [E1.1] Kiểm thử lưu khảo sát và góp ý vào Supabase

- **Jira Ticket:** SCRUM-256
- **Sprint:** Sprint 4
- **Loại kiểm thử:** Kiểm thử chức năng hộp đen (Manual Black-box QA) trên môi trường tích hợp thật
- **Cam kết tham chiếu:** `09a8511` (`SCRUM-254`)
- **Ngày lập báo cáo:** 25/11/2026
- **Trạng thái tổng thể:** **PASSED (10/10 Test Cases — 100%)**

---

## 1. Mục tiêu & Phạm vi kiểm thử

Kiểm chứng toàn bộ luồng khảo sát khách hàng (từ quét mã QR, đánh giá sao, chuyển hướng Google Review đến gửi góp ý nội bộ và phát cảnh báo) hoạt động ổn định trên môi trường chạy thật kết nối trực tiếp cơ sở dữ liệu **Supabase PostgreSQL**, đảm bảo dữ liệu được lưu chính xác và đồng bộ lên trang quản trị **Dashboard**.

### Môi trường thực hiện
- **Backend:** Java 21 / Spring Boot (`port 8080`), kết nối Supabase qua `SUPABASE_SERVICE_ROLE_KEY`.
- **Frontend:** Flutter Web (`port 8000`), cấu hình `BACKEND_URL` trỏ trực tiếp tới Backend `port 8080`.
- **Database:** Supabase PostgreSQL (kiểm tra trực tiếp các bảng `qr_codes`, `survey_sessions`, `survey_responses`, `feedbacks`).
- **Trình duyệt:** Google Chrome (kèm DevTools Network throttling để kiểm thử điều kiện mạng chậm `Slow 3G`).

---

## 2. Kết quả tổng hợp

| Chỉ số kiểm thử | Số lượng | Tỷ lệ |
| :--- | :---: | :---: |
| **Tổng số Test Case thực thi** | **10** | **100%** |
| **PASS (Đạt yêu cầu)** | **10** | **100%** |
| **FAIL (Không đạt)** | **0** | **0%** |
| **BLOCKED (Bị chặn)** | **0** | **0%** |
| **Tổng số Bug phát hiện** | **0** | — |

---

## 3. Chi tiết kết quả theo từng nhóm chức năng

1. **Khởi tạo phiên khảo sát & Xử lý mã QR (`TC-01`, `TC-08`):**
   - Quét mã QR hợp lệ (`MC-B01`) hiển thị đúng tên chi nhánh/bàn và sinh bản ghi `survey_sessions` trên Supabase đầy đủ khóa ngoại (`qr_code_id`, `branch_id`, `business_id`).
   - Truy cập mã QR không tồn tại (`ABC123`) trả về thông báo lỗi chuẩn (`"Mã QR không tồn tại trong hệ thống: ABC123"`), không tự động tạo bản ghi fallback trong `qr_codes` và không sinh phiên rác.
2. **Luồng đánh giá tích cực 4–5 sao & Google Review (`TC-02`, `TC-03`):**
   - Chấm 4–5 sao cập nhật `survey_sessions.status = COMPLETED` và ghi nhận bản ghi vào `survey_responses` với `sentiment_group = SATISFIED`, đầy đủ `business_id`.
   - Bấm mở liên kết Google Review cập nhật chính xác dấu thời gian vào cột `redirect_clicked_at`.
3. **Luồng đánh giá tiêu cực 1–3 sao, Góp ý & Cảnh báo (`TC-04`, `TC-05`, `TC-06`, `TC-10`):**
   - Chấm 1–3 sao lưu bản ghi `UNSATISFIED` vào `survey_responses` và tạo bản ghi góp ý đầy đủ nội dung, chủ đề, `business_id` trong bảng `feedbacks`.
   - Mức 1 sao hiển thị đầy đủ tùy chọn hỗ trợ khẩn cấp / gọi quản lý trực tiếp.
   - Kênh cảnh báo nhận thông báo tự động ngay sau khi phát sinh góp ý tiêu cực; form góp ý chặn gửi hợp lệ khi bỏ trống dữ liệu bắt buộc.
4. **Tính ổn định & Đồng bộ dữ liệu (`TC-07`, `TC-09`):**
   - Khi giả lập mạng chậm (`Slow 3G`) và bấm sao ngay lúc vừa mở trang, hệ thống giữ lại thao tác và tự động đồng bộ sau khi API khởi tạo phiên hoàn tất, không làm mất lượt đánh giá.
   - Số liệu tổng hợp trên màn hình Dashboard và danh sách Quản lý phản hồi cập nhật khớp chính xác với dữ liệu trên Supabase.

---

## 4. Kết luận & Đề xuất

- **Kết luận:** Toàn bộ **10/10** kịch bản kiểm thử đều đạt yêu cầu (**PASS 100%**), không phát hiện lỗi (0 Bug). Luồng lưu khảo sát, góp ý và đồng bộ dữ liệu Supabase đáp ứng đầy đủ tiêu chí nghiệm thu của ticket **SCRUM-256**.
- **Đề xuất:** Đủ điều kiện đóng ticket **SCRUM-256** (Done).