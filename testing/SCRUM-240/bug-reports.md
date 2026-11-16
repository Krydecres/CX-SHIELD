# BÁO CÁO LỖI VÀ GHI NHẬN KỸ THUẬT (BUG REPORTS & OBSERVATIONS)

- **Mã Jira:** SCRUM-240
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người lập:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026 (Cập nhật sau Final QA Audit)
- **Trạng thái kiểm định:** Đã hoàn tất thực thi kiểm thử trên môi trường local (37/37 automated tests passed, 0 failures). Chưa ghi nhận Confirmed Defect nào.

---

## 1. Danh Sách Lỗi Chính Thức (Confirmed Defects)

> [!IMPORTANT]
> **Nguyên tắc phân loại lỗi:**
> - Kết quả chạy thực tế 37 automated tests (20 Backend, 17 Frontend) đều PASS, do đó **chưa có lỗi chính thức (Confirmed Bug)** nào được xác nhận.
> - Các bất thường phát hiện qua việc đọc và phân tích mã nguồn được phân loại chuẩn mực thành:
>   - **Điểm bất thường trong mã nguồn (Code Anomaly / High Risk):** Vấn đề tiềm ẩn rủi ro logic trong kiến trúc mã nguồn. Chưa ghi nhận là bug chính thức vì chưa được tái hiện bằng integration test trên PostgreSQL thật.
>   - **Vấn đề quan sát kỹ thuật (Technical Observation):** Các quan sát về hiển thị giao diện hoặc căn chỉnh yêu cầu nghiệp vụ UX.
> - Không tự ý sinh mã Bug ID Jira khi chưa có lỗi tái hiện xác nhận từ PO / Lead.

| Phân loại | Số lượng | Diễn giải chi tiết |
| :--- | :---: | :--- |
| **Tổng số Lỗi chính thức (Confirmed Defects)** | **0** | Đã chạy 37 unit/widget tests thành công 100%, không phát sinh lỗi |
| **Bất thường mã nguồn cần xác minh (Code Anomalies)** | **1** | OBS-SCRUM-240-01 (High Risk): Nguy cơ đếm trùng số liệu do LEFT JOIN và thiếu UNIQUE(session_id) |
| **Vấn đề quan sát kỹ thuật (Technical Observations)** | **1** | OBS-SCRUM-240-02 (Medium / UX): Thẻ Google hiển thị snapshot tuần mới nhất khác với tổng tích lũy của các thẻ khác |

---

## 2. Chi Tiết Điểm Bất Thường Mã Nguồn Cần Xác Minh (Code Anomalies)

### OBS-SCRUM-240-01: Nguy cơ đếm trùng số liệu do sử dụng phép `LEFT JOIN` kết hợp thiếu ràng buộc `UNIQUE`

- **Mã định danh nội bộ:** `OBS-SCRUM-240-01`
- **Loại vấn đề:** Bất thường cấu trúc mã nguồn (Code Anomaly / High Risk) – *Chưa phải Confirmed Bug do chưa tái hiện bằng integration test trên PostgreSQL thật.*
- **Mức độ nghiêm trọng dự kiến:** High (nếu xảy ra sẽ làm sai lệch các chỉ số KPI cốt lõi của Dashboard)
- **Vị trí mã nguồn liên quan:**
  1. `database/n5_dashboard.sql` (dòng 48–64):
     ```sql
     rows_by_session as (
       select
         date_trunc('week', ss.scan_date)::date as week_start,
         r.star_rating,
         r.redirect_clicked_at
       from sessions ss
       left join public.survey_responses r on r.session_id = ss.id
     ),
     weekly as (
       select
         week_start,
         count(*)::int as scan_count,
         count(star_rating)::int as rated_count,
         (count(*) filter (where star_rating >= 4))::int as satisfied_count,
         (count(*) filter (where redirect_clicked_at is not null))::int as google_redirect_count
       from rows_by_session
       group by week_start
     )
     ```
  2. `database/n1_khao_sat.sql` (dòng 25–39) & `database/99_foreign_keys.sql` (dòng 26–28):
     - Bảng `survey_responses` chỉ có `FOREIGN KEY (session_id) REFERENCES survey_sessions(id)`.
     - **Hoàn toàn không có ràng buộc `UNIQUE(session_id)`**, không có Unique Index hay Trigger chặn bản ghi trùng.
  3. `backend/src/main/java/com/cxshield/backend/service/impl/SurveyServiceImpl.java` (dòng 127–145):
     - Phương thức `submitRating` nhận `sessionId` và thực hiện insert trực tiếp vào `survey_responses` mà không kiểm tra phiên đó đã có phản hồi trước đó hay chưa.
