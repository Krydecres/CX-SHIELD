# BÁO CÁO LỖI VÀ GHI NHẬN KỸ THUẬT (BUG REPORTS)

- **Mã Jira:** SCRUM-189
- **Tên User Story:** [E1.1] Kiểm thử chức năng và giao diện khảo sát QR
- **Phân hệ:** Review Funnel (Màn hình M1-01, M1-02, M1-04, M1-05, M1-06)
- **Thiết bị thử nghiệm:** Samsung Galaxy A07, Android 16 (Samsung One UI)
- **Ngày ghi nhận:** 06/11/2026
- **Lần cập nhật:** Điều chỉnh theo xác nhận từ Developer (chức năng 4–5 sao chưa được phân công triển khai; không ghi nhận bug độc lập cho luồng chưa hoàn thiện)

---

## 1. Danh sách Lỗi chính thức trong SCRUM-189

> [!IMPORTANT]
> **Quy tắc phân loại lỗi theo tiến độ phát triển:**
> - **Developer đã xác nhận:** Chức năng đánh giá 4–5 sao và màn hình cảm ơn M1-02 **chưa được phân công thực hiện / chưa hoàn thiện** trong phạm vi nhiệm vụ SCRUM-189.
> - Theo chuẩn quy trình kiểm thử chất lượng, **không ghi nhận chức năng chưa phát triển là lỗi (bug)**.
> - Hiện tượng đứng giao diện khi nhấn Back sau luồng 4–5 sao (M1-02) **không được kết luận là bug độc lập**, do bản thân màn hình và luồng này chưa hoàn chỉnh. Hiện tượng này được chuyển sang mục **Vấn đề quan sát kỹ thuật (Technical Observation)** để phục vụ tái kiểm thử khi Developer bàn giao chức năng chính thức.
> - Đối với luồng 1–3 sao đã triển khai: Toàn bộ quy trình từ đánh giá, hiển thị cờ khẩn cấp 1 sao, form góp ý, validation cho đến ghi nhận vào Backend Spring Boot đều hoạt động chính xác và **không phát sinh bug**.

| Phân loại | Số lượng | Diễn giải chi tiết |
| :--- | :---: | :--- |
| **Tổng số Lỗi chính thức (Confirmed Defects)** | **0** | Luồng 1–3 sao hoạt động tốt; luồng 4–5 sao chưa triển khai nên không tính bug |
| **Vấn đề quan sát kỹ thuật (Technical Observations)** | **2** | OBS-SCRUM-189-01 (Hiện tượng Back trên luồng 4–5 sao) & OBS-SCRUM-189-02 (Silent fallback) |

---

## 2. Danh mục Vấn đề Quan sát Kỹ thuật (Technical Observations)

### 2.1. OBS-SCRUM-189-01: Quan sát hiện tượng đóng băng điều hướng Back trên luồng 4–5 sao (M1-02) cần kiểm thử lại sau khi chức năng hoàn thành

- **Mã theo dõi:** `OBS-SCRUM-189-01`
- **Tiêu đề:** `Quan sát hiện tượng ứng dụng bị đứng / không phản hồi khi thao tác Back trên màn hình M1-02 (thuộc luồng 4–5 sao chưa triển khai hoàn thiện) trên thiết bị Samsung A07 (Android 16)`
- **Màn hình liên quan:** M1-02 (`M102GoogleReviewScreen`)
- **Tình trạng:** **Quan sát kỹ thuật (Cần kiểm thử lại sau khi Developer hoàn thành chức năng 4–5 sao)**
- **Mô tả hiện tượng quan sát được:**
  - Trên thiết bị Samsung Galaxy A07 (Android 16), khi chọn 4 hoặc 5 sao và chuyển sang màn hình M1-02:
    - *Thao tác 1 (Nút in-app):* Nhấn nút `"← Trở lại khảo sát"` (dòng 216–219 trong `m1_02_google_review_screen.dart`), ứng dụng bị đứng hình, không phản hồi.
    - *Thao tác 2 (Nút Back Android 16):* Vuốt cử chỉ Back hoặc bấm phím Back Android, cử chỉ bị khựng lại, không quay về M1-01.
- **Phân tích nguyên nhân kỹ thuật trong mã nguồn hiện tại:**
  - `m1_01_rating_screen.dart` (dòng 79): Gọi `Navigator.of(context).pushReplacement(...)` khi chọn 4–5 sao, làm gỡ bỏ M1-01 khỏi ngăn xếp, khiến `Navigator.canPop(context)` tại M1-02 là `false`.
  - `m1_02_google_review_screen.dart` (dòng 217): Nút in-app lại gọi `Navigator.of(context).pop()` trên một ngăn xếp rỗng.
  - Về mặt kiểm thử tự động, script `TC14` trong `frontend/test/scrum_189_survey_widget_test.dart` đã chạy **PASS** vì xác nhận đúng assertion kỹ thuật `Navigator.canPop() == false`.
- **Hành động tiếp theo (Next Action):**
  - Chuyển toàn bộ ghi chú phân tích kỹ thuật này cho Developer phụ trách luồng 4–5 sao để tối ưu hóa kiến trúc điều hướng (dùng `Navigator.push` thay vì `pushReplacement`, hoặc reset `_isSubmitting`).
  - Đội QA sẽ thực hiện kiểm thử hồi quy (re-test) chính thức cho mục này khi User Story phát triển luồng 4–5 sao được bàn giao.

---

### 2.2. OBS-SCRUM-189-02: Cơ chế Silent Fallback tự sinh dữ liệu cục bộ khi mất mạng mà không cảnh báo lỗi cho người dùng

- **Mã theo dõi:** `OBS-SCRUM-189-02`
- **Tiêu đề:** `Cơ chế Silent Fallback trong SurveyApiService tự sinh dữ liệu cục bộ khi mất kết nối Backend mà không hiển thị thông báo lỗi`
- **Màn hình liên quan:** Toàn bộ luồng khảo sát (M1-01, M1-04, M1-02)
- **Tình trạng:** **Quan sát rủi ro kỹ thuật (Technical Risk)**
- **Mô tả chi tiết:**
  - Lớp `SurveyApiService` bọc toàn bộ gọi HTTP mạng bằng khối `catch (_)`.
  - Khi Backend tắt hoặc thiết bị mất kết nối, hệ thống tự động sinh `responseId` giả lập dạng `local-${DateTime.now().millisecondsSinceEpoch}` và tiếp tục cho phép chuyển màn hình như bình thường.
- **Rủi ro kiểm thử và vận hành:**
  - Người dùng tại bàn hoặc tester có thể lầm tưởng rằng đánh giá và góp ý đã được chuyển thành công tới Quản lý cơ sở trong khi dữ liệu chỉ lưu tạm thời trên RAM client.
- **Khuyến nghị kỹ thuật:**
  - Đội phát triển nên bổ sung SnackBar hoặc Banner thông báo chế độ ngoại tuyến (Offline Banner) khi kết nối API không thành công để người dùng nắm rõ trạng thái thực của yêu cầu.
