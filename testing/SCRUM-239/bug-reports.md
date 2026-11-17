# BÁO CÁO LỖI VÀ QUAN SÁT (BUG REPORTS & OBSERVATIONS)

**Mã công việc:** SCRUM-239
**Tiêu đề:** [E5.3] Kiểm thử tự động xuất file in và đặt thẻ NFC
**Màn hình kiểm thử:** D3-11 (`/print-nfc` - `D311PrintNfcPage`)
**Story cha:** SCRUM-136
**Repository:** `Krydecres/CX-SHIELD`
**Nhánh:** `main`
**Ngày báo cáo:** 17/11/2026

---

## 1. DANH SÁCH TỔNG HỢP

| Mã Bug / Quan sát | Phân loại | Mức độ nghiêm trọng | Tiêu đề tóm tắt | Trạng thái |
|---|---|---|---|---|
| `BUG-SCRUM237-01` | Bug Chức năng | **Medium** | Tái hiện lỗi xuất PDF khai báo `/Filter /DCTDecode` nhưng nhúng bytes PNG | **CONFIRMED** (tại `AUTO-239-11`) |
| `BUG-SCRUM237-02` | Bug Bảo mật | **High** | Dẫn chiếu: Rò rỉ danh sách đơn đặt thẻ NFC khi thiếu tenant filter | **CONFIRMED** (từ SCRUM-237) |
| `BUG-SCRUM237-03` | Bug Bảo mật | **High** | Dẫn chiếu: Lỗ hổng IDOR trên API tra cứu đơn và xuất file in theo ID | **CONFIRMED** (từ SCRUM-237) |
| `OBS-SCRUM237-01` | Quan sát Kỹ thuật | **Low** | Dẫn chiếu: File PNG 300 DPI chưa nhúng metadata chunk `pHYs` | **CONFIRMED** (từ SCRUM-237) |
| `OBS-SCRUM238-01` | Quan sát UX/UI | **Low** | Dẫn chiếu: Live Preview trên màn hình nhỏ cần cuộn để thấy nút tải file | **OPEN** (từ SCRUM-238) |

---

## 2. CHI TIẾT BÁO CÁO LỖI

### BUG-SCRUM237-01 (TÁI HIỆN XÁC NHẬN TẠI AUTO-239-11)
- **Mã lỗi:** `BUG-SCRUM237-01`
- **Tiêu đề:** File PDF xuất từ chức năng D3-11 khai báo bộ lọc nén `/Filter /DCTDecode` nhưng chứa dữ liệu nhị phân của ảnh PNG
- **Thành phần ảnh hưởng:**
  - Backend: `PrintExportService.java` (dòng 222)
  - Endpoint: `GET /api/v1/print-designs/{id}/export?format=pdf&dpi=300`
  - Frontend: Màn hình D3-11 (`D311PrintNfcPage` - Luồng xuất file PDF in ấn)
- **Mức độ nghiêm trọng:** Medium
- **Mức độ ưu tiên:** High
- **Bằng chứng kiểm thử tự động (Automation Evidence):**
  - Kịch bản tự động hóa backend `PrintNfcSourceTest.java`:
    ```java
    try (PDDocument document = Loader.loadPDF(pdfBytes)) {
        PDPage page = document.getPage(0);
        PDImageXObject xImage = (PDImageXObject) page.getResources().getXObject(COSName.getPDFName("Im1"));
        assertEquals("DCTDecode", xImage.getCOSObject().getNameAsString(COSName.FILTER));
        // Lệnh giải mã ném IOException
        assertThrows(java.io.IOException.class, xImage::getImage);
    }
    ```
  - Ngoại lệ thực tế bắt được từ trình phân tích Apache PDFBox 3.0.4:
    ```text
    javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11
        at java.desktop/com.sun.imageio.plugins.jpeg.JPEGImageReader.readImageHeader(Native Method)
    ```
- **Hậu quả:** File PDF không thể mở được trên một số phần mềm xem tài liệu hoặc in ấn chuyên dụng (bị trang trắng hoặc báo lỗi cấu trúc tệp).
- **Khuyến nghị khắc phục:** Thay đổi khai báo bộ lọc thành `/Filter /FlateDecode` hoặc nén lại luồng ảnh thành JPEG trước khi gán `/DCTDecode`.

---

### DẪN CHIẾU CÁC LỖI TỒN TẠI TỪ CÁC TASK TRƯỚC

#### BUG-SCRUM237-02: Lỗ hổng Multi-tenant Isolation Breach
- **Mức độ:** High
- **Mô tả:** API `GET /api/v1/nfc-orders` và `GET /api/v1/print-designs` nếu không nhận `businessId` từ token JWT sẽ trả về toàn bộ đơn hàng và thiết kế của mọi khách hàng trong hệ thống.
- **Trạng thái:** Dẫn chiếu từ SCRUM-237, chờ đội Dev xử lý.

#### BUG-SCRUM237-03: Lỗ hổng bảo mật IDOR
- **Mức độ:** High
- **Mô tả:** Caller có thể truy cập thông tin người nhận đơn hàng hoặc tải file ấn phẩm của tenant khác nếu biết được UUID thông qua các API tra cứu trực tiếp theo ID.
- **Trạng thái:** Dẫn chiếu từ SCRUM-237, chờ đội Dev xử lý.

---

## 3. QUAN SÁT VÀ ĐỀ XUẤT UX/UI

### OBS-SCRUM238-01: Tối ưu thanh hành động xuất file in ấn
- **Mức độ:** Low (UI/UX)
- **Mô tả:** Trên các màn hình có chiều cao giới hạn (dưới 700px), khung xem trước bản in Standee chiếm toàn bộ màn hình khiến nút "Tải File In Ấn" bị khuất.
- **Đề xuất:** Cố định nút bấm ở chân trang (Bottom Sticky Action Bar) để người dùng có thể thao tác tải file ngay mà không cần cuộn trang.
