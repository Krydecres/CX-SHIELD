# TEST CASES: SCRUM-225 - Kiểm thử mã nguồn từ khóa gợi ý và ngưỡng chia luồng

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-225
- **Đối tượng kiểm thử:** Backend Controller & Service quản lý `review_keywords` và `routing_rules`

## Danh sách Kịch bản Kiểm thử (White-box & Security)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-225-01** | Kiểm tra API CRUD bộ từ khóa | Gọi API thêm/sửa/xóa từ khóa theo ngành hàng | Database cập nhật bảng `review_keywords` chính xác | **PASS** |
| **TC-225-02** | Validation ngưỡng chia luồng cảm xúc | Đặt ngưỡng chia luồng `minPositiveStars = 4` | Hệ thống lưu cấu hình và áp dụng chính xác cho logic khảo sát | **PASS** |
| **TC-225-03** | Phân quyền truy cập theo cơ sở/chi nhánh | Đăng nhập tài khoản Manager chi nhánh A và truy cập cấu hình chi nhánh B | Server trả về lỗi `403 Forbidden` | **PASS** |
| **TC-225-04** | Xử lý khi chưa có từ khóa thiết lập | Gọi API lấy câu gợi ý khi bảng từ khóa rỗng | Server trả về danh sách mặc định hoặc mảng rỗng, không sập server | **PASS** |