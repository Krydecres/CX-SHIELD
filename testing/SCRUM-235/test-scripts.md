# KỊCH BẢN KIỂM THỬ CHỨC NĂNG TỰ ĐỘNG GIAO DIỆN D3-09 (SCRUM-235)

- **Mã Jira:** SCRUM-235
- **Tên User Story:** [E5.1] Kiểm thử chức năng studio thiết kế ấn phẩm QR
- **Phân hệ:** Giao diện người dùng Flutter (Màn hình D3-09 · `/print-materials`)
- **Công cụ kiểm thử:** Flutter Widget Test Framework, MockClient (`http/testing.dart`), Dart SDK
- **Tệp kịch bản kiểm thử:** `frontend/test/d3_09_qr_studio_functional_test.dart` (12 automation tests)

---

## 1. Yêu cầu môi trường & Cài đặt

- **Hệ điều hành:** Windows 10/11 x64
- **Flutter SDK:** Flutter 3.29.x trở lên, Dart 3.7.x
- **Trình duyệt / Thiết bị:** Chrome (Web Desktop) hoặc Windows desktop runner
- **Thư mục làm việc:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend`

---

## 2. Các lệnh thực thi kiểm thử (Execution Commands)

### 2.1. Chạy bộ kiểm thử chức năng SCRUM-235 (12 tests)
Thực thi toàn bộ 12 ca kiểm thử chức năng tự động hóa trên Widget Test:

```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/d3_09_qr_studio_functional_test.dart
```

### 2.2. Chạy bộ kiểm thử hồi quy màn D3-09 hiện có (6 tests)
```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/d3_09_qr_studio_test.dart
```

### 2.3. Chạy toàn bộ kiểm thử gói Studio Thiết kế QR (18 tests frontend)
```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/d3_09_qr_studio_functional_test.dart test/d3_09_qr_studio_test.dart
```

---

## 3. Cấu trúc kịch bản kiểm thử tự động (`d3_09_qr_studio_functional_test.dart`)

```dart
import 'dart:async';
import 'dart:convert';
import 'package:cx_shield/core/api/api_client.dart';
import 'package:cx_shield/core/models/account_models.dart';
import 'package:cx_shield/core/session/session_controller.dart';
import 'package:cx_shield/core/theme/app_theme.dart';
import 'package:cx_shield/features/d3_09_qr_studio/d3_09_qr_studio_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  // Mock dữ liệu cơ sở Maison Coffee, chi nhánh b0eebc99 và danh sách mã QR MC-B04
  // Thiết lập Viewport máy tính bảng/màn hình rộng (1280 x 1600 px)
  // Thực thi tuần tự 12 kịch bản kiểm thử tương ứng TC-235-01 đến TC-235-12
}
```

---

## 4. Chiến lược Mock và Xử lý Giả lập

1. **Giả lập API Backend bằng MockClient:**
   - Endpoint `/api/v1/qr-codes` (GET danh sách QR, POST tạo QR vị trí mới).
   - Endpoint `/api/v1/print-designs` (GET danh sách mẫu đã lưu, POST lưu mẫu mới / cập nhật mẫu, DELETE xóa mẫu).
   - Đảm bảo thời gian phản hồi tức thì (< 0.1s), cô lập hoàn toàn khỏi sự cố mạng hay trạng thái cơ sở dữ liệu thật.
2. **Viewport Simulation:**
   - Đặt kích thước màn hình `1280 x 1600` với pixel ratio `1.0` để kích hoạt giao diện Responsive hai cột chuẩn Desktop (`flex: 6` form editor, `flex: 5` live preview pane).
3. **Giới hạn kiểm thử phần cứng vật lý (Out of Scope):**
   - Kiểm thử thao tác quét quang học bằng camera điện thoại thật từ ngoài đời thực được ghi nhận trạng thái **NOT RUN**; thay vào đó hệ thống kiểm chứng thành công thông qua nút điều hướng thử nghiệm và phân tích dữ liệu URL ma trận QR ZXing.
