// Render a pandoc-generated HTML file to PDF with Playwright Chromium.
// Usage: NODE_PATH=$(npm root -g) node render.cjs input.html output.pdf "Footer title"
// Mermaid code blocks (<pre class="mermaid">) are turned into SVG diagrams before printing;
// the script fails if any diagram does not render.
const path = require('path');
const { chromium } = require('playwright');

(async () => {
  const [input, output, title = ''] = process.argv.slice(2);
  const browser = await chromium.launch();
  const page = await browser.newPage();
  page.on('pageerror', (e) => console.error('page error:', e.message));
  await page.goto('file://' + path.resolve(input), { waitUntil: 'load' });
  const diagrams = await page.evaluate(async () => {
    const blocks = Array.from(document.querySelectorAll('pre.mermaid'));
    const errors = [];
    let rendered = 0;
    for (let i = 0; i < blocks.length; i++) {
      const pre = blocks[i];
      const src = pre.textContent;
      try {
        // eslint-disable-next-line no-undef
        const { svg } = await mermaid.render('mmd' + i, src);
        const div = document.createElement('div');
        div.className = 'mermaid';
        div.innerHTML = svg;
        pre.replaceWith(div);
        rendered++;
      } catch (e) {
        errors.push(String(e && (e.message || e.str) || e) + ' :: ' + src.slice(0, 80));
      }
    }
    return { found: blocks.length, rendered, errors };
  });
  for (const e of diagrams.errors || []) console.error('mermaid error:', e);
  if (diagrams.found !== diagrams.rendered) {
    console.error(`mermaid: ${diagrams.rendered}/${diagrams.found} diagrams rendered`);
    process.exit(1);
  }
  await page.evaluate(() => document.fonts.ready);
  const footer = `<div style="font-family:'Noto Sans';font-size:7.5pt;color:#666;width:100%;padding:0 14mm;display:flex;justify-content:space-between;">
    <span>${title}</span><span><span class="pageNumber"></span> / <span class="totalPages"></span></span></div>`;
  await page.pdf({
    path: output, format: 'A4', printBackground: true, displayHeaderFooter: true,
    headerTemplate: '<div></div>', footerTemplate: footer,
    margin: { top: '16mm', bottom: '18mm', left: '14mm', right: '14mm' },
  });
  await browser.close();
  console.log(`${output}: mermaid diagrams ${diagrams.rendered}/${diagrams.found}`);
})().catch((e) => { console.error(e); process.exit(1); });
