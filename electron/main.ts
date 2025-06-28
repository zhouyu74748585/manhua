import { app, BrowserWindow, ipcMain, dialog, protocol } from 'electron'
import { join } from 'path'
import { readdir, stat } from 'fs/promises'
import { readFile } from 'fs/promises'
import { extname } from 'path'
import { spawn, ChildProcess } from 'child_process'
import { existsSync } from 'fs'

const isDev = process.env.NODE_ENV === 'development'

let mainWindow: BrowserWindow
let backendProcess: ChildProcess | null = null
const BACKEND_PORT = 8080

function startBackendServer(): Promise<void> {
  return new Promise((resolve, reject) => {
    if (isDev) {
      // 开发模式下，假设后端已经单独启动
      resolve()
      return
    }

    // 查找后端 JAR 文件
    const backendDir = join(__dirname, '../backend/target')
    const jarFiles = existsSync(backendDir) ? 
      require('fs').readdirSync(backendDir).filter((file: string) => file.endsWith('.jar') && !file.includes('sources')) : []
    
    if (jarFiles.length === 0) {
      reject(new Error('未找到后端 JAR 文件'))
      return
    }

    const jarPath = join(backendDir, jarFiles[0])
    console.log('启动后端服务器:', jarPath)

    backendProcess = spawn('java', ['-jar', jarPath, `--server.port=${BACKEND_PORT}`], {
      stdio: ['ignore', 'pipe', 'pipe']
    })

    backendProcess.stdout?.on('data', (data) => {
      console.log('Backend stdout:', data.toString())
    })

    backendProcess.stderr?.on('data', (data) => {
      console.log('Backend stderr:', data.toString())
    })

    backendProcess.on('error', (error) => {
      console.error('后端启动失败:', error)
      reject(error)
    })

    // 等待后端启动
    setTimeout(() => {
      if (backendProcess && !backendProcess.killed) {
        resolve()
      } else {
        reject(new Error('后端启动超时'))
      }
    }, 10000) // 等待10秒
  })
}

function createWindow(): void {
  mainWindow = new BrowserWindow({
    width: 1920,
    height: 1080,
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

  // 在开发模式下加载 Vite 开发服务器
  const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged
  if (isDev) {
    mainWindow.loadURL('http://localhost:5174')
    // 打开开发者工具
    mainWindow.webContents.openDevTools()
  } else {
    // 在生产模式下加载构建后的文件
    mainWindow.loadFile(join(__dirname, '../dist/index.html'))
  }
}

app.whenReady().then(async () => {
  // 注册自定义协议来处理本地文件访问
  protocol.registerFileProtocol('manga-file', (request, callback) => {
    const url = request.url.substr(12) // 移除 'manga-file:' 前缀
    callback({ path: decodeURIComponent(url) })
  })

  try {
    // 启动后端服务器
    await startBackendServer()
    console.log('后端服务器启动成功')
  } catch (error) {
    console.error('后端服务器启动失败:', error)
    // 即使后端启动失败，也继续启动前端
  }

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

app.on('before-quit', () => {
  // 关闭后端进程
  if (backendProcess && !backendProcess.killed) {
    console.log('正在关闭后端服务器...')
    backendProcess.kill('SIGTERM')
    
    // 如果进程没有正常关闭，强制杀死
    setTimeout(() => {
      if (backendProcess && !backendProcess.killed) {
        backendProcess.kill('SIGKILL')
      }
    }, 5000)
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

// 获取漫画页面图片
ipcMain.handle('get-manga-page', async (_, mangaPath: string, pageNumber: number) => {
  try {
    const files = await readdir(mangaPath)
    // 过滤图片文件并排序
    const imageFiles = files
      .filter(file => {
        const ext = extname(file).toLowerCase()
        return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].includes(ext)
      })
      .sort((a, b) => {
        // 自然排序，处理数字
        return a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' })
      })
    
    if (pageNumber > 0 && pageNumber <= imageFiles.length) {
      const imagePath = join(mangaPath, imageFiles[pageNumber - 1])
      return `manga-file://${imagePath}`
    }
    
    throw new Error(`页面 ${pageNumber} 不存在`)
  } catch (error) {
    throw error
  }
})

// 获取漫画总页数
ipcMain.handle('get-manga-page-count', async (_, mangaPath: string) => {
  try {
    const files = await readdir(mangaPath)
    const imageFiles = files.filter(file => {
      const ext = extname(file).toLowerCase()
      return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].includes(ext)
    })
    return imageFiles.length
  } catch (error) {
    throw error
  }
})