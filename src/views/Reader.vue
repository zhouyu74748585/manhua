<template>
  <div class="reader-container" :class="{ 'fullscreen': isFullscreen }">
    <!-- 数据加载中 -->
    <div v-if="!isDataLoaded" class="reader-loading">
      <el-icon class="is-loading"><Loading /></el-icon>
      <p>正在加载漫画数据...</p>
    </div>
    
    <!-- 阅读器工具栏 -->
    <div v-else class="reader-toolbar" :class="{ 'hidden': isToolbarHidden }">
      <div class="toolbar-left">
        <el-button :icon="ArrowLeft" @click="goBack" circle />
        <span class="manga-title">{{ manga?.title }}</span>
      </div>
      
      <div class="toolbar-center">
        <div class="page-info">
          <span v-if="totalPages > 0">{{ currentPage }} / {{ totalPages }}</span>
          <span v-else>加载中...</span>
        </div>
        
        <div class="page-controls">
          <el-button
            :icon="ArrowLeftBold"
            @click="previousPage"
            :disabled="currentPage <= 1 || totalPages <= 0"
            size="small"
          />
          <el-input-number
            v-if="totalPages > 0"
            v-model="currentPage"
            :min="1"
            :max="totalPages"
            size="small"
            controls-position="right"
            @change="goToPage"
          />
          <span v-else class="page-loading-text">加载中...</span>
          <el-button
            :icon="ArrowRightBold"
            @click="nextPage"
            :disabled="currentPage >= totalPages || totalPages <= 0"
            size="small"
          />
        </div>
      </div>
      
      <div class="toolbar-right">
        <el-button-group>
          <el-button
            :type="readingMode === 'single' ? 'primary' : 'default'"
            @click="setReadingMode('single')"
            size="small"
          >
            单页
          </el-button>
          <el-button
            :type="readingMode === 'double' ? 'primary' : 'default'"
            @click="setReadingMode('double')"
            size="small"
          >
            双页
          </el-button>
          <el-button
            :type="readingMode === 'continuous' ? 'primary' : 'default'"
            @click="setReadingMode('continuous')"
            size="small"
          >
            连续
          </el-button>
        </el-button-group>
        
        <el-dropdown @command="handleToolbarAction">
          <el-button :icon="Setting" circle size="small" />
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="fitWidth">
                <el-icon><FullScreen /></el-icon>
                适应宽度
              </el-dropdown-item>
              <el-dropdown-item command="fitHeight">
                <el-icon><ScaleToOriginal /></el-icon>
                适应高度
              </el-dropdown-item>
              <el-dropdown-item command="originalSize">
                <el-icon><Crop /></el-icon>
                原始大小
              </el-dropdown-item>
              <el-dropdown-item divided command="toggleDirection">
                <el-icon><Sort /></el-icon>
                {{ readingDirection === 'ltr' ? '从右到左' : '从左到右' }}
              </el-dropdown-item>
              <el-dropdown-item command="toggleFullscreen">
                <el-icon><FullScreen /></el-icon>
                {{ isFullscreen ? '退出全屏' : '全屏模式' }}
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>

    <!-- 阅读器内容区 -->
    <div 
      v-if="isDataLoaded"
      class="reader-content"
      :style="{ backgroundColor: readerSettings.backgroundColor }"
      @click="toggleToolbar"
      @wheel="handleWheel"
      @keydown="handleKeydown"
      tabindex="0"
      ref="readerContentRef"
    >
      <!-- 单页模式 -->
      <div v-if="readingMode === 'single'" class="single-page-mode">
        <div class="page-container" :class="fitModeClass">
          <img
            v-if="currentPageImage"
            :src="currentPageImage"
            :alt="`Page ${currentPage}`"
            class="manga-page"
            @load="handleImageLoad"
            @error="handleImageError"
            @click.stop="handleImageClick"
          />
          <div v-else class="page-loading">
            <el-icon class="is-loading"><Loading /></el-icon>
            <p>加载中...</p>
          </div>
        </div>
      </div>
      
      <!-- 双页模式 -->
      <div v-else-if="readingMode === 'double'" class="double-page-mode">
        <div class="page-container" :class="fitModeClass">
          <img
            v-if="leftPageImage"
            :src="leftPageImage"
            :alt="`Page ${currentPage - 1}`"
            class="manga-page left-page"
            @load="handleImageLoad"
            @error="handleImageError"
          />
          <img
            v-if="rightPageImage"
            :src="rightPageImage"
            :alt="`Page ${currentPage}`"
            class="manga-page right-page"
            @load="handleImageLoad"
            @error="handleImageError"
          />
        </div>
      </div>
      
      <!-- 连续滚动模式 -->
      <div v-else class="continuous-mode">
        <div
          v-for="(page, index) in visiblePages"
          :key="index"
          class="page-container continuous-page"
          :class="fitModeClass"
        >
          <img
            v-if="page.src"
            :src="page.src"
            :alt="`Page ${page.number}`"
            class="manga-page"
            @load="handleImageLoad"
            @error="handleImageError"
          />
          <div v-else class="page-loading">
            <el-icon class="is-loading"><Loading /></el-icon>
            <p>加载第 {{ page.number }} 页...</p>
          </div>
        </div>
      </div>
      
      <!-- 缩放控制 -->
      <div v-if="readerSettings.enableZoom && isZoomed" class="zoom-controls">
        <el-button-group>
          <el-button @click="zoomOut" :icon="ZoomOut" size="small" />
          <el-button @click="resetZoom" size="small">{{ Math.round(zoomLevel * 100) }}%</el-button>
          <el-button @click="zoomIn" :icon="ZoomIn" size="small" />
        </el-button-group>
      </div>
    </div>

    <!-- 页面导航区域 -->
    <div class="page-navigation" v-if="isDataLoaded && totalPages > 0">
      <div 
        class="nav-area nav-prev"
        @click="previousPage"
        :class="{ 'disabled': currentPage <= 1 }"
      ></div>
      <div 
        class="nav-area nav-next"
        @click="nextPage"
        :class="{ 'disabled': currentPage >= totalPages }"
      ></div>
    </div>

    <!-- 进度条 -->
    <div class="reading-progress" v-if="isDataLoaded">
      <el-progress
        :percentage="progressPercentage"
        :show-text="false"
        :stroke-width="3"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { Manga, ReaderSettings } from '../types'
