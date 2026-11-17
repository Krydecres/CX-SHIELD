# BÃO CÃO Káº¾T QUáº¢ KIá»‚M THá»¬ MÃƒ NGUá»’N (TEST EXECUTION REPORT)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-237
**TiÃªu Ä‘á»:** [E5.3] Kiá»ƒm thá»­ mÃ£ nguá»“n xuáº¥t file in vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC
**Story cha:** SCRUM-136 ([E5.3] Xuáº¥t file in áº¥n cháº¥t lÆ°á»£ng cao & Ä‘áº·t hÃ ng phÃ´i tháº» NFC váº­t lÃ½)
**Task code Ä‘á»‘i á»©ng:** SCRUM-214 (ÄÃ£ hoÃ n thÃ nh vÃ  merge vÃ o `main` táº¡i commit `b819682`)
**Repository:** `Krydecres/CX-SHIELD`
**NhÃ¡nh:** `main`
**NgÃ y thá»±c hiá»‡n & RÃ  soÃ¡t cuá»‘i:** 17/11/2026
**MÃ´i trÆ°á»ng:** Java 21 / Apache Maven 3.8+ / Spring Boot Unit Test

---

## 1. Tá»”NG QUAN Káº¾T QUáº¢ KIá»‚M THá»¬

| Chá»‰ sá»‘ kiá»ƒm thá»­ | Sá»‘ lÆ°á»£ng | Tá»· lá»‡ (%) | Ghi chÃº |
|---|---|---|---|
| **Tá»•ng sá»‘ Test Cases thiáº¿t káº¿** | **16** | **100%** | Bao phá»§ toÃ n bá»™ pháº¡m vi SCRUM-237 |
| **â€¢ PASS** | **13** | **81.25%** | ÄÃ¡p á»©ng Ä‘Ãºng yÃªu cáº§u thiáº¿t káº¿ vÃ  nghiá»‡p vá»¥ |
| **â€¢ FAIL** | **3** | **18.75%** | PhÃ¡t hiá»‡n sai lá»‡ch chuáº©n PDF vÃ  2 lá»— há»•ng báº£o máº­t tenant |
| **â€¢ BLOCKED** | **0** | **0%** | KhÃ´ng cÃ³ test case nÃ o bá»‹ ngháº½n |
| **â€¢ NOT RUN** | **0** | **0%** | Cháº¡y Ä‘áº§y Ä‘á»§ 16/16 test cases trÃªn test suite |

### Thá»‘ng kÃª thá»±c thi Automated Unit Tests
- **Bá»™ kiá»ƒm thá»­ mÃ£ nguá»“n má»›i (`PrintNfcSourceTest.java`):**
  - **28/28 tests passed** (Bao gá»“m 15 bÃ i test tiÃªu chuáº©n vÃ  13 láº§n cháº¡y tham sá»‘ hÃ³a `@ParameterizedTest` cho kiá»ƒm tra biá»ƒu thá»©c chÃ­nh quy sá»‘ Ä‘iá»‡n thoáº¡i Viá»‡t Nam, tÃ­ch há»£p xÃ¡c thá»±c parser PDFBox 3.0.4).
- **Bá»™ kiá»ƒm thá»­ há»“i quy Backend liÃªn quan:**
  - `PrintDesignControllerTest.java`: **8/8 passed**
  - `NfcOrderControllerTest.java`: **8/8 passed**
  - `QrStudioSourceTest.java`: **14/14 passed**
  - *Tá»•ng cá»™ng há»“i quy backend:* **30/30 passed** (100%)
- **Bá»™ kiá»ƒm thá»­ há»“i quy Frontend liÃªn quan:**
  - `d3_11_print_nfc_test.dart`: **4/4 passed** (100%)
- **Tá»•ng sá»‘ automated tests Ä‘Ã£ cháº¡y thá»±c táº¿:** **62 tests** (62/62 passed â€“ BUILD SUCCESS).

---

## 2. Káº¾T QUáº¢ CHI TIáº¾T Tá»ªNG TEST CASE

