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

    // 1. Quét QR và tạo phiên khảo sát
    const qrResponse = await request.get('/api/v1/surveys/qr/MC-B04');

    expect(qrResponse.status()).toBe(200);

    const qr = await qrResponse.json();

    expect(qr.success).toBe(true);
    expect(qr.data.sessionId).toBeTruthy();
    expect(qr.data.branchName).toBeTruthy();

    const sessionId = qr.data.sessionId;

    // 2. Kiểm tra session ban đầu
    const initialResponse = await request.get(
      `/api/v1/surveys/session/${sessionId}`
    );

    expect(initialResponse.status()).toBe(200);

    const initialSession = await initialResponse.json();

    expect(initialSession.success).toBe(true);
    expect(initialSession.data.status).toBe('STARTED');

    // 3. Gửi đánh giá
    const ratingResponse = await request.post('/api/v1/surveys/rate', {
      data: {
        sessionId,
        starRating: scenario.stars
      }
    });

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
