import { defineStore } from 'pinia'

// 主题状态管理
export const useThemeStore = defineStore('theme', {
  // 状态
  state: () => ({
    isDarkMode: false, // 默认使用亮色主题
  }),
  
  // 动作
  actions: {
    // 初始化主题
    initTheme() {
      // 从本地存储中获取主题设置
      const savedTheme = localStorage.getItem('theme')
      if (savedTheme) {
        this.isDarkMode = savedTheme === 'dark'
      } else {
        // 如果没有保存的主题设置，则检查系统主题偏好
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
        this.isDarkMode = prefersDark
      }
    },
    
    // 切换主题
    toggleTheme() {
      this.isDarkMode = !this.isDarkMode
      // 保存主题设置到本地存储
      localStorage.setItem('theme', this.isDarkMode ? 'dark' : 'light')
    },
    
    // 设置为暗色主题
    setDarkMode() {
      this.isDarkMode = true
      localStorage.setItem('theme', 'dark')
    },
    
    // 设置为亮色主题
    setLightMode() {
      this.isDarkMode = false
      localStorage.setItem('theme', 'light')
    }
  }
})