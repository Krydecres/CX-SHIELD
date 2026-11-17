# BÁO CÁO PHÁT HIỆN LỖI VÀ GHI NHẬN KIẾN TRÚC GIAO DIỆN D3-09 (SCRUM-235)

- **Mã Jira:** SCRUM-235
- **Tên User Story:** [E5.1] Kiểm thử chức năng studio thiết kế ấn phẩm QR
- **Phân hệ:** Giao diện người dùng Flutter (Màn hình D3-09 · `/print-materials`)
- **Thời điểm ghi nhận:** 17/11/2026
- **Môi trường:** Flutter Web Desktop / Widget Test Runner

---

## Danh sách lỗi và bất cập kiến trúc (Defect & Observation Summary)

| Mã ID | Tên lỗi / Vấn đề phát hiện | Phân loại | Mức độ nghiêm trọng (Severity) | Trạng thái (Status) | Thành phần bị ảnh hưởng |
| :---: | :--- | :---: | :---: | :---: | :--- |
| `BUG-SCRUM235-01` | Giao diện D3-09 thiếu validation định dạng và dung lượng logo, cho phép lưu URL file không hợp lệ | **BUG (Defect)** | **Medium** | **OPEN (Confirmed Bug)** | `D309QrStudioPage` (`_logoUrlController`), `d3_09_qr_studio_page.dart` |
| `OBS-SCRUM235-01` | D3-09 chỉ hỗ trợ nhập URL ảnh thô, thiếu nút tải tệp từ máy kèm giới hạn dung lượng <= 2MB | **OBSERVATION** | **Low** | **OPEN (Observation)** | `D309QrStudioPage` (Logo Form Field) |

---

## Chi tiết BUG-SCRUM235-01: Giao diện D3-09 thiếu validation định dạng logo

### 1. Phân loại và Lý do (Classification Justification)
- **Phân loại:** **BUG (Defect - Xác nhận vi phạm yêu cầu chức năng)**.
- **Căn cứ:** User Story E5.1 (SCRUM-134/213) yêu cầu: *"Kiểm tra định dạng và kích thước file logo"*.
- **Hiện trạng:**
  - Trên màn hình D3-09, trường nhập logo được khai báo như sau:
    ```dart
    const FormLabel('Logo cơ sở (URL ảnh)'),
    TextField(
      controller: _logoUrlController,
      decoration: const InputDecoration(
        hintText: 'Nhập URL hình ảnh logo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.image_outlined),
      ),
      onChanged: (_) => setState(() {}),
    ),
    ```
  - Ô input hoàn toàn không có `FormValidator` kiểm tra phần mở rộng file (chỉ cho phép `.png`, `.jpg`, `.jpeg`, `.webp`, `.svg`).
  - Khi người dùng nhập đường dẫn file thực thi như `https://malicious.example.com/payload.exe`, giao diện không hiển thị bất kỳ cảnh báo lỗi nào.
  - Khi nhấn nút `'Lưu mẫu thiết kế'`, giao diện vẫn gửi request `POST /api/v1/print-designs` chứa đường dẫn nguy hiểm này lên máy chủ và lưu thành công.

### 2. Bằng chứng kiểm thử tự động (Proof of Concept)
Trong bài test `TC-235-12` (`d3_09_qr_studio_functional_test.dart`):
- Nhập text `'https://malicious.example.com/payload.exe'` vào trường `_logoUrlController`.
- Giao diện không kích hoạt validation error nào, hiển thị icon ngôi sao fallback `Icons.star_rounded` trong `Image.network(errorBuilder: ...)`.
- Nút bấm `'Lưu mẫu thiết kế'` vẫn ở trạng thái enabled và cho phép gửi dữ liệu lên backend.

### 3. Đánh giá rủi ro và khuyến nghị
- **Rủi ro:** Người dùng có thể vô tình nhập URL file hỏng hoặc liên kết mã độc, dẫn đến bản in ấn phẩm bị mất logo hoặc chứa dữ liệu không an toàn.
- **Khuyến nghị khắc phục:**
  - Bổ sung validation regex cho `_logoUrlController`: yêu cầu bắt đầu bằng `http://` hoặc `https://` và kết thúc bằng đuôi ảnh hợp lệ.
  - Nếu URL không hợp lệ, hiển thị `errorText` inline màu đỏ và vô hiệu hóa nút `'Lưu mẫu thiết kế'`.

---

## Chi tiết OBS-SCRUM235-01: Thiếu bộ chọn tệp (File Picker) từ máy tính kèm kiểm tra kích thước

### 1. Phân loại và Lý do (Classification Justification)
- **Phân loại:** **OBSERVATION (Trải nghiệm người dùng & Kiến trúc)**.
- **Hiện trạng:**
  - Hiện tại màn D3-09 chỉ cung cấp duy nhất 1 ô nhập chuỗi URL (`TextField`). Chủ cơ sở kinh doanh F&B thường lưu trữ file logo trên máy tính hoặc điện thoại, không có sẵn URL hình ảnh host trên cloud.
  - Người dùng không có nút `'Tải ảnh từ máy'` (Upload logo) để tải trực tiếp ảnh từ máy tính lên Supabase Storage bucket `business-assets`.
- **Rủi ro:** Trải nghiệm người dùng gặp trở ngại lớn khi phải tự tìm dịch vụ lưu trữ ảnh bên ngoài để lấy link dán vào studio.
- **Khuyến nghị:** Bổ sung nút `'Tải logo lên'` tích hợp thư viện `file_picker` hoặc `image_picker`, đồng thời validate dung lượng file <= 2MB trước khi upload.
