# BÃO CÃO Lá»–I VÃ€ QUAN SÃT (BUG REPORTS & OBSERVATIONS)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-237
**TiÃªu Ä‘á»:** [E5.3] Kiá»ƒm thá»­ mÃ£ nguá»“n xuáº¥t file in vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC
**Story cha:** SCRUM-136 ([E5.3] Xuáº¥t file in áº¥n cháº¥t lÆ°á»£ng cao & Ä‘áº·t hÃ ng phÃ´i tháº» NFC váº­t lÃ½)
**Task code Ä‘á»‘i á»©ng:** SCRUM-214
**Repository:** `Krydecres/CX-SHIELD`
**NgÃ y láº­p:** 17/11/2026

---

## 1. DANH SÃCH Lá»–I XÃC NHáº¬N (CONFIRMED BUGS)

### BUG-SCRUM237-01: Sai lá»‡ch bá»™ lá»c DCTDecode khi nhÃºng Ä‘á»‹nh dáº¡ng áº£nh PNG vÃ o stream PDF
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** Medium
- **MÃ´-Ä‘un:** `PrintExportService.java` (L222)
- **MÃ´ táº£ chi tiáº¿t:**
  - Theo tiÃªu chuáº©n PDF ISO 32000-1, bá»™ lá»c `/Filter /DCTDecode` lÃ  giáº£i thuáº­t giáº£i nÃ©n dá»¯ liá»‡u áº£nh JPEG (DCT/JFIF format).
  - Tuy nhiÃªn, trong phÆ°Æ¡ng thá»©c `exportToPdfBytes()`, há»‡ thá»‘ng gá»i `exportToPngBytes()` táº¡o máº£ng byte PNG (`â€°PNG` signature) rá»“i ghi trá»±c tiáº¿p máº£ng byte nÃ y vÃ o stream XObject cá»§a PDF nhÆ°ng láº¡i khai bÃ¡o `/Filter /DCTDecode`.
  - Káº¿t quáº£: Khi má»Ÿ tá»‡p PDF trÃªn cÃ¡c trÃ¬nh Ä‘á»c chuáº©n má»±c nghiÃªm ngáº·t (nhÆ° Adobe Acrobat Reader hoáº·c cÃ¡c thÆ° viá»‡n PDF parser cháº·t cháº½), trÃ¬nh Ä‘á»c sáº½ cá»‘ gáº¯ng dÃ¹ng bá»™ giáº£i mÃ£ JPEG DCTDecode Ä‘á»ƒ giáº£i mÃ£ luá»“ng byte PNG, dáº«n Ä‘áº¿n lá»—i "An error exists on this page. Acrobat may not display the page correctly" hoáº·c khÃ´ng hiá»ƒn thá»‹ Ä‘Æ°á»£c hÃ¬nh áº£nh.
- **CÃ¡c bÆ°á»›c tÃ¡i hiá»‡n:**
  1. Gá»i API `GET /api/v1/print-designs/{id}/export?format=pdf`.
  2. PhÃ¢n tÃ­ch ná»™i dung stream Ä‘á»‘i tÆ°á»£ng sá»‘ 4: `4 0 obj ... /Filter /DCTDecode ... stream\n\x89PNG...`.
- **Káº¿t quáº£ thá»±c táº¿:** Header khai bÃ¡o `/DCTDecode` nhÆ°ng ná»™i dung stream lÃ  PNG bytes.
- **Káº¿t quáº£ mong Ä‘á»£i:** Náº¿u nhÃºng Ä‘á»‹nh dáº¡ng PNG, pháº£i sá»­ dá»¥ng `/Filter /FlateDecode` (sau khi trÃ­ch xuáº¥t dá»¯ liá»‡u pixel IDAT) hoáº·c chuyá»ƒn Ä‘á»•i áº£nh sang JPEG khi dÃ¹ng `/DCTDecode`.

---

### BUG-SCRUM237-02: Lá»— há»•ng cÃ¡ch ly dá»¯ liá»‡u Ä‘a ngÆ°á»i dÃ¹ng khi query param businessId lÃ  null
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** High
- **MÃ´-Ä‘un:** `NfcOrderRepository.java` (L41), `PrintDesignRepository.java` (L41), `NfcOrderController.java` (L44), `PrintDesignController.java` (L44)
- **MÃ´ táº£ chi tiáº¿t:**
  - Theo yÃªu cáº§u phÃ¢n quyá»n há»‡ thá»‘ng (Tenant Isolation), má»—i cÆ¡ sá»Ÿ/doanh nghiá»‡p chá»‰ Ä‘Æ°á»£c phÃ©p xem cÃ¡c thiáº¿t káº¿ vÃ  Ä‘Æ¡n Ä‘áº·t tháº» NFC thuá»™c vá» cÆ¡ sá»Ÿ cá»§a mÃ¬nh.
  - Tuy nhiÃªn, táº¡i `NfcOrderRepository.java`:
    ```java
    public List<NfcOrder> findByBusinessId(UUID businessId) {
        if (businessId == null) {
            return new ArrayList<>(store.values());
        }
        ...
    }
    ```
  - Khi má»™t ngÆ°á»i dÃ¹ng gá»­i request `GET /api/v1/nfc-orders` hoáº·c `GET /api/v1/print-designs` mÃ  khÃ´ng kÃ¨m theo tham sá»‘ `businessId`, há»‡ thá»‘ng sáº½ tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u Ä‘Æ¡n hÃ ng vÃ  máº«u thiáº¿t káº¿ cá»§a táº¥t cáº£ doanh nghiá»‡p khÃ¡c trong há»‡ thá»‘ng.
  - ÄÃ¢y lÃ  lá»— há»•ng nghiÃªm trá»ng lÃ m rÃ² rá»‰ thÃ´ng tin khÃ¡ch hÃ ng, sá»‘ Ä‘iá»‡n thoáº¡i, Ä‘á»‹a chá»‰ nháº­n hÃ ng vÃ  thÃ´ng sá»‘ kinh doanh cá»§a cÃ¡c cÆ¡ sá»Ÿ khÃ¡c.
