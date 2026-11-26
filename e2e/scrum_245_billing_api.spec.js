
const { test, expect } = require('@playwright/test');

const API_TOKEN = process.env.API_TOKEN;

test.describe('SCRUM-245 - Billing Plans API', () => {
  test('TC01 - API từ chối truy cập khi chưa đăng nhập', async ({ request }) => {
    const response = await request.get('/api/v1/plans');

    expect([401, 403]).toContain(response.status());
  });

  test('TC02 - API trả về danh sách gói dịch vụ', async ({ request }) => {
    test.skip(!API_TOKEN, 'Cần cung cấp API_TOKEN để kiểm thử API có xác thực');

    const response = await request.get('/api/v1/plans', {
      headers: {
        Authorization: `Bearer ${API_TOKEN}`,
      },
    });

    expect(response.status()).toBe(200);

    const plans = await response.json();

    expect(Array.isArray(plans)).toBe(true);

    for (const plan of plans) {
      expect(plan).toHaveProperty('id');
      expect(plan).toHaveProperty('name');
    }
  });
});
