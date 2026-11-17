# DANH SÁCH TEST CASES KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST CASES)

**Mã công việc:** SCRUM-239
**Tiêu đề:** [E5.3] Kiểm thử tự động xuất file in và đặt thẻ NFC
**Màn hình:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Tập tin kịch bản tự động:**
- Frontend: `frontend/test/d3_11_print_nfc_automation_test.dart`
- Backend: `backend/src/test/java/com/cxshield/backend/PrintNfcSourceTest.java`
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày thực hiện:** 17/11/2026
**Môi trường:** Flutter 3.38+ / Dart 3.10+ / Java 21 / Apache Maven / Apache PDFBox 3.0.4 / ZXing Core 3.5.3

---

## 1. BẢNG TỔNG HỢP AUTOMATION TEST CASES

| Mã TC | Phân nhóm kiểm thử | Tên ca kiểm thử tự động | Mức độ ưu tiên | Trạng thái |
|---|---|---|---|---|
| `AUTO-239-01` | Giao diện & Trạng thái | Tự động khởi tạo D3-11, tải mẫu in và hiển thị Live Preview đạt chuẩn in ấn | High | **PASS** |
| `AUTO-239-02` | Xuất file in ấn | Tự động kích hoạt luồng xuất ảnh PNG chuẩn 300 DPI và bắt URL tham số `format=png&dpi=300` | Critical | **PASS** |
| `AUTO-239-03` | Xuất file in ấn | Tự động kích hoạt luồng xuất file PDF chuẩn in ấn và bắt URL tham số `format=pdf&dpi=300` | High | **PASS** |
| `AUTO-239-04` | Đặt hàng thẻ NFC | Tự động chuyển đổi chất liệu thẻ Gỗ (45k) và Mica (35k), xác minh cập nhật đơn giá & tạm tính | High | **PASS** |
| `AUTO-239-05` | Đặt hàng thẻ NFC | Tự động điều chỉnh số lượng phôi thẻ (+/-), xác minh tổng tiền tính tức thì `unitPrice * quantity` | High | **PASS** |
| `AUTO-239-06` | Form Validation | Tự động kiểm tra Validation chặn gửi đơn khi để trống các trường bắt buộc | High | **PASS** |
| `AUTO-239-07` | Form Validation | Tự động kiểm tra Validation từ chối số điện thoại giao hàng sai cấu trúc viễn thông Việt Nam | Medium | **PASS** |
| `AUTO-239-08` | Form Validation | Tự động kiểm tra Validation từ chối địa chỉ giao hàng quá ngắn (dưới 5 ký tự) | Medium | **PASS** |
| `AUTO-239-09` | Luồng nghiệp vụ End-to-End | Tự động hoàn tất đặt hàng thành công, hiển thị AlertDialog và kiểm tra lưu đơn `PENDING` vào Lịch sử | Critical | **PASS** |
| `AUTO-239-10` | Xử lý lỗi & Ngoại lệ | Tự động xử lý lỗi kết nối khi API gửi đơn đặt thẻ thất bại, hiển thị SnackBar cảnh báo | Medium | **PASS** |
| `AUTO-239-11` | Cấu trúc file in PDF | Tái hiện xác nhận `BUG-SCRUM237-01` qua parser Apache PDFBox 3.0.4: stream khai báo `/Filter /DCTDecode` nhưng ghi PNG bytes | Critical | **FAIL** |

---

## 2. CHI TIẾT TỪNG TEST CASE TỰ ĐỘNG HÓA

### AUTO-239-01: Tự động khởi tạo D3-11, tải mẫu in và hiển thị Live Preview đạt chuẩn in ấn
- **Mục tiêu:** Kiểm tra quá trình tải màn hình D3-11, render thanh điều hướng 3 Tab, nạp mẫu thiết kế in ấn ban đầu và hiển thị huy hiệu chuẩn in ấn ≥ 300 DPI.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Khởi tạo `D311PrintNfcPage` với `SessionController` và `MockClient`.
  2. Bơm widget và chờ giao diện ổn định (`pumpAndSettle`).
  3. Kiểm tra sự xuất hiện của tiêu đề `D3-11 • Ấn phẩm QR / NFC`, badge `Chuẩn in ấn ≥ 300 DPI` và 3 tab chức năng.
  4. Kiểm tra Live Preview hiển thị tên thương hiệu `Maison Coffee & Bistro` và mã QR chi nhánh `MC-B04`.
