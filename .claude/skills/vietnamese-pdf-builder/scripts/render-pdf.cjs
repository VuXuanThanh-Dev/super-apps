#!/usr/bin/env node
// Print a standalone HTML file to PDF with Playwright Chromium.
// Usage: node render-pdf.cjs <input.html> <output.pdf> [title]
// Needs the `playwright` package (global or local) and a Chromium that matches it
// (PLAYWRIGHT_BROWSERS_PATH). Mermaid blocks (<pre class="mermaid">) are rendered to SVG
// before printing when MERMAID_JS points to mermaid.min.js.
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

async function main() {
  const [input, output, title = ''] = process.argv.slice(2);
  if (!input || !output) {
    console.error('usage: render-pdf.cjs <input.html> <output.pdf> [title]');
    process.exit(2);
  }
  const browser = await chromium.launch();
  const page = await browser.newPage();
  page.on('console', (m) => { if (m.type() === 'error') console.error('[page]', m.text()); });
  await page.goto('file://' + path.resolve(input), { waitUntil: 'load' });

  const hasMermaid = await page.locator('pre.mermaid').count();
  if (hasMermaid) {
    const js = process.env.MERMAID_JS;
    if (!js || !fs.existsSync(js)) {
      console.error(`ERROR: ${hasMermaid} mermaid block(s) found but MERMAID_JS is not set to mermaid.min.js`);
      await browser.close();
      process.exit(3);
    }
    await page.addScriptTag({ path: js });
    const errors = await page.evaluate(async () => {
      // pandoc writes <pre class="mermaid"><code>...</code></pre>; mermaid wants plain text.
      document.querySelectorAll('pre.mermaid').forEach((el) => { el.textContent = el.textContent; });
      window.mermaid.initialize({ startOnLoad: false, theme: 'neutral',
        fontFamily: '"Noto Sans", sans-serif', securityLevel: 'strict' });
      try { await window.mermaid.run({ querySelector: 'pre.mermaid' }); return []; }
      catch (e) { return [String(e)]; }
    });
    if (errors.length) { console.error('ERROR: mermaid:', errors.join('\n')); await browser.close(); process.exit(4); }
    const svgs = await page.locator('pre.mermaid svg').count();
    console.log(`mermaid: ${svgs}/${hasMermaid} diagram(s) rendered to SVG`);
  }
  await page.evaluate(() => document.fonts.ready);
  await page.pdf({
    path: output, format: 'A4', printBackground: true, preferCSSPageSize: true,
    displayHeaderFooter: true,
    headerTemplate: `<div style="font-size:8px;width:100%;text-align:center;font-family:'Noto Sans'">${title.replace(/</g, '&lt;')}</div>`,
    footerTemplate: '<div style="font-size:8px;width:100%;text-align:center;font-family:\'Noto Sans\'"><span class="pageNumber"></span> / <span class="totalPages"></span></div>',
  });
  await browser.close();
  console.log('pdf:', output);
}
main().catch((e) => { console.error(e); process.exit(1); });
