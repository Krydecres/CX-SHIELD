# TEST CASES: SCRUM-198 - Kiểm thử chức năng form góp ý 1–3 sao

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-198
- **Đối tượng kiểm thử:** Frontend màn `m1_04_feedback_screen.dart`

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-198-01** | Chuyển màn hình khi chọn 1-3 sao | Chọn 1, 2 hoặc 3 sao ở màn M1-01 | Giao diện tự chuyển sang màn M1-04 (Form Góp ý) | **PASS** |
| **TC-198-02** | Bắt buộc nhập nội dung góp ý | Để trống ô nội dung và bấm "Gửi góp ý" | Hiển thị thông báo lỗi màu đỏ ngay dưới ô nhập | **PASS** |
| **TC-198-03** | Ô nhập Số điện thoại tùy chọn | Nhập góp ý, để trống SĐT và bấm Gửi | Gửi góp ý thành công không báo lỗi | **PASS** |
| **TC-198-04** | Checkbox đồng ý liên hệ | Tích chọn "Đồng ý để nhà hàng liên hệ lại" | Checkbox phản hồi mượt mà, lưu đúng trạng thái | **PASS** |
| **TC-198-05** | Màn hình Cảm ơn sau khi gửi | Bấm nút Gửi góp ý thành công | Chuyển sang màn cảm ơn (M1-05), hiển thị lời xin lỗi/cảm ơn chân thành | **PASS** |