# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG (FUNCTIONAL TEST REPORT)

**Mã công việc:** SCRUM-238
**Tiêu đề:** [E5.3] Kiểm thử chức năng xuất file in và đặt thẻ NFC
**Màn hình kiểm thử:** Màn hình D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Task code đối ứng:** SCRUM-214 (Commit `b819682` trên nhánh `main`)
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày thực hiện:** 17/11/2026
**Môi trường kiểm thử:** Flutter 3.38+ / Dart 3.10+ / Java 21 / Maven 3.8+ / ZXing Core 3.5.3 / Apache PDFBox 3.0.4

---

## 1. TỔNG QUAN KẾT QUẢ KIỂM THỬ

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Ghi chú |
|---|---|---|---|
| **Tổng số Test Cases thiết kế** | **14** | **100%** | Bao phủ đầy đủ phạm vi chức năng D3-11 |
| **• PASS** | **11** | **78.57%** | Các luồng chức năng, UI, Live Preview, tính giá, validation form hoạt động tốt |
| **• FAIL** | **1** | **7.14%** | Tái hiện xác nhận lại `BUG-SCRUM237-01` (PDF stream DCTDecode lỗi font/byte) |
| **• BLOCKED** | **0** | **0%** | Không có test case nào bị tắc nghẽn |
| **• NOT RUN** | **2** | **14.29%** | In giấy vật lý và quét bằng camera điện thoại thật ngoài đời (giới hạn thiết bị phần cứng) |

### Thống kê thực thi Automated Tests
- **Bộ Functional Test mới cho màn D3-11 (`d3_11_print_nfc_functional_test.dart`):**
  - **10/10 tests passed (100%)**
- **Bộ Widget Test hồi quy Frontend (`d3_11_print_nfc_test.dart`):**
  - **4/4 tests passed (100%)**
- **Bộ Unit Test hồi quy Backend (`PrintNfcSourceTest.java`):**
  - **28/28 tests passed (100%)**
- **Tổng số Automated Tests thực thi thành công:** **42/42 tests passed** (100% BUILD SUCCESS).

---

## 2. KẾT QUẢ CHI TIẾT TỪNG TEST CASE

| Mã TC | Phân loại | Tên ca kiểm thử | Kết quả | Chi tiết kết quả thực tế |
|---|---|---|---|---|
| `TC-238-01` | Giao diện | Mở D3-11, hiển thị 3 Tab và Live Preview bản in | **PASS** | Hiển thị chuẩn xác 3 Tab, khung Live Preview A6, mã chi nhánh MC-B04 và CTA |
| `TC-238-02` | Xuất file | Tải file in định dạng PNG chuẩn 300 DPI | **PASS** | Kích hoạt URL `format=png&dpi=300`, hiển thị SnackBar xác nhận tải 300 DPI |
| `TC-238-03` | Xuất file | Kích thước PNG 1240x1754 px và giải mã QR bằng ZXing | **PASS** | Kích thước ảnh xuất ra đạt đúng 1240x1754 px (A6 300 DPI); ZXing giải mã đúng `https://cxshield.vn/survey?qr=MC-B04` |
| `TC-238-04` | Xuất file | Tải file in định dạng PDF chuẩn 300 DPI | **PASS** | Kích hoạt URL `format=pdf&dpi=300`, SnackBar thông báo tải file PDF 300 DPI |
| `TC-238-05` | Xuất file | Tái hiện BUG-SCRUM237-01 khi mở PDF trên PDFBox | **FAIL** | Xác nhận lỗi: Header `/Filter /DCTDecode` nhưng ghi PNG bytes, PDFBox ném `IIOException: Not a JPEG file` |
| `TC-238-06` | Đặt thẻ | Chọn Thẻ Gỗ Walnut (45k) và Thẻ Mica Acrylic (35k) | **PASS** | Giao diện cập nhật tức thì đơn giá 45.000 đ và 35.000 đ, tạm tính đúng số tiền |
| `TC-238-07` | Đặt thẻ | Tăng giảm số lượng phôi thẻ tính đúng tổng tiền | **PASS** | Tăng/giảm số lượng cập nhật chính xác (`unitPrice * quantity`), không cho giảm dưới 1 |
| `TC-238-08` | Validation | Chặn gửi đơn khi để trống tên, SĐT, địa chỉ | **PASS** | Kích hoạt form validation, hiển thị đủ 3 thông báo lỗi màu đỏ tại từng trường |
| `TC-238-09` | Validation | Chặn gửi đơn khi SĐT sai định dạng Việt Nam | **PASS** | Regex từ chối các số `12345678`, `0281234567`; chấp nhận đầu số di động chuẩn |
| `TC-238-10` | Validation | Chặn gửi đơn khi địa chỉ nhận hàng dưới 5 ký tự | **PASS** | Báo lỗi "Địa chỉ quá ngắn (tối thiểu 5 ký tự)" khi nhập địa chỉ không hợp lệ |
| `TC-238-11` | Đặt thẻ | Gửi đơn hợp lệ thành công và xem trong Lịch sử đơn | **PASS** | Tạo đơn thành công, popup AlertDialog hiển thị đúng, đơn được ghi nhận trạng thái `PENDING` ("Mới tiếp nhận") |
| `TC-238-12` | Xử lý lỗi | Xử lý lỗi khi API gửi đơn thất bại | **PASS** | Try-catch bắt exception, hiển thị SnackBar cảnh báo lỗi màu đỏ cho người dùng |
| `TC-238-13` | Giới hạn | In ấn bản cứng ra giấy bằng máy in vật lý | **NOT RUN** | Không có thiết bị máy in phần cứng kết nối trong môi trường kiểm thử CI/Server |
| `TC-238-14` | Giới hạn | Quét mã QR trên bản in bằng camera điện thoại thật | **NOT RUN** | Không có camera quang học và điện thoại vật lý; đã xác minh tự động bằng ZXing reader (TC-238-03) |

