# BÁO CÁO KIỂM THỬ TỰ ĐỘNG – SCRUM-193

### 1. Mục tiêu

Kiểm tra tự động các chức năng đăng ký tài khoản, đăng nhập, xác thực người dùng và onboarding của hệ thống CX-SHIELD.

### 2. Môi trường kiểm thử

- Frontend: Flutter Web.
- Backend: Spring Boot.
- Công cụ kiểm thử Backend: Maven.
- Công cụ kiểm thử Frontend: Flutter Test.
- Hệ quản trị dữ liệu và xác thực: Supabase.

### 3. Kết quả kiểm thử Backend

Thực hiện lệnh:

`.\mvnw.cmd verify`

Kết quả:

- Tổng số test: 123.
- Failures: 0.
- Errors: 0.
- Skipped: 0.
- Kết quả build: BUILD SUCCESS.

### 4. Kết quả kiểm thử Frontend

**Kiểm thử Auth & Onboarding**

Lệnh thực hiện:

`flutter test test/auth_onboarding_test.dart`

Kết quả: 18 test thành công, không có test thất bại.

**Kiểm thử toàn bộ Frontend**

Lệnh thực hiện:

`flutter test`

Kết quả: 91 test thành công, không có test thất bại.

**Kiểm tra chất lượng mã nguồn**

Lệnh thực hiện:

`flutter analyze`

Kết quả: Phát hiện 1 cảnh báo tại `lib/main.dart:113:7`:

`_MissingConfigApp` isn't referenced (unused_element).

Đây là cảnh báo về khai báo không được sử dụng, không ảnh hưởng đến kết quả chạy test.

### 5. Đánh giá

- Các bài kiểm thử tự động Backend hoàn thành thành công.
- Các bài kiểm thử tự động Frontend hoàn thành thành công.
- Nhóm test Auth & Onboarding có 18 test và đều đạt yêu cầu.
- Toàn bộ 91 test Frontend đều thành công.
- Không ghi nhận lỗi test thất bại trong các lần chạy trên.

### 6. Kết luận

Đã hoàn thành việc chạy và kiểm tra bộ kiểm thử tự động cho các chức năng đăng ký, đăng nhập và onboarding.

Kết quả Backend và Frontend đều đạt yêu cầu, không có test thất bại hoặc lỗi thực thi. Còn một cảnh báo Flutter Analyze liên quan đến khai báo không được sử dụng, không ảnh hưởng đến kết quả kiểm thử.

**Trạng thái: COMPLETED – Đã hoàn thành kiểm thử tự động SCRUM-193.**
