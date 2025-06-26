<template>
  <el-dialog
    v-model="dialogVisible"
    :title="isEditMode ? '编辑漫画信息' : '漫画详情'"
    width="700px"
    :close-on-click-modal="false"
    @closed="handleDialogClosed"
  >
    <div class="comic-detail">
      <div class="detail-layout">
        <!-- 封面区域 -->
        <div class="cover-section">
          <div class="comic-cover" @click="isEditMode && triggerCoverUpload">
            <img 
              :src="coverUrl" 
              :alt="formData.title" 
              @error="handleImageError"
            >
            
            <div v-if="isEditMode" class="cover-overlay">
              <el-icon><Upload /></el-icon>
              <span>更换封面</span>
            </div>
            
            <input 
              v-if="isEditMode"
              ref="coverInput"
              type="file"
              accept="image/*"
              style="display: none"
              @change="handleCoverChange"
            >
          </div>
          
          <div v-if="!isEditMode" class="comic-actions">
            <el-button type="primary" @click="$emit('read')">
              <el-icon><Reading /></el-icon> 开始阅读
            </el-button>
            
            <el-button @click="startEdit">
              <el-icon><Edit /></el-icon> 编辑信息
            </el-button>
          </div>
        </div>
        
        <!-- 信息区域 -->
        <div class="info-section">
          <template v-if="isEditMode">
            <!-- 编辑模式 -->
            <el-form :model="formData" label-position="top" :rules="rules" ref="formRef">
              <el-form-item label="标题" prop="title">
                <el-input v-model="formData.title" placeholder="请输入漫画标题" />
              </el-form-item>
              
              <el-form-item label="作者">
                <el-input v-model="formData.author" placeholder="请输入作者名称" />
              </el-form-item>
              
              <el-form-item label="标签">
                <el-tag
                  v-for="tag in formData.tags"
                  :key="tag"
                  closable
                  @close="removeTag(tag)"
                  class="tag-item"
                >
                  {{ tag }}
                </el-tag>
                
                <el-input
                  v-if="tagInputVisible"
                  ref="tagInputRef"
                  v-model="tagInputValue"
                  class="tag-input"
                  size="small"
                  @keyup.enter="handleTagConfirm"
                  @blur="handleTagConfirm"
                />
                
                <el-button v-else class="button-new-tag" size="small" @click="showTagInput">
                  + 添加标签
                </el-button>
              </el-form-item>
              
              <el-form-item label="描述">
                <el-input 
                  v-model="formData.description" 
                  type="textarea" 
                  :rows="3" 
                  placeholder="请输入漫画描述"
                />
              </el-form-item>
              
              <el-form-item label="评分">
                <el-rate v-model="formData.rating" :max="5" />
              </el-form-item>
              
              <el-form-item label="隐私设置">
                <el-switch
                  v-model="formData.isPrivacy"
                  :disabled="!canTogglePrivacy"
                  :title="!canTogglePrivacy ? '请先验证隐私模式密码' : ''"
                />
                <span class="setting-description">
                  {{ formData.isPrivacy ? '隐私内容（仅在隐私模式下可见）' : '公开内容' }}
                </span>
              </el-form-item>
            </el-form>
            
            <div class="form-actions">
              <el-button @click="cancelEdit">取消</el-button>
              <el-button type="primary" @click="saveChanges" :loading="saving">
                保存
              </el-button>
            </div>
          </template>
          
          <template v-else>
            <!-- 查看模式 -->
            <h2 class="comic-title">{{ comic.title }}</h2>
            
            <div v-if="comic.author" class="info-item">
              <span class="info-label">作者：</span>
              <span class="info-value">{{ comic.author }}</span>
            </div>
            
            <div class="info-item">
              <span class="info-label">页数：</span>
              <span class="info-value">{{ comic.pageCount || '未知' }}</span>
            </div>
            
            <div class="info-item">
              <span class="info-label">阅读进度：</span>
              <span class="info-value">
                <template v-if="hasProgress">
                  {{ comic.currentPage }}/{{ comic.pageCount }}
                  ({{ progressPercentage }}%)
                </template>
                <template v-else>未开始阅读</template>
              </span>
            </div>
            
            <div class="info-item">
              <span class="info-label">阅读状态：</span>
              <span class="info-value">
                <el-tag size="small" :type="statusTagType">
                  {{ statusText }}
                </el-tag>
              </span>
            </div>
            
            <div v-if="comic.lastReadTime" class="info-item">
              <span class="info-label">最近阅读：</span>
              <span class="info-value">{{ formatDate(comic.lastReadTime) }}</span>
            </div>
            
            <div v-if="comic.addTime" class="info-item">
              <span class="info-label">添加时间：</span>
              <span class="info-value">{{ formatDate(comic.addTime) }}</span>
            </div>
            
            <div class="info-item">
              <span class="info-label">评分：</span>
              <span class="info-value">
                <el-rate v-model="comic.rating" disabled />
              </span>
            </div>
            
            <div v-if="comic.tags && comic.tags.length > 0" class="info-item">
              <span class="info-label">标签：</span>
              <div class="tags-list">
                <el-tag 
                  v-for="tag in comic.tags" 
                  :key="tag"
                  size="small"
                  effect="plain"
                  class="tag-item"
                >
                  {{ tag }}
                </el-tag>
              </div>
            </div>
            
            <div v-if="comic.description" class="info-item description-item">
              <span class="info-label">描述：</span>
              <div class="info-value description-value">
                {{ comic.description }}
              </div>
            </div>
            
            <div class="info-item">
              <span class="info-label">隐私状态：</span>
              <span class="info-value">
                <el-tag size="small" :type="isPrivacy ? 'danger' : 'info'">
                  {{ isPrivacy ? '隐私内容' : '公开内容' }}
                </el-tag>
              </span>
            </div>
            
            <div class="info-item">
              <span class="info-label">文件路径：</span>
              <span class="info-value file-path" :title="comic.filePath">
                {{ comic.filePath }}
              </span>
            </div>
          </template>
        </div>
      </div>
    </div>
    
    <template #footer v-if="!isEditMode">
      <div class="dialog-footer">
        <el-button @click="dialogVisible = false">关闭</el-button>
        <el-button type="danger" @click="confirmDelete">
          <el-icon><Delete /></el-icon> 删除
        </el-button>
      </div>
    </template>
  </el-dialog>
  
  <!-- 删除确认对话框 -->
  <el-dialog
    v-model="deleteDialogVisible"
    title="确认删除"
    width="400px"
  >
    <div class="delete-confirm">
      <el-icon class="warning-icon"><Warning /></el-icon>
      <p>确定要删除漫画 <strong>{{ comic.title }}</strong> 吗？</p>
      <p class="delete-note">此操作不会删除原始文件，仅从漫画库中移除。</p>
    </div>
    
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="deleteDialogVisible = false">取消</el-button>
        <el-button type="danger" @click="handleDelete" :loading="deleting">
          确认删除
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, computed, watch, nextTick } from 'vue'
import { usePrivacyStore } from '../store/privacy'
import { ElMessage } from 'element-plus'
import { 
  Upload, 
  Reading, 
  Edit, 
  Delete, 
  Warning 
} from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  // 漫画对象
  comic: {
    type: Object,
    required: true
  },
  // 对话框是否可见
  visible: {
    type: Boolean,
    default: false
  }
})

