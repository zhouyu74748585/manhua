import { defineStore } from 'pinia'

// 漫画库状态管理
export const useLibraryStore = defineStore('library', {
  // 状态
  state: () => ({
    libraries: [], // 所有漫画库
    currentLibrary: null, // 当前选中的漫画库
    isLoading: false, // 加载状态
    error: null, // 错误信息
  }),
  
  // 计算属性
  getters: {
    // 获取所有非隐私库
    publicLibraries: (state) => {
      return state.libraries.filter(library => !library.isPrivate)
    },
    
    // 获取所有隐私库
    privateLibraries: (state) => {
      return state.libraries.filter(library => library.isPrivate)
    },
    
    // 获取指定ID的漫画库
    getLibraryById: (state) => (id) => {
      return state.libraries.find(library => library.id === id) || null
    },
  },
  
  // 动作
  actions: {
    // 获取所有漫画库
    async fetchLibraries() {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API获取漫画库列表
        const response = await fetch('/api/libraries')
        const data = await response.json()
        
        this.libraries = data
      } catch (error) {
        console.error('获取漫画库列表失败:', error)
        this.error = '获取漫画库列表失败'
      } finally {
        this.isLoading = false
      }
    },
    
    // 获取指定ID的漫画库详情
    async fetchLibraryById(id) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API获取漫画库详情
        const response = await fetch(`/api/libraries/${id}`)
        const data = await response.json()
        
        // 更新当前选中的漫画库
        this.currentLibrary = data
        
        // 同时更新libraries中的对应项
        const index = this.libraries.findIndex(lib => lib.id === id)
        if (index !== -1) {
          this.libraries[index] = data
        } else {
          this.libraries.push(data)
        }
        
        return data
      } catch (error) {
        console.error(`获取漫画库 ${id} 详情失败:`, error)
        this.error = `获取漫画库详情失败`
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 创建新漫画库
    async createLibrary(libraryData) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API创建漫画库
        const response = await fetch('/api/libraries', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(libraryData),
        })
        
        const data = await response.json()
        
        // 添加到漫画库列表
        this.libraries.push(data)
        
        return data
      } catch (error) {
        console.error('创建漫画库失败:', error)
        this.error = '创建漫画库失败'
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 更新漫画库
    async updateLibrary(id, libraryData) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API更新漫画库
        const response = await fetch(`/api/libraries/${id}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(libraryData),
        })
        
        const data = await response.json()
        
        // 更新漫画库列表中的对应项
        const index = this.libraries.findIndex(lib => lib.id === id)
        if (index !== -1) {
          this.libraries[index] = data
        }
        
        // 如果当前选中的是这个漫画库，也更新currentLibrary
        if (this.currentLibrary && this.currentLibrary.id === id) {
          this.currentLibrary = data
        }
        
        return data
      } catch (error) {
        console.error(`更新漫画库 ${id} 失败:`, error)
        this.error = '更新漫画库失败'
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 删除漫画库
    async deleteLibrary(id) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API删除漫画库
        await fetch(`/api/libraries/${id}`, {
          method: 'DELETE',
        })
        
        // 从漫画库列表中移除
        this.libraries = this.libraries.filter(lib => lib.id !== id)
        
        // 如果当前选中的是这个漫画库，清空currentLibrary
        if (this.currentLibrary && this.currentLibrary.id === id) {
          this.currentLibrary = null
        }
        
        return true
      } catch (error) {
        console.error(`删除漫画库 ${id} 失败:`, error)
        this.error = '删除漫画库失败'
        return false
      } finally {
        this.isLoading = false
      }
    },
    
    // 导入漫画到指定漫画库
    async importComicsToLibrary(libraryId, comicPaths) {
      this.isLoading = true
      this.error = null
      
      try {
        // 调用后端API导入漫画
        const response = await fetch(`/api/libraries/${libraryId}/import`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ paths: comicPaths }),
        })
        
        const data = await response.json()
        
        // 更新漫画库
        await this.fetchLibraryById(libraryId)
        
        return data
      } catch (error) {
        console.error(`导入漫画到漫画库 ${libraryId} 失败:`, error)
        this.error = '导入漫画失败'
        return null
      } finally {
        this.isLoading = false
      }
    },
    
    // 设置当前漫画库
    setCurrentLibrary(library) {
      this.currentLibrary = library
    },
  }
})