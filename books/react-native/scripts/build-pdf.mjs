// Build 3 file PDF cho bộ sách React Native.
// Quy trình: Markdown (nguồn chính) → pandoc → HTML (CSS dùng font Noto) → Chromium (playwright-core) → PDF.
// Sơ đồ Mermaid được vẽ ngay trong trang bằng mermaid (npm, bản local) trước khi in.
//
// Dùng:
//   cd books/react-native/scripts && npm ci && node build-pdf.mjs
// Yêu cầu: pandoc (sách dùng 3.1.3), Chromium của Playwright (biến PLAYWRIGHT_BROWSERS_PATH
// hoặc CHROME_PATH), font Noto Serif / Noto Sans / Noto Sans Mono / Noto Color Emoji.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright-core';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..');
const dist = join(root, 'dist');
mkdirSync(dist, { recursive: true });

const chapters = (vol) =>
  readdirSync(join(root, vol))
    .filter((f) => /^\d\d-.*\.md$/.test(f))
    .sort()
    .map((f) => join(root, vol, f));

const VOLUMES = [
  {
    id: 'vol1-co-ban',
    out: 'React-Native-Tap1-Co-Ban.pdf',
    title: 'React Native từ cơ bản đến nâng cao — Tập 1: Cơ bản',
    subtitle: 'Cài đặt, component, styling, Flexbox, danh sách, form, điều hướng — và React Native cho Angular developer',
    extra: ['STACK.md', 'GLOSSARY.md'],
  },
  {
    id: 'vol2-trung-cap',
    out: 'React-Native-Tap2-Trung-Cap.pdf',
    title: 'React Native từ cơ bản đến nâng cao — Tập 2: Trung cấp',
    subtitle: 'Quản lý state, lấy dữ liệu, lưu trữ offline, animation, device APIs, testing',
    extra: ['GLOSSARY.md'],
  },
  {
    id: 'vol3-nang-cao',
    out: 'React-Native-Tap3-Nang-Cao.pdf',
    title: 'React Native từ cơ bản đến nâng cao — Tập 3: Nâng cao',
    subtitle: 'New Architecture, native modules, performance, security, CI/CD, phát hành, monitoring',
    extra: ['GLOSSARY.md'],
  },
];

const CSS = `
@page { size: A4; margin: 18mm 16mm 20mm 16mm; }
html { font-family: "Noto Serif", "Noto Color Emoji", serif; font-size: 10.5pt; line-height: 1.5; color: #111827; }
body { max-width: none; margin: 0; padding: 0; }
h1, h2, h3, h4 { font-family: "Noto Sans", "Noto Color Emoji", sans-serif; line-height: 1.25; }
h1 { font-size: 20pt; color: #1d4ed8; break-before: page; margin-top: 0; }
h2 { font-size: 14pt; color: #1e3a8a; border-bottom: 1px solid #dbeafe; padding-bottom: 2pt; margin-top: 16pt; }
h3 { font-size: 12pt; }
code, pre, kbd { font-family: "Noto Sans Mono", "Noto Color Emoji", monospace; font-size: 8.6pt; }
pre { background: #f6f8fa; border: 1px solid #e5e7eb; border-radius: 4px; padding: 6pt 8pt; white-space: pre-wrap; word-break: break-word; }
p code, li code, td code { background: #f3f4f6; padding: 0 2pt; border-radius: 2px; }
table { border-collapse: collapse; width: 100%; margin: 8pt 0; font-size: 9pt; }
th, td { border: 1px solid #d1d5db; padding: 3pt 5pt; vertical-align: top; }
th { background: #eff6ff; font-family: "Noto Sans", sans-serif; }
blockquote { border-left: 3px solid #93c5fd; margin: 8pt 0; padding: 2pt 10pt; color: #374151; background: #f8fafc; }
details { border: 1px dashed #9ca3af; border-radius: 4px; padding: 4pt 8pt; margin: 6pt 0; }
summary { font-family: "Noto Sans", sans-serif; font-weight: 700; color: #065f46; }
a { color: #1d4ed8; text-decoration: none; word-break: break-all; }
.mermaid { text-align: center; margin: 10pt 0; break-inside: avoid; }
.mermaid svg { max-width: 100%; height: auto; }
pre, table, blockquote { break-inside: avoid-page; }
#title-block-header { display: none; }
nav#TOC { break-after: page; }
nav#TOC::before { content: "Mục lục"; display: block; font-family: "Noto Sans", sans-serif; font-size: 18pt; font-weight: 700; color: #1d4ed8; margin-bottom: 8pt; }
nav#TOC ul { list-style: none; padding-left: 12pt; }
nav#TOC > ul { padding-left: 0; }
.cover { height: 250mm; display: flex; flex-direction: column; justify-content: center; break-after: page; }
.cover h1 { break-before: auto; font-size: 26pt; }
.cover .sub { font-family: "Noto Sans", sans-serif; font-size: 13pt; color: #374151; }
.cover .meta { margin-top: 30pt; font-size: 10pt; color: #6b7280; }
`;

