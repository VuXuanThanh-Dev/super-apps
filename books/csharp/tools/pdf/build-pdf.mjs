// Usage: node build-pdf.mjs <input.html> <output.pdf> "<footer title>"
// Opens the pandoc HTML in Chromium, renders Mermaid diagrams, opens <details>, prints to PDF.
import { chromium } from 'playwright';
import { pathToFileURL, fileURLToPath } from 'node:url';
import path from 'node:path';

const [input, output, footerTitle = ''] = process.argv.slice(2);
if (!input || !output) { console.error('usage: build-pdf.mjs in.html out.pdf [title]'); process.exit(2); }
const here = path.dirname(fileURLToPath(import.meta.url));

const browser = await chromium.launch();
const page = await browser.newPage();
page.on('pageerror', e => console.error('page error:', e.message));
await page.goto(pathToFileURL(path.resolve(input)).href, { waitUntil: 'load' });

// Mermaid: pandoc emits <pre class="mermaid"><code>...</code></pre>; mermaid needs the raw text.
await page.addScriptTag({ path: path.join(here, 'node_modules/mermaid/dist/mermaid.min.js') });
const diagrams = await page.evaluate(async () => {
  const blocks = [...document.querySelectorAll('pre.mermaid')];
  const mermaid = window.mermaid;
  mermaid.initialize({ startOnLoad: false, theme: 'neutral', fontFamily: 'Noto Sans', securityLevel: 'loose' });
  let ok = 0;
  for (const [i, pre] of blocks.entries()) {
    const text = pre.textContent;
    try {
      const { svg } = await mermaid.render(`mmd-${i}`, text);
      const div = document.createElement('div');
      div.className = 'mermaid-rendered';
      div.innerHTML = svg;
      pre.replaceWith(div);
      ok++;
    } catch (e) {
      console.error('mermaid failed', i, e?.message);
    }
  }
  document.querySelectorAll('details').forEach(d => d.open = true);
  await document.fonts.ready;
  return { total: blocks.length, ok };
});

await page.pdf({
  path: output,
  format: 'A4',
  printBackground: true,
  displayHeaderFooter: true,
  headerTemplate: '<span></span>',
  footerTemplate: `<div style="font-family:'Noto Sans';font-size:8px;width:100%;padding:0 16mm;display:flex;justify-content:space-between;color:#666">
      <span>${footerTitle}</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`,
  margin: { top: '16mm', bottom: '18mm', left: '14mm', right: '14mm' },
});
await browser.close();
console.log(`${output}: mermaid diagrams rendered ${diagrams.ok}/${diagrams.total}`);
if (diagrams.ok !== diagrams.total) process.exit(1);
