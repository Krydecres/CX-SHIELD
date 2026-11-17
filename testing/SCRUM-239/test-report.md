# BÁO CÁO KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (AUTOMATION TEST REPORT)

**Mã công việc:** SCRUM-239
**Tiêu đề:** [E5.3] Kiểm thử tự động xuất file in và đặt thẻ NFC
**Màn hình kiểm thử:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Task code đối ứng:** SCRUM-214 (Commit `b819682` trên nhánh `main`)
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày thực hiện:** 17/11/2026
**Môi trường:** Flutter 3.38+ / Dart 3.10+ / Java 21 / Apache Maven 3.8+ / Apache PDFBox 3.0.4 / ZXing Core 3.5.3

---

## 1. TỔNG QUAN KẾT QUẢ KIỂM THỬ

| Chỉ số kiểm thử | Số lượng | Tỷ lệ (%) | Ghi chú |
|---|---|---|---|
| **Tổng số Test Cases thiết kế** | **11** | **100%** | Bao phủ các luồng tự động hóa trọng tâm D3-11 |
| **• PASS** | **10** | **90.91%** | Các luồng automation UI, validation, tính giá, tải file và bắt URL hoạt động tốt |
| **• FAIL** | **1** | **9.09%** | `AUTO-239-11` (Tái hiện xác nhận `BUG-SCRUM237-01` qua parser PDFBox) |
| **• BLOCKED** | **0** | **0%** | Không có ca kiểm thử nào bị chặn |
| **• NOT RUN** | **0** | **0%** | Chạy đầy đủ 100% test cases trong bộ kiểm thử CI |

---

### Thống kê thực thi Automated Test Runners

| Tên Test Suite / Runner | Số tests chạy | Kết quả | Ghi chú |
|---|---|---|---|
| `d3_11_print_nfc_automation_test.dart` | **10** | **10/10 PASS** | Kịch bản Automation mới cho SCRUM-239 |
| `d3_11_print_nfc_functional_test.dart` | **10** | **10/10 PASS** | Hồi quy Functional Tests SCRUM-238 |
| `d3_11_print_nfc_test.dart` | **4** | **4/4 PASS** | Hồi quy Widget Tests cơ sở SCRUM-214 |
| **Tổng Frontend Runners:** | **24** | **24/24 PASS** | **100% Passed (0 failures)** |
| `PrintNfcSourceTest.java` (Backend) | **28** | **28/28 PASS** | Hồi quy Backend + PDFBox 3.0.4 + ZXing |
| **TỔNG CỘNG AUTOMATED TESTS:** | **52** | **52/52 PASS** | **BUILD SUCCESS** |

---

## 2. KẾT QUẢ CHI TIẾT TỪNG TEST CASE TỰ ĐỘNG

| Mã TC | Phân loại | Tên ca kiểm thử | Kết quả | Chi tiết kết quả thực tế |
|---|---|---|---|---|
| `AUTO-239-01` | UI & State | Khởi tạo D3-11, Live Preview chuẩn in ấn | **PASS** | Hiển thị 3 tab, Live Preview A6, badge in ấn ≥ 300 DPI, tên thương hiệu và mã QR |
| `AUTO-239-02` | Xuất file in | Xuất PNG 300 DPI, bắt URL tham số | **PASS** | Kích hoạt URL `format=png&dpi=300`, SnackBar hiển thị thông báo tải 300 DPI |
| `AUTO-239-03` | Xuất file in | Xuất PDF chuẩn in, bắt URL tham số | **PASS** | Kích hoạt URL `format=pdf&dpi=300`, SnackBar hiển thị thông báo tải file PDF |
| `AUTO-239-04` | Đặt thẻ NFC | Đổi thẻ Gỗ (45k) và Mica (35k), tính đơn giá | **PASS** | UI cập nhật tức thì đơn giá 45.000 đ và 35.000 đ, tạm tính đúng số tiền tương ứng |
| `AUTO-239-05` | Đặt thẻ NFC | Tăng giảm số lượng thẻ (+/-), tính tổng tiền | **PASS** | Nút +/- cập nhật đúng số lượng và công thức `unitPrice * quantity` |
| `AUTO-239-06` | Validation | Chặn gửi đơn khi để trống trường bắt buộc | **PASS** | Form validation chặn submit, hiển thị 3 thông báo lỗi màu đỏ tại từng trường |
| `AUTO-239-07` | Validation | Từ chối SĐT giao hàng sai cấu trúc VN | **PASS** | Regex từ chối số sai cấu trúc (`012345678`), yêu cầu SĐT di động Việt Nam chuẩn |
| `AUTO-239-08` | Validation | Từ chối địa chỉ giao hàng dưới 5 ký tự | **PASS** | Chặn submit khi nhập địa chỉ quá ngắn (`HN`), yêu cầu tối thiểu 5 ký tự |
| `AUTO-239-09` | E2E Flow | Đặt thẻ hợp lệ thành công, lưu đơn PENDING | **PASS** | AlertDialog chúc mừng hiển thị mã đơn, đơn được lưu vào Lịch sử với trạng thái `PENDING` ("Mới tiếp nhận") |
| `AUTO-239-10` | Ngoại lệ | Xử lý lỗi API gửi đơn đặt thẻ thất bại | **PASS** | Bắt lỗi HTTP 500 an toàn, hiển thị SnackBar cảnh báo lỗi màu đỏ |
| `AUTO-239-11` | Cấu trúc file | Tái hiện BUG-SCRUM237-01 qua Apache PDFBox | **FAIL** | Xác nhận lỗi: Header `/Filter /DCTDecode` nhưng ghi bytes PNG, PDFBox ném `IIOException: Not a JPEG file` |