// 定义事件
const emit = defineEmits(['update:visible', 'read', 'save', 'delete', 'privacy-auth-required'])

// 获取隐私状态管理
const privacyStore = usePrivacyStore()

// 对话框可见状态
const dialogVisible = ref(false)

// 编辑模式
const isEditMode = ref(false)

// 表单引用
const formRef = ref(null)

// 表单数据
const formData = ref({
  title: '',
  author: '',
  description: '',
  tags: [],
  rating: 0,
  isPrivacy: false
})

// 表单验证规则
const rules = {
  title: [
    { required: true, message: '请输入漫画标题', trigger: 'blur' }
  ]
}

// 标签输入
const tagInputVisible = ref(false)
const tagInputValue = ref('')
const tagInputRef = ref(null)

// 封面输入
const coverInput = ref(null)
const newCoverFile = ref(null)

// 加载状态
const saving = ref(false)
const deleting = ref(false)

// 删除对话框
const deleteDialogVisible = ref(false)

// 监听 visible 变化
watch(() => props.visible, (newVal) => {
  dialogVisible.value = newVal
  if (newVal) {
    // 重置编辑模式
    isEditMode.value = false
    // 初始化表单数据
    initFormData()
  }
}, { immediate: true })

// 监听对话框可见状态变化
watch(dialogVisible, (newVal) => {
  emit('update:visible', newVal)
})

