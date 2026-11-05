const { test, expect } = require('@playwright/test');

const scenarios = [
  {
    name: '5 sao - đánh giá tích cực',
    stars: 5,
    sentiment: 'POSITIVE',
    screen: 'M1-02',
    urgentCall: false
  },
  {
    name: '3 sao - đánh giá tiêu cực',
    stars: 3,
    sentiment: 'NEGATIVE',
    screen: 'M1-04',
    urgentCall: false
  },
  {
    name: '1 sao - yêu cầu gọi khẩn cấp',
    stars: 1,
    sentiment: 'NEGATIVE',
    screen: 'M1-04',
    urgentCall: true
  }
];

for (const scenario of scenarios) {
  test(scenario.name, async ({ request }) => {

    // 1. Quét QR và tạo phiên khảo sát (TC01)
    const startQr = Date.now();
    const qrResponse = await request.get('/api/v1/surveys/qr/MC-B04');
    const qrDuration = Date.now() - startQr;
    console.log(`[TC01 - Scan QR MC-B04] Status: ${qrResponse.status()}, ResponseTime: ${qrDuration}ms`);

    expect(qrResponse.status()).toBe(200);

    const qr = await qrResponse.json();

    expect(qr.success).toBe(true);
    expect(qr.data.sessionId).toBeTruthy();
    expect(qr.data.branchName).toBeTruthy();

    const sessionId = qr.data.sessionId;

    // 2. Kiểm tra session ban đầu (TC02)
    const startSess = Date.now();
    const initialResponse = await request.get(
      `/api/v1/surveys/session/${sessionId}`
    );
    const sessDuration = Date.now() - startSess;
    console.log(`[TC02 - Get Initial Session] Status: ${initialResponse.status()}, ResponseTime: ${sessDuration}ms`);

    expect(initialResponse.status()).toBe(200);

    const initialSession = await initialResponse.json();

    expect(initialSession.success).toBe(true);
    expect(initialSession.data.status).toBe('STARTED');

    // 3. Gửi đánh giá (TC04/TC06/TC08)
    const startRate = Date.now();
    const ratingResponse = await request.post('/api/v1/surveys/rate', {
      data: {
        sessionId,
        starRating: scenario.stars
      }
    });
    const rateDuration = Date.now() - startRate;
    console.log(`[Rate ${scenario.stars} stars] Status: ${ratingResponse.status()}, ResponseTime: ${rateDuration}ms`);

    expect(ratingResponse.status()).toBe(200);

    const rating = await ratingResponse.json();

    expect(rating.success).toBe(true);
    expect(rating.data.responseId).toBeTruthy();
    expect(rating.data.sessionId).toBe(sessionId);
    expect(rating.data.starRating).toBe(scenario.stars);
    expect(rating.data.sentimentGroup).toBe(scenario.sentiment);
    expect(rating.data.targetScreen).toBe(scenario.screen);
    expect(rating.data.allowUrgentCall).toBe(scenario.urgentCall);

    // 4. Kiểm tra session sau khi đánh giá
    const finalResponse = await request.get(
      `/api/v1/surveys/session/${sessionId}`
    );

    expect(finalResponse.status()).toBe(200);

    const finalSession = await finalResponse.json();

    expect(finalSession.success).toBe(true);
    expect(finalSession.data.status).toBe('COMPLETED');
    expect(finalSession.data.completedAt).not.toBeNull();
  });
}
