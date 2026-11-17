# DANH SÃCH TEST CASES KIá»‚M THá»¬ Tá»° Äá»˜NG (AUTOMATION TEST CASES)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-236
**Chá»©c nÄƒng:** [E5.1] Studio Thiáº¿t Káº¿ áº¤n Pháº©m QR (MÃ n hÃ¬nh D3-09 - `/print-materials`)
**Táº­p tin ká»‹ch báº£n tá»± Ä‘á»™ng:** `frontend/test/d3_09_qr_studio_automation_test.dart`
**NgÃ y thá»±c thi:** 17/11/2026
**MÃ´i trÆ°á»ng:** Flutter 3.x / Dart SDK (Widget Tester & Mock HTTP Client)

---

## Báº¢NG Tá»”NG Há»¢P Káº¾T QUáº¢ AUTOMATION TEST CASES

| MÃ£ TC | TÃªn ca kiá»ƒm thá»­ | Loáº¡i kiá»ƒm thá»­ | Tráº¡ng thÃ¡i |
|---|---|---|---|
| AUTO-236-01 | Khá»Ÿi Ä‘á»™ng Studio D3-09, táº£i chi nhÃ¡nh vÃ  mÃ£ QR máº·c Ä‘á»‹nh | UI & State Flow | PASS |
| AUTO-236-02 | Táº¡o mÃ£ QR má»›i cho chi nhÃ¡nh qua Dialog vÃ  cáº­p nháº­t Studio | End-to-End Dialog | PASS |
| AUTO-236-03 | Chá»n khung máº«u Standee Äá»ƒ BÃ n (TABLE_TENT) kiá»ƒm tra khá»• in A6 | Live Preview Layout | PASS |
| AUTO-236-04 | Chá»n khung máº«u Sticker DÃ¡n Quáº§y (WINDOW_STICKER) kiá»ƒm tra Decal trÃ²n | Live Preview Layout | PASS |
| AUTO-236-05 | Chá»n khung máº«u Tháº» Cháº¡m NFC (CARD_NFC) kiá»ƒm tra bá»‘ cá»¥c NFC | Live Preview Layout | PASS |
| AUTO-236-06 | ThÃªm Ä‘Æ°á»ng dáº«n logo há»£p lá»‡ cáº­p nháº­t áº£nh banner Live Preview | Component Binding | PASS |
| AUTO-236-07 | Chá»‰nh sá»­a CTA vÃ  chá»n gá»£i Ã½ chip CTA nhanh cáº­p nháº­t Live Preview | Reactive Form Input | PASS |
| AUTO-236-08 | TÃ¹y biáº¿n mÃ u nháº­n diá»‡n thÆ°Æ¡ng hiá»‡u real-time trÃªn Live Preview | Realtime Customization | PASS |
| AUTO-236-09 | LÆ°u thiáº¿t káº¿ vÃ o print_designs vÃ  náº¡p láº¡i phá»¥c há»“i Ä‘áº§y Ä‘á»§ dá»¯ liá»‡u | Data Persistence & Restore | PASS |
| AUTO-236-10 | Kiá»ƒm tra URL trong mÃ£ QR trá» chÃ­nh xÃ¡c mÃ n kháº£o sÃ¡t M1-01 chi nhÃ¡nh | Navigation & QR URL Target | PASS |

---

## CHI TIáº¾T CÃC CA KIá»‚M THá»¬ Tá»° Äá»˜NG

### AUTO-236-01: Khá»Ÿi Ä‘á»™ng Studio D3-09, táº£i chi nhÃ¡nh vÃ  mÃ£ QR máº·c Ä‘á»‹nh
- **Má»¥c tiÃªu:** XÃ¡c nháº­n giao diá»‡n D3-09 khá»Ÿi táº¡o thÃ nh cÃ´ng, tá»± Ä‘á»™ng gá»i API láº¥y danh sÃ¡ch QR vÃ  hiá»ƒn thá»‹ thÃ´ng tin Live Preview máº·c Ä‘á»‹nh.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Mock API `/api/v1/qr-codes` tráº£ vá» danh sÃ¡ch mÃ£ QR gá»“m `MC-B04`, `MC-Q1-T1`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Render widget `D309QrStudioPage` vá»›i mock client.
  2. KÃ­ch hoáº¡t `tester.pumpAndSettle()`.
  3. Kiá»ƒm tra tiÃªu Ä‘á» trang vÃ  danh sÃ¡ch dropdown mÃ£ QR.
