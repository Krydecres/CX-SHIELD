# TEST CASES: SCRUM-200 - Kiểm thử mã nguồn lối đánh giá công khai và chống lọc đánh giá

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-200
- **Đối tượng kiểm thử:** Backend API & Logic sinh Place ID Google Maps

## Danh sách Kịch bản Kiểm thử (White-box & Security)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-200-01** | Kiểm tra Place ID trả về cho khách 1-3 sao | Gọi API lấy cấu hình khảo sát cho session 1-3 sao | API trả về đúng `googlePlaceId` của cơ sở, không bị ẩn hay null | **PASS** |
| **TC-200-02** | Rà soát điều kiện chống Review Gating | Kiểm tra logic server khi khách chọn 1-3 sao | Không có điều kiện ẩn chặn hiển thị link Google Maps công khai | **PASS** |
| **TC-200-03** | Tracking sự kiện mở link Google công khai | Gọi API ghi nhận click link Google khi ở màn 1-3 sao | Server lưu timestamp `redirect_clicked_at` độc lập với việc gửi form | **PASS** |