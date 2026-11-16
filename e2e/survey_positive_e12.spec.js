const { test, expect } = require('@playwright/test');

test.describe('SCRUM-224 [E1.2]: Kiểm thử tự động luồng 4-5 sao sang Google Maps & ghi nhận lượt chuyển', () => {

  test('TC-224-01: Đánh giá 5 sao điều hướng M1-02, không gắn voucher/quà tặng', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 5 }
    });
    expect(rateRes.status()).toBe(200);

    const body = await rateRes.json();
    console.log('[TC-224-01] 5-star response:', JSON.stringify(body.data));
    expect(body.success).toBe(true);
    expect(body.data.starRating).toBe(5);
    expect(body.data.sentimentGroup).toBe('POSITIVE');
    expect(body.data.targetScreen).toBe('M1-02');
    expect(body.data.allowUrgentCall).toBe(false);
    // Đảm bảo không gắn voucher với 5 sao (chống review gating)
    expect(body.data.voucherCode).toBeUndefined();
  });

  test('TC-224-02: Đánh giá 4 sao điều hướng M1-02 (POSITIVE)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 4 }
    });
    expect(rateRes.status()).toBe(200);

    const body = await rateRes.json();
    console.log('[TC-224-02] 4-star response:', JSON.stringify(body.data));
    expect(body.data.starRating).toBe(4);
    expect(body.data.sentimentGroup).toBe('POSITIVE');
    expect(body.data.targetScreen).toBe('M1-02');
  });

  test('TC-224-03: Ghi nhận lượt chuyển Google Maps (redirect_clicked_at) và kiểm tra Place ID', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 5 }
    });
    const { responseId } = (await rateRes.json()).data;

    const bypassRes = await request.post('/api/v1/surveys/public-review', {
      data: { responseId }
    });
    expect(bypassRes.status()).toBe(200);

    const bypassBody = await bypassRes.json();
    console.log('[TC-224-03] Public review redirect:', JSON.stringify(bypassBody.data));
    expect(bypassBody.success).toBe(true);
    expect(bypassBody.data.publicBypass).toBe(true);
    expect(bypassBody.data.redirectClickedAt).toBeTruthy();
    expect(bypassBody.data.reviewDirectUrl).toContain('writereview?placeid=');
    // Không điền sẵn số sao hay nội dung trên URL Google Maps
    expect(bypassBody.data.reviewDirectUrl).not.toContain('rating=');
    expect(bypassBody.data.reviewDirectUrl).not.toContain('review=');
  });

  test('TC-224-04: Từ chối ghi nhận lượt chuyển Google khi thiếu responseId', async ({ request }) => {
    const bypassRes = await request.post('/api/v1/surveys/public-review', {
      data: { responseId: null }
    });
    expect(bypassRes.status()).toBe(400);
    const body = await bypassRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Response ID không được để trống');
  });
});