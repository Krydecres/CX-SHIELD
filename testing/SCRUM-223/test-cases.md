# TEST CASES: SCRUM-223 - Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-223
- **Đối tượng kiểm thử:** Màn hình Frontend `m1_02_google_review_screen.dart`

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-223-01** | Đổi màn hình khi chọn 4-5 sao | Chọn 4 hoặc 5 sao tại màn M1-01 | Giao diện tự chuyển sang màn M1-02 | **PASS** |
| **TC-223-02** | Gợi ý từ khóa copy | Quan sát danh sách câu gợi ý | Hiển thị các bộ từ khóa SEO theo đúng ngành hàng | **PASS** |
| **TC-223-03** | Sao chép câu gợi ý | Bấm vào nút "Copy" câu gợi ý | Nội dung được lưu vào Clipboard và hiện Toast thông báo | **PASS** |
| **TC-223-04** | Chuyển hướng Google Maps | Bấm nút "Đánh giá trên Google Maps" | Mở đúng URL Google Maps Place ID của cơ sở | **PASS** |