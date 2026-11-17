# DANH SÁCH TEST CASES KIỂM THỬ CHỨC NĂNG D3-11

**Mã công việc:** SCRUM-238
**Tiêu đề:** [E5.3] Kiểm thử chức năng xuất file in và đặt thẻ NFC
**Màn hình:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136 ([E5.3] Xuất file in ấn chất lượng cao & đặt hàng phôi thẻ NFC vật lý)
**Task code đối ứng:** SCRUM-214 (Đã hoàn thành và merge vào `main` tại commit `b819682`)
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày thực hiện:** 17/11/2026

---

## BẢNG TỔNG HỢP TEST CASES

| Mã TC | Phân loại | Tiêu đề Test Case | Mức độ ưu tiên | Trạng thái |
|---|---|---|---|---|
| `TC-238-01` | Giao diện | Mở màn hình D3-11, hiển thị đầy đủ 3 Tab và Live Preview bản in mặc định | High | **PASS** |
| `TC-238-02` | Xuất file in | Chọn định dạng PNG và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI | High | **PASS** |
| `TC-238-03` | Xuất file in | Tải file PNG kiểm tra kích thước 1240x1754 px và quét QR bằng ZXing Reader trỏ đúng URL | Critical | **PASS** |
| `TC-238-04` | Xuất file in | Chọn định dạng PDF và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI | High | **PASS** |
| `TC-238-05` | Xuất file in | Rà soát tái hiện BUG-SCRUM237-01 khi mở file PDF trên PDF parser chuẩn mực | High | **FAIL** |
| `TC-238-06` | Đặt thẻ NFC | Chọn loại thẻ Gỗ Walnut (45.000 đ) và Thẻ Mica Acrylic (35.000 đ) cập nhật đơn giá và tạm tính | High | **PASS** |
| `TC-238-07` | Đặt thẻ NFC | Điều chỉnh tăng/giảm số lượng phôi thẻ tính đúng tổng tiền (`unitPrice * quantity`) | High | **PASS** |
| `TC-238-08` | Validation | Chặn gửi đơn đặt phôi thẻ NFC khi để trống họ tên, số điện thoại và địa chỉ nhận hàng | High | **PASS** |
| `TC-238-09` | Validation | Chặn gửi đơn khi số điện thoại giao hàng sai quy chuẩn đầu số viễn thông Việt Nam | Medium | **PASS** |
| `TC-238-10` | Validation | Chặn gửi đơn khi địa chỉ nhận hàng quá ngắn (dưới 5 ký tự) | Medium | **PASS** |
| `TC-238-11` | Đặt thẻ NFC | Gửi đơn đặt phôi thẻ NFC hợp lệ thành công, hiển thị AlertDialog và nạp vào Lịch sử đơn (`PENDING`) | Critical | **PASS** |
| `TC-238-12` | Xử lý lỗi | Xử lý lỗi khi API gửi đơn đặt thẻ NFC thất bại hiển thị SnackBar cảnh báo lỗi | Medium | **PASS** |
| `TC-238-13` | Giới hạn | In ấn bản cứng ra giấy bằng máy in vật lý | Medium | **NOT RUN** |
| `TC-238-14` | Giới hạn | Quét mã QR trên bản in vật lý bằng camera điện thoại thật ngoài đời | Medium | **NOT RUN** |

---

## CHI TIẾT TỪNG TEST CASE

### TC-238-01: Mở màn hình D3-11, hiển thị đầy đủ 3 Tab và Live Preview bản in mặc định
- **Phân loại:** Giao diện & Hiển thị
- **Mức độ ưu tiên:** High
- **Tiền điều kiện (Preconditions):**
  - Người dùng đăng nhập tài khoản Merchant/Quản lý chi nhánh.
  - Có ít nhất một mẫu thiết kế QR đã lưu (mặc định Mock: Standee để bàn A6, Chi nhánh Trung Tâm).
- **Các bước thực hiện:**
  1. Điều hướng đến tuyến đường `/print-nfc` (màn hình D3-11).
  2. Quan sát thanh tiêu đề AppBar và danh sách TabBar.
  3. Kiểm tra nội dung Tab đầu tiên "Xuất file in ấn" và khung Live Preview.
