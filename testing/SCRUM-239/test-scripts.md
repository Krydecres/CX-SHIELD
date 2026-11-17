# KỊCH BẢN VÀ HƯỚNG DẪN THỰC THI KIỂM THỬ TỰ ĐỘNG (TEST SCRIPTS)

**Mã công việc:** SCRUM-239
**Tiêu đề:** [E5.3] Kiểm thử tự động xuất file in và đặt thẻ NFC
**Màn hình:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày cập nhật:** 17/11/2026

---

## 1. CẤU TRÚC BỘ KIỂM THỬ TỰ ĐỘNG (AUTOMATION STRUCTURE)

```text
CX-SHIELD/
├── frontend/
│   ├── lib/
│   │   ├── features/d3_11_print_nfc/
│   │   │   └── d3_11_print_nfc_page.dart         # Giao diện chức năng D3-11 (3 Tabs)
│   │   └── core/
│   │       ├── api/api_client.dart               # HTTP Client gọi backend
│   │       └── session/session_controller.dart   # Quản lý phiên làm việc Merchant
│   └── test/
│       ├── d3_11_print_nfc_automation_test.dart  # Kịch bản Automation SCRUM-239 (10 tests)
│       ├── d3_11_print_nfc_functional_test.dart  # Bộ Functional Test SCRUM-238 (10 tests)
│       └── d3_11_print_nfc_test.dart             # Bộ Widget Test cơ sở SCRUM-214 (4 tests)
├── backend/
│   ├── src/main/java/com/cxshield/backend/
│   │   ├── service/PrintExportService.java       # Service xuất ảnh PNG và file PDF 300 DPI
│   │   └── service/NfcOrderService.java          # Service lưu trữ đơn đặt phôi thẻ NFC
│   └── src/test/java/com/cxshield/backend/
│       └── PrintNfcSourceTest.java               # Automation Backend + PDFBox + ZXing (28 tests)
└── testing/
    └── SCRUM-239/
        ├── test-cases.md                         # Danh sách 11 Automation Test Cases
        ├── test-scripts.md                       # Kịch bản chi tiết & lệnh thực thi
        ├── test-report.md                        # Báo cáo tổng hợp số liệu thực thi
        └── bug-reports.md                        # Báo cáo lỗi và quan sát
```

---

## 2. HƯỚNG DẪN THỰC THI KIỂM THỬ TỰ ĐỘNG

### 2.1. Chạy bộ kiểm thử tự động Frontend (Flutter Test Runner)

Mở terminal tại thư mục gốc repository và chạy:

```powershell
# Di chuyển vào thư mục frontend
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"

# Chạy riêng kịch bản Automation D3-11 của SCRUM-239
flutter test test/d3_11_print_nfc_automation_test.dart

# Chạy kiểm thử hồi quy toàn diện cho màn hình D3-11 (Automation + Functional + Widget)
flutter test test/d3_11_print_nfc_test.dart test/d3_11_print_nfc_functional_test.dart test/d3_11_print_nfc_automation_test.dart
```

**Kết quả runner kỳ vọng:**
```text
00:05 +24: All tests passed!
```

---

### 2.2. Chạy bộ kiểm thử tự động Backend & Parser PDF/ZXing (Maven Runner)

Mở terminal tại thư mục backend và chạy:

```powershell
# Di chuyển vào thư mục backend
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"

# Chạy bộ test mã nguồn backend tích hợp xác minh PDFBox và ZXing
mvn test "-Dtest=PrintNfcSourceTest"
```

**Kết quả runner kỳ vọng:**
```text
[INFO] Running com.cxshield.backend.PrintNfcSourceTest
[INFO] Tests run: 28, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 2.152 s
[INFO] BUILD SUCCESS
```

---

## 3. PHÂN TÍCH KỸ THUẬT KỊCH BẢN AUTOMATION

### 3.1. Frontend Automation (`d3_11_print_nfc_automation_test.dart`)
1. **Mock Platform URL Launcher:** Sử dụng `MockUrlLauncher` implements `UrlLauncherPlatform` để tự động chặn và ghi lại URL tải file ấn phẩm mà không làm gián đoạn headless testing:
   ```dart
   class MockUrlLauncher extends Fake with MockPlatformInterfaceMixin implements UrlLauncherPlatform {
     String? launchedUrl;
     @override
     Future<bool> launchUrl(String url, LaunchOptions options) async {
       launchedUrl = url;
       return true;
     }
   }
   ```
2. **Kích hoạt & Đo đạc kích thước giao diện:** Tự động định kích thước màn hình test `tester.view.physicalSize = const Size(1280, 1600)` để đảm bảo mọi phần tử giao diện nằm trong viewport có thể cuộn và tương tác.
3. **Mô phỏng API Client linh hoạt:** Sử dụng `MockClient` của package `http/testing` để xử lý cả request GET tải thiết kế/đơn hàng, POST đặt đơn thành công, và giả lập mã lỗi HTTP 500 để kiểm tra luồng xử lý ngoại lệ.

### 3.2. Backend & Parser Automation (`PrintNfcSourceTest.java`)
1. **Tự động đo kích thước pixel ảnh PNG:**
   - Sử dụng `javax.imageio.ImageIO.read(new ByteArrayInputStream(pngBytes))` để xác nhận chính xác pixel dimensions của bản in A6 đạt 1240 x 1754 px và A5 đạt 1754 x 2480 px (tương ứng kích thước thực tế ở độ phân giải 300 DPI).
2. **Tự động quét và giải mã mã QR bằng ZXing Reader:**
   - Dùng `com.google.zxing.MultiFormatReader` quét trực tiếp trên luồng bitmap của ảnh PNG xuất ra, xác minh chuỗi URL giải mã được trỏ chính xác về trang khảo sát M1-01: `https://cxshield.vn/survey?qr=MC-B04`.
3. **Phân tích đối tượng PDF bằng Apache PDFBox 3.0.4:**
   - Dùng `org.apache.pdfbox.Loader.loadPDF(pdfBytes)` tải tài liệu PDF xuất từ `PrintExportService`.
   - Trích xuất `PDImageXObject` và kiểm tra bộ lọc `/Filter /DCTDecode`.
   - Gọi phương thức `xImage.getImage()` và bắt ngoại lệ `IIOException: Not a JPEG file` để tự động xác nhận lỗi cấu trúc luồng ảnh `BUG-SCRUM237-01`.