import { mangaApi } from '../services/api'
import {
  ArrowLeft,
  ArrowLeftBold,
  ArrowRightBold,
  Setting,
  FullScreen,
  ScaleToOriginal,
  Crop,
  Sort,
  Loading,
  ZoomIn,
  ZoomOut
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
// 响应式数据
const manga = ref<Manga>()
const currentPage = ref(1)
const totalPages = ref(0)
const isDataLoaded = ref(false)
const isToolbarHidden = ref(false)
const isFullscreen = ref(false)
const isZoomed = ref(false)
const zoomLevel = ref(1)
const readerContentRef = ref<HTMLElement>()

// 阅读设置
const readerSettings = ref<ReaderSettings>({
  readingMode: 'single',
  readingDirection: 'ltr',
  fitMode: 'width',
  backgroundColor: '#000000',
  autoHideUI: true,
  preloadPages: 3,
  enableZoom: true,
  enableFullscreen: true
})

// 页面图片缓存
const pageImages = ref<Map<number, string>>(new Map())
const loadingPages = ref<Set<number>>(new Set())

// 计算属性
const readingMode = computed(() => readerSettings.value.readingMode)
const readingDirection = computed(() => readerSettings.value.readingDirection)
const fitModeClass = computed(() => `fit-${readerSettings.value.fitMode}`)

const progressPercentage = computed(() => {
  if (totalPages.value === 0) return 0
  return (currentPage.value / totalPages.value) * 100
})

const currentPageImage = computed(() => {
  return pageImages.value.get(currentPage.value)
})

const leftPageImage = computed(() => {
  if (readingDirection.value === 'rtl') {
    return pageImages.value.get(currentPage.value)
  } else {
    return pageImages.value.get(currentPage.value - 1)
  }
})

const rightPageImage = computed(() => {
  if (readingDirection.value === 'rtl') {
    return pageImages.value.get(currentPage.value - 1)
  } else {
    return pageImages.value.get(currentPage.value)
  }
})

const visiblePages = computed(() => {
  const pages = []
  const startPage = Math.max(1, currentPage.value - 2)
  const endPage = Math.min(totalPages.value, currentPage.value + 2)
  
  for (let i = startPage; i <= endPage; i++) {
    pages.push({
      number: i,
      src: pageImages.value.get(i)
    })
  }
  
  return pages
})

// 自动隐藏工具栏
let hideToolbarTimer: NodeJS.Timeout | null = null

const startHideToolbarTimer = () => {
  if (!readerSettings.value.autoHideUI) return
  
  if (hideToolbarTimer) {
    clearTimeout(hideToolbarTimer)
  }
  
  hideToolbarTimer = setTimeout(() => {
    isToolbarHidden.value = true
  }, 3000)
}

const toggleToolbar = () => {
  isToolbarHidden.value = !isToolbarHidden.value
  if (!isToolbarHidden.value) {
    startHideToolbarTimer()
  }
}

// 页面导航
const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    saveProgress()
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
    saveProgress()
  }
}

