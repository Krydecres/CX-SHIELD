# TEST CASES: SCRUM-223 – Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-223 (Story cha: SCRUM-123 – E1.2)
- **Đối tượng kiểm thử:** Màn hình Frontend `M1-02` (`frontend/lib/screens/m1_02_google_review_screen.dart`)
- **Môi trường kiểm thử:** Thiết bị thật Samsung Galaxy A07 (Android 16) & Flutter Widget Test (`frontend/test/m1_02_google_review_screen_test.dart`)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box & Device Test)

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-223-01** | Chọn 4 sao hoặc 5 sao điều hướng đúng màn `M1-02` | 1. Mở khảo sát QR `MC-B04` tại `M1-01`.<br>2. Chạm chọn 4 sao (và lặp lại với 5 sao). | Chuyển sang màn `M1-02: Đánh giá Google Maps`, hiển thị đúng tiêu đề `"Cảm ơn bạn đã chấm 4/5 sao!"` và tên cơ sở. | **PASS** |
| **TC-223-02** | Hiển thị câu gợi ý & tuân thủ chống Review Gating | Quan sát toàn bộ giao diện `M1-02` sau khi chọn 5 sao. | Hiển thị khung `"Gợi ý nhận xét (tự động copy)"`; không chọn sẵn sao, không tự điền chữ vào URL, không hiển thị voucher/quà tặng gắn với 5 sao. | **PASS** |
| **TC-223-03** | Sao chép câu gợi ý vào bộ nhớ tạm (Clipboard) | Chạm nút `"Sao chép"` trên khung gợi ý nhận xét. | Lưu đúng nội dung gợi ý vào Clipboard, hiện SnackBar `"Đã sao chép câu gợi ý vào bộ nhớ tạm!"` và đổi nhãn nút thành `"Đã chép"`. | **PASS** |
| **TC-223-04** | Thao tác nút `"Đăng Đánh Giá Lên Google Maps"` | Chạm nút `"Đăng Đánh Giá Lên Google Maps"` trên màn `M1-02`. | Tự động sao chép câu gợi ý vào Clipboard và bật hộp thoại `"Mở Google Maps"` với nút xác nhận `"Đã hiểu & Tiếp tục"`. | **PASS** |
| **TC-223-05** | Kiểm thử hồi quy nút `"← Trở lại khảo sát"` trên `M1-02` | Tại màn `M1-02` trên Samsung Galaxy A07 (Android 16), cuộn xuống dưới và chạm `"← Trở lại khảo sát"` hoặc vuốt Back. | Đóng màn `M1-02` và quay về màn chọn sao `M1-01` để khách có thể đánh giá lại. | **FAIL** |