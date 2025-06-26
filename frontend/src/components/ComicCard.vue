<template>
  <div 
    class="comic-card" 
    :class="{ 'is-privacy': isPrivacy, 'is-reading': isReading, 'is-completed': isCompleted }"
    @click="$emit('click')"
  >
    <div class="comic-cover">
      <img 
        :src="coverUrl" 
        :alt="comic.title" 
        @error="handleImageError"
        loading="lazy"
      >
      
      <div class="comic-status">
        <el-tag v-if="isPrivacy" size="small" type="danger">
          <el-icon><Lock /></el-icon>
        </el-tag>
        
        <el-tag v-if="isReading" size="small" type="primary">
          阅读中
        </el-tag>
        
        <el-tag v-if="isCompleted" size="small" type="success">
          已读完
        </el-tag>
      </div>
      
      <div class="comic-progress" v-if="hasProgress">
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: `${progressPercentage}%` }"></div>
        </div>
        <div class="progress-text">{{ progressText }}</div>
      </div>
    </div>
    
    <div class="comic-info">
      <h3 class="comic-title" :title="comic.title">{{ comic.title }}</h3>
      
      <div class="comic-meta">
        <span v-if="comic.lastReadTime" class="last-read">
          {{ formatLastRead(comic.lastReadTime) }}
        </span>
        
        <span v-if="comic.pageCount" class="page-count">
          {{ comic.pageCount }}页
        </span>
      </div>
      
      <div class="comic-tags" v-if="comic.tags && comic.tags.length > 0">
        <el-tag 
          v-for="tag in displayTags" 
          :key="tag" 
          size="small" 
          effect="plain"
        >
          {{ tag }}
        </el-tag>
        <span v-if="comic.tags.length > maxTags" class="more-tags">+{{ comic.tags.length - maxTags }}</span>
      </div>
    </div>
    
    <div class="comic-actions">
      <el-dropdown trigger="click" @click.stop>
        <el-button type="text" class="action-button">
          <el-icon><MoreFilled /></el-icon>
        </el-button>
        
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="$emit('open')">
              <el-icon><Reading /></el-icon> 阅读
            </el-dropdown-item>
            
            <el-dropdown-item @click="$emit('edit')">
              <el-icon><Edit /></el-icon> 编辑信息
            </el-dropdown-item>
            
            <el-dropdown-item @click="togglePrivacy">
              <el-icon><Lock /></el-icon> {{ isPrivacy ? '取消隐私' : '设为隐私' }}
            </el-dropdown-item>
            
            <el-dropdown-item @click="$emit('delete')" divided>
              <el-icon><Delete /></el-icon> 删除
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<script setup>
import { computed, ref } from 'vue'
import { usePrivacyStore } from '../store/privacy'
import { ElMessage } from 'element-plus'
import { Lock, MoreFilled, Reading, Edit, Delete } from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  comic: {
    type: Object,
    required: true
  }
})

// 定义事件
const emit = defineEmits(['click', 'open', 'edit', 'delete', 'privacy-changed'])

// 获取隐私状态管理
const privacyStore = usePrivacyStore()

// 最大显示标签数
const maxTags = 2

// 计算封面URL
const coverUrl = computed(() => {
  if (!props.comic.coverPath) {
    return '/placeholder-cover.png'
  }
  
  // 如果是本地路径，使用 Electron 的文件协议
  if (props.comic.coverPath.startsWith('/') || props.comic.coverPath.includes(':\\')) {
    return `file://${props.comic.coverPath}`
  }
  
  return props.comic.coverPath
})

// 处理图片加载错误
function handleImageError(e) {
  e.target.src = '/placeholder-cover.png'
}

// 计算是否为隐私漫画
const isPrivacy = computed(() => {
  return privacyStore.isPrivacyBook(props.comic.id)
})

// 计算阅读状态
const isReading = computed(() => {
  return props.comic.readingStatus === 'reading'
})

const isCompleted = computed(() => {
  return props.comic.readingStatus === 'completed'
})

// 计算阅读进度
const hasProgress = computed(() => {
  return props.comic.currentPage > 0 && props.comic.pageCount > 0
})

