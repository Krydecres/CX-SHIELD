# BÃO CÃO Lá»–I VÃ€ QUAN SÃT (BUG REPORTS & OBSERVATIONS)

**MÃ£ cÃ´ng viá»‡c:** SCRUM-236
**Chá»©c nÄƒng:** [E5.1] Studio Thiáº¿t Káº¿ áº¤n Pháº©m QR (D3-09)
**Repository:** `Krydecres/CX-SHIELD`
**NgÃ y bÃ¡o cÃ¡o:** 17/11/2026

---

## 1. DANH SÃCH Lá»–I XÃC NHáº¬N (CONFIRMED BUGS)

### BUG-SCRUM236-01: Thiáº¿u validation kiá»ƒm tra Ä‘á»‹nh dáº¡ng vÃ  dung lÆ°á»£ng file logo
- **Má»©c Ä‘á»™ nghiÃªm trá»ng:** Medium
- **MÃ´-Ä‘un:** Frontend (`D309QrStudioPage`) & Backend (`PrintDesignService`)
- **MÃ´ táº£ chi tiáº¿t:**
  - Theo tÃ i liá»‡u Ä‘áº·c táº£ nghiá»‡p vá»¥ SCRUM-134/SCRUM-213, logo táº£i lÃªn/Ä‘Ã­nh kÃ¨m vÃ o áº¥n pháº©m pháº£i cÃ³ Ä‘á»‹nh dáº¡ng há»£p lá»‡ (PNG, JPG, SVG) vÃ  dung lÆ°á»£ng tá»‘i Ä‘a khÃ´ng vÆ°á»£t quÃ¡ 2MB.
  - Tuy nhiÃªn, trÃªn giao diá»‡n D3-09 ngÆ°á»i dÃ¹ng cÃ³ thá»ƒ nháº­p báº¥t ká»³ Ä‘Æ°á»ng dáº«n URL nÃ o (ká»ƒ cáº£ tá»‡p .exe, file rá»—ng hoáº·c URL khÃ´ng há»— trá»£ hÃ¬nh áº£nh).
  - PhÃ­a backend API cháº¥p nháº­n lÆ°u báº¥t ká»³ chuá»—i `logo_url` nÃ o vÃ o báº£ng `print_designs` mÃ  khÃ´ng cÃ³ bÆ°á»›c kiá»ƒm tra pháº§n má»Ÿ rá»™ng hay xÃ¡c thá»±c mime type.
- **CÃ¡c bÆ°á»›c tÃ¡i hiá»‡n:**
  1. Má»Ÿ mÃ n hÃ¬nh D3-09 Studio Thiáº¿t Káº¿ áº¤n Pháº©m QR.
  2. Táº¡i Ã´ "ÄÆ°á»ng dáº«n logo thÆ°Æ¡ng hiá»‡u", nháº­p: `https://example.com/malware.exe`.
  3. Báº¥m "LÆ°u Thiáº¿t Káº¿".
  4. Há»‡ thá»‘ng ghi nháº­n lÆ°u thÃ nh cÃ´ng thay vÃ¬ thÃ´ng bÃ¡o lá»—i Ä‘á»‹nh dáº¡ng khÃ´ng há»£p lá»‡.
- **Káº¿t quáº£ thá»±c táº¿:** Cho phÃ©p lÆ°u dá»¯ liá»‡u logo khÃ´ng Ä‘Ãºng chuáº©n; Live Preview chá»‰ hiá»ƒn thá»‹ fallback icon lá»—i vá»¡ áº£nh mÃ  khÃ´ng ngÄƒn cháº·n lÆ°u.
- **Káº¿t quáº£ mong Ä‘á»£i:** Giao diá»‡n hiá»ƒn thá»‹ cáº£nh bÃ¡o lá»—i Ä‘á»‹nh dáº¡ng khÃ´ng há»£p lá»‡ vÃ  vÃ´ hiá»‡u hÃ³a nÃºt lÆ°u cho tá»›i khi ngÆ°á»i dÃ¹ng cung cáº¥p link áº£nh Ä‘Ãºng chuáº©n (PNG/JPG/SVG <= 2MB).

---

## 2. QUAN SÃT VÃ€ Äá»€ XUáº¤T NÃ‚NG CAO (OBSERVATIONS)

### OBS-SCRUM236-01: ChÆ°a há»— trá»£ File Picker chá»n áº£nh trá»±c tiáº¿p tá»« mÃ¡y tÃ­nh / Ä‘iá»‡n thoáº¡i
- **Má»©c Ä‘á»™:** Low (Observation / Improvement)
- **MÃ´-Ä‘un:** Frontend D3-09
- **MÃ´ táº£ chi tiáº¿t:**
  - Hiá»‡n táº¡i giao diá»‡n chá»‰ cÃ³ text field Ä‘á»ƒ dÃ¡n Ä‘Æ°á»ng link URL áº£nh (`https://...`). Háº§u háº¿t ngÆ°á»i dÃ¹ng cuá»‘i (chá»§ cá»­a hÃ ng, quáº£n lÃ½ chi nhÃ¡nh) thÆ°á»ng cÃ³ sáºµn file áº£nh logo trong mÃ¡y vÃ  cÃ³ nhu cáº§u upload file trá»±c tiáº¿p thay vÃ¬ pháº£i tá»± táº£i áº£nh lÃªn hosting trÆ°á»›c Ä‘á»ƒ láº¥y link.
  - Kiá»ƒm thá»­ quÃ©t mÃ£ QR báº±ng camera tháº­t phá»¥ thuá»™c vÃ o pháº§n cá»©ng váº­t lÃ½ bÃªn ngoÃ i; mÃ´i trÆ°á»ng automation trÃªn CI/Runner chá»‰ cÃ³ thá»ƒ mÃ´ phá»ng luá»“ng thÃ´ng qua kÃ­ch hoáº¡t URL in-app.
- **Äá» xuáº¥t:**
  - TÃ­ch há»£p thÃªm nÃºt "Táº£i áº£nh tá»« mÃ¡y" sá»­ dá»¥ng `image_picker` hoáº·c `file_picker` kÃ¨m tá»± Ä‘á»™ng nÃ©n áº£nh vÃ  kiá»ƒm tra dung lÆ°á»£ng <= 2MB trÆ°á»›c khi lÆ°u.
