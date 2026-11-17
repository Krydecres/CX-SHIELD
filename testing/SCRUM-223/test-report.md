# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG – SCRUM-223

- **Nhiệm vụ:** [E1.2] Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 17/11/2026
- **Story cha:** SCRUM-123 (E1.2) | **Task code phụ thuộc:** `SCRUM-208`
- **Thiết bị kiểm thử thật:** Samsung Galaxy A07 (Android 16)

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 4 (80%)
- **Số case FAIL:** 1 (20%)
- **Số Bug phát hiện:** 1 (`BUG-SCRUM-189-01` – tái hiện lỗi treo vòng xoay `"Đang chuyển tiếp..."` vô tận sau khi bấm `"← Trở lại khảo sát"` và chọn lại 4 sao)
- **Kết quả Flutter Widget Test:** 5/5 tests **PASS**

## 2. CHI TIẾT THỰC THI & BẰNG CHỨNG
1. **Kiểm thử trên thiết bị thật (Samsung Galaxy A07 – Android 16):**
   - **Đạt (4/5 – `TC-223-01` đến `TC-223-04`):** Chọn 4 sao và 5 sao đều vào đúng màn `M1-02`; hiển thị đầy đủ câu gợi ý từ bộ từ khóa; bấm sao chép lưu đúng nội dung vào Clipboard; nút mở Google Maps trỏ đúng trang `writereview` theo `placeid` của cơ sở và ghi nhận lượt bấm; xác nhận link không chọn sẵn sao, không điền sẵn nội dung và không có voucher gắn với 5 sao.
   - **Lỗi (1/5 – `TC-223-05`):** Trên thiết bị thật Samsung Galaxy A07, sau khi từ màn `M1-02` bấm nút `"← Trở lại khảo sát"` quay về `M1-01` và chạm chọn lại `4 sao`, giao diện sáng 4 sao kèm nhãn `"😊 Hài lòng"` nhưng vòng xoay `"Đang chuyển tiếp..."` quay vô tận, không điều hướng sang `M1-02` và không hiển thị thông báo lỗi (đã thu thập bằng chứng ảnh chụp màn hình).
2. **Log chạy Flutter Widget Test (`frontend/test/m1_02_google_review_screen_test.dart`):**

```text
h-22259841:~/h/CX-SHIELD/frontend{cuong}$ flutter test test/m1_02_google_review_screen_test.dart
00:08 +5: All tests passed!
```

## 3. KẾT LUẬN & ĐỀ XUẤT
Đã hoàn tất kiểm thử chức năng trên thiết bị thật Samsung Galaxy A07 (Android 16) và bộ Flutter Widget Test (5/5 passed). Ghi nhận 1 lỗi điều hướng/trạng thái loading (`BUG-SCRUM-189-01` tại `TC-223-05`) để đội phát triển xử lý trước khi nghiệm thu hoàn tất hạng mục E1.2.