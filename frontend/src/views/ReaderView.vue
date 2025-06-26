<template>
  <div class="reader-view" :class="{ 'fullscreen': isFullscreen, 'ui-hidden': !showUI }">
    <!-- 顶部控制栏 -->
    <div v-show="showUI" class="reader-header">
      <div class="reader-controls left">
        <el-button @click="goBack" plain>
          <el-icon><Back /></el-icon> 返回
        </el-button>
        <h2 class="comic-title">{{ comic?.name || '加载中...' }}</h2>
      </div>
      
      <div class="reader-controls right">
        <el-button-group>
          <el-tooltip content="上一页" placement="bottom">
            <el-button @click="prevPage" :disabled="currentPage <= 1" plain>
              <el-icon><ArrowLeft /></el-icon>
            </el-button>
          </el-tooltip>
          
          <el-button plain>
            {{ currentPage }} / {{ totalPages }}
          </el-button>
          
          <el-tooltip content="下一页" placement="bottom">
            <el-button @click="nextPage" :disabled="currentPage >= totalPages" plain>
              <el-icon><ArrowRight /></el-icon>
            </el-button>
          </el-tooltip>
        </el-button-group>
        
        <el-dropdown @command="handleReadingModeChange">
          <el-button plain>
            <el-icon><Reading /></el-icon>
            {{ readingModeText }}
            <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="single">单页模式</el-dropdown-item>
              <el-dropdown-item command="double">双页模式</el-dropdown-item>
              <el-dropdown-item command="continuous">连续模式</el-dropdown-item>
              <el-dropdown-item command="webtoon">条漫模式</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        
        <el-dropdown @command="handleZoomChange">
          <el-button plain>
            <el-icon><ZoomIn /></el-icon>
            {{ zoomLevelText }}
            <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="fit-width">适合宽度</el-dropdown-item>
              <el-dropdown-item command="fit-height">适合高度</el-dropdown-item>
              <el-dropdown-item command="fit-page">适合页面</el-dropdown-item>
              <el-dropdown-item command="100">100%</el-dropdown-item>
              <el-dropdown-item command="125">125%</el-dropdown-item>
              <el-dropdown-item command="150">150%</el-dropdown-item>
              <el-dropdown-item command="200">200%</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
        
        <el-button-group>
          <el-tooltip content="全屏" placement="bottom">
            <el-button @click="toggleFullscreen" plain>
              <el-icon><component :is="isFullscreen ? 'FullscreenExit' : 'FullScreen'" /></el-icon>
            </el-button>
          </el-tooltip>
          
          <el-tooltip content="设置" placement="bottom">
            <el-button @click="showSettings = true" plain>
              <el-icon><Setting /></el-icon>
            </el-button>
          </el-tooltip>
        </el-button-group>
      </div>
    </div>
    
    <!-- 阅读区域 -->
    <div 
      class="reader-content" 
      :class="readingMode"
      @click="handleContentClick"
      @wheel="handleWheel"
      @keydown="handleKeyDown"
      tabindex="0"
      ref="readerContent"
    >
      <div v-if="isLoading" class="loading-container">
        <el-skeleton animated :rows="5" />
      </div>
      
      <div v-else-if="error" class="error-container">
        <el-empty :description="error" />
        <el-button @click="loadComic" type="primary">重试</el-button>
      </div>
      
      <template v-else>
        <!-- 单页/双页模式 -->
        <template v-if="readingMode === 'single-page' || readingMode === 'double-page'">
          <div class="page-container">
            <img 
              v-for="(page, index) in visiblePages" 
              :key="currentPage + '-' + index"
              :src="page.url" 
              :alt="`Page ${currentPage + index}`"
              :class="{
                'left-page': readingMode === 'double-page' && index === 0,
                'right-page': readingMode === 'double-page' && index === 1
              }"
              :style="getImageStyle()"
              @load="handleImageLoad"
              @error="handleImageError"
            />
          </div>
        </template>
        
        <!-- 连续模式 -->
        <template v-else-if="readingMode === 'continuous'">
          <div class="continuous-container" ref="continuousContainer">
            <div 
              v-for="(page, index) in pages" 
              :key="index"
              :id="`page-${index + 1}`"
              class="continuous-page"
            >
              <img 
                :src="page.url" 
                :alt="`Page ${index + 1}`"
                :style="getImageStyle()"
                @load="handleImageLoad"
                @error="handleImageError"
              />
              <div class="page-number">{{ index + 1 }}</div>
            </div>
          </div>
        </template>
        
        <!-- 条漫模式 -->
        <template v-else-if="readingMode === 'webtoon'">
          <div class="webtoon-container" ref="webtoonContainer">
            <div 
              v-for="(page, index) in pages" 
              :key="index"
              :id="`page-${index + 1}`"
              class="webtoon-page"
            >
              <img 
                :src="page.url" 
                :alt="`Page ${index + 1}`"
                :style="getWebtoonImageStyle()"
                @load="handleImageLoad"
                @error="handleImageError"
              />
            </div>
          </div>
        </template>
      </template>
    </div>
    
    <!-- 底部导航栏 -->
    <div v-show="showUI" class="reader-footer">
      <el-slider 
        v-model="currentPage" 
        :min="1" 
        :max="totalPages" 
        :format-tooltip="(val) => `${val}/${totalPages}`"
        @change="handleSliderChange"
      />
    </div>
    
    <!-- 设置对话框 -->
    <el-dialog
      v-model="showSettings"
      title="阅读设置"
      width="400px"
    >
      <div class="reader-settings">
        <h3>阅读方向</h3>
        <el-radio-group v-model="readingDirection" @change="saveReaderSettings">
          <el-radio label="ltr">从左到右</el-radio>
          <el-radio label="rtl">从右到左</el-radio>
        </el-radio-group>
        
        <h3>背景颜色</h3>
        <el-radio-group v-model="backgroundColor" @change="applyBackgroundColor">
          <el-radio label="white">白色</el-radio>
          <el-radio label="black">黑色</el-radio>
          <el-radio label="gray">灰色</el-radio>
          <el-radio label="sepia">棕褐色</el-radio>
        </el-radio-group>
        
        <h3>预加载页数</h3>
        <el-slider 
          v-model="preloadPages" 
          :min="0" 
          :max="10" 
          :format-tooltip="(val) => val === 0 ? '不预加载' : `${val}页`"
          @change="saveReaderSettings"
        />
        
        <h3>自动隐藏UI</h3>
        <el-switch v-model="autoHideUI" @change="saveReaderSettings" />
        <span class="setting-description">阅读时自动隐藏界面元素</span>
        
        <h3>记住阅读设置</h3>
        <el-switch v-model="rememberSettings" @change="saveReaderSettings" />
        <span class="setting-description">为每本漫画保存单独的阅读设置</span>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReaderStore } from '../store/reader'