- **Kết quả kỳ vọng:**
  - Tiêu đề màn hình hiển thị: "Xuất file in & Đặt thẻ NFC".
  - Hiển thị đầy đủ 3 Tab: "Xuất file in ấn", "Đặt thẻ NFC", "Lịch sử đơn".
  - Live Preview hiển thị đầy đủ: Khung preview bản in, Chip định dạng A6 (105 x 148 mm), mã chi nhánh `MC-B04`, CTA "Quét mã để đánh giá dịch vụ" và ảnh mã QR.
- **Kết quả thực tế:** Giao diện tải đầy đủ, đúng màu sắc và bố cục thương hiệu CX-Shield.
- **Trạng thái:** **PASS**

---

### TC-238-02: Chọn định dạng PNG và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI
- **Phân loại:** Xuất file in ấn
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** Đang ở màn hình D3-11, Tab "Xuất file in ấn".
- **Các bước thực hiện:**
  1. Chọn Radio/Segment định dạng "PNG (Ảnh độ nét cao 300 DPI)".
  2. Bấm nút "Tải file in ấn (PNG)".
- **Kết quả kỳ vọng:**
  - Hệ thống kích hoạt lời gọi backend URL với query parameters `format=png&dpi=300`.
  - Hiển thị SnackBar thành công thông báo: "Đang tải file in ấn định dạng PNG (300 DPI)...".
- **Kết quả thực tế:** SnackBar hiển thị chính xác, URL tải xuống được kích hoạt với đầy đủ query parameters format và DPI.
- **Trạng thái:** **PASS**

---

### TC-238-03: Tải file PNG kiểm tra kích thước 1240x1754 px và quét QR bằng ZXing Reader trỏ đúng URL
- **Phân loại:** Xuất file in ấn / Chất lượng đồ họa & Quét mã
- **Mức độ ưu tiên:** Critical
- **Tiền điều kiện:** API Backend `GET /api/v1/print-designs/{id}/export?format=png&dpi=300` sẵn sàng.
- **Các bước thực hiện:**
  1. Gọi endpoint xuất file PNG từ thiết kế A6.
  2. Đo đạc kích thước pixel dimensions của file ảnh nhị phân trả về.
  3. Sử dụng thư viện quét mã vạch/QR tiêu chuẩn ZXing (`MultiFormatReader`) để giải mã barcode từ ảnh.
  4. Đối chiếu URL khảo sát giải mã được với chi nhánh tương ứng.
- **Kết quả kỳ vọng:**
  - Ảnh PNG có kích thước chính xác 1240 x 1754 pixels (chuẩn in ấn A6 ở độ phân giải 300 DPI).
  - Thư viện ZXing giải mã thành công nội dung QR text: `https://cxshield.vn/survey?qr=MC-B04`.
  - URL trỏ thẳng về màn hình khảo sát M1-01 của chi nhánh.
- **Kết quả thực tế:** Kích thước ảnh xuất ra đạt đúng 1240x1754 px; ZXing giải mã chính xác URL khảo sát chi nhánh MC-B04.
- **Trạng thái:** **PASS**

---

### TC-238-04: Chọn định dạng PDF và bấm tải file in ấn kích hoạt thông báo tải chuẩn 300 DPI
- **Phân loại:** Xuất file in ấn
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** Đang ở màn hình D3-11, Tab "Xuất file in ấn".
- **Các bước thực hiện:**
  1. Nhấp chọn Radio/Segment định dạng "PDF (Bản in vector/A4/A5/A6)".
  2. Bấm nút "Tải file in ấn (PDF)".
- **Kết quả kỳ vọng:**
  - Hệ thống kích hoạt lời gọi URL xuất file với `format=pdf&dpi=300`.
  - Hiển thị SnackBar thông báo: "Đang tải file in ấn định dạng PDF (300 DPI)...".
- **Kết quả thực tế:** Hệ thống hiển thị SnackBar thành công và kích hoạt URL xuất PDF chuẩn 300 DPI.
- **Trạng thái:** **PASS**

---

