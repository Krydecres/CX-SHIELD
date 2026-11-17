# TÀI LIỆU KỊCH BẢN KIỂM THỬ TỰ ĐỘNG (SCRUM-234)

- **Mã Jira:** SCRUM-234
- **Tên User Story:** [E5.1] Kiểm thử mã nguồn studio thiết kế ấn phẩm QR
- **Phân hệ:** QR & NFC Management (Studio thiết kế ấn phẩm QR để bàn & dán quầy thu ngân D3-09)
- **Framework & Công cụ:** JUnit 5, Mockito, Spring Boot 4.0.0, Java 21 LTS, Apache Maven
- **File mã nguồn kiểm thử:** `backend/src/test/java/com/cxshield/backend/QrStudioSourceTest.java`

---

## 1. Cấu hình môi trường thực thi

- **Hệ điều hành:** Windows 11 / Windows Server
- **Java Development Kit (JDK):** OpenJDK 21 LTS (Temurin-21.0.12.1 hoặc tương đương)
- **Maven:** Apache Maven 3.9.x trở lên
- **Thư mục làm việc:** `C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend`

---

## 2. Các lệnh thực thi kiểm thử (Execution Commands)

### 2.1. Chạy riêng bộ kiểm thử mã nguồn SCRUM-234
Để thực thi độc lập 14 test cases thuộc SCRUM-234:

```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
mvn test "-Dtest=QrStudioSourceTest"
```

### 2.2. Chạy toàn bộ kiểm thử SCRUM-234 cùng bộ hồi quy Backend (38 tests)
Để kiểm tra tính toàn vẹn và đảm bảo không có hồi quy đối với các phân hệ QR Code, Print Design và NFC Order:

```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\backend"
mvn test "-Dtest=QrStudioSourceTest,QrCodeControllerTest,PrintDesignControllerTest,NfcOrderControllerTest"
```

### 2.3. Chạy kiểm thử hồi quy Frontend Studio D3-09 (6 widget tests)
```powershell
cd "C:\Users\dnccr\OneDrive\Desktop\New folder\CX-SHIELD-GIT\frontend"
flutter test test/d3_09_qr_studio_test.dart
```

---

## 3. Cấu trúc kịch bản kiểm thử tự động (`QrStudioSourceTest.java`)

```java
package com.cxshield.backend;

import com.cxshield.backend.common.ApiException;
import com.cxshield.backend.common.ApiResponse;
import com.cxshield.backend.controller.PrintDesignController;
import com.cxshield.backend.controller.QrCodeController;
import com.cxshield.backend.dto.*;
import com.cxshield.backend.entity.*;
import com.cxshield.backend.repository.PrintDesignRepository;
import com.cxshield.backend.repository.QrCodeRepository;
import com.cxshield.backend.service.PrintExportService;
import com.cxshield.backend.supabase.SupabaseAdminClient;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

class QrStudioSourceTest {
    // 14 test methods tương ứng với TC-234-01 đến TC-234-14
}
```

---

## 4. Chiến lược Mock và Xử lý Cơ sở Dữ liệu

1. **In-Memory Repository Store:**
   - Cả `QrCodeRepository` và `PrintDesignRepository` đều hỗ trợ chế độ lưu trữ song song in-memory (ConcurrentHashMap).
   - Đảm bảo tốc độ thực thi siêu tốc (dưới 3 giây cho toàn bộ suite), độc lập hoàn toàn với network hay kết nối ngoài.
2. **Mock Supabase PostgREST Client:**
   - Trong `TC-234-12`, `SupabaseAdminClient` được mock bằng Mockito nhằm kiểm tra cú pháp truy vấn `branch_id = eq.<UUID>`.
   - Lưu ý an toàn bảo mật: RLS thật trên production database không được gọi trực tiếp trong unit test và được đánh dấu rõ ràng là **NOT RUN**.
3. **Mã nguồn không bị can thiệp:**
   - Mọi test case đều viết dựa trên code thực tế, không chỉnh sửa production code để làm test PASS.