import { useBookshelfStore } from '../store/bookshelf'
import { usePrivacyStore } from '../store/privacy'
import { ElMessage } from 'element-plus'
import { Back, ArrowLeft, ArrowRight, Reading, ZoomIn, FullScreen, FullscreenExit, Setting } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const readerStore = useReaderStore()
const bookshelfStore = useBookshelfStore()
const privacyStore = usePrivacyStore()

// 获取路由参数中的漫画ID
const comicId = computed(() => route.params.id)

// 漫画信息
const comic = ref(null)

// 阅读状态
const isLoading = computed(() => readerStore.isLoading)
const error = computed(() => readerStore.error)
const currentPage = computed({
  get: () => readerStore.currentPage,
  set: (value) => readerStore.setCurrentPage(value)
})
const totalPages = computed(() => readerStore.totalPages)
const pages = computed(() => readerStore.pages)

// 阅读模式
const readingMode = computed(() => {
  switch (readerStore.readingMode) {
    case 'single': return 'single-page'
    case 'double': return 'double-page'
    case 'continuous': return 'continuous'
    case 'webtoon': return 'webtoon'
    default: return 'single-page'
  }
})

// 阅读模式文本
const readingModeText = computed(() => {
  const modeMap = {
    'single': '单页模式',
    'double': '双页模式',
    'continuous': '连续模式',
    'webtoon': '条漫模式'
  }
  return modeMap[readerStore.readingMode] || '单页模式'
})

// 缩放级别
const zoomLevelText = computed(() => {
  const zoomMap = {
    'fit-width': '适合宽度',
    'fit-height': '适合高度',
    'fit-page': '适合页面',
    '100': '100%',
    '125': '125%',
    '150': '150%',
    '200': '200%'
  }
  return zoomMap[readerStore.zoomLevel] || '适合页面'
})