const goToPage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    saveProgress()
  }
}

// 阅读模式切换
const setReadingMode = (mode: ReaderSettings['readingMode']) => {
  readerSettings.value.readingMode = mode
  saveReaderSettings()
}

// 工具栏操作
const handleToolbarAction = (command: string) => {
  switch (command) {
    case 'fitWidth':
      readerSettings.value.fitMode = 'width'
      break
    case 'fitHeight':
      readerSettings.value.fitMode = 'height'
      break
    case 'originalSize':
      readerSettings.value.fitMode = 'original'
      break
    case 'toggleDirection':
      readerSettings.value.readingDirection = 
        readerSettings.value.readingDirection === 'ltr' ? 'rtl' : 'ltr'
      break
    case 'toggleFullscreen':
      toggleFullscreen()
      break
  }
  saveReaderSettings()
}

// 全屏控制
const toggleFullscreen = () => {
  if (!readerSettings.value.enableFullscreen) return
  
  if (!isFullscreen.value) {
    document.documentElement.requestFullscreen()
  } else {
    document.exitFullscreen()
  }
}

// 缩放控制
const zoomIn = () => {
  zoomLevel.value = Math.min(zoomLevel.value * 1.2, 5)
  isZoomed.value = zoomLevel.value !== 1
}

const zoomOut = () => {
  zoomLevel.value = Math.max(zoomLevel.value / 1.2, 0.2)
  isZoomed.value = zoomLevel.value !== 1
}

const resetZoom = () => {
  zoomLevel.value = 1
  isZoomed.value = false
}

// 事件处理
const handleWheel = (event: WheelEvent) => {
  if (event.ctrlKey || event.metaKey) {
    // 缩放
    event.preventDefault()
    if (event.deltaY < 0) {
      zoomIn()
    } else {
      zoomOut()
    }
  } else {
    // 翻页
    if (readingMode.value !== 'continuous') {
      event.preventDefault()
      if (event.deltaY > 0) {
        nextPage()
      } else {
        previousPage()
      }
    }
  }
}

