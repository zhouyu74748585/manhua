<template>
  <div class="library-view">
    <!-- 库信息头部 -->
    <div class="library-header">
      <div class="library-info">
        <h1>{{ library?.name || '加载中...' }}</h1>
        <p v-if="library">{{ library.description }}</p>
        <div v-if="library" class="library-meta">
          <span><el-icon><Folder /></el-icon> {{ formatLibraryType(library.type) }}</span>
          <span><el-icon><Location /></el-icon> {{ library.path }}</span>
          <span v-if="library.isPrivate" class="private-badge">
            <el-icon><Lock /></el-icon> 隐私库
          </span>
        </div>
      </div>
      
      <div class="library-actions">
        <el-button-group>
          <el-button @click="importComics" type="primary">
            <el-icon><Upload /></el-icon> 导入漫画
          </el-button>
          <el-button @click="editLibrary">
            <el-icon><Edit /></el-icon> 编辑
          </el-button>
          <el-button @click="confirmDeleteLibrary" type="danger">
            <el-icon><Delete /></el-icon> 删除
          </el-button>
        </el-button-group>
      </div>
    </div>

    <!-- 漫画列表工具栏 -->
    <div class="comics-toolbar">
      <div class="search-filter">
        <el-input
          v-model="searchQuery"
          placeholder="搜索漫画"
          prefix-icon="el-icon-search"
          clearable
          @input="handleSearch"
        />
        
        <el-dropdown @command="handleFilterChange">
          <el-button>
            <el-icon><Filter /></el-icon> 筛选
            <el-icon><ArrowDown /></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item command="all">全部</el-dropdown-item>
              <el-dropdown-item command="unread">未读</el-dropdown-item>
              <el-dropdown-item command="reading">阅读中</el-dropdown-item>
              <el-dropdown-item command="finished">已读完</el-dropdown-item>
              <el-dropdown-item divided command="showTags">按标签筛选...</el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
      
      <div class="sort-options">
        <span>排序方式:</span>
        <el-radio-group v-model="sortBy" size="small" @change="handleSortChange">
          <el-radio-button label="name">名称</el-radio-button>
          <el-radio-button label="lastRead">最近阅读</el-radio-button>
          <el-radio-button label="addTime">添加时间</el-radio-button>
        </el-radio-group>
        
        <el-button @click="toggleSortOrder" size="small">
          <el-icon>
            <component :is="sortOrder === 'asc' ? 'SortUp' : 'SortDown'" />
          </el-icon>
        </el-button>
      </div>
    </div>

    <!-- 漫画列表 -->
    <div v-if="isLoading" class="loading-container">
      <el-skeleton :rows="3" animated />
    </div>
    <div v-else-if="filteredComics.length === 0" class="empty-container">
      <el-empty description="没有找到漫画" />
    </div>
    <div v-else class="comics-grid">
      <comic-card 
        v-for="comic in filteredComics" 
        :key="comic.id" 
        :comic="comic"
        @click="openComic(comic.id)"
        @context-menu="handleComicContextMenu"
      />
    </div>

    <!-- 编辑漫画库对话框 -->
    <el-dialog
      v-model="showEditLibraryDialog"
      title="编辑漫画库"
      width="500px"
    >
      <el-form v-if="editingLibrary" :model="editingLibrary" label-width="100px">
        <el-form-item label="名称" required>
          <el-input v-model="editingLibrary.name" placeholder="请输入漫画库名称" />
        </el-form-item>
        <el-form-item label="类型" required>
          <el-select v-model="editingLibrary.type" placeholder="请选择漫画库类型" style="width: 100%">
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
            <el-input v-model="editingLibrary.path" placeholder="请输入路径" />
            <el-button @click="browsePath">浏览...</el-button>
          </div>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="editingLibrary.description" type="textarea" placeholder="请输入描述信息" />
        </el-form-item>
        <el-form-item label="隐私库">
          <el-switch v-model="editingLibrary.isPrivate" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showEditLibraryDialog = false">取消</el-button>
          <el-button type="primary" @click="submitEditLibrary">保存</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 标签筛选对话框 -->
    <el-dialog
      v-model="showTagsFilterDialog"
      title="按标签筛选"
      width="400px"
    >
      <div class="tags-filter">
        <el-checkbox-group v-model="selectedTags">
          <el-checkbox 
            v-for="tag in availableTags" 
            :key="tag" 
            :label="tag"
          >
            {{ tag }}
          </el-checkbox>
        </el-checkbox-group>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showTagsFilterDialog = false">取消</el-button>
          <el-button type="primary" @click="applyTagsFilter">应用</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 导入漫画对话框 -->
    <el-dialog
      v-model="showImportDialog"
      title="导入漫画"
      width="500px"
    >
      <div class="import-options">
        <el-radio-group v-model="importType">
          <el-radio label="folder">从文件夹导入</el-radio>
          <el-radio label="files">选择文件导入</el-radio>
        </el-radio-group>
        
        <div class="import-path-input">
          <el-input v-model="importPath" placeholder="请选择路径" readonly />
          <el-button @click="browseImportPath">浏览...</el-button>
        </div>
        
        <div v-if="importFiles.length > 0" class="import-files-list">
          <p>已选择 {{ importFiles.length }} 个文件:</p>
          <el-scrollbar height="150px">
            <ul>
              <li v-for="(file, index) in importFiles" :key="index">{{ file }}</li>
            </ul>
          </el-scrollbar>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showImportDialog = false">取消</el-button>
          <el-button type="primary" @click="submitImport" :loading="isImporting">导入</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useLibraryStore } from '../store/library'