### TC-238-05: Rà soát tái hiện BUG-SCRUM237-01 khi mở file PDF trên PDF parser chuẩn mực
- **Phân loại:** Xuất file in ấn / Định dạng tài liệu PDF
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** File PDF xuất từ `PrintExportService.java`.
- **Các bước thực hiện:**
  1. Nạp file PDF xuất từ backend vào bộ giải mã chuẩn công nghiệp Apache PDFBox 3.0.4.
  2. Đọc đối tượng luồng hình ảnh nhúng trong trang PDF (`/Type /XObject /Subtype /Image`).
  3. Kiểm tra khai báo bộ lọc nén `/Filter` so với dữ liệu nhị phân thực tế.
- **Kết quả kỳ vọng:**
  - Bộ nén `/Filter` phải tương thích với định dạng ảnh (ví dụ `/FlateDecode` cho PNG hoặc dữ liệu nén JPEG thực sự nếu dùng `/DCTDecode`).
  - Trình đọc PDF giải mã và hiển thị hình ảnh bình thường không ném lỗi.
- **Kết quả thực tế:**
  - Đối tượng ảnh trong PDF khai báo `/Filter /DCTDecode` (JPEG) nhưng dữ liệu nhúng thực tế là chuỗi bytes định dạng PNG (bắt đầu bằng magic bytes `0x89 0x50 0x4E 0x47`).
  - Apache PDFBox ném ngoại lệ nghiêm trọng: `javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11`.
  - Tái hiện hoàn toàn lỗi `BUG-SCRUM237-01`.
- **Trạng thái:** **FAIL**

---

### TC-238-06: Chọn loại thẻ Gỗ Walnut (45.000 đ) và Thẻ Mica Acrylic (35.000 đ) cập nhật đơn giá và tạm tính
- **Phân loại:** Đặt hàng phôi thẻ NFC
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** Chuyển sang Tab "Đặt thẻ NFC" trên màn hình D3-11.
- **Các bước thực hiện:**
  1. Quan sát thẻ đang được chọn mặc định (Thẻ Gỗ Walnut).
  2. Kiểm tra thông tin đơn giá hiển thị: "45.000 đ/thẻ".
  3. Nhấp chọn thẻ "Thẻ Mica Acrylic".
  4. Quan sát giá tiền cập nhật trên giao diện.
- **Kết quả kỳ vọng:**
  - Khi chọn Thẻ Gỗ Walnut: Đơn giá hiển thị 45.000 đ/thẻ; Tạm tính với số lượng 10 thẻ là "450.000 đ".
  - Khi chuyển sang Thẻ Mica Acrylic: Đơn giá cập nhật thành 35.000 đ/thẻ; Tạm tính với số lượng 10 thẻ giảm về "350.000 đ".
- **Kết quả thực tế:** Giao diện phản hồi tức thì, cập nhật đúng thông số kỹ thuật và đơn giá tương ứng của từng chất liệu.
- **Trạng thái:** **PASS**

---

### TC-238-07: Điều chỉnh tăng/giảm số lượng phôi thẻ tính đúng tổng tiền (`unitPrice * quantity`)
- **Phân loại:** Đặt hàng phôi thẻ NFC / Tính toán giá tiền
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", loại thẻ đang chọn là Thẻ Gỗ Walnut (đơn giá 45.000 đ).
- **Các bước thực hiện:**
  1. Bấm nút giảm (-) số lượng từ 10 xuống 9 thẻ.
  2. Quan sát ô hiển thị số lượng và dòng "Tạm tính".
  3. Bấm nút tăng (+) số lượng từ 9 lên 11 thẻ.
  4. Quan sát tổng tiền cập nhật.
- **Kết quả kỳ vọng:**
  - 9 thẻ Gỗ Walnut: Tổng tiền = 9 * 45.000 = 405.000 đ.
  - 11 thẻ Gỗ Walnut: Tổng tiền = 11 * 45.000 = 495.000 đ.
  - Không cho phép giảm số lượng xuống dưới 1.
- **Kết quả thực tế:** Phép tính số lượng và tổng tiền chuẩn xác 100%, định dạng tiền tệ Việt Nam Đồng hiển thị rõ ràng.
- **Trạng thái:** **PASS**

---

