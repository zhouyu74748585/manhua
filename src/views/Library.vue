<template>
  <div class="library-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h1>漫画库管理</h1>
        <p class="subtitle">管理您的漫画收藏来源</p>
      </div>
      <div class="header-right">
        <el-button type="primary" @click="showCreateDialog = true">
          <el-icon><Plus /></el-icon>
          添加漫画库
        </el-button>
      </div>
    </div>

    <!-- 漫画库列表 -->
    <div class="library-list">
      <el-row :gutter="20">
        <el-col
          v-for="library in libraries"
          :key="library.id"
          :xs="24"
          :sm="12"
          :md="8"
          :lg="6"
        >
          <el-card class="library-card" shadow="hover">
            <template #header>
              <div class="card-header">
                <div class="library-info">
                  <h3 class="library-name">{{ library.name }}</h3>
                  <el-tag :type="getLibraryTypeColor(library.type)" size="small">
                    {{ getLibraryTypeText(library.type) }}
                  </el-tag>
                </div>
                <el-dropdown @command="handleLibraryAction">
                  <el-button :icon="MoreFilled" circle size="small" />
                  <template #dropdown>
                    <el-dropdown-menu>
                      <el-dropdown-item :command="{ action: 'scan', library }">
                        <el-icon><Refresh /></el-icon>
                        扫描
                      </el-dropdown-item>
                      <el-dropdown-item :command="{ action: 'edit', library }">
                        <el-icon><Edit /></el-icon>
                        编辑
                      </el-dropdown-item>
                      <el-dropdown-item :command="{ action: 'delete', library }" divided>
                        <el-icon><Delete /></el-icon>
                        删除
                      </el-dropdown-item>
                    </el-dropdown-menu>
                  </template>
                </el-dropdown>
              </div>
            </template>
            
            <div class="library-content">
              <div class="library-path">
                <el-icon><Folder /></el-icon>
                <span class="path-text">{{ library.path }}</span>
              </div>
              
              <div class="library-stats">
                <div class="stat-item">
                  <span class="stat-label">漫画数量:</span>
                  <span class="stat-value">{{ library.mangaCount }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">创建时间:</span>
                  <span class="stat-value">{{ formatDate(library.createdAt) }}</span>
                </div>
              </div>
              
              <div class="library-actions">
                <el-button
                  size="small"
                  @click="setCurrentLibrary(library.id)"
                  :type="currentLibraryId === library.id ? 'primary' : 'default'"
                >
                  {{ currentLibraryId === library.id ? '当前库' : '切换到此库' }}
                </el-button>
                <el-button
                  size="small"
                  @click="scanLibrary(library.id)"
                  :loading="loading && scanningLibraryId === library.id"
                >
                  扫描
                </el-button>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
      
      <!-- 空状态 -->
      <el-empty v-if="libraries.length === 0" description="暂无漫画库">
        <el-button type="primary" @click="showCreateDialog = true">
          创建第一个漫画库
        </el-button>
      </el-empty>
    </div>

    <!-- 创建/编辑漫画库对话框 -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingLibrary ? '编辑漫画库' : '创建漫画库'"
      width="600px"
      @close="resetForm"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入漫画库名称" />
        </el-form-item>
        
        <el-form-item label="类型" prop="type">
          <el-select v-model="form.type" placeholder="请选择类型" style="width: 100%">
            <el-option label="本地文件夹" value="LOCAL" />
            <el-option label="SMB/CIFS" value="SMB" />
            <el-option label="FTP/SFTP" value="FTP" />
            <el-option label="WEBDAV" value="WEBDAV" />
            <el-option label="NFS" value="NFS" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="路径" prop="path" v-if="form.type === 'LOCAL'">
          <el-input
            v-model="form.path"
            placeholder="请输入文件夹路径，如：/Users/username/Documents/Manga"
          >
            <template #append>
              <el-button
                @click="selectFolder"
                :icon="Folder"
                type="primary"
              >
                选择文件夹
              </el-button>
            </template>
          </el-input>
          <div class="form-tip">
            <el-text size="small" type="info">
              提示：在Web环境中，点击"选择文件夹"将打开文件夹选择器，或者您可以直接输入完整的文件夹路径
            </el-text>
          </div>
        </el-form-item>
        
        <!-- 其他类型的路径输入 -->
        <el-form-item label="路径" prop="path" v-if="form.type !== 'LOCAL'">
          <el-input
            v-model="form.path"
            :placeholder="getPathPlaceholder(form.type)"
          />
        </el-form-item>
        
        <el-form-item label="描述">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入描述（可选）"
          />
        </el-form-item>
        
        <el-form-item>
          <el-checkbox v-model="form.isPrivate">
            设为隐私库（需要密码访问）
          </el-checkbox>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          {{ editingLibrary ? '更新' : '创建' }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useLibraryStore } from '../stores/library'
import type { MangaLibrary } from '../types'
import {
  Plus,
  MoreFilled,
  Refresh,
  Edit,
  Delete,
  Folder
} from '@element-plus/icons-vue'

const libraryStore = useLibraryStore()
const showCreateDialog = ref(false)
const editingLibrary = ref<MangaLibrary | null>(null)
const submitting = ref(false)
const scanningLibraryId = ref<string | null>(null)
const formRef = ref()

// 表单数据
const form = ref({
  name: '',
  type: 'LOCAL' as MangaLibrary['type'],
  path: '',
  description: '',
  isPrivate: false
})

// 表单验证规则
const rules = {
  name: [
    { required: true, message: '请输入漫画库名称', trigger: 'blur' }
  ],
  type: [
    { required: true, message: '请选择类型', trigger: 'change' }
  ],
  path: [
    { required: true, message: '请输入路径', trigger: 'blur' }
  ]
}

// 计算属性
const libraries = computed(() => libraryStore.libraries)
const currentLibraryId = computed(() => libraryStore.currentLibraryId)
const loading = computed(() => libraryStore.loading)



// 获取库类型颜色
const getLibraryTypeColor = (type: string) => {
  const colors = {
    LOCAL: 'success',
    SMB: 'primary',
    FTP: 'warning',
    WEBDAV: 'info',
    NFS: 'danger'
  }
  return colors[type as keyof typeof colors] || 'default'
}

// 获取库类型文本
const getLibraryTypeText = (type: string) => {
  const texts = {
    LOCAL: '本地',
    SMB: 'SMB',
    FTP: 'FTP',
    WEBDAV: 'WEBDAV',
    NFS: 'NFS'
  }
  return texts[type as keyof typeof texts] || type
}

// 格式化日期
const formatDate = (date: Date) => {
  return new Date(date).toLocaleDateString('zh-CN')
}

// 选择文件夹
const selectFolder = async () => {
  try {
    // 检查是否在Electron环境中
    if (window.electronAPI && window.electronAPI.selectFolder) {
      const result = await window.electronAPI.selectFolder()
      if (!result.canceled && result.filePaths.length > 0) {
        // Electron环境下直接获取绝对路径
        form.value.path = result.filePaths[0]
        ElMessage.success('已选择文件夹: ' + form.value.path)
      }
    } else {
      // Web环境中无法获取绝对路径，提示用户手动输入
      ElMessage.warning({
        message: 'Web环境下无法自动获取绝对路径，请在路径输入框中手动输入完整的文件夹绝对路径',
        duration: 5000
      })
      
      // 仍然提供文件夹选择功能作为参考，但提醒用户需要手动输入绝对路径
      const input = document.createElement('input')
      input.type = 'file'
      input.webkitdirectory = true
      input.multiple = true
      input.style.display = 'none'
      
      input.onchange = (event: any) => {
        const files = event.target.files
        if (files && files.length > 0) {
          const firstFile = files[0]
          const relativePath = firstFile.webkitRelativePath
          const folderName = relativePath.substring(0, relativePath.indexOf('/')) || firstFile.name
          
          // 清空路径输入框，提示用户输入绝对路径
          form.value.path = ''
          ElMessage.info({
            message: `检测到文件夹名称: ${folderName}，请在路径输入框中输入该文件夹的完整绝对路径`,
            duration: 8000
          })
        }
        document.body.removeChild(input)
      }
      
      document.body.appendChild(input)
      input.click()
    }
  } catch (error) {
    console.error('选择文件夹失败:', error)
    ElMessage.error('选择文件夹失败，请手动输入绝对路径')
  }
}

// 获取路径占位符文本
const getPathPlaceholder = (type: string) => {
  switch (type) {
    case 'SMB':
      return '请输入SMB路径，如：//192.168.1.100/share/manga'
    case 'FTP':
      return '请输入FTP路径，如：FTP://192.168.1.100/manga'
    case 'WEBDAV':
      return '请输入WEBDAV路径，如：https://example.com/WEBDAV/manga'
    case 'NFS':
      return '请输入NFS路径，如：192.168.1.100:/export/manga'
    default:
      return '请输入路径'
  }
}

// 设置当前库
const setCurrentLibrary = (libraryId: string) => {
  libraryStore.setCurrentLibrary(libraryId)
  ElMessage.success('已切换漫画库')
}

// 扫描库
const scanLibrary = async (libraryId: string) => {
  scanningLibraryId.value = libraryId
  try {
    await libraryStore.scanLibrary(libraryId)
    ElMessage.success('扫描完成')
  } catch (error) {
    ElMessage.error('扫描失败')
  } finally {
    scanningLibraryId.value = null
  }
}

// 处理库操作
const handleLibraryAction = async ({ action, library }: { action: string, library: MangaLibrary }) => {
  switch (action) {
    case 'scan':
      await scanLibrary(library.id)
      break
    case 'edit':
      editLibrary(library)
      break
    case 'delete':
      await deleteLibrary(library)
      break
  }
}

// 编辑库
const editLibrary = (library: MangaLibrary) => {
  editingLibrary.value = library
  form.value = {
    name: library.name,
    type: library.type,
    path: library.path,
    description: library.description || '',
    isPrivate: library.isPrivate
  }
  showCreateDialog.value = true
}

// 删除库
const deleteLibrary = async (library: MangaLibrary) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除漫画库 "${library.name}" 吗？这将同时删除库中的所有漫画记录。`,
      '确认删除',
      {
        confirmButtonText: '删除',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await libraryStore.deleteLibrary(library.id)
    ElMessage.success('删除成功')
  } catch (error) {
    // 用户取消删除
  }
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    submitting.value = true
    
    if (editingLibrary.value) {
      await libraryStore.updateLibrary(editingLibrary.value.id, form.value)
      ElMessage.success('更新成功')
    } else {
      await libraryStore.createLibrary(form.value)
      ElMessage.success('创建成功')
    }
    
    showCreateDialog.value = false
    resetForm()
  } catch (error) {
    ElMessage.error('操作失败')
  } finally {
    submitting.value = false
  }
}

// 重置表单
const resetForm = () => {
  editingLibrary.value = null
  form.value = {
    name: '',
    type: 'LOCAL',
    path: '',
    description: '',
    isPrivate: false
  }
  if (formRef.value) {
    formRef.value.resetFields()
  }
}

// 初始化
onMounted(async () => {
  await libraryStore.initializeData()
})
</script>

<style scoped>
.library-page {
  padding: 24px;
  height: 100%;
  overflow: auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 24px;
}

.header-left h1 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.subtitle {
  margin: 0;
  color: var(--el-text-color-regular);
  font-size: 14px;
}

.library-card {
  margin-bottom: 20px;
  transition: transform 0.2s ease;
}

.library-card:hover {
  transform: translateY(-2px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.library-info {
  flex: 1;
}

.library-name {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.library-content {
  padding: 0;
}

.library-path {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  padding: 8px;
  background: var(--el-bg-color-page);
  border-radius: 4px;
}

.library-path .el-icon {
  margin-right: 8px;
  color: var(--el-text-color-regular);
}

.path-text {
  font-size: 12px;
  color: var(--el-text-color-regular);
  word-break: break-all;
}

.library-stats {
  margin-bottom: 16px;
}

.stat-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 12px;
}

.stat-label {
  color: var(--el-text-color-regular);
}

.stat-value {
  color: var(--el-text-color-primary);
  font-weight: 500;
}

.library-actions {
  display: flex;
  gap: 8px;
}

.library-actions .el-button {
  flex: 1;
}

.path-input {
  display: flex;
  gap: 8px;
}

.path-input .el-input {
  flex: 1;
}

@media (max-width: 768px) {
  .library-page {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .header-right {
    width: 100%;
  }
  
  .header-right .el-button {
    width: 100%;
  }
}

.form-tip {
  margin-top: 8px;
}

.form-tip .el-text {
  line-height: 1.4;
}
</style>