// 计算封面URL
const coverUrl = computed(() => {
  // 如果有新上传的封面
  if (newCoverFile.value) {
    return URL.createObjectURL(newCoverFile.value)
  }
  
  // 使用漫画封面
  if (!props.comic.coverPath) {
    return '/placeholder-cover.png'
  }
  
  // 如果是本地路径，使用 Electron 的文件协议
  if (props.comic.coverPath.startsWith('/') || props.comic.coverPath.includes(':\\')) {
    return `file://${props.comic.coverPath}`
  }
  
  return props.comic.coverPath
})

// 计算是否有阅读进度
const hasProgress = computed(() => {
  return props.comic.currentPage > 0 && props.comic.pageCount > 0
})

// 计算阅读进度百分比
const progressPercentage = computed(() => {
  if (!hasProgress.value) return 0
  return Math.min(100, Math.round((props.comic.currentPage / props.comic.pageCount) * 100))
})

// 计算阅读状态文本
const statusText = computed(() => {
  switch (props.comic.readingStatus) {
    case 'reading':
      return '阅读中'
    case 'completed':
      return '已读完'
    default:
      return '未读'
  }
})

// 计算状态标签类型
const statusTagType = computed(() => {
  switch (props.comic.readingStatus) {
    case 'reading':
      return 'primary'
    case 'completed':
      return 'success'
    default:
      return 'info'
  }
})

// 计算是否为隐私漫画
const isPrivacy = computed(() => {
  return privacyStore.isPrivacyBook(props.comic.id)
})

// 计算是否可以切换隐私状态
const canTogglePrivacy = computed(() => {
  // 如果当前是隐私漫画，必须已授权才能切换
  if (isPrivacy.value) {
    return privacyStore.isPrivacyModeAuthorized
  }
  
  // 如果当前不是隐私漫画，但要设为隐私，也必须已授权
  if (formData.value.isPrivacy) {
    return privacyStore.isPrivacyModeAuthorized
  }
  
  return true
})

// 初始化表单数据
function initFormData() {
  formData.value = {
    title: props.comic.title || '',
    author: props.comic.author || '',
    description: props.comic.description || '',
    tags: props.comic.tags ? [...props.comic.tags] : [],
    rating: props.comic.rating || 0,
    isPrivacy: isPrivacy.value
  }
  
  // 重置新封面
  newCoverFile.value = null
}

// 处理图片加载错误
function handleImageError(e) {
  e.target.src = '/placeholder-cover.png'
}

