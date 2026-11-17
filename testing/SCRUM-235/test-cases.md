# BỘ TEST CASES KIỂM THỬ CHỨC NĂNG STUDIO THIẾT KẾ ẤN PHẨM QR (SCRUM-235)

- **Mã Jira:** SCRUM-235
- **Tên User Story:** [E5.1] Kiểm thử chức năng studio thiết kế ấn phẩm QR
- **Màn hình kiểm thử:** Màn hình D3-09 (`/print-materials`) – Studio Thiết Kế Ấn Phẩm QR Để Bàn & Dán Quầy
- **Công cụ kiểm thử:** Flutter Widget Test Runner, MockClient, Dart Test
- **Tệp thực thi tự động:** `frontend/test/d3_09_qr_studio_functional_test.dart` (12 automation tests)
- **Ranh giới phân định:**
  - **SCRUM-213:** Đã hoàn thành code tính năng và merge vào `main`.
  - **SCRUM-234:** Đã kiểm thử mã nguồn Java backend và unit test (14 tests).
  - **SCRUM-235:** Tập trung 100% vào kiểm thử chức năng giao diện người dùng Flutter (màn hình D3-09), luồng thao tác studio, Live Preview real-time, thêm/sửa CTA, chọn khung mẫu, thêm logo, lưu & nạp mẫu, điều hướng khảo sát M1-01.
  - **SCRUM-236:** Phụ trách kiểm thử E2E tích hợp mở rộng. Không thực hiện lại tại đây.

---

## I. Bảng tổng hợp hiện trạng kiểm thử (Coverage & Execution Matrix)

> [!IMPORTANT]
> **LƯU Ý VỀ KIỂM THỬ QUÉT QR BẰNG CAMERA ĐIỆN THOẠI THẬT:**
> Trong kịch bản `TC-235-11`, việc quét bằng nút *"Thử nghiệm quét QR: Mở màn khảo sát M1-01"* và tap vào ma trận QR trên giao diện giả lập đạt kết quả **PASS**. Thao tác quét quang học bằng camera của **điện thoại vật lý ngoài đời thực ghi nhận trạng thái NOT RUN** do môi trường server thử nghiệm cục bộ không có thiết bị phần cứng điện thoại di động kết nối.

| Mã TC | Tên kịch bản kiểm thử | Trọng tâm chức năng | Test Method thực thi | Kết quả TC | Kết quả Auto | Ghi chú kỹ thuật & Bằng chứng |
| :--- | :--- | :---: | :--- | :---: | :---: | :--- |
| `TC-235-01` | Mở màn D3-09, tải danh sách QR và hiển thị Live Preview | 1. Mở màn D3-09 | `testWidgets('TC-235-01: ...')` | **PASS** | **PASS** | Tải danh sách QR chi nhánh, nạp mẫu mặc định, render QrImageView |
| `TC-235-02` | Mở Dialog và tạo mã QR vị trí mới cho chi nhánh | 2. Tạo mã QR | `testWidgets('TC-235-02: ...')` | **PASS** | **PASS** | Dialog "Tạo Mã QR Vị Trí Mới", gọi POST /api/v1/qr-codes, hiện SnackBar |
| `TC-235-03` | Chọn khung mẫu Standee Để Bàn (TABLE_TENT) | 3. Khung mẫu Standee | `testWidgets('TC-235-03: ...')` | **PASS** | **PASS** | Bố cục đứng A6, có chân đế gỗ/mica, banner thương hiệu và nhãn vị trí |
| `TC-235-04` | Chọn khung mẫu Sticker Dán Quầy và Thẻ Chạm NFC | 4. Sticker & Thẻ NFC | `testWidgets('TC-235-04: ...')` | **PASS** | **PASS** | Decal tròn 270px cho Sticker; gradient card bo góc cho Thẻ NFC |
| `TC-235-05` | Thêm đường dẫn logo hợp lệ và hiển thị trên banner Live Preview | 5. Thêm logo hợp lệ | `testWidgets('TC-235-05: ...')` | **PASS** | **PASS** | Nhập HTTPS URL ảnh, render ClipRRect 32x32px trong banner |
| `TC-235-06` | Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh | 6. Chỉnh sửa CTA | `testWidgets('TC-235-06: ...')` | **PASS** | **PASS** | Nhập text tùy biến hoặc bấm ActionChip cập nhật Live Preview |
| `TC-235-07` | Kiểm tra Live Preview cập nhật màu sắc thương hiệu real-time | 7. Live Preview real-time | `testWidgets('TC-235-07: ...')` | **PASS** | **PASS** | Bấm ChoiceChip chọn màu (Nâu, Đỏ Rượu,...), preview đổi màu tức thì |
| `TC-235-08` | Lưu mẫu thiết kế và lưu bản sao mới thành công | 8. Lưu thiết kế | `testWidgets('TC-235-08: ...')` | **PASS** | **PASS** | Gọi POST /api/v1/print-designs, hỗ trợ lưu đè và lưu bản sao mới |
| `TC-235-09` | Nạp lại mẫu thiết kế đã lưu phục hồi dữ liệu form và preview | 9. Mở lại mẫu đã lưu | `testWidgets('TC-235-09: ...')` | **PASS** | **PASS** | Bấm "Nạp mẫu này", điền lại toàn bộ thông số lên form và đổi preview |
| `TC-235-10` | Xóa mẫu thiết kế ấn phẩm khỏi danh sách mẫu đã lưu | 9. Quản lý mẫu | `testWidgets('TC-235-10: ...')` | **PASS** | **PASS** | Bấm icon xóa, gọi DELETE /api/v1/print-designs/{id}, cập nhật list |
| `TC-235-11` | Thử nghiệm quét QR mở màn khảo sát M1-01 (In-App Simulation) | 10. Quét QR mở M1-01 | `testWidgets('TC-235-11: ...')` | **PASS (In-App)** / **NOT RUN (Physical)** | **PASS** | Điều hướng /survey?qr={code} thành công; Quét camera điện thoại thật: NOT RUN |
| `TC-235-12` | Thử logo sai định dạng và quá lớn trên giao diện D3-09 | 11-12. Thử logo sai / lớn | `testWidgets('TC-235-12: ...')` | **FAIL (Bug)** | **PASS (Proof)** | Giao diện thiếu validation chặn URL không phải ảnh / file độc hại (BUG-SCRUM235-01) |