- **Kết quả kỳ vọng:** Giao diện dựng chuẩn xác đầy đủ thành phần.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-02: Tự động kích hoạt luồng xuất ảnh PNG chuẩn 300 DPI và bắt URL tham số `format=png&dpi=300`
- **Mục tiêu:** Xác minh khi người dùng chọn định dạng ảnh PNG và bấm "Tải File In Ấn", hệ thống gọi đúng API backend với các tham số chất lượng in 300 DPI.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Tìm và tap vào Segment `PNG 300 DPI`.
  2. Tap nút `Tải File In Ấn`.
  3. Kiểm tra SnackBar xuất hiện: "Đang tải file ấn phẩm chuẩn in ấn (300 DPI, định dạng PNG)...".
  4. Xác minh đối tượng `MockUrlLauncher` bắt được URL chứa `format=png` và `dpi=300`.
- **Kết quả kỳ vọng:** URL được kích hoạt chính xác, thông báo phản hồi người dùng rõ ràng.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-03: Tự động kích hoạt luồng xuất file PDF chuẩn in ấn và bắt URL tham số `format=pdf&dpi=300`
- **Mục tiêu:** Xác minh khi chọn định dạng PDF Vector và bấm tải file, hệ thống kích hoạt URL xuất file PDF chuẩn in ấn.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Tìm và tap vào Segment `PDF Vector`.
  2. Tap nút `Tải File In Ấn`.
  3. Kiểm tra SnackBar xuất hiện: "Đang tải file ấn phẩm chuẩn in ấn (300 DPI, định dạng PDF)...".
  4. Xác minh `MockUrlLauncher` bắt được URL chứa `format=pdf` và `dpi=300`.
- **Kết quả kỳ vọng:** Bắt đúng query parameter định dạng PDF và độ phân giải 300 DPI.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-04: Tự động chuyển đổi chất liệu thẻ Gỗ (45k) và Mica (35k), xác minh cập nhật đơn giá & tạm tính
- **Mục tiêu:** Kiểm tra phản hồi chuyển đổi chất liệu phôi thẻ NFC trên giao diện, tính đúng đơn giá niêm yết cho 10 thẻ mặc định.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Tap chuyển sang Tab `Đặt phôi thẻ NFC vật lý`.
  2. Kiểm tra Thẻ Gỗ Walnut hiển thị mặc định: `450.000 đ` (10 thẻ x 45.000 đ).
  3. Tap chuyển sang `Thẻ Mica Acrylic trong suốt`.
  4. Xác minh tổng tiền tạm tính cập nhật tức thời thành `350.000 đ` (10 thẻ x 35.000 đ).
- **Kết quả kỳ vọng:** Dữ liệu tính toán phản ứng tức thì không có độ trễ.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-05: Tự động điều chỉnh số lượng phôi thẻ (+/-), xác minh tổng tiền tính tức thì `unitPrice * quantity`
- **Mục tiêu:** Xác minh tính năng tăng giảm số lượng phôi thẻ cập nhật đúng tổng tiền theo công thức số học.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Mở Tab Đặt thẻ NFC (đang chọn Thẻ Gỗ 45.000 đ).
  2. Tap nút (+) 2 lần để tăng số lượng từ 10 lên 12 thẻ.
  3. Kiểm tra ô số lượng hiển thị `12` và tạm tính là `540.000 đ` (12 x 45k).
  4. Tap nút (-) 1 lần để giảm về 11 thẻ.
  5. Kiểm tra ô số lượng hiển thị `11` và tạm tính là `495.000 đ` (11 x 45k).
- **Kết quả kỳ vọng:** Tổng tiền tự động tính lại chuẩn xác theo đơn giá nhân với số lượng.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-06: Tự động kiểm tra Validation chặn gửi đơn khi để trống các trường bắt buộc
- **Mục tiêu:** Đảm bảo hệ thống chặn gửi đơn đặt hàng nếu người dùng chưa nhập họ tên, số điện thoại hoặc địa chỉ.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Vào Tab Đặt thẻ NFC, giữ nguyên các ô input để trống.
  2. Tap nút `Gửi Đơn Đặt Mua Phôi Thẻ NFC`.
  3. Kiểm tra sự xuất hiện của cả 3 câu thông báo lỗi:
     - `Vui lòng nhập họ và tên người nhận`
     - `Vui lòng nhập số điện thoại nhận hàng`
     - `Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)`
- **Kết quả kỳ vọng:** Không gửi request POST, hiển thị thông báo đỏ dưới từng ô nhập.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-07: Tự động kiểm tra Validation từ chối số điện thoại giao hàng sai cấu trúc viễn thông Việt Nam
- **Mục tiêu:** Xác minh regex kiểm tra số điện thoại từ chối các số sai quy chuẩn viễn thông Việt Nam.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Nhập số điện thoại `012345678` (sai đầu số và thiếu ký tự).
  2. Tap nút `Gửi Đơn Đặt Mua Phôi Thẻ NFC`.
  3. Kiểm tra thông báo lỗi xuất hiện: `Số điện thoại không đúng định dạng Việt Nam`.