// 计算当前可见页面
const visiblePages = computed(() => {
  if (!pages.value || pages.value.length === 0) return []
  
  if (readingMode.value === 'single-page') {
    // 单页模式只显示当前页
    return [pages.value[currentPage.value - 1]].filter(Boolean)
  } else if (readingMode.value === 'double-page') {
    // 双页模式显示当前页和下一页
    const currentPageIndex = currentPage.value - 1
    const nextPageIndex = currentPageIndex + 1
    
    // 检查是否有下一页
    if (nextPageIndex < pages.value.length) {
      return [pages.value[currentPageIndex], pages.value[nextPageIndex]].filter(Boolean)
    } else {
      return [pages.value[currentPageIndex]].filter(Boolean)
    }
  }
  
  return []
})

// UI状态
const showUI = ref(true)
const isFullscreen = ref(false)
const uiHideTimeout = ref(null)
const autoHideUI = ref(true)

// 设置对话框
const showSettings = ref(false)

// 阅读设置
const readingDirection = ref('ltr')
const backgroundColor = ref('white')
const preloadPages = ref(3)
const rememberSettings = ref(true)

// DOM引用
const readerContent = ref(null)
const continuousContainer = ref(null)
const webtoonContainer = ref(null)

// 监听漫画ID变化，加载漫画
watch(comicId, async (newId) => {
  if (newId) {
    await loadComic(newId)
  }
}, { immediate: true })

// 加载漫画
async function loadComic(id) {
  try {
    // 获取漫画信息
    comic.value = await bookshelfStore.getComicById(id)
    
    // 检查是否是隐私漫画，如果是且未授权，则请求授权
    if (comic.value && privacyStore.isPrivacyBook(comic.value.id) && !privacyStore.isPrivacyModeAuthorized) {
      await privacyStore.requestPrivacyModeAccess()
      
      // 如果授权失败，返回首页
      if (!privacyStore.isPrivacyModeAuthorized) {
        router.push('/')
        return
      }
    }
    
    // 加载漫画页面
    await readerStore.loadComic(id)
    
    // 加载阅读设置
    loadReaderSettings(id)
    
    // 设置焦点到阅读区域，以便捕获键盘事件
    nextTick(() => {
      if (readerContent.value) {
        readerContent.value.focus()
      }
    })
  } catch (error) {
    console.error('加载漫画失败:', error)
    ElMessage.error('加载漫画失败')
  }
}

// 返回上一页
function goBack() {
  // 如果是从库页面进入，则返回库页面
  if (comic.value && comic.value.libraryId) {
    router.push(`/library/${comic.value.libraryId}`)
  } else {
    // 否则返回首页
    router.push('/')
  }
}

// 上一页
function prevPage() {
  if (readingMode.value === 'single-page' || readingMode.value === 'double-page') {
    // 单页/双页模式
    const step = readingMode.value === 'double-page' ? 2 : 1
    const newPage = Math.max(1, currentPage.value - step)
    readerStore.setCurrentPage(newPage)
  } else if (readingMode.value === 'continuous' || readingMode.value === 'webtoon') {
    // 连续/条漫模式，滚动到上一页
    const container = readingMode.value === 'continuous' ? continuousContainer.value : webtoonContainer.value
    if (container) {
      // 找到当前可见的页面
      const visiblePageIndex = findVisiblePageIndex(container)
      if (visiblePageIndex > 0) {
        // 滚动到上一页
        const prevPageElement = container.querySelector(`#page-${visiblePageIndex}`)
        if (prevPageElement) {
          prevPageElement.scrollIntoView({ behavior: 'smooth' })
          readerStore.setCurrentPage(visiblePageIndex)
        }
      }
    }
  }
  
  // 更新阅读进度
  updateReadingProgress()
}

// 下一页
function nextPage() {
  if (readingMode.value === 'single-page' || readingMode.value === 'double-page') {
    // 单页/双页模式
    const step = readingMode.value === 'double-page' ? 2 : 1
    const newPage = Math.min(totalPages.value, currentPage.value + step)
    readerStore.setCurrentPage(newPage)
  } else if (readingMode.value === 'continuous' || readingMode.value === 'webtoon') {
    // 连续/条漫模式，滚动到下一页
    const container = readingMode.value === 'continuous' ? continuousContainer.value : webtoonContainer.value
    if (container) {
      // 找到当前可见的页面
      const visiblePageIndex = findVisiblePageIndex(container)
      if (visiblePageIndex < totalPages.value) {
        // 滚动到下一页
        const nextPageElement = container.querySelector(`#page-${visiblePageIndex + 2}`)
        if (nextPageElement) {
          nextPageElement.scrollIntoView({ behavior: 'smooth' })
          readerStore.setCurrentPage(visiblePageIndex + 2)
        }
      }
    }
  }
  
  // 更新阅读进度
  updateReadingProgress()
}

