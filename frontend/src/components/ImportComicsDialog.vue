<template>
  <el-dialog
    v-model="dialogVisible"
    title="导入漫画"
    width="700px"
    :close-on-click-modal="false"
  >
    <div class="import-dialog">
      <!-- 导入选项 -->
      <div class="import-options" v-if="!isImporting && !importComplete">
        <h3>选择导入方式</h3>
        
        <el-form label-position="top">
          <el-form-item label="导入类型">
            <el-radio-group v-model="importType">
              <el-radio label="files">选择文件</el-radio>
              <el-radio label="folder">选择文件夹</el-radio>
              <el-radio label="url">从URL导入</el-radio>
            </el-radio-group>
          </el-form-item>
          
          <template v-if="importType === 'files'">
            <el-form-item label="选择文件">
              <div class="file-selector">
                <el-button @click="browseFiles">
                  <el-icon><Folder /></el-icon> 浏览文件
                </el-button>
                <span v-if="selectedFiles.length > 0" class="selected-info">
                  已选择 {{ selectedFiles.length }} 个文件
                </span>
                <span v-else class="selected-info empty">
                  未选择文件
                </span>
              </div>
              
              <div v-if="selectedFiles.length > 0" class="selected-files">
                <div v-for="(file, index) in selectedFiles" :key="index" class="selected-file">
                  <el-icon><Document /></el-icon>
                  <span class="file-name">{{ getFileName(file) }}</span>
                  <el-button 
                    type="text" 
                    @click="removeFile(index)"
                    class="remove-file"
                  >
                    <el-icon><Close /></el-icon>
                  </el-button>
                </div>
              </div>
            </el-form-item>
          </template>
          
          <template v-if="importType === 'folder'">
            <el-form-item label="选择文件夹">
              <div class="file-selector">
                <el-button @click="browseFolder">
                  <el-icon><FolderOpened /></el-icon> 浏览文件夹
                </el-button>
                <span v-if="selectedFolder" class="selected-info">
                  {{ selectedFolder }}
                </span>
                <span v-else class="selected-info empty">
                  未选择文件夹
                </span>
              </div>
            </el-form-item>
            
            <el-form-item label="包含子文件夹">
              <el-switch v-model="includeSubfolders" />
              <span class="option-description">搜索子文件夹中的漫画文件</span>
            </el-form-item>
          </template>
          
          <template v-if="importType === 'url'">
            <el-form-item label="输入URL">
              <el-input 
                v-model="importUrl" 
                placeholder="输入漫画URL" 
                clearable
              />
            </el-form-item>
          </template>
          
          <el-form-item label="导入选项">
            <el-checkbox v-model="extractMetadata">尝试提取元数据</el-checkbox>
            <div class="option-description">从文件名和内容中提取标题、作者等信息</div>
            
            <el-checkbox v-model="generateCovers">自动生成封面</el-checkbox>
            <div class="option-description">使用漫画第一页作为封面图片</div>
          </el-form-item>
        </el-form>
      </div>
      
      <!-- 导入进度 -->
      <div class="import-progress" v-if="isImporting && !importComplete">
        <h3>正在导入漫画</h3>
        
        <div class="progress-info">
          <el-progress 
            :percentage="importProgress" 
            :format="progressFormat"
            :stroke-width="20"
          />
          
          <div class="current-file">
            <span class="label">当前处理：</span>
            <span class="value">{{ currentImportFile || '准备中...' }}</span>
          </div>
          
          <div class="import-stats">
            <div class="stat-item">
              <span class="label">已导入：</span>
              <span class="value">{{ importedCount }}</span>
            </div>
            
            <div class="stat-item">
              <span class="label">失败：</span>
              <span class="value">{{ failedCount }}</span>
            </div>
            
            <div class="stat-item">
              <span class="label">总计：</span>
              <span class="value">{{ totalFilesToImport }}</span>
            </div>
          </div>
        </div>
        
        <div class="import-log">
          <div class="log-header">
            <h4>导入日志</h4>
            <el-button type="text" size="small" @click="clearLog">
              清空
            </el-button>
          </div>
          
          <div class="log-content" ref="logContent">
            <div 
              v-for="(log, index) in importLogs" 
              :key="index" 
              class="log-item"
              :class="{ 'error': log.type === 'error', 'success': log.type === 'success' }"
            >
              <span class="log-time">{{ formatLogTime(log.time) }}</span>
              <span class="log-message">{{ log.message }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 导入完成 -->
      <div class="import-complete" v-if="importComplete">
        <div class="complete-icon">
          <el-icon v-if="importedCount > 0"><SuccessFilled /></el-icon>
          <el-icon v-else><WarningFilled /></el-icon>
        </div>
        
        <h3>导入完成</h3>
        
        <div class="complete-stats">
          <div class="stat-item">
            <span class="label">成功导入：</span>
            <span class="value success">{{ importedCount }}</span>
          </div>
          
          <div class="stat-item">
            <span class="label">导入失败：</span>
            <span class="value error">{{ failedCount }}</span>
          </div>
          
          <div class="stat-item">
            <span class="label">总计：</span>
            <span class="value">{{ totalFilesToImport }}</span>
          </div>
        </div>
        
        <div v-if="failedCount > 0" class="failed-files">
          <h4>导入失败的文件</h4>
          <ul>
            <li v-for="(file, index) in failedFiles" :key="index">
              {{ getFileName(file.path) }}
              <span class="error-reason">{{ file.reason }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="closeDialog" :disabled="isImporting">
          {{ importComplete ? '关闭' : '取消' }}
        </el-button>
        
        <template v-if="!isImporting && !importComplete">
          <el-button type="primary" @click="startImport" :disabled="!canImport">
            开始导入
          </el-button>
        </template>
        
        <template v-if="isImporting && !importComplete">
          <el-button type="danger" @click="cancelImport">
            取消导入
          </el-button>
        </template>
        
        <template v-if="importComplete">
          <el-button type="primary" @click="newImport">
            继续导入
          </el-button>
        </template>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { 
  Folder, 
  FolderOpened, 
  Document, 
  Close, 
  SuccessFilled, 
  WarningFilled 
} from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  // 对话框是否可见
  visible: {
    type: Boolean,
    default: false
  },
  // 当前库ID
  libraryId: {
    type: String,
    required: true
  }
})