---

## 3. TỔNG HỢP LỖI VÀ QUAN SÁT (BUGS & OBSERVATIONS)

1. **`BUG-SCRUM237-01` (Mức độ: Medium - TÁI HIỆN XÁC NHẬN TẠI `AUTO-239-11`):**
   - **Vấn đề:** File PDF xuất từ backend `PrintExportService.java` (L222) khai báo bộ lọc nén `/Filter /DCTDecode` nhưng nhúng dữ liệu byte định dạng ảnh PNG (`‰PNG`).
   - **Xác minh thực tế:** Thư viện Apache PDFBox 3.0.4 khi phân tích luồng ảnh qua lệnh `xImage.getImage()` đã ném ngoại lệ `javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11`.
   - **Tác động:** File PDF in ấn không đạt chuẩn ISO 32000-1; có thể gây lỗi trang trắng hoặc máy in công nghiệp từ chối in.
   - **Khuyến nghị khắc phục:** Thay đổi khai báo `/Filter /DCTDecode` thành `/Filter /FlateDecode` hoặc chuyển đổi byte ảnh thành JPEG trước khi nhúng.

2. **Dẫn chiếu các lỗi bảo mật phát hiện từ SCRUM-237 (Liên quan đến API của D3-11):**
   - **`BUG-SCRUM237-02` (High):** Rò rỉ dữ liệu đa cơ sở (Multi-tenant Leakage) tại API lấy danh sách đơn thẻ `GET /api/v1/nfc-orders` khi thiếu param `businessId`.
   - **`BUG-SCRUM237-03` (High):** Lỗ hổng IDOR trên API tra cứu đơn hàng và xuất ấn phẩm theo ID.
   - **`OBS-SCRUM237-01` (Low):** File PNG 300 DPI chưa có chunk metadata `pHYs`.
   - **`OBS-SCRUM238-01` (Low - UI/UX):** Khung Live Preview chiếm diện tích lớn trên màn hình chiều cao hẹp, cần cuộn chuột để nhấn nút tải file in.

---

## 4. MỨC ĐỘ KIỂM THỬ THỰC TẾ VS MOCK

1. **Phần đã được kiểm chứng bằng Parser / Engine thật:**
   - **Đo kích thước ảnh PNG:** Kiểm chứng bằng thư viện `javax.imageio.ImageIO`, xác nhận bản in A6 đạt chính xác 1240 x 1754 px và A5 đạt 1754 x 2480 px (chuẩn 300 DPI).
   - **Giải mã mã QR:** Kiểm chứng bằng thư viện `com.google.zxing.MultiFormatReader`, giải mã thành công URL khảo sát chi nhánh `https://cxshield.vn/survey?qr=MC-B04`.
   - **Phân tích cấu trúc file PDF:** Phân tích trực tiếp bằng `org.apache.pdfbox.Loader`, bóc tách `PDImageXObject` và xác minh ngoại lệ giải mã luồng ảnh.
2. **Phần kiểm thử qua Mock Service & Platform:**
   - **Giao diện D3-11:** Chạy trên môi trường headless widget test sử dụng `MockClient` và `MockUrlLauncher`.
   - **Trạng thái `PENDING`:** Được đọc từ dữ liệu giả lập (Mock/In-Memory), **chưa kết nối CSDL Supabase PostgreSQL Live**.
3. **Phần cứng ngoại vi (In ấn giấy & Camera điện thoại thật):**
   - Không đưa vào pipeline automation CI do môi trường server không có thiết bị máy in và camera quang học vật lý.
