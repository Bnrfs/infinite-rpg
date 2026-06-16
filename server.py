# 简易热更新开发服务器 (Python版)
# 使用方法: python server.py
# 访问 http://localhost:3000
# 修改文件后浏览器自动刷新

import http.server
import socketserver
import os
import time
import threading
import asyncio
import json
import sys
import io
from urllib.parse import urlparse

# 修复Windows控制台编码问题
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

PORT = 3000
WATCH_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'index.html')

LIVE_RELOAD_SCRIPT = f"""
<script>
(function(){{
  var lastCheck = Date.now();
  setInterval(function(){{
    fetch('/__check_update?t=' + Date.now())
      .then(function(r){{ return r.json(); }})
      .then(function(d){{
        if(d.updated && d.mtime > lastCheck){{
          lastCheck = d.mtime;
          console.log('🔄 检测到文件变更，正在刷新页面...');
          location.reload();
        }}
      }});
  }}, 1000);
}})();
</script>
"""

last_mtime = os.path.getmtime(WATCH_FILE)

class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        global last_mtime
        parsed = urlparse(self.path)
        path = parsed.path
        
        if path == '/__check_update':
            current_mtime = os.path.getmtime(WATCH_FILE)
            updated = current_mtime > last_mtime
            if updated:
                last_mtime = current_mtime
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({'updated': updated, 'mtime': current_mtime}).encode())
            return
        
        if path in ['/', '/index.html', '/infinite-rpg.html']:
            with open(WATCH_FILE, 'r', encoding='utf-8') as f:
                html = f.read()
            html = html.replace('</body>', LIVE_RELOAD_SCRIPT + '\n</body>')
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write(html.encode('utf-8'))
            return
        
        super().do_GET()
    
    def log_message(self, format, *args):
        pass  # 静默模式

print(f"""
==========================================
  无限流RPG - 开发服务器已启动
  地址: http://localhost:{PORT}
  修改文件后浏览器自动刷新
  按 Ctrl+C 停止服务器
==========================================
""")

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n服务器已停止")