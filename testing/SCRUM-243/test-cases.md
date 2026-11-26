# SCRUM-243 — Test Cases: Kiểm thử mã nguồn bảng giá và chọn gói

**Epic:** E8.1 — Bảng giá gói dịch vụ và nâng cấp/gia hạn  
**Story cha:** SCRUM-143  
**Tester:** Huynh Gia Phong  
**Kết quả:** 12/12 PASS — 0 FAIL

## 1. Phạm vi kiểm thử

- Kiểm tra dữ liệu gói dịch vụ lấy từ bảng `plans`.
- Kiểm tra chu kỳ tháng, năm và trọn đời.
- Kiểm tra giá hiển thị và phép tính VAT.
- Kiểm tra chuyển từ bảng giá sang màn hình thanh toán.
- Kiểm tra trạng thái thuê bao để hiển thị Nâng cấp/Gia hạn.
- Kiểm tra quyền truy cập theo cơ sở và xử lý dữ liệu không hợp lệ.

## 2. Danh sách Test Case

| ID        | Nội dung kiểm thử                        | Kết quả mong đợi                                         | Trạng thái |
| --------- | ---------------------------------------- | -------------------------------------------------------- | ---------- |
| TC-243-01 | Kiểm tra danh sách gói dịch vụ           | Hiển thị đủ 3 gói Cơ bản, Nâng cao, Chuỗi                | PASS       |
| TC-243-02 | Kiểm tra dữ liệu giá gói                 | Giá hiển thị đúng theo dữ liệu gói                       | PASS       |
| TC-243-03 | Chọn chu kỳ tháng                        | Hiển thị giá theo tháng                                  | PASS       |
| TC-243-04 | Chọn chu kỳ năm                          | Hiển thị giá theo năm và mức giá tương ứng               | PASS       |
| TC-243-05 | Chọn gói trọn đời                        | Hiển thị giá mua trọn đời chính xác                      | PASS       |
| TC-243-06 | Chuyển đổi tháng/năm                     | Giá và thông tin gói cập nhật đúng khi đổi chu kỳ        | PASS       |
| TC-243-07 | Chọn gói Cơ bản                          | Chuyển sang màn hình thanh toán đúng gói                 | PASS       |
| TC-243-08 | Kiểm tra giá và VAT                      | Tổng thanh toán bằng giá gói cộng VAT 10%                | PASS       |
| TC-243-09 | Kiểm tra thông tin hóa đơn VAT           | Hiển thị các trường thông tin hóa đơn khi bật tùy chọn   | PASS       |
| TC-243-10 | Kiểm tra dữ liệu hóa đơn không hợp lệ    | Hiển thị thông báo khi bỏ trống hoặc nhập sai định dạng  | PASS       |
| TC-243-11 | Kiểm tra trạng thái thuê bao             | Hiển thị hành động Nâng cấp/Gia hạn phù hợp với thuê bao | PASS       |
| TC-243-12 | Kiểm tra quyền truy cập và phạm vi cơ sở | Người dùng chỉ thao tác trong phạm vi được cấp quyền     | PASS       |

## 3. Dữ liệu kiểm thử giá

| Gói      | Chu kỳ   | Giá trước VAT |
| -------- | -------- | ------------: |
| Cơ bản   | Tháng    |      200.000đ |
| Nâng cao | Tháng    |      350.000đ |
| Chuỗi    | Tháng    |      500.000đ |
| Cơ bản   | Năm      |    1.920.000đ |
| Nâng cao | Năm      |    3.360.000đ |
| Chuỗi    | Năm      |    4.800.000đ |
| Cơ bản   | Trọn đời |      990.000đ |
| Nâng cao | Trọn đời |    1.490.000đ |

**Quy tắc tính VAT:** VAT = Giá gói × 10%; Tổng thanh toán = Giá gói + VAT.

## 4. Kết luận

Tất cả 12 Test Case được ghi nhận PASS theo kết quả kiểm thử đã được Tester xác nhận. Không ghi nhận lỗi trong phạm vi kiểm thử SCRUM-243.
