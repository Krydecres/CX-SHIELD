# TEST CASES: SCRUM-222 - Kiểm thử mã nguồn phân luồng 4–5 sao và ghi nhận lượt chuyển Google

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-222
- **Đối tượng kiểm thử:** Backend (`SurveyController.java`, `SurveyServiceImpl.java`)

## Danh sách Kịch bản Kiểm thử (White-box & Integration)

| Mã TC | Tên Kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-222-01** | Phân luồng rating 5 sao | Gọi POST `/api/v1/surveys/rate` với `starRating = 5` | Server trả về `targetScreen = M1-02`, `sentimentGroup = POSITIVE` | **PASS** |
| **TC-222-02** | Phân luồng rating 4 sao | Gọi POST `/api/v1/surveys/rate` với `starRating = 4` | Server trả về `targetScreen = M1-02`, `sentimentGroup = POSITIVE` | **PASS** |
| **TC-222-03** | Xác minh thông điệp gợi ý Google Review | Kiểm tra `data.message` trong response rating 4-5 sao | Chứa hướng dẫn khách chia sẻ trải nghiệm lên Google Maps | **PASS** |
| **TC-222-04** | Kiểm tra chính sách Review Gating (Không tặng Voucher với 5 sao) | Rà soát payload trả về khi rating 5 sao | Response không chứa thông tin voucher hay quà tặng miễn phí kèm theo | **PASS** |
| **TC-222-05** | Chặn rating vượt biên trên (6 sao) | Gọi API rate với `starRating = 6` | Server trả lỗi `400 Bad Request` | **PASS** |
| **TC-222-06** | Chặn rating biên dưới không hợp lệ (0 sao) | Gọi API rate với `starRating = 0` | Server trả lỗi `400 Bad Request` | **PASS** |