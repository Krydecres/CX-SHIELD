# HÆ¯á»šNG DáºªN THá»°C THI KIá»‚M THá»¬ MÃƒ NGUá»’N (TEST SCRIPTS)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-237
**TiÃªu Ä‘á»:** [E5.3] Kiá»ƒm thá»­ mÃ£ nguá»“n xuáº¥t file in vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC
**Repository:** `Krydecres/CX-SHIELD`
**NhÃ¡nh:** `main`

---

## 1. YÃŠU Cáº¦U MÃ”I TRÆ¯á»œNG & CÃ”NG Cá»¤

1. **Java Development Kit (JDK):** JDK 21 (hoáº·c JDK 17+).
2. **Apache Maven:** 3.8+ (hoáº·c Maven Wrapper Ä‘i kÃ¨m dá»± Ã¡n).
3. **ThÆ° viá»‡n kiá»ƒm thá»­:**
   - JUnit Jupiter (JUnit 5.10+) kÃ¨m JUnit Jupiter Params.
   - ZXing (`com.google.zxing:core` vÃ  `com.google.zxing:javase` phiÃªn báº£n 3.5.3).
   - Java ImageIO (JDK tiÃªu chuáº©n) cho kiá»ƒm tra Ä‘á»“ há»a nhá»‹ phÃ¢n.
4. **Flutter SDK:** PhiÃªn báº£n 3.x (dÃ¹ng cho cháº¡y regression tests frontend liÃªn quan).

---

## 2. DANH SÃCH FILE TEST SCRIPT

### 2.1. Bá»™ kiá»ƒm thá»­ mÃ£ nguá»“n má»›i (SCRUM-237)
- `backend/src/test/java/com/cxshield/backend/PrintNfcSourceTest.java`:
  - Bao phá»§ 16 Test Cases nghiá»‡p vá»¥ (`SRC-237-01` $\rightarrow$ `SRC-237-16`).
  - Cháº¡y thá»±c táº¿ 28 test methods trong JUnit (do bao gá»“m 13 láº§n cháº¡y tham sá»‘ hÃ³a cho `@ParameterizedTest` kiá»ƒm thá»­ biá»ƒu thá»©c chÃ­nh quy sá»‘ Ä‘iá»‡n thoáº¡i Viá»‡t Nam).

### 2.2. Bá»™ kiá»ƒm thá»­ há»“i quy liÃªn quan (Regression Tests)
- `backend/src/test/java/com/cxshield/backend/PrintDesignControllerTest.java`: 8 unit tests kiá»ƒm tra API Controller xuáº¥t file in áº¥n vÃ  CRUD máº«u thiáº¿t káº¿.
- `backend/src/test/java/com/cxshield/backend/NfcOrderControllerTest.java`: 8 unit tests kiá»ƒm tra API Controller Ä‘Æ¡n Ä‘áº·t hÃ ng phÃ´i tháº» NFC.
- `backend/src/test/java/com/cxshield/backend/QrStudioSourceTest.java`: 14 unit tests kiá»ƒm tra logic táº¡o QR chi nhÃ¡nh vÃ  cáº¥u hÃ¬nh studio D3-09 tá»« SCRUM-234.
- `frontend/test/d3_11_print_nfc_test.dart`: 4 widget tests kiá»ƒm tra hiá»ƒn thá»‹ giao diá»‡n vÃ  chuyá»ƒn tab Ä‘áº·t tháº» trÃªn mÃ n D3-11.

---

## 3. Lá»†NH THá»°C THI KIá»‚M THá»¬

### 3.1. Cháº¡y bá»™ kiá»ƒm thá»­ mÃ£ nguá»“n má»›i cá»§a SCRUM-237
Thá»±c thi táº¡i thÆ° má»¥c `backend`:
```powershell
cd backend
mvn test "-Dtest=PrintNfcSourceTest"
```

### 3.2. Cháº¡y toÃ n bá»™ kiá»ƒm thá»­ há»“i quy Backend liÃªn quan
Thá»±c thi táº¡i thÆ° má»¥c `backend`:
```powershell
cd backend
mvn test "-Dtest=PrintNfcSourceTest,PrintDesignControllerTest,NfcOrderControllerTest,QrStudioSourceTest"
```

### 3.3. Cháº¡y kiá»ƒm thá»­ há»“i quy giao diá»‡n Frontend (D3-11)
Thá»±c thi táº¡i thÆ° má»¥c `frontend`:
```powershell
cd frontend
flutter test test/d3_11_print_nfc_test.dart
```

---

## 4. CHIáº¾N LÆ¯á»¢C MOCK VÃ€ Äáº¢M Báº¢O AN TOÃ€N Dá»® LIá»†U

- **Táº§ng Repository Mock:** Sá»­ dá»¥ng in-memory mock repository (`ConcurrentHashMap`) giáº£ láº­p lÆ°u trá»¯ dá»¯ liá»‡u cá»§a báº£ng `print_designs` vÃ  `nfc_orders` tÆ°Æ¡ng Ä‘Æ°Æ¡ng mÃ´i trÆ°á»ng Supabase PostgreSQL.
- **KhÃ´ng truy cáº­p cÆ¡ sá»Ÿ dá»¯ liá»‡u tháº­t:** Bá»™ test khÃ´ng táº¡o káº¿t ná»‘i máº¡ng ra ngoÃ i, khÃ´ng gá»i PostgREST hoáº·c Supabase Live Database, ngÄƒn ngá»«a rá»§i ro rÃ² rá»‰ dá»¯ liá»‡u hoáº·c sai lá»‡ch dá»¯ liá»‡u sáº£n xuáº¥t.
- **KhÃ´ng hardcode secrets:** KhÃ´ng lÆ°u trá»¯ API key, service role key hay JWT token bÃ­ máº­t trong mÃ£ kiá»ƒm thá»­.
- **Kiá»ƒm tra Ä‘á»“ há»a vÃ  mÃ£ váº¡ch thá»±c táº¿:**
  - áº¢nh PNG Ä‘Æ°á»£c render thá»±c sá»± trong bá»™ nhá»› RAM qua `BufferedImage` vÃ  thÆ° viá»‡n ZXing `MultiFormatReader` quÃ©t ngÆ°á»£c láº¡i ma tráº­n Ä‘iá»ƒm áº£nh Ä‘á»ƒ chá»©ng minh tÃ­nh quÃ©t Ä‘Æ°á»£c 100%.
  - Luá»“ng nhá»‹ phÃ¢n PDF Ä‘Æ°á»£c phÃ¢n tÃ­ch trá»±c tiáº¿p theo tá»«ng byte Ä‘á»‘i tÆ°á»£ng (`%PDF-1.4`, `MediaBox`, `XObject`, `xref`, `trailer`) Ä‘á»ƒ xÃ¡c Ä‘á»‹nh Ä‘Ãºng cáº¥u trÃºc ISO 32000-1.