- **Phân tích cơ chế và tác động toán học riêng lên từng KPI khi 1 session có nhiều response ($N \ge 2$):**
  - **`scanCount` (Lượt quét QR):**
    - Đang tính bằng `count(*)::int` trên bảng đã `LEFT JOIN`.
    - Khi 1 phiên quét có $N$ bản ghi response, phép JOIN sẽ nhân số dòng của phiên đó lên $N$ lần. Do đó `scanCount` bị đếm thành $N$ (thổi phồng số lượt quét).
    - *Lưu ý kỹ thuật:* Giải pháp `count(distinct ss.id)` trong SQL **chỉ xử lý được duy nhất `scanCount`**, vì `ss.id` là khóa định danh của bảng phiên quét gốc. Nó **không thể giải quyết** các chỉ số còn lại (`ratedCount`, `satisfiedCount`, `googleRedirectCount`).
  - **`ratedCount` (Lượt đánh giá sao):**
    - Đang tính bằng `count(star_rating)::int`.
    - Khi 1 phiên có $N$ response mang `star_rating`, hàm sẽ đếm thành $N$ lượt đánh giá, làm sai lệch tổng số lượt khách đánh giá. `count(distinct ...)` không áp dụng được vì nếu distinct theo `session_id` thì SQL không biết lấy giá trị `star_rating` nào; còn nếu distinct theo `star_rating` thì lại đếm sai hoàn toàn nghiệp vụ.
  - **`satisfiedCount` (Lượt hài lòng 4–5 sao):**
    - Đang tính bằng `(count(*) filter (where star_rating >= 4))::int`.
    - Nếu cả $N$ responses của phiên đều $\ge 4$ sao, `satisfiedCount` bị đếm lặp $N$ lần. Nếu các response có điểm sao khác nhau (ví dụ 1 response 2 sao và 1 response 5 sao), `satisfiedCount` tăng 1 nhưng `ratedCount` tăng 2.
  - **`satisfactionRate` (Tỷ lệ hài lòng %):**
    - Tính bằng $(\text{satisfiedCount} / \text{ratedCount}) \times 100\%$.
    - Tỷ lệ này sẽ bị méo mó, dịch chuyển tùy thuộc vào tổ hợp điểm sao của các response dư thừa (ví dụ: một khách gửi 1 sao sau đó gửi lại 5 sao sẽ làm sai lệch tỷ lệ thực tế).
  - **`googleRedirectCount` (Lượt chuyển tiếp Google):**
    - Đang tính bằng `(count(*) filter (where redirect_clicked_at is not null))::int`.
    - Nếu các response dư thừa của cùng một phiên đều có cờ click chuyển tiếp, chỉ số này cũng bị nhân bản $N$ lần.
- **Đề xuất hướng xử lý căn cơ theo nghiệp vụ:**
  - Cần xác định rõ yêu cầu nghiệp vụ: **Một phiên khảo sát (`survey_sessions`) theo thiết kế được phép có một (`1:1`) hay nhiều (`1:N`) phản hồi (`survey_responses`)?**
    1. *Nếu nghiệp vụ quy định quan hệ `1:1` (mỗi lượt quét mã QR chỉ được gửi 1 lần đánh giá duy nhất):*
       - Cân nhắc bổ sung ràng buộc toàn vẹn `CONSTRAINT uq_survey_responses_session UNIQUE (session_id)` trên bảng `survey_responses` ở CSDL.
       - Bổ sung cơ chế chống trùng lặp / kiểm tra tính duy nhất (idempotency) ở tầng backend (`SurveyServiceImpl`) trước khi thực hiện insert.
    2. *Nếu nghiệp vụ cho phép quan hệ `1:N` (khách hàng có thể gửi bổ sung hoặc cập nhật câu trả lời trong cùng phiên):*
       - Cần định nghĩa rõ quy tắc tính toán KPI lấy theo phản hồi nào (ví dụ: chỉ lấy phản hồi mới nhất thông qua `DISTINCT ON (session_id) ORDER BY session_id, created_at DESC`).
