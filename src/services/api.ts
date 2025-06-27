import type {
  MangaLibrary,
  Manga,
  FileInfo,
  ApiResponse,
  ReadingProgress,
  AppSettings
} from '../types'

// API基础配置
const API_BASE_URL = 'http://localhost:8080/api'
const API_TIMEOUT = 30000

/**
 * HTTP请求客户端
 */
class ApiClient {
  private baseURL: string
  private timeout: number

  constructor(baseURL: string = API_BASE_URL, timeout: number = API_TIMEOUT) {
    this.baseURL = baseURL
    this.timeout = timeout
  }

  /**
   * 发送HTTP请求
   */
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    const url = `${this.baseURL}${endpoint}`
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), this.timeout)

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers
        }
      })

      clearTimeout(timeoutId)

      if (!response.ok) {
        const errorData = await response.json()
        if (errorData && errorData.error === null) {
          return { success: true, data: errorData, message: 'Success' }
        } else {
          throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`)
        }
      }

      const data = await response.json()
      return {
        success: true,
        data,
        message: 'Success'
      }
    } catch (error) {
      clearTimeout(timeoutId)
      
      if (error instanceof Error) {
        if (error.name === 'AbortError') {
          throw new Error('请求超时')
        }
        throw error
      }
      
      throw new Error('未知错误')
    }
  }

  /**
   * GET请求
   */
  async get<T>(endpoint: string, params?: Record<string, any>): Promise<ApiResponse<T>> {
    let url = endpoint
    if (params) {
      const searchParams = new URLSearchParams()
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, String(value))
        }
      })
      url += `?${searchParams.toString()}`
    }
    
    return this.request<T>(url, { method: 'GET' })
  }

  /**
   * POST请求
   */
  async post<T>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined
    })
  }

  /**
   * PUT请求
   */
  async put<T>(endpoint: string, data?: any): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined
    })
  }

  /**
   * DELETE请求
   */
  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    return this.request<T>(endpoint, { method: 'DELETE' })
  }
}

// 创建API客户端实例
const apiClient = new ApiClient()

/**
 * 漫画库相关API
 */
export const libraryApi = {
  /**
   * 获取所有漫画库
   */
  async getLibraries(): Promise<ApiResponse<MangaLibrary[]>> {
    return apiClient.get<MangaLibrary[]>('/libraries')
  },

  /**
   * 创建漫画库
   */
  async createLibrary(library: Omit<MangaLibrary, 'id' | 'createdAt' | 'updatedAt'>): Promise<ApiResponse<MangaLibrary>> {
    return apiClient.post<MangaLibrary>('/libraries', library)
  },

  /**
   * 更新漫画库
   */
  async updateLibrary(id: string, library: Partial<MangaLibrary>): Promise<ApiResponse<MangaLibrary>> {
    return apiClient.put<MangaLibrary>(`/libraries/${id}`, library)
  },

  /**
   * 删除漫画库
   */
  async deleteLibrary(id: string): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/libraries/${id}`)
  },

  /**
   * 扫描漫画库
   */
  async scanLibrary(id: string): Promise<ApiResponse<{ taskId: string }>> {
    return apiClient.post<{ taskId: string }>(`/libraries/${id}/scan`)
  },

  /**
   * 获取扫描状态
   */
  async getScanStatus(taskId: string): Promise<ApiResponse<{ status: string; progress: number; message?: string }>> {
    return apiClient.get<{ status: string; progress: number; message?: string }>(`/scan-status/${taskId}`)
  },

  /**
   * 测试连接
   */
  async testConnection(config: any): Promise<ApiResponse<{ success: boolean; message: string }>> {
    return apiClient.post<{ success: boolean; message: string }>('/libraries/test-connection', config)
  }
}

/**
 * 漫画相关API
 */