| MÃ£ TC | Háº¡ng má»¥c kiá»ƒm tra | Tráº¡ng thÃ¡i | Diá»…n giáº£i káº¿t quáº£ thá»±c táº¿ |
|---|---|---|---|
| `SRC-237-01` | KÃ­ch thÆ°á»›c xuáº¥t áº£nh PNG chuáº©n 300 DPI | PASS | A6 xuáº¥t Ä‘Ãºng 1240x1754 px, A5 xuáº¥t Ä‘Ãºng 1754x2480 px. Header `X-Print-DPI: 300` |
| `SRC-237-02` | Kháº£ nÄƒng quÃ©t mÃ£ QR tá»« áº£nh xuáº¥t ra | PASS | ThÆ° viá»‡n ZXing giáº£i mÃ£ thÃ nh cÃ´ng URL `https://cxshield.vn/survey?qr=MC-B04` |
| `SRC-237-03` | Tá»± Ä‘á»™ng chuáº©n hÃ³a Ä‘á»™ phÃ¢n giáº£i tá»‘i thiá»ƒu 300 DPI | PASS | Cáº¥u hÃ¬nh DPI Ä‘áº§u vÃ o 72 Ä‘Æ°á»£c Ã©p lÃªn 300 DPI (`Math.max(dpi, 300)`) |
| `SRC-237-04` | PhÃ¢n tÃ­ch metadata PNG máº­t Ä‘á»™ Ä‘iá»ƒm áº£nh | PASS | áº¢nh cÃ³ pixel 300 DPI nhÆ°ng khÃ´ng chá»©a chunk `pHYs` nhÃºng metadata DPI |
| `SRC-237-05` | Cáº¥u trÃºc chuáº©n file PDF 1.4 | PASS | CÃ³ header `%PDF-1.4`, Catalog, Pages, Page MediaBox `[0 0 298 420]` vÃ  XObject |
| `SRC-237-06` | Chuáº©n hÃ³a stream nÃ©n hÃ¬nh áº£nh trong PDF | FAIL | DÃ²ng 222 khai bÃ¡o `/Filter /DCTDecode` (JPEG) nhÆ°ng nhÃºng bytes áº£nh PNG (`BUG-SCRUM237-01`) |
| `SRC-237-07` | Xá»­ lÃ½ lá»—i xuáº¥t file khi ID khÃ´ng tá»“n táº¡i | PASS | NÃ©m `ApiException` HTTP 404 `DESIGN_NOT_FOUND` |
| `SRC-237-08` | Äáº·t phÃ´i tháº» Gá»— & tÃ­nh toÃ¡n Ä‘Æ¡n giÃ¡ | PASS | ÄÆ¡n giÃ¡ 45.000 VNÄ, nhÃ¢n Ä‘Ãºng sá»‘ lÆ°á»£ng, tráº¡ng thÃ¡i ban Ä‘áº§u `PENDING` |
| `SRC-237-09` | Äáº·t phÃ´i tháº» Mica & tÃ­nh toÃ¡n Ä‘Æ¡n giÃ¡ | PASS | ÄÆ¡n giÃ¡ 35.000 VNÄ, nhÃ¢n Ä‘Ãºng sá»‘ lÆ°á»£ng, tráº¡ng thÃ¡i ban Ä‘áº§u `PENDING` |
| `SRC-237-10` | Validation sá»‘ lÆ°á»£ng phÃ´i tháº» | PASS | Tá»« chá»‘i sá»‘ lÆ°á»£ng <= 0 vá»›i `IllegalArgumentException` |
| `SRC-237-11` | Validation sá»‘ Ä‘iá»‡n thoáº¡i giao hÃ ng VN | PASS | Cháº¥p nháº­n cÃ¡c Ä‘áº§u sá»‘ 03, 05, 07, 08, 09, +84; tá»« chá»‘i sá»‘ sai quy chuáº©n |
| `SRC-237-12` | Validation tÃªn vÃ  Ä‘á»‹a chá»‰ ngÆ°á»i nháº­n | PASS | Tá»« chá»‘i tÃªn rá»—ng vÃ  Ä‘á»‹a chá»‰ nháº­n hÃ ng dÆ°á»›i 5 kÃ½ tá»± |
| `SRC-237-13` | RÃ ng buá»™c khÃ³a ngoáº¡i máº«u thiáº¿t káº¿ | PASS | Tá»« chá»‘i Ä‘áº·t hÃ ng vá»›i designId khÃ´ng tá»“n táº¡i (HTTP 400 `DESIGN_NOT_FOUND`) |
| `SRC-237-14` | Ghi nháº­n Ä‘Æ¡n hÃ ng vÃ o nfc_orders | PASS | Tá»± sinh UUID, lÆ°u Ä‘Ãºng giÃ¡ trá»‹, tráº¡ng thÃ¡i khá»Ÿi táº¡o `PENDING` ("Má»›i tiáº¿p nháº­n") |
| `SRC-237-15` | PhÃ¢n quyá»n truy cáº­p theo cÆ¡ sá»Ÿ (Tenant Isolation) | FAIL | `getOrders(null)` vÃ  `getDesigns(null)` tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u cá»§a má»i cÆ¡ sá»Ÿ (`BUG-SCRUM237-02`) |
| `SRC-237-16` | PhÃ¢n quyá»n truy cáº­p theo ID (IDOR) | FAIL | Thiáº¿u kiá»ƒm tra quyá»n sá»Ÿ há»¯u Ä‘á»‘i chiáº¿u JWT token khi xem/xuáº¥t/xÃ³a theo ID (`BUG-SCRUM237-03`) |

