// Pi Jarvis — desktop app window (Electron). Wraps the containerized chat UI
// at http://127.0.0.1:8799, started automatically via the podman launcher.
const { app, BrowserWindow, shell } = require("electron");
const URL = process.env.JARVIS_URL || "http://127.0.0.1:8799";

function createWindow() {
  const win = new BrowserWindow({
    width: 1100,
    height: 760,
    minWidth: 640,
    minHeight: 480,
    title: "Pi Jarvis",
    backgroundColor: "#0d1117",
    autoHideMenuBar: true,
    webPreferences: { contextIsolation: true, nodeIntegration: false },
  });

  win.loadURL(URL);

  // open external links in the real browser, keep the app window for the chat
  win.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith(URL)) return { action: "allow" };
    shell.openExternal(url);
    return { action: "deny" };
  });
}

app.whenReady().then(() => {
  createWindow();
  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on("window-all-closed", () => app.quit());
