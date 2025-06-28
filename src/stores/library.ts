import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import type { MangaLibrary, Manga } from '../types'
import { libraryApi, mangaApi } from '../services/api'

export const useLibraryStore = defineStore('library', () => {
  const libraries = ref<MangaLibrary[]>([])
  const currentLibraryId = ref<string | null>(null)
  const mangas = ref<{"content":Manga[],"last":boolean,"size":number,"number":number,"totalElements":number,"totalPages":number}>()
  const loading = ref(false)

  // 计算属性
  const currentLibrary = computed(() => {
    return libraries.value.find(lib => lib.id === currentLibraryId.value) || null
  })

  const mangasByLibrary = computed(() => {
    if (!currentLibraryId.value) return mangas.value
    return mangas.value?.content.filter(manga => manga.libraryId === currentLibraryId.value)
  })

  // 创建漫画库
  const createLibrary = async (libraryData: Omit<MangaLibrary, 'id' | 'createdAt' | 'updatedAt'>) => {
    loading.value = true
    try {
      const response = await libraryApi.createLibrary(libraryData)
      if (response.success) {
        libraries.value.push(response.data)
        // 创建后刷新库列表
        await loadLibraries()
        return response.data
      } else {
        throw new Error(response.message || '创建漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 更新漫画库
  const updateLibrary = async (id: string, updates: Partial<MangaLibrary>, oldPassword?: string) => {
    loading.value = true
    try {
      const response = await libraryApi.updateLibrary(id, updates, oldPassword)
      if (response.success && response.data) {
        const index = libraries.value.findIndex(lib => lib.id === id)
        if (index !== -1) {
          libraries.value[index] = response.data
        }
        // 更新后刷新库列表
        await loadLibraries()
      } else {
        throw new Error(response.message || '更新漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 删除漫画库
  const deleteLibrary = async (id: string) => {
    loading.value = true
    try {
      const response = await libraryApi.deleteLibrary(id)
      if (response.success) {
        // 删除后刷新库列表
        await loadLibraries()
      } else {
        throw new Error(response.message || '删除漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 激活漫画库
  const activateLibrary = async (id: string, password?: string) => {
    try {
      const response = await libraryApi.activateLibrary(id, password)
      if (response.success) {
        // 更新本地状态
        const index = libraries.value.findIndex(lib => lib.id === id)
        if (index !== -1) {
          libraries.value[index] = { ...libraries.value[index], isActive: true }
        }
        currentLibraryId.value = id
      } else {
        throw new Error(response.message || '激活漫画库失败')
      }
    } catch (error) {
      console.error('激活漫画库失败:', error)
      throw error
    }
  }

  // 停用漫画库
  const deactivateLibrary = async (id: string) => {
    try {
      const response = await libraryApi.deactivateLibrary(id)
      if (response.success) {
        // 更新本地状态
        const index = libraries.value.findIndex(lib => lib.id === id)
        if (index !== -1) {
          libraries.value[index] = { ...libraries.value[index], isActive: false }
        }
        if (currentLibraryId.value === id) {
          currentLibraryId.value = null
        }
      } else {
        throw new Error(response.message || '停用漫画库失败')
      }
    } catch (error) {
      console.error('停用漫画库失败:', error)
      throw error
    }
  }

  // 设置当前漫画库（激活库）- 保留兼容性
  const setCurrentLibrary = async (id: string | null) => {
    if (id) {
      await activateLibrary(id)
    } else {
      currentLibraryId.value = null
    }
  }

  // 验证库密码
  const validateLibraryPassword = async (libraryId: string, password: string): Promise<boolean> => {
    try {
      const response = await libraryApi.validatePassword(libraryId, password)
      return response.success && response.data?.valid === true
    } catch (error) {
      console.error('密码验证失败:', error)
      return false
    }
  }

  // 扫描漫画库
  const scanLibrary = async (libraryId: string) => {
    const library = libraries.value.find(lib => lib.id === libraryId)
    if (!library) return

    try {
      const response = await libraryApi.scanLibrary(libraryId)
      if (response.success) {
        // 立即更新库状态为扫描中
        const index = libraries.value.findIndex(lib => lib.id === libraryId)
        if (index !== -1) {
          libraries.value[index] = { ...libraries.value[index], currentStatus: '扫描中' }
        }
        
        // 延迟1秒后开始轮询状态
        setTimeout(() => {
          pollLibraryStatus(libraryId)
        }, 1000)
        
        return response.data
      } else {
        throw new Error(response.message || '扫描漫画库失败')
      }
    } catch (error) {
      // 扫描失败时更新状态
      const index = libraries.value.findIndex(lib => lib.id === libraryId)
      if (index !== -1) {
        libraries.value[index] = { ...libraries.value[index], currentStatus: '扫描失败' }
      }
      throw error
    }
  }

  // 轮询库状态
  const pollLibraryStatus = async (libraryId: string) => {
    try {
      await loadLibraries() // 重新加载库列表以获取最新状态
      const library = libraries.value.find(lib => lib.id === libraryId)
      
      if (library && library.currentStatus === '扫描中') {
        // 如果仍在扫描中，继续轮询
        setTimeout(() => {
          pollLibraryStatus(libraryId)
        }, 2000)
      } 
    } catch (error) {
      console.error('轮询库状态失败:', error)
    }
  }

  // 加载漫画库列表
  const loadLibraries = async () => {
    loading.value = true
    try {
      const response = await libraryApi.getLibraries()
      if (response.success && response.data) {
        libraries.value = response.data
      } else {
        throw new Error(response.message || '加载漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

    // 加载漫画列表
  const loadMangas = async (libraryId?: string, params?: {
    page?: number
    limit?: number
    search?: string
    genre?: string
    status?: string
    sort?: string
    order?: string
    activeLibrariesOnly?: boolean
  }) => {
    loading.value = true
    try {
      const response = await mangaApi.pageMangas(libraryId,params)
      if (response.success && response.data) {
        mangas.value=response.data
        return mangas // 返回响应数据
      } else {
        throw new Error(response.message || '加载漫画失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 初始化数据
  const initializeData = async () => {
    await loadLibraries()
  }

  // 初始化数据
  const initializeBookshelfData = async () => {
    await loadMangas()
  }


  return {
    libraries,
    currentLibraryId,
    mangas,
    loading,
    currentLibrary,
    mangasByLibrary,
    createLibrary,
    updateLibrary,
    deleteLibrary,
    activateLibrary,
    deactivateLibrary,
    setCurrentLibrary,
    validateLibraryPassword,
    scanLibrary,
    pollLibraryStatus,
    loadLibraries,
    loadMangas,
    initializeData,
    initializeBookshelfData
  }
})