const progressPercentage = computed(() => {
  if (!hasProgress.value) return 0
  return Math.min(100, Math.round((props.comic.currentPage / props.comic.pageCount) * 100))
})

const progressText = computed(() => {
  if (!hasProgress.value) return ''
  return `${props.comic.currentPage}/${props.comic.pageCount}`
})

// 格式化最后阅读时间
function formatLastRead(timestamp) {
  if (!timestamp) return ''
  
  const date = new Date(timestamp)
  const now = new Date()
  const diffMs = now - date
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  
  if (diffDays === 0) {
    // 今天
    return '今天'
  } else if (diffDays === 1) {
    // 昨天
    return '昨天'
  } else if (diffDays < 7) {
    // 本周
    return `${diffDays}天前`
  } else if (diffDays < 30) {
    // 本月
    return `${Math.floor(diffDays / 7)}周前`
  } else {
    // 更早
    return `${date.getMonth() + 1}月${date.getDate()}日`
  }
}

// 显示的标签
const displayTags = computed(() => {
  if (!props.comic.tags || !props.comic.tags.length) return []
  return props.comic.tags.slice(0, maxTags)
})

// 切换隐私状态
async function togglePrivacy() {
  try {
    // 如果当前不是隐私模式且要设置为隐私，需要先验证密码
    if (!isPrivacy.value && !privacyStore.isPrivacyModeAuthorized) {
      // 跳转到隐私验证页面
      emit('privacy-changed', { id: props.comic.id, action: 'request-auth' })
      return
    }
    
    // 切换隐私状态
    await privacyStore.setBookPrivacy(props.comic.id, !isPrivacy.value)
    
    // 通知父组件
    emit('privacy-changed', { 
      id: props.comic.id, 
      isPrivacy: !isPrivacy.value,
      action: 'changed'
    })
    
    ElMessage.success(isPrivacy.value ? '已取消隐私设置' : '已设为隐私内容')
  } catch (error) {
    console.error('切换隐私状态失败:', error)
    ElMessage.error('操作失败')
  }
}
</script>

<style scoped>
.comic-card {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--bg-color-light);
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.comic-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.comic-cover {
  position: relative;
  width: 100%;
  padding-top: 140%; /* 宽高比约为 5:7 */
  overflow: hidden;
}

.comic-cover img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.comic-card:hover .comic-cover img {
  transform: scale(1.05);
}

.comic-status {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.comic-progress {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: rgba(0, 0, 0, 0.7);
  padding: 5px 8px;
  font-size: 12px;
  color: #fff;
}

.progress-bar {
  height: 4px;
  background-color: rgba(255, 255, 255, 0.3);
  border-radius: 2px;
  margin-bottom: 4px;
}

.progress-fill {
  height: 100%;
  background-color: var(--primary-color);
  border-radius: 2px;
}

.progress-text {
  text-align: right;
  font-size: 10px;
}

.comic-info {
  padding: 12px;
  flex: 1;
  display: flex;
  flex-direction: column;
}

.comic-title {
  margin: 0 0 8px 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--text-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.comic-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: var(--text-color-secondary);
  margin-bottom: 8px;
}

.comic-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 5px;
  margin-top: auto;
}

.more-tags {
  font-size: 12px;
  color: var(--text-color-secondary);
  display: inline-flex;
  align-items: center;
}

.comic-actions {
  position: absolute;
  top: 8px;
  left: 8px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.comic-card:hover .comic-actions {
  opacity: 1;
}

.action-button {
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
}

/* 状态样式 */
.comic-card.is-privacy {
  border: 2px solid var(--danger-color);
}

.comic-card.is-reading {
  border: 2px solid var(--primary-color);
}

.comic-card.is-completed {
  border: 2px solid var(--success-color);
}

/* 暗色模式适配 */
.dark .comic-card {
  background-color: var(--bg-color-dark);
}

.dark .comic-title {
  color: var(--text-color-dark);
}

.dark .comic-meta {
  color: var(--text-color-secondary-dark);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .comic-title {
    font-size: 13px;
  }
  
  .comic-meta,
  .comic-tags {
    font-size: 11px;
  }
}
</style>