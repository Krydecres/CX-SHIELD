const { defineConfig } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './e2e',
  fullyParallel: false,
  workers: 1,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }]
  ],
  use: {
    baseURL: process.env.API_BASE_URL || 'http://localhost:8080',
    extraHTTPHeaders: {
      'Content-Type': 'application/json'
    }
  }
});
