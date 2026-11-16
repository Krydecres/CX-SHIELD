# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN – SCRUM-225

- **Nhiệm vụ:** [E4.3] Kiểm thử mã nguồn từ khóa gợi ý và ngưỡng chia luồng
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 16/11/2026
- **Task code phụ thuộc:** `SCRUM-212`
- **Trạng thái kiểm thử:** **BLOCKED**

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 0
- **Số case FAIL:** 0
- **Số case BLOCKED:** 5 (100%)
- **Số Bug phát hiện:** 0 (Chưa đủ điều kiện mã nguồn để thực thi kiểm thử)

## 2. BẰNG CHỨNG RÀ SOÁT MÃ NGUỒN (CODE INSPECTION)
1. **Cơ sở dữ liệu (`database/`):**
   - Đã rà soát toàn bộ các tệp SQL (`n1_khao_sat.sql`, `n1_feedback_topics.sql`, `n3_thiet_lap.sql`, `n3_onboarding_google_place.sql`, `n4_canh_bao.sql`, `n5_dashboard.sql`, `n5_thanh_toan.sql`).
   - Chưa tồn tại bảng `review_keywords` và bảng `routing_rules`.
2. **Backend (`backend/src/main/java/com/cxshield/backend/`):**
   - Chưa có package/Controller/Service/Repository xử lý CRUD bộ từ khóa gợi ý theo ngành và cấu hình ngưỡng chia luồng cảm xúc.
   - Tại `SurveyServiceImpl.java` (dòng 117), quy tắc phân luồng hiện đang cố định cứng bằng biểu thức `boolean isPositive = stars >= 4;`, chưa truy vấn quy tắc động theo cơ sở/chi nhánh.
   - Chưa có bộ Unit Test của task code `SCRUM-212` trong `backend/src/test/java/com/cxshield/backend/`.

## 3. KẾT LUẬN & ĐỀ XUẤT
Chuyển trạng thái task `SCRUM-225` sang **Blocked** trên Jira để chờ hoàn tất và merge mã nguồn của `SCRUM-212`. Ngay sau khi `SCRUM-212` chuyển sang *In Review*, QA sẽ tiến hành rà soát mã nguồn và chạy Unit Test cho toàn bộ 5 kịch bản trên.