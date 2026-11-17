# SCRUM-245 – TEST SCRIPTS

## 1. Mục tiêu

Tài liệu mô tả các kịch bản kiểm thử tự động được sử dụng để kiểm tra chức năng bảng giá và lựa chọn gói dịch vụ trong CX-SHIELD.

Các công cụ:

- Flutter Test
- Playwright
- PowerShell
- Chrome / Microsoft Edge

## 2. Cấu trúc thư mục

```text
CX-SHIELD/
├── e2e/
│   └── scrum_245_billing_api.spec.js
│
├── frontend/
│   └── test/
│       └── scrum_245_pricing_test.dart
│
└── testing/
    └── SCRUM-245/
        ├── test-cases.md
        ├── test-scripts.md
        └── test-report.md
```

## 3. Flutter Automated Testing

### 3.1. Test Script

File:
frontend/test/scrum_245_pricing_test.dart

### 3.2. Phạm vi kiểm thử

- Đọc dữ liệu BillingPlan.
- Kiểm tra chu kỳ thanh toán.
- Kiểm tra giá theo tháng, năm và trọn đời.
- Kiểm tra định dạng tiền.
- Kiểm tra VAT.
- Kiểm tra trạng thái Subscription.
- Kiểm tra nhãn Chọn gói, Nâng cấp gói và Gia hạn gói.
- Kiểm tra mã số thuế.
- Kiểm tra email hóa đơn.
- Kiểm tra Billing API.
- Kiểm tra thành phần giao diện PlanCard.
- Kiểm tra bảng so sánh gói.

### 3.3. Cách chạy

Mở Terminal tại thư mục frontend:

```powershell
cd D:\Learn\CX-SHIELD\frontend
```

Chạy:

```powershell
flutter test test/scrum_245_pricing_test.dart
```

### 3.4. Kết quả thực tế

```text
00:10 +15: All tests passed!
```

Kết quả:

- Total: 15
- Passed: 15
- Failed: 0

Status: PASS

## 4. Playwright API Automated Testing

### 4.1. Test Script

File:
e2e/scrum_245_billing_api.spec.js

### 4.2. Phạm vi kiểm thử

TC01 – API từ chối truy cập khi chưa đăng nhập.

- Gửi GET request đến /api/v1/plans.
- Không cung cấp access token.
- Kiểm tra API trả về HTTP 401 hoặc 403.

TC02 – API trả về danh sách gói dịch vụ.

- Gửi GET request đến /api/v1/plans.
- Đính kèm access token hợp lệ.
- Kiểm tra HTTP status 200.
- Kiểm tra response là một danh sách.
- Kiểm tra từng gói có id và name.

### 4.3. Cấu hình Playwright

File:
playwright.config.js

- testDir: ./e2e
- fullyParallel: false
- workers: 1
- baseURL: http://localhost:8080
- Reporter: list và HTML report.

### 4.4. Cách chạy

Mở Terminal tại thư mục gốc dự án:

```powershell
cd D:\Learn\CX-SHIELD
```

Cung cấp access token trong biến môi trường:

```powershell
$env:API_TOKEN = Get-Clipboard
```

Chạy test:

```powershell
npx.cmd playwright test e2e/scrum_245_billing_api.spec.js
```

Lưu ý:

- Backend phải đang chạy.
- API_TOKEN phải là access token hợp lệ.
- Không ghi token trực tiếp vào source code.
- Không commit token hoặc thông tin xác thực lên GitHub.

### 4.5. Kết quả thực tế

```text
Running 2 tests using 1 worker

✓ TC01 - API từ chối truy cập khi chưa đăng nhập
✓ TC02 - API trả về danh sách gói dịch vụ

2 passed (2.7s)
```

Kết quả:

- Total: 2
- Passed: 2
- Failed: 0
- Skipped: 0

Status: PASS

## 5. Manual UI Testing

Người kiểm thử đã thực hiện kiểm thử trực tiếp trên giao diện CX-SHIELD.

Các chức năng đã xác nhận:

- Hiển thị bảng giá.
- Hiển thị danh sách gói dịch vụ.
- Chuyển đổi chu kỳ thanh toán.
- Kiểm tra giá và VAT.
- Chọn gói dịch vụ.
- Điều hướng đến Checkout.
- Kiểm tra nâng cấp và gia hạn.

Kết quả: Tất cả 15 Test Case UI đã thực hiện đều PASS.

## 6. Test Evidence

Bằng chứng cần lưu:

1. Ảnh kết quả Flutter Test 15/15 PASS.
2. Ảnh kết quả Playwright 2/2 PASS.
3. Ảnh giao diện bảng giá.
4. Ảnh chuyển đổi chu kỳ tháng/năm.
5. Ảnh trang Checkout sau khi chọn gói.

## 7. Kết luận

Các kịch bản kiểm thử tự động đã thực hiện đều PASS.

- Flutter Test: 15/15 PASS.
- Playwright API Test: 2/2 PASS.
- Manual UI Test: 15/15 PASS theo kết quả kiểm thử thực tế đã xác nhận.

Tổng số kiểm thử đã xác nhận: 32 PASS.
