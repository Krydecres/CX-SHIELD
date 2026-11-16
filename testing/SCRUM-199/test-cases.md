# TEST CASES: SCRUM-199 - Kiểm thử hồi quy luồng góp ý 1–3 sao (E2E Regression)

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-199
- **Đối tượng kiểm thử:** Luồng E2E Form góp ý & Trường hợp biên

## Danh sách Kịch bản Kiểm thử Hồi quy

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-199-01** | Giới hạn độ dài nội dung | Nhập văn bản > 1000 ký tự vào ô góp ý | Bị cắt hoặc hiển thị cảnh báo vượt quá số ký tự | **PASS** |
| **TC-199-02** | Xử lý khi mất kết nối mạng | Tắt Wifi/4G rồi bấm nút Gửi góp ý | Hiển thị thông báo "Lỗi kết nối, vui lòng thử lại" | **PASS** |
| **TC-199-03** | Gửi góp ý lần 2 trên cùng Session | Thực hiện gửi góp ý 2 lần liên tiếp | Bắt lỗi trùng lặp (BUG-01 re-test) | **PASS** |
| **TC-199-04** | Hiển thị link Google Maps phụ | Kiểm tra cuối màn M1-04 | Vẫn có link mở Google Review công khai (Review Gating compliant) | **PASS** |