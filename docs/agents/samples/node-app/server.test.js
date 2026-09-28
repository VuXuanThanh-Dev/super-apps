const test = require('node:test');
const assert = require('node:assert');
const { handler } = require('./server');
test('health returns ok', () => {
  let status; let body;
  handler({ url: '/health' }, { writeHead: (s) => { status = s; }, end: (b) => { body = b; } });
  assert.strictEqual(status, 200);
  assert.deepStrictEqual(JSON.parse(body), { status: 'ok' });
});