- **Káº¿t quáº£ mong Ä‘á»£i:** Trang hiá»ƒn thá»‹ tiÃªu Ä‘á» `Studio Thiáº¿t Káº¿ áº¤n Pháº©m QR (D3-09)`, mÃ£ QR máº·c Ä‘á»‹nh `MC-B04` Ä‘Æ°á»£c chá»n, hiá»ƒn thá»‹ báº£n xem trÆ°á»›c.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-02: Táº¡o mÃ£ QR má»›i cho chi nhÃ¡nh qua Dialog vÃ  cáº­p nháº­t Studio
- **Má»¥c tiÃªu:** XÃ¡c nháº­n luá»“ng má»Ÿ dialog, nháº­p thÃ´ng tin táº¡o mÃ£ QR vá»‹ trÃ­ bÃ n má»›i vÃ  tá»± Ä‘á»™ng cáº­p nháº­t vÃ o danh sÃ¡ch Studio.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** TÃªn vá»‹ trÃ­: `BÃ n 15 - Khu ngoÃ i trá»i`, MÃ£ tÃ¹y chá»‰nh: `MC-BAN15`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº¥n nÃºt "Táº¡o mÃ£ QR".
  2. Äiá»n thÃ´ng tin vá»‹ trÃ­ vÃ  mÃ£ tÃ¹y chá»‰nh vÃ o Dialog.
  3. Nháº¥n "LÆ°u mÃ£ QR".
  4. XÃ¡c nháº­n Dialog Ä‘Ã³ng vÃ  danh sÃ¡ch mÃ£ vá»‹ trÃ­ cáº­p nháº­t.
- **Káº¿t quáº£ mong Ä‘á»£i:** Dialog Ä‘Ã³ng, xuáº¥t hiá»‡n thÃ´ng bÃ¡o `ÄÃ£ táº¡o mÃ£ QR thÃ nh cÃ´ng`, dropdown hiá»ƒn thá»‹ `MC-BAN15`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-03: Chá»n khung máº«u Standee Äá»ƒ BÃ n (TABLE_TENT) kiá»ƒm tra khá»• in A6
- **Má»¥c tiÃªu:** XÃ¡c nháº­n lá»±a chá»n khung máº«u Standee hiá»ƒn thá»‹ Ä‘Ãºng thÃ´ng sá»‘ kÃ­ch thÆ°á»›c A6 vÃ  chÃ¢n Ä‘áº¿ standee.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Khung máº«u `TABLE_TENT` ("Standee Äá»ƒ BÃ n").
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº¥n chá»n FilterChip `Standee Äá»ƒ BÃ n`.
  2. Chá» re-render Live Preview.
  3. Kiá»ƒm tra cÃ¡c pháº§n tá»­ Ä‘á»“ há»a Ä‘áº·c trÆ°ng.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview hiá»ƒn thá»‹ `Khá»• chuáº©n A6 (105 x 148 mm)`, hiá»ƒn thá»‹ chÃ¢n Ä‘áº¿ standee vÃ  huy hiá»‡u quÃ©t Ä‘Ã¡nh giÃ¡.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-04: Chá»n khung máº«u Sticker DÃ¡n Quáº§y (WINDOW_STICKER) kiá»ƒm tra Decal trÃ²n
- **Má»¥c tiÃªu:** XÃ¡c nháº­n lá»±a chá»n khung Sticker hiá»ƒn thá»‹ decal bo trÃ²n 270px kÃ¨m viá»n thÆ°Æ¡ng hiá»‡u.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Khung máº«u `WINDOW_STICKER` ("Sticker DÃ¡n Quáº§y").
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº¥n chá»n FilterChip `Sticker DÃ¡n Quáº§y`.
  2. Chá» re-render Live Preview.
  3. Kiá»ƒm tra cÃ¡c pháº§n tá»­ hÃ¬nh há»c vÃ  vÄƒn báº£n hÆ°á»›ng dáº«n.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview hiá»ƒn thá»‹ Decal bo trÃ²n Ä‘Æ°á»ng kÃ­nh 270px vÃ  dÃ²ng CTA `DÃN Táº I Cá»¬A KÃNH / BÃ€N THU NGÃ‚N`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-05: Chá»n khung máº«u Tháº» Cháº¡m NFC (CARD_NFC) kiá»ƒm tra bá»‘ cá»¥c NFC
