#!/usr/bin/env node
/* Pi Jarvis web chat — zero-dependency local server bridging the browser to `pi`. */
const http = require("http");
const fs = require("fs");
const path = require("path");


const PORT = process.env.PORT || 8799;
const CFG = process.env.PI_CODING_AGENT_DIR || "/home/jarvis/.pi-jarvis";
const INDEX = path.join(__dirname, "index.html");

function hasSession() {
  try {
    const dir = path.join(CFG, "sessions");
    const files = fs.readdirSync(dir, { recursive: true });
    return files.some((f) => String(f).endsWith(".jsonl"));
  } catch {
    return false;
  }
}

const { exec } = require("child_process");
const shq = (s) => "'" + String(s).replace(/'/g, "'\\''") + "'";

function chat(message, cb) {
  // pi hangs when spawned with piped stdio by node; wrapping in sh with
  // stdin from /dev/null avoids that (verified: 3s vs indefinite hang)
  const cont = hasSession() ? "--continue" : "";
  const cmd = `pi -p ${shq(String(message).slice(0, 8000))} ${cont} < /dev/null 2>/dev/null`;
  exec(cmd, { timeout: 300000, maxBuffer: 10 * 1024 * 1024 }, (err, stdout) => {
    if (err && !stdout) return cb({ error: (err.message || "pi failed").trim() });
    cb(null, String(stdout).trim());
  });
}

http
  .createServer((req, res) => {
    if (req.method === "POST" && req.url === "/api/chat") {
      let body = "";
      req.on("data", (c) => (body += c));
      req.on("end", () => {
        let message;
        try {
          message = JSON.parse(body).message;
        } catch {}
        if (!message) return send(res, 400, { error: "empty message" });
        chat(message, (err, reply) => (err ? send(res, 500, err) : send(res, 200, { reply })));
      });
      return;
    }
    if (req.method === "GET" && (req.url === "/" || req.url === "/index.html")) {
      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
      res.end(fs.readFileSync(INDEX));
      return;
    }
    res.writeHead(404);
    res.end();
  })
  .listen(PORT, "0.0.0.0", () => console.log(`Pi Jarvis UI → http://localhost:${PORT}`));

function send(res, code, obj) {
  res.writeHead(code, { "Content-Type": "application/json; charset=utf-8" });
  res.end(JSON.stringify(obj));
}
