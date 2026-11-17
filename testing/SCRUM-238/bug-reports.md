# BÁO CÁO LỖI VÀ QUAN SÁT (BUG REPORTS & OBSERVATIONS)

**Mã công việc:** SCRUM-238
**Tiêu đề:** [E5.3] Kiểm thử chức năng xuất file in và đặt thẻ NFC
**Màn hình kiểm thử:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày báo cáo:** 17/11/2026

---

## 1. DANH SÁCH TỔNG HỢP

| Mã Bug / Quan sát | Phân loại | Mức độ nghiêm trọng | Tiêu đề tóm tắt | Trạng thái |
|---|---|---|---|---|
| `BUG-SCRUM237-01` | Bug Chức năng | **Medium** | Tái hiện lỗi xuất PDF khai báo `/Filter /DCTDecode` nhưng nhúng bytes PNG | **CONFIRMED** |
| `BUG-SCRUM237-02` | Bug Bảo mật | **High** | Dẫn chiếu: Rò rỉ danh sách đơn đặt thẻ NFC khi thiếu tenant filter | **CONFIRMED** (từ SCRUM-237) |
| `BUG-SCRUM237-03` | Bug Bảo mật | **High** | Dẫn chiếu: Lỗ hổng IDOR trên API tra cứu đơn và xuất file in theo ID | **CONFIRMED** (từ SCRUM-237) |
| `OBS-SCRUM237-01` | Quan sát Kỹ thuật | **Low** | Dẫn chiếu: File PNG 300 DPI chưa nhúng metadata chunk `pHYs` | **CONFIRMED** (từ SCRUM-237) |
| `OBS-SCRUM238-01` | Quan sát UX/UI | **Low** | Giao diện Live Preview trên màn hình hẹp cần cuộn dọc để bấm nút tải file | **OPEN** |

---

## 2. CHI TIẾT BÁO CÁO LỖI

### BUG-SCRUM237-01 (TÁI HIỆN XÁC NHẬN TẠI TC-238-05)
- **Mã lỗi:** `BUG-SCRUM237-01`
- **Tiêu đề:** File PDF xuất từ chức năng D3-11 khai báo bộ lọc nén `/Filter /DCTDecode` nhưng chứa dữ liệu nhị phân của ảnh PNG
- **Thành phần ảnh hưởng:**
  - Backend: `PrintExportService.java` (dòng 222)
  - Frontend: Màn hình D3-11 (`d3_11_print_nfc_page.dart` - Tab "Xuất file in ấn", nút "Tải file in ấn (PDF)")
- **Mức độ nghiêm trọng:** Medium
- **Mức độ ưu tiên khắc phục:** High
- **Điều kiện tiên quyết:** Có mẫu thiết kế QR in ấn sẵn sàng trên hệ thống.
- **Các bước tái hiện (Steps to Reproduce):**
  1. Truy cập màn hình D3-11 tại tab "Xuất file in ấn".
  2. Chọn định dạng xuất file: "PDF (Bản in vector/A4/A5/A6)".
  3. Bấm "Tải file in ấn (PDF)" hoặc gửi request HTTP:
     `GET /api/v1/print-designs/mc-des-001/export?format=pdf&dpi=300`
  4. Lưu file `.pdf` tải về máy và mở bằng phần mềm đọc PDF chuẩn (Adobe Acrobat Reader, Foxit Reader) hoặc đọc qua thư viện lập trình `org.apache.pdfbox.Loader.loadPDF()`.
- **Kết quả kỳ vọng (Expected Result):**
  - File PDF hợp lệ theo chuẩn ISO 32000-1.
  - Hình ảnh bản in hiển thị trọn vẹn, không xảy ra xung đột giữa bộ lọc giải mã (`/Filter`) và luồng byte nhị phân.
- **Kết quả thực tế (Actual Result):**
  - Đối tượng XObject hình ảnh trong file PDF được khai báo:
    ```pdf
    << /Type /XObject /Subtype /Image /Width 1240 /Height 1754 /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length 125842 >>
    stream
    \x89PNG\r\n\x1a\n... (Dữ liệu byte thực tế là ảnh PNG)
    endstream
    ```
  - Trình phân tích PDFBox ném ngoại lệ khi giải mã luồng ảnh:
    ```text
    javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11
        at java.desktop/com.sun.imageio.plugins.jpeg.JPEGImageReader.readImageHeader(Native Method)
    ```
- **Tác động nghiệp vụ:** Khách hàng hoặc nhà in ấn mở file PDF để in ấn Standee/Sticker có thể gặp lỗi trang trắng hoặc máy in từ chối xử lý lệnh in vì lỗi cấu trúc luồng ảnh.
- **Khuyến nghị khắc phục:**
  - Cách 1 (Khuyến nghị): Nếu dùng ảnh PNG, thay đổi khai báo `/Filter /DCTDecode` thành `/Filter /FlateDecode` và sử dụng luồng nén Deflate/ZLIB chuẩn.
  - Cách 2: Sử dụng `ImageIO.write(image, "JPEG", outputStream)` để sinh ra dữ liệu nén JPEG thực sự trước khi nhúng vào đối tượng PDF.

---

### DẪN CHIẾU CÁC LỖI TỒN TẠI TỪ SCRUM-237

#### BUG-SCRUM237-02: Lỗ hổng Multi-tenant Isolation Breach
- **Mức độ:** High
- **Ảnh hưởng đến D3-11:** Khi merchant vào Tab "Lịch sử đơn", API `GET /api/v1/nfc-orders` nếu không được inject `businessId` từ JWT context một cách an toàn sẽ trả về toàn bộ đơn đặt thẻ của mọi cửa hàng khác trong hệ thống.
- **Trạng thái:** Đã ghi nhận trong báo cáo SCRUM-237, chờ đội Dev xử lý.

#### BUG-SCRUM237-03: Lỗ hổng bảo mật IDOR
- **Mức độ:** High
- **Ảnh hưởng đến D3-11:** Kẻ tấn công có thể thay đổi `orderId` trên API để xem thông tin nhận hàng (tên, SĐT, địa chỉ) của khách hàng khác, hoặc đổi `designId` trên endpoint export để tải ấn phẩm của đối thủ.
- **Trạng thái:** Đã ghi nhận trong báo cáo SCRUM-237, chờ đội Dev xử lý.

---

## 3. QUAN SÁT VÀ ĐỀ XUẤT NÂNG CAO TRẢI NGHIỆM (OBSERVATIONS)

### OBS-SCRUM238-01: Tối ưu hiển thị responsive Live Preview trên màn hình hẹp
- **Mức độ:** Low (UI/UX)
- **Mô tả:** Trên các màn hình có chiều cao hạn chế (chiều cao cửa sổ dưới 700px), khung Live Preview của bản in A6 chiếm diện tích lớn khiến nút "Tải file in ấn" bị đẩy xuống dưới khung nhìn, người dùng phải cuộn trang xuống mới thấy nút hành động.
- **Đề xuất:** Cân nhắc cố định thanh hành động (Action Bar) hoặc thanh nút tải file ở đáy màn hình (Bottom Navigation / Sticky Footer) để người dùng thao tác thuận tiện hơn.
