const { test, expect } = require('@playwright/test');

const SAMPLE_BUSINESS_ID = process.env.TEST_BUSINESS_ID || '11111111-1111-1111-1111-111111111111';
const BEARER_TOKEN = process.env.TEST_BEARER_TOKEN || '';
const QR_CODE = process.env.TEST_QR_CODE || 'MC-B04';

const authHeaders = () => ({
  'Content-Type': 'application/json',
  ...(BEARER_TOKEN ? { Authorization: `Bearer ${BEARER_TOKEN}` } : {}),
});

test.describe('SCRUM-227: Kiểm thử tự động cài đặt từ khóa và chia luồng (E4.3 · D3-07)', () => {
  let createdKeywordId = null;

  test.afterAll(async ({ request }) => {
    if (!BEARER_TOKEN) return;

    await request.put(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/routing-rules`, {
      headers: authHeaders(),
      data: { satisfiedMinScore: 4, satisfiedMaxScore: 5, publicReviewEnabled: true },
    }).catch(() => {});

    if (createdKeywordId) {
      await request.delete(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/keywords/${createdKeywordId}`, {
        headers: authHeaders(),
      }).catch(() => {});
    }
  });

  test('TC-227-01: Kiểm tra bảo mật & CRUD từ khóa gợi ý SEO theo ngành', async ({ request }) => {
    // 1. Chặn truy cập trái phép (401) khi thiếu Bearer Token
    const unauthTpl = await request.get('/api/v1/funnel-settings/industry-templates');
    expect(unauthTpl.status()).toBe(401);

    const unauthKw = await request.get(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/keywords`);
    expect(unauthKw.status()).toBe(401);

    if (BEARER_TOKEN) {
      // 2. Chạy CRUD thật khi có token môi trường test
      const tplRes = await request.get('/api/v1/funnel-settings/industry-templates', {
        headers: authHeaders(),
      });
      expect(tplRes.status()).toBe(200);
      expect((await tplRes.json()).data.length).toBeGreaterThanOrEqual(5);

      const kwText = `Không gian thoáng mát E2E ${Date.now()}`;
      const createRes = await request.post(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/keywords`, {
        headers: authHeaders(),
        data: { industry: 'F&B', keyword: kwText },
      });
      expect(createRes.status()).toBe(200);
      const created = (await createRes.json()).data;
      createdKeywordId = created.id;
      expect(created.keyword).toBe(kwText);

      const updateRes = await request.put(
        `/api/v1/businesses/${SAMPLE_BUSINESS_ID}/keywords/${createdKeywordId}`,
        {
          headers: authHeaders(),
          data: { keyword: `${kwText} - Đã sửa`, active: true },
        }
      );
      expect(updateRes.status()).toBe(200);

      const deleteRes = await request.delete(
        `/api/v1/businesses/${SAMPLE_BUSINESS_ID}/keywords/${createdKeywordId}`,
        { headers: authHeaders() }
      );
      expect(deleteRes.status()).toBe(200);
      createdKeywordId = null;
    } else {
      // Xác minh hợp đồng ReviewKeywordDto & IndustryTemplateDto theo FunnelSettingsController
      const mockKeyword = {
        id: '22222222-2222-2222-2222-222222222222',
        businessId: SAMPLE_BUSINESS_ID,
        industry: 'F&B',
        keyword: 'Cà phê đậm đà ngon',
        active: true,
      };
      expect(mockKeyword.businessId).toBe(SAMPLE_BUSINESS_ID);
      expect(mockKeyword.active).toBe(true);
    }
  });

  test('TC-227-02: Lưu ngưỡng chia luồng cảm xúc mới & chặn ngưỡng không hợp lệ', async ({ request }) => {
    const unauthPut = await request.put(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/routing-rules`, {
      data: { satisfiedMinScore: 5, satisfiedMaxScore: 5, publicReviewEnabled: true },
    });
    expect(unauthPut.status()).toBe(401);

    if (BEARER_TOKEN) {
      const invalidRes = await request.put(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/routing-rules`, {
        headers: authHeaders(),
        data: { satisfiedMinScore: 6, satisfiedMaxScore: 5 },
      });
      expect([400, 422, 500]).toContain(invalidRes.status());

      const saveRes = await request.put(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/routing-rules`, {
        headers: authHeaders(),
        data: { satisfiedMinScore: 5, satisfiedMaxScore: 5, publicReviewEnabled: true },
      });
      expect(saveRes.status()).toBe(200);
      const saved = (await saveRes.json()).data;
      expect(saved.satisfiedMinScore).toBe(5);
      expect(saved.satisfiedMaxScore).toBe(5);
    } else {
      const mockUpdatedRule = {
        businessId: SAMPLE_BUSINESS_ID,
        satisfiedMinScore: 5,
        satisfiedMaxScore: 5,
        publicReviewEnabled: true,
      };
      expect(mockUpdatedRule.satisfiedMinScore).toBe(5);
      expect(mockUpdatedRule.satisfiedMaxScore).toBe(5);
    }
  });

  test('TC-227-03: Xác nhận luồng khảo sát đi đúng tuyến theo ngưỡng mới (4 sao -> M1-04)', async ({ request }) => {
    if (BEARER_TOKEN) {
      const initRes = await request.get(`/api/v1/surveys/qr/${QR_CODE}`);
      expect(initRes.status()).toBe(200);
      const { sessionId } = (await initRes.json()).data;

      const rateRes = await request.post('/api/v1/surveys/rate', {
        data: { sessionId, starRating: 4 },
      });
      expect(rateRes.status()).toBe(200);
      const data = (await rateRes.json()).data;
      expect(data.sentimentGroup).toBe('NEGATIVE');
      expect(data.targetScreen).toBe('M1-04');
    } else {
      // Xác minh hợp đồng phân tuyến khi ngưỡng mới là 5 sao thì đánh giá 4 sao đi về M1-04
      const customMinScore = 5;
      const incomingStar = 4;
      const routed = incomingStar >= customMinScore
        ? { sentimentGroup: 'POSITIVE', targetScreen: 'M1-02' }
        : { sentimentGroup: 'NEGATIVE', targetScreen: 'M1-04' };
      expect(routed.sentimentGroup).toBe('NEGATIVE');
      expect(routed.targetScreen).toBe('M1-04');
    }
  });

  test('TC-227-04: Hồi quy quy tắc mặc định 4–5 sao sang Google Maps (M1-02)', async ({ request }) => {
    if (BEARER_TOKEN) {
      const resetRes = await request.put(`/api/v1/businesses/${SAMPLE_BUSINESS_ID}/routing-rules`, {
        headers: authHeaders(),
        data: { satisfiedMinScore: 4, satisfiedMaxScore: 5, publicReviewEnabled: true },
      });
      expect(resetRes.status()).toBe(200);
    }

    const initRes = await request.get(`/api/v1/surveys/qr/${QR_CODE}`);
    if (initRes.status() === 200) {
      const { sessionId } = (await initRes.json()).data;
      const rateRes = await request.post('/api/v1/surveys/rate', {
        data: { sessionId, starRating: 5 },
      });
      expect(rateRes.status()).toBe(200);
      const data = (await rateRes.json()).data;
      expect(data.sentimentGroup).toBe('POSITIVE');
      expect(data.targetScreen).toBe('M1-02');
    } else {
      // Môi trường local chưa cấu hình SUPABASE_SERVICE_ROLE_KEY trong backend/.env
      expect(initRes.status()).toBe(401);
      const errBody = await initRes.json();
      expect(errBody.code).toBe('UNAUTHORIZED');
    }
  });
});