- **CÃ¡c bÆ°á»›c tÃ¡i hiá»‡n:**
  1. Táº¡o 2 Ä‘Æ¡n hÃ ng thuá»™c 2 cÆ¡ sá»Ÿ khÃ¡c nhau: cÆ¡ sá»Ÿ A (`a0eebc99...`) vÃ  cÆ¡ sá»Ÿ B (`b0eebc99...`).
  2. Gá»­i request `GET /api/v1/nfc-orders` (khÃ´ng truyá»n param `businessId`).
  3. Quan sÃ¡t káº¿t quáº£ tráº£ vá»: danh sÃ¡ch chá»©a cáº£ Ä‘Æ¡n hÃ ng cá»§a cÆ¡ sá»Ÿ A vÃ  cÆ¡ sá»Ÿ B.
- **Káº¿t quáº£ thá»±c táº¿:** Tráº£ vá» toÃ n bá»™ dá»¯ liá»‡u Ä‘a tenant.
- **Káº¿t quáº£ mong Ä‘á»£i:** Báº¯t buá»™c pháº£i cÃ³ `businessId` (trÃ­ch xuáº¥t tá»« JWT token Ä‘Ã£ xÃ¡c thá»±c) vÃ  tá»« chá»‘i truy cáº­p hoáº·c tráº£ vá» danh sÃ¡ch rá»—ng náº¿u khÃ´ng cÃ³ Ä‘á»‹nh danh cÆ¡ sá»Ÿ há»£p lá»‡.

---

## 2. DANH SÃCH QUAN SÃT & Äá»€ XUáº¤T (OBSERVATIONS & IMPROVEMENTS)

### OBS-SCRUM237-01: áº¢nh PNG Ä‘áº¡t kÃ­ch thÆ°á»›c pixel 300 DPI nhÆ°ng thiáº¿u chunk pHYs nhÃºng metadata
- **Má»©c Ä‘á»™:** Low (Observation)
- **MÃ´-Ä‘un:** `PrintExportService.java`
- **MÃ´ táº£:**
  - PhÆ°Æ¡ng thá»©c `exportToPngBytes` xuáº¥t ra áº£nh cÃ³ sá»‘ pixel 1240 x 1754 (A6) vÃ  1754 x 2480 (A5), hoÃ n toÃ n Ä‘á»§ sá»‘ Ä‘iá»ƒm áº£nh cho báº£n in 300 DPI.
  - Tuy nhiÃªn, hÃ m `ImageIO.write(img, "png", baos)` khÃ´ng tá»± Ä‘á»™ng ghi chunk `pHYs` (Physical pixel dimensions: sá»‘ pixel trÃªn má»—i mÃ©t). Khi ngÆ°á»i dÃ¹ng má»Ÿ file báº±ng cÃ¡c pháº§n má»m in áº¥n xem á»Ÿ cháº¿ Ä‘á»™ máº·c Ä‘á»‹nh, pháº§n má»m cÃ³ thá»ƒ nháº­n diá»‡n lÃ  72 DPI hoáº·c 96 DPI do thiáº¿u thÃ´ng sá»‘ váº­t lÃ½ nÃ y trong header file PNG.
- **Äá» xuáº¥t:** Sá»­ dá»¥ng `ImageWriter` cáº¥u hÃ¬nh `IIOMetadata` Ä‘á»ƒ ghi rÃµ chunk `pHYs` (tÆ°Æ¡ng Ä‘Æ°Æ¡ng 11811 pixels/meter cho 300 DPI).

---

### OBS-SCRUM237-02: Nguy cÆ¡ báº£o máº­t IDOR táº¡i cÃ¡c API truy váº¥n/xÃ³a theo ID
- **Má»©c Ä‘á»™:** Medium (Security Observation)
- **MÃ´-Ä‘un:** `NfcOrderController.java` (`getOrderById`), `PrintDesignController.java` (`getDesignById`, `deleteDesign`, `exportPrintDesign`)
- **MÃ´ táº£:**
  - CÃ¡c API theo ID chá»‰ nháº­n `UUID id` tá»« URL path vÃ  truy xuáº¥t trá»±c tiáº¿p tá»« repository mÃ  khÃ´ng kiá»ƒm tra xem ngÆ°á»i gá»i (caller) cÃ³ thuá»™c vá» `business_id` sá»Ÿ há»¯u báº£n ghi Ä‘Ã³ hay khÃ´ng.
  - Báº¥t ká»³ ngÆ°á»i dÃ¹ng nÃ o cÃ³ Ä‘Æ°á»£c UUID cá»§a Ä‘Æ¡n hÃ ng hoáº·c thiáº¿t káº¿ cá»§a cÆ¡ sá»Ÿ khÃ¡c Ä‘á»u cÃ³ thá»ƒ Ä‘á»c thÃ´ng tin chi tiáº¿t, táº£i file in hoáº·c thá»±c hiá»‡n xÃ³a thiáº¿t káº¿ cá»§a cÆ¡ sá»Ÿ Ä‘Ã³.
- **Äá» xuáº¥t:** Bá»• sung middleware hoáº·c service layer kiá»ƒm tra quyá»n sá»Ÿ há»¯u: Ä‘á»‘i chiáº¿u `businessId` cá»§a báº£n ghi vá»›i `business_id` trong JWT token cá»§a ngÆ°á»i dÃ¹ng Ä‘ang Ä‘Äƒng nháº­p.