- **Tổng số Test Cases thiết kế:** **12**
- **Test Case PASS:** **10 / 12** (83.3%)
- **Test Case FAIL:** **1 / 12** (8.3%) (`TC-235-12` – Thiếu kiểm tra định dạng và kích thước logo trên giao diện)
- **Test Case NOT RUN / BLOCKED:** **1 / 12** (8.3%) (`TC-235-11` – Quét camera vật lý điện thoại ngoài đời thực: NOT RUN do thiếu thiết bị phần cứng)
- **Automation Tests thực tế chạy (SCRUM-235):** **12 / 12 PASS** (`d3_09_qr_studio_functional_test.dart`)
- **Regression Tests (Frontend D3-09):** **6 / 6 PASS** (`d3_09_qr_studio_test.dart`)
- **Phân loại vấn đề ghi nhận:**
  - **1 BUG (Defect):** `BUG-SCRUM235-01` (Giao diện D3-09 thiếu validation chặn URL logo sai định dạng / file thực thi nguy hiểm).
  - **1 OBSERVATION:** `OBS-SCRUM235-01` (D3-09 chưa tích hợp File Picker chọn file từ máy có kiểm tra dung lượng <= 2MB; Quét QR bằng điện thoại vật lý ghi nhận NOT RUN).

---

## II. Chi tiết 12 Test Cases

### TC-235-01: Mở màn D3-09, tải danh sách QR và hiển thị Live Preview
- **Mục tiêu:** Kiểm tra chức năng khởi tạo màn D3-09, tải danh sách QR của chi nhánh đang chọn và render giao diện Live Preview trực quan.
- **Dữ liệu đầu vào:** Session đã đăng nhập cơ sở Maison Coffee, chi nhánh `b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22`.
- **Các bước thực hiện:**
  1. Khởi chạy màn hình D3-09.
  2. Đợi `_initData()` hoàn thành tải dữ liệu.
- **Kết quả mong đợi:**
  - Tiêu đề `'Studio Thiết Kế Ấn Phẩm QR (D3-09)'` hiển thị.
  - Dropdown chọn mã QR hiển thị `'MC-B04 - Bàn 04 (TABLE)'`.
  - Khung Live Preview xuất hiện với QrImageView ma trận QR thật 100%.
