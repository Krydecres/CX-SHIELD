# SCRUM-245 – TEST REPORT

## 1. Thông tin dự án

| Thuộc tính | Nội dung                                          |
| ---------- | ------------------------------------------------- |
| Project    | CX-SHIELD                                         |
| Epic       | E8.1 – Bảng giá và chọn gói                       |
| Task       | SCRUM-245                                         |
| Module     | Billing / Pricing / Checkout                      |
| Tester     | QA                                                |
| Branch     | feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan |

## 2. Mục tiêu kiểm thử

Đánh giá chất lượng và tính ổn định của chức năng bảng giá và lựa chọn gói dịch vụ.

Các nội dung:

- Kiểm tra dữ liệu bảng giá.
- Kiểm tra chu kỳ thanh toán.
- Kiểm tra giá và VAT.
- Kiểm tra lựa chọn gói.
- Kiểm tra nâng cấp và gia hạn.
- Kiểm tra API.
- Kiểm tra tính đúng đắn của dữ liệu và giao diện.

## 3. Môi trường kiểm thử

| Thành phần          | Môi trường              |
| ------------------- | ----------------------- |
| Frontend            | Flutter                 |
| Backend             | Spring Boot             |
| API Testing         | Playwright              |
| Unit/Widget Testing | Flutter Test            |
| Browser             | Microsoft Edge / Chrome |
| Operating System    | Windows 11              |
| API Base URL        | http://localhost:8080   |
| Frontend URL        | http://localhost:3000   |

## 4. Kết quả kiểm thử giao diện

Người kiểm thử đã thực hiện kiểm thử trực tiếp trên giao diện trước khi hoàn thiện bộ kiểm thử tự động.

| Nhóm                     | Số lượng | PASS | FAIL |
| ------------------------ | -------: | ---: | ---: |
| Hiển thị bảng giá        |        5 |    5 |    0 |
| Chu kỳ và giá thanh toán |        5 |    5 |    0 |
| Lựa chọn gói dịch vụ     |        5 |    5 |    0 |
| Tổng cộng                |       15 |   15 |    0 |

Kết luận:
Tất cả 15 Test Case giao diện đã thực hiện đều PASS.

## 5. Kết quả Flutter Automated Testing

Test file:

frontend/test/scrum_245_pricing_test.dart

Lệnh thực hiện:

```powershell
flutter test test/scrum_245_pricing_test.dart
```

Kết quả:

```text
00:10 +15: All tests passed!
```

| Chỉ số | Kết quả |
| ------ | ------: |
| Total  |      15 |
| Passed |      15 |
| Failed |       0 |
| Status |    PASS |

## 6. Kết quả Playwright API Testing

Test file:

e2e/scrum_245_billing_api.spec.js

Lệnh thực hiện:

```powershell
npx.cmd playwright test e2e/scrum_245_billing_api.spec.js
```

Kết quả:

```text
Running 2 tests using 1 worker

2 passed (2.7s)
```

| ID   | Test Case                               | Kết quả |
| ---- | --------------------------------------- | ------- |
| TC01 | API từ chối truy cập khi chưa đăng nhập | PASS    |
| TC02 | API trả về danh sách gói dịch vụ        | PASS    |

Tổng kết:

- Total: 2
- Passed: 2
- Failed: 0
- Skipped: 0

## 7. Tổng hợp kết quả kiểm thử

| Loại kiểm thử          | Total | PASS | FAIL |
| ---------------------- | ----: | ---: | ---: |
| Manual UI Testing      |    15 |   15 |    0 |
| Flutter Testing        |    15 |   15 |    0 |
| Playwright API Testing |     2 |    2 |    0 |
| Tổng cộng              |    32 |   32 |    0 |

Tỷ lệ PASS của các Test Case đã thực hiện: 100%.

Lưu ý: 10 Test Case UI bổ sung trong test-cases.md chưa được tính vào thống kê này.

## 8. Defect Report

Trong các lần kiểm thử được ghi nhận:

- Không có Test Case tự động nào thất bại sau lần chạy thành công cuối cùng.
- Không ghi nhận lỗi chức năng UI trong các Test Case đã xác nhận PASS.
- Không ghi nhận defect sản phẩm từ kết quả hiện có.

Sự cố trong quá trình kiểm thử:

- Playwright từng trả về HTTP 401 do biến môi trường API_TOKEN chứa dữ liệu xác thực không hợp lệ.
- Sau khi thiết lập lại access token hợp lệ, TC02 chạy thành công.
- Đây là vấn đề trong quá trình thiết lập môi trường kiểm thử, không phải defect đã xác nhận của sản phẩm.

## 9. Các Test Case cần thực hiện bổ sung

10 Test Case UI bổ sung đã được đề xuất:

- UI-16: Tải lại trang bảng giá.
- UI-17: API tải danh sách gói thất bại.
- UI-18: Thử tải lại sau khi API lỗi.
- UI-19: Gói không có giá ở chu kỳ được chọn.
- UI-20: Gói đang sử dụng.
- UI-21: Tài khoản không có quyền OWNER.
- UI-22: Bảng so sánh các gói.
- UI-23: Gói trọn đời.
- UI-24: Mua gói trọn đời.
- UI-25: Giao diện trên màn hình nhỏ.

Các trường hợp này chưa được tính vào kết quả PASS hiện tại.

## 10. Kết luận

Qua quá trình kiểm thử SCRUM-245:

- 15/15 Test Case UI đã thực hiện PASS.
- 15/15 Flutter Test PASS.
- 2/2 Playwright API Test PASS.
- Tổng cộng 32/32 Test Case đã thực hiện PASS.
- Không có Test Case thất bại trong kết quả kiểm thử cuối cùng.

Kết quả kiểm thử cho thấy các chức năng đã được kiểm tra hoạt động đúng theo Expected Result.

Đề xuất:

- Lưu trữ đầy đủ bằng chứng kiểm thử.
- Thực hiện thêm các Test Case mở rộng.
- Cập nhật kết quả vào Jira SCRUM-245.
- Đính kèm Test Cases, Test Scripts và Test Report.
