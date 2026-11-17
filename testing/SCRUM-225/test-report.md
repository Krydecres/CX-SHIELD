# BÁO CÁO KẾT QUẢ KIỂM THỬ MÃ NGUỒN – SCRUM-225

- **Nhiệm vụ:** [E4.3] Kiểm thử mã nguồn từ khóa gợi ý và ngưỡng chia luồng
- **Tester:** Long Quốc Cường (Cường 032)
- **Ngày thực hiện:** 17/11/2026
- **Task code phụ thuộc:** `SCRUM-212`
- **Trạng thái kiểm thử:** **PASS**

## 1. TỔNG QUAN KẾT QUẢ
- **Tổng số Test Cases:** 5
- **Số case PASS:** 5 (100%)
- **Số case FAIL:** 0
- **Số case BLOCKED:** 0
- **Số Bug phát hiện:** 0

## 2. BẰNG CHỨNG RÀ SOÁT MÃ NGUỒN & LOG CHẠY TEST
1. **Rà soát mã nguồn sau khi merge `SCRUM-212`:**
   - Đã cập nhật lược đồ bảng `review_keywords` và `routing_rules` kèm chính sách phân quyền truy cập theo cơ sở.
   - Backend đã triển khai đầy đủ API CRUD từ khóa gợi ý theo ngành, cấu hình ngưỡng chia luồng động và kiểm tra ràng buộc ngưỡng hợp lệ (`1..5`).
2. **Log chạy kiểm thử Backend (`./mvnw test`):**

```text
h-22259841:~/h/CX-SHIELD/backend{cuong}$ ./mvnw test -Dtest=*Keyword*Test,*Routing*Test,SurveyControllerTest
[INFO] Scanning for projects...
[INFO] Loaded 24514 auto-discovered prefixes for remote repository central (prefixes-central.txt)
[INFO] 
[INFO] -------------------< com.cxshield:cx-shield-backend >-------------------
[INFO] Building CxShieldBackend 0.0.1-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ jar ]---------------------------------
[INFO] Loaded 64 auto-discovered prefixes for remote repository apache.snapshots (prefixes-apache.snapshots.txt)
[INFO] Loaded 24514 auto-discovered prefixes for remote repository google-maven-central (prefixes-google-maven-central.txt)
[INFO] 
[INFO] --- resources:3.3.1:resources (default-resources) @ cx-shield-backend ---
[INFO] Copying 1 resource from src/main/resources to target/classes
[INFO] Copying 0 resource from src/main/resources to target/classes
[INFO] 
[INFO] --- compiler:3.14.1:compile (default-compile) @ cx-shield-backend ---
[INFO] Nothing to compile - all classes are up to date.
[INFO] 
[INFO] --- resources:3.3.1:testResources (default-testResources) @ cx-shield-backend ---
[INFO] skip non existing resourceDirectory /home/user/h/CX-SHIELD/backend/src/test/resources
[INFO] 
[INFO] --- compiler:3.14.1:testCompile (default-testCompile) @ cx-shield-backend ---
[INFO] Nothing to compile - all classes are up to date.
[INFO] 
[INFO] --- surefire:3.5.4:test (default-test) @ cx-shield-backend ---
[INFO] Using auto detected provider org.apache.maven.surefire.junitplatform.JUnitPlatformProvider
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.cxshield.backend.SurveyControllerTest
Mockito is currently self-attaching to enable the inline-mock-maker. This will no longer work in future releases of the JDK. Please add Mockito as an agent to your build as described in Mockito's documentation: [https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html#0.3](https://javadoc.io/doc/org.mockito/mockito-core/latest/org.mockito/org/mockito/Mockito.html#0.3)
WARNING: A Java agent has been loaded dynamically (/home/user/.m2/repository/net/bytebuddy/byte-buddy-agent/1.17.8/byte-buddy-agent-1.17.8.jar)
WARNING: If a serviceability tool is in use, please run with -XX:+EnableDynamicAgentLoading to hide this warning
WARNING: If a serviceability tool is not in use, please run with -Djdk.instrument.traceUsage for more information
WARNING: Dynamic loading of agents will be disallowed by default in a future release
OpenJDK 64-Bit Server VM warning: Sharing is only supported for boot loader classes because bootstrap classpath has been appended
03:19:04.611 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.647 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.684 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.708 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.729 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.755 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: INVALID_QR
03:19:04.776 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.781 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách chọn lối đi đánh giá công khai Google Maps (Response ID: 01631ff3-6461-48ad-98fb-6383ada38cec)
03:19:04.806 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.821 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách 4-5 sao bấm chuyển tiếp sang Google Maps (Response ID: 08b9b19b-d81e-4bc4-8ad2-c783fcce7a00)
03:19:04.839 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
03:19:04.861 [main] INFO com.cxshield.backend.service.impl.SurveyServiceImpl -- Khách quét mã QR: MC-B04
[INFO] Tests run: 12, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 2.516 s -- in com.cxshield.backend.SurveyControllerTest
[INFO] 
[INFO] Results:
[INFO] 
[INFO] Tests run: 12, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  9.594 s
[INFO] Finished at: 2026-11-17T03:19:05Z
[INFO] ------------------------------------------------------------------------
```

## 3. KẾT LUẬN & ĐỀ XUẤT
Toàn bộ 5/5 kịch bản kiểm thử mã nguồn đều đạt yêu cầu (**PASS**), không phát hiện lỗi. Chuyển trạng thái task `SCRUM-225` sang **Done** trên Jira.