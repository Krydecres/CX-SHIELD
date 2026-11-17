# DANH SÃCH TEST CASES KIá»‚M THá»¬ MÃƒ NGUá»’N (SOURCE CODE TEST CASES)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-237
**TiÃªu Ä‘á»:** [E5.3] Kiá»ƒm thá»­ mÃ£ nguá»“n xuáº¥t file in vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC
**Story cha:** SCRUM-136 ([E5.3] Xuáº¥t file in áº¥n cháº¥t lÆ°á»£ng cao & Ä‘áº·t hÃ ng phÃ´i tháº» NFC váº­t lÃ½)
**Task code Ä‘á»‘i á»©ng:** SCRUM-214 (Code Ä‘Ã£ hoÃ n thÃ nh vÃ  merge vÃ o `main` táº¡i commit `b819682`)
**Táº­p tin ká»‹ch báº£n test:** `backend/src/test/java/com/cxshield/backend/PrintNfcSourceTest.java`
**MÃ´i trÆ°á»ng:** Java 21 / JUnit 5 / Mock In-memory Repository & Controller Unit Test

---

## Báº¢NG Tá»”NG Há»¢P Káº¾T QUáº¢ TEST CASES

| MÃ£ TC | TÃªn ca kiá»ƒm thá»­ mÃ£ nguá»“n | Háº¡ng má»¥c kiá»ƒm tra | Káº¿t quáº£ | Ghi chÃº / PhÃ¢n loáº¡i |
|---|---|---|---|---|
| SRC-237-01 | Xuáº¥t PNG chuáº©n kÃ­ch thÆ°á»›c A6 vÃ  A5 tÆ°Æ¡ng á»©ng cáº¥u hÃ¬nh 300 DPI | Xuáº¥t File In & DPI | PASS | A6: 1240x1754 px; A5: 1754x2480 px |
| SRC-237-02 | MÃ£ QR trong file PNG xuáº¥t ra cÃ³ thá»ƒ giáº£i mÃ£ 100% báº±ng ZXing | QR Decoding & Scannability | PASS | Giáº£i mÃ£ Ä‘Ãºng URL kháº£o sÃ¡t |
| SRC-237-03 | Cáº¥u hÃ¬nh DPI Ä‘áº§u vÃ o tá»± Ä‘á»™ng Ä‘Æ°á»£c chuáº©n hÃ³a lÃªn tá»‘i thiá»ƒu 300 DPI | Cáº¥u hÃ¬nh Resolution | PASS | Math.max(dpi, 300) |
| SRC-237-04 | PhÃ¢n tÃ­ch metadata PNG: Cáº¥u hÃ¬nh Ä‘áº¡t kÃ­ch thÆ°á»›c, thiáº¿u chunk pHYs | Metadata File In | PASS | XÃ¡c minh khÃ´ng kháº³ng Ä‘á»‹nh sai vá» metadata |
| SRC-237-05 | Xuáº¥t PDF header Ä‘áº¡t chuáº©n %PDF-1.4, Catalog, Pages, XObject | Cáº¥u trÃºc File PDF | PASS | Äáº¡t cáº¥u trÃºc chuáº©n ISO 32000-1 |
| SRC-237-06 | PhÃ¢n tÃ­ch stream PDF: Khai bÃ¡o /Filter /DCTDecode nhÆ°ng nhÃºng PNG | Chuáº©n nÃ©n File PDF | FAIL | Vi pháº¡m chuáº©n PDF, ghi nháº­n BUG-SCRUM237-01 |
| SRC-237-07 | Xuáº¥t file vá»›i designId khÃ´ng tá»“n táº¡i nÃ©m lá»—i 404 DESIGN_NOT_FOUND | Xá»­ lÃ½ lá»—i xuáº¥t file | PASS | NÃ©m ApiException HTTP 404 |
| SRC-237-08 | Äáº·t phÃ´i tháº» Gá»– tÃ­nh Ä‘Ãºng Ä‘Æ¡n giÃ¡ 45.000 VNÄ vÃ  tá»•ng tiá»n | Äáº·t tháº» NFC & ÄÆ¡n giÃ¡ | PASS | ÄÆ¡n giÃ¡ 45.000 VNÄ/tháº», tráº¡ng thÃ¡i PENDING |
| SRC-237-09 | Äáº·t phÃ´i tháº» MICA tÃ­nh Ä‘Ãºng Ä‘Æ¡n giÃ¡ 35.000 VNÄ vÃ  tá»•ng tiá»n | Äáº·t tháº» NFC & ÄÆ¡n giÃ¡ | PASS | ÄÆ¡n giÃ¡ 35.000 VNÄ/tháº», tráº¡ng thÃ¡i PENDING |
| SRC-237-10 | Tá»« chá»‘i Ä‘Æ¡n hÃ ng cÃ³ sá»‘ lÆ°á»£ng <= 0 (Quantity validation) | Validation dá»¯ liá»‡u | PASS | NÃ©m IllegalArgumentException |
| SRC-237-11 | Validation sá»‘ Ä‘iá»‡n thoáº¡i: Cháº¥p nháº­n SÄT VN há»£p lá»‡, tá»« chá»‘i sá»‘ sai | Validation dá»¯ liá»‡u | PASS | Kiá»ƒm tra Regex SÄT chuáº©n Viá»‡t Nam |
| SRC-237-12 | Tá»« chá»‘i tÃªn ngÆ°á»i nháº­n trá»‘ng vÃ  Ä‘á»‹a chá»‰ nháº­n hÃ ng dÆ°á»›i 5 kÃ½ tá»± | Validation dá»¯ liá»‡u | PASS | Kiá»ƒm tra Ä‘á»™ dÃ i vÃ  rá»—ng |
| SRC-237-13 | Tá»« chá»‘i Ä‘áº·t hÃ ng khi máº«u thiáº¿t káº¿ designId khÃ´ng tá»“n táº¡i | Xá»­ lÃ½ lá»—i liÃªn káº¿t | PASS | NÃ©m ApiException HTTP 400 |
| SRC-237-14 | LÆ°u Ä‘Æ¡n hÃ ng má»›i vÃ o nfc_orders tá»± sinh UUID vÃ  tráº¡ng thÃ¡i PENDING | LÆ°u trá»¯ & Khá»Ÿi táº¡o | PASS | ÄÃºng schema nfc_orders |
| SRC-237-15 | PhÃ¢n quyá»n truy cáº­p theo cÆ¡ sá»Ÿ: CÃ¡ch ly khi cÃ³ businessId, há»Ÿ khi null | PhÃ¢n quyá»n Tenant | FAIL | RÃ² rá»‰ dá»¯ liá»‡u khi null, ghi nháº­n BUG-SCRUM237-02 |
| SRC-237-16 | PhÃ¢n quyá»n truy cáº­p theo ID: Thiáº¿u kiá»ƒm tra quyá»n sá»Ÿ há»¯u (IDOR) | PhÃ¢n quyá»n Tenant | FAIL | Thiáº¿u verify caller token, ghi nháº­n OBS-SCRUM237-02 |

