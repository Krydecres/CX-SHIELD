# Test Cases — SCRUM-256: [E1.1] Kiểm thử lưu khảo sát và góp ý vào Supabase

- **Jira Ticket:** SCRUM-256
- **Sprint:** Sprint 4
- **Loại kiểm thử:** Kiểm thử chức năng hộp đen (Manual Black-box QA) trên môi trường chạy thật (Backend Spring Boot + Frontend Flutter Web + Supabase PostgreSQL)
- **Cam kết tham chiếu:** `09a8511` (`SCRUM-254` — lưu khảo sát/góp ý thật vào Supabase & chặn fallback tự tạo mã QR)
- **Người thực hiện:** QA Team
- **Ngày thực hiện:** 25/11/2026

---

## 1. Điều kiện tiên quyết & Dữ liệu chuẩn bị (Pre-conditions)

1. **Backend:** Đã cấu hình đầy đủ `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `CORS_ALLOWED_ORIGINS` trong `backend/.env` và khởi động thành công trên cổng `8080`.
2. **Frontend:** Khởi động Flutter Web trên cổng `8000` với `--dart-define=BACKEND_URL` trỏ trực tiếp tới Backend cổng `8080`.
3. **Database (Supabase):**
   - Bảng `qr_codes` có sẵn các mã QR đang hoạt động (`is_active = true`, ví dụ: `MC-B01`, `MC-VIP`), đã gắn hợp lệ với `branch_id` và `business_id`.
   - Không tồn tại mã `ABC123` trong bảng `qr_codes`.
4. **Cấu hình cảnh báo & Tài khoản quản trị:**
   - Có sẵn tài khoản chủ cửa hàng/quản lý để đăng nhập kiểm tra Dashboard (`SCRUM-211`) và trang Quản lý phản hồi.
   - Đã bật kênh nhận cảnh báo trong phần cài đặt cảnh báo để kiểm tra luồng nhận thông báo khi có góp ý tiêu cực.

---

## 2. Danh sách Test Cases chi tiết

| ID | Nhóm chức năng | Tên Test Case | Điều kiện đầu vào | Các bước thực hiện | Kết quả mong đợi (Expected Result) | Kết quả thực tế (Actual Result) | Trạng thái (PASS/FAIL) | Ghi chú / Bug ID |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-01** | Quét mã QR hợp lệ | Khởi tạo phiên khảo sát khi quét mã QR tồn tại trong DB | Mã `MC-B01` tồn tại trên Supabase (`is_active = true`). | 1. Mở trình duyệt truy cập đường dẫn `/?qr=MC-B01` (hoặc `/s/MC-B01`).<br>2. Quan sát giao diện màn hình đánh giá (`M1-01`).<br>3. Kiểm tra bảng `survey_sessions` trên Supabase. | 1. Màn hình `M1-01` hiển thị đúng thông tin cửa hàng, tên bàn/khu vực của mã `MC-B01`.<br>2. Bảng `survey_sessions` sinh ra **01 dòng mới** với `status = STARTED`, có đầy đủ `qr_code_id`, `branch_id`, `business_id` khớp với bản ghi của `MC-B01`. | Màn hình `M1-01` hiển thị đúng tên chi nhánh và bàn của mã `MC-B01`. Bảng `survey_sessions` sinh 01 bản ghi mới đầy đủ `qr_code_id`, `branch_id`, `business_id`. | **PASS** | — |
| **TC-02** | Đánh giá tích cực (4–5 sao) | Gửi đánh giá 5 sao và chuyển sang trang Google Review | Đang ở màn hình `M1-01` của phiên vừa tạo ở `TC-01`. | 1. Chọn **5 sao** (hoặc 4 sao) trên màn hình `M1-01`.<br>2. Xác nhận gửi đánh giá để hệ thống chuyển sang màn hình `M1-02`.<br>3. Kiểm tra bảng `survey_sessions` và `survey_responses` trên Supabase. | 1. Giao diện điều hướng mượt sang màn hình `M1-02` (mời đánh giá công khai trên Google).<br>2. Bảng `survey_sessions` cập nhật `status = COMPLETED` cho phiên hiện tại.<br>3. Bảng `survey_responses` thêm **01 dòng mới** với `star_rating = 5`, `sentiment_group = SATISFIED`, đầy đủ `session_id`, `branch_id`, `business_id` và `redirect_clicked_at` đang là `null`. | Điều hướng sang `M1-02` thành công; `survey_sessions` cập nhật `COMPLETED`; `survey_responses` lưu bản ghi 5 sao với `sentiment_group = SATISFIED` và đầy đủ `business_id`. | **PASS** | — |
| **TC-03** | Theo dõi chuyển hướng Google Review | Ghi nhận thời điểm khách bấm nút mở Google Review | Đang ở màn hình `M1-02` sau bước `TC-02`. | 1. Bấm vào nút mở trang đánh giá Google Maps trên màn hình `M1-02`.<br>2. Kiểm tra lại dòng dữ liệu tương ứng trong bảng `survey_responses` trên Supabase. | 1. Mở tab/liên kết Google Review của chi nhánh.<br>2. Cột `redirect_clicked_at` trong bảng `survey_responses` được cập nhật timestamp khác `null`. | Mở trang Google Review thành công; cột `redirect_clicked_at` trên Supabase cập nhật dấu thời gian chính xác. | **PASS** | — |
| **TC-04** | Đánh giá tiêu cực (1–3 sao) & Góp ý | Chọn 2 sao và gửi góp ý nội bộ thành công | Quét mới mã `MC-B01` (`/?qr=MC-B01`) để tạo phiên khảo sát mới. | 1. Chọn **2 sao** trên màn hình `M1-01`.<br>2. Hệ thống chuyển sang màn hình góp ý nội bộ (`M1-04`).<br>3. Chọn chủ đề, nhập nội dung góp ý chi tiết và bấm **Gửi góp ý**.<br>4. Kiểm tra bảng `survey_responses` và `feedbacks` trên Supabase. | 1. Hệ thống báo gửi góp ý thành công (chuyển sang màn hình cảm ơn `M1-06`).<br>2. Bảng `survey_sessions` có `status = COMPLETED`.<br>3. Bảng `survey_responses` có 01 dòng mới với `star_rating = 2`, `sentiment_group = UNSATISFIED`, đầy đủ `business_id`.<br>4. Bảng `feedbacks` thêm **01 dòng mới** chứa đúng nội dung góp ý, chủ đề, `session_id`, `branch_id`, `business_id`. | Chuyển sang `M1-06` thành công; `survey_responses` lưu `UNSATISFIED` và bảng `feedbacks` lưu đầy đủ nội dung góp ý, chủ đề, `business_id`. | **PASS** | — |
| **TC-05** | Cảnh báo tự động | Kích hoạt cảnh báo đa kênh khi phát sinh góp ý tiêu cực | Đã cấu hình và bật kênh cảnh báo (Telegram / Zalo / Email). | 1. Thực hiện gửi góp ý 1 sao hoặc 2 sao như `TC-04`.<br>2. Kiểm tra ứng dụng nhận tin nhắn/email đã cấu hình. | Trong vòng vài giây sau khi gửi góp ý, kênh cảnh báo nhận được thông báo đầy đủ thông tin: số sao, nội dung góp ý, vị trí/bàn và chi nhánh. | Hệ thống gửi thông báo cảnh báo tức thì về kênh đã cấu hình với đầy đủ nội dung góp ý và thông tin bàn/chi nhánh. | **PASS** | — |
| **TC-06** | Đánh giá 1 sao khẩn cấp | Hiển thị tùy chọn gọi quản lý trực tiếp khi chấm 1 sao | Quét mới mã `MC-B01` (`/?qr=MC-B01`). | 1. Chọn **1 sao** trên màn hình `M1-01`.<br>2. Quan sát giao diện trên màn hình `M1-04`. | Màn hình `M1-04` hiển thị nút/tùy chọn hỗ trợ khẩn cấp (gọi trực tiếp quản lý / `M1-05`) theo đúng quy tắc phân luồng cho mức 1 sao. | Hiển thị đầy đủ tùy chọn hỗ trợ khẩn cấp / gọi quản lý trực tiếp khi khách chọn 1 sao. | **PASS** | — |
| **TC-07** | Điều kiện tranh chấp (Race condition) | Bấm chọn sao ngay khi vừa mở trang trước khi API init phản hồi xong | Bật DevTools $\rightarrow$ Network $\rightarrow$ chọn **Slow 3G**. | 1. Mở đường dẫn `/?qr=MC-B01`.<br>2. Ngay khi giao diện sao vừa hiện lên (lúc request init vẫn đang *Pending*), bấm chọn ngay **4 sao** hoặc **3 sao**.<br>3. Chờ mạng tải xong và kiểm tra trạng thái trên UI lẫn Supabase. | 1. Lượt bấm sao của khách **không bị mất** hoặc báo lỗi.<br>2. Sau khi request khởi tạo phiên hoàn tất, hệ thống tự động nối tiếp để lưu đánh giá vào `survey_responses` và cập nhật `survey_sessions` thành `COMPLETED`. | Lượt chọn sao được giữ lại và tự động gửi ngay sau khi API khởi tạo phiên hoàn tất; dữ liệu trên Supabase được lưu đầy đủ. | **PASS** | — |
| **TC-08** | Mã QR không hợp lệ | Truy cập mã QR không tồn tại trong cơ sở dữ liệu | Mã `ABC123` không tồn tại trong bảng `qr_codes`. | 1. Truy cập đường dẫn `/?qr=ABC123` trên trình duyệt.<br>2. Gọi trực tiếp `GET /api/v1/surveys/qr/ABC123`.<br>3. Kiểm tra bảng `qr_codes` và `survey_sessions` trên Supabase. | 1. API trả về thông báo lỗi `"Mã QR không tồn tại trong hệ thống: ABC123"`.<br>2. Bảng `qr_codes` **không** tự động sinh thêm bản ghi fallback nào cho `ABC123`.<br>3. Bảng `survey_sessions` không tạo phiên rác. | API trả về lỗi `"Mã QR không tồn tại trong hệ thống: ABC123"`, không tự tạo bản ghi fallback trong `qr_codes` và không sinh phiên rác. | **PASS** | — |
| **TC-09** | Đồng bộ Dashboard & Quản lý phản hồi | Kiểm tra số liệu tổng hợp trên Dashboard sau khi gửi khảo sát | Đã hoàn thành các lượt test `TC-01` đến `TC-06`. | 1. Đăng nhập tài khoản quản trị của doanh nghiệp sở hữu mã `MC-B01`.<br>2. Mở màn hình **Dashboard** (`SCRUM-211`) và tải lại trang (F5).<br>3. Mở màn hình **Quản lý phản hồi / Góp ý**. | 1. Tổng lượt khảo sát, điểm đánh giá trung bình, tỷ lệ hài lòng và số phản hồi tiêu cực trên Dashboard tăng lên khớp chính xác với dữ liệu vừa tạo trên Supabase.<br>2. Góp ý tiêu cực ở `TC-04` xuất hiện đầy đủ trong danh sách Quản lý phản hồi. | Số liệu trên Dashboard tăng khớp chính xác với dữ liệu Supabase; góp ý tiêu cực hiển thị đầy đủ ở trang Quản lý phản hồi. | **PASS** | — |
| **TC-10** | Dữ liệu biên (Validation) | Gửi góp ý tiêu cực khi bỏ trống nội dung và không chọn chủ đề | Đang ở màn hình `M1-04` (sau khi chọn 2 sao). | 1. Không chọn chủ đề, để trống ô nội dung góp ý.<br>2. Bấm nút **Gửi góp ý**. | Hệ thống chặn gửi hoặc yêu cầu nhập thông tin tối thiểu theo validation của form; không phát sinh bản ghi lỗi trên Supabase. | Form chặn gửi hợp lệ và không phát sinh bản ghi lỗi trên Supabase. | **PASS** | — |

---

## 3. Bảng tổng hợp kết quả

- **Tổng số Test Case:** 10
- **Số lượng PASS:** 10
- **Số lượng FAIL:** 0
- **Số lượng BLOCKED:** 0
- **Số Bug phát hiện:** 0 (Không có lỗi phát sinh)