function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function buildHtml(vol) {
  const files = [...chapters(vol.id), ...vol.extra.map((f) => join(root, f))];
  for (const f of files) if (!existsSync(f)) throw new Error(`Thiếu file: ${f}`);
  let html = execFileSync(
    'pandoc',
    [...files, '-f', 'gfm', '-t', 'html5', '-s', '--toc', '--toc-depth=2', '--metadata', `title=${vol.title}`],
    { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 },
  );
  // 1) Sơ đồ Mermaid: pandoc xuất <pre class="mermaid"><code>…</code></pre> → <div class="mermaid">…</div>
  html = html.replace(/<pre class="mermaid"><code>([\s\S]*?)<\/code><\/pre>/g, (_m, code) => `<div class="mermaid">${code}</div>`);
  // 2) Lời giải trong <details>: mở sẵn để in ra giấy.
  html = html.replace(/<details>/g, '<details open>');
  // 3) CSS + trang bìa
  const cover = `<section class="cover"><h1>${escapeHtml(vol.title)}</h1><p class="sub">${escapeHtml(vol.subtitle)}</p>
    <p class="meta">Expo SDK 57 · React Native 0.86.3 · React 19.2.3 · TypeScript 6.0.3<br/>Bản dựng: ${new Date().toISOString().slice(0, 10)} — Markdown là nguồn chính (books/react-native/${vol.id}/)
    <br/>Kiểm tra dấu tiếng Việt: ắ ằ ẳ ẵ ặ ơ ư đ Ư Đ — Đường ướt, trăng khuyết, Ưu tiên</p></section>`;
  html = html.replace(/<html[^>]*>/, '<html lang="vi">').replace('</head>', `<style>${CSS}</style></head>`).replace(/<body>/, `<body>${cover}`);
  return html;
}

async function main() {
  const executablePath = process.env.CHROME_PATH || (existsSync('/opt/pw-browsers/chromium-1194/chrome-linux/chrome') ? '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' : undefined);
  const browser = await chromium.launch({ executablePath });
  const mermaidPath = join(here, 'node_modules', 'mermaid', 'dist', 'mermaid.min.js');
  try {
    for (const vol of VOLUMES) {
      const page = await browser.newPage();
      await page.setContent(buildHtml(vol), { waitUntil: 'load' });
      await page.addScriptTag({ content: readFileSync(mermaidPath, 'utf8') });
      const diagrams = await page.evaluate(async () => {
        const m = globalThis.mermaid;
        m.initialize({ startOnLoad: false, theme: 'neutral', fontFamily: 'Noto Sans', securityLevel: 'strict' });
        const nodes = document.querySelectorAll('.mermaid');
        await m.run({ nodes });
        return { total: nodes.length, rendered: document.querySelectorAll('.mermaid svg').length };
      });
      if (diagrams.rendered !== diagrams.total) throw new Error(`${vol.id}: chỉ vẽ được ${diagrams.rendered}/${diagrams.total} sơ đồ`);
      await page.evaluate(() => document.fonts.ready);
      const out = join(dist, vol.out);
      await page.pdf({
        path: out,
        format: 'A4',
        printBackground: true,
        displayHeaderFooter: true,
        headerTemplate: '<span></span>',
        footerTemplate: `<div style="font-family:'Noto Sans';font-size:8px;color:#6b7280;width:100%;text-align:center;">${escapeHtml(vol.title)} — <span class="pageNumber"></span>/<span class="totalPages"></span></div>`,
        margin: { top: '18mm', bottom: '20mm', left: '16mm', right: '16mm' },
      });
      console.log(`✔ ${vol.out} (${diagrams.rendered} sơ đồ Mermaid)`);
      await page.close();
    }
  } finally {
    await browser.close();
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
