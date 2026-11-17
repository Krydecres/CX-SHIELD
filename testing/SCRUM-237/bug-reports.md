# BÃO CÃO Lá»–I VÃ€ QUAN SÃT (BUG REPORTS & OBSERVATIONS)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-237
**TiÃªu Ä‘á»:** [E5.3] Kiá»ƒm thá»­ mÃ£ nguá»“n xuáº¥t file in vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC
**Story cha:** SCRUM-136 ([E5.3] Xuáº¥t file in áº¥n cháº¥t lÆ°á»£ng cao & Ä‘áº·t hÃ ng phÃ´i tháº» NFC váº­t lÃ½)
**Task code Ä‘á»‘i á»©ng:** SCRUM-214
**Repository:** `Krydecres/CX-SHIELD`
**NgÃ y láº­p & RÃ  soÃ¡t cuá»‘i:** 17/11/2026

---

## 1. DANH SÃCH Lá»–I XÃC NHáº¬N (CONFIRMED BUGS)

### BUG-SCRUM237-01: Sai lá»‡ch bá»™ lá»c DCTDecode khi nhÃºng Ä‘á»‹nh dáº¡ng áº£nh PNG vÃ o stream PDF
- **Tráº¡ng thÃ¡i:** CONFIRMED
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** Medium
- **MÃ´-Ä‘un:** `PrintExportService.java` (DÃ²ng 188, 222-225)
- **MÃ´ táº£ chi tiáº¿t:**
  - Theo tiÃªu chuáº©n PDF ISO 32000-1, bá»™ lá»c `/Filter /DCTDecode` lÃ  giáº£i thuáº­t giáº£i nÃ©n áº£nh JPEG (DCT/JFIF format, báº¯t Ä‘áº§u báº±ng byte `0xFF 0xD8`).
  - Trong phÆ°Æ¡ng thá»©c `exportToPdfBytes()`, code gá»i `exportToPngBytes()` táº¡o máº£ng byte PNG (báº¯t Ä‘áº§u báº±ng `\x89PNG\x0d\x0a\x1a\x0a`) rá»“i ghi trá»±c tiáº¿p máº£ng byte nÃ y vÃ o stream XObject cá»§a PDF nhÆ°ng láº¡i khai bÃ¡o `/Filter /DCTDecode`:
    ```java
    pdf.write(String.format("4 0 obj\n<< /Type /XObject /Subtype /Image /Width %d /Height %d /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /DCTDecode /Length %d >>\nstream\n",
            pxWidth, pxHeight, pngBytes.length).getBytes(StandardCharsets.ISO_8859_1));
    pdf.write(pngBytes);
    ```
  - **Báº±ng chá»©ng xÃ¡c minh báº±ng PDF parser thá»±c táº¿:**
    - Sá»­ dá»¥ng thÆ° viá»‡n chuáº©n cÃ´ng nghiá»‡p Apache PDFBox 3.0.4 Ä‘á»ƒ phÃ¢n tÃ­ch Ä‘á»‘i tÆ°á»£ng áº£nh `Im1` trong trang PDF:
    - Khi gá»i `xImage.getImage()`, bá»™ giáº£i mÃ£ `org.apache.pdfbox.filter.DCTFilter` tháº¥t báº¡i vÃ  nÃ©m lá»—i:
      `javax.imageio.IIOException: Not a JPEG file: starts with 0xf1 0x11`
    - TrÃ¬nh xem PDF nghiÃªm ngáº·t (Adobe Acrobat Reader, PDF.js) sáº½ bÃ¡o lá»—i file há»ng hoáº·c hiá»ƒn thá»‹ khung trá»‘ng/xÃ¡m.
- **Káº¿t quáº£ mong Ä‘á»£i:** Náº¿u nhÃºng Ä‘á»‹nh dáº¡ng PNG, pháº£i sá»­ dá»¥ng `/Filter /FlateDecode` (sau khi trÃ­ch xuáº¥t dá»¯ liá»‡u pixel IDAT) hoáº·c chuyá»ƒn Ä‘á»•i áº£nh sang JPEG khi dÃ¹ng `/DCTDecode`.

---

