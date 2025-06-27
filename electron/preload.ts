import { contextBridge, ipcRenderer } from 'electron'

// 定义API接口
interface ElectronAPI {
  selectFolder: () => Promise<Electron.OpenDialogReturnValue>
  readDirectory: (dirPath: string) => Promise<FileInfo[]>
  getAppVersion: () => Promise<string>
}

interface FileInfo {
  name: string
  path: string
  isDirectory: boolean
  size: number
  modified: Date
}

// 暴露安全的API给渲染进程
const electronAPI: ElectronAPI = {
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  readDirectory: (dirPath: string) => ipcRenderer.invoke('read-directory', dirPath),
  getAppVersion: () => ipcRenderer.invoke('get-app-version')
}

contextBridge.exposeInMainWorld('electronAPI', electronAPI)

// 类型声明
declare global {
  interface Window {
    electronAPI: ElectronAPI
  }
}