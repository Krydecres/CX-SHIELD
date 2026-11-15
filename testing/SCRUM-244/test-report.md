# SCRUM-244 — TEST REPORT

**Tên task:** [E8.1] Kiểm thử chức năng bảng giá và nâng cấp gói  
**Story cha:** SCRUM-143  
**Tester:** Huynh Gia Phong  
**Ngày báo cáo:** 16/11/2026  
**Môi trường:** CX-SHIELD — D5-10 Pricing, D5-11 Checkout

## 1. Tổng quan kết quả

| Chỉ tiêu                       | Kết quả |
| ------------------------------ | ------: |
| Test Case chức năng            |      12 |
| PASS thủ công                  |      12 |
| FAIL chức năng                 |       0 |
| Automated Test                 |       1 |
| Automated Test hoàn thành      |       0 |
| Automated Test chưa hoàn thành |       1 |

**Kết quả kiểm thử chức năng:** 12/12 PASS theo xác nhận của Tester.

**Kết quả kiểm thử tự động:** Chưa hoàn thành.

## 2. Phạm vi kiểm thử chức năng

### 2.1. Màn hình bảng giá D5-10

- Kiểm tra hiển thị ba gói Cơ bản, Nâng cao và Chuỗi.
- Kiểm tra giá theo chu kỳ tháng.
- Kiểm tra giá theo chu kỳ năm.
- Kiểm tra chuyển đổi giữa các chu kỳ.
- Kiểm tra gói trọn đời.

**Kết quả: PASS**

### 2.2. Màn hình thanh toán D5-11

- Kiểm tra lựa chọn gói dịch vụ.
- Kiểm tra điều hướng từ bảng giá sang thanh toán.
- Kiểm tra tên gói và chu kỳ thanh toán.
- Kiểm tra giá gói và VAT 10%.
- Kiểm tra thông tin hóa đơn VAT.

**Kết quả: PASS**

### 2.3. Trạng thái thuê bao

- Kiểm tra hành động Nâng cấp/Gia hạn.
- Kiểm tra trạng thái gói dịch vụ.
- Kiểm tra quyền thao tác theo vai trò.

**Kết quả: PASS theo xác nhận của Tester.**

## 3. Kết quả kiểm tra giá

| Gói                 |    Giá gói |  VAT 10% | Tổng thanh toán |
| ------------------- | ---------: | -------: | --------------: |
| Cơ bản — Tháng      |   200.000đ |  20.000đ |        220.000đ |
| Cơ bản — Năm        | 1.920.000đ | 192.000đ |      2.112.000đ |
| Cơ bản — Trọn đời   |   990.000đ |  99.000đ |      1.089.000đ |
| Nâng cao — Trọn đời | 1.490.000đ | 149.000đ |      1.639.000đ |

## 4. Kiểm thử tự động

**File:** `e2e/scrum_244_pricing.spec.js`

Đã cài đặt các dependency cần thiết và thực hiện chạy Playwright.

Kết quả nhận được:

```text
Running 1 test using 1 worker

GET /api/v1/plans: 401

1 failed
```

**Nguyên nhân:** API `/api/v1/plans` yêu cầu xác thực. Request kiểm thử chưa cung cấp JWT hợp lệ nên máy chủ trả về HTTP 401 Unauthorized.

**Đánh giá:** Chưa thể xác nhận kết quả kiểm thử tự động. Đây là vấn đề cấu hình xác thực cho môi trường kiểm thử, chưa đủ căn cứ kết luận API có lỗi chức năng.

## 5. Bug và vấn đề tồn tại

| ID          | Vấn đề                                                    | Mức độ         | Trạng thái |
| ----------- | --------------------------------------------------------- | -------------- | ---------- |
| AUTO-244-01 | Playwright chưa xác thực được khi gọi API `/api/v1/plans` | Chưa phân loại | Pending    |

Hướng xử lý: Bổ sung cơ chế lấy JWT hợp lệ cho tài khoản kiểm thử và chạy lại automated test.

## 6. Kết luận

Kiểm thử chức năng SCRUM-244 được ghi nhận **12/12 PASS**, không ghi nhận lỗi chức năng trong phạm vi đã kiểm thử.

Phần kiểm thử tự động đã có script nhưng chưa hoàn thành do thiếu thông tin xác thực API.

**Đề xuất:** Ghi nhận kết quả kiểm thử chức năng và tiếp tục hoàn thiện automated test khi cấu hình xác thực được thiết lập.