const handleKeydown = (event: KeyboardEvent) => {
  switch (event.key) {
    case 'ArrowLeft':
      if (readingDirection.value === 'ltr') {
        previousPage()
      } else {
        nextPage()
      }
      break
    case 'ArrowRight':
      if (readingDirection.value === 'ltr') {
        nextPage()
      } else {
        previousPage()
      }
      break
    case 'ArrowUp':
      previousPage()
      break
    case 'ArrowDown':
      nextPage()
      break
    case 'Home':
      goToPage(1)
      break
    case 'End':
      goToPage(totalPages.value)
      break
    case 'f':
    case 'F11':
      event.preventDefault()
      toggleFullscreen()
      break
    case 'Escape':
      if (isFullscreen.value) {
        document.exitFullscreen()
      } else {
        goBack()
      }
      break
  }
}

const handleImageLoad = () => {
  // 图片加载完成
}

const handleImageError = (event: Event) => {
  console.error('图片加载失败:', event)
}

const handleImageClick = (event: MouseEvent) => {
  event.stopPropagation()
  if (readerSettings.value.enableZoom) {
    if (event.detail === 2) { // 双击
      if (isZoomed.value) {
        resetZoom()
      } else {
        zoomIn()
      }
    }
  }
}

// 页面加载
const loadPage = async (pageNumber: number) => {
  if (loadingPages.value.has(pageNumber) || pageImages.value.has(pageNumber)) {
    return
  }
  
  if (!manga.value) {
    console.error('漫画数据未加载')
    return
  }
  
  loadingPages.value.add(pageNumber)
  
  try {
    let imageSrc: string
    
    // 检查是否在Electron环境中
    if (window.electronAPI) {
      // 使用Electron API直接访问本地文件
      imageSrc = await window.electronAPI.getMangaPage(manga.value.filePath, pageNumber)
    } else {
      // 回退到后端API（用于Web版本）
      imageSrc = `/api/manga/${manga.value.id}/page/${pageNumber}`
    }
    
    // 预加载图片以检查是否可用
    const img = new Image()
    img.onload = () => {
      pageImages.value.set(pageNumber, imageSrc)
    }
    img.onerror = () => {
      console.error(`第${pageNumber}页图片加载失败`)
    }
    img.src = imageSrc
    
  } catch (error) {
    console.error(`加载第${pageNumber}页失败:`, error)
  } finally {
    loadingPages.value.delete(pageNumber)
  }
}

// 预加载页面
const preloadPages = () => {
  const preloadCount = readerSettings.value.preloadPages
  const startPage = Math.max(1, currentPage.value - preloadCount)
  const endPage = Math.min(totalPages.value, currentPage.value + preloadCount)
  
  for (let i = startPage; i <= endPage; i++) {
    loadPage(i)
  }
}

// 保存阅读进度
const saveProgress = () => {
  if (manga.value) {
    manga.value.currentPage = currentPage.value
    manga.value.lastReadAt = new Date()
    
    // 更新阅读状态
    if (currentPage.value === 1) {
      manga.value.status = 'READING'
    } else if (currentPage.value === totalPages.value) {
      manga.value.status = 'COMPLETED'
    } else {
      manga.value.status = 'READING'
    }
    
    // 数据已自动同步到后端
  }
}

// 保存阅读器设置
const saveReaderSettings = () => {
  localStorage.setItem('reader-settings', JSON.stringify(readerSettings.value))
}

// 加载阅读器设置
const loadReaderSettings = () => {
  const saved = localStorage.getItem('reader-settings')
  if (saved) {
    Object.assign(readerSettings.value, JSON.parse(saved))
  }
}

// 返回
const goBack = () => {
  router.push('/bookshelf')
}

// 监听全屏状态变化
const handleFullscreenChange = () => {
  isFullscreen.value = !!document.fullscreenElement
}

// 监听当前页变化
watch(currentPage, () => {
  preloadPages()
  if (!isToolbarHidden.value) {
    startHideToolbarTimer()
  }
})

