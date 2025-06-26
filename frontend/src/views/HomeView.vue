<template>
  <div class="home-view">
    <!-- 欢迎区域 -->
    <div class="welcome-section">
      <h1>欢迎使用漫画阅读器</h1>
      <p>一款现代化、简约风格的漫画阅读软件</p>
    </div>

    <!-- 最近阅读区域 -->
    <div class="recent-section">
      <div class="section-header">
        <h2>最近阅读</h2>
        <el-button type="primary" plain @click="viewAllComics">查看全部</el-button>
      </div>
      
      <div v-if="isLoading" class="loading-container">
        <el-skeleton :rows="1" animated />
      </div>
      <div v-else-if="recentComics.length === 0" class="empty-container">
        <el-empty description="暂无最近阅读记录" />
      </div>
      <div v-else class="comics-grid">
        <comic-card 
          v-for="comic in recentComics" 
          :key="comic.id" 
          :comic="comic"
          @click="openComic(comic.id)"
        />
      </div>
    </div>

    <!-- 漫画库区域 -->
    <div class="libraries-section">
      <div class="section-header">
        <h2>漫画库</h2>
        <el-button type="primary" @click="createLibrary">创建漫画库</el-button>
      </div>
      
      <div v-if="isLoading" class="loading-container">
        <el-skeleton :rows="1" animated />
      </div>
      <div v-else-if="libraries.length === 0" class="empty-container">
        <el-empty description="暂无漫画库，点击'创建漫画库'按钮创建一个新的漫画库" />
      </div>
      <div v-else class="libraries-grid">
        <library-card 
          v-for="library in visibleLibraries" 
          :key="library.id" 
          :library="library"
          @click="openLibrary(library.id)"
        />
      </div>
    </div>

    <!-- 创建漫画库对话框 -->
    <el-dialog
      v-model="showCreateLibraryDialog"
      title="创建漫画库"
      width="500px"
    >
      <el-form :model="newLibrary" label-width="100px">
        <el-form-item label="名称" required>
          <el-input v-model="newLibrary.name" placeholder="请输入漫画库名称" />
        </el-form-item>
        <el-form-item label="类型" required>
          <el-select v-model="newLibrary.type" placeholder="请选择漫画库类型" style="width: 100%">
            <el-option label="本地文件夹" value="local_folder" />
            <el-option label="压缩文件" value="archive" />
            <el-option label="网络共享 (SMB)" value="smb" />
            <el-option label="FTP/SFTP" value="ftp" />
            <el-option label="WebDAV" value="webdav" />
            <el-option label="NFS" value="nfs" />
          </el-select>
        </el-form-item>
        <el-form-item label="路径" required>
          <div class="path-input">
            <el-input v-model="newLibrary.path" placeholder="请输入路径" />
            <el-button @click="browsePath">浏览...</el-button>
          </div>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="newLibrary.description" type="textarea" placeholder="请输入描述信息" />
        </el-form-item>
        <el-form-item label="隐私库">
          <el-switch v-model="newLibrary.isPrivate" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showCreateLibraryDialog = false">取消</el-button>
          <el-button type="primary" @click="submitCreateLibrary">创建</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useLibraryStore } from '../store/library'
import { useBookshelfStore } from '../store/bookshelf'
import { usePrivacyStore } from '../store/privacy'
import ComicCard from '../components/ComicCard.vue'
import LibraryCard from '../components/LibraryCard.vue'

const router = useRouter()
const libraryStore = useLibraryStore()
const bookshelfStore = useBookshelfStore()
const privacyStore = usePrivacyStore()

// 加载状态
const isLoading = computed(() => libraryStore.isLoading || bookshelfStore.isLoading)

// 漫画库列表
const libraries = computed(() => libraryStore.libraries)

// 可见的漫画库（根据隐私设置）
const visibleLibraries = computed(() => {
  if (privacyStore.isPrivacyModeAuthorized) {
    return libraries.value
  } else {
    return libraries.value.filter(library => !library.isPrivate)
  }
})

