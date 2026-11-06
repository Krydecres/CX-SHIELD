# TEST CASES: SCRUM-226 - Kiểm thử chức năng cài đặt từ khóa và ngưỡng chia luồng

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-226
- **Đối tượng kiểm thử:** Frontend Admin Màn D3-07 (Quản lý Từ khóa & Phân luồng)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-226-01** | Thêm mới từ khóa theo ngành | Thêm bộ từ khóa ngành F&B / Spa / Nha khoa tại D3-07 | Từ khóa mới xuất hiện lập tức trên danh sách giao diện Admin | **PASS** |
| **TC-226-02** | Cập nhật ngưỡng phân luồng | Thay đổi ngưỡng hài lòng từ 4 sao thành 5 sao | Hệ thống lưu thành công và hiển thị Toast thông báo | **PASS** |
| **TC-226-03** | Bắt lỗi nhập dữ liệu trùng lặp | Nhập từ khóa đã tồn tại trong cùng danh mục | Hiển thị thông báo lỗi "Từ khóa đã tồn tại" | **PASS** |
| **TC-226-04** | Kiểm tra đồng bộ sang màn khách | Thay đổi từ khóa ở Admin rồi thực hiện đánh giá ở màn M1-02 | Màn khách M1-02 hiển thị câu gợi ý theo bộ từ khóa mới tạo | **PASS** |