// 查找当前可见的页面索引
function findVisiblePageIndex(container) {
  const containerRect = container.getBoundingClientRect()
  const pageElements = container.querySelectorAll('[id^="page-"]')
  
  for (let i = 0; i < pageElements.length; i++) {
    const pageRect = pageElements[i].getBoundingClientRect()
    
    // 如果页面的中心点在容器的可见区域内，则认为该页面是可见的
    const pageCenter = pageRect.top + pageRect.height / 2
    if (pageCenter >= containerRect.top && pageCenter <= containerRect.bottom) {
      // 从id中提取页码
      const pageId = pageElements[i].id
      const pageNumber = parseInt(pageId.replace('page-', ''))
      return pageNumber
    }
  }
  
  return 1 // 默认返回第一页
}

// 处理滑块变化
function handleSliderChange(value) {
  readerStore.setCurrentPage(value)
  updateReadingProgress()
}

// 处理阅读模式变更
function handleReadingModeChange(mode) {
  readerStore.setReadingMode(mode)
  saveReaderSettings()
  
  // 在模式切换后，确保当前页面正确显示
  nextTick(() => {
    if ((mode === 'continuous' || mode === 'webtoon') && currentPage.value > 1) {
      // 在连续/条漫模式下，滚动到当前页
      const container = mode === 'continuous' ? continuousContainer.value : webtoonContainer.value
      if (container) {
        const pageElement = container.querySelector(`#page-${currentPage.value}`)
        if (pageElement) {
          pageElement.scrollIntoView({ behavior: 'auto' })
        }
      }
    }
  })
}

// 处理缩放变更
function handleZoomChange(zoom) {
  readerStore.setZoomLevel(zoom)
  saveReaderSettings()
}

// 获取图片样式
function getImageStyle() {
  const style = {}
  
  // 根据缩放级别设置样式
  switch (readerStore.zoomLevel) {
    case 'fit-width':
      style.width = '100%'
      style.height = 'auto'
      break
    case 'fit-height':
      style.width = 'auto'
      style.height = '100%'
      break
    case 'fit-page':
      style.maxWidth = '100%'
      style.maxHeight = '100%'
      break
    default:
      // 百分比缩放
      const zoomPercent = parseInt(readerStore.zoomLevel) || 100
      style.width = `${zoomPercent}%`
      style.height = 'auto'
  }
  
  return style
}

// 获取条漫模式图片样式
function getWebtoonImageStyle() {
  return {
    width: '100%',
    height: 'auto'
  }
}

// 切换全屏
async function toggleFullscreen() {
  try {
    if (!isFullscreen.value) {
      // 进入全屏
      await window.electronAPI.enterFullscreen()
      isFullscreen.value = true
    } else {
      // 退出全屏
      await window.electronAPI.exitFullscreen()
      isFullscreen.value = false
    }
    
    // 设置焦点到阅读区域
    nextTick(() => {
      if (readerContent.value) {
        readerContent.value.focus()
      }
    })
  } catch (error) {
    console.error('切换全屏失败:', error)
  }
}

// 处理内容点击
function handleContentClick(event) {
  // 计算点击位置
  const contentRect = event.currentTarget.getBoundingClientRect()
  const clickX = event.clientX - contentRect.left
  const clickRatio = clickX / contentRect.width
  
  // 根据阅读方向和点击位置决定翻页方向
  if (readingMode.value === 'single-page' || readingMode.value === 'double-page') {
    if (readingDirection.value === 'ltr') {
      // 从左到右阅读
      if (clickRatio < 0.3) {
        // 点击左侧区域，上一页
        prevPage()
      } else if (clickRatio > 0.7) {
        // 点击右侧区域，下一页
        nextPage()
      } else {
        // 点击中间区域，切换UI显示
        toggleUI()
      }
    } else {
      // 从右到左阅读
      if (clickRatio < 0.3) {
        // 点击左侧区域，下一页
        nextPage()
      } else if (clickRatio > 0.7) {
        // 点击右侧区域，上一页
        prevPage()
      } else {
        // 点击中间区域，切换UI显示
        toggleUI()
      }
    }
  } else {
    // 连续/条漫模式下，点击切换UI显示
    toggleUI()
  }
}