### BUG-SCRUM237-02: Lá»— há»•ng cÃ¡ch ly dá»¯ liá»‡u Ä‘a ngÆ°á»i dÃ¹ng khi query param businessId lÃ  null
- **Tráº¡ng thÃ¡i:** CONFIRMED
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** High
- **MÃ´-Ä‘un:** `NfcOrderRepository.java` (DÃ²ng 41), `PrintDesignRepository.java` (DÃ²ng 41), `NfcOrderController.java` (DÃ²ng 44), `PrintDesignController.java` (DÃ²ng 44)
- **MÃ´ táº£ chi tiáº¿t:**
  - Theo nguyÃªn táº¯c phÃ¢n quyá»n há»‡ thá»‘ng Ä‘a ngÆ°á»i dÃ¹ng (Multi-tenant Isolation), má»—i doanh nghiá»‡p/cÆ¡ sá»Ÿ chá»‰ Ä‘Æ°á»£c phÃ©p truy xuáº¥t dá»¯ liá»‡u thuá»™c cÆ¡ sá»Ÿ cá»§a mÃ¬nh.
  - Tuy nhiÃªn, táº¡i `NfcOrderRepository.java` (L41) vÃ  `PrintDesignRepository.java` (L41):
    ```java
    public List<NfcOrder> findByBusinessId(UUID businessId) {
        if (businessId == null) {
            return new ArrayList<>(store.values());
        }
        ...
    }
    ```
  - Hai endpoint `GET /api/v1/nfc-orders` vÃ  `GET /api/v1/print-designs` khai bÃ¡o tham sá»‘ `@RequestParam(required = false) UUID businessId`.
  - KhÃ´ng cÃ³ táº§ng middleware, service hay controller nÃ o trÃ­ch xuáº¥t `business_id` tá»« JWT Claims cá»§a ngÆ°á»i dÃ¹ng Ä‘Ã£ xÃ¡c thá»±c Ä‘á»ƒ Ã©p buá»™c lá»c dá»¯ liá»‡u.
  - Khi client gá»­i request khÃ´ng cÃ³ query param `businessId` (hoáº·c `businessId` null), há»‡ thá»‘ng tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u Ä‘Æ¡n hÃ ng vÃ  máº«u thiáº¿t káº¿ cá»§a táº¥t cáº£ cÆ¡ sá»Ÿ kinh doanh trong há»‡ thá»‘ng.
- **Báº±ng chá»©ng xÃ¡c minh thá»±c táº¿:**
  - Kiá»ƒm thá»­ `SRC-237-15` (`testRepositoryAccessControlMultiTenantIsolation` trong `PrintNfcSourceTest.java`) chá»©ng minh khi gá»i `getOrders(null)`, káº¿t quáº£ tráº£ vá» Ä‘á»“ng thá»i Ä‘Æ¡n hÃ ng cá»§a cÆ¡ sá»Ÿ A (`a0eebc99...`) vÃ  cÆ¡ sá»Ÿ B (`b0eebc99...`), lÃ m lá»™ tÃªn, sá»‘ Ä‘iá»‡n thoáº¡i, Ä‘á»‹a chá»‰ nháº­n hÃ ng cá»§a khÃ¡ch hÃ ng tenant khÃ¡c.
- **Káº¿t quáº£ mong Ä‘á»£i:** Báº¯t buá»™c trÃ­ch xuáº¥t Ä‘á»‹nh danh `business_id` tá»« JWT token xÃ¡c thá»±c; cáº¥m tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u khi thiáº¿u tham sá»‘ cÆ¡ sá»Ÿ.

---

### BUG-SCRUM237-03: Lá»— há»•ng IDOR - Cho phÃ©p Ä‘á»c, xuáº¥t file vÃ  xÃ³a tÃ i nguyÃªn cá»§a cÆ¡ sá»Ÿ khÃ¡c qua ID
- **Tráº¡ng thÃ¡i:** CONFIRMED
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** High (Security Vulnerability)
- **MÃ´-Ä‘un:** `NfcOrderController.java` (DÃ²ng 53), `PrintDesignController.java` (DÃ²ng 55, 111, 123)
- **MÃ´ táº£ chi tiáº¿t:**
  - CÃ¡c endpoint chi tiáº¿t theo ID:
    - `GET /api/v1/nfc-orders/{id}`
    - `GET /api/v1/print-designs/{id}`
    - `GET /api/v1/print-designs/{id}/export`
    - `DELETE /api/v1/print-designs/{id}`
  - Cáº£ 4 endpoint trÃªn chá»‰ nháº­n `UUID id` tá»« URL path vÃ  truy xuáº¥t/xÃ³a trá»±c tiáº¿p tá»« repository mÃ  hoÃ n toÃ n KHÃ”NG cÃ³ bÆ°á»›c kiá»ƒm tra ngÆ°á»i gá»i (caller) cÃ³ quyá»n sá»Ÿ há»¯u `business_id` cá»§a báº£n ghi Ä‘Ã³ hay khÃ´ng.
  - Báº¥t ká»³ ngÆ°á»i dÃ¹ng Ä‘Ã£ Ä‘Äƒng nháº­p nÃ o (ká»ƒ cáº£ thuá»™c cÆ¡ sá»Ÿ khÃ¡c) náº¿u biáº¿t hoáº·c Ä‘oÃ¡n Ä‘Æ°á»£c UUID cá»§a Ä‘Æ¡n hÃ ng/thiáº¿t káº¿ Ä‘á»u cÃ³ thá»ƒ:
    1. Äá»c toÃ n bá»™ thÃ´ng tin nháº¡y cáº£m cá»§a Ä‘Æ¡n hÃ ng (`shipName`, `shipPhone`, `shipAddress`).
    2. Xuáº¥t vÃ  táº£i file in áº¥n cá»§a Ä‘á»‘i thá»§.
    3. XÃ³a vÄ©nh viá»…n máº«u thiáº¿t káº¿ cá»§a doanh nghiá»‡p khÃ¡c khá»i há»‡ thá»‘ng (`deleteDesign`).
