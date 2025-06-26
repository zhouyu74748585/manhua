<template>
  <div class="app-container">
    <!-- 应用头部 -->
    <header class="app-header" v-if="!isReaderMode">
      <div class="logo">
        <img src="./assets/logo.svg" alt="漫画阅读器" />
        <span>漫画阅读器</span>
      </div>
      <div class="header-controls">
        <el-switch
          v-model="isDarkMode"
          active-text="暗色"
          inactive-text="亮色"
          @change="toggleTheme"
        />
        <el-dropdown>
          <el-button>
            <el-icon><Setting /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item @click="openSettings">设置</el-dropdown-item>
              <el-dropdown-item @click="togglePrivacyMode">{{ isPrivacyMode ? '退出隐私模式' : '进入隐私模式' }}</el-dropdown-item>
              <el-dropdown-item @click="checkForUpdates">检查更新</el-dropdown-item>
              <el-dropdown-item @click="about">关于</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </header>

    <!-- 主内容区 -->
    <main class="app-main">
      <router-view />
    </main>

    <!-- 应用底部 -->
    <footer class="app-footer" v-if="!isReaderMode">
      <p>© {{ new Date().getFullYear() }} 漫画阅读器</p>
    </footer>
  </div>
</template>

<script setup>
import { ref, provide, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Setting } from '@element-plus/icons-vue'
import { useThemeStore } from './store/theme'
import { usePrivacyStore } from './store/privacy'

const router = useRouter()
const route = useRoute()
const themeStore = useThemeStore()
const privacyStore = usePrivacyStore()

// 主题设置
const isDarkMode = ref(themeStore.isDarkMode)

// 隐私模式设置
const isPrivacyMode = computed(() => privacyStore.isPrivacyMode)

// 是否处于阅读模式（全屏阅读时隐藏头部和底部）
const isReaderMode = computed(() => {
  return route.path.includes('/reader')
})

// 切换主题
function toggleTheme() {
  themeStore.toggleTheme()
  document.documentElement.classList.toggle('dark-mode', isDarkMode.value)
}

// 切换隐私模式
function togglePrivacyMode() {
  if (!isPrivacyMode.value) {
    // 进入隐私模式前可能需要验证
    privacyStore.requestPrivacyModeAccess()
  } else {
    // 直接退出隐私模式
    privacyStore.exitPrivacyMode()
  }
}

// 打开设置页面
function openSettings() {
  router.push('/settings')
}

// 检查更新
function checkForUpdates() {
  // 调用Electron API检查更新
  window.electronAPI.checkForUpdates()
    .then(updateInfo => {
      if (updateInfo.hasUpdate) {
        // 显示更新提示
        ElMessageBox.confirm(
          `发现新版本 ${updateInfo.version}，是否立即更新？`,
          '更新提示',
          {
            confirmButtonText: '更新',
            cancelButtonText: '稍后',
            type: 'info',
          }
        ).then(() => {
          // 用户选择更新
          // 这里可以调用下载更新的方法
        })
      } else {
        // 没有更新
        ElMessage({
          message: '当前已是最新版本',
          type: 'success',
        })
      }
    })
    .catch(error => {
      console.error('检查更新失败:', error)
      ElMessage.error('检查更新失败，请稍后再试')
    })
}

// 关于页面
function about() {
  ElMessageBox.alert(
    '漫画阅读器 v1.0.0\n一款现代化的漫画阅读软件',
    '关于',
    {
      confirmButtonText: '确定',
    }
  )
}

// 在组件挂载时应用当前主题
onMounted(() => {
  document.documentElement.classList.toggle('dark-mode', isDarkMode.value)
})

// 提供主题变量给子组件
provide('isDarkMode', isDarkMode)
</script>

<style>
/* 全局样式 */
:root {
  --primary-color: #4a69bd;
  --secondary-color: #6a89cc;
  --background-color: #f5f6fa;
  --text-color: #2f3542;
  --border-color: #dfe4ea;
  --card-background: #ffffff;
  --header-background: #ffffff;
  --footer-background: #f1f2f6;
  --shadow-color: rgba(0, 0, 0, 0.1);
}

/* 暗色主题变量 */
.dark-mode {
  --primary-color: #546de5;
  --secondary-color: #778beb;
  --background-color: #2f3542;
  --text-color: #f5f6fa;
  --border-color: #57606f;
  --card-background: #353b48;
  --header-background: #2f3542;
  --footer-background: #2f3542;
  --shadow-color: rgba(0, 0, 0, 0.3);
}

body {
  margin: 0;
  padding: 0;
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', '微软雅黑', Arial, sans-serif;
  background-color: var(--background-color);
  color: var(--text-color);
  transition: background-color 0.3s, color 0.3s;
}

.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  height: 60px;
  background-color: var(--header-background);
  box-shadow: 0 2px 8px var(--shadow-color);
  z-index: 100;
}

.logo {
  display: flex;
  align-items: center;
}

.logo img {
  height: 32px;
  margin-right: 10px;
}

.logo span {
  font-size: 18px;
  font-weight: bold;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 16px;
}

.app-main {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.app-footer {
  padding: 15px 20px;
  text-align: center;
  background-color: var(--footer-background);
  font-size: 14px;
}

/* 当处于阅读模式时，让内容区域占满整个屏幕 */
.app-container:has(.reader-view) .app-main {
  padding: 0;
}
</style>