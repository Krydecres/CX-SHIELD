# Thống nhất thuật ngữ và Coding Conventions (bản đề xuất)

Bổ sung cho sheet **Thuật ngữ** và **Coding Conventions** trong `Epic_User_Story.xlsx`.
Nhóm duyệt xong thì chép vào file chung; file chung vẫn là bản chính.

## 1. Thuật ngữ kiểm thử (thêm vào sheet Thuật ngữ)

Tên cột theo bảng thống kê Sprint 1, để cả nhóm đếm số liệu cùng một cách.

| Thuật ngữ thống nhất | Nghĩa | Không dùng nữa | Tên trên Jira / cột thống kê |
| --- | --- | --- | --- |
| Unit test | Test tự động do người code viết, kiểm tra một hàm hoặc lớp | Test đơn vị | Cột "Số unit tests" |
| Test case manual | Một kịch bản có bước, dữ liệu và kết quả mong đợi, do người kiểm thử chạy tay. Gồm cả kiểm thử chức năng và kiểm thử mã nguồn | Test tay, kịch bản test | Cột "Số test cases (Manual)" |
| Test case automation | Một kịch bản chạy bằng công cụ (Playwright, Postman chạy tự động), đếm theo từng test trong báo cáo | Auto test, test tự động hoá | Cột "Số test cases (Automation)" |
| Bug | Lỗi đã tái hiện được, có bước tái hiện và bằng chứng, được ghi trên Jira | Lỗi vặt, issue | Cột "Số bug phát hiện" |
| Kiểm thử chức năng | Kiểm thử theo yêu cầu qua giao diện hoặc API, không đọc mã nguồn | blackbox, black box, `[BB]` | Tên task `[E<x>.<y>] Kiểm thử chức năng ...`, nhãn `qa-bb` |
| Kiểm thử mã nguồn | Kiểm thử dựa trên mã nguồn: nhánh logic, quyền truy cập, xử lý lỗi | whitebox, white box, `[WB]`, review code (khi nói về task kiểm thử) | Tên task `[E<x>.<y>] Kiểm thử mã nguồn ...`, nhãn `qa-wb` |
| Kiểm thử tự động | Viết và chạy test case automation | automation test, `[AUTO]` | Tên task `[E<x>.<y>] Kiểm thử tự động ...`, nhãn `qa-auto` |
| Smoke test | Bộ test ngắn xác nhận luồng chính còn chạy | Test khói | Trong task kiểm thử tự động |
| Kiểm thử hồi quy | Chạy lại test cũ sau khi sửa code để chắc không phát sinh lỗi mới | regression | Trong task kiểm thử chức năng, kiểm thử tự động |
| Bằng chứng | Ảnh, video, file kết quả, link báo cáo test đính kèm task | evidence | Đính kèm trên task Jira |

## 2. Quy ước Jira (thêm vào sheet Coding Conventions, phần Git & quy trình)

- **Story** là một user story mã `E<x>.<y>`. Mỗi story chỉ có **một** người kiểm thử phụ trách.
- **Subtask** đặt tên theo mã user story của Story cha: `[E<x>.<y>] <nội dung>`, không dùng `[DEV]`, `Full-stack`, `[WB]`, `[BB]`, `[AUTO]` và không ghi SP trong tên. SP nằm ở trường Story point estimate.
- Mỗi người kiểm thử phải có cả test case manual và automation.
- **Developer:** bắt buộc phải có Unit Test.
- **Tester:** sản phẩm thể hiện qua Test cases + Test scripts (automation) + Test reports (báo cáo kết quả test).
- Nhãn chỉ dùng `dev-fullstack`, `qa-bb`, `qa-wb`, `qa-auto`, `MVP`, `backlog`, `week-<số>`.

| Trạng thái | Nghĩa với task code | Nghĩa với task kiểm thử |
| --- | --- | --- |
| Idea | Chưa nhận việc | Chưa nhận việc |
| To Do | Đã nhận, chưa làm | Đã nhận, chưa làm |
| In Progress | Đang code | Đang viết hoặc đang chạy test case |
| In Review | Code đã lên GitHub, chờ review và kiểm thử | Đã chạy xong, chờ xác nhận bug đã sửa |
| Done | Đã merge và kiểm thử đạt | Đã ghi kết quả, bằng chứng và link bug |

**Khi kiểm thử hoàn thành, bắt buộc comment trên task:** tổng số test case, số pass, số fail, số bug phát hiện, kèm link Test cases, Test scripts và Test reports.

## 3. Chỗ đang chưa thống nhất

| # | Vấn đề | Đang ở đâu | Đề xuất |
| --- | --- | --- | --- |
| 1 | Thư mục Flutter có hai kiểu: `lib/features/d3_xx_...` và `lib/screens/m1_xx_...` | `frontend/lib` trên `main` | Thống nhất `lib/features/<mã_màn>_<mô_tả>/`, chuyển 5 file M1 sang |
| 2 | Quy ước Frontend còn nói CSS class và component, trong khi dự án dùng Flutter | Sheet Coding Conventions, Người 2 | Sửa thành: file và thư mục `snake_case`, class và widget `PascalCase`, màu lấy từ `context.colors` |
| 3 | Quy ước có nhánh `develop` nhưng repo không có | Sheet Coding Conventions, Người 3 | Bỏ `develop`, hoặc tạo nhánh này và merge qua đó |
| 4 | Commit có nơi `feat: ...`, có nơi `SCRUM-190: Add ...`; lẫn tiếng Anh và tiếng Việt | Lịch sử Git | Mẫu chung `feat: SCRUM-xxx <mô tả tiếng Việt>` |
| 5 | Dùng "phản ánh" thay cho "góp ý" | `m1_04_feedback_screen.dart:235`, `m1_06_thank_you_screen.dart:75` | Đổi thành "góp ý" |
| 6 | Dùng "tenant" thay cho "cơ sở" | Mô tả SCRUM-191, SCRUM-196 | Đổi thành "cơ sở" |
| 7 | Trạng thái sheet dùng "Chờ review", Jira dùng "In Review" | Sheet Phân công CSDL | Quy ước: Chưa làm = To Do, Chờ review = In Review, Xong = Done |
| 8 | Chủ cơ sở và Chủ chuỗi cùng role OWNER, không phân biệt trong code | Sheet Thuật ngữ | Ghi rõ: trong code chỉ có OWNER, "Chủ chuỗi" chỉ là cách gọi khi có nhiều chi nhánh |
