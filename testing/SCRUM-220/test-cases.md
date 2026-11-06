# TEST CASES: SCRUM-220 - Kiểm thử thủ công chuyển đổi giao diện sáng / tối

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-220
- **Đối tượng kiểm thử:** Theme Toggle (Sáng / Tối / Theo hệ thống) tại Màn hình Login, Onboarding và Header Admin

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-220-01** | Đổi sang Giao diện Tối (Dark Mode) | Chọn chế độ "Tối" ở nút chuyển Theme tại Header | Toàn bộ giao diện đổi sang tông tối, tỉ lệ màu 60-30-10, chữ và thông báo đọc rõ | **PASS** |
| **TC-220-02** | Đổi sang Giao diện Sáng (Light Mode) | Chọn chế độ "Sáng" ở nút chuyển Theme | Giao diện chuyển mượt mà về tông sáng tiêu chuẩn | **PASS** |
| **TC-220-03** | Chế độ theo Hệ thống (System Preference) | Chọn "Theo hệ thống" và thay đổi theme trên thiết bị | Ứng dụng tự động thay đổi theme tương ứng với cài đặt OS | **PASS** |
| **TC-220-04** | Lưu trạng thái sau khi tải lại trang (Persistence) | Đổi sang "Tối" rồi bấm F5 / Reload trang | Trang web tải lại vẫn giữ nguyên chế độ giao diện Tối đã chọn | **PASS** |