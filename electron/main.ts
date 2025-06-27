import { app, BrowserWindow, ipcMain, dialog } from 'electron'
import { join } from 'path'
import { readdir, stat } from 'fs/promises'

const isDev = process.env.NODE_ENV === 'development'

let mainWindow: BrowserWindow

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: join(__dirname, 'preload.js')
    },
    titleBarStyle: 'hiddenInset',
    show: false
  })

  // 窗口准备好后显示
  mainWindow.once('ready-to-show', () => {
    mainWindow.show()
  })

  if (isDev) {
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    mainWindow.loadFile(join(__dirname, '../dist/index.html'))
  }
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

// IPC 处理器
ipcMain.handle('select-folder', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory']
  })
  return result
})

ipcMain.handle('read-directory', async (_, dirPath: string) => {
  try {
    const files = await readdir(dirPath)
    const fileInfos = await Promise.all(
      files.map(async (file) => {
        const filePath = join(dirPath, file)
        const stats = await stat(filePath)
        return {
          name: file,
          path: filePath,
          isDirectory: stats.isDirectory(),
          size: stats.size,
          modified: stats.mtime
        }
      })
    )
    return fileInfos
  } catch (error) {
    throw error
  }
})

ipcMain.handle('get-app-version', () => {
  return app.getVersion()
})