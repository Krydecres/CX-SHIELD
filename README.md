# CX-SHIELD

Bộ khung dự án Flutter + Spring Boot. Flutter phụ trách giao diện; backend dùng
Spring Boot, xây dựng trên Spring Framework, để phát triển REST API.

## Cấu trúc

```text
CX-SHIELD/
├── frontend/    Flutter: Android, iOS và Web, màn hình trắng
└── backend/     Spring Boot: Java 21, Spring Web MVC, Maven Wrapper
```

Bản khởi tạo chỉ có mã nguồn khởi động, chưa có màn hình nghiệp vụ, API nghiệp vụ,
đăng nhập, cơ sở dữ liệu hoặc tích hợp dịch vụ ngoài. Hai ứng dụng chạy độc lập;
việc gọi API giữa chúng sẽ được thêm khi phát triển chức năng.

## Môi trường

- Flutter 3.47.3, kèm Dart 3.13.3, hoặc phiên bản mới hơn tương thích.
- JDK 21. Đặt `JAVA_HOME` trỏ tới thư mục JDK nếu Maven Wrapper chưa nhận Java.
- Spring Boot 4.0.0. Maven Wrapper đã có sẵn, không cần cài Maven riêng.
- Chrome để chạy Web. Android cần Android SDK và thiết bị hoặc emulator.
  Build iOS cần macOS và Xcode.

## Chạy backend

Mở terminal tại thư mục gốc dự án:

```powershell
cd backend
.\mvnw.cmd spring-boot:run
```

Server chạy tại `http://localhost:8080`. Do chưa có controller, truy cập `/`
trả về HTTP 404 là bình thường. Có thể đổi cổng bằng biến môi trường `PORT`.

Trên macOS/Linux, dùng `sh ./mvnw spring-boot:run`.

## Chạy Flutter

Mở terminal khác tại thư mục gốc dự án:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 3000
```

Ứng dụng hiển thị một màn hình trắng tại `http://localhost:3000`.
Để chạy trên Android/iOS, dùng `flutter devices`, sau đó `flutter run -d <device-id>`.

## Kiểm tra và build

Backend, từ thư mục `backend`:

```powershell
.\mvnw.cmd verify
```

Frontend, từ thư mục `frontend`:

```powershell
flutter analyze
flutter build web
```

## Phù hợp với dự án

Flutter có thể phục vụ ứng dụng quản lý và giao diện khách hàng; Spring Boot xử lý
nghiệp vụ và các tích hợp qua API. Với trang khảo sát mở qua QR và mục tiêu tải
dưới 1 giây trong tài liệu Epic/User Story, cần đo thời gian tải lần đầu của
Flutter Web trên thiết bị và mạng thực tế khi phát triển giao diện.
