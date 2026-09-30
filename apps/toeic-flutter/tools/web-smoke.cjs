#!/usr/bin/env node
/* Smoke test of the Flutter WEB build in headless Chromium (extra evidence; the real targets are iPhone/Android).
 *
 *   flutter build web --no-web-resources-cdn --release
 *   NODE_PATH=$(npm root -g) node tools/web-smoke.cjs build/web [screenshot-dir]
 *
 * Needs Playwright (global `playwright` 1.56.1 in the sandbox; Chromium from PLAYWRIGHT_BROWSERS_PATH).
 * Flutter web draws on a canvas, so we turn on Flutter's semantics tree (click <flt-semantics-placeholder>)
 * and drive the app through it: every tappable word of TappableText becomes an <a> element there.
 * Flow (same as Task 5's tools/web-smoke.js): Home stats -> Read -> passage -> tap a word -> popup,
 * Practice -> flashcard -> grade Good -> next card, Home counts the review, Settings -> Dark mode.
 * The page is served with COOP/COEP headers (needed by the sqflite Wasm worker).
 */
const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const root = path.resolve(process.argv[2] || 'build/web');
const shots = process.argv[3];
if (!fs.existsSync(path.join(root, 'index.html'))) {
  console.error(`no ${root}/index.html — run: flutter build web --no-web-resources-cdn --release`);
  process.exit(2);
}
if (shots) fs.mkdirSync(shots, { recursive: true });
const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript', '.wasm': 'application/wasm',
  '.json': 'application/json', '.png': 'image/png', '.ttf': 'font/ttf', '.otf': 'font/otf', '.db': 'application/octet-stream',
};
const server = http.createServer((req, res) => {
  let f = path.normalize(path.join(root, decodeURIComponent(new URL(req.url, 'http://x').pathname)));
  if (!f.startsWith(root)) { res.writeHead(403).end(); return; }
  if (!fs.existsSync(f) || fs.statSync(f).isDirectory()) f = path.join(root, 'index.html');
  res.writeHead(200, {
    'content-type': types[path.extname(f)] || 'application/octet-stream',
    'cross-origin-opener-policy': 'same-origin',
    'cross-origin-embedder-policy': 'require-corp',
  });
  res.end(fs.readFileSync(f));
});

let failed = 0;
function check(name, ok) {
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`);
  if (!ok) failed++;
}

(async () => {
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  const url = `http://127.0.0.1:${server.address().port}/`;
  const browser = await chromium.launch();
  // locale: the sandbox has no LANG, so headless Chromium reports "en-US@posix", which Flutter web rejects
  // ("Incorrect locale information provided"). Real browsers send a normal tag like "vi-VN" or "en-US".
  const page = await browser.newPage({ viewport: { width: 390, height: 844 }, locale: 'en-US' });
  const errors = [];
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  page.on('console', (m) => { if (m.type() === 'error' && !/fonts\.gstatic|Failed to load resource/.test(m.text())) errors.push(`console: ${m.text()}`); });
  const shot = async (n) => shots && page.screenshot({ path: path.join(shots, `${n}.png`) });
  const wait = (ms = 800) => page.waitForTimeout(ms);
  const semText = () => page.evaluate(() => [...document.querySelectorAll('flt-semantics, flt-semantics *')]
    .map((n) => `${n.getAttribute('aria-label') ?? ''} ${n.childElementCount ? '' : n.textContent ?? ''}`).join('\n'));
  const waitText = async (re, ms = 20000) => {
    const end = Date.now() + ms;
    while (Date.now() < end) { if (re.test(await semText())) return true; await wait(300); }
    return false;
  };
  const tab = async (name) => { await page.getByRole('tab', { name }).click(); await wait(); };
  const button = (re) => page.locator('flt-semantics[role=button]', { hasText: re }).first();
  const speakLabel = async () => {
    const labels = await page.evaluate(() => [...document.querySelectorAll('[role=button]')]
      .map((n) => n.getAttribute('aria-label') || n.textContent || '').filter((t) => /^Speak (?!example|line)/.test(t)));
    return (labels[0] || '').replace(/^Speak /, '');
  };

  try {
    await page.goto(url, { waitUntil: 'load' });
    await page.waitForSelector('flt-semantics-placeholder', { state: 'attached', timeout: 90000 });
    await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
    check('Home shows progress stats (Streak, Learned, Due today)', await waitText(/Streak[\s\S]*|Learned/));
    const home = await semText();
    const m = home.match(/(\d+) words · (\d+) units/);
    console.log(`      dataset on screen: ${m ? m[0] : '?'}${/Sample data/.test(home) ? ' (sample — private-data empty)' : ''}`);
    await shot('1-home');

    // Tap-to-define in a reading passage
    await tab('Read');
    const firstPassage = page.getByRole('button').first();
    const title = (await firstPassage.textContent()) || '';
    await firstPassage.click();
    await wait(1200);
    const links = page.locator('flt-semantics a');
    check(`passage "${title.trim()}" renders words as tappable links (${await links.count()})`, (await links.count()) > 20);
    const word = page.locator('flt-semantics a', { hasText: /^[A-Za-z]{7,}$/ }).nth(1);
    const tapped = ((await word.textContent()) || '').trim();
    await word.click();
    await wait(1200);
    const popupWord = await speakLabel();
    const popupText = await semText();
    check(`tap "${tapped}" opens the popup (headword "${popupWord}", Save button)`, popupWord.length > 0 && /Save to my list|Saved \(tap to remove\)/.test(popupText));
    await shot('2-popup');
    await button(/^Close$/).click();
    await wait();

    // Flashcards
    await tab('Practice');
    await button(/Flashcards/).click();
    await wait(1500);
    const front = await speakLabel();
    await button(/Show answer/).click();
    await wait();
    await button(/^Good/).click();
    await wait(1200);
    const next = await speakLabel();
    check(`flashcard "${front}" graded Good, next card "${next}"`, front.length > 0 && next.length > 0 && next !== front);
    await shot('3-flashcards');

    // Stats
    await tab('Home');
    check('Home counts the review ("1 reviews")', await waitText(/1 reviews/, 8000));

    // Dark mode
    await button(/^Settings$/).click();
    await wait();
    await wait(800);
    // Tap like a finger at the button's position (pointer event goes to the Flutter view). A plain
    // locator.click() is refused here because an empty full-screen semantics node sits on top.
    const box = await button(/Dark/).boundingBox();
    await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
    check('dark mode on (Settings → Dark)', await waitText(/Current: dark/, 5000));
    await wait(500);
    await shot('4-dark');
  } catch (e) {
    check(`no exception (${e.message.split('\n')[0]})`, false);
    if (process.env.SMOKE_DEBUG) console.log(e.message);
  }
  check(`no page errors (${errors.length})`, errors.length === 0);
  errors.slice(0, 5).forEach((e) => console.log('   ', e.slice(0, 300)));
  await browser.close();
  server.close();
  console.log(failed ? `WEB SMOKE FAILED (${failed})` : 'WEB SMOKE OK');
  process.exit(failed ? 1 : 0);
})();
