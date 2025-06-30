import { contextBridge, ipcRenderer } from 'electron'

interface FileInfo {
  name: string
  path: string
  isDirectory: boolean
  size: number
  modified: Date
}

// 定义API接口
interface ElectronAPI {
  selectFolder: () => Promise<Electron.OpenDialogReturnValue>
  readDirectory: (dirPath: string) => Promise<FileInfo[]>
  getAppVersion: () => Promise<string>
  getMangaPage: (mangaPath: string, pageNumber: number) => Promise<string>
  getMangaPageCount: (mangaPath: string) => Promise<number>
}

// 暴露安全的API给渲染进程
const electronAPI: ElectronAPI = {
  selectFolder: () => ipcRenderer.invoke('select-folder'),
  readDirectory: (dirPath: string) => ipcRenderer.invoke('read-directory', dirPath),
  getAppVersion: () => ipcRenderer.invoke('get-app-version'),
  getMangaPage: (mangaPath: string, pageNumber: number) => ipcRenderer.invoke('get-manga-page', mangaPath, pageNumber),
  getMangaPageCount: (mangaPath: string) => ipcRenderer.invoke('get-manga-page-count', mangaPath)
}

contextBridge.exposeInMainWorld('electronAPI', electronAPI)

// 类型声明
declare global {
  interface Window {
    electronAPI: ElectronAPI
  }
}