// 最近阅读的漫画
const recentComics = computed(() => {
  // 按最近阅读时间排序，并限制数量为6
  return [...bookshelfStore.visibleComics]
    .filter(comic => comic.lastReadTime)
    .sort((a, b) => {
      return new Date(b.lastReadTime) - new Date(a.lastReadTime)
    })
    .slice(0, 6)
})

// 创建漫画库相关
const showCreateLibraryDialog = ref(false)
const newLibrary = ref({
  name: '',
  type: 'local_folder',
  path: '',
  description: '',
  isPrivate: false
})

// 打开漫画
function openComic(comicId) {
  router.push(`/reader/${comicId}`)
}

// 查看全部漫画
function viewAllComics() {
  router.push('/bookshelf')
}

// 打开漫画库
function openLibrary(libraryId) {
  router.push(`/library/${libraryId}`)
}

// 创建漫画库
function createLibrary() {
  // 重置表单
  newLibrary.value = {
    name: '',
    type: 'local_folder',
    path: '',
    description: '',
    isPrivate: false
  }
  
  // 显示对话框
  showCreateLibraryDialog.value = true
}

// 浏览路径
async function browsePath() {
  try {
    // 根据库类型选择不同的对话框类型
    let options = {
      title: '选择路径',
      properties: ['openDirectory']
    }
    
    if (newLibrary.value.type === 'archive') {
      options = {
        title: '选择压缩文件',
        properties: ['openFile'],
        filters: [
          { name: '压缩文件', extensions: ['zip', 'rar', '7z', 'cbz', 'cbr', 'cb7'] }
        ]
      }
    }
    
    // 调用Electron API打开对话框
    const result = await window.electronAPI.openDirectoryDialog(options)
    
    if (!result.canceled && result.filePaths.length > 0) {
      newLibrary.value.path = result.filePaths[0]
    }
  } catch (error) {
    console.error('浏览路径失败:', error)
  }
}

// 提交创建漫画库
async function submitCreateLibrary() {
  // 表单验证
  if (!newLibrary.value.name || !newLibrary.value.path) {
    ElMessage.error('请填写必填字段')
    return
  }
  
  try {
    // 创建漫画库
    const library = await libraryStore.createLibrary(newLibrary.value)
    
    if (library) {
      ElMessage.success('漫画库创建成功')
      showCreateLibraryDialog.value = false
      
      // 如果是隐私库，设置隐私状态
      if (newLibrary.value.isPrivate) {
        await privacyStore.setLibraryPrivacy(library.id, true)
      }
    }
  } catch (error) {
    console.error('创建漫画库失败:', error)
    ElMessage.error('创建漫画库失败')
  }
}

// 组件挂载时加载数据
onMounted(async () => {
  // 加载漫画库列表
  await libraryStore.fetchLibraries()
  
  // 加载漫画列表
  await bookshelfStore.fetchAllComics()
  
  // 初始化隐私设置
  await privacyStore.initPrivacySettings()
})
</script>

<style scoped>
.home-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.welcome-section {
  text-align: center;
  margin-bottom: 40px;
}

.welcome-section h1 {
  font-size: 28px;
  margin-bottom: 10px;
  color: var(--primary-color);
}

.welcome-section p {
  font-size: 16px;
  color: var(--text-color);
  opacity: 0.8;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.section-header h2 {
  font-size: 20px;
  margin: 0;
}

.recent-section,
.libraries-section {
  margin-bottom: 40px;
}

.comics-grid,
.libraries-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 20px;
}

.loading-container,
.empty-container {
  padding: 40px 0;
  text-align: center;
}

.path-input {
  display: flex;
  gap: 10px;
}

.path-input .el-input {
  flex: 1;
}

@media (max-width: 768px) {
  .comics-grid,
  .libraries-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 15px;
  }
}
</style>