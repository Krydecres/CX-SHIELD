# CX-SHIELD

Review Funnel: Flutter phụ trách giao diện; backend Spring Boot cung cấp REST API;
CSDL và xác thực dùng Supabase (PostgreSQL + Supabase Auth).

## Cấu trúc

```text
CX-SHIELD/
├── frontend/    Flutter: màn hình theo mã màn (lib/features/d3_01_auth, d3_02_onboarding, d3_05_google_place…)
├── backend/     Spring Boot: Java 21, Spring Web MVC, Spring Security (JWT Supabase), Maven Wrapper
└── database/    Script SQL đã chạy trên Supabase
```

Chức năng đã có:

| Jira | User story | Màn hình | API |
| --- | --- | --- | --- |
| SCRUM-203 (E7.1) | Đăng ký / đăng nhập Email + Google, onboarding cơ sở | D3-01, D3-02, khung admin D3-00 | `GET /api/v1/me`, `POST /api/v1/onboarding`, `GET /api/v1/businesses/{id}/branches` |
| SCRUM-207 (E4.1) | Cấu hình Google Place ID theo chi nhánh | D3-05 | `GET/PUT /api/v1/branches/{id}/google-place`, `POST /api/v1/branches/{id}/google-place/verifications` |

Luồng: Flutter đăng nhập bằng Supabase Auth và gửi access token cho backend. Backend
kiểm tra token qua JWKS (ES256) của Supabase rồi gọi Supabase Data API bằng chính token
đó, nên RLS policy trên CSDL vẫn áp dụng theo người đang đăng nhập.

Màu giao diện theo quy tắc 60-30-10 (`frontend/lib/core/theme/app_colors.dart`):
60% nền trung tính, 30% xanh slate cho menu bên / thông báo / khung thông tin,
10% cam cho nút hành động chính, mục menu đang chọn và liên kết.

## Môi trường

- Flutter 3.47.3, kèm Dart 3.13.3, hoặc phiên bản mới hơn tương thích.
- JDK 21. Đặt `JAVA_HOME` trỏ tới thư mục JDK nếu Maven Wrapper chưa nhận Java.
- Spring Boot 4.0.0. Maven Wrapper đã có sẵn, không cần cài Maven riêng.
- Chrome để chạy Web. Android cần Android SDK và thiết bị hoặc emulator.
  Build iOS cần macOS và Xcode.

## Cấu hình

Backend: sao chép `backend/.env.example` thành `backend/.env` và điền
`SUPABASE_PUBLISHABLE_KEY` (Supabase Dashboard > Project Settings > API Keys).
`GOOGLE_PLACES_API_KEY` là tuỳ chọn: khi có, nút "Kiểm tra kết nối" ở D3-05 lấy được tên
và địa chỉ địa điểm từ Google và trạng thái chuyển thành "Đã kết nối"; khi không có,
Place ID chỉ được kiểm tra định dạng và lưu với trạng thái "Chưa xác minh".

Frontend: sao chép `frontend/config/app.example.json` thành `frontend/config/app.json`
và điền publishable key. Hai file `.env` / `app.json` không được commit.

Supabase Auth (Dashboard > Authentication):

- URL Configuration: thêm `http://localhost:3000` vào Site URL / Redirect URLs.
- Sign In / Providers: bật Google và nhập OAuth Client ID / Secret từ Google Cloud
  để nút "Tiếp tục với Google" hoạt động.

## Chạy backend

Mở terminal tại thư mục gốc dự án:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Server chạy tại `http://localhost:8080`, mọi API nằm dưới `/api/v1` và cần token đăng nhập.
Có thể đổi cổng bằng biến môi trường `PORT`.

Trên macOS/Linux, dùng `sh ./mvnw spring-boot:run`.

## Chạy Flutter

Mở terminal khác tại thư mục gốc dự án:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define-from-file=config/app.json
```

Ứng dụng chạy tại `http://localhost:3000` (cổng 3000 phải khớp `CORS_ALLOWED_ORIGINS`
của backend và Redirect URL của Supabase).
Để chạy trên Android/iOS, dùng `flutter devices`, sau đó `flutter run -d <device-id>`.

## Kiểm tra và build

Backend, từ thư mục `backend`:

```powershell
.\mvnw.cmd verify
```

Frontend, từ thư mục `frontend`:

```powershell
flutter analyze
flutter test
flutter build web --dart-define-from-file=config/app.json
```

## Phù hợp với dự án

Flutter có thể phục vụ ứng dụng quản lý và giao diện khách hàng; Spring Boot xử lý
nghiệp vụ và các tích hợp qua API. Với trang khảo sát mở qua QR và mục tiêu tải
dưới 1 giây trong tài liệu Epic/User Story, cần đo thời gian tải lần đầu của
Flutter Web trên thiết bị và mạng thực tế khi phát triển giao diện.