- **Kết quả thực tế:** **PASS**.

### TC-235-02: Mở Dialog và tạo mã QR vị trí mới cho chi nhánh
- **Mục tiêu:** Kiểm tra chức năng tạo mã QR mới ngay trên Studio thiết kế khi chi nhánh cần thêm vị trí bàn/quầy.
- **Dữ liệu đầu vào:** Loại vị trí `COUNTER`, tên `'Quầy thu ngân 3'`, mã code tự sinh.
- **Các bước thực hiện:**
  1. Nhấn nút `'Tạo mã QR'` (OutlinedButton) bên cạnh Dropdown.
  2. Dialog `'Tạo Mã QR Vị Trí Mới'` xuất hiện.
  3. Nhấn nút `'Tạo mã QR'` trong Dialog.
- **Kết quả mong đợi:**
  - Gửi request `POST /api/v1/qr-codes`.
  - Hiển thị SnackBar màu xanh thông báo tạo thành công.
  - Dropdown tự động cập nhật và chọn mã QR mới sinh.
- **Kết quả thực tế:** **PASS**.

### TC-235-03: Chọn khung mẫu Standee Để Bàn (TABLE_TENT)
- **Mục tiêu:** Kiểm tra chức năng chuyển sang mẫu Standee để bàn tam giác (A6).
- **Các bước thực hiện:** Nhấn vào thẻ `'Standee Để Bàn'`.
- **Kết quả mong đợi:**
  - Khung xem trước cập nhật dạng thẻ chữ nhật đứng A6.
  - Hiển thị banner thương hiệu trên cùng, ma trận QR 135x135 px, nhãn mã bàn và chân đế gỗ/mica.
- **Kết quả thực tế:** **PASS**.

### TC-235-04: Chọn khung mẫu Sticker Dán Quầy và Thẻ Chạm NFC
- **Mục tiêu:** Kiểm tra chức năng chuyển sang mẫu Decal tròn dán quầy thu ngân và Thẻ chạm NFC.
- **Các bước thực hiện:**
  1. Nhấn vào thẻ `'Sticker Dán Quầy'`.
  2. Nhấn tiếp vào thẻ `'Thẻ Chạm NFC'`.
- **Kết quả mong đợi:**
  - Sticker: Render khung tròn decal 270x270 px có viền màu thương hiệu, QrImageView 110x110 px ở giữa.
  - Thẻ NFC: Render dạng thẻ ngân hàng gradient, biểu tượng NFC không tiếp xúc, nhãn `'NFC TAG 215'`.
- **Kết quả thực tế:** **PASS**.

### TC-235-05: Thêm đường dẫn logo hợp lệ và hiển thị trên banner Live Preview
- **Mục tiêu:** Kiểm tra hiển thị hình ảnh logo thương hiệu khi người dùng nhập URL ảnh hợp lệ.
- **Dữ liệu đầu vào:** `logoUrl = "https://images.unsplash.com/photo-custom-logo.png"`.
- **Các bước thực hiện:** Nhập URL vào trường `'Logo cơ sở (URL ảnh)'`.
- **Kết quả mong đợi:**Widget `Image.network` được render trong khung bo tròn `ClipRRect(borderRadius: 16)` kích thước 32x32 px trên banner.
- **Kết quả thực tế:** **PASS**.

### TC-235-06: Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh
- **Mục tiêu:** Kiểm tra nhập câu kêu gọi hành động (CTA) tùy biến hoặc bấm chọn từ danh sách chip gợi ý nhanh.
- **Dữ liệu đầu vào:** Bấm chip `'Đánh giá 5 sao nhận ngay quà tặng'`.
- **Kết quả mong đợi:**Ô nhập text CTA nhận giá trị của chip, Live Preview cập nhật câu CTA tương ứng ngay lập tức.
- **Kết quả thực tế:** **PASS**.

### TC-235-07: Kiểm tra Live Preview cập nhật màu sắc thương hiệu real-time
- **Mục tiêu:** Kiểm tra tính năng cập nhật màu sắc nhận diện thương hiệu tức thì trên Live Preview.
- **Dữ liệu đầu vào:** Chọn chip màu `'Đỏ Rượu'` (`#991B1B`).
- **Kết quả mong đợi:**Banner thương hiệu và viền trang trí của Live Preview đổi sang màu đỏ rượu ngay lập tức.
- **Kết quả thực tế:** **PASS**.