import { useBookshelfStore } from '../store/bookshelf'
import { usePrivacyStore } from '../store/privacy'
import ComicCard from '../components/ComicCard.vue'
import { Folder, Location, Lock, Upload, Edit, Delete, Filter, ArrowDown, SortUp, SortDown } from '@element-plus/icons-vue'
import { ElMessageBox, ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const libraryStore = useLibraryStore()
const bookshelfStore = useBookshelfStore()
const privacyStore = usePrivacyStore()

// 获取路由参数中的库ID
const libraryId = computed(() => route.params.id)

// 当前库信息
const library = computed(() => libraryStore.currentLibrary)

// 加载状态
const isLoading = computed(() => libraryStore.isLoading || bookshelfStore.isLoading)

// 搜索和筛选
const searchQuery = ref('')
const readStatusFilter = ref('all')
const selectedTags = ref([])
const showTagsFilterDialog = ref(false)

// 排序
const sortBy = ref('name')
const sortOrder = ref('asc')

// 编辑库
const showEditLibraryDialog = ref(false)
const editingLibrary = ref(null)

// 导入漫画
const showImportDialog = ref(false)
const importType = ref('folder')
const importPath = ref('')
const importFiles = ref([])
const isImporting = ref(false)

// 计算属性：当前库中的漫画
const libraryComics = computed(() => {
  return bookshelfStore.visibleComics.filter(comic => comic.libraryId === libraryId.value)
})

// 计算属性：筛选后的漫画
const filteredComics = computed(() => {
  let result = [...libraryComics.value]
  
  // 应用搜索
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(comic => {
      return (
        comic.name.toLowerCase().includes(query) ||
        (comic.author && comic.author.toLowerCase().includes(query)) ||
        (comic.tags && comic.tags.some(tag => tag.toLowerCase().includes(query)))
      )
    })
  }
  
  // 应用阅读状态筛选
  if (readStatusFilter.value !== 'all') {
    switch (readStatusFilter.value) {
      case 'unread':
        result = result.filter(comic => !comic.readingProgress || comic.readingProgress === 0)
        break
      case 'reading':
        result = result.filter(comic => comic.readingProgress > 0 && comic.readingProgress < 100)
        break
      case 'finished':
        result = result.filter(comic => comic.readingProgress === 100)
        break
    }
  }
  
  // 应用标签筛选
  if (selectedTags.value.length > 0) {
    result = result.filter(comic => {
      return comic.tags && selectedTags.value.every(tag => comic.tags.includes(tag))
    })
  }
  
  // 应用排序
  result.sort((a, b) => {
    let valueA, valueB
    
    switch (sortBy.value) {
      case 'name':
        valueA = a.name.toLowerCase()
        valueB = b.name.toLowerCase()
        break
      case 'lastRead':
        valueA = a.lastReadTime ? new Date(a.lastReadTime).getTime() : 0
        valueB = b.lastReadTime ? new Date(b.lastReadTime).getTime() : 0
        break
      case 'addTime':
        valueA = a.addTime ? new Date(a.addTime).getTime() : 0
        valueB = b.addTime ? new Date(b.addTime).getTime() : 0
        break
      default:
        valueA = a.name.toLowerCase()
        valueB = b.name.toLowerCase()
    }
    
    // 根据排序顺序返回比较结果
    if (sortOrder.value === 'asc') {
      return valueA > valueB ? 1 : valueA < valueB ? -1 : 0
    } else {
      return valueA < valueB ? 1 : valueA > valueB ? -1 : 0
    }
  })
  
  return result
})

