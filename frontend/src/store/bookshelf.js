import { defineStore } from 'pinia'
import { usePrivacyStore } from './privacy'

// 书架状态管理
export const useBookshelfStore = defineStore('bookshelf', {
  // 状态
  state: () => ({
    comics: [], // 所有漫画
    filteredComics: [], // 筛选后的漫画
    currentComic: null, // 当前选中的漫画
    isLoading: false, // 加载状态
    error: null, // 错误信息
    sortBy: 'name', // 排序方式：name(名称)、lastRead(最近阅读)、addTime(添加时间)
    sortOrder: 'asc', // 排序顺序：asc(升序)、desc(降序)
    filters: {
      library: null, // 按漫画库筛选
      tags: [], // 按标签筛选
      categories: [], // 按分类筛选
      readStatus: null, // 按阅读状态筛选：null(全部)、unread(未读)、reading(阅读中)、finished(已读完)
    },
    searchQuery: '', // 搜索关键词
  }),
  
  // 计算属性
  getters: {
    // 获取所有可见的漫画（根据隐私设置）
    visibleComics: (state) => {
      const privacyStore = usePrivacyStore()
      
      // 如果已授权访问隐私内容，则显示所有漫画
      if (privacyStore.isPrivacyModeAuthorized) {
        return state.comics
      }
      
      // 否则只显示非隐私漫画
      return state.comics.filter(comic => {
        // 检查漫画本身是否为隐私漫画
        if (privacyStore.isPrivacyBook(comic.id)) {
          return false
        }
        
        // 检查漫画所属的漫画库是否为隐私库
        if (comic.libraryId && privacyStore.isPrivacyLibrary(comic.libraryId)) {
          return false
        }
        
        return true
      })
    },
    
    // 获取指定ID的漫画
    getComicById: (state) => (id) => {
      return state.comics.find(comic => comic.id === id) || null
    },
    
    // 获取同一系列的漫画
    getComicsBySeries: (state) => (seriesId) => {
      return state.comics.filter(comic => comic.seriesId === seriesId)
    },
  },
  
  // 动作
  actions: {
    // 获取所有漫画
    async fetchAllComics() {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API获取所有漫画
        const response = await fetch('/api/comics')
        const data = await response.json()
        
        this.comics = data
        this.applyFiltersAndSort() // 应用筛选和排序
      } catch (error) {
        console.error('获取漫画列表失败:', error)
        this.error = '获取漫画列表失败'
      } finally {
        this.isLoading = false
      }
    },
    
    // 获取指定ID的漫画详情
    async fetchComicById(id) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API获取漫画详情
        const response = await fetch(`/api/comics/${id}`)
        const data = await response.json()
        
        // 更新当前选中的漫画
        this.currentComic = data
        
        // 同时更新comics中的对应项
        const index = this.comics.findIndex(comic => comic.id === id)
        if (index !== -1) {
          this.comics[index] = data
        } else {
          this.comics.push(data)
        }
        
        return data
      } catch (error) {
        console.error(`获取漫画 ${id} 详情失败:`, error)
        this.error = `获取漫画详情失败`
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 更新漫画信息
    async updateComic(id, comicData) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API更新漫画信息
        const response = await fetch(`/api/comics/${id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(comicData),
        })
        
        const data = await response.json()
        
        // 更新漫画列表中的对应项
        const index = this.comics.findIndex(comic => comic.id === id)
        if (index !== -1) {
          this.comics[index] = data
        }
        
        // 如果当前选中的是这个漫画，也更新currentComic
        if (this.currentComic && this.currentComic.id === id) {
          this.currentComic = data
        }
        
        // 重新应用筛选和排序
        this.applyFiltersAndSort()
        
        return data
      } catch (error) {
        console.error(`更新漫画 ${id} 失败:`, error)
        this.error = '更新漫画失败'
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 删除漫画
    async deleteComic(id) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API删除漫画
        await fetch(`/api/comics/${id}`, {
          method: 'DELETE',
        })
        
        // 从漫画列表中移除
        this.comics = this.comics.filter(comic => comic.id !== id)
        
        // 如果当前选中的是这个漫画，清空currentComic
        if (this.currentComic && this.currentComic.id === id) {
          this.currentComic = null
        }
        
        // 重新应用筛选和排序
        this.applyFiltersAndSort()
        
        return true
      } catch (error) {
        console.error(`删除漫画 ${id} 失败:`, error)
        this.error = '删除漫画失败'
        return false
      } finally {
        this.isLoading = false
      }
    },
    
    // 更新阅读进度
    async updateReadingProgress(id, progress) {
      try {
        // 调用后端API更新阅读进度
        const response = await fetch(`/api/comics/${id}/progress`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ progress }),
        })
        
        const data = await response.json()
        
        // 更新漫画列表中的对应项
        const index = this.comics.findIndex(comic => comic.id === id)
        if (index !== -1) {
          this.comics[index].readingProgress = progress
          this.comics[index].lastReadTime = new Date().toISOString()
        }
        
        // 如果当前选中的是这个漫画，也更新currentComic
        if (this.currentComic && this.currentComic.id === id) {
          this.currentComic.readingProgress = progress
          this.currentComic.lastReadTime = new Date().toISOString()
        }
        
        return data
      } catch (error) {
        console.error(`更新漫画 ${id} 阅读进度失败:`, error)
        return null
      }
    },
    
    // 设置排序方式
    setSortBy(sortBy) {
      this.sortBy = sortBy
      this.applyFiltersAndSort()
    },
    
    // 设置排序顺序
    setSortOrder(sortOrder) {
      this.sortOrder = sortOrder
      this.applyFiltersAndSort()
    },
    
    // 设置筛选条件
    setFilters(filters) {
      this.filters = { ...this.filters, ...filters }
      this.applyFiltersAndSort()
    },
    
    // 设置搜索关键词
    setSearchQuery(query) {
      this.searchQuery = query
      this.applyFiltersAndSort()
    },
    
    // 应用筛选和排序
    applyFiltersAndSort() {
      // 首先获取可见的漫画
      let result = [...this.visibleComics]
      
      // 应用搜索
      if (this.searchQuery) {
        const query = this.searchQuery.toLowerCase()
        result = result.filter(comic => {
          return (
            comic.name.toLowerCase().includes(query) ||
            (comic.author && comic.author.toLowerCase().includes(query)) ||
            (comic.tags && comic.tags.some(tag => tag.toLowerCase().includes(query)))
          )
        })
      }
      
      // 应用筛选
      if (this.filters.library) {
        result = result.filter(comic => comic.libraryId === this.filters.library)
      }
      
      if (this.filters.tags.length > 0) {
        result = result.filter(comic => {
          return comic.tags && this.filters.tags.every(tag => comic.tags.includes(tag))
        })
      }
      
      if (this.filters.categories.length > 0) {
        result = result.filter(comic => {
          return comic.category && this.filters.categories.includes(comic.category)
        })
      }
      
      if (this.filters.readStatus) {
        switch (this.filters.readStatus) {
          case 'unread':
            result = result.filter(comic => !comic.readingProgress || comic.readingProgress === 0)
            break
          case 'reading':
            result = result.filter(comic => comic.readingProgress > 0 && comic.readingProgress < 100)
            break
          case 'finished':
            result = result.filter(comic => comic.readingProgress === 100)
            break
        }
      }
      
      // 应用排序
      result.sort((a, b) => {
        let valueA, valueB
        
        switch (this.sortBy) {
          case 'name':
            valueA = a.name.toLowerCase()
            valueB = b.name.toLowerCase()
            break
          case 'lastRead':
            valueA = a.lastReadTime ? new Date(a.lastReadTime).getTime() : 0
            valueB = b.lastReadTime ? new Date(b.lastReadTime).getTime() : 0
            break
          case 'addTime':
            valueA = a.addTime ? new Date(a.addTime).getTime() : 0
            valueB = b.addTime ? new Date(b.addTime).getTime() : 0
            break
          default:
            valueA = a.name.toLowerCase()
            valueB = b.name.toLowerCase()
        }
        
        // 根据排序顺序返回比较结果
        if (this.sortOrder === 'asc') {
          return valueA > valueB ? 1 : valueA < valueB ? -1 : 0
        } else {
          return valueA < valueB ? 1 : valueA > valueB ? -1 : 0
        }
      })
      
      // 更新筛选后的漫画列表
      this.filteredComics = result
    },
    
    // 重置筛选条件
    resetFilters() {
      this.filters = {
        library: null,
        tags: [],
        categories: [],
        readStatus: null,
      }
      this.searchQuery = ''
      this.applyFiltersAndSort()
    },
  }
})