- **Má»¥c tiÃªu:** XÃ¡c nháº­n khung máº«u tháº» tÃ­ch há»£p chip NFC hiá»ƒn thá»‹ Ä‘Ãºng kÃ­ch cá»¡ tháº» ATM/ID-1 vÃ  icon contactless.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Khung máº«u `CARD_NFC` ("Tháº» Cháº¡m NFC").
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº¥n chá»n FilterChip `Tháº» Cháº¡m NFC`.
  2. Chá» re-render Live Preview.
  3. Kiá»ƒm tra icon NFC contactless vÃ  thÃ´ng sá»‘ ID-1.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview hiá»ƒn thá»‹ khung tháº» náº±m ngang `Khá»• tháº» ATM / ID-1 (85.6 x 54 mm)` vÃ  icon `contactless_rounded`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-06: ThÃªm Ä‘Æ°á»ng dáº«n logo há»£p lá»‡ cáº­p nháº­t áº£nh banner Live Preview
- **Má»¥c tiÃªu:** XÃ¡c nháº­n nháº­p URL logo há»£p lá»‡ sáº½ hiá»ƒn thá»‹ banner áº£nh logo trÃªn báº£n xem trÆ°á»›c trá»±c tiáº¿p.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** `https://example.com/logo.png`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº­p URL logo vÃ o trÆ°á»ng text field `ÄÆ°á»ng dáº«n logo`.
  2. Chá» kÃ­ch hoáº¡t debounce / render Live Preview.
  3. TÃ¬m kiáº¿m widget hÃ¬nh áº£nh `ClipRRect`.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview hiá»ƒn thá»‹ hÃ¬nh áº£nh logo vá»›i kÃ­ch thÆ°á»›c 32x32px bo gÃ³c 6px.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-07: Chá»‰nh sá»­a CTA vÃ  chá»n gá»£i Ã½ chip CTA nhanh cáº­p nháº­t Live Preview
- **Má»¥c tiÃªu:** XÃ¡c nháº­n ngÆ°á»i dÃ¹ng cÃ³ thá»ƒ gÃµ CTA tÃ¹y biáº¿n hoáº·c báº¥m chip gá»£i Ã½ nhanh Ä‘á»ƒ Ä‘á»•i thÃ´ng Ä‘iá»‡p má»i quÃ©t.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Tá»± gÃµ `ÄÃ¡nh giÃ¡ ngay nháº­n trÃ  sá»¯a miá»…n phÃ­!` vÃ  báº¥m chip gá»£i Ã½ `GÃ³p Ã½ nháº­n quÃ  50K`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº­p vÄƒn báº£n vÃ o Ã´ `ThÃ´ng Ä‘iá»‡p kÃªu gá»i hÃ nh Ä‘á»™ng (CTA)`.
  2. Kiá»ƒm tra Live Preview hiá»ƒn thá»‹ Ä‘Ãºng thÃ´ng Ä‘iá»‡p.
  3. Báº¥m chá»n ActionChip `GÃ³p Ã½ nháº­n quÃ  50K`.
  4. Kiá»ƒm tra Live Preview cáº­p nháº­t thÃ´ng Ä‘iá»‡p má»›i tá»« chip.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview pháº£n há»“i tá»©c thÃ¬ vá»›i cáº£ hai thao tÃ¡c thay Ä‘á»•i CTA.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-08: TÃ¹y biáº¿n mÃ u nháº­n diá»‡n thÆ°Æ¡ng hiá»‡u real-time trÃªn Live Preview
- **Má»¥c tiÃªu:** XÃ¡c nháº­n Ä‘á»•i mÃ u thÆ°Æ¡ng hiá»‡u (MÃ u Cam `0xFFEA580C`) Ã¡p dá»¥ng tá»©c thá»i lÃªn viá»n khung vÃ  QR code.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** Chá»n mÃ£ mÃ u `0xFFEA580C`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Chá»n mÃ u Cam trong báº£ng mÃ u thÆ°Æ¡ng hiá»‡u.
  2. Kiá»ƒm tra thuá»™c tÃ­nh mÃ u sáº¯c trong widget State.