- **Báº±ng chá»©ng xÃ¡c minh báº±ng automated test:**
  - Kiá»ƒm thá»­ `SRC-237-16` (`testAccessControlMissingOwnershipCheckOnGetAndExport` trong `PrintNfcSourceTest.java`):
    - Äá»c chi tiáº¿t Ä‘Æ¡n hÃ ng cá»§a Tenant A thÃ nh cÃ´ng tá»« client khÃ´ng cÃ³ quyá»n sá»Ÿ há»¯u.
    - Xuáº¥t file in cá»§a Tenant A thÃ nh cÃ´ng (HTTP 200 OK).
    - Gá»i `printDesignController.deleteDesign(designIdA)` xÃ³a thÃ nh cÃ´ng thiáº¿t káº¿ cá»§a Tenant A (`findId(designIdA).isPresent() == false`).
- **Káº¿t quáº£ mong Ä‘á»£i:** Kiá»ƒm tra quyá»n sá»Ÿ há»¯u Ä‘á»‘i chiáº¿u giá»¯a `businessId` cá»§a báº£n ghi vá»›i `business_id` trong JWT Claims cá»§a caller trÆ°á»›c khi cho phÃ©p xem, táº£i hoáº·c xÃ³a.

---

## 2. DANH SÃCH QUAN SÃT & Äá»€ XUáº¤T (OBSERVATIONS)

### OBS-SCRUM237-01: Tá»‡p PNG Ä‘áº¡t kÃ­ch thÆ°á»›c pixel 300 DPI nhÆ°ng thiáº¿u chunk pHYs nhÃºng metadata
- **Tráº¡ng thÃ¡i:** CONFIRMED (Observation)
- **Má»©c Ä‘á»™:** Low
- **MÃ´-Ä‘un:** `PrintExportService.java` (DÃ²ng 177-182)
- **MÃ´ táº£:**
  - `exportToPngBytes` xuáº¥t ra áº£nh cÃ³ sá»‘ pixel 1240 x 1754 (A6) vÃ  1754 x 2480 (A5), hoÃ n toÃ n Ä‘á»§ sá»‘ Ä‘iá»ƒm áº£nh cho báº£n in 300 DPI.
  - Tuy nhiÃªn, `ImageIO.write(img, "png", baos)` máº·c Ä‘á»‹nh khÃ´ng tá»± ghi chunk `pHYs` (Physical pixel dimensions: sá»‘ pixel trÃªn má»—i mÃ©t) vÃ o header file PNG. Khi ngÆ°á»i dÃ¹ng má»Ÿ file báº±ng cÃ¡c pháº§n má»m in áº¥n xem á»Ÿ cháº¿ Ä‘á»™ máº·c Ä‘á»‹nh, pháº§n má»m cÃ³ thá»ƒ nháº­n diá»‡n lÃ  72 DPI hoáº·c 96 DPI do thiáº¿u thÃ´ng sá»‘ váº­t lÃ½ nÃ y.
- **Äá» xuáº¥t:** Cáº¥u hÃ¬nh `ImageWriter` vá»›i `IIOMetadata` Ä‘á»ƒ ghi chunk `pHYs` (11811 pixels/meter tÆ°Æ¡ng á»©ng 300 DPI).
