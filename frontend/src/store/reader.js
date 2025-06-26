import { defineStore } from 'pinia'
import { useBookshelfStore } from './bookshelf'

// 阅读器状态管理
export const useReaderStore = defineStore('reader', {
  // 状态
  state: () => ({
    currentComicId: null, // 当前阅读的漫画ID
    currentPage: 0, // 当前页码
    totalPages: 0, // 总页数
    pages: [], // 页面列表
    isLoading: false, // 加载状态
    error: null, // 错误信息
    readingMode: 'single', // 阅读模式：single(单页)、double(双页)、continuous(连续滚动)
    zoomLevel: 100, // 缩放级别（百分比）
    isFullscreen: false, // 是否全屏
    showUI: true, // 是否显示UI控件
    preloadCount: 3, // 预加载页数
  }),
  
  // 计算属性
  getters: {
    // 当前漫画信息
    currentComic() {
      const bookshelfStore = useBookshelfStore()
      return bookshelfStore.getComicById(this.currentComicId)
    },
    
    // 当前页面
    currentPageData() {
      return this.pages[this.currentPage] || null
    },
    
    // 阅读进度百分比
    progressPercentage() {
      if (this.totalPages === 0) return 0
      return Math.round((this.currentPage + 1) / this.totalPages * 100)
    },
    
    // 是否有上一页
    hasPreviousPage() {
      return this.currentPage > 0
    },
    
    // 是否有下一页
    hasNextPage() {
      return this.currentPage < this.totalPages - 1
    },
    
    // 预加载的页面索引列表
    preloadPageIndices() {
      const indices = []
      
      // 预加载后面的页面
      for (let i = 1; i <= this.preloadCount; i++) {
        const index = this.currentPage + i
        if (index < this.totalPages) {
          indices.push(index)
        }
      }
      
      // 预加载前面的页面（优先级较低）
      for (let i = 1; i <= Math.min(2, this.preloadCount); i++) {
        const index = this.currentPage - i
        if (index >= 0) {
          indices.push(index)
        }
      }
      
      return indices
    },
  },
  
  // 动作
  actions: {
    // 加载漫画
    async loadComic(comicId) {
      this.isLoading = true
      this.error = null
      this.currentComicId = comicId
      this.pages = []
      
      try {
        // 调用后端API获取漫画页面
        const response = await fetch(`/api/comics/${comicId}/pages`)
        const data = await response.json()
        
        this.pages = data.pages
        this.totalPages = data.pages.length
        
        // 获取上次阅读进度
        const bookshelfStore = useBookshelfStore()
        const comic = bookshelfStore.getComicById(comicId)
        
        if (comic && comic.readingProgress > 0) {
          // 根据阅读进度计算页码
          const pageIndex = Math.floor(comic.readingProgress / 100 * this.totalPages)
          this.currentPage = Math.min(pageIndex, this.totalPages - 1)
        } else {
          // 新漫画从第一页开始
          this.currentPage = 0
        }
        
        // 预加载图片
        this.preloadImages()
        
        return true
      } catch (error) {
        console.error(`加载漫画 ${comicId} 失败:`, error)
        this.error = '加载漫画失败'
        return false
      } finally {
        this.isLoading = false
      }
    },
    
    // 跳转到指定页面
    goToPage(pageIndex) {
      if (pageIndex >= 0 && pageIndex < this.totalPages) {
        this.currentPage = pageIndex
        this.updateReadingProgress()
        this.preloadImages()
      }
    },
    
    // 上一页
    previousPage() {
      if (this.hasPreviousPage) {
        this.currentPage--
        this.updateReadingProgress()
        this.preloadImages()
      }
    },
    
    // 下一页
    nextPage() {
      if (this.hasNextPage) {
        this.currentPage++
        this.updateReadingProgress()
        this.preloadImages()
      }
    },
    
    // 第一页
    firstPage() {
      this.currentPage = 0
      this.updateReadingProgress()
      this.preloadImages()
    },
    
    // 最后一页
    lastPage() {
      this.currentPage = this.totalPages - 1
      this.updateReadingProgress()
      this.preloadImages()
    },
    
    // 更新阅读进度
    updateReadingProgress() {
      if (!this.currentComicId || this.totalPages === 0) return
      
      const progress = this.progressPercentage
      const bookshelfStore = useBookshelfStore()
      
      // 更新阅读进度
      bookshelfStore.updateReadingProgress(this.currentComicId, progress)
    },
    
    // 预加载图片
    preloadImages() {
      // 获取需要预加载的页面索引
      const indices = this.preloadPageIndices
      
      // 预加载图片
      indices.forEach(index => {
        const page = this.pages[index]
        if (page && page.url) {
          const img = new Image()
          img.src = page.url
        }
      })
    },
    
    // 设置阅读模式
    setReadingMode(mode) {
      this.readingMode = mode
      // 保存到本地存储
      localStorage.setItem('readingMode', mode)
    },
    
    // 设置缩放级别
    setZoomLevel(level) {
      this.zoomLevel = level
    },
    
    // 切换全屏
    toggleFullscreen() {
      this.isFullscreen = !this.isFullscreen
      
      if (this.isFullscreen) {
        // 进入全屏
        const element = document.documentElement
        if (element.requestFullscreen) {
          element.requestFullscreen()
        } else if (element.mozRequestFullScreen) {
          element.mozRequestFullScreen()
        } else if (element.webkitRequestFullscreen) {
          element.webkitRequestFullscreen()
        } else if (element.msRequestFullscreen) {
          element.msRequestFullscreen()
        }
      } else {
        // 退出全屏
        if (document.exitFullscreen) {
          document.exitFullscreen()
        } else if (document.mozCancelFullScreen) {
          document.mozCancelFullScreen()
        } else if (document.webkitExitFullscreen) {
          document.webkitExitFullscreen()
        } else if (document.msExitFullscreen) {
          document.msExitFullscreen()
        }
      }
    },
    
    // 切换UI显示
    toggleUI() {
      this.showUI = !this.showUI
    },
    
    // 设置预加载页数
    setPreloadCount(count) {
      this.preloadCount = count
      // 保存到本地存储
      localStorage.setItem('preloadCount', count.toString())
    },
    
    // 初始化阅读器设置
    initReaderSettings() {
      // 从本地存储中获取阅读模式
      const savedMode = localStorage.getItem('readingMode')
      if (savedMode) {
        this.readingMode = savedMode
      }
      
      // 从本地存储中获取预加载页数
      const savedPreloadCount = localStorage.getItem('preloadCount')
      if (savedPreloadCount) {
        this.preloadCount = parseInt(savedPreloadCount, 10)
      }
    },
  }
})