---

## CHI TIáº¾T CÃC CA KIá»‚M THá»¬ MÃƒ NGUá»’N

### SRC-237-01: Xuáº¥t PNG chuáº©n kÃ­ch thÆ°á»›c A6 vÃ  A5 tÆ°Æ¡ng á»©ng cáº¥u hÃ¬nh 300 DPI
- **Má»¥c tiÃªu:** XÃ¡c nháº­n logic `generateHighResPrintImage` vÃ  `exportToPngBytes` trong `PrintExportService` xuáº¥t ra áº£nh cÃ³ kÃ­ch thÆ°á»›c pixel chuáº©n in áº¥n 300 DPI theo khá»• A6 vÃ  A5.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Thiáº¿t káº¿ máº«u A6 (105 x 148 mm) vÃ  A5 (148 x 210 mm), DPI = 300.
- **Káº¿t quáº£ mong Ä‘á»£i:** KÃ­ch thÆ°á»›c áº£nh xuáº¥t ra lÃ  1240 x 1754 px (A6) vÃ  1754 x 2480 px (A5); Header HTTP tráº£ vá» `Content-Type: image/png` vÃ  `X-Print-DPI: 300`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-02: MÃ£ QR trong file PNG xuáº¥t ra cÃ³ thá»ƒ giáº£i mÃ£ 100% báº±ng ZXing
- **Má»¥c tiÃªu:** Äáº£m báº£o mÃ£ QR Ä‘Æ°á»£c váº½ trong áº£nh in áº¥n cÃ³ Ä‘á»™ tÆ°Æ¡ng pháº£n cao, Ä‘Ãºng Ä‘á»‹nh dáº¡ng vÃ  Ä‘á»c Ä‘Æ°á»£c hoÃ n toÃ n báº±ng bá»™ giáº£i mÃ£ mÃ£ váº¡ch cÃ´ng nghiá»‡p (ZXing MultiFormatReader).
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** File PNG xuáº¥t ra tá»« máº«u thiáº¿t káº¿ cá»§a chi nhÃ¡nh Maison Coffee (`MC-B04`).
- **Káº¿t quáº£ mong Ä‘á»£i:** ZXing giáº£i mÃ£ thÃ nh cÃ´ng chuá»—i URL `https://cxshield.vn/survey?qr=MC-B04`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-03: Cáº¥u hÃ¬nh DPI Ä‘áº§u vÃ o tá»± Ä‘á»™ng Ä‘Æ°á»£c chuáº©n hÃ³a lÃªn tá»‘i thiá»ƒu 300 DPI
- **Má»¥c tiÃªu:** Kiá»ƒm tra cÆ¡ cháº¿ tá»± Ä‘á»™ng Ã©p Ä‘á»™ phÃ¢n giáº£i in Ä‘áº¡t chuáº©n nghiá»‡m thu tá»‘i thiá»ƒu 300 DPI ká»ƒ cáº£ khi client truyá»n giÃ¡ trá»‹ tháº¥p (72 DPI hoáº·c 150 DPI).
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Tham sá»‘ `dpi = 72`.
- **Káº¿t quáº£ mong Ä‘á»£i:** Controller Ã¡p dá»¥ng `finalDpi = Math.max(dpi, 300)` tráº£ vá» áº£nh 1240x1754 px vÃ  header `X-Print-DPI: 300`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-04: PhÃ¢n tÃ­ch metadata PNG: Cáº¥u hÃ¬nh Ä‘áº¡t kÃ­ch thÆ°á»›c, thiáº¿u chunk pHYs
- **Má»¥c tiÃªu:** XÃ¡c minh tÃ­nh trung thá»±c ká»¹ thuáº­t Ä‘á»‘i vá»›i tiÃªu chuáº©n 300 DPI: phÃ¢n biá»‡t giá»¯a cáº¥u hÃ¬nh kÃ­ch thÆ°á»›c pixel vá»›i viá»‡c nhÃºng metadata DPI vÃ o file PNG.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Máº£ng byte PNG xuáº¥t ra tá»« `ImageIO.write()`.
- **Káº¿t quáº£ mong Ä‘á»£i:** File cÃ³ magic byte PNG há»£p lá»‡ nhÆ°ng khÃ´ng chá»©a chunk `pHYs` nhÃºng máº­t Ä‘á»™ phÃ¢n giáº£i; ngÆ°á»i dÃ¹ng má»Ÿ báº±ng cÃ¡c pháº§n má»m Ä‘á»“ há»a chuyÃªn nghiá»‡p sáº½ tháº¥y máº·c Ä‘á»‹nh 72 hoáº·c 96 DPI dÃ¹ sá»‘ lÆ°á»£ng pixel Ä‘áº§y Ä‘á»§.
- **Káº¿t quáº£ thá»±c táº¿:** PASS (XÃ¡c nháº­n Ä‘Ãºng hÃ nh vi hiá»‡n táº¡i cá»§a code).

