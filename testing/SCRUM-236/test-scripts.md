# HÆ¯á»šNG DáºªN THá»°C THI KIá»‚M THá»¬ Tá»° Äá»˜NG (TEST SCRIPTS)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-236
**Chá»©c nÄƒng:** [E5.1] Studio Thiáº¿t Káº¿ áº¤n Pháº©m QR (D3-09)
**Repository:** `Krydecres/CX-SHIELD`
**NhÃ¡nh:** `main`

---

## 1. YÃŠU Cáº¦U MÃ”I TRÆ¯á»œNG & CÃ”NG Cá»¤

1. **Flutter SDK:** PhiÃªn báº£n 3.x (kÃ¨m Dart SDK >= 3.0.0).
2. **Java Development Kit (JDK):** JDK 17 hoáº·c 21 (dÃ nh cho Backend).
3. **Apache Maven:** 3.8+ (dÃ nh cho Backend).
4. **Há»‡ Ä‘iá»u hÃ nh há»— trá»£:** Windows / macOS / Linux.

---

## 2. DANH SÃCH FILE TEST SCRIPT

- **Bá»™ kiá»ƒm thá»­ tá»± Ä‘á»™ng má»›i:**
  - `frontend/test/d3_09_qr_studio_automation_test.dart`: Gá»“m 10 luá»“ng automation E2E kiá»ƒm tra toÃ n diá»‡n chá»©c nÄƒng studio thiáº¿t káº¿ áº¥n pháº©m QR D3-09.
- **Bá»™ kiá»ƒm thá»­ há»“i quy (Regression Tests):**
  - `frontend/test/d3_09_qr_studio_test.dart`: 6 widget unit tests kiá»ƒm tra render cÆ¡ báº£n vÃ  live preview.
  - `frontend/test/d3_09_qr_studio_functional_test.dart`: 12 widget tests chá»©c nÄƒng giao diá»‡n D3-09 tá»« SCRUM-235.
  - `backend/src/test/java/com/cxshield/backend/QrStudioSourceTest.java`: 14 unit test Spring Boot / JUnit 5 tá»« SCRUM-234 kiá»ƒm tra logic backend táº¡o QR, lÆ°u `print_designs`, CTA vÃ  logo.

---

## 3. Lá»†NH CHáº Y KIá»‚M THá»¬

### 3.1. Cháº¡y bá»™ kiá»ƒm thá»­ tá»± Ä‘á»™ng má»›i (SCRUM-236)
Thá»±c thi táº¡i thÆ° má»¥c `frontend`:
```powershell
cd frontend
flutter test test/d3_09_qr_studio_automation_test.dart
```

### 3.2. Cháº¡y kiá»ƒm thá»­ há»“i quy Frontend (Regression Tests)
Thá»±c thi táº¡i thÆ° má»¥c `frontend`:
```powershell
cd frontend
flutter test test/d3_09_qr_studio_test.dart test/d3_09_qr_studio_functional_test.dart
```

### 3.3. Cháº¡y kiá»ƒm thá»­ há»“i quy Backend (Regression Tests)
Thá»±c thi táº¡i thÆ° má»¥c `backend`:
```powershell
cd backend
mvn test "-Dtest=QrStudioSourceTest"
```

---

## 4. CHI TIáº¾T CHIáº¾N LÆ¯á»¢C MOCK & Dá»® LIá»†U TEST

- **Mock API HTTP Client:** Bá»™ automation sá»­ dá»¥ng `MockClient` (package `http/testing.dart`) giáº£ láº­p toÃ n bá»™ endpoints backend:
  - `GET /api/v1/qr-codes`: Tráº£ vá» danh sÃ¡ch mÃ£ QR cÃ³ sáºµn cá»§a chi nhÃ¡nh (`MC-B04`, `MC-Q1-T1`).
  - `POST /api/v1/qr-codes`: Tráº£ vá» mÃ£ QR má»›i Ä‘Æ°á»£c táº¡o (`MC-BAN15`).
  - `GET /api/v1/print-designs`: Tráº£ vá» danh sÃ¡ch máº«u thiáº¿t káº¿ áº¥n pháº©m Ä‘Ã£ lÆ°u.
  - `POST /api/v1/print-designs`: Giáº£ láº­p lÆ°u thÃ nh cÃ´ng báº£n thiáº¿t káº¿ vÃ o cÆ¡ sá»Ÿ dá»¯ liá»‡u `print_designs`.
- **Dá»¯ liá»‡u an toÃ n:** KhÃ´ng sá»­ dá»¥ng token tháº­t, khÃ´ng gá»i Supabase production, khÃ´ng hardcode credentials.
- **Giáº£ láº­p Ä‘iá»u hÆ°á»›ng QR (M1-01):**
  - Do háº¡n cháº¿ pháº§n cá»©ng trong mÃ´i trÆ°á»ng CI/Server (khÃ´ng cÃ³ camera Ä‘iá»‡n thoáº¡i tháº­t), ká»‹ch báº£n tá»± Ä‘á»™ng kiá»ƒm tra URL Ä‘Ã­ch `https://cxshield.vn/survey?qr=...` thÃ´ng qua viá»‡c phÃ¢n tÃ­ch dá»¯ liá»‡u tham sá»‘ vÃ  sá»± kiá»‡n Ä‘iá»u hÆ°á»›ng khi click trá»±c tiáº¿p vÃ o khá»‘i QR hoáº·c nÃºt thá»­ nghiá»‡m.
