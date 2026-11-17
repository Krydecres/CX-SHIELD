# TEST CASES: SCRUM-225 – Kiểm thử mã nguồn từ khóa gợi ý và ngưỡng chia luồng

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-225 (Story cha: SCRUM-133 – E4.3)
- **Task code phụ thuộc:** `SCRUM-212`
- **Trạng thái thực thi:** **PASS** (5/5 test cases đạt yêu cầu sau khi merge `SCRUM-212`)

## Danh sách Kịch bản Kiểm thử Mã nguồn (White-box & Security)

| Mã TC | Tên kịch bản | Đối tượng / Điều kiện kiểm tra | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-225-01** | Kiểm tra logic CRUD từ khóa gợi ý theo ngành (`review_keywords`) | Controller / Service / Repository quản lý `review_keywords` theo ngành hàng (Nha khoa, Spa, F&B…) | Hỗ trợ đầy đủ thêm / sửa / xóa từ khóa theo cơ sở và ngành hàng | **PASS** |
| **TC-225-02** | Kiểm tra hợp lệ ngưỡng chia luồng (`routing_rules`) & giá trị mặc định | Cấu hình ngưỡng chia luồng trong `routing_rules` và nhánh mặc định | Mặc định `4–5 sao → Google` và `1–3 sao → góp ý nội bộ`; từ chối ngưỡng ngoài khoảng `1..5` | **PASS** |
| **TC-225-03** | Kiểm tra áp dụng ngưỡng chia luồng động trong luồng khảo sát | Hàm `SurveyServiceImpl.submitRating()` đọc ngưỡng từ `routing_rules` | Điều hướng `M1-02` / `M1-04` theo ngưỡng động đã cấu hình cho từng chi nhánh | **PASS** |
| **TC-225-04** | Kiểm tra phân quyền truy cập theo cơ sở trên `review_keywords` & `routing_rules` | Chính sách RLS Supabase và kiểm tra quyền tầng Service giữa các cơ sở khác nhau | Tài khoản thuộc cơ sở A không đọc/sửa được cấu hình của cơ sở B (`403 Forbidden` / RLS chặn) | **PASS** |
| **TC-225-05** | Kiểm tra xử lý lỗi khi thiếu từ khóa / chưa cấu hình quy tắc & Unit Test task code | Gọi API khi `review_keywords` rỗng và chạy bộ Unit Test của `SCRUM-212` | Trả về danh sách rỗng hoặc gợi ý mặc định an toàn; 100% Unit Test của `SCRUM-212` chạy xanh | **PASS** |