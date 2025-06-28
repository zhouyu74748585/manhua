// 漫画库类型
export interface MangaLibrary {
  id: string
  name: string
  path: string
  mangaCount: number
  type: 'LOCAL' | 'SMB' | 'FTP' | 'WEBDAV' | 'NFS'
  description?: string
  isPrivate: boolean
  isActive?: boolean // 是否激活
  accessPassword?: string // 隐私库访问密码
  password?: string // 网络文件系统密码
  username?: string // 网络文件系统用户名
  host?: string // 网络文件系统主机
  port?: number // 网络文件系统端口
  shareName?: string // SMB共享名
  autoScan?: boolean // 自动扫描
  scanInterval?: number // 扫描间隔
  config?: LibraryConfig
  currentStatus?: string // 当前状态：空闲、扫描中、错误等
  createdAt: Date
  updatedAt: Date
  oldPassword?: string // 用于更新时验证的旧密码
}

// 漫画库配置
export interface LibraryConfig {
  // SMB配置
  smbConfig?: {
    host: string
    username: string
    password: string
    domain?: string
    port?: number
  }
  // FTP配置
  ftpConfig?: {
    host: string
    port: number
    username: string
    password: string
    secure?: boolean
  }
  // WebDAV配置
  webdavConfig?: {
    url: string
    username: string
    password: string
  }
  // NFS配置
  nfsConfig?: {
    host: string
    path: string
    version?: number
  }
}

// 漫画类型
export interface Manga {
  id: string
  title: string
  author?: string
  libraryId: string
  path: string
  coverImage?: string
  totalPages: number
  currentPage: number
  tags: string[]
  rating?: number
  status: 'UNREAD' | 'READING' | 'COMPLETED'
  series?: string
  volume?: number
  chapter?: number
  description?: string
  createdAt: Date
  updatedAt: Date
  lastReadAt?: Date
}

// 阅读进度
export interface ReadingProgress {
  id?: string
  mangaId: string
  currentPage: number
  totalPages: number
  lastReadAt: Date
  readingTime: number // 阅读时长（秒）
}

// 阅读设置
export interface ReaderSettings {
  readingMode: 'single' | 'double' | 'continuous'
  readingDirection: 'ltr' | 'rtl' // left-to-right or right-to-left
  fitMode: 'width' | 'height' | 'original'
  backgroundColor: string
  autoHideUI: boolean
  preloadPages: number
  enableZoom: boolean
  enableFullscreen: boolean
}

// 应用设置
export interface AppSettings {
  theme: 'light' | 'dark' | 'auto'
  language: 'zh-CN' | 'en-US'
  cacheSize: number // MB
  autoScan: boolean
  checkUpdates: boolean
  readerSettings: ReaderSettings
}

// 文件信息
export interface FileInfo {
  name: string
  path: string
  isDirectory: boolean
  size: number
  modified: Date
  extension?: string
}

// 缓存项
export interface CacheItem {
  id: string
  mangaId: string
  pageNumber: number
  filePath: string
  cachedPath: string
  size: number
  createdAt: Date
  lastAccessAt: Date
}

// API响应类型
export interface ApiResponse<T = any> {
  success: boolean
  data?: T
  message?: string
  error?: string
}

// 筛选选项
export interface FilterOptions {
  libraryId?: string
  status?: Manga['status']
  tags?: string[]
  rating?: number
  searchText?: string
}

// 排序选项
export interface SortOptions {
  field: 'title' | 'author' | 'createdAt' | 'lastReadAt' | 'rating'
  order: 'asc' | 'desc'
}

// 隐私模式配置
export interface PrivacyConfig {
  enabled: boolean
  passwordHash?: string
  biometricEnabled: boolean
  sessionTimeout: number // 分钟
}

// 系列信息
export interface Series {
  id: string
  name: string
  mangas: Manga[]
  totalVolumes: number
  coverPath?: string
  description?: string
  tags: string[]
  author?: string
  status: 'ongoing' | 'completed' | 'hiatus'
}

// 标签
export interface Tag {
  id: string
  name: string
  color?: string
  count: number
}

// 阅读历史
export interface ReadingHistory {
  id: string
  mangaId: string
  pageNumber: number
  timestamp: Date
  duration: number // 阅读时长（秒）
}

// Electron API类型声明
declare global {
  interface Window {
    electronAPI?: {
      selectFolder: () => Promise<{
        canceled: boolean
        filePaths: string[]
      }>
    }
  }
}