# BÁO CÁO LỖI VÀ GHI NHẬN KỸ THUẬT (BUG REPORTS & OBSERVATIONS)

- **Mã Jira:** SCRUM-241
- **Tên nhiệm vụ:** [E3.1] Kiểm thử chức năng dashboard tổng quan
- **Story cha:** SCRUM-129 ([E3.1] Dashboard tổng quan)
- **Task code liên quan:** SCRUM-211 (Trạng thái: *In Review*)
- **Phân hệ:** Quản trị & Báo cáo số liệu (Màn hình D5-01 Dashboard tổng quan)
- **Người lập:** QA Engineer / Tester
- **Ngày lập:** 16/11/2026
- **Trạng thái kiểm định:** Đã hoàn tất thực thi kiểm thử trên môi trường local (65/65 automated tests passed, 0 failures). Ghi nhận **0 Lỗi chính thức (Confirmed Defect)**, **1 Bất thường mã nguồn tiềm ẩn rủi ro cao (Code Anomaly / High Risk)** và **1 Vấn đề quan sát kỹ thuật giao diện (Technical Observation / UX)**.

---

## 1. Danh Sách Lỗi Chính Thức (Confirmed Defects)

> [!IMPORTANT]
> **Nguyên tắc phân loại lỗi QA (Defect vs Anomaly vs Observation):**
> - **Confirmed Defect (Lỗi chính thức):** Chỉ được xác nhận khi có ít nhất một automated test bị fail, hoặc có kịch bản tái hiện cụ thể chứng minh kết quả thực tế đi ngược lại tài liệu yêu cầu nghiệp vụ đã thống nhất. Hiện tại toàn bộ 65 automated tests đều **PASS 100%**, nên **CHƯA CÓ LỖI CHÍNH THỨC NÀO ĐƯỢC MỞ TRÊN JIRA**.
> - **Code Anomaly (Bất thường mã nguồn tiềm ẩn rủi ro):** Vấn đề khiếm khuyết trong cấu trúc thiết kế database hoặc logic SQL được phát hiện qua việc phân tích mã nguồn chuyên sâu (*White-box Code Inspection*). Mặc dù chưa bị bắt bởi unit test (do unit test mock tầng DTO), nó tiềm ẩn nguy cơ sai lệch dữ liệu nghiêm trọng trong thực tế.
> - **Technical Observation (Quan sát kỹ thuật):** Điểm chưa rõ ràng hoặc có thể gây hiểu lầm cho người dùng cuối về mặt trải nghiệm UX, cần tham vấn ý kiến của Product Owner (PO) và Business Analyst (BA).

| Phân loại | Số lượng | Diễn giải chi tiết |
| :--- | :---: | :--- |
| **Tổng số Lỗi chính thức (Confirmed Defects)** | **0** | Đã chạy 65 unit/widget tests thành công 100%, không phát sinh exception |
| **Bất thường mã nguồn cần xác minh (Code Anomalies)** | **1** | `OBS-SCRUM-241-01` (High Risk): Nguy cơ đếm trùng số liệu do phép `LEFT JOIN` và thiếu ràng buộc `UNIQUE(session_id)` |
| **Vấn đề quan sát kỹ thuật (Technical Observations)** | **1** | `OBS-SCRUM-241-02` (Medium / UX): Thẻ Google hiển thị snapshot tuần mới nhất khác với tổng tích lũy của các thẻ khảo sát nội bộ |

---

## 2. Chi Tiết Điểm Bất Thường Mã Nguồn Tiềm Ẩn Rủi Ro Cao (Code Anomaly)

### OBS-SCRUM-241-01: Nguy cơ đếm trùng số liệu KPI do sử dụng phép `LEFT JOIN` kết hợp thiếu ràng buộc `UNIQUE` trên bảng phản hồi khảo sát

- **Mã định danh nội bộ:** `OBS-SCRUM-241-01`
- **Loại vấn đề:** Bất thường cấu trúc mã nguồn (Code Anomaly / High Risk Architecture Flaw)
- **Mức độ nghiêm trọng dự kiến:** **High** (Nếu phát sinh trên dữ liệu thực tế sẽ làm sai lệch toàn bộ chỉ số KPI kinh doanh cốt lõi của Dashboard)
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
     - Bảng `survey_responses` chỉ khai báo khóa ngoại `FOREIGN KEY (session_id) REFERENCES survey_sessions(id)`.
     - **Hoàn toàn không có ràng buộc duy nhất `UNIQUE(session_id)`**, không có Unique Index hay Trigger chặn bản ghi trùng.
  3. `backend/src/main/java/com/cxshield/backend/service/impl/SurveyServiceImpl.java` (dòng 127–145):
     - Hàm `submitRating` nhận `sessionId` và thực hiện câu lệnh INSERT trực tiếp vào `survey_responses` mà không có cơ chế kiểm tra tính duy nhất (idempotency check) để xác định phiên đó đã có phản hồi trước đó hay chưa.

