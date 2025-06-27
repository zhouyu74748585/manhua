<template>
  <div id="app" :class="{ 'dark': isDark }">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useThemeStore } from './stores/theme'

const themeStore = useThemeStore()
const isDark = ref(false)

onMounted(() => {
  // 初始化主题
  themeStore.initTheme()
  isDark.value = themeStore.isDark
  
  // 监听主题变化
  themeStore.$subscribe(() => {
    isDark.value = themeStore.isDark
  })
})
</script>

<style>
#app {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}

.dark {
  color-scheme: dark;
}
</style>