### TC-238-08: Chặn gửi đơn đặt phôi thẻ NFC khi để trống họ tên, số điện thoại và địa chỉ nhận hàng
- **Phân loại:** Form Validation
- **Mức độ ưu tiên:** High
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", các trường thông tin nhận hàng đang để trống.
- **Các bước thực hiện:**
  1. Xóa sạch dữ liệu (nếu có) trong 3 ô: Họ tên người nhận, Số điện thoại, Địa chỉ giao hàng.
  2. Bấm nút "Xác nhận đặt thẻ NFC".
- **Kết quả kỳ vọng:**
  - Form validation được kích hoạt; ngăn chặn việc gửi dữ liệu lên server.
  - Hiển thị 3 thông báo lỗi màu đỏ dưới từng trường:
    - "Vui lòng nhập họ tên người nhận"
    - "Vui lòng nhập số điện thoại"
    - "Vui lòng nhập địa chỉ nhận hàng"
- **Kết quả thực tế:** Form chặn gửi đơn thành công, cả 3 thông báo lỗi validation hiển thị đầy đủ ngay vị trí input.
- **Trạng thái:** **PASS**

---

### TC-238-09: Chặn gửi đơn khi số điện thoại giao hàng sai quy chuẩn đầu số viễn thông Việt Nam
- **Phân loại:** Form Validation
- **Mức độ ưu tiên:** Medium
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", đã nhập họ tên hợp lệ và địa chỉ hợp lệ.
- **Các bước thực hiện:**
  1. Nhập số điện thoại sai cấu trúc (ví dụ: `12345678`, `0281234567`, `090123`).
  2. Bấm nút "Xác nhận đặt thẻ NFC".
- **Kết quả kỳ vọng:**
  - Hệ thống chặn gửi đơn.
  - Hiển thị thông báo lỗi: "Số điện thoại không hợp lệ (10 số, bắt đầu bằng 03, 05, 07, 08, 09)".
- **Kết quả thực tế:** Regex validation hoạt động chính xác theo tiêu chuẩn số di động Việt Nam.
- **Trạng thái:** **PASS**

---

### TC-238-10: Chặn gửi đơn khi địa chỉ nhận hàng quá ngắn (dưới 5 ký tự)
- **Phân loại:** Form Validation
- **Mức độ ưu tiên:** Medium
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", đã nhập họ tên và SĐT hợp lệ.
- **Các bước thực hiện:**
  1. Nhập địa chỉ dưới 5 ký tự (ví dụ: `HN`, `Q1`).
  2. Bấm nút "Xác nhận đặt thẻ NFC".
- **Kết quả kỳ vọng:**
  - Hệ thống chặn gửi đơn.
  - Hiển thị thông báo lỗi: "Địa chỉ quá ngắn (tối thiểu 5 ký tự)".
- **Kết quả thực tế:** Chặn thành công địa chỉ không đủ thông tin chi tiết.
- **Trạng thái:** **PASS**

---

### TC-238-11: Gửi đơn đặt phôi thẻ NFC hợp lệ thành công, hiển thị AlertDialog và nạp vào Lịch sử đơn (`PENDING`)
- **Phân loại:** Luồng nghiệp vụ chính (Happy Path)
- **Mức độ ưu tiên:** Critical
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", chọn 10 Thẻ Gỗ Walnut (450.000 đ).
- **Các bước thực hiện:**
  1. Điền thông tin giao hàng:
     - Họ tên: "Nguyễn Văn Chủ Mới"
     - SĐT: "0901234567"
     - Địa chỉ: "789 Đường Hoa Lan, Phường 2, Phú Nhuận, TP.HCM"
     - Ghi chú: "Khắc laser logo sắc nét giúp shop"
  2. Bấm nút "Xác nhận đặt thẻ NFC".
  3. Quan sát thông báo popup xác nhận và chuyển sang Tab "Lịch sử đơn".
- **Kết quả kỳ vọng:**
  - Hiển thị popup AlertDialog: Tiêu đề "Đặt thẻ NFC thành công!", nội dung hiển thị tổng tiền "450.000 đ" và ghi chú đơn hàng đang được chuyển sang bộ phận sản xuất.
  - Bấm "Đóng" hoặc chuyển sang Tab "Lịch sử đơn": Xuất hiện đơn hàng mới nhất với trạng thái "Mới tiếp nhận" (`PENDING`), đúng tên người nhận "Nguyễn Văn Chủ Mới (0901234567)", địa chỉ và số lượng 10 thẻ.