- **Phân tích cơ chế và tác động toán học riêng lên từng chỉ số khi 1 phiên quét có $N \ge 2$ phản hồi:**
  - **`scanCount` (Lượt quét QR):**
    - Đang được tính bằng `count(*)::int` trên bảng kết quả sau khi `LEFT JOIN`.
    - Khi 1 phiên quét phát sinh $N$ phản hồi, phép JOIN giữa `survey_sessions` và `survey_responses` sẽ nhân số dòng của phiên quét đó lên $N$ lần. Do đó, `count(*)` sẽ đếm phiên quét đó thành $N$ lượt quét (thổi phồng số lượt khách quét mã thực tế).
    - *Lưu ý kỹ thuật đặc biệt:* Ý tưởng sửa đổi bằng cách thêm `COUNT(DISTINCT ss.id)` trong SQL **chỉ giải quyết được duy nhất chỉ số `scanCount`** (vì `ss.id` là khóa chính của bảng phiên quét). Nó **hoàn toàn bất lực và không thể áp dụng** cho các chỉ số còn lại (`ratedCount`, `satisfiedCount`, `googleRedirectCount`).
  - **`ratedCount` (Lượt đánh giá sao):**
    - Đang được tính bằng `count(star_rating)::int`.
    - Khi 1 phiên có $N$ bản ghi response mang `star_rating`, hàm sẽ đếm thành $N$ lượt đánh giá.
    - Không thể dùng `COUNT(DISTINCT ...)` vì nếu distinct theo `session_id` thì SQL không biết chọn giá trị `star_rating` của bản ghi nào; còn nếu distinct theo `star_rating` thì sẽ đếm sai hoàn toàn nghiệp vụ (chỉ đếm số mức sao phân biệt).
  - **`satisfiedCount` (Lượt hài lòng 4–5 sao):**
    - Đang được tính bằng `(count(*) filter (where star_rating >= 4))::int`.
    - Nếu cả $N$ responses của phiên đều $\ge 4$ sao, `satisfiedCount` bị đếm lặp $N$ lần. Nếu khách hàng gửi phản hồi lần đầu 2 sao, sau đó gửi lại 5 sao, `satisfiedCount` tăng 1 nhưng `ratedCount` lại tăng 2, làm sai lệch cấu trúc dữ liệu.
  - **`satisfactionRate` (Tỷ lệ hài lòng %):**
    - Công thức tính: $(\text{satisfiedCount} / \text{ratedCount}) \times 100\%$.
    - Tỷ lệ này sẽ bị méo mó, trượt khỏi giá trị thực tế tùy thuộc vào tổ hợp điểm sao của các response dư thừa.
  - **`googleRedirectCount` (Lượt chuyển tiếp Google):**
    - Đang được tính bằng `(count(*) filter (where redirect_clicked_at is not null))::int`.
    - Nếu các response dư thừa của cùng một phiên đều có cờ chuyển tiếp Google, chỉ số này cũng bị nhân bản $N$ lần.

- **Đề xuất hướng xử lý căn cơ từ đội ngũ QA:**
  Đội ngũ phát triển cần thống nhất với Product Owner quy tắc nghiệp vụ cốt lõi:
  1. *Trường hợp nghiệp vụ quy định quan hệ `1:1` (Mỗi phiên quét QR chỉ được gửi đánh giá 1 lần duy nhất):*
     - Bổ sung ràng buộc toàn vẹn CSDL: `ALTER TABLE public.survey_responses ADD CONSTRAINT uq_survey_responses_session UNIQUE (session_id);`.
     - Bổ sung kiểm tra tính bất biến (Idempotency) tại Backend `SurveyServiceImpl.submitRating`: nếu phiên đã có rating thì trả về lỗi hoặc bỏ qua ghi đè.
  2. *Trường hợp nghiệp vụ cho phép quan hệ `1:N` (Khách hàng có thể cập nhật hoặc gửi lại đánh giá trong cùng một phiên):*
     - Câu truy vấn SQL trong hàm `get_dashboard_stats` phải được tái cấu trúc để chỉ lấy bản ghi mới nhất của mỗi phiên trước khi tính tổng:
       ```sql
       latest_responses as (
         select distinct on (session_id) session_id, star_rating, redirect_clicked_at, created_at
         from public.survey_responses
         order by session_id, created_at desc
       ),
       rows_by_session as (
         select
           date_trunc('week', ss.scan_date)::date as week_start,
           r.star_rating,
           r.redirect_clicked_at
         from sessions ss
         left join latest_responses r on r.session_id = ss.id
       )
       ```
