const http = require('node:http');
const port = process.env.PORT || 3000;
function handler(req, res) {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ status: 'ok' }));
  }
  res.writeHead(404);
  res.end();
}
if (require.main === module) {
  http.createServer(handler).listen(port, () => console.log(`listening on ${port}`));
}
module.exports = { handler };
