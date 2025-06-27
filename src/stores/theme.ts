import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useThemeStore = defineStore('theme', () => {
  const isDark = ref(false)
  const theme = ref<'light' | 'dark'>('light')

  // 初始化主题
  const initTheme = () => {
    const savedTheme = localStorage.getItem('theme')
    if (savedTheme) {
      theme.value = savedTheme as 'light' | 'dark'
    } else {
      // 检测系统主题偏好
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      theme.value = prefersDark ? 'dark' : 'light'
    }
    applyTheme()
  }

  // 切换主题
  const toggleTheme = () => {
    theme.value = theme.value === 'light' ? 'dark' : 'light'
    applyTheme()
    localStorage.setItem('theme', theme.value)
  }

  // 应用主题
  const applyTheme = () => {
    isDark.value = theme.value === 'dark'
    const html = document.documentElement
    
    if (isDark.value) {
      html.classList.add('dark')
      html.setAttribute('data-theme', 'dark')
    } else {
      html.classList.remove('dark')
      html.setAttribute('data-theme', 'light')
    }
  }

  // 设置特定主题
  const setTheme = (newTheme: 'light' | 'dark') => {
    theme.value = newTheme
    applyTheme()
    localStorage.setItem('theme', theme.value)
  }

  return {
    isDark,
    theme,
    initTheme,
    toggleTheme,
    setTheme
  }
})