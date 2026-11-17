# BÁO CÁO PHÁT HIỆN LỖI VÀ GHI NHẬN KIẾN TRÚC (SCRUM-234)

- **Mã Jira:** SCRUM-234
- **Tên User Story:** [E5.1] Kiểm thử mã nguồn studio thiết kế ấn phẩm QR
- **Thời điểm ghi nhận:** 17/11/2026
- **Môi trường:** Local Backend Spring Boot (Java 21 LTS)

---

## Danh sách lỗi và bất cập kiến trúc (Defect & Observation Summary)

| Mã ID | Tên lỗi / Vấn đề phát hiện | Phân loại | Mức độ nghiêm trọng (Severity) | Trạng thái (Status) | Thành phần bị ảnh hưởng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| `BUG-SCRUM234-01` | Thiếu kiểm tra định dạng tập tin và giới hạn dung lượng logo trong API lưu ấn phẩm QR | **BUG (Defect)** | **Medium** | **OPEN (Confirmed Bug)** | `PrintDesignController`, `PrintDesignRequestDto` |
| `OBS-SCRUM234-01` | API tạo mã QR (`createQrCode`) chưa kiểm tra tính duy nhất của mã `code` tùy chỉnh | **OBSERVATION** | **Low** | **OPEN (Observation)** | `QrCodeController.createQrCode`, `QrCodeRepository` |

---

## Chi tiết BUG-SCRUM234-01: Thiếu kiểm tra định dạng và dung lượng file logo

### 1. Phân loại và Lý do (Classification Justification)
- **Phân loại:** **BUG (Defect - Xác nhận vi phạm yêu cầu chức năng)**.
- **Căn cứ:** User Story SCRUM-234 (thuộc E5.1) quy định rõ trọng tâm kiểm thử số 4: *"Kiểm tra định dạng và kích thước file logo"*.
- **Hiện trạng:**
  - Trong `PrintDesignRequestDto`:
    ```java
    public record PrintDesignRequestDto(
        ...
        String logoUrl,
        ...
    )
    ```
  - Backend Spring Boot nhận trường `logoUrl` là một chuỗi thô (`String`), hoàn toàn không có bất kỳ annotation validation (`@Pattern`, `@URL`, validator tùy biến) hay logic kiểm tra tại Controller/Service đối với:
    1. Định dạng tập tin hình ảnh cho phép (chỉ cho phép các phần mở rộng `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`).
    2. Kích thước tập tin tối đa cho phép (dung lượng upload tối đa, ví dụ <= 2MB).
    3. Cú pháp URL an toàn (chặn các URL độc hại, file thực thi `.exe`, script nguy hiểm).
  - Đồng thời, trong `PrintExportService.java`, hàm `generateHighResPrintImage` hiện tại chưa tải và vẽ hình ảnh logo vào canvas ảnh in ấn độ phân giải cao.

### 2. Bằng chứng kiểm thử tự động (Proof of Concept)
Trong bài test `QrStudioSourceTest.testLogoValidationBackendLacksFormatAndSizeEnforcementObservation()` (`TC-234-08`):
- Gửi payload lưu thiết kế với `logoUrl = "https://malicious.example.com/payload.exe"`.
- Backend không ném bất kỳ ngoại lệ nào và trả về HTTP 200 OK kèm mã thành công.
- Kết quả kiểm thử: **Test Case FAIL** (Hệ thống vi phạm yêu cầu kiểm tra định dạng/dung lượng logo); **Automation test PASS** (Chứng minh và tái hiện được lỗi).

### 3. Đánh giá rủi ro và khuyến nghị
- **Rủi ro:** Người dùng có thể vô tình nhập URL file hỏng hoặc kẻ gian lợi dụng lưu trữ URL mã độc vào cơ sở dữ liệu hệ thống.
- **Khuyến nghị khắc phục:**
  - Bổ sung validation regex cho `logoUrl` trong DTO hoặc service: chỉ chấp nhận URL giao thức `https://` trỏ đến các định dạng ảnh hợp lệ.
  - Phối hợp với frontend/storage: kiểm tra kích thước file logo (<= 2MB) trước khi tải lên Supabase Storage và lưu vào `print_designs`.

---

## Chi tiết OBS-SCRUM234-01: Chưa kiểm tra tính duy nhất của mã QR tùy chỉnh

### 1. Phân loại và Lý do (Classification Justification)
- **Phân loại:** **OBSERVATION (Rủi ro kiến trúc / Chưa đủ bằng chứng đặc tả)**.
- **Căn cứ:**
  - Trọng tâm số 2 của User Story *"Không tạo QR trùng nếu chi nhánh đã có mã"* được thiết kế nhằm giải quyết bài toán chống tạo trùng mã QR mặc định khi mở studio ấn phẩm D3-09 (`ensureDefaultQrCode`). Chức năng này đã được kiểm tra và đạt 100% tại `TC-234-03`.
  - Đối với API `POST /api/v1/qr-codes` khi người dùng tự nhập mã `code` tùy chỉnh, tài liệu User Story E5.1 chưa có đặc tả quy định cấm đặt trùng mã giữa các bàn/quầy hoặc quy định mã lỗi HTTP cần trả về (ví dụ: `409 Conflict`).
  - Do đó, hiện tượng này được phân loại chính xác là **OBSERVATION (Rủi ro toàn vẹn dữ liệu)** thay vì BUG trực tiếp.

### 2. Bằng chứng kiểm thử tự động (Proof of Concept)
Trong bài test `QrStudioSourceTest.testCreateQrCodeCustomCodeIndexAndUniquenessObservation()` (`TC-234-04`):
- Tạo 2 mã QR liên tiếp với cùng một `code = "MC-VIP-SPECIAL"` trong cùng một chi nhánh.
- Cả 2 request đều trả về HTTP 200 OK.
- Trong `QrCodeRepository`: bản ghi thứ hai được lưu thành công, nhưng chỉ mục `codeIndex` bị ghi đè trỏ sang ID mới nhất, làm lu mờ bản ghi ban đầu khi tra cứu qua `findByCode`.

### 3. Đánh giá rủi ro và khuyến nghị
- **Rủi ro:** Khi 2 vị trí trùng mã code, việc tra cứu mã qua survey funnel (`/survey?qr={code}`) sẽ luôn trỏ về bản ghi sau cùng, gây sai lệch thống kê khảo sát theo vị trí.
- **Khuyến nghị khắc phục:**
  - Bổ sung kiểm tra `qrCodeRepository.findByCode(code)`. Nếu mã đã tồn tại trong cùng chi nhánh, trả về mã lỗi `409 Conflict` kèm thông báo `"Mã QR này đã tồn tại trong chi nhánh"`.
