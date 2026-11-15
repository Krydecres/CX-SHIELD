# SCRUM-244 — Test Cases: Kiểm thử chức năng bảng giá và nâng cấp gói

**Epic:** E8.1 — Bảng giá gói dịch vụ và nâng cấp/gia hạn  
**Story cha:** SCRUM-143  
**Tester:** Huynh Gia Phong  
**Phạm vi:** Màn D5-10 và D5-11  
**Kết quả:** 12/12 PASS theo xác nhận của Tester

## 1. Mục tiêu

Kiểm thử chức năng bảng giá, lựa chọn gói dịch vụ và chuyển tiếp sang màn hình thanh toán. Đảm bảo giá hiển thị đúng theo chu kỳ, lựa chọn gói chính xác và tài khoản đang có gói được hiển thị hành động Nâng cấp/Gia hạn phù hợp.

## 2. Test Cases

| ID        | Nội dung kiểm thử                | Các bước thực hiện                        | Kết quả mong đợi                                 | Kết quả |
| --------- | -------------------------------- | ----------------------------------------- | ------------------------------------------------ | ------- |
| TC-244-01 | Hiển thị bảng giá                | Mở màn D5-10                              | Hiển thị 3 gói Cơ bản, Nâng cao, Chuỗi           | PASS    |
| TC-244-02 | Giá chu kỳ tháng                 | Chọn chu kỳ tháng                         | Giá 200.000đ, 350.000đ, 500.000đ tương ứng       | PASS    |
| TC-244-03 | Giá chu kỳ năm                   | Chọn chu kỳ năm                           | Giá 1.920.000đ, 3.360.000đ, 4.800.000đ tương ứng | PASS    |
| TC-244-04 | Chuyển đổi chu kỳ                | Chuyển qua lại tháng và năm               | Giá hiển thị cập nhật chính xác                  | PASS    |
| TC-244-05 | Hiển thị gói trọn đời            | Chọn tùy chọn trọn đời                    | Hiển thị giá gói trọn đời                        | PASS    |
| TC-244-06 | Chọn gói Cơ bản                  | Nhấn nút chọn gói Cơ bản                  | Điều hướng đến màn D5-11 đúng gói                | PASS    |
| TC-244-07 | Chọn gói Nâng cao                | Nhấn nút chọn gói Nâng cao                | Điều hướng đến màn thanh toán đúng gói           | PASS    |
| TC-244-08 | Chọn gói Chuỗi                   | Nhấn nút chọn gói Chuỗi                   | Điều hướng đến màn thanh toán đúng gói           | PASS    |
| TC-244-09 | Kiểm tra giá tại thanh toán      | Chọn gói và kiểm tra thông tin thanh toán | Tên gói, chu kỳ và giá khớp bảng giá             | PASS    |
| TC-244-10 | Kiểm tra trạng thái đã có gói    | Đăng nhập bằng tài khoản đã có thuê bao   | Hiển thị hành động Nâng cấp/Gia hạn phù hợp      | PASS    |
| TC-244-11 | Kiểm tra thanh toán gói năm      | Chọn gói năm và mở thanh toán             | Giá năm và VAT được tính đúng                    | PASS    |
| TC-244-12 | Kiểm tra thanh toán gói trọn đời | Chọn gói trọn đời và mở thanh toán        | Giá trọn đời và VAT được tính đúng               | PASS    |

## 3. Dữ liệu kiểm thử

### Chu kỳ tháng

| Gói      |      Giá |
| -------- | -------: |
| Cơ bản   | 200.000đ |
| Nâng cao | 350.000đ |
| Chuỗi    | 500.000đ |

### Chu kỳ năm

| Gói      |        Giá |
| -------- | ---------: |
| Cơ bản   | 1.920.000đ |
| Nâng cao | 3.360.000đ |
| Chuỗi    | 4.800.000đ |

### Gói trọn đời

| Gói      |        Giá |
| -------- | ---------: |
| Cơ bản   |   990.000đ |
| Nâng cao | 1.490.000đ |

## 4. Kết luận

12/12 Test Case được ghi nhận PASS