// 定义事件
const emit = defineEmits(['update:visible', 'import-complete'])

// 对话框可见状态
const dialogVisible = ref(false)

// 导入类型
const importType = ref('files')

// 选择的文件
const selectedFiles = ref([])

// 选择的文件夹
const selectedFolder = ref('')

// 包含子文件夹
const includeSubfolders = ref(true)

// 导入URL
const importUrl = ref('')

// 导入选项
const extractMetadata = ref(true)
const generateCovers = ref(true)

// 导入状态
const isImporting = ref(false)
const importComplete = ref(false)
const importProgress = ref(0)
const currentImportFile = ref('')
const importedCount = ref(0)
const failedCount = ref(0)
const totalFilesToImport = ref(0)
const importLogs = ref([])
const failedFiles = ref([])
const logContent = ref(null)

// 是否可以导入
const canImport = computed(() => {
  if (importType.value === 'files') {
    return selectedFiles.value.length > 0
  } else if (importType.value === 'folder') {
    return !!selectedFolder.value
  } else if (importType.value === 'url') {
    return !!importUrl.value
  }
  return false
})

// 监听 visible 变化
watch(() => props.visible, (newVal) => {
  dialogVisible.value = newVal
  if (newVal) {
    resetImportState()
  }
}, { immediate: true })

// 监听对话框可见状态变化
watch(dialogVisible, (newVal) => {
  emit('update:visible', newVal)
})

// 监听日志变化，自动滚动到底部
watch(importLogs, async () => {
  if (logContent.value) {
    await nextTick()
    logContent.value.scrollTop = logContent.value.scrollHeight
  }
})

// 重置导入状态
function resetImportState() {
  importType.value = 'files'
  selectedFiles.value = []
  selectedFolder.value = ''
  includeSubfolders.value = true
  importUrl.value = ''
  extractMetadata.value = true
  generateCovers.value = true
  
  isImporting.value = false
  importComplete.value = false
  importProgress.value = 0
  currentImportFile.value = ''
  importedCount.value = 0
  failedCount.value = 0
  totalFilesToImport.value = 0
  importLogs.value = []
  failedFiles.value = []
}

// 浏览文件
async function browseFiles() {
  try {
    const result = await window.electronAPI.openFileDialog({
      title: '选择漫画文件',
      filters: [
        { name: '漫画文件', extensions: ['cbz', 'cbr', 'zip', 'rar', 'pdf'] },
        { name: '所有文件', extensions: ['*'] }
      ],
      properties: ['openFile', 'multiSelections']
    })
    
    if (result && result.filePaths && result.filePaths.length > 0) {
      selectedFiles.value = result.filePaths
    }
  } catch (error) {
    console.error('选择文件失败:', error)
    ElMessage.error('选择文件失败')
  }
}

// 浏览文件夹
async function browseFolder() {
  try {
    const result = await window.electronAPI.openDirectoryDialog({
      title: '选择漫画文件夹',
      properties: ['openDirectory']
    })
    
    if (result && result.filePaths && result.filePaths.length > 0) {
      selectedFolder.value = result.filePaths[0]
    }
  } catch (error) {
    console.error('选择文件夹失败:', error)
    ElMessage.error('选择文件夹失败')
  }
}