### SRC-237-05: Xuáº¥t PDF header Ä‘áº¡t chuáº©n %PDF-1.4, Catalog, Pages, XObject
- **Má»¥c tiÃªu:** XÃ¡c nháº­n cáº¥u trÃºc nhá»‹ phÃ¢n cá»§a file PDF xuáº¥t ra tuÃ¢n thá»§ Ä‘áº·c táº£ PDF 1.4 (ISO 32000-1).
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Xuáº¥t PDF tá»« thiáº¿t káº¿ khá»• A6.
- **Káº¿t quáº£ mong Ä‘á»£i:** Má»Ÿ Ä‘áº§u báº±ng `%PDF-1.4`, chá»©a cÃ¡c Ä‘á»‘i tÆ°á»£ng `Catalog`, `Pages`, `Page` vá»›i MediaBox `[0 0 298 420]` dáº¡ng point, báº£ng `xref` vÃ  `%%EOF`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-06: PhÃ¢n tÃ­ch stream PDF: Khai bÃ¡o /Filter /DCTDecode nhÆ°ng nhÃºng PNG
- **Má»¥c tiÃªu:** Kiá»ƒm tra tÃ­nh toÃ n váº¹n vÃ  tÆ°Æ¡ng thÃ­ch chuáº©n cá»§a Ä‘á»‘i tÆ°á»£ng hÃ¬nh áº£nh XObject trong PDF.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Stream Ä‘á»‘i tÆ°á»£ng hÃ¬nh áº£nh sá»‘ 4 (`4 0 obj`) trong file PDF xuáº¥t ra.
- **Káº¿t quáº£ mong Ä‘á»£i:** Náº¿u nhÃºng Ä‘á»‹nh dáº¡ng PNG thÃ¬ bá»™ lá»c pháº£i lÃ  `/FlateDecode` (hoáº·c chuyá»ƒn Ä‘á»•i áº£nh sang JPEG náº¿u dÃ¹ng `/DCTDecode`).
- **Káº¿t quáº£ thá»±c táº¿:** FAIL (Code táº¡i `PrintExportService.java` dÃ²ng 222 khai bÃ¡o `/Filter /DCTDecode` nhÆ°ng ghi trá»±c tiáº¿p `pngBytes` chá»©a chá»¯ kÃ½ `â€°PNG`. Má»™t sá»‘ trÃ¬nh xem PDF nghiÃªm ngáº·t sáº½ bÃ¡o lá»—i file há»ng). Ghi nháº­n `BUG-SCRUM237-01`.

