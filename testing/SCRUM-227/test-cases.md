# TEST CASES: SCRUM-227 – Kiểm thử tự động cài đặt từ khóa và chia luồng

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-227 (Story cha: SCRUM-133 – E4.3)
- **Task code phụ thuộc:** `SCRUM-212`
- **Trạng thái thực thi:** **PASS** (4/4 test cases đạt yêu cầu sau khi chạy `e2e/keywords_routing_e43.spec.js`)

## Danh sách Kịch bản Kiểm thử Tự động (Automation E2E)

| Mã TC | Tên kịch bản | Luồng tự động dự kiến | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-227-01** | Tự động hóa thêm / sửa / xóa từ khóa gợi ý theo ngành | Đăng nhập bằng tài khoản test → gọi API / thao tác tại `D3-07` để thêm mới, cập nhật và xóa từ khóa | Dữ liệu từ khóa thay đổi đúng qua từng bước CRUD và không làm lộ secrets trong script | **PASS** |
| **TC-227-02** | Tự động hóa lưu ngưỡng chia luồng cảm xúc mới | Cập nhật ngưỡng chia luồng từ mặc định `4 sao` lên `5 sao` và kiểm tra lưu trữ cấu hình | Hệ thống lưu thành công ngưỡng `minPositiveStars = 5` cho chi nhánh | **PASS** |
| **TC-227-03** | Xác nhận luồng khảo sát đi đúng tuyến theo ngưỡng mới | Sau khi đổi ngưỡng lên `5 sao`, chạy kịch bản quét QR và chấm `4 sao` | Khảo sát `4 sao` được định tuyến sang màn góp ý nội bộ `M1-04` (`NEGATIVE`) thay vì `M1-02` | **PASS** |
| **TC-227-04** | Kiểm thử hồi quy (Regression) quy tắc mặc định & màn khách `M1-02` | Khôi phục ngưỡng mặc định `4–5 sao → Google`, kiểm tra câu gợi ý trên `M1-02` và chạy smoke test `e2e/survey_qr_smoke.spec.js` | Khảo sát `4–5 sao` quay lại `M1-02`, hiển thị đúng từ khóa vừa cấu hình và không ảnh hưởng luồng E1.1 | **PASS** |