- **Kế hoạch kiểm thử xác minh:** Vấn đề này đã được mã hóa thành ca kiểm thử tích hợp **TC-D501-INT-02** (hiện ở trạng thái *BLOCKED* do cần môi trường PostgreSQL test để kiểm chứng).

---

## 3. Vấn Đề Quan Sát Kỹ Thuật Cần Làm Rõ (Technical Observations)

### OBS-SCRUM-241-02: Bản chất khác biệt giữa số liệu thẻ Google và các thẻ khảo sát nội bộ trên màn hình D5-01

- **Mã định danh nội bộ:** `OBS-SCRUM-241-02`
- **Loại vấn đề:** Điểm cần thống nhất nghiệp vụ & Tối ưu trải nghiệm người dùng (UX Observation)
- **Mức độ nghiêm trọng dự kiến:** Medium (Dễ gây hiểu lầm cho người dùng quản trị)
- **Vị trí mã nguồn liên quan:**
  - `backend/src/main/java/com/cxshield/backend/report/DashboardService.java` (dòng 78–82):
    ```java
    DashboardWeek latestWeekWithGoogle = weekly.stream()
            .filter(w -> w.googleReviewCount() != null || w.googleAvgRating() != null)
            .reduce((first, second) -> second)
            .orElse(null);
    ```
  - `frontend/lib/pages/admin/dashboard/dashboard_page.dart` (dòng 105–125): Khối 5 thẻ số liệu hiển thị ngang hàng.
- **Mô tả hiện tượng và phân tích sự khác biệt:**
  - **Thẻ 1, 2, 3 (Khảo sát nội bộ):** Thể hiện **tổng số lũy kế tích lũy** của toàn bộ khoảng thời gian lọc được chọn (mặc định là 8 tuần gần nhất).
    - Ví dụ: 8 tuần có 1.248 lượt quét, 684 lượt đánh giá $\rightarrow$ Thẻ hiển thị `"1.248"` và `"82,5%"`.
  - **Thẻ 4, 5 (Chỉ số Google Place):** Lại thể hiện **giá trị snapshot của duy nhất 1 tuần gần nhất** có dữ liệu Google (`latestWeekWithGoogle`).
    - Ví dụ: Chi nhánh có tổng cộng 428 lượt review trên Google Maps tính đến tuần hiện tại $\rightarrow$ Thẻ hiển thị `"428"` và `"4,6★"`.
  - **Rủi ro trải nghiệm người dùng (UX Confusion):**
    - Người dùng quản trị khi nhìn vào hàng 5 thẻ số liệu trong bộ lọc "8 tuần gần nhất" rất dễ ngộ nhận rằng thẻ "Đánh giá Google: 428" có nghĩa là *"Cơ sở nhận được 428 đánh giá mới trên Google trong vòng 8 tuần qua"*, trong khi thực tế 428 là tổng số review tích lũy toàn thời gian của Google Place ID tính đến thời điểm snapshot gần nhất.
- **Đề xuất từ phía QA:**
  - Bổ sung một icon trợ giúp nhỏ (Tooltip / Info icon) cạnh tiêu đề *"Đánh giá Google"* và *"Điểm sao Google"* với nội dung giải thích:  
    *`"Số liệu Google hiển thị theo tuần ghi nhận gần nhất, không tính lũy kế theo khoảng thời gian lọc."`*

---

## 4. Danh Sách Câu Hỏi Trọng Tâm Gửi Product Owner / Solution Architect

Để chuẩn bị nghiệm thu chính thức và đóng User Story SCRUM-129 / Code Task SCRUM-211, đội ngũ QA kính chuyển 2 câu hỏi nghiệp vụ sau:

1. **Về mô hình quan hệ dữ liệu giữa phiên quét và phản hồi (Liên quan `OBS-SCRUM-241-01`):**
   - Về mặt nghiệp vụ, khách hàng khi quét mã QR tại bàn có được phép gửi nhiều lượt đánh giá sao trong cùng một phiên quét hay không?
   - Nếu hệ thống cho phép khách hàng đổi ý và gửi lại đánh giá, hệ thống sẽ ghi đè lên đánh giá cũ, hay lưu thành bản ghi mới và Dashboard sẽ chỉ lấy đánh giá mới nhất?
2. **Về nhãn và giải thích thẻ Google Metrics trên giao diện D5-01 (Liên quan `OBS-SCRUM-241-02`):**
   - Đội ngũ PO/BA có đồng ý bổ sung thêm ghi chú hoặc tooltip trên giao diện D5-01 để phân biệt rõ số liệu Google là snapshot thời điểm gần nhất, tránh việc người dùng nhầm lẫn với tổng tích lũy kỳ lọc của các thẻ khảo sát nội bộ hay không?
