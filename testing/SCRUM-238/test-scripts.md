# KỊCH BẢN KIỂM THỬ TỰ ĐỘNG (TEST SCRIPTS)

**Mã công việc:** SCRUM-238
**Tiêu đề:** [E5.3] Kiểm thử chức năng xuất file in và đặt thẻ NFC
**Màn hình:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Task code đối ứng:** SCRUM-214 (Commit `b819682` trên `main`)
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày cập nhật:** 17/11/2026

---

## 1. CẤU TRÚC TEST SUITE LIÊN QUAN

```text
CX-SHIELD/
├── frontend/
│   ├── lib/
│   │   ├── pages/d3_11_print_nfc_page.dart         # Giao diện chức năng D3-11 (3 Tabs)
│   │   ├── services/print_nfc_service.dart         # Service gọi API xuất file in & đặt thẻ
│   │   └── models/print_nfc_models.dart            # Model dữ liệu (PrintDesign, NfcOrder)
│   └── test/
│       ├── d3_11_print_nfc_functional_test.dart    # Bộ Functional Test mới cho SCRUM-238 (10 tests)
│       └── d3_11_print_nfc_test.dart               # Bộ Widget Test cơ bản SCRUM-214 (4 tests)
├── backend/
│   ├── src/main/java/com/cxshield/backend/
│   │   ├── service/PrintExportService.java         # Service tạo file xuất PNG và PDF 300 DPI
│   │   └── service/NfcOrderService.java            # Service xử lý đơn hàng phôi thẻ NFC
│   └── src/test/java/com/cxshield/backend/
│       └── PrintNfcSourceTest.java                 # Unit Test backend SCRUM-237 (28 tests)
└── testing/
    └── SCRUM-238/
        ├── test-cases.md                           # Danh sách 14 Test Cases chi tiết
        ├── test-scripts.md                         # Tài liệu kịch bản & lệnh chạy test
        ├── test-report.md                          # Báo cáo tổng kết thực thi kiểm thử
        └── bug-reports.md                          # Báo cáo lỗi & quan sát chi tiết
```

---

## 2. HƯỚNG DẪN LỆNH THỰC THI KIỂM THỬ

### 2.1. Chạy bộ kiểm thử chức năng Frontend (Flutter Widget & Functional Tests)

Di chuyển vào thư mục `frontend` và thực thi:

```powershell
# Chạy riêng bộ kiểm thử chức năng SCRUM-238
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/d3_11_print_nfc_functional_test.dart

# Chạy toàn bộ test liên quan đến màn hình D3-11 (Hồi quy Frontend)
flutter test test/d3_11_print_nfc_test.dart test/d3_11_print_nfc_functional_test.dart
```

**Kết quả kỳ vọng:**
```text
00:11 +14: All tests passed!
```

---

### 2.2. Chạy bộ kiểm thử Backend đối ứng (Maven & JUnit 5)

Di chuyển vào thư mục `backend` và thực thi:

```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
mvn test "-Dtest=PrintNfcSourceTest"
```

**Kết quả kỳ vọng:**
```text
[INFO] Running com.cxshield.backend.PrintNfcSourceTest
[INFO] Tests run: 28, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 5.358 s
[INFO] BUILD SUCCESS
```

---

## 3. THIẾT KẾ KỊCH BẢN KIỂM THỬ TỰ ĐỘNG CHỨC NĂNG

Bộ kiểm thử `d3_11_print_nfc_functional_test.dart` được xây dựng với các cơ chế kỹ thuật trọng tâm:

### 3.1. Giả lập Nền tảng URL Launcher (`UrlLauncherPlatform`)
Nhằm kiểm tra việc tải file PNG và PDF chuẩn 300 DPI mà không phụ thuộc vào trình duyệt web thật của hệ điều hành:

```dart
class MockUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? launchedUrl;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    return true;
  }
}
```

### 3.2. Mock Service Phân tầng (`MockPrintNfcService`)
Hỗ trợ kiểm thử các tình huống: nạp danh sách thiết kế sẵn có, đặt hàng phôi thẻ NFC thành công (lưu vào bộ nhớ mock và chuyển trạng thái `PENDING`), và giả lập ném Exception để kiểm tra luồng xử lý lỗi:

```dart
class MockPrintNfcService extends PrintNfcService {
  bool shouldFail = false;
  final List<NfcOrder> savedOrders = [];

  @override
  Future<NfcOrder> createNfcOrder({
    required String designId,
    required String cardType,
    required int quantity,
    required String shipName,
    required String shipPhone,
    required String shipAddress,
    String? note,
  }) async {
    if (shouldFail) {
      throw Exception('Lỗi kết nối máy chủ');
    }
    final order = NfcOrder(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      businessId: 'mock-biz',
      designId: designId,
      cardType: cardType,
      quantity: quantity,
      unitPrice: cardType == 'WOOD' ? 45000 : 35000,
      totalAmount: (cardType == 'WOOD' ? 45000 : 35000) * quantity,
      shipName: shipName,
      shipPhone: shipPhone,
      shipAddress: shipAddress,
      note: note,
      status: 'PENDING',
      createdAt: DateTime.now().toIso8601String(),
    );
    savedOrders.add(order);
    return order;
  }
}
```

### 3.3. Các ca kiểm thử tự động chính đã cài đặt

1. **TC-238-01:** Mở D3-11, kiểm tra 3 Tab, xem chi tiết Live Preview A6 và CTA.
2. **TC-238-02:** Chọn định dạng PNG, bấm tải file in, kiểm tra SnackBar "300 DPI" và URL `format=png&dpi=300`.
3. **TC-238-06:** Chọn Tab Đặt thẻ NFC, đổi loại thẻ giữa Gỗ (45k) và Mica (35k), đối chiếu giá hiển thị.
4. **TC-238-07:** Tăng giảm số lượng thẻ bằng widget nút bấm (+/-), kiểm tra tổng tiền tự động tính lại.
5. **TC-238-08:** Để trống thông tin form, bấm Xác nhận, kiểm tra 3 thông báo lỗi validation bắt buộc.
6. **TC-238-09:** Nhập số điện thoại sai định dạng viễn thông Việt Nam (`12345678`), kiểm tra thông báo từ chối.
7. **TC-238-10:** Nhập địa chỉ dưới 5 ký tự (`HN`), kiểm tra thông báo yêu cầu địa chỉ chi tiết hơn.
8. **TC-238-11:** Nhập thông tin đầy đủ, đặt hàng thành công, kiểm tra AlertDialog và hiển thị trong danh sách Lịch sử đơn với trạng thái `PENDING`.
9. **TC-238-12:** Bật cờ `shouldFail = true`, gửi đơn đặt thẻ, kiểm tra SnackBar hiển thị thông báo lỗi màu đỏ.
