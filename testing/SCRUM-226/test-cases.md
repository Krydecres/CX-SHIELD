# TEST CASES: SCRUM-226 – Kiểm thử chức năng cài đặt từ khóa và ngưỡng chia luồng

- **Người thực hiện:** Long Quốc Cường (Cường 032)
- **Mã Task Jira:** SCRUM-226 (Story cha: SCRUM-133 – E4.3)
- **Đối tượng kiểm thử:** Màn hình Frontend Admin `D3-07` & đồng bộ sang màn khách `M1-02`
- **Task code phụ thuộc:** `SCRUM-212`
- **Trạng thái thực thi:** **BLOCKED** (Giao diện màn hình `D3-07` và API nền tảng chưa được xây dựng trên nhánh làm việc)

## Danh sách Kịch bản Kiểm thử Chức năng (Black-box)

| Mã TC | Tên kịch bản | Các bước thực hiện | Kết quả mong đợi | Trạng thái |
| :---: | :--- | :--- | :--- | :---: |
| **TC-226-01** | Thêm mới từ khóa gợi ý theo ngành (Nha khoa, Spa, F&B…) | 1. Mở màn hình quản trị `D3-07`.<br>2. Chọn ngành hàng (F&B, Spa, Nha khoa) và nhập từ khóa SEO mới.<br>3. Nhấn lưu. | Từ khóa mới được lưu và hiển thị ngay trong danh sách bộ từ khóa của cơ sở theo đúng ngành hàng. | **BLOCKED** |
| **TC-226-02** | Sửa và xóa từ khóa đã tạo | 1. Tại danh sách từ khóa trên `D3-07`, chọn sửa nội dung một từ khóa và lưu.<br>2. Chọn xóa một từ khóa khác và xác nhận. | Nội dung từ khóa được cập nhật chính xác; từ khóa bị xóa biến mất khỏi danh sách. | **BLOCKED** |
| **TC-226-03** | Thiết lập ngưỡng chia luồng cảm xúc | 1. Kiểm tra giá trị mặc định trên `D3-07` (`4–5 sao → Google`, `1–3 sao → góp ý nội bộ`).<br>2. Đổi ngưỡng lên Google thành `5 sao` và bấm lưu. | Hệ thống lưu cấu hình thành công và hiển thị thông báo cập nhật ngưỡng chia luồng. | **BLOCKED** |
| **TC-226-04** | Kiểm tra bắt lỗi nhập dữ liệu sai (Invalid Input) | 1. Nhập từ khóa rỗng / chỉ chứa khoảng trắng hoặc vượt độ dài tối đa.<br>2. Chọn ngưỡng chia luồng ngoài phạm vi cho phép (`< 1` hoặc `> 5`). | Giao diện chặn thao tác lưu và hiển thị thông báo lỗi hợp lệ rõ ràng cho người dùng. | **BLOCKED** |
| **TC-226-05** | Kiểm tra bắt lỗi nhập dữ liệu trùng lặp (Duplicate Keyword) | Nhập một từ khóa đã tồn tại trong cùng ngành/cơ sở và nhấn lưu. | Hệ thống từ chối lưu trùng và hiển thị cảnh báo từ khóa đã tồn tại. | **BLOCKED** |
| **TC-226-06** | Xác nhận thay đổi áp dụng ngay cho màn khách `M1-02` & `M1-01` | 1. Cập nhật bộ từ khóa mới và ngưỡng chia luồng tại `D3-07`.<br>2. Quét QR mở màn khách, đánh giá sao theo ngưỡng mới và kiểm tra màn `M1-02`. | Luồng phân tuyến chạy đúng theo ngưỡng mới; màn `M1-02` hiển thị ngay câu gợi ý từ bộ từ khóa vừa cập nhật. | **BLOCKED** |