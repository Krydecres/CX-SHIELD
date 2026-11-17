# BÁO CÁO KẾT QUẢ KIỂM THỬ CHỨC NĂNG – SCRUM-223

- **Nhiệm vụ:** [E1.2] Kiểm thử chức năng màn 4–5 sao và chuyển sang Google Maps
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 17/11/2026
- **Story cha:** SCRUM-123 (E1.2) | **Task code phụ thuộc:** `SCRUM-208`
- **Thiết bị kiểm thử thật:** Samsung Galaxy A07 (Android 16)

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 5 (100%)
- **Số case FAIL:** 0 (0%)
- **Số Bug phát hiện:** 0
- **Kết quả Flutter Widget Test:** 5/5 tests **PASS**

## 2. CHI TIẾT THỰC THI & BẰNG CHỨNG
1. **Kiểm thử trên thiết bị thật (Samsung Galaxy A07 – Android 16):**
   - **Đạt (5/5 – `TC-223-01` đến `TC-223-04`):** Chọn 4 sao và 5 sao đều vào đúng màn `M1-02`; hiển thị đầy đủ câu gợi ý từ bộ từ khóa; bấm sao chép lưu đúng nội dung vào Clipboard; nút mở Google Maps trỏ đúng trang `writereview` theo `placeid` của cơ sở và ghi nhận lượt bấm; xác nhận link không chọn sẵn sao, không điền sẵn nội dung và không có voucher gắn với 5 sao.
   - **Lỗi (0/5 – `TC-223-05`)**
2. **Log chạy Flutter Widget Test (`frontend/test/m1_02_google_review_screen_test.dart`):**

```text
h-22259841:~/h/CX-SHIELD/frontend{cuong}$ flutter test test/m1_02_google_review_screen_test.dart
00:08 +5: All tests passed!
```

## 3. KẾT LUẬN & ĐỀ XUẤT
Đã hoàn tất kiểm thử chức năng trên thiết bị thật Samsung Galaxy A07 (Android 16) và bộ Flutter Widget Test (5/5 passed)
