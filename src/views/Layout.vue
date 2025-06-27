<template>
  <div class="layout">
    <!-- 侧边栏 -->
    <el-aside :width="sidebarWidth" class="sidebar">
      <div class="sidebar-header">
        <h2 class="app-title">漫画阅读器</h2>
        <el-button
          :icon="isDark ? Sunny : Moon"
          circle
          size="small"
          @click="toggleTheme"
          class="theme-toggle"
        />
      </div>
      
      <el-menu
        :default-active="$route.path"
        router
        class="sidebar-menu"
        :collapse="isCollapsed"
      >
        <el-menu-item index="/library">
          <el-icon><Collection /></el-icon>
          <span>漫画库</span>
        </el-menu-item>
        
        <el-menu-item index="/bookshelf">
          <el-icon><Reading /></el-icon>
          <span>书架</span>
        </el-menu-item>
        
        <el-menu-item index="/settings">
          <el-icon><Setting /></el-icon>
          <span>设置</span>
        </el-menu-item>
      </el-menu>
      
      <div class="sidebar-footer">
        <el-button
          :icon="isCollapsed ? Expand : Fold"
          circle
          size="small"
          @click="toggleSidebar"
        />
      </div>
    </el-aside>
    
    <!-- 主内容区 -->
    <el-main class="main-content">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </el-main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useThemeStore } from '../stores/theme'
import {
  Collection,
  Reading,
  Setting,
  Moon,
  Sunny,
  Expand,
  Fold
} from '@element-plus/icons-vue'

const themeStore = useThemeStore()
const isCollapsed = ref(false)

const isDark = computed(() => themeStore.isDark)
const sidebarWidth = computed(() => isCollapsed.value ? '64px' : '200px')

const toggleTheme = () => {
  themeStore.toggleTheme()
}

const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}
</script>

<style scoped>
.layout {
  display: flex;
  height: 100vh;
  overflow: hidden;
}

.sidebar {
  background: var(--el-bg-color-page);
  border-right: 1px solid var(--el-border-color-light);
  display: flex;
  flex-direction: column;
  transition: width 0.3s ease;
}

.sidebar-header {
  padding: 16px;
  border-bottom: 1px solid var(--el-border-color-lighter);
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 64px;
}

.app-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0;
  white-space: nowrap;
  overflow: hidden;
}

.theme-toggle {
  flex-shrink: 0;
}

.sidebar-menu {
  flex: 1;
  border: none;
  background: transparent;
}

.sidebar-menu .el-menu-item {
  height: 48px;
  line-height: 48px;
}

.sidebar-footer {
  padding: 16px;
  border-top: 1px solid var(--el-border-color-lighter);
  display: flex;
  justify-content: center;
}

.main-content {
  flex: 1;
  padding: 0;
  overflow: auto;
  background: var(--el-bg-color);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    z-index: 1000;
    height: 100vh;
  }
  
  .main-content {
    margin-left: 0;
  }
}
</style>