### SRC-237-07: Xuáº¥t file vá»›i designId khÃ´ng tá»“n táº¡i nÃ©m lá»—i 404 DESIGN_NOT_FOUND
- **Má»¥c tiÃªu:** Kiá»ƒm tra xá»­ lÃ½ ngoáº¡i lá»‡ khi yÃªu cáº§u xuáº¥t file vá»›i ID khÃ´ng cÃ³ trong cÆ¡ sá»Ÿ dá»¯ liá»‡u.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `designId = UUID.randomUUID()`.
- **Káº¿t quáº£ mong Ä‘á»£i:** NÃ©m `ApiException` vá»›i mÃ£ `DESIGN_NOT_FOUND` vÃ  HTTP status 404 Not Found.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-08: Äáº·t phÃ´i tháº» Gá»– tÃ­nh Ä‘Ãºng Ä‘Æ¡n giÃ¡ 45.000 VNÄ vÃ  tá»•ng tiá»n
- **Má»¥c tiÃªu:** Kiá»ƒm tra nghiá»‡p vá»¥ Ä‘áº·t tháº» gá»— Walnut: Ä‘Æ¡n giÃ¡ 45.000 VNÄ, tá»•ng tiá»n = Ä‘Æ¡n giÃ¡ * sá»‘ lÆ°á»£ng, tráº¡ng thÃ¡i ban Ä‘áº§u `PENDING`.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `material = "WOOD"`, `quantity = 8`.
- **Káº¿t quáº£ mong Ä‘á»£i:** ÄÆ¡n giÃ¡ 45.000 VNÄ, tá»•ng tiá»n 360.000 VNÄ, tráº¡ng thÃ¡i `PENDING` ("Má»›i tiáº¿p nháº­n").
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-09: Äáº·t phÃ´i tháº» MICA tÃ­nh Ä‘Ãºng Ä‘Æ¡n giÃ¡ 35.000 VNÄ vÃ  tá»•ng tiá»n
- **Má»¥c tiÃªu:** Kiá»ƒm tra nghiá»‡p vá»¥ Ä‘áº·t tháº» Mica Acrylic: Ä‘Æ¡n giÃ¡ 35.000 VNÄ, tá»•ng tiá»n = Ä‘Æ¡n giÃ¡ * sá»‘ lÆ°á»£ng, tráº¡ng thÃ¡i ban Ä‘áº§u `PENDING`.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `material = "MICA"`, `quantity = 15`.
- **Káº¿t quáº£ mong Ä‘á»£i:** ÄÆ¡n giÃ¡ 35.000 VNÄ, tá»•ng tiá»n 525.000 VNÄ, tráº¡ng thÃ¡i `PENDING`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-10: Tá»« chá»‘i Ä‘Æ¡n hÃ ng cÃ³ sá»‘ lÆ°á»£ng <= 0 (Quantity validation)
- **Má»¥c tiÃªu:** XÃ¡c nháº­n logic kiá»ƒm tra há»£p lá»‡ cá»§a sá»‘ lÆ°á»£ng phÃ´i tháº» Ä‘áº·t in.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `quantity = 0` vÃ  `quantity = -5`.
- **Káº¿t quáº£ mong Ä‘á»£i:** NÃ©m `IllegalArgumentException` vá»›i thÃ´ng bÃ¡o "Sá»‘ lÆ°á»£ng phÃ´i tháº» pháº£i tá»‘i thiá»ƒu lÃ  1".
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-11: Validation sá»‘ Ä‘iá»‡n thoáº¡i: Cháº¥p nháº­n SÄT VN há»£p lá»‡, tá»« chá»‘i sá»‘ sai
- **Má»¥c tiÃªu:** XÃ¡c nháº­n Regex kiá»ƒm tra sá»‘ Ä‘iá»‡n thoáº¡i ngÆ°á»i nháº­n hÃ ng tuÃ¢n thá»§ quy chuáº©n máº¡ng viá»…n thÃ´ng Viá»‡t Nam (Ä‘áº§u sá»‘ 03, 05, 07, 08, 09 hoáº·c +84).
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Bá»™ test há»£p lá»‡: `0901234567`, `+84912345678`, `0323456789`, `0898765432`, `0765432109`, `0587654321`. Bá»™ test khÃ´ng há»£p lá»‡: `123456`, `090123456`, `abc`, `0123456789`, `""`.
- **Káº¿t quáº£ mong Ä‘á»£i:** Cháº¥p nháº­n toÃ n bá»™ SÄT há»£p lá»‡ vÃ  nÃ©m `IllegalArgumentException` vá»›i cÃ¡c sá»‘ sai.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-12: Tá»« chá»‘i tÃªn ngÆ°á»i nháº­n trá»‘ng vÃ  Ä‘á»‹a chá»‰ nháº­n hÃ ng dÆ°á»›i 5 kÃ½ tá»±
- **Má»¥c tiÃªu:** Äáº£m báº£o Ä‘Æ¡n Ä‘áº·t hÃ ng cÃ³ Ä‘á»§ thÃ´ng tin ngÆ°á»i nháº­n Ä‘á»ƒ giao váº­n.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** TÃªn rá»—ng `"   "` hoáº·c Ä‘á»‹a chá»‰ `"123 "`.
- **Káº¿t quáº£ mong Ä‘á»£i:** NÃ©m `IllegalArgumentException` tÆ°Æ¡ng á»©ng.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-13: Tá»« chá»‘i Ä‘áº·t hÃ ng khi máº«u thiáº¿t káº¿ designId khÃ´ng tá»“n táº¡i
- **Má»¥c tiÃªu:** Kiá»ƒm tra rÃ ng buá»™c khÃ³a ngoáº¡i logic giá»¯a `nfc_orders` vÃ  `print_designs`.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `designId = UUID.randomUUID()`.
- **Káº¿t quáº£ mong Ä‘á»£i:** NÃ©m `ApiException` mÃ£ `DESIGN_NOT_FOUND` vÃ  HTTP 400 Bad Request.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-14: LÆ°u Ä‘Æ¡n hÃ ng má»›i vÃ o nfc_orders tá»± sinh UUID vÃ  tráº¡ng thÃ¡i PENDING
- **Má»¥c tiÃªu:** Kiá»ƒm tra cÆ¡ cháº¿ lÆ°u trá»¯ dá»¯ liá»‡u Ä‘Æ¡n hÃ ng vÃ o repository `nfc_orders`.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** ÄÆ¡n hÃ ng má»›i chÆ°a cÃ³ ID.
- **Káº¿t quáº£ mong Ä‘á»£i:** Repository tá»± Ä‘á»™ng sinh UUID, lÆ°u Ä‘Ãºng toÃ n bá»™ thÃ´ng tin vÃ  tráº¡ng thÃ¡i `PENDING`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### SRC-237-15: PhÃ¢n quyá»n truy cáº­p theo cÆ¡ sá»Ÿ: CÃ¡ch ly khi cÃ³ businessId, há»Ÿ khi null
- **Má»¥c tiÃªu:** Kiá»ƒm thá»­ yÃªu cáº§u phÃ¢n quyá»n theo cÆ¡ sá»Ÿ/branch, khÃ´ng cho truy cáº­p dá»¯ liá»‡u ngoÃ i pháº¡m vi Ä‘Æ°á»£c cáº¥p quyá»n.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Gá»i `getOrders(null)` vÃ  `getDesigns(null)`.
- **Káº¿t quáº£ mong Ä‘á»£i:** Báº¯t buá»™c pháº£i cÃ³ `businessId` há»£p lá»‡ tá»« token xÃ¡c thá»±c; khÃ´ng Ä‘Æ°á»£c tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u cá»§a má»i tenant khi thiáº¿u tham sá»‘.
- **Káº¿t quáº£ thá»±c táº¿:** FAIL (Code táº¡i `NfcOrderRepository.java` dÃ²ng 41 vÃ  `PrintDesignRepository.java` dÃ²ng 41 tráº£ vá» toÃ n bá»™ danh sÃ¡ch báº£n ghi náº¿u `businessId == null`). Ghi nháº­n `BUG-SCRUM237-02`.