- **Kế hoạch kiểm thử:** Được đưa vào danh mục kiểm thử tại Test Case **TC-DASH-10** (hiện ở trạng thái *NOT RUN* do cần môi trường PostgreSQL tích hợp để kiểm chứng).

---

## 3. Vấn Đề Quan Sát Kỹ Thuật Cần Làm Rõ (Technical Observations)

### OBS-SCRUM-240-02: Bản chất khác biệt giữa số liệu thẻ Google và các thẻ khảo sát nội bộ

- **Mã định danh nội bộ:** `OBS-SCRUM-240-02`
- **Loại vấn đề:** Điểm cần thống nhất nghiệp vụ (Business Requirement Alignment)
- **Vị trí mã nguồn liên quan:**
  - `backend/src/main/java/com/cxshield/backend/report/DashboardService.java` (dòng 78–82):
    ```java
    GoogleWeek latest = google.isEmpty() ? null : google.lastEntry().getValue();
    return new DashboardResponse(..., stats.scanCount(), ...,
        latest == null ? null : latest.reviewCount(),
        latest == null ? null : latest.avgRating(), points);
    ```
- **Mô tả:**
  - Các thẻ: "Lượt quét QR" (`scanCount`), "Hài lòng 4–5 sao", "Chuyển sang Google" phản ánh **tổng số lượng phát sinh trong toàn bộ khoảng thời gian lọc** (ví dụ: tổng phát sinh trong 8 tuần).
  - Thẻ: "Đánh giá Google" (`googleReviewCount`) và "Điểm sao Google" (`googleAvgRating`) lại phản ánh **giá trị snapshot của tuần gần nhất** (`latest snapshot`).
  - Người dùng hoặc chủ cơ sở có thể hiểu lầm rằng "Đánh giá Google" là số lượng review tăng thêm trong 8 tuần qua, thay vì tổng số review tích lũy hiện có của cơ sở trên Google Maps.
- **Đề xuất cho PO / UX Designer:**
  - Cân nhắc bổ sung dòng chú thích (tooltip hoặc caption phụ) trên giao diện D5-01: *"Số liệu tích lũy trên Google tính đến tuần hiện tại"* để tránh hiểu lầm khi phân tích dữ liệu.

---

## 4. Mẫu Phiếu Ghi Nhận Lỗi Chuẩn (Defect Template)

*(Sử dụng mẫu này khi phát hiện lỗi trong quá trình chạy kiểm thử động)*

```markdown
### [BUG-SCRUM-240-XX]: [Tiêu đề ngắn gọn, súc tích mô tả lỗi]
- **Mã Test Case liên quan:** TC-DASH-XX
- **Mức độ nghiêm trọng (Severity):** Critical / High / Medium / Low
- **Mức độ ưu tiên (Priority):** P1 / P2 / P3
- **Thành phần bị ảnh hưởng:** Backend API / PostgreSQL Function / Frontend UI
- **Môi trường thử nghiệm:**
  - OS / Browser:
  - Backend version: Spring Boot 4.0.0
  - Database: PostgreSQL (Supabase)
- **Dữ liệu đầu vào:**
- **Các bước tái hiện (Steps to Reproduce):**
  1. ...
  2. ...
- **Kết quả thực tế (Actual Result):**
- **Kết quả mong đợi (Expected Result):**
- **Bằng chứng đính kèm (Screenshots / Logs / Payload):**
```