// 处理鼠标滚轮
function handleWheel(event) {
  if (readingMode.value === 'continuous' || readingMode.value === 'webtoon') {
    // 连续/条漫模式下，滚轮用于滚动页面，不需要额外处理
    return
  }
  
  // 阻止默认滚动行为
  event.preventDefault()
  
  // 根据滚轮方向翻页
  if (event.deltaY > 0) {
    // 向下滚动，下一页
    nextPage()
  } else {
    // 向上滚动，上一页
    prevPage()
  }
}

// 处理键盘事件
function handleKeyDown(event) {
  switch (event.key) {
    case 'ArrowLeft':
      // 左箭头
      if (readingDirection.value === 'ltr') {
        prevPage()
      } else {
        nextPage()
      }
      event.preventDefault()
      break
    case 'ArrowRight':
      // 右箭头
      if (readingDirection.value === 'ltr') {
        nextPage()
      } else {
        prevPage()
      }
      event.preventDefault()
      break
    case 'ArrowUp':
      // 上箭头
      if (readingMode.value !== 'continuous' && readingMode.value !== 'webtoon') {
        prevPage()
        event.preventDefault()
      }
      break
    case 'ArrowDown':
      // 下箭头
      if (readingMode.value !== 'continuous' && readingMode.value !== 'webtoon') {
        nextPage()
        event.preventDefault()
      }
      break
    case ' ':
      // 空格
      toggleUI()
      event.preventDefault()
      break
    case 'f':
    case 'F':
      // F键
      toggleFullscreen()
      event.preventDefault()
      break
    case 'Escape':
      // ESC键
      if (isFullscreen.value) {
        toggleFullscreen()
      }
      break
  }
}

// 切换UI显示
function toggleUI() {
  showUI.value = !showUI.value
  
  // 如果UI显示，并且启用了自动隐藏，则设置定时器
  if (showUI.value && autoHideUI.value) {
    resetUIHideTimer()
  }
}

// 重置UI隐藏定时器
function resetUIHideTimer() {
  // 清除现有定时器
  if (uiHideTimeout.value) {
    clearTimeout(uiHideTimeout.value)
  }
  
  // 如果启用了自动隐藏，则设置新定时器
  if (autoHideUI.value) {
    uiHideTimeout.value = setTimeout(() => {
      showUI.value = false
    }, 3000) // 3秒后隐藏UI
  }
}

// 应用背景颜色
function applyBackgroundColor() {
  const colorMap = {
    'white': '#ffffff',
    'black': '#000000',
    'gray': '#333333',
    'sepia': '#f4ecd8'
  }
  
  if (readerContent.value) {
    readerContent.value.style.backgroundColor = colorMap[backgroundColor.value] || '#ffffff'
  }
  
  saveReaderSettings()
}

// 处理图片加载
function handleImageLoad() {
  // 图片加载完成后，如果是第一次加载，则预加载后续页面
  if (preloadPages.value > 0) {
    readerStore.preloadImages(currentPage.value, preloadPages.value)
  }
}

// 处理图片加载错误
function handleImageError() {
  console.error('图片加载失败')
}

// 更新阅读进度
function updateReadingProgress() {
  if (comic.value && totalPages.value > 0) {
    // 计算阅读进度百分比
    const progress = Math.round((currentPage.value / totalPages.value) * 100)
    
    // 更新漫画阅读进度
    bookshelfStore.updateReadingProgress(comic.value.id, {
      currentPage: currentPage.value,
      readingProgress: progress,
      lastReadTime: new Date().toISOString()
    })
  }
}

// 加载阅读设置
function loadReaderSettings(comicId) {
  try {
    // 尝试从本地存储加载设置
    const settingsKey = rememberSettings.value ? `reader_settings_${comicId}` : 'reader_settings_global'
    const savedSettings = localStorage.getItem(settingsKey)
    
    if (savedSettings) {
      const settings = JSON.parse(savedSettings)
      
      // 应用设置
      if (settings.readingMode) readerStore.setReadingMode(settings.readingMode)
      if (settings.zoomLevel) readerStore.setZoomLevel(settings.zoomLevel)
      if (settings.readingDirection) readingDirection.value = settings.readingDirection
      if (settings.backgroundColor) {
        backgroundColor.value = settings.backgroundColor
        applyBackgroundColor()
      }
      if (settings.preloadPages !== undefined) preloadPages.value = settings.preloadPages
      if (settings.autoHideUI !== undefined) autoHideUI.value = settings.autoHideUI
    } else {
      // 应用默认设置
      readerStore.initReaderSettings()
      applyBackgroundColor()
    }
  } catch (error) {
    console.error('加载阅读设置失败:', error)
    // 应用默认设置
    readerStore.initReaderSettings()
    applyBackgroundColor()
  }
}