// 移除文件
function removeFile(index) {
  selectedFiles.value.splice(index, 1)
}

// 获取文件名
function getFileName(path) {
  if (!path) return ''
  return path.split(/[\\/]/).pop()
}

// 开始导入
async function startImport() {
  if (!canImport.value) {
    ElMessage.warning('请先选择要导入的文件或文件夹')
    return
  }
  
  try {
    isImporting.value = true
    importComplete.value = false
    importProgress.value = 0
    importedCount.value = 0
    failedCount.value = 0
    importLogs.value = []
    failedFiles.value = []
    
    // 添加开始日志
    addLog('info', '开始导入漫画...')
    
    // 准备导入参数
    const importParams = {
      libraryId: props.libraryId,
      options: {
        extractMetadata: extractMetadata.value,
        generateCovers: generateCovers.value
      }
    }
    
    // 根据导入类型设置不同参数
    if (importType.value === 'files') {
      importParams.files = selectedFiles.value
      totalFilesToImport.value = selectedFiles.value.length
      addLog('info', `准备导入 ${totalFilesToImport.value} 个文件`)
    } else if (importType.value === 'folder') {
      importParams.folder = selectedFolder.value
      importParams.includeSubfolders = includeSubfolders.value
      addLog('info', `准备从文件夹导入: ${selectedFolder.value}`)
      addLog('info', `包含子文件夹: ${includeSubfolders.value ? '是' : '否'}`)
      
      // 获取文件夹中的文件数量
      const fileCount = await window.electronAPI.countComicFiles({
        folderPath: selectedFolder.value,
        includeSubfolders: includeSubfolders.value
      })
      
      totalFilesToImport.value = fileCount
      addLog('info', `找到 ${totalFilesToImport.value} 个漫画文件`)
    } else if (importType.value === 'url') {
      importParams.url = importUrl.value
      totalFilesToImport.value = 1
      addLog('info', `准备从URL导入: ${importUrl.value}`)
    }
    
    // 模拟导入过程
    // 实际项目中，这里应该调用真实的导入API
    await simulateImport(importParams)
    
    // 导入完成
    importComplete.value = true
    importProgress.value = 100
    addLog('info', '导入完成')
    
    // 通知父组件
    emit('import-complete', {
      imported: importedCount.value,
      failed: failedCount.value,
      total: totalFilesToImport.value
    })
  } catch (error) {
    console.error('导入失败:', error)
    addLog('error', `导入过程中发生错误: ${error.message || '未知错误'}`)
    ElMessage.error('导入失败')
  } finally {
    isImporting.value = false
  }
}

// 模拟导入过程（实际项目中应替换为真实API调用）
async function simulateImport(params) {
  const files = params.files || []
  const isFolder = !!params.folder
  const isUrl = !!params.url
  
  if (isFolder) {
    // 模拟从文件夹导入
    for (let i = 0; i < totalFilesToImport.value; i++) {
      const fileName = `漫画文件_${i + 1}.cbz`
      await processFile(fileName, i)
    }
  } else if (isUrl) {
    // 模拟从URL导入
    currentImportFile.value = params.url
    importProgress.value = 50
    
    await new Promise(resolve => setTimeout(resolve, 2000))
    
    // 随机成功或失败
    const success = Math.random() > 0.3
    if (success) {
      importedCount.value++
      addLog('success', `成功导入: ${params.url}`)
    } else {
      failedCount.value++
      addLog('error', `导入失败: ${params.url} - 网络错误`)
      failedFiles.value.push({ path: params.url, reason: '网络错误' })
    }
    
    importProgress.value = 100
  } else {
    // 模拟从文件列表导入
    for (let i = 0; i < files.length; i++) {
      await processFile(files[i], i)
    }
  }
}

// 处理单个文件
async function processFile(filePath, index) {
  currentImportFile.value = getFileName(filePath)
  importProgress.value = Math.round((index / totalFilesToImport.value) * 100)
  
  addLog('info', `处理文件: ${currentImportFile.value}`)
  
  // 模拟处理时间
  await new Promise(resolve => setTimeout(resolve, 500 + Math.random() * 1000))
  
  // 随机成功或失败
  const success = Math.random() > 0.2
  if (success) {
    importedCount.value++
    addLog('success', `成功导入: ${currentImportFile.value}`)
  } else {
    failedCount.value++
    const reason = Math.random() > 0.5 ? '文件格式不支持' : '文件损坏'
    addLog('error', `导入失败: ${currentImportFile.value} - ${reason}`)
    failedFiles.value.push({ path: filePath, reason })
  }
}