---

## 3. BÃO CÃO Lá»–I VÃ€ QUAN SÃT (BUGS & OBSERVATIONS)

1. **BUG-SCRUM237-01 (Má»©c Ä‘á»™: Medium - CONFIRMED):** Sai lá»‡ch bá»™ lá»c giáº£i mÃ£ Ä‘á»‘i tÆ°á»£ng áº£nh trong file PDF. Code `PrintExportService.java` (L222) chá»‰ Ä‘á»‹nh `/Filter /DCTDecode` nhÆ°ng ghi dá»¯ liá»‡u byte PNG (chá»©a chá»¯ kÃ½ `â€°PNG`). ThÆ° viá»‡n Apache PDFBox 3.0.4 giáº£i mÃ£ tháº¥t báº¡i vá»›i `IIOException: Not a JPEG file: starts with 0xf1 0x11`.
2. **BUG-SCRUM237-02 (Má»©c Ä‘á»™: High - CONFIRMED):** Lá»— há»•ng rÃ² rá»‰ dá»¯ liá»‡u Ä‘a cÆ¡ sá»Ÿ (Multi-tenant Isolation Breach). Khi client khÃ´ng truyá»n `businessId` lÃªn API `GET /api/v1/nfc-orders` vÃ  `GET /api/v1/print-designs`, repository tráº£ vá» toÃ n bá»™ Ä‘Æ¡n hÃ ng vÃ  thiáº¿t káº¿ cá»§a má»i khÃ¡ch hÃ ng trong há»‡ thá»‘ng.
3. **BUG-SCRUM237-03 (Má»©c Ä‘á»™: High - CONFIRMED):** Lá»— há»•ng báº£o máº­t IDOR táº¡i cÃ¡c API truy váº¥n trá»±c tiáº¿p qua ID (`getOrderById`, `getDesignById`, `exportPrintDesign`, `deleteDesign`). Caller cÃ³ thá»ƒ truy cáº­p thÃ´ng tin cÃ¡ nhÃ¢n khÃ¡ch hÃ ng, xuáº¥t file in áº¥n vÃ  xÃ³a vÄ©nh viá»…n thiáº¿t káº¿ cá»§a tenant khÃ¡c mÃ  khÃ´ng bá»‹ kiá»ƒm tra quyá»n sá»Ÿ há»¯u.
4. **OBS-SCRUM237-01 (Má»©c Ä‘á»™: Low - CONFIRMED):** Tá»‡p PNG xuáº¥t ra cÃ³ kÃ­ch thÆ°á»›c pixel tÆ°Æ¡ng á»©ng 300 DPI nhÆ°ng chÆ°a cÃ³ chunk `pHYs` nhÃºng thÃ´ng tin máº­t Ä‘á»™ Ä‘iá»ƒm áº£nh.

---

## 4. PHáº M VI CHÆ¯A KIá»‚M THá»¬ ÄÆ¯á»¢C (TEST LIMITATIONS)

1. **Kiá»ƒm thá»­ trÃªn CSDL Supabase PostgreSQL Live:** ToÃ n bá»™ test mÃ£ nguá»“n á»Ÿ task nÃ y cháº¡y trÃªn táº§ng Unit/Mock Repository (`ConcurrentHashMap`) nháº±m Ä‘áº£m báº£o an toÃ n tuyá»‡t Ä‘á»‘i vÃ  tÃ­nh Ä‘á»™c láº­p cá»§a CI pipeline; cÃ¡c chÃ­nh sÃ¡ch Supabase Row-Level Security (RLS) trÃªn server tháº­t chÆ°a Ä‘Æ°á»£c kÃ­ch hoáº¡t trá»±c tiáº¿p trong Ä‘á»£t test nÃ y.
2. **Pháº§n cá»©ng tháº» NFC váº­t lÃ½:** Kiá»ƒm thá»­ chá»‰ xÃ¡c thá»±c viá»‡c lÆ°u trá»¯ Ä‘Æ¡n hÃ ng vÃ  tÃ­nh Ä‘Ãºng Ä‘áº¯n cá»§a URL; viá»‡c náº¡p chip NFC (NFC encoding) vÃ  giao nháº­n thá»±c táº¿ cáº§n kiá»ƒm chá»©ng á»Ÿ mÃ´i trÆ°á»ng ngoÃ i Ä‘á»i thá»±c.