// 初始化
onMounted(async () => {
  const mangaId = route.params.id as string
  
   const response = await mangaApi.getManga(mangaId)
   manga.value = response.data
  
  if (!manga.value) {
    console.error('未找到漫画:', mangaId)
    router.push('/bookshelf')
    return
  }
  
  // 初始化页面信息
  currentPage.value = manga.value.currentPage || 1
  
  // 在Electron环境中，直接从文件系统获取总页数
  if (window.electronAPI) {
    try {
      totalPages.value = await window.electronAPI.getMangaPageCount(manga.value.path)
      console.log('从文件系统获取总页数:', totalPages.value)
    } catch (error) {
      console.error('获取文件系统页数失败:', error)
      totalPages.value = manga.value.totalPages
    }
  } else {
    totalPages.value = manga.value.totalPages
  }
  
  console.log('漫画信息:', manga.value)
  
  // 检查总页数是否有效
  if (totalPages.value <= 0) {
    console.error('漫画总页数无效:', totalPages.value)
    ElMessage.error('漫画数据异常，总页数为0')
    router.push('/bookshelf')
    return
  }
  
  // 标记数据已加载
  isDataLoaded.value = true
  
  // 加载设置
  loadReaderSettings()
  
  // 预加载页面
  preloadPages()
  
  // 开始自动隐藏计时器
  startHideToolbarTimer()
  
  // 监听全屏事件
  document.addEventListener('fullscreenchange', handleFullscreenChange)
  
  // 聚焦到内容区域以接收键盘事件
  nextTick(() => {
    readerContentRef.value?.focus()
  })
})

onUnmounted(() => {
  if (hideToolbarTimer) {
    clearTimeout(hideToolbarTimer)
  }
  document.removeEventListener('fullscreenchange', handleFullscreenChange)
  
  // 保存最终进度
  saveProgress()
})
</script>

<style scoped>
.reader-container {
  height: 100vh;
  width: 100vw;
  position: relative;
  overflow: hidden;
  background: #000;
}

.reader-container.fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  z-index: 9999;
}

.reader-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  color: white;
  background: #000;
}

.reader-loading .el-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.reader-loading p {
  font-size: 16px;
  margin: 0;
}

.reader-toolbar {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 60px;
  background: rgba(0, 0, 0, 0.8);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  z-index: 100;
  transition: transform 0.3s ease;
}

.reader-toolbar.hidden {
  transform: translateY(-100%);
}

.toolbar-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.manga-title {
  color: white;
  font-weight: 500;
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.toolbar-center {
  display: flex;
  align-items: center;
  gap: 16px;
}

.page-info {
  color: white;
  font-size: 14px;
}

.page-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.page-loading-text {
  color: white;
  font-size: 14px;
  padding: 0 8px;
}

.toolbar-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.reader-content {
  height: 100vh;
  width: 100vw;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: auto;
  outline: none;
}

.single-page-mode,
.double-page-mode {
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.continuous-mode {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px 0;
}

.page-container {
  display: flex;
  align-items: center;
  justify-content: center;
  max-width: 100%;
  max-height: 100%;
}

.page-container.fit-width {
  width: 100%;
}

.page-container.fit-height {
  height: 100%;
}

.page-container.fit-original {
  width: auto;
  height: auto;
}

.continuous-page {
  margin-bottom: 20px;
}

.manga-page {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.double-page-mode .manga-page {
  max-width: 50%;
}

.page-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  min-height: 200px;
}

.page-loading .el-icon {
  font-size: 32px;
  margin-bottom: 12px;
}

.page-navigation {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: flex;
  pointer-events: none;
}

.nav-area {
  flex: 1;
  pointer-events: auto;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.nav-area:hover {
  background-color: rgba(255, 255, 255, 0.1);
}

.nav-area.disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.zoom-controls {
  position: absolute;
  bottom: 80px;
  right: 20px;
  z-index: 50;
}

.reading-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 50;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .reader-toolbar {
    height: 50px;
    padding: 0 12px;
  }
  
  .toolbar-center {
    gap: 8px;
  }
  
  .page-controls {
    gap: 4px;
  }
  
  .manga-title {
    max-width: 120px;
  }
  
  .zoom-controls {
    bottom: 60px;
    right: 12px;
  }
}
</style>