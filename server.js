// 简易热更新开发服务器 - 文件修改后自动刷新浏览器
// 使用方法: node server.js
// 然后访问 http://localhost:3000

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const WATCH_FILE = path.join(__dirname, 'index.html');

// 注入到HTML中的热更新脚本
const LIVE_RELOAD_SCRIPT = `
<script>
(function(){
  var ws = new WebSocket('ws://localhost:${PORT}/__live_reload');
  ws.onmessage = function(e){
    if(e.data === 'reload'){
      console.log('🔄 检测到文件变更，正在刷新页面...');
      location.reload();
    }
  };
  ws.onclose = function(){
    console.log('热更新连接断开，5秒后重试...');
    setTimeout(function(){location.reload();}, 5000);
  };
})();
</script>`;

const server = http.createServer((req, res) => {
  // WebSocket upgrade
  if (req.headers.upgrade && req.headers.upgrade.toLowerCase() === 'websocket') {
    return;
  }

  if (req.url === '/' || req.url === '/index.html' || req.url === '/infinite-rpg.html') {
    let html = fs.readFileSync(WATCH_FILE, 'utf-8');
    html = html.replace('</body>', LIVE_RELOAD_SCRIPT + '\n</body>');
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
    return;
  }

  res.writeHead(404);
  res.end('Not Found');
});

// WebSocket 服务器用于热更新通知
const { Server: WebSocketServer } = require('ws') || {};
let wss;
try {
  const WS = require('ws');
  wss = new WS.Server({ server });
} catch (e) {
  // ws 模块未安装，使用简化版
  console.log('提示: 安装 ws 模块可获得更好的热更新体验: npm install ws');
}

server.on('upgrade', (req, socket, head) => {
  if (!wss) { socket.destroy(); return; }
  wss.handleUpgrade(req, socket, head, (ws) => {
    wss.emit('connection', ws, req);
  });
});

// 监听文件变更
let lastMtime = fs.statSync(WATCH_FILE).mtimeMs;
fs.watchFile(WATCH_FILE, { interval: 500 }, (curr) => {
  if (curr.mtimeMs !== lastMtime) {
    lastMtime = curr.mtimeMs;
    console.log(`[${new Date().toLocaleTimeString()}] 📝 文件已变更，通知浏览器刷新...`);
    if (wss) {
      wss.clients.forEach(client => {
        if (client.readyState === 1) client.send('reload');
      });
    }
  }
});

server.listen(PORT, () => {
  console.log(`
╔══════════════════════════════════════════╗
║   🎮 无限流RPG - 开发服务器已启动      ║
║   地址: http://localhost:${PORT}           ║
║   修改文件后浏览器自动刷新 ✨           ║
║   按 Ctrl+C 停止服务器                 ║
╚══════════════════════════════════════════╝
  `);
});