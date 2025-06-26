// preload.js
const { contextBridge, ipcRenderer } = require('electron');

// 暴露安全的API给渲染进程
contextBridge.exposeInMainWorld('electronAPI', {
  // 获取应用路径
  getAppPath: () => ipcRenderer.invoke('get-app-path'),
  
  // 读取目录
  readDirectory: (dirPath) => ipcRenderer.invoke('read-directory', dirPath),
  
  // 读取文件
  readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),
  
  // 写入文件
  writeFile: (filePath, data) => ipcRenderer.invoke('write-file', filePath, data),
  
  // 打开文件对话框
  openFileDialog: (options) => ipcRenderer.invoke('open-file-dialog', options),
  
  // 打开目录对话框
  openDirectoryDialog: (options) => ipcRenderer.invoke('open-directory-dialog', options),
  
  // 保存文件对话框
  saveFileDialog: (options) => ipcRenderer.invoke('save-file-dialog', options),
  
  // 打开外部链接
  openExternal: (url) => ipcRenderer.invoke('open-external', url),
  
  // 获取系统信息
  getSystemInfo: () => ipcRenderer.invoke('get-system-info'),
  
  // 检查更新
  checkForUpdates: () => ipcRenderer.invoke('check-for-updates'),
  
  // 退出应用
  quitApp: () => ipcRenderer.invoke('quit-app'),
});