// 计算属性：可用的标签列表
const availableTags = computed(() => {
  const tagsSet = new Set()
  
  libraryComics.value.forEach(comic => {
    if (comic.tags && Array.isArray(comic.tags)) {
      comic.tags.forEach(tag => tagsSet.add(tag))
    }
  })
  
  return Array.from(tagsSet).sort()
})

// 监听库ID变化，加载库信息
watch(libraryId, async (newId) => {
  if (newId) {
    await loadLibraryData(newId)
  }
}, { immediate: true })

// 加载库数据
async function loadLibraryData(id) {
  try {
    // 加载库详情
    await libraryStore.fetchLibraryById(id)
    
    // 重置筛选条件
    searchQuery.value = ''
    readStatusFilter.value = 'all'
    selectedTags.value = []
    
    // 检查是否是隐私库，如果是且未授权，则请求授权
    if (library.value && library.value.isPrivate && !privacyStore.isPrivacyModeAuthorized) {
      await privacyStore.requestPrivacyModeAccess()
      
      // 如果授权失败，返回首页
      if (!privacyStore.isPrivacyModeAuthorized) {
        router.push('/')
        return
      }
    }
  } catch (error) {
    console.error('加载库数据失败:', error)
    ElMessage.error('加载库数据失败')
  }
}

// 打开漫画
function openComic(comicId) {
  router.push(`/reader/${comicId}`)
}

// 处理漫画右键菜单
function handleComicContextMenu(comic, event) {
  // 阻止默认右键菜单
  event.preventDefault()
  
  // 显示自定义右键菜单
  // 这里可以使用Element Plus的Dropdown或自定义菜单组件
}

// 处理搜索
function handleSearch() {
  // 搜索逻辑已在计算属性中处理
}

// 处理筛选变更
function handleFilterChange(command) {
  if (command === 'showTags') {
    // 显示标签筛选对话框
    showTagsFilterDialog.value = true
  } else {
    // 设置阅读状态筛选
    readStatusFilter.value = command
  }
}

// 应用标签筛选
function applyTagsFilter() {
  showTagsFilterDialog.value = false
  // 筛选逻辑已在计算属性中处理
}

// 处理排序变更
function handleSortChange() {
  // 排序逻辑已在计算属性中处理
}

// 切换排序顺序
function toggleSortOrder() {
  sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
}

// 编辑库
function editLibrary() {
  if (library.value) {
    // 创建一个副本以避免直接修改原对象
    editingLibrary.value = { ...library.value }
    showEditLibraryDialog.value = true
  }
}

// 浏览路径
async function browsePath() {
  try {
    // 根据库类型选择不同的对话框类型
    let options = {
      title: '选择路径',
      properties: ['openDirectory']
    }
    
    if (editingLibrary.value.type === 'archive') {
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
      editingLibrary.value.path = result.filePaths[0]
    }
  } catch (error) {
    console.error('浏览路径失败:', error)
  }
}

// 提交编辑库
async function submitEditLibrary() {
  // 表单验证
  if (!editingLibrary.value.name || !editingLibrary.value.path) {
    ElMessage.error('请填写必填字段')
    return
  }
  
  try {
    // 更新库
    const updatedLibrary = await libraryStore.updateLibrary(libraryId.value, editingLibrary.value)
    
    if (updatedLibrary) {
      ElMessage.success('漫画库更新成功')
      showEditLibraryDialog.value = false
      
      // 更新隐私状态
      await privacyStore.setLibraryPrivacy(updatedLibrary.id, updatedLibrary.isPrivate)
    }
  } catch (error) {
    console.error('更新漫画库失败:', error)
    ElMessage.error('更新漫画库失败')
  }
}

// 确认删除库
function confirmDeleteLibrary() {
  ElMessageBox.confirm(
    '确定要删除这个漫画库吗？这将移除库中的所有漫画记录（不会删除实际文件）。',
    '删除确认',
    {
      confirmButtonText: '删除',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      // 删除库
      const success = await libraryStore.deleteLibrary(libraryId.value)
      
      if (success) {
        ElMessage.success('漫画库删除成功')
        router.push('/')
      }
    } catch (error) {
      console.error('删除漫画库失败:', error)
      ElMessage.error('删除漫画库失败')
    }
  }).catch(() => {
    // 用户取消删除
  })
}