- **Káº¿t quáº£ mong Ä‘á»£i:** Live Preview cáº­p nháº­t mÃ u chá»§ Ä‘áº¡o cá»§a QR code vÃ  header sang mÃ u cam Ä‘Ã£ chá»n.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-09: LÆ°u thiáº¿t káº¿ vÃ o print_designs vÃ  náº¡p láº¡i phá»¥c há»“i Ä‘áº§y Ä‘á»§ dá»¯ liá»‡u
- **Má»¥c tiÃªu:** XÃ¡c nháº­n lÆ°u máº«u thiáº¿t káº¿ má»›i qua API vÃ  náº¡p láº¡i tá»« danh sÃ¡ch máº«u Ä‘Ã£ lÆ°u phá»¥c há»“i Ä‘Ãºng dá»¯ liá»‡u.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** TÃªn máº«u: `Standee QuÃ¡n CÃ  PhÃª MÃ¹a HÃ¨ 2026`, MÃ£ QR: `MC-B04`, CTA: `QuÃ©t mÃ£ nháº­n trÃ  Ä‘Ã o free`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Nháº­p tÃªn máº«u vÃ  CTA tÃ¹y biáº¿n.
  2. Nháº¥n nÃºt "LÆ°u Thiáº¿t Káº¿".
  3. Báº¥m nÃºt "Náº¡p" táº¡i má»¥c thiáº¿t káº¿ Ä‘Ã£ lÆ°u.
  4. Kiá»ƒm tra dá»¯ liá»‡u trÃªn form vÃ  preview.
- **Káº¿t quáº£ mong Ä‘á»£i:** API lÆ°u thÃ nh cÃ´ng tráº£ vá» 201 Created; khi nháº¥n náº¡p, form vÃ  preview phá»¥c há»“i nguyÃªn váº¹n cÃ¡c giÃ¡ trá»‹.
- **Káº¿t quáº£ thá»±c táº¿:** PASS.

### AUTO-236-10: Kiá»ƒm tra URL trong mÃ£ QR trá» chÃ­nh xÃ¡c mÃ n kháº£o sÃ¡t M1-01 chi nhÃ¡nh
- **Má»¥c tiÃªu:** XÃ¡c nháº­n URL nhÃºng vÃ o mÃ£ QR trá» chÃ­nh xÃ¡c Ä‘áº¿n mÃ n hÃ¬nh kháº£o sÃ¡t khÃ¡ch hÃ ng M1-01 vá»›i tham sá»‘ QR cá»§a chi nhÃ¡nh.
- **Dá»¯ liá»‡u Ä‘áº§u vÃ o:** MÃ£ QR Ä‘ang chá»n: `MC-B04`.
- **CÃ¡c bÆ°á»›c tá»± Ä‘á»™ng:**
  1. Kiá»ƒm tra sá»± tá»“n táº¡i cá»§a widget `QrImageView`.
  2. TÆ°Æ¡ng tÃ¡c nháº¥n vÃ o khá»‘i QR Code trÃªn Live Preview.
  3. Kiá»ƒm tra SnackBar Ä‘iá»u hÆ°á»›ng chá»©a `/survey?qr=MC-B04`.
  4. Nháº¥n nÃºt "Thá»­ nghiá»‡m quÃ©t QR: Má»Ÿ mÃ n kháº£o sÃ¡t M1-01 (MC-B04)".
  5. XÃ¡c nháº­n Ä‘iá»u hÆ°á»›ng chÃ­nh xÃ¡c mÃ n khÃ¡ch M1-01 vá»›i `targetUrl = https://cxshield.vn/survey?qr=MC-B04`.
- **Káº¿t quáº£ mong Ä‘á»£i:** Cáº£ hai thao tÃ¡c cháº¡m Ä‘á»u xÃ¡c nháº­n Ä‘Ã­ch Ä‘áº¿n lÃ  `/survey?qr=MC-B04`.
- **Káº¿t quáº£ thá»±c táº¿:** PASS. (LÆ°u Ã½: KhÃ´ng thá»±c hiá»‡n quÃ©t báº±ng camera Ä‘iá»‡n thoáº¡i váº­t lÃ½ do cháº¡y trong mÃ´i trÆ°á»ng CI/Server).
