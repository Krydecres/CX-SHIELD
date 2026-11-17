# SCRUM-247 — Test cases: Thanh toán sandbox và thông tin xuất hóa đơn

## Phạm vi và tiền điều kiện

- Kiểm thử theo implementation hiện có của màn D5-11.
- Chỉ chạy unit test với mock; chưa kết nối cổng thanh toán sandbox và không phát sinh giao dịch tiền thật.
- Môi trường quan sát: branch `feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan`.

| ID | Tình huống | Các bước / dữ liệu | Kết quả mong đợi | Kết quả |
|---|---|---|---|---|
| TC-01 | Mã số thuế hợp lệ 10 số | Gọi validator với `0312345678` | Được chấp nhận | PASS — Flutter unit test |
| TC-02 | Mã số thuế hợp lệ 13 số | Dùng `0312345678-001` và `0312345678001` | Cả hai dạng được chấp nhận | PASS — Flutter unit test |
| TC-03 | Mã số thuế sai / bỏ trống | Dùng chuỗi rỗng và `123` | Báo lỗi, không cho tiếp tục checkout | PASS — Flutter unit test |
| TC-04 | Email hóa đơn hợp lệ | Dùng `ketoan@maison.vn` | Được chấp nhận | PASS — Flutter unit test |
| TC-05 | Email hóa đơn sai / bỏ trống | Dùng chuỗi rỗng và `a@b` | Báo lỗi, không cho tiếp tục checkout | PASS — Flutter unit test |
| TC-06 | Tên công ty bắt buộc | Gửi hồ sơ có tên công ty chỉ gồm khoảng trắng | Backend từ chối `INVALID_COMPANY_NAME`; không tạo payment | PASS — BillingServiceTest |
| TC-07 | Lưu thông tin hóa đơn hợp lệ | Checkout với mã số thuế, tên công ty, email hợp lệ | Hồ sơ được gửi/lưu cùng business; payment được tạo | PASS — Flutter + BillingServiceTest |
| TC-08 | Tạo checkout | Chọn gói và chu kỳ có hỗ trợ | Tạo transaction, tính VAT 10%, tổng tiền đúng; chưa tự kích hoạt thuê bao | PASS — BillingServiceTest |
| TC-09 | Thanh toán thành công | Callback có chữ ký và số tiền hợp lệ | Giao dịch được xác nhận; cơ chế xác nhận kích hoạt thuê bao được gọi | PASS — VnpayCallbackServiceTest (mock) |
| TC-10 | Thanh toán thất bại hoặc người dùng hủy | Mã phản hồi lỗi / mã hủy `24` | Trạng thái FAILED, thông báo phù hợp; không kích hoạt gói | PASS — BillingServiceTest + VnpayCallbackServiceTest (mock) |
| TC-11 | Quét VietQR qua sandbox | Thực hiện giao dịch QR trên cổng sandbox và quay lại ứng dụng | Xác nhận thành công kích hoạt đúng gói | CHƯA CHẠY — chưa thực hiện E2E với cổng sandbox |
| TC-12 | PayOS success / failure / cancel | Thực hiện các luồng trên PayOS sandbox | Kích hoạt chỉ khi thành công; lỗi/hủy không kích hoạt | BLOCKED — không tìm thấy tích hợp PayOS trong source hiện tại |

## Ghi chú

Các test backend callback dùng mock, không chứng minh cấu hình tài khoản hoặc kết nối sandbox thực tế. Màn hiện tại chuyển sang VNPAY (có lựa chọn QR); Jira yêu cầu VietQR / PayOS nên cần xác nhận cổng dự kiến trước khi nghiệm thu E2E.