// 添加日志
function addLog(type, message) {
  importLogs.value.push({
    type,
    message,
    time: new Date()
  })
}

// 格式化日志时间
function formatLogTime(date) {
  return `${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`
}

// 格式化进度
function progressFormat(percentage) {
  return `${percentage}%`
}

// 清空日志
function clearLog() {
  importLogs.value = []
}

// 取消导入
function cancelImport() {
  // 实际项目中，这里应该调用取消导入的API
  isImporting.value = false
  addLog('info', '导入已取消')
  ElMessage.info('导入已取消')
}

// 新的导入
function newImport() {
  resetImportState()
}

// 关闭对话框
function closeDialog() {
  if (isImporting.value) {
    ElMessage.warning('导入正在进行中，请先取消导入')
    return
  }
  
  dialogVisible.value = false
}
</script>

<style scoped>
.import-dialog {
  width: 100%;
}

.import-options h3,
.import-progress h3,
.import-complete h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: var(--text-color);
  font-size: 18px;
}

.file-selector {
  display: flex;
  align-items: center;
  gap: 15px;
}

.selected-info {
  color: var(--text-color);
}

.selected-info.empty {
  color: var(--text-color-secondary);
  font-style: italic;
}

.selected-files {
  margin-top: 10px;
  max-height: 150px;
  overflow-y: auto;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 5px;
}

.selected-file {
  display: flex;
  align-items: center;
  padding: 5px;
  border-bottom: 1px solid var(--border-color);
}

.selected-file:last-child {
  border-bottom: none;
}

.file-name {
  margin-left: 8px;
  flex: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.remove-file {
  color: var(--danger-color);
}

.option-description {
  font-size: 12px;
  color: var(--text-color-secondary);
  margin: 5px 0 10px 24px;
}

.progress-info {
  margin-bottom: 20px;
}

.current-file {
  margin-top: 10px;
  font-size: 14px;
}

.import-stats {
  display: flex;
  gap: 20px;
  margin-top: 15px;
}

.stat-item {
  display: flex;
  align-items: center;
}

.label {
  color: var(--text-color-secondary);
  margin-right: 5px;
}

.value {
  font-weight: 500;
  color: var(--text-color);
}

.value.success {
  color: var(--success-color);
}

.value.error {
  color: var(--danger-color);
}

.import-log {
  margin-top: 20px;
}

.log-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.log-header h4 {
  margin: 0;
  font-size: 16px;
  color: var(--text-color);
}

.log-content {
  height: 200px;
  overflow-y: auto;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 10px;
  background-color: var(--bg-color-light);
  font-family: monospace;
  font-size: 13px;
}

.log-item {
  margin-bottom: 5px;
  line-height: 1.4;
}

.log-time {
  color: var(--text-color-secondary);
  margin-right: 8px;
}

.log-item.success .log-message {
  color: var(--success-color);
}

.log-item.error .log-message {
  color: var(--danger-color);
}

.import-complete {
  text-align: center;
}

.complete-icon {
  font-size: 48px;
  margin-bottom: 15px;
}

.complete-icon .el-icon {
  color: var(--success-color);
}

.complete-icon .el-icon.warning-filled {
  color: var(--warning-color);
}

.complete-stats {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin: 20px 0;
}

.failed-files {
  margin-top: 20px;
  text-align: left;
}

.failed-files h4 {
  margin-bottom: 10px;
  color: var(--text-color);
}

.failed-files ul {
  max-height: 150px;
  overflow-y: auto;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 10px;
  background-color: var(--bg-color-light);
  margin: 0;
}

.failed-files li {
  margin-bottom: 5px;
}

.error-reason {
  color: var(--danger-color);
  margin-left: 10px;
  font-size: 12px;
}

/* 暗色模式适配 */
.dark .import-options h3,
.dark .import-progress h3,
.dark .import-complete h3,
.dark .log-header h4,
.dark .failed-files h4 {
  color: var(--text-color-dark);
}

.dark .selected-info {
  color: var(--text-color-dark);
}

.dark .selected-info.empty,
.dark .option-description,
.dark .label,
.dark .log-time {
  color: var(--text-color-secondary-dark);
}

.dark .value {
  color: var(--text-color-dark);
}

.dark .log-content,
.dark .failed-files ul {
  background-color: var(--bg-color-dark);
  border-color: var(--border-color-dark);
}

.dark .selected-files,
.dark .selected-file {
  border-color: var(--border-color-dark);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .import-stats {
    flex-direction: column;
    gap: 10px;
  }
  
  .complete-stats {
    flex-direction: column;
    gap: 10px;
    align-items: center;
  }
}
</style>