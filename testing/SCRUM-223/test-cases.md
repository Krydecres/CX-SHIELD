# TEST CASES: SCRUM-223 – Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-223 (Story cha: SCRUM-123 – E1.2)
- **Task code phụ thuộc:** `SCRUM-208`
- **Thiết bị & Môi trường:** Samsung Galaxy A07 (Android 16) & Flutter Widget Test (`frontend/test/m1_02_google_review_screen_test.dart`)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-223-01** | Chọn 4 và 5 sao điều hướng đúng màn `M1-02` & hiển thị từ khóa gợi ý | 1. Quét QR mở màn `M1-01`.<br>2. Lần lượt chọn mức `4 sao` và `5 sao`.<br>3. Quan sát màn `M1-02`. | Điều hướng đúng vào màn `M1-02`, hiển thị đúng tên cơ sở, lời cảm ơn, danh sách từ khóa gợi ý từ bộ từ khóa và câu nhận xét mẫu. | **PASS** |
| **TC-223-02** | Chọn từ khóa gợi ý và sao chép câu nhận xét vào Clipboard | 1. Tại màn `M1-02`, chạm chọn các chip từ khóa ấn tượng.<br>2. Bấm biểu tượng sao chép câu gợi ý.<br>3. Dán thử ra ô nhập liệu ngoài. | Câu gợi ý cập nhật theo từ khóa đã chọn, hiển thị thông báo đã sao chép và bộ nhớ tạm (Clipboard) lưu đúng nội dung. | **PASS** |
| **TC-223-03** | Bấm nút mở đúng trang viết đánh giá Google của cơ sở & ghi nhận lượt bấm | 1. Bấm nút `Đăng Đánh Giá Lên Google Maps` trên `M1-02`.<br>2. Kiểm tra trang Google mở ra và kiểm tra log API `/surveys/google-redirect`. | Mở đúng trang viết đánh giá Google (`writereview`) theo `placeid` của cơ sở; hệ thống ghi nhận `redirect_clicked_at`. | **PASS** |
| **TC-223-04** | Kiểm tra tuân thủ chống review gating (không pre-fill, không voucher 5 sao) | 1. Kiểm tra URL chuyển hướng sang Google Maps.<br>2. Kiểm tra toàn bộ nội dung hiển thị trên màn `M1-02`. | URL chỉ chứa `placeid` của cơ sở, không chọn sẵn số sao, không điền sẵn nội dung đánh giá và không gắn voucher/ưu đãi đổi lấy đánh giá 5 sao. | **PASS** |
| **TC-223-05** | Kiểm tra nút `"← Trở lại khảo sát"` và chọn lại số sao trên thiết bị thật | 1. Từ màn `M1-02` trên Samsung Galaxy A07, bấm nút `"← Trở lại khảo sát"`.<br>2. Trên màn `M1-01` vừa quay lại, chạm chọn lại `4 sao`. | Quay lại `M1-01` an toàn, chọn lại 4 sao điều hướng mượt sang `M1-02` và không bị treo trạng thái loading. | **PASS** |
