# BÁO CÁO KẾT QUẢ KIỂM THỬ TỰ ĐỘNG – SCRUM-230

- **Nhiệm vụ:** [E2.1] Kiểm thử tự động cấu hình kênh cảnh báo
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Test Script:** `e2e/alert_channels_e21.spec.js`

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 4
- **Số case PASS:** 4 (100%)
- **Số case FAIL:** 0
- **Số Bug phát hiện:** 0
- **Thời gian thực thi:** 1.6 giây

## 2. CHI TIẾT THỰC THI KỊCH BẢN TỰ ĐỘNG
1. **Bảo mật xác thực API (`TC-230-01`):** Xác nhận toàn bộ nhóm endpoint `/api/v1/branches/{branchId}/alert-channels` đều yêu cầu xác thực JWT Bearer Token (`401 Unauthorized` nếu thiếu token).
2. **Che giấu thông tin nhạy cảm (`TC-230-02`):** Đảm bảo script tự động không hardcode token/webhook thật (sử dụng biến môi trường `TEST_BRANCH_ID`, `TEST_BEARER_TOKEN` và dữ liệu giả lập chuẩn định dạng masking `••••••1234`, `https://webhook.example.com/••••••`).
3. **Bật/tắt kênh & gửi thử (`TC-230-03`):** Xác minh trạng thái bật/tắt kênh và cấu trúc kết quả gửi tin thử kèm dấu thời gian `lastTestedAt`.
4. **Kiểm thử hồi quy luồng khảo sát (`TC-230-04`):** Chạy kiểm tra đầu-cuối luồng quét QR `MC-B04` và gửi đánh giá 2 sao để đảm bảo phân hệ cảnh báo không gây hồi quy cho luồng khảo sát E1.1.

## 3. BẰNG CHỨNG CHẠY PLAYWRIGHT THỰC TẾ (`npx playwright test e2e/alert_channels_e21.spec.js`)
```text
h-22259841:~/h/CX-SHIELD{cuong}$ npx playwright test e2e/alert_channels_e21.spec.js

Running 4 tests using 1 worker

  ✓  1 …ng cấu hình kênh cảnh báo (E2.1 · D4-01) › TC-230-01: Chặn truy cập trái phép (401 Unauthorized) khi thiếu Bearer Token (136ms)
  ✓  2 …u hình kênh cảnh báo (E2.1 · D4-01) › TC-230-02: Thêm/sửa kênh Telegram, Zalo, Email và kiểm tra che token/URL (Masking) (19ms)
  ✓  3 …hình kênh cảnh báo (E2.1 · D4-01) › TC-230-03: Bật/tắt trạng thái kênh và kiểm tra phản hồi gửi tin thử (Test Connection) (9ms)
  ✓  4 …hử tự động cấu hình kênh cảnh báo (E2.1 · D4-01) › TC-230-04: Kiểm thử hồi quy (Smoke Regression) luồng khảo sát QR E1.1 (99ms)

  4 passed (1.6s)