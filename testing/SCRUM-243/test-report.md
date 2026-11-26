# SCRUM-243 — Test Report

**Tên task:** [E8.1] Kiểm thử mã nguồn bảng giá và chọn gói  
**Story cha:** SCRUM-143  
**Tester:** Huynh Gia Phong  
**Ngày báo cáo:** 16/11/2026  
**Trạng thái:** PASS

## 1. Tổng quan kết quả

| Chỉ tiêu          | Kết quả |
| ----------------- | ------: |
| Tổng số Test Case |      12 |
| PASS              |      12 |
| FAIL              |       0 |
| Tỷ lệ PASS        |    100% |
| Bug phát hiện     |       0 |

<badge color="success">12/12 PASS</badge>

## 2. Nội dung đã kiểm thử

### 2.1. Bảng giá và dữ liệu gói

- Kiểm tra hiển thị ba gói Cơ bản, Nâng cao và Chuỗi.
- Kiểm tra giá theo chu kỳ tháng.
- Kiểm tra giá theo chu kỳ năm.
- Kiểm tra gói trọn đời.
- Kiểm tra cập nhật giá khi chuyển đổi chu kỳ.

**Kết quả: PASS**

### 2.2. Chọn gói và thanh toán

- Chọn gói từ màn hình bảng giá.
- Kiểm tra điều hướng sang màn hình thanh toán.
- Kiểm tra giá gói, VAT 10% và tổng thanh toán.
- Kiểm tra các trường thông tin hóa đơn VAT.
- Kiểm tra thông báo xác thực khi dữ liệu hóa đơn không hợp lệ.

**Kết quả: PASS**

### 2.3. Thuê bao và quyền truy cập

- Kiểm tra trạng thái thuê bao và hành động Nâng cấp/Gia hạn.
- Kiểm tra quyền thao tác theo vai trò.
- Kiểm tra phạm vi truy cập theo cơ sở.

**Kết quả: PASS theo xác nhận kiểm thử của Tester.**

## 3. Kết quả kiểm tra giá và VAT

| Gói                 |    Giá gói |  VAT 10% | Tổng thanh toán |
| ------------------- | ---------: | -------: | --------------: |
| Cơ bản — Tháng      |   200.000đ |  20.000đ |        220.000đ |
| Cơ bản — Năm        | 1.920.000đ | 192.000đ |      2.112.000đ |
| Cơ bản — Trọn đời   |   990.000đ |  99.000đ |      1.089.000đ |
| Nâng cao — Trọn đời | 1.490.000đ | 149.000đ |      1.639.000đ |

## 4. Bug và vấn đề phát hiện

Không ghi nhận bug trong phạm vi các trường hợp đã kiểm thử.

## 5. Kết luận

Kết quả kiểm thử SCRUM-243: **12/12 Test Case PASS, 0 FAIL, 0 bug**.

Các chức năng thuộc phạm vi bảng giá, chọn gói, chu kỳ thanh toán, giá/VAT, thuê bao và quyền truy cập được Tester xác nhận hoạt động đúng.

**Đề xuất:** Có thể chuyển task sang bước hoàn tất kiểm thử sau khi đính kèm Test Cases, Test Scripts và Test Report lên Jira.

## 6. Tài liệu liên quan

- `test-cases.md`
- `test-scripts/pricing_test.dart`
- `test-report.md`