### TC-235-08: Lưu mẫu thiết kế và lưu bản sao mới thành công
- **Mục tiêu:** Kiểm tra chức năng lưu đè mẫu thiết kế hiện tại và nhân bản thành mẫu mới (`asNew: true`).
- **Các bước thực hiện:**
  1. Nhấn nút `'Lưu mẫu thiết kế'`.
  2. Đợi hoàn tất, nhấn nút `'Lưu bản sao mới'`.
- **Kết quả mong đợi:**
  - Lần 1: Gọi `POST /api/v1/print-designs` kèm `id` hiện tại, hiển thị SnackBar `'Đã lưu mẫu thiết kế ấn phẩm vào print_designs thành công!'`.
  - Lần 2: Gọi `POST` với `id` rỗng, hiển thị SnackBar `'Đã lưu thành mẫu thiết kế mới thành công!'`.
- **Kết quả thực tế:** **PASS**.

### TC-235-09: Nạp lại mẫu thiết kế đã lưu phục hồi dữ liệu form và preview
- **Mục tiêu:** Kiểm tra chức năng phục hồi thông số thiết kế khi chọn một mẫu từ danh sách mẫu đã lưu.
- **Các bước thực hiện:** Cuộn xuống danh sách `'Mẫu Thiết Kế Đã Lưu'`, nhấn nút `'Nạp mẫu này'` tại mẫu `'Maison Coffee Quầy Thu Ngân'`.
- **Kết quả mong đợi:**
  - Hiển thị SnackBar thông báo nạp mẫu thành công.
  - Ô nhập Tên thương hiệu, CTA, màu sắc và template trên form được điền lại đúng dữ liệu của mẫu đã chọn.
  - Live Preview chuyển đổi tương ứng theo mẫu được nạp.
- **Kết quả thực tế:** **PASS**.

### TC-235-10: Xóa mẫu thiết kế ấn phẩm khỏi danh sách mẫu đã lưu
- **Mục tiêu:** Kiểm tra chức năng xóa mẫu thiết kế không còn nhu cầu sử dụng.
- **Các bước thực hiện:** Nhấn icon thùng rác (tooltip `'Xóa mẫu này'`) tại thẻ mẫu thiết kế.
- **Kết quả mong đợi:**Gọi `DELETE /api/v1/print-designs/{id}`, hiển thị SnackBar `'Đã xóa mẫu thiết kế thành công!'`, thẻ mẫu biến mất khỏi danh sách.
- **Kết quả thực tế:** **PASS**.

### TC-235-11: Thử nghiệm quét QR mở màn khảo sát M1-01
- **Mục tiêu:** Kiểm tra tính năng thử nghiệm quét QR điều hướng trực tiếp sang phễu khảo sát khách hàng M1-01 mang đúng mã QR chi nhánh.
- **Các bước thực hiện:**
  1. Nhấn nút `'Thử nghiệm quét QR: Mở màn khảo sát M1-01 (MC-B04)'`.
  2. Hoặc tap trực tiếp vào QrImageView trên Live Preview.
- **Kết quả mong đợi:**
  - Điều hướng tới `/survey?qr=MC-B04`.
  - Quét quang học camera điện thoại thật ngoài đời: Ghi nhận **NOT RUN** do môi trường server thử nghiệm không có điện thoại vật lý kết nối.
- **Kết quả thực tế:** **PASS (In-App Simulation)** / **NOT RUN (Physical camera scan)**.

### TC-235-12: Thử logo sai định dạng và quá lớn trên giao diện D3-09
- **Mục tiêu:** Kiểm tra phản ứng của giao diện khi người dùng dán URL file sai định dạng (ví dụ `.exe`) hoặc chuỗi URL dung lượng cực lớn.
- **Dữ liệu đầu vào:** `logoUrl = "https://malicious.example.com/payload.exe"`.
- **Kết quả mong đợi:**Giao diện cần có validator cảnh báo định dạng không hợp lệ và chặn lưu.
- **Kết quả thực tế:** **FAIL (Bug)** (Giao diện không crash nhờ fallback icon `errorBuilder`, nhưng hoàn toàn thiếu validation cảnh báo định dạng và dung lượng logo; cho phép bấm lưu chuỗi độc hại vào database -> Ghi nhận `BUG-SCRUM235-01`).
