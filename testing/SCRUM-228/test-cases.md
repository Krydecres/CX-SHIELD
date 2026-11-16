# TEST CASES: SCRUM-228 – Kiểm thử mã nguồn cấu hình kênh cảnh báo

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-228 (Story cha: SCRUM-126 – E2.1)
- **Đối tượng kiểm thử:**
  - Backend: `AlertChannelController.java`, `AlertChannelService.java`, `AlertMasking.java`, `WebhookUrlValidator.java`, `AlertDtos.java`, `database/n4_canh_bao.sql`
  - Unit Test Scripts: `AlertChannelControllerTest.java`, `AlertChannelServiceTest.java`, `AlertMaskingTest.java`, `WebhookUrlValidatorTest.java`, `AlertSendersTest.java`

## Danh sách Kịch bản Kiểm thử Mã nguồn (White-box, Security & Unit Test)

| Mã TC | Tên kịch bản | Cách thức kiểm tra & Điểm rà soát | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-228-01** | Lưu kênh Telegram / Zalo / Email theo chi nhánh & kiểm tra đầu vào | Rà soát `AlertChannelService.save()`, `validatedValues()` (L73–153) và `WebhookUrlValidator.validate()` (L22–33); chạy `AlertChannelServiceTest`, `WebhookUrlValidatorTest` | Lưu đúng từng loại kênh theo `branch_id`; từ chối token/chatId/email sai định dạng (`422`) và chặn Zalo Webhook URL không phải `https` hoặc trỏ vào IP mạng nội bộ (chống SSRF) | **PASS** |
| **TC-228-02** | Che token & URL sau khi lưu, không lộ bí mật qua API hoặc log | Rà soát `AlertMasking.java` (L14–31), `AlertChannelService.toResponse()` (L167–170) và chạy `AlertMaskingTest`, `AlertChannelControllerTest#requestToStringHidesSecrets` | Token trả về dạng `••••••<4 ký tự cuối>`, URL trả về `https://<host>/••••••`; `toString()` của request che toàn bộ secret để không ghi ra log | **PASS** |
| **TC-228-03** | Bật / tắt trạng thái kênh (`is_enabled`) & giữ secret cũ khi cập nhật | Rà soát `AlertChannelService.save()` (L77, L117–120, L130–132) và chạy `AlertChannelServiceTest#keepsSavedTokenWhenLeftBlank` | Cập nhật đúng cột `is_enabled`; khi sửa trạng thái bật/tắt mà để trống `botToken` hoặc `webhookUrl`, hệ thống giữ nguyên giá trị cũ trong DB | **PASS** |
| **TC-228-04** | Ngưỡng cảnh báo mặc định dưới 4 sao | Rà soát `AlertChannelService.DEFAULT_THRESHOLD_STAR` (L34), `getChannels()` (L67–69) và chạy `AlertChannelServiceTest#listsAllThreeChannelTypesWithDefaultThreshold` | Khi chi nhánh chưa có dòng cấu hình trong `alert_rules`, API trả về ngưỡng mặc định `thresholdStar = 4` (cảnh báo khi `< 4` sao) | **PASS** |
| **TC-228-05** | Gửi thử tin mẫu (`sendTest`), lưu `last_tested_at` & xử lý lỗi gửi | Rà soát `AlertChannelService.sendTest()` (L92–107) và chạy `AlertChannelServiceTest#sendTestStoresLastTestedAt`, `failedTestKeepsOldTimestampAndReturnsReason` | Gửi thành công cập nhật `last_tested_at = now()`; khi gửi lỗi (`AlertSendException`), API trả `success = false` kèm lý do rõ ràng và giữ nguyên `last_tested_at` cũ | **PASS** |
| **TC-228-06** | Phân quyền truy cập theo cơ sở/chi nhánh & chạy bộ Unit Test task code | Rà soát `requireBranch()` (L155–158), RLS policy tại `database/n4_canh_bao.sql` (L108–114) và chạy toàn bộ 56 unit tests | Chỉ `OWNER` và `BRANCH_MANAGER` thuộc chi nhánh mới được cấu hình (trái quyền trả `403 Forbidden` / `404`); 56/56 unit tests chạy xanh | **PASS** |