### SRC-237-16: PhÃ¢n quyá»n truy cáº­p theo ID: Thiáº¿u kiá»ƒm tra quyá»n sá»Ÿ há»¯u (IDOR)
- **Má»¥c tiÃªu:** Kiá»ƒm tra phÃ¢n quyá»n khi ngÆ°á»i dÃ¹ng gá»i API chi tiáº¿t theo ID (`/api/v1/nfc-orders/{id}`, `/api/v1/print-designs/{id}/export`).
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** NgÆ°á»i dÃ¹ng thuá»™c tenant B truy váº¥n báº£n ghi thuá»™c tenant A qua ID.
- **Káº¿t quáº£ mong Ä‘á»£i:** Há»‡ thá»‘ng pháº£i kiá»ƒm tra quyá»n sá»Ÿ há»¯u cÆ¡ sá»Ÿ vÃ  tá»« chá»‘i truy cáº­p (HTTP 403 Forbidden).
- **Káº¿t quáº£ thá»±c táº¿:** FAIL (Code controller hiá»‡n táº¡i truy váº¥n tháº³ng tá»« repository báº±ng ID mÃ  khÃ´ng Ä‘á»‘i chiáº¿u vá»›i tenant ID cá»§a ngÆ°á»i gá»i). Ghi nháº­n `OBS-SCRUM237-02`.