// 保存阅读设置
function saveReaderSettings() {
  try {
    const settings = {
      readingMode: readerStore.readingMode,
      zoomLevel: readerStore.zoomLevel,
      readingDirection: readingDirection.value,
      backgroundColor: backgroundColor.value,
      preloadPages: preloadPages.value,
      autoHideUI: autoHideUI.value
    }
    
    // 根据是否记住设置决定存储键
    const settingsKey = rememberSettings.value && comic.value ? `reader_settings_${comic.value.id}` : 'reader_settings_global'
    
    // 保存到本地存储
    localStorage.setItem(settingsKey, JSON.stringify(settings))
  } catch (error) {
    console.error('保存阅读设置失败:', error)
  }
}

// 组件挂载时
onMounted(() => {
  // 添加鼠标移动事件监听器，用于显示UI
  window.addEventListener('mousemove', handleMouseMove)
  
  // 添加全屏变更事件监听器
  window.electronAPI.onFullscreenChange((isFullscreen) => {
    isFullscreen.value = isFullscreen
  })
  
  // 初始化UI隐藏定时器
  if (autoHideUI.value) {
    resetUIHideTimer()
  }
})

// 组件卸载时
onUnmounted(() => {
  // 移除事件监听器
  window.removeEventListener('mousemove', handleMouseMove)
  
  // 清除定时器
  if (uiHideTimeout.value) {
    clearTimeout(uiHideTimeout.value)
  }
  
  // 退出全屏
  if (isFullscreen.value) {
    window.electronAPI.exitFullscreen()
  }
})

// 处理鼠标移动
function handleMouseMove() {
  // 显示UI
  showUI.value = true
  
  // 重置UI隐藏定时器
  resetUIHideTimer()
}
</script>

<style scoped>
.reader-view {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  background-color: #ffffff;
  z-index: 1000;
}

.reader-header,
.reader-footer {
  background-color: rgba(0, 0, 0, 0.7);
  color: #fff;
  padding: 10px 20px;
  transition: opacity 0.3s ease;
}

.reader-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.reader-controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.reader-controls.left {
  flex: 1;
}

.comic-title {
  margin: 0 0 0 10px;
  font-size: 18px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 300px;
}

.reader-content {
  flex: 1;
  overflow: hidden;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  outline: none; /* 移除焦点轮廓 */
}

.reader-content.single-page,
.reader-content.double-page {
  overflow: hidden;
}

.reader-content.continuous,
.reader-content.webtoon {
  overflow-y: auto;
  overflow-x: hidden;
  justify-content: flex-start;
  align-items: flex-start;
}

.page-container {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
}

.page-container img {
  object-fit: contain;
  max-height: 100%;
  max-width: 100%;
}

.page-container img.left-page {
  margin-right: 5px;
}

.page-container img.right-page {
  margin-left: 5px;
}

.continuous-container,
.webtoon-container {
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.continuous-page,
.webtoon-page {
  margin: 10px 0;
  position: relative;
  text-align: center;
}

.continuous-page img,
.webtoon-page img {
  max-width: 100%;
  height: auto;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
}

.continuous-page .page-number {
  position: absolute;
  bottom: 10px;
  right: 10px;
  background-color: rgba(0, 0, 0, 0.7);
  color: white;
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 12px;
}

.reader-footer {
  padding: 15px 20px;
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
  gap: 20px;
}

.reader-settings {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.reader-settings h3 {
  margin: 10px 0 5px 0;
  font-size: 16px;
}

.setting-description {
  font-size: 12px;
  color: #666;
  margin-left: 10px;
}

/* 全屏模式 */
.fullscreen {
  background-color: #000;
}

/* 隐藏UI */
.ui-hidden .reader-header,
.ui-hidden .reader-footer {
  opacity: 0;
  pointer-events: none;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .reader-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }
  
  .reader-controls {
    width: 100%;
    justify-content: space-between;
  }
  
  .comic-title {
    max-width: 100%;
  }
}
</style>