// 格式化日期
function formatDate(timestamp) {
  if (!timestamp) return ''
  
  const date = new Date(timestamp)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

// 开始编辑
function startEdit() {
  // 如果是隐私漫画但未授权，需要先验证
  if (isPrivacy.value && !privacyStore.isPrivacyModeAuthorized) {
    emit('privacy-auth-required')
    return
  }
  
  isEditMode.value = true
  initFormData()
}

// 取消编辑
function cancelEdit() {
  isEditMode.value = false
  initFormData()
}

// 保存更改
async function saveChanges() {
  // 表单验证
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    saving.value = true
    
    // 如果要设为隐私但未授权，需要先验证
    if (formData.value.isPrivacy && !isPrivacy.value && !privacyStore.isPrivacyModeAuthorized) {
      emit('privacy-auth-required')
      saving.value = false
      return
    }
    
    // 准备更新数据
    const updatedData = {
      id: props.comic.id,
      title: formData.value.title,
      author: formData.value.author,
      description: formData.value.description,
      tags: formData.value.tags,
      rating: formData.value.rating,
      newCover: newCoverFile.value
    }
    
    // 触发保存事件
    emit('save', updatedData)
    
    // 如果隐私状态有变化，更新隐私状态
    if (formData.value.isPrivacy !== isPrivacy.value) {
      await privacyStore.setBookPrivacy(props.comic.id, formData.value.isPrivacy)
    }
    
    // 退出编辑模式
    isEditMode.value = false
    ElMessage.success('保存成功')
  } catch (error) {
    console.error('保存失败:', error)
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

// 显示标签输入
async function showTagInput() {
  tagInputVisible.value = true
  await nextTick()
  tagInputRef.value.focus()
}

// 处理标签确认
function handleTagConfirm() {
  const value = tagInputValue.value.trim()
  if (value) {
    // 检查是否已存在
    if (!formData.value.tags.includes(value)) {
      formData.value.tags.push(value)
    }
  }
  tagInputVisible.value = false
  tagInputValue.value = ''
}

// 移除标签
function removeTag(tag) {
  const index = formData.value.tags.indexOf(tag)
  if (index !== -1) {
    formData.value.tags.splice(index, 1)
  }
}

// 触发封面上传
function triggerCoverUpload() {
  if (coverInput.value) {
    coverInput.value.click()
  }
}

// 处理封面变更
function handleCoverChange(event) {
  const file = event.target.files[0]
  if (!file) return
  
  // 检查文件类型
  if (!file.type.startsWith('image/')) {
    ElMessage.error('请选择图片文件')
    return
  }
  
  // 检查文件大小（限制为 2MB）
  if (file.size > 2 * 1024 * 1024) {
    ElMessage.error('图片大小不能超过 2MB')
    return
  }
  
  newCoverFile.value = file
}

// 确认删除
function confirmDelete() {
  deleteDialogVisible.value = true
}

// 处理删除
async function handleDelete() {
  try {
    deleting.value = true
    emit('delete', props.comic.id)
    deleteDialogVisible.value = false
    dialogVisible.value = false
  } catch (error) {
    console.error('删除失败:', error)
    ElMessage.error('删除失败')
  } finally {
    deleting.value = false
  }
}

// 处理对话框关闭
function handleDialogClosed() {
  // 重置状态
  isEditMode.value = false
  newCoverFile.value = null
  tagInputVisible.value = false
  tagInputValue.value = ''
}
</script>

<style scoped>
.comic-detail {
  width: 100%;
}

.detail-layout {
  display: flex;
  gap: 20px;
}

.cover-section {
  flex: 0 0 200px;
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.comic-cover {
  width: 200px;
  height: 280px;
  border-radius: 8px;
  overflow: hidden;
  position: relative;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.comic-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.cover-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: white;
  opacity: 0;
  transition: opacity 0.3s;
  cursor: pointer;
}

.comic-cover:hover .cover-overlay {
  opacity: 1;
}

.cover-overlay .el-icon {
  font-size: 24px;
  margin-bottom: 8px;
}

.comic-actions {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-section {
  flex: 1;
  min-width: 0;
}

.comic-title {
  margin: 0 0 15px 0;
  font-size: 20px;
  color: var(--text-color);
  line-height: 1.3;
}

.info-item {
  margin-bottom: 12px;
  display: flex;
}

.info-label {
  font-weight: 500;
  color: var(--text-color-secondary);
  width: 80px;
  flex-shrink: 0;
}

.info-value {
  color: var(--text-color);
  flex: 1;
  min-width: 0;
}

.description-item {
  align-items: flex-start;
}

.description-value {
  white-space: pre-line;
  line-height: 1.5;
}

.file-path {
  word-break: break-all;
  font-family: monospace;
  font-size: 13px;
  background-color: var(--bg-color-light);
  padding: 2px 5px;
  border-radius: 3px;
}

.tags-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.tag-item {
  margin-right: 0;
}

.tag-input {
  width: 100px;
  margin-right: 8px;
  vertical-align: bottom;
}

.form-actions {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.setting-description {
  margin-left: 10px;
  font-size: 13px;
  color: var(--text-color-secondary);
}

.delete-confirm {
  text-align: center;
  padding: 10px 0;
}

.warning-icon {
  font-size: 48px;
  color: var(--danger-color);
  margin-bottom: 15px;
}

.delete-note {
  font-size: 13px;
  color: var(--text-color-secondary);
  margin-top: 10px;
}

/* 暗色模式适配 */
.dark .comic-title {
  color: var(--text-color-dark);
}

.dark .info-label {
  color: var(--text-color-secondary-dark);
}

.dark .info-value {
  color: var(--text-color-dark);
}

.dark .file-path {
  background-color: var(--bg-color-dark);
}

.dark .setting-description,
.dark .delete-note {
  color: var(--text-color-secondary-dark);
}

/* 响应式调整 */
@media (max-width: 600px) {
  .detail-layout {
    flex-direction: column;
  }
  
  .cover-section {
    align-items: center;
  }
  
  .comic-title {
    text-align: center;
  }
  
  .info-item {
    flex-direction: column;
    gap: 5px;
  }
  
  .info-label {
    width: auto;
  }
}
</style>