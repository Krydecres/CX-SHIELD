# SCRUM-245 – TEST CASES

## 1. Thông tin chung

- Project: CX-SHIELD
- Epic: E8.1 – Bảng giá và chọn gói
- Task: SCRUM-245 – Kiểm thử tự động bảng giá và chọn gói
- Module: Billing / Pricing / Checkout
- Tester: QA
- Branch: feature/D4-01-D5-11-canh-bao-dashboard-thanh-toan

## 2. Mục tiêu kiểm thử

Kiểm tra tính chính xác và ổn định của chức năng bảng giá và lựa chọn gói dịch vụ.

Các nội dung kiểm thử:

- Hiển thị danh sách gói dịch vụ.
- Lấy dữ liệu gói từ API.
- Chuyển đổi chu kỳ thanh toán tháng/năm.
- Hiển thị giá và VAT.
- Hiển thị thông tin và giới hạn của từng gói.
- Lựa chọn gói dịch vụ.
- Điều hướng sang Checkout.
- Kiểm tra chức năng nâng cấp và gia hạn.
- Kiểm tra quyền truy cập API.
- Kiểm tra dữ liệu đầu vào và xử lý lỗi.

## 3. Test Cases giao diện (Manual Testing)

### Nhóm A – Hiển thị bảng giá

| ID    | Test Case                            | Expected Result                     | Actual Result | Status |
| ----- | ------------------------------------ | ----------------------------------- | ------------- | ------ |
| UI-01 | Truy cập trang bảng giá              | Trang bảng giá hiển thị bình thường | Hiển thị đúng | PASS   |
| UI-02 | Kiểm tra danh sách gói dịch vụ       | Các gói được hiển thị đầy đủ        | Hiển thị đúng | PASS   |
| UI-03 | Kiểm tra tên các gói                 | Tên gói hiển thị chính xác          | Hiển thị đúng | PASS   |
| UI-04 | Kiểm tra thông tin quyền lợi của gói | Quyền lợi hiển thị đúng             | Hiển thị đúng | PASS   |
| UI-05 | Kiểm tra giới hạn chi nhánh và mã QR | Các giới hạn hiển thị đúng          | Hiển thị đúng | PASS   |

### Nhóm B – Chu kỳ và giá thanh toán

| ID    | Test Case                              | Expected Result                           | Actual Result  | Status |
| ----- | -------------------------------------- | ----------------------------------------- | -------------- | ------ |
| UI-06 | Chọn chu kỳ thanh toán theo tháng      | Hiển thị giá theo tháng                   | Hoạt động đúng | PASS   |
| UI-07 | Chuyển sang chu kỳ thanh toán theo năm | Hiển thị giá theo năm                     | Hoạt động đúng | PASS   |
| UI-08 | Chuyển đổi qua lại giữa tháng và năm   | Giá thay đổi tương ứng                    | Hoạt động đúng | PASS   |
| UI-09 | Kiểm tra định dạng giá tiền            | Giá hiển thị đúng định dạng tiền Việt Nam | Hiển thị đúng  | PASS   |
| UI-10 | Kiểm tra thông tin VAT                 | Hiển thị thông tin VAT 10%                | Hiển thị đúng  | PASS   |

### Nhóm C – Lựa chọn gói dịch vụ

| ID    | Test Case                        | Expected Result                        | Actual Result  | Status |
| ----- | -------------------------------- | -------------------------------------- | -------------- | ------ |
| UI-11 | Chọn một gói dịch vụ             | Điều hướng đến trang Checkout          | Hoạt động đúng | PASS   |
| UI-12 | Kiểm tra thông tin gói được chọn | Checkout nhận đúng planId và chu kỳ    | Hoạt động đúng | PASS   |
| UI-13 | Kiểm tra nút chọn gói            | Nút hoạt động đúng theo trạng thái gói | Hoạt động đúng | PASS   |
| UI-14 | Kiểm tra nút nâng cấp gói        | Hiển thị hành động nâng cấp phù hợp    | Hoạt động đúng | PASS   |
| UI-15 | Kiểm tra nút gia hạn gói         | Hiển thị hành động gia hạn phù hợp     | Hoạt động đúng | PASS   |

### Nhóm D – Kiểm thử bổ sung

Các trường hợp dưới đây được bổ sung để mở rộng độ bao phủ kiểm thử. Chưa đánh dấu PASS khi chưa thực hiện.

| ID    | Test Case                                    | Expected Result                                               | Status  |
| ----- | -------------------------------------------- | ------------------------------------------------------------- | ------- |
| UI-16 | Tải lại trang bảng giá                       | Dữ liệu gói được tải lại chính xác                            | NOT RUN |
| UI-17 | Kiểm tra khi API tải danh sách gói thất bại  | Hiển thị thông báo lỗi phù hợp                                | NOT RUN |
| UI-18 | Nhấn nút tải lại khi API gặp lỗi             | Hệ thống thực hiện tải lại dữ liệu                            | NOT RUN |
| UI-19 | Kiểm tra gói không có giá ở chu kỳ được chọn | Hiển thị Liên hệ hoặc trạng thái phù hợp, không phát sinh lỗi | NOT RUN |
| UI-20 | Kiểm tra gói đang sử dụng                    | Hiển thị trạng thái Đang sử dụng và không cho mua lại         | NOT RUN |
| UI-21 | Kiểm tra tài khoản không có quyền OWNER      | Không cho phép mua hoặc gia hạn gói                           | NOT RUN |
| UI-22 | Kiểm tra bảng so sánh các gói                | Thông tin giá và giới hạn hiển thị chính xác                  | NOT RUN |
| UI-23 | Kiểm tra gói trọn đời                        | Hiển thị giá và thông tin gói trọn đời                        | NOT RUN |
| UI-24 | Kiểm tra nút mua gói trọn đời                | Điều hướng đến Checkout với chu kỳ LIFETIME                   | NOT RUN |
| UI-25 | Kiểm tra giao diện trên màn hình nhỏ         | Nội dung không bị tràn hoặc che khuất                         | NOT RUN |

## 4. API Test Cases

| ID     | Test Case                                     | Expected Result                           | Status |
| ------ | --------------------------------------------- | ----------------------------------------- | ------ |
| API-01 | Gọi API danh sách gói khi chưa xác thực       | API từ chối truy cập                      | PASS   |
| API-02 | Gọi API danh sách gói với access token hợp lệ | API trả về danh sách gói dịch vụ HTTP 200 | PASS   |

## 5. Automated Flutter Test

File:
frontend/test/scrum_245_pricing_test.dart

| ID              | Nội dung                                                                       | Status |
| --------------- | ------------------------------------------------------------------------------ | ------ |
| FL-01 đến FL-15 | Kiểm thử model, chu kỳ, giá, VAT, trạng thái gói, validation, API và giao diện | PASS   |

Kết quả:
15/15 tests passed.

## 6. Tổng kết

- Manual UI Test đã thực hiện: 15/15 PASS.
- API Test: 2/2 PASS.
- Flutter Test: 15/15 PASS.
- Test Case bổ sung UI: 10 trường hợp, chờ thực hiện.

Lưu ý: Không tính các Test Case NOT RUN vào số lượng PASS.
