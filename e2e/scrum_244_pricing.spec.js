const { test, expect } = require('@playwright/test');

test.describe('SCRUM-244: Pricing and plan selection API', () => {
  test('TC-244-A01: API trả về danh sách gói dịch vụ', async ({ request }) => {
    const response = await request.get('/api/v1/plans');

    console.log(`[SCRUM-244] GET /api/v1/plans: ${response.status()}`);

    expect(response.status()).toBe(200);

    const body = await response.json();
    expect(body).toBeTruthy();

    // Hỗ trợ response dạng array trực tiếp hoặc { data: [...] }.
    const plans = Array.isArray(body) ? body : body.data;

    expect(Array.isArray(plans)).toBe(true);
    expect(plans.length).toBeGreaterThanOrEqual(3);

    const serialized = JSON.stringify(plans).toLowerCase();

    // Kiểm tra dữ liệu có đủ ba nhóm gói dịch vụ.
    expect(serialized).toContain('basic');
    expect(serialized).toContain('advanced');
    expect(serialized).toContain('chain');
  });
});
