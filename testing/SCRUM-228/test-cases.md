# TEST CASES: SCRUM-228 - Kiểm thử mã nguồn cấu hình kênh cảnh báo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-228
- **Đối tượng kiểm thử:** Backend Controller & Service quản lý `alert_channels`

## Danh sách Kịch bản Kiểm thử (White-box & Security)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-228-01** | Che giấu Token bảo mật (Masking Token) | Gọi API GET danh sách kênh cảnh báo Telegram / Zalo | Token/Secret được che `****` trong response API và Log | **PASS** |
| **TC-228-02** | Bật / Tắt trạng thái kênh | Gọi API PATCH đổi `enabled = false` | Server lưu trạng thái và không gửi tin qua kênh này | **PASS** |
| **TC-228-03** | Cập nhật timestamp gửi thử | Thực hiện test connection nút "Gửi thử" | Server lưu đúng mốc thời gian `last_tested_at` trong DB | **PASS** |
| **TC-228-04** | Phân quyền cấu hình kênh theo Chi nhánh | Đăng nhập tài khoản chi nhánh A sửa cấu hình chi nhánh B | Server trả về lỗi `403 Forbidden` | **PASS** |