- **Kết quả kỳ vọng:** Chặn gửi đơn thành công.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-08: Tự động kiểm tra Validation từ chối địa chỉ giao hàng quá ngắn (dưới 5 ký tự)
- **Mục tiêu:** Ngăn chặn việc nhập địa chỉ nhận hàng sơ sài không đủ để đơn vị vận chuyển giao phôi thẻ.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Nhập địa chỉ: `HN`.
  2. Tap nút `Gửi Đơn Đặt Mua Phôi Thẻ NFC`.
  3. Kiểm tra thông báo lỗi: `Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)`.
- **Kết quả kỳ vọng:** Form invalid, không gửi đơn.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-09: Tự động hoàn tất đặt hàng thành công, hiển thị AlertDialog và kiểm tra lưu đơn `PENDING` vào Lịch sử
- **Mục tiêu:** Kiểm tra luồng đặt thẻ hoàn chỉnh khi điền đầy đủ thông tin hợp lệ: gọi API POST, nhận response, hiển thị AlertDialog xác nhận và chuyển sang danh sách lịch sử với trạng thái khởi tạo `PENDING` ("Mới tiếp nhận").
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Điền họ tên `Nguyễn Văn Chủ Mới`, SĐT `0909999888`, địa chỉ `999 Lê Duẩn, Bến Nghé, Quận 1, TP. HCM`.
  2. Tap nút gửi đơn.
  3. Xác minh hiển thị popup `Đặt hàng thành công!`, mã đơn hàng `a1b2c3d4`, tổng tiền `450.000 đ`.
  4. Tap nút `Xem lịch sử đơn`.
  5. Xác minh hiển thị trong tab Lịch sử đơn hàng: tên người nhận, số điện thoại, và trạng thái `Mới tiếp nhận` (`PENDING`).
- **Kết quả kỳ vọng:** Đơn hàng được tạo và lưu trữ đúng trạng thái ban đầu `PENDING`.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-10: Tự động xử lý lỗi kết nối khi API gửi đơn đặt thẻ thất bại, hiển thị SnackBar cảnh báo
- **Mục tiêu:** Đảm bảo hệ thống bắt lỗi an toàn và hiển thị cảnh báo cho người dùng khi backend trả về lỗi HTTP 500 hoặc rớt mạng.
- **Tập tin kịch bản:** `frontend/test/d3_11_print_nfc_automation_test.dart`
- **Các bước tự động:**
  1. Mock API POST `/api/v1/nfc-orders` trả về mã lỗi 500 kèm thông điệp `Lỗi máy chủ kết nối kho`.
  2. Nhập thông tin form hợp lệ và bấm gửi đơn.
  3. Kiểm tra xuất hiện thông báo SnackBar lỗi: `Lỗi khi gửi đơn hàng`.
- **Kết quả kỳ vọng:** Ứng dụng không bị crash, hiển thị SnackBar thông báo rõ ràng.
- **Kết quả thực tế:** **PASS**.

---

### AUTO-239-11: Tái hiện xác nhận `BUG-SCRUM237-01` qua parser Apache PDFBox 3.0.4: stream khai báo `/Filter /DCTDecode` nhưng ghi PNG bytes
- **Mục tiêu:** Kiểm tra tính toàn vẹn cấu trúc dữ liệu của file PDF xuất ra bằng bộ parser chuẩn công nghiệp Apache PDFBox 3.0.4.
- **Tập tin kịch bản:** `backend/src/test/java/com/cxshield/backend/PrintNfcSourceTest.java` (Method: `testExportPdfEmbeddedStreamDctDecodeDiscrepancy`)
- **Các bước tự động:**
  1. Gọi endpoint `GET /api/v1/print-designs/{id}/export?format=pdf&dpi=300`.
  2. Nạp luồng bytes trả về vào `org.apache.pdfbox.Loader.loadPDF(pdfBytes)`.
  3. Lấy đối tượng `PDImageXObject` từ trang đầu tiên của tài liệu PDF.
  4. Kiểm tra khai báo bộ lọc: `assertEquals("DCTDecode", xImage.getCOSObject().getNameAsString(COSName.FILTER))` $\rightarrow$ Khai báo DCTDecode (dành riêng cho ảnh JPEG).
  5. Gọi hàm giải mã `xImage.getImage()`.
- **Kết quả kỳ vọng của hệ thống hoàn thiện:** File PDF mở được và hiển thị hình ảnh bản in bình thường (PASS).
- **Kết quả thực tế:** Bộ giải mã ImageIO của PDFBox ném ngoại lệ: `javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11` do luồng byte bên trong thực chất là ảnh PNG (`‰PNG`).
- **Trạng thái:** **FAIL** (Tái hiện xác nhận lỗi `BUG-SCRUM237-01`).