export const mangaApi = {
  /**
   * 获取漫画列表
   */
  async getMangas(libraryId?: string, params?: {
    page?: number
    limit?: number
    search?: string
    genre?: string
    status?: string
    sort?: string
  }): Promise<ApiResponse<Manga[]>> {
    const queryParams = { libraryId, ...params }
    return apiClient.get<Manga[]>('/mangas', queryParams)
  },

  /**
   * 获取漫画详情
   */
  async getManga(id: string): Promise<ApiResponse<Manga>> {
    return apiClient.get<Manga>(`/mangas/${id}`)
  },

  /**
   * 更新漫画信息
   */
  async updateManga(id: string, manga: Partial<Manga>): Promise<ApiResponse<Manga>> {
    return apiClient.put<Manga>(`/mangas/${id}`, manga)
  },

  /**
   * 删除漫画
   */
  async deleteManga(id: string): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/mangas/${id}`)
  },

  /**
   * 获取漫画页面
   */
  async getMangaPage(mangaId: string, pageNumber: number, thumbnail: boolean = false): Promise<string> {
    // 返回图片URL，不使用JSON API
    const params = thumbnail ? '?thumbnail=true' : ''
    return `${API_BASE_URL}/mangas/${mangaId}/page/${pageNumber}${params}`
  },

  /**
   * 获取漫画封面
   */
  async getMangaCover(mangaId: string): Promise<string> {
    return `${API_BASE_URL}/mangas/${mangaId}/cover`
  },

  /**
   * 获取漫画缩略图
   */
  async getMangaThumbnail(mangaId: string, pageNumber: number = 0): Promise<string> {
    return `${API_BASE_URL}/mangas/${mangaId}/page/${pageNumber}?thumbnail=true`
  }
}

/**
 * 文件系统相关API
 */
export const fileApi = {
  /**
   * 浏览目录
   */
  async browseDirectory(path: string): Promise<ApiResponse<FileInfo[]>> {
    return apiClient.get<FileInfo[]>('/files/browse', { path })
  },

  /**
   * 获取文件信息
   */
  async getFileInfo(path: string): Promise<ApiResponse<FileInfo>> {
    return apiClient.get<FileInfo>('/files/info', { path })
  },

  /**
   * 检查路径是否存在
   */
  async checkPath(path: string): Promise<ApiResponse<{ exists: boolean; isDirectory: boolean }>> {
    return apiClient.get<{ exists: boolean; isDirectory: boolean }>('/files/check', { path })
  }
}

/**
 * 阅读进度相关API
 */
export const progressApi = {
  /**
   * 获取阅读进度
   */
  async getProgress(mangaId: string): Promise<ApiResponse<ReadingProgress>> {
    return apiClient.get<ReadingProgress>(`/reading-progress/manga/${mangaId}`)
  },

  /**
   * 保存阅读进度
   */
  async saveProgress(mangaId: string, progress: Partial<ReadingProgress>): Promise<ApiResponse<ReadingProgress>> {
    // 先获取现有进度，如果存在则更新，否则创建
    try {
      const existing = await this.getProgress(mangaId)
      if (existing.success && existing.data) {
        return apiClient.put<ReadingProgress>(`/reading-progress/${existing.data.id}`, progress)
      }
    } catch (e) {
      // 如果获取失败，说明不存在，创建新的
    }
    return apiClient.post<ReadingProgress>('/reading-progress', { ...progress, mangaId })
  },

  /**
   * 获取所有阅读进度
   */
  async getAllProgress(): Promise<ApiResponse<ReadingProgress[]>> {
    return apiClient.get<ReadingProgress[]>('/reading-progress')
  },

  /**
   * 删除阅读进度
   */
  async deleteProgress(mangaId: string): Promise<ApiResponse<void>> {
    // 先获取进度ID，然后删除
    try {
      const existing = await this.getProgress(mangaId)
      if (existing.success && existing.data) {
        return apiClient.delete<void>(`/reading-progress/${existing.data.id}`)
      }
      return { success: true, data: undefined, message: 'Progress not found' }
    } catch (e) {
      return { success: false, data: undefined, message: 'Failed to delete progress' }
    }
  }
}

/**
 * 设置相关API
 */
export const settingsApi = {
  /**
   * 获取应用设置
   */
  async getSettings(): Promise<ApiResponse<AppSettings>> {
    return apiClient.get<AppSettings>('/settings')
  },

  /**
   * 保存应用设置
   */
  async saveSettings(settings: Partial<AppSettings>): Promise<ApiResponse<AppSettings>> {
    return apiClient.put<AppSettings>('/settings', settings)
  },

  /**
   * 重置设置
   */
  async resetSettings(): Promise<ApiResponse<AppSettings>> {
    return apiClient.post<AppSettings>('/settings/reset')
  }
}

/**
 * 系统相关API
 */
export const systemApi = {
  /**
   * 获取系统信息
   */
  async getSystemInfo(): Promise<ApiResponse<{
    version: string
    platform: string
    arch: string
    nodeVersion: string
    uptime: number
  }>> {
    return apiClient.get('/system/info')
  },

  /**
   * 检查更新
   */
  async checkUpdate(): Promise<ApiResponse<{
    hasUpdate: boolean
    latestVersion?: string
    downloadUrl?: string
    releaseNotes?: string
  }>> {
    return apiClient.get('/system/check-update')
  },

  /**
   * 获取日志
   */
  async getLogs(level?: string, limit?: number): Promise<ApiResponse<{
    logs: Array<{
      timestamp: string
      level: string
      message: string
      meta?: any
    }>
  }>> {
    return apiClient.get('/system/logs', { level, limit })
  },

  /**
   * 清理缓存
   */
  async clearCache(): Promise<ApiResponse<{ cleared: number; size: number }>> {
    return apiClient.post('/system/clear-cache')
  },

  /**
   * 获取缓存统计
   */
  async getCacheStats(): Promise<ApiResponse<{
    totalSize: number
    itemCount: number
    hitRate: number
  }>> {
    return apiClient.get('/system/cache-stats')
  }
}

/**
 * 搜索相关API
 */
export const searchApi = {
  /**
   * 搜索漫画
   */
  async searchMangas(query: string, options?: {
    libraryId?: string
    limit?: number
    includeContent?: boolean
  }): Promise<ApiResponse<Manga[]>> {
    return apiClient.get('/search/mangas', { query, ...options })
  },

  /**
   * 获取搜索建议
   */
  async getSearchSuggestions(query: string): Promise<ApiResponse<string[]>> {
    return apiClient.get('/search/suggestions', { query })
  },

  /**
   * 获取热门搜索
   */
  async getPopularSearches(): Promise<ApiResponse<string[]>> {
    return apiClient.get('/search/popular')
  }
}

/**
 * 统计相关API
 */
export const statsApi = {
  /**
   * 获取阅读统计
   */
  async getReadingStats(): Promise<ApiResponse<{
    totalMangas: number
    readingMangas: number
    completedMangas: number
    totalPages: number
    readPages: number
    readingTime: number
    averageRating: number
  }>> {
    return apiClient.get('/stats/reading')
  },

  /**
   * 获取库统计
   */
  async getLibraryStats(): Promise<ApiResponse<{
    totalLibraries: number
    totalSize: number
    mangasByGenre: Record<string, number>
    mangasByStatus: Record<string, number>
    recentlyAdded: Manga[]
  }>> {
    return apiClient.get('/stats/library')
  }
}

/**
 * 导入导出相关API
 */
export const importExportApi = {
  /**
   * 导出数据
   */
  async exportData(options: {
    includeLibraries?: boolean
    includeProgress?: boolean
    includeSettings?: boolean
  }): Promise<ApiResponse<{ downloadUrl: string }>> {
    return apiClient.post('/export', options)
  },

  /**
   * 导入数据
   */
  async importData(file: File): Promise<ApiResponse<{
    imported: {
      libraries: number
      mangas: number
      progress: number
    }
  }>> {
    const formData = new FormData()
    formData.append('file', file)
    
    const response = await fetch(`${API_BASE_URL}/import`, {
      method: 'POST',
      body: formData
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    return response.json()
  }
}

// 默认导出所有API
export default {
  library: libraryApi,
  manga: mangaApi,
  file: fileApi,
  progress: progressApi,
  settings: settingsApi,
  system: systemApi,
  search: searchApi,
  stats: statsApi,
  importExport: importExportApi
}