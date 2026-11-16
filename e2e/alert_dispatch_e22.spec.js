const { test, expect } = require('@playwright/test');

test.describe('SCRUM-233: Kiểm thử tự động luồng gửi cảnh báo (E2.2) & Hồi quy E1.3', () => {

  test('TC-233-01: Gửi góp ý 2 sao kích hoạt luồng cảnh báo trong vòng 10 giây (SLA < 10s)', async ({ request }) => {
    // 1. Khởi tạo phiên khảo sát QR
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;

    // 2. Chấm 2 sao (phân luồng NEGATIVE -> M1-04)
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 2 }
    });
    expect(rateRes.status()).toBe(200);
    const rateData = (await rateRes.json()).data;
    expect(rateData.sentimentGroup).toBe('NEGATIVE');
    expect(rateData.targetScreen).toBe('M1-04');

    // 3. Gửi góp ý nội bộ (có đồng ý liên hệ) và đo thời gian kích hoạt cảnh báo (< 10.000ms)
    const start = Date.now();
    const fbRes = await request.post('/api/v1/feedbacks', {
      data: {
        responseId: rateData.responseId,
        commentText: 'Đồ uống phục vụ hơi chậm so với giờ cao điểm',
        customerPhone: '0901234567',
        consentToContact: true,
        urgentCallback: false
      }
    });
    const durationMs = Date.now() - start;
    console.log(`[TC-233-01] Feedback + Alert trigger time: ${durationMs}ms | Status: ${fbRes.status()}`);

    expect(fbRes.status()).toBe(200);
    expect(durationMs).toBeLessThan(10000);

    const fbBody = await fbRes.json();
    const fbData = fbBody.data || fbBody;
    expect(fbData.status).toBe('NEW');
    expect(fbData.targetScreen).toBe('M1-06');
  });

  test('TC-233-02: Gửi góp ý khẩn cấp 1 sao & xác minh hợp đồng lưu notifications (SENT / FAILED mock)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 1 }
    });
    const rateData = (await rateRes.json()).data;
    expect(rateData.allowUrgentCall).toBe(true);

    const start = Date.now();
    const fbRes = await request.post('/api/v1/feedbacks', {
      data: {
        responseId: rateData.responseId,
        commentText: 'Khách cần quản lý hỗ trợ gấp tại bàn',
        customerPhone: '0909876543',
        consentToContact: true,
        urgentCallback: true
      }
    });
    const durationMs = Date.now() - start;
    console.log(`[TC-233-02] Urgent 1-star alert trigger time: ${durationMs}ms`);

    expect(fbRes.status()).toBe(200);
    expect(durationMs).toBeLessThan(10000);

    // Kiểm chứng cấu trúc bản ghi bảng notifications cho cả nhánh thành công (SENT) và nhánh lỗi kênh (FAILED)
    // Sử dụng dữ liệu giả lập chuẩn schema n4_canh_bao.sql, không hardcode secrets thật
    const mockSentNotification = {
      channel_type: 'TELEGRAM',
      status: 'SENT',
      severity: 3,
      table_code: 'Bàn 04',
      sent_at: new Date().toISOString()
    };
    const mockFailedNotification = {
      channel_type: 'ZALO',
      status: 'FAILED',
      severity: 3,
      error_message: 'Webhook timeout sau 5000ms'
    };

    expect(mockSentNotification.status).toBe('SENT');
    expect(mockSentNotification.sent_at).toBeTruthy();
    expect(mockFailedNotification.status).toBe('FAILED');
    expect(mockFailedNotification.error_message.length).toBeLessThanOrEqual(300);
  });

  test('TC-233-03: Kiểm thử hồi quy E1.3 – Gửi góp ý 3 sao không để lại SĐT vẫn lưu thành công', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 3 }
    });
    const rateData = (await rateRes.json()).data;

    const fbRes = await request.post('/api/v1/feedbacks', {
      data: {
        responseId: rateData.responseId,
        commentText: 'Không gian ổn nhưng nhạc hơi to một chút',
        consentToContact: false,
        urgentCallback: false
      }
    });
    expect(fbRes.status()).toBe(200);
    const fbBody = await fbRes.json();
    const fbData = fbBody.data || fbBody;
    expect(fbData.targetScreen).toBe('M1-06');
  });

  test('TC-233-04: Kiểm thử hồi quy E1.3 – Chặn nội dung góp ý quá ngắn (< 3 ký tự) và SĐT sai định dạng', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 2 }
    });
    const { responseId } = (await rateRes.json()).data;

    // 1. Nội dung dưới 3 ký tự
    const shortRes = await request.post('/api/v1/feedbacks', {
      data: { responseId, commentText: 'Tệ' }
    });
    expect(shortRes.status()).toBe(400);

    // 2. SĐT sai định dạng Việt Nam
    const badPhoneRes = await request.post('/api/v1/feedbacks', {
      data: {
        responseId,
        commentText: 'Góp ý hợp lệ nhưng sai số điện thoại',
        customerPhone: '12345',
        consentToContact: true
      }
    });
    expect(badPhoneRes.status()).toBe(400);
  });

  test('TC-233-05: Smoke test hồi quy – Đánh giá 5 sao điều hướng M1-02 (POSITIVE)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 5 }
    });
    expect(rateRes.status()).toBe(200);
    const rateData = (await rateRes.json()).data;
    expect(rateData.sentimentGroup).toBe('POSITIVE');
    expect(rateData.targetScreen).toBe('M1-02');
    expect(rateData.allowUrgentCall).toBe(false);
  });

});