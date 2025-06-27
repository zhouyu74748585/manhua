import { ref, computed } from 'vue'
import { defineStore } from 'pinia'
import type { MangaLibrary, Manga } from '../types'
import { libraryApi, mangaApi } from '../services/api'

export const useLibraryStore = defineStore('library', () => {
  const libraries = ref<MangaLibrary[]>([])
  const currentLibraryId = ref<string | null>(null)
  const mangas = ref<Manga[]>([])
  const loading = ref(false)

  // 计算属性
  const currentLibrary = computed(() => {
    return libraries.value.find(lib => lib.id === currentLibraryId.value) || null
  })

  const mangasByLibrary = computed(() => {
    if (!currentLibraryId.value) return mangas.value
    return mangas.value.filter(manga => manga.libraryId === currentLibraryId.value)
  })

  // 创建漫画库
  const createLibrary = async (libraryData: Omit<MangaLibrary, 'id' | 'createdAt' | 'updatedAt'>) => {
    loading.value = true
    try {
      const response = await libraryApi.createLibrary(libraryData)
      if (response.success) {
        libraries.value.push(response.data)
        return response.data
      } else {
        throw new Error(response.message || '创建漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 更新漫画库
  const updateLibrary = async (id: string, updates: Partial<MangaLibrary>) => {
    loading.value = true
    try {
      const response = await libraryApi.updateLibrary(id, updates)
      if (response.success && response.data) {
        const index = libraries.value.findIndex(lib => lib.id === id)
        if (index !== -1) {
          libraries.value[index] = response.data
        }
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
        libraries.value = libraries.value.filter(lib => lib.id !== id)
        // 同时删除该库下的所有漫画
        mangas.value = mangas.value.filter(manga => manga.libraryId !== id)
        if (currentLibraryId.value === id) {
          currentLibraryId.value = null
        }
      } else {
        throw new Error(response.message || '删除漫画库失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 设置当前漫画库
  const setCurrentLibrary = (id: string | null) => {
    currentLibraryId.value = id
  }

  // 扫描漫画库
  const scanLibrary = async (libraryId: string) => {
    const library = libraries.value.find(lib => lib.id === libraryId)
    if (!library) return

    loading.value = true
    try {
      const response = await libraryApi.scanLibrary(libraryId)
      if (response.success) {
        // 扫描完成后重新加载漫画列表
        await loadMangas(libraryId)
        return response.data
      } else {
        throw new Error(response.message || '扫描漫画库失败')
      }
    } finally {
      loading.value = false
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
  const loadMangas = async (libraryId?: string) => {
    loading.value = true
    try {
      const response = await mangaApi.getMangas(libraryId)
      if (response.success && response.data) {
        if (libraryId) {
          // 只更新指定库的漫画
          mangas.value = mangas.value.filter(manga => manga.libraryId !== libraryId)
          mangas.value.push(...response.data.mangas)
        } else {
          // 加载所有漫画
          mangas.value = response.data.mangas
        }
      } else {
        throw new Error(response.message || '加载漫画列表失败')
      }
    } finally {
      loading.value = false
    }
  }

  // 初始化数据
  const initializeData = async () => {
    await loadLibraries()
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
    setCurrentLibrary,
    scanLibrary,
    loadLibraries,
    loadMangas,
    initializeData
  }
})