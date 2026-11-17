# BÁO CÁO PHÁT HIỆN LỖI VÀ GHI NHẬN KIẾN TRÚC (SCRUM-234)

- **Mã Jira:** SCRUM-234
- **Tên User Story:** [E5.1] Kiểm thử mã nguồn studio thiết kế ấn phẩm QR
- **Thời điểm ghi nhận:** 17/11/2026
- **Môi trường:** Local Backend Spring Boot (Java 21 LTS)

---

## Danh sách lỗi và bất cập kiến trúc (Defect & Observation Summary)

| Bug ID | Tên lỗi / Vấn đề phát hiện | Phân loại | Mức độ nghiêm trọng (Severity) | Trạng thái (Status) | Thành phần bị ảnh hưởng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| `BUG-SCRUM234-01` | Thiếu kiểm tra định dạng tập tin và giới hạn dung lượng logo trong API lưu ấn phẩm | Input Validation / Security | **Low / Medium** | **OPEN (Observation)** | `PrintDesignController`, `PrintDesignRequestDto` |
| `BUG-SCRUM234-02` | API tạo mã QR (`createQrCode`) chưa kiểm tra tính duy nhất của mã `code` tùy chỉnh | Business Logic / Data Integrity | **Low** | **OPEN (Observation)** | `QrCodeController.createQrCode`, `QrCodeRepository` |

---

## Chi tiết lỗi BUG-SCRUM234-01

### 1. Mô tả chi tiết (Summary & Description)
Khi thực hiện kiểm thử mã nguồn cho studio thiết kế ấn phẩm in ấn QR, QA kiểm tra khả năng kiểm soát dữ liệu đầu vào của trường `logoUrl` tại endpoint `POST /api/v1/print-designs`:
- Trong `PrintDesignRequestDto`:
  ```java
  public record PrintDesignRequestDto(
      ...
      String logoUrl,
      ...
  )
  ```
- **Hiện trạng:** Backend chỉ nhận `logoUrl` dưới dạng `String` thô mà không có bất kỳ annotation hoặc phương thức nào kiểm tra:
  1. Định dạng tập tin hình ảnh cho phép (ví dụ: chỉ chấp nhận đuôi `.png`, `.jpg`, `.jpeg`, `.svg` hoặc MIME-type `image/*`).
  2. Kích thước tập tin tối đa (ví dụ: dung lượng <= 2MB hoặc <= 5MB).
  3. Cú pháp URL an toàn (chặn các URL nguy hiểm như `javascript:`, data URI độc hại, hoặc liên kết file thực thi `.exe`).
- Đồng thời, trong `PrintExportService`, hàm `generateHighResPrintImage` hiện tại mới chỉ vẽ khung thẻ, tên thương hiệu, CTA và mã QR ZXing; trường `design.getLogoUrl()` chưa được tải về để nhúng vào ảnh in ấn.

### 2. Bằng chứng kiểm thử tự động (Proof of Concept)
Trong bài test `QrStudioSourceTest.testLogoValidationBackendLacksFormatAndSizeEnforcementObservation()`:
- Gửi payload với `logoUrl = "https://malicious.example.com/payload.exe"`.
- Backend không ném bất kỳ ngoại lệ nào và trả về HTTP 200 OK kèm mã thành công.

### 3. Đánh giá rủi ro và khuyến nghị
- **Rủi ro:** Người dùng có thể vô tình nhập URL file hỏng hoặc kẻ gian lợi dụng truyền URL mã độc vào cơ sở dữ liệu.
- **Khuyến nghị:**
  - Bổ sung pattern regex hoặc validator cho URL hình ảnh hợp lệ (chỉ cho phép giao thức `https://` và phần mở rộng `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`).
  - Khi frontend upload logo lên Supabase Storage, cần validate dung lượng file (<= 2MB) trước khi sinh URL lưu vào `print_designs`.

---

## Chi tiết lỗi BUG-SCRUM234-02

### 1. Mô tả chi tiết (Summary & Description)
Tại endpoint `POST /api/v1/qr-codes`, người dùng có thể gửi thông tin tạo mã QR tùy chỉnh kèm mã `code`:
- Nếu `code` được truyền vào, hệ thống thực hiện:
  ```java
  code = code.trim().toUpperCase();
  QrCode qrCode = new QrCode(UUID.randomUUID(), request.branchId(), code, type, name, "ACTIVE");
  QrCode saved = qrCodeRepository.save(qrCode);
  ```
- **Hiện trạng:** `QrCodeController` không kiểm tra `qrCodeRepository.findByCode(code)` xem mã code này đã tồn tại trong chi nhánh hoặc hệ thống hay chưa.
- Hậu quả: Nếu người dùng gửi 2 request với cùng một mã code (ví dụ: `MC-VIP01`), hệ thống sẽ tạo ra 2 bản ghi khác ID trong `store`, và `codeIndex` bị ghi đè trỏ sang ID của bản ghi tạo sau cùng.

### 2. Bằng chứng kiểm thử tự động (Proof of Concept)
Trong bài test `QrStudioSourceTest.testCreateQrCodeCustomCodeIndexAndUniquenessObservation()`:
- Tạo 2 mã QR với cùng một `code = "MC-VIP-SPECIAL"`.
- Cả 2 request đều trả về HTTP 200 thành công thay vì từ chối với lỗi `409 CONFLICT` hoặc `DUPLICATE_CODE`.

### 3. Đánh giá rủi ro và khuyến nghị
- **Rủi ro:** Có thể dẫn đến xung đột khi khách hàng quét QR hoặc khi nhân viên đối chiếu mã bàn/quầy trong hệ thống.
- **Khuyến nghị:**
  - Kiểm tra `qrCodeRepository.findByCode(code)`.
  - Nếu đã tồn tại mã trong chi nhánh, ném `ApiException(HttpStatus.CONFLICT, "DUPLICATE_QR_CODE", "Mã QR này đã tồn tại trong hệ thống")`.
