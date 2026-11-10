const { test, expect } = require('@playwright/test');

test.describe('SCRUM-188: Kịch bản kiểm thử bổ sung cho phân hệ khảo sát QR (E1.1)', () => {

  test('TC03: Quét mã QR chưa có sẵn trong CSDL (Cơ chế tự động Fallback)', async ({ request }) => {
    const unknownCode = 'TABLE-UNKNOWN-99';
    const start = Date.now();
    const res = await request.get(`/api/v1/surveys/qr/${unknownCode}`);
    const duration = Date.now() - start;

    console.log(`[TC03 Response Time]: ${duration}ms | Status: ${res.status()}`);
    expect(res.status()).toBe(200);

    const body = await res.json();
    expect(body.success).toBe(true);
    expect(body.message).toBe('Khởi tạo khảo sát thành công');
    expect(body.data.sessionId).toBeTruthy();
    expect(body.data.branchName).toBe('Chi nhánh Quận 1 - Đồng Khởi');
    expect(body.data.businessName).toBe('Maison Coffee & Bistro');
    expect(body.data.tableOrAreaCode).toBe(`Vị trí ${unknownCode}`);
  });

  test('TC05: Gửi đánh giá 4 sao (Hài lòng - Phân luồng POSITIVE)', async ({ request }) => {
    // Khởi tạo phiên
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;

    // Gửi đánh giá 4 sao
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 4 }
    });
    console.log(`[TC05 - 4 Stars] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(200);

    const body = await rateRes.json();
    expect(body.success).toBe(true);
    expect(body.data.starRating).toBe(4);
    expect(body.data.sentimentGroup).toBe('POSITIVE');
    expect(body.data.targetScreen).toBe('M1-02');
    expect(body.data.allowUrgentCall).toBe(false);
  });

  test('TC07: Gửi đánh giá 2 sao (Không hài lòng - Phân luồng NEGATIVE)', async ({ request }) => {
    // Khởi tạo phiên
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;

    // Gửi đánh giá 2 sao
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 2 }
    });
    console.log(`[TC07 - 2 Stars] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(200);

    const body = await rateRes.json();
    expect(body.success).toBe(true);
    expect(body.data.starRating).toBe(2);
    expect(body.data.sentimentGroup).toBe('NEGATIVE');
    expect(body.data.targetScreen).toBe('M1-04');
    expect(body.data.allowUrgentCall).toBe(false);
  });

  test('TC09: Gửi đánh giá 0 sao (Dưới biên hợp lệ)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 0 }
    });
    console.log(`[TC09 - 0 Stars] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Đánh giá sao phải từ 1 đến 5');
  });

  test('TC10: Gửi đánh giá 6 sao (Vượt quá biên trên hợp lệ)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 6 }
    });
    console.log(`[TC10 - 6 Stars] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Đánh giá sao phải từ 1 đến 5');
  });

  test('TC11: Gửi đánh giá số sao âm (-1 sao)', async ({ request }) => {
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    const { sessionId } = (await initRes.json()).data;

    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: -1 }
    });
    console.log(`[TC11 - -1 Stars] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Đánh giá sao phải từ 1 đến 5');
  });

  test('TC12: Gửi đánh giá thiếu sessionId (null)', async ({ request }) => {
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId: null, starRating: 5 }
    });
    console.log(`[TC12 - null SessionId] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Session ID không được để trống');
  });

  test('TC13: Gửi đánh giá với sessionId không tồn tại trong hệ thống', async ({ request }) => {
    const fakeUuid = '00000000-0000-0000-0000-000000000000';
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId: fakeUuid, starRating: 5 }
    });
    console.log(`[TC13 - Non-existent SessionId] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Phiên khảo sát không tồn tại hoặc đã hết hạn');
  });

  test('TC14: Gửi đánh giá sai định dạng kiểu dữ liệu (Kiểu chuỗi thay vì số)', async ({ request }) => {
    const rateRes = await request.post('/api/v1/surveys/rate', {
      data: { sessionId: 'invalid-uuid-string', starRating: 'nam-sao' }
    });
    console.log(`[TC14 - Malformed Data] Status: ${rateRes.status()}`);
    expect(rateRes.status()).toBe(400);

    const body = await rateRes.json();
    expect(body.code).toBe('BAD_REQUEST');
    expect(body.message).toBe('Yêu cầu không hợp lệ.');
  });

  test('TC15: Tra cứu phiên khảo sát với sessionId không tồn tại', async ({ request }) => {
    const fakeUuid = '00000000-0000-0000-0000-000000000000';
    const res = await request.get(`/api/v1/surveys/session/${fakeUuid}`);
    console.log(`[TC15 - Non-existent Session Query] Status: ${res.status()}`);
    expect(res.status()).toBe(400);

    const body = await res.json();
    expect(body.success).toBe(false);
    expect(body.message).toBe('Không tìm thấy phiên khảo sát');
  });

  test('TC17: Kiểm chứng lỗi BUG-01 (Đánh giá lần 2 trên cùng một session COMPLETED)', async ({ request }) => {
    // 1. Tạo session mới
    const initRes = await request.get('/api/v1/surveys/qr/MC-B04');
    expect(initRes.status()).toBe(200);
    const { sessionId } = (await initRes.json()).data;
    console.log(`[TC17] Đã tạo session mới: ${sessionId}`);

    // 2. Gửi đánh giá lần đầu (5 sao)
    const rateRes1 = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 5 }
    });
    const status1 = rateRes1.status();
    const body1 = await rateRes1.json();
    console.log(`[TC17 - Lần 1] Status: ${status1} | Body: ${JSON.stringify(body1)}`);

    expect(status1).toBe(200);
    expect(body1.success).toBe(true);
    expect(body1.data.targetScreen).toBe('M1-02');
    const responseId1 = body1.data.responseId;

    // 3. Gửi đánh giá lần 2 trên CÙNG session đó (1 sao)
    const rateRes2 = await request.post('/api/v1/surveys/rate', {
      data: { sessionId, starRating: 1 }
    });
    const status2 = rateRes2.status();
    const body2 = await rateRes2.json();
    console.log(`[TC17 - Lần 2] Status: ${status2} | Body: ${JSON.stringify(body2)}`);

    // GHI NHẬN KẾT QUẢ THỰC TẾ:
    // Theo chuẩn nghiệp vụ lý tưởng, request lần 2 phải bị chặn (400 hoặc 409).
    // Nhưng mã nguồn thực tế hiện tại trả về 200 OK và tạo thêm một responseId mới (BUG-01).
    if (status2 === 200) {
      console.log(`[TC17 BẰNG CHỨNG BUG-01]: Server trả về HTTP 200 OK cho lần đánh giá thứ 2!`);
      console.log(`[TC17 BẰNG CHỨNG BUG-01]: Response ID 1 = ${responseId1} vs Response ID 2 = ${body2.data.responseId}`);
      console.log(`[TC17 BẰNG CHỨNG BUG-01]: Trạng thái bị ghi đè từ POSITIVE (5 sao) sang ${body2.data.sentimentGroup} (${body2.data.starRating} sao)!`);
    }

    // Assertion kiểm tra hành vi thực tế của hệ thống để xác nhận BUG-01 đã tái hiện
    expect(status2).toBe(200);
    expect(body2.data.responseId).not.toBe(responseId1);
  });

});