---

## 3. TỔNG HỢP LỖI VÀ QUAN SÁT (BUGS & OBSERVATIONS)

1. **BUG-SCRUM237-01 (Mức độ: Medium - TÁI HIỆN XÁC NHẬN TẠI TC-238-05):**
   - **Vấn đề:** Khi xuất file PDF tại endpoint `GET /api/v1/print-designs/{id}/export?format=pdf`, file PDF sinh ra khai báo đối tượng hình ảnh mang bộ lọc `/Filter /DCTDecode` (bộ lọc chuẩn của ảnh JPEG), nhưng dữ liệu nhị phân bên trong luồng (`stream`) lại là mã nhị phân của ảnh PNG (`‰PNG`).
   - **Tác động:** Khi người dùng mở file bằng các phần mềm xem PDF tiêu chuẩn công nghiệp (Adobe Acrobat Reader, Apache PDFBox, Ghostscript), trang in sẽ bị lỗi không hiển thị hình ảnh hoặc ứng dụng báo file PDF bị lỗi cấu trúc dữ liệu (`IIOException: Not a JPEG file`).
   - **Giải pháp khuyến nghị:** Trong `PrintExportService.java`, nếu nhúng ảnh PNG cần đổi bộ lọc sang `/Filter /FlateDecode` hoặc nén lại luồng ảnh thành định dạng JPEG trước khi nhúng với `/DCTDecode`.

2. **Dẫn chiếu các lỗi bảo mật phát hiện từ SCRUM-237 (Tác động tới nghiệp vụ D3-11):**
   - **BUG-SCRUM237-02 (High):** Rò rỉ dữ liệu đa cơ sở (Multi-tenant Leakage) tại API lấy danh sách đơn đặt thẻ `GET /api/v1/nfc-orders` khi `businessId` bị null.
   - **BUG-SCRUM237-03 (High):** Lỗ hổng IDOR trên API tra cứu đơn hàng `GET /api/v1/nfc-orders/{id}` và xuất file `GET /api/v1/print-designs/{id}/export`, thiếu xác thực quyền sở hữu theo token đăng nhập.
   - **OBS-SCRUM237-01 (Low):** File PNG xuất ra đạt chuẩn 300 DPI theo pixel dimension (1240x1754 px) nhưng chưa nhúng metadata chunk `pHYs`.

---

## 4. GIỚI HẠN KIỂM THỬ THỰC TẾ (TEST LIMITATIONS)

1. **In giấy vật lý ra máy in (`TC-238-13 - NOT RUN`):** Môi trường thực thi là máy tính lập trình và server CI, không kết nối thiết bị máy in màu phần cứng. Không thể đánh giá độ sai lệch màu in CMYK so với RGB hiển thị trên màn hình.
2. **Quét QR bằng camera điện thoại thật ngoài đời (`TC-238-14 - NOT RUN`):** Không có thiết bị điện thoại thật với cảm biến quang học trong pipeline tự động. Đã thay thế bằng việc kiểm tra giải mã ma trận QR kỹ thuật số tự động bằng thư viện ZXing Core với kết quả chính xác 100%.
3. **Mã hóa chip NFC (NFC Chip Encoding):** Kiểm thử đã xác nhận luồng đặt đơn hàng và lưu trữ thông tin ghi thẻ vào CSDL (`nfc_orders`), công đoạn nạp dữ liệu URL vật lý vào chip NFC NTAG213/NTAG215 và giao vận cần được kiểm tra khi đơn vị sản xuất bàn giao phôi thẻ thực tế.