- **Kết quả thực tế:** Đơn hàng được tạo thành công, popup hiển thị đúng, đơn được thêm vào danh sách quản lý lịch sử với trạng thái PENDING.
- **Trạng thái:** **PASS**

---

### TC-238-12: Xử lý lỗi khi API gửi đơn đặt thẻ NFC thất bại hiển thị SnackBar cảnh báo lỗi
- **Phân loại:** Xử lý lỗi hệ thống & Ngoại lệ
- **Mức độ ưu tiên:** Medium
- **Tiền điều kiện:** Tab "Đặt thẻ NFC", kết nối mạng bị gián đoạn hoặc API trả về lỗi HTTP 500/Timeout.
- **Các bước thực hiện:**
  1. Nhập thông tin đặt thẻ hợp lệ.
  2. Giả lập API `createNfcOrder` ném lỗi Exception ("Lỗi kết nối máy chủ").
  3. Bấm "Xác nhận đặt thẻ NFC".
- **Kết quả kỳ vọng:**
  - Ứng dụng không bị crash.
  - Hiển thị SnackBar màu đỏ cảnh báo lỗi: "Đặt thẻ thất bại: Exception: Lỗi kết nối máy chủ".
- **Kết quả thực tế:** Ngoại lệ được try-catch đầy đủ, giao diện phản hồi SnackBar lỗi rõ ràng cho người dùng.
- **Trạng thái:** **PASS**

---

### TC-238-13: In ấn bản cứng ra giấy bằng máy in vật lý
- **Phân loại:** Kiểm thử thiết bị phần cứng ngoại vi
- **Mức độ ưu tiên:** Medium
- **Tiền điều kiện:** Máy tính kết nối máy in laser/phun màu hỗ trợ in độ phân giải 300 DPI, nạp giấy in A5/A6.
- **Các bước thực hiện:**
  1. Tải file xuất PNG/PDF từ hệ thống.
  2. Mở trình quản lý in của hệ điều hành, cấu hình in 100% tỷ lệ thực (No scaling) trên khổ giấy A6.
  3. Thực hiện in bản cứng và đánh giá chất lượng mực, độ sắc nét của QR code và CTA.
- **Kết quả kỳ vọng:** Bản in sắc nét, không bị nhòe vỡ hạt, đúng tỷ lệ kích thước vật lý A6 (105 x 148 mm).
- **Kết quả thực tế:** **NOT RUN (Không thể thực hiện)**. Môi trường kiểm thử hiện tại là máy chủ / CI pipeline không có thiết bị máy in phần cứng kết nối.
- **Trạng thái:** **NOT RUN**

---

### TC-238-14: Quét mã QR trên bản in vật lý bằng camera điện thoại thật ngoài đời
- **Phân loại:** Kiểm thử trải nghiệm người dùng thực tế (End-to-End Hardware)
- **Mức độ ưu tiên:** Medium
- **Tiền điều kiện:** Có bản in vật lý thực tế từ TC-238-13 và điện thoại thông minh (iOS/Android) có camera quang học.
- **Các bước thực hiện:**
  1. Cầm điện thoại ở khoảng cách 15 - 30 cm so với bản in giấy đặt trên bàn.
  2. Bật ứng dụng Camera mặc định để quét mã QR.
  3. Nhấp vào liên kết xuất hiện trên màn hình điện thoại.
- **Kết quả kỳ vọng:** Camera nhận diện tức thì trong vòng dưới 1 giây; trình duyệt mở ra trang đánh giá khảo sát M1-01 tương ứng với chi nhánh `MC-B04`.
- **Kết quả thực tế:** **NOT RUN (Không thể thực hiện)**. Môi trường kiểm thử tự động không có thiết bị điện thoại thật và camera quang học vật lý. Đã được thay thế bằng kiểm thử tự động giải mã luồng bit ảnh số bằng thư viện chuẩn ZXing trong `TC-238-03` (kết quả PASSED).
- **Trạng thái:** **NOT RUN**
