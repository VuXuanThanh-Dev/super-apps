#!/usr/bin/env node
/* Optional smoke test of the WEB build in headless Chromium (extra evidence only;
 * the real target is iPhone + Expo Go). Needs Playwright installed globally.
 *   CI=1 npx expo export --platform web --output-dir /tmp/toeic-web
 *   NODE_PATH=$(npm root -g) node tools/web-smoke.js /tmp/toeic-web [screenshot-dir]
 * Serves the folder with the COOP/COEP headers that expo-sqlite (wasm) needs,
 * then clicks through: Home -> Read -> passage -> tap a word -> popup,
 * Practice -> flashcard -> grade, Settings -> dark mode. */
const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = process.argv[2];
const shots = process.argv[3];
if (!root) {
  console.error('usage: node tools/web-smoke.js <web-export-dir> [screenshot-dir]');
  process.exit(2);
}
const types = { '.html': 'text/html', '.js': 'application/javascript', '.wasm': 'application/wasm', '.ttf': 'font/ttf', '.png': 'image/png', '.json': 'application/json' };
const server = http
  .createServer((req, res) => {
    let f = path.join(root, decodeURIComponent(req.url.split('?')[0]));
    if (!fs.existsSync(f) || fs.statSync(f).isDirectory()) f = path.join(root, 'index.html');
    res.writeHead(200, {
      'Content-Type': types[path.extname(f)] || 'application/octet-stream',
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    });
    fs.createReadStream(f).pipe(res);
  })
  .listen(8123);

function check(name, ok) {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`);
  if (!ok) process.exitCode = 1;
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  const errors = [];
  page.on('pageerror', (e) => errors.push(String(e)));
  const shot = async (n) => shots && page.screenshot({ path: path.join(shots, `${n}.png`) });
  const tab = (name) => page.getByRole('tab', { name: new RegExp(name) }).first().click();

  await page.goto('http://localhost:8123/', { waitUntil: 'networkidle' });
  await page.waitForTimeout(2500);
  check('Home shows stats', (await page.getByText('Streak').count()) > 0);
  await shot('1-home');

  await tab('Read');
  await page.waitForTimeout(800);
  const firstPassage = page.getByTestId(/^passage-/).first();
  check('Read tab lists passages', (await firstPassage.count()) > 0);
  await firstPassage.click();
  await page.waitForTimeout(1500);
  // every word is a role=link span (TappableText); take a longer one from the passage
  const word = page.getByRole('link').filter({ hasText: /^[A-Za-z]{7,}$/ }).nth(1);
  const tapped = (await word.textContent()) || '';
  await word.click();
  await page.waitForTimeout(800);
  const popupWord = (await page.getByTestId('popup-word').first().textContent()) || '';
  check(`tap "${tapped}" opens popup (${popupWord})`, popupWord.length > 0);
  await shot('2-popup');
  await page.getByTestId('popup-close').first().click();

  await page.goBack();
  await tab('Practice');
  await page.waitForTimeout(500);
  await page.getByTestId('start-flashcards').click();
  await page.waitForTimeout(800);
  const front = (await page.getByTestId('flash-front').first().textContent()) || '';
  await page.getByTestId('flash-show').click();
  await page.getByTestId('grade-good').click();
  await page.waitForTimeout(800);
  const next = (await page.getByTestId('flash-front').first().textContent()) || '';
  check(`flashcard "${front}" graded, next card "${next}"`, front.length > 0 && next !== front);
  await shot('3-flashcards');

  await page.goBack();
  await tab('Home');
  await page.waitForTimeout(500);
  check('Home counts the review (1 word started)', (await page.getByText(/1 reviews/).count()) > 0);
  await page.getByTestId('open-settings').click();
  await page.waitForTimeout(500);
  await page.getByTestId('theme-dark').click();
  await page.waitForTimeout(300);
  check('dark mode on', ((await page.getByTestId('theme-current').textContent()) || '').includes('dark'));
  await shot('4-dark');

  check(`no page errors (${errors.length})`, errors.length === 0);
  errors.slice(0, 5).forEach((e) => console.log('  ', e));
  await browser.close();
  server.close();
})().catch((e) => {
  console.error(e);
  server.close();
  process.exit(1);
});
