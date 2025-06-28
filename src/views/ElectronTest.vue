<template>
  <div class="electron-test">
    <h2>Electron API 测试</h2>
    
    <div class="test-section">
      <h3>环境检测</h3>
      <p>Electron API 可用: {{ isElectronAvailable ? '是' : '否' }}</p>
      <p v-if="appVersion">应用版本: {{ appVersion }}</p>
    </div>
    
    <div class="test-section" v-if="isElectronAvailable">
      <h3>文件夹选择测试</h3>
      <el-button @click="selectFolder" type="primary">选择文件夹</el-button>
      <p v-if="selectedFolder">选择的文件夹: {{ selectedFolder }}</p>
    </div>
    
    <div class="test-section" v-if="selectedFolder">
      <h3>漫画页面测试</h3>
      <el-input-number v-model="testPageNumber" :min="1" :max="totalTestPages" />
      <el-button @click="loadTestPage" type="success">加载页面</el-button>
      <p v-if="totalTestPages > 0">总页数: {{ totalTestPages }}</p>
      <div v-if="testPageUrl" class="test-image">
        <img :src="testPageUrl" alt="测试页面" @load="onImageLoad" @error="onImageError" />
      </div>
      <p v-if="imageStatus">图片状态: {{ imageStatus }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const isElectronAvailable = ref(false)
const appVersion = ref('')
const selectedFolder = ref('')
const testPageNumber = ref(1)
const totalTestPages = ref(0)
const testPageUrl = ref('')
const imageStatus = ref('')

onMounted(async () => {
  // 检查Electron API是否可用
  if (window.electronAPI) {
    isElectronAvailable.value = true
    try {
      appVersion.value = await window.electronAPI.getAppVersion()
    } catch (error) {
      console.error('获取应用版本失败:', error)
    }
  }
})

const selectFolder = async () => {
  if (!window.electronAPI) return
  
  try {
    const result = await window.electronAPI.selectFolder()
    if (!result.canceled && result.filePaths.length > 0) {
      selectedFolder.value = result.filePaths[0]
      // 获取总页数
      try {
        totalTestPages.value = await window.electronAPI.getMangaPageCount(selectedFolder.value)
        ElMessage.success(`检测到 ${totalTestPages.value} 页图片`)
      } catch (error) {
        console.error('获取页数失败:', error)
        ElMessage.error('获取页数失败')
      }
    }
  } catch (error) {
    console.error('选择文件夹失败:', error)
    ElMessage.error('选择文件夹失败')
  }
}

const loadTestPage = async () => {
  if (!window.electronAPI || !selectedFolder.value) return
  
  try {
    imageStatus.value = '加载中...'
    testPageUrl.value = await window.electronAPI.getMangaPage(selectedFolder.value, testPageNumber.value)
    console.log('页面URL:', testPageUrl.value)
  } catch (error) {
    console.error('加载页面失败:', error)
    imageStatus.value = '加载失败'
    ElMessage.error('加载页面失败')
  }
}

const onImageLoad = () => {
  imageStatus.value = '加载成功'
  ElMessage.success('图片加载成功')
}

const onImageError = () => {
  imageStatus.value = '图片加载失败'
  ElMessage.error('图片加载失败')
}
</script>

<style scoped>
.electron-test {
  padding: 20px;
  max-width: 800px;
  margin: 0 auto;
}

.test-section {
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}

.test-section h3 {
  margin-top: 0;
  color: #409eff;
}

.test-image {
  margin-top: 20px;
  text-align: center;
}

.test-image img {
  max-width: 100%;
  max-height: 400px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.el-button {
  margin-right: 10px;
  margin-bottom: 10px;
}
</style>