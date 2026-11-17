# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG STUDIO THIẾT KẾ ẤN PHẨM QR (SCRUM-235)

- **Mã Jira:** SCRUM-235
- **Tên User Story:** [E5.1] Kiểm thử chức năng studio thiết kế ấn phẩm QR
- **Phân hệ:** Giao diện quản lý & Studio ấn phẩm (Màn hình D3-09 · `/print-materials`)
- **Thời điểm thực hiện:** 17/11/2026
- **Kỹ sư QA phụ trách:** QA Engineer – CX-SHIELD Team
- **Môi trường thực thi:**
  - Framework: Flutter 3.29.x, Dart 3.7.x
  - Runner: Flutter Widget Test Runner với MockClient HTTP Client
  - Viewport: Desktop 1280 x 1600 px

---

## 1. Tóm tắt kết quả kiểm thử (Executive Summary)

| Chỉ số đo lường (Metric) | Giá trị thực tế | Tỷ lệ (%) | Ghi chú đánh giá |
| :--- | :---: | :---: | :--- |
| **Tổng số Test Cases thiết kế (Designed TCs)** | **12** | **100%** | Đồng bộ chính xác 1:1 với 12 test methods trong `d3_09_qr_studio_functional_test.dart` |
| - Số Test Cases ĐẠT (PASS)** | **10** | **83.3%** | Hoàn thành tốt các tính năng mở màn, tạo QR, đổi mẫu Standee/Sticker/NFC, CTA, Live Preview, lưu và nạp mẫu |
| - Số Test Cases KHÔNG ĐẠT (FAIL)** | **1** | **8.3%** | `TC-235-12`: Giao diện thiếu validation chặn URL logo sai định dạng (BUG-SCRUM235-01) |
| - Số Test Cases CHƯA CHẠY (NOT RUN)** | **1** | **8.3%** | `TC-235-11`: Thao tác quét camera điện thoại thật ngoài đời (Môi trường test thiếu thiết bị di động vật lý) |
| - Số Test Cases BỊ CHẶN (BLOCKED)** | **0** | **0%** | Không có ca kiểm thử nào bị chặn luồng nghiệp vụ |
| **Số Automation Tests mới (SCRUM-235)** | **12 / 12** | **100% PASS** | 12 tests chạy thành công trên `d3_09_qr_studio_functional_test.dart` |
| **Số Automation Tests hồi quy Frontend** | **6 / 6** | **100% PASS** | 6 tests chạy thành công trên `d3_09_qr_studio_test.dart` |
| **Số Automation Tests hồi quy Backend** | **30 / 30** | **100% PASS** | 30 tests backend (`QrStudioSourceTest`, `QrCodeControllerTest`, `PrintDesignControllerTest`) |
| **Tổng số Automation Tests thực thi** | **48 / 48** | **100% PASS** | Toàn bộ 48 tests (18 frontend + 30 backend) đều hoàn thành 100% |
| **Lỗi & Kiến trúc ghi nhận (Defects & Observations)** | **2** | **1 Bug + 1 Obs** | `BUG-SCRUM235-01` (Confirmed Bug - Medium) & `OBS-SCRUM235-01` (Observation - Low) |
| **Sửa đổi Production Code** | **KHÔNG** | **0 lines** | Tuyệt đối tuân thủ nguyên tắc không can thiệp sửa production code |

---

## 2. Bảng đối chiếu chi tiết 12 Test Cases SCRUM-235

| STT / Test ID | Test Method trong code | Mục tiêu kiểm định | Kết quả TC | Kết quả Auto | Phân loại chức năng |
| :---: | :--- | :--- | :---: | :---: | :--- |
| `TC-235-01` | `TC-235-01: Mở màn D3-09, tải danh sách QR và hiển thị Live Preview` | Mở màn D3-09, tải QR mặc định, nạp mẫu thiết kế đã lưu | **PASS** | **PASS** | 1. Mở màn D3-09 |
| `TC-235-02` | `TC-235-02: Mở Dialog và tạo mã QR vị trí mới cho chi nhánh` | Mở Dialog, nhập tên/loại QR, gọi POST /api/v1/qr-codes tạo mã | **PASS** | **PASS** | 2. Tạo mã QR |
| `TC-235-03` | `TC-235-03: Chọn khung mẫu Standee Để Bàn (TABLE_TENT)` | Chuyển đổi khung Standee bàn tam giác A6, chân đế gỗ/mica | **PASS** | **PASS** | 3. Khung mẫu Standee |
| `TC-235-04` | `TC-235-04: Chọn khung mẫu Sticker Dán Quầy và Thẻ Chạm NFC` | Chuyển sang decal tròn 270px cho Sticker và gradient cho Thẻ NFC | **PASS** | **PASS** | 4. Sticker & Thẻ NFC |
| `TC-235-05` | `TC-235-05: Thêm đường dẫn logo hợp lệ và hiển thị trên banner Live Preview` | Nhập URL ảnh HTTPS, render ClipRRect 32x32px trong banner | **PASS** | **PASS** | 5. Thêm logo |
| `TC-235-06` | `TC-235-06: Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh cập nhật Live Preview trực tiếp` | Nhập CTA hoặc chọn chip gợi ý nhanh cập nhật real-time | **PASS** | **PASS** | 6. Chỉnh sửa CTA |
| `TC-235-07` | `TC-235-07: Kiểm tra Live Preview cập nhật màu sắc nhận diện thương hiệu real-time` | Chọn ChoiceChip màu (Nâu, Đỏ Rượu,...), preview đổi màu tức thì | **PASS** | **PASS** | 7. Live Preview real-time |
| `TC-235-08` | `TC-235-08: Lưu mẫu thiết kế và lưu bản sao mới thành công` | Bấm Lưu mẫu thiết kế và Lưu bản sao mới vào print_designs | **PASS** | **PASS** | 8. Lưu thiết kế |
| `TC-235-09` | `TC-235-09: Nạp lại mẫu thiết kế đã lưu phục hồi đầy đủ dữ liệu lên form và Live Preview` | Bấm "Nạp mẫu này", điền lại toàn bộ thông số lên form và đổi preview | **PASS** | **PASS** | 9. Mở lại mẫu đã lưu |
| `TC-235-10` | `TC-235-10: Xóa mẫu thiết kế ấn phẩm thành công khỏi danh sách` | Nhấn icon xóa, gọi DELETE /api/v1/print-designs/{id}, cập nhật list | **PASS** | **PASS** | 9. Quản lý mẫu |
| `TC-235-11` | `TC-235-11: Thử nghiệm quét QR kích hoạt điều hướng màn khảo sát M1-01` | Điều hướng /survey?qr={code} (In-App) / Quét camera điện thoại thật | **PASS (In-App)** / **NOT RUN (Physical)** | **PASS** | 10. Quét QR mở M1-01 |
| `TC-235-12` | `TC-235-12: Nhập logo sai định dạng không làm crash giao diện (hiển thị fallback error icon)` | Nhập URL .exe sai định dạng (Thiếu validation chặn ở giao diện) | **FAIL (Bug)** | **PASS (Proof)** | 11-12. Thử logo sai / lớn |

