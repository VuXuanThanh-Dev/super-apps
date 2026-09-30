// Smoke test bản build web của một app Flutter trong Chromium headless.
//
// Dùng:
//   node web-smoke.mjs <thư mục build/web> "<chữ phải thấy 1>" ["<chữ 2>" ...]
// Ví dụ:
//   node web-smoke.mjs ../vol1-co-ban/examples/build/web "Việc cần làm" "Còn 3 việc chưa xong"
//
// Cách làm: chạy một HTTP server tĩnh nhỏ (Node), mở trang bằng Chromium của Playwright,
// bật cây semantics của Flutter (bấm vào <flt-semantics-placeholder>) rồi tìm chữ trong
// các node semantics (aria-label / textContent). Flutter web vẽ lên canvas, nên nếu không
// bật semantics thì chữ không có trong DOM.
// Build web nên dùng `--no-web-resources-cdn` vì sandbox chặn CDN gstatic.
import { createServer } from 'node:http';
import { existsSync, readFileSync, statSync } from 'node:fs';
import { extname, join, normalize, resolve } from 'node:path';
import { chromium } from 'playwright-core';

const [dirArg, ...expected] = process.argv.slice(2);
if (!dirArg || expected.length === 0) {
  console.error('Dùng: node web-smoke.mjs <build/web> "<chữ 1>" ["<chữ 2>" ...]');
  process.exit(2);
}
const root = resolve(dirArg);
if (!existsSync(join(root, 'index.html'))) {
  console.error(`Không thấy ${root}/index.html — hãy chạy flutter build web trước.`);
  process.exit(2);
}

const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript',
  '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png',
  '.otf': 'font/otf', '.ttf': 'font/ttf', '.css': 'text/css', '.symbols': 'text/plain',
};

const server = createServer((req, res) => {
  const path = decodeURIComponent(new URL(req.url, 'http://x').pathname);
  let file = normalize(join(root, path));
  if (!file.startsWith(root)) { res.writeHead(403).end(); return; }
  if (!existsSync(file) || statSync(file).isDirectory()) file = join(root, 'index.html'); // SPA fallback
  res.writeHead(200, {
    'content-type': TYPES[extname(file)] ?? 'application/octet-stream',
    // Cần cho SharedArrayBuffer / Wasm worker (sqflite web) — vô hại với app khác.
    'cross-origin-opener-policy': 'same-origin',
    'cross-origin-embedder-policy': 'require-corp',
  });
  res.end(readFileSync(file));
});

await new Promise((r) => server.listen(0, '127.0.0.1', r));
const url = `http://127.0.0.1:${server.address().port}/`;
const executablePath = process.env.CHROME_PATH ||
  (existsSync('/opt/pw-browsers/chromium-1194/chrome-linux/chrome') ? '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' : undefined);
const browser = await chromium.launch({ executablePath });
const errors = [];
const external = []; // request ra ngoài 127.0.0.1 bị lỗi (sandbox chặn) → chỉ cảnh báo
let ok = false;
try {
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } }); // cỡ iPhone
  page.on('pageerror', (e) => errors.push(`pageerror: ${e.message}`));
  page.on('console', (m) => {
    if (m.type() !== 'error') return;
    const src = m.location()?.url ?? '';
    if (src && !src.startsWith(url)) external.push(`${m.text()} (${src})`);
    else errors.push(`console: ${m.text()}`);
  });
  page.on('requestfailed', (r) => { if (!r.url().startsWith(url)) external.push(`request failed: ${r.url()}`); });
  await page.goto(url, { waitUntil: 'load' });
  await page.waitForSelector('flt-semantics-placeholder', { state: 'attached', timeout: 60000 });
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  const found = {};
  const deadline = Date.now() + 30000;
  while (Date.now() < deadline) {
    const texts = await page.evaluate(() =>
      [...document.querySelectorAll('flt-semantics, flt-semantics *')]
        .map((n) => `${n.getAttribute('aria-label') ?? ''} ${n.textContent ?? ''}`)
        .join('\n'));
    for (const t of expected) found[t] = texts.includes(t);
    if (Object.values(found).every(Boolean)) break;
    await page.waitForTimeout(500);
  }
  for (const [t, v] of Object.entries(found)) console.log(`${v ? '✔' : '✘'} thấy "${t}"`);
  const title = await page.title();
  console.log(`title: ${title}`);
  if (errors.length) console.log(`Lỗi trong trang:\n  ${errors.join('\n  ')}`);
  if (external.length) console.log(`Cảnh báo (tài nguyên bên ngoài, sandbox chặn — không tính là lỗi):\n  ${[...new Set(external)].join('\n  ')}`);
  ok = Object.values(found).every(Boolean) && errors.length === 0;
} finally {
  await browser.close();
  server.close();
}
console.log(ok ? 'WEB SMOKE OK' : 'WEB SMOKE FAILED');
process.exit(ok ? 0 : 1);