// 导入漫画
function importComics() {
  // 重置导入表单
  importType.value = 'folder'
  importPath.value = ''
  importFiles.value = []
  
  // 显示导入对话框
  showImportDialog.value = true
}

// 浏览导入路径
async function browseImportPath() {
  try {
    let options = {}
    
    if (importType.value === 'folder') {
      options = {
        title: '选择文件夹',
        properties: ['openDirectory']
      }
    } else {
      options = {
        title: '选择文件',
        properties: ['openFile', 'multiSelections'],
        filters: [
          { name: '漫画文件', extensions: ['zip', 'rar', '7z', 'cbz', 'cbr', 'cb7', 'pdf'] }
        ]
      }
    }
    
    // 调用Electron API打开对话框
    const result = await window.electronAPI.openDirectoryDialog(options)
    
    if (!result.canceled) {
      if (importType.value === 'folder') {
        if (result.filePaths.length > 0) {
          importPath.value = result.filePaths[0]
          importFiles.value = []
        }
      } else {
        importFiles.value = result.filePaths
        importPath.value = result.filePaths.length > 0 ? '已选择多个文件' : ''
      }
    }
  } catch (error) {
    console.error('浏览路径失败:', error)
  }
}

// 提交导入
async function submitImport() {
  // 验证是否选择了路径或文件
  if (importType.value === 'folder' && !importPath.value) {
    ElMessage.error('请选择文件夹')
    return
  }
  
  if (importType.value === 'files' && importFiles.value.length === 0) {
    ElMessage.error('请选择文件')
    return
  }
  
  isImporting.value = true
  
  try {
    // 准备导入路径
    const paths = importType.value === 'folder' ? [importPath.value] : importFiles.value
    
    // 调用导入API
    const result = await libraryStore.importComicsToLibrary(libraryId.value, paths)
    
    if (result) {
      ElMessage.success(`成功导入 ${result.imported} 本漫画`)
      showImportDialog.value = false
      
      // 重新加载漫画列表
      await bookshelfStore.fetchAllComics()
    }
  } catch (error) {
    console.error('导入漫画失败:', error)
    ElMessage.error('导入漫画失败')
  } finally {
    isImporting.value = false
  }
}

// 格式化库类型
function formatLibraryType(type) {
  const typeMap = {
    'local_folder': '本地文件夹',
    'archive': '压缩文件',
    'smb': '网络共享 (SMB)',
    'ftp': 'FTP/SFTP',
    'webdav': 'WebDAV',
    'nfs': 'NFS'
  }
  
  return typeMap[type] || type
}

// 组件挂载时加载数据
onMounted(async () => {
  // 初始化隐私设置
  await privacyStore.initPrivacySettings()
  
  // 加载漫画列表
  await bookshelfStore.fetchAllComics()
})
</script>

<style scoped>
.library-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.library-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border-color);
}

.library-info h1 {
  font-size: 24px;
  margin: 0 0 10px 0;
  color: var(--primary-color);
}

.library-info p {
  margin: 0 0 15px 0;
  color: var(--text-color);
  opacity: 0.8;
}

.library-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  font-size: 14px;
}

.library-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
}

.private-badge {
  color: var(--primary-color);
  font-weight: bold;
}

.comics-toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.search-filter {
  display: flex;
  gap: 10px;
  flex: 1;
  max-width: 500px;
}

.sort-options {
  display: flex;
  align-items: center;
  gap: 10px;
}

.comics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 20px;
}

.loading-container,
.empty-container {
  padding: 40px 0;
  text-align: center;
}

.path-input,
.import-path-input {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.path-input .el-input,
.import-path-input .el-input {
  flex: 1;
}

.tags-filter {
  max-height: 300px;
  overflow-y: auto;
}

.tags-filter .el-checkbox {
  display: block;
  margin-right: 0;
  margin-bottom: 10px;
}

.import-options {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.import-files-list {
  margin-top: 10px;
}

.import-files-list ul {
  margin: 0;
  padding: 0 0 0 20px;
}

.import-files-list li {
  margin-bottom: 5px;
  word-break: break-all;
}

@media (max-width: 768px) {
  .library-header {
    flex-direction: column;
    gap: 15px;
  }
  
  .comics-toolbar {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }
  
  .comics-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
    gap: 15px;
  }
}
</style>