---

## 3. Kết quả kiểm thử tự động thực tế (Execution Output)

### 3.1. Kết quả thực thi `frontend/test/d3_09_qr_studio_functional_test.dart` (12 tests)
```text
00:00 +0: loading C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/d3_09_qr_studio_functional_test.dart
00:00 +0: TC-235-01: Mở màn D3-09, tải danh sách QR và hiển thị Live Preview
00:02 +1: TC-235-02: Mở Dialog và tạo mã QR vị trí mới cho chi nhánh
00:03 +2: TC-235-03: Chọn khung mẫu Standee Để Bàn (TABLE_TENT)
00:04 +3: TC-235-04: Chọn khung mẫu Sticker Dán Quầy và Thẻ Chạm NFC
00:05 +4: TC-235-05: Thêm đường dẫn logo hợp lệ và hiển thị trên banner Live Preview
00:06 +5: TC-235-06: Chỉnh sửa CTA và chọn gợi ý chip CTA nhanh cập nhật Live Preview trực tiếp
00:06 +6: TC-235-07: Kiểm tra Live Preview cập nhật màu sắc nhận diện thương hiệu real-time
00:07 +7: TC-235-08: Lưu mẫu thiết kế và lưu bản sao mới thành công
00:07 +8: TC-235-09: Nạp lại mẫu thiết kế đã lưu phục hồi đầy đủ dữ liệu lên form và Live Preview
00:08 +9: TC-235-10: Xóa mẫu thiết kế ấn phẩm thành công khỏi danh sách
00:08 +10: TC-235-11: Thử nghiệm quét QR kích hoạt điều hướng màn khảo sát M1-01
00:08 +11: TC-235-12: Nhập logo sai định dạng không làm crash giao diện (hiển thị fallback error icon)
00:09 +12: All tests passed!
```

### 3.2. Kết quả kiểm thử hồi quy `frontend/test/d3_09_qr_studio_test.dart` (6 tests)
```text
00:00 +0: loading C:/Users/dnccr/OneDrive/Desktop/New folder/CX-SHIELD-GIT/frontend/test/d3_09_qr_studio_test.dart
00:00 +0: E5.1: Hiển thị đầy đủ Studio D3-09, tải danh sách QR và Live Preview ma trận QR
00:02 +1: E5.1: Chuyển đổi khung mẫu sang Sticker Dán Quầy và Thẻ Chạm NFC cập nhật Live Preview tương ứng
00:03 +2: E5.1: Tạo mã QR mới cho chi nhánh khi bấm nút "Tạo mã QR"
00:04 +3: E5.1: Chọn câu gợi ý CTA nhanh và cập nhật màu nhận diện thương hiệu
00:04 +4: E5.1: Lưu mẫu thiết kế ấn phẩm vào print_designs thành công
00:05 +5: E5.1: Quét QR trên bản xem trước mở đúng màn khảo sát M1-01
00:05 +6: All tests passed!
```

---

## 4. Những phạm vi chưa kiểm thử được (Out of Scope / Limitations)

1. **Quét trực tiếp bằng camera vật lý của điện thoại ngoài đời thực (`TC-235-11`):**
   - Môi trường máy chủ thử nghiệm cục bộ không có thiết bị điện thoại vật lý kết nối để thực hiện thao tác giơ camera quét màn hình.
   - Trạng thái kiểm thử quang học ngoài đời thực được ghi nhận là **NOT RUN**.
   - Thay vào đó, chức năng đã được kiểm chứng thông qua nút *"Thử nghiệm quét QR: Mở màn khảo sát M1-01"* và kiểm tra giải mã ma trận QR ZXing đạt 100% độ chính xác đối với URL đích `https://cxshield.vn/survey?qr=...`.
2. **Kiểm thử tải ảnh trực tiếp từ máy (File Picker):**
   - Hiện tại giao diện D3-09 chỉ có trường nhập link ảnh dạng chuỗi URL, chưa có nút bấm chọn file cục bộ từ bộ nhớ máy tính để kiểm tra giới hạn kích thước file upload. Ghi nhận `OBS-SCRUM235-01`.
