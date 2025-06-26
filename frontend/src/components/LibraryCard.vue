<template>
  <div 
    class="library-card" 
    :class="{ 'is-privacy': isPrivacy }"
    @click="$emit('click')"
  >
    <div class="library-icon">
      <el-icon v-if="library.type === 'folder'"><Folder /></el-icon>
      <el-icon v-else-if="library.type === 'archive'"><Files /></el-icon>
      <el-icon v-else><Collection /></el-icon>
    </div>
    
    <div class="library-info">
      <h3 class="library-title" :title="library.name">{{ library.name }}</h3>
      
      <p v-if="library.description" class="library-description">
        {{ library.description }}
      </p>
      
      <div class="library-meta">
        <span class="library-type">
          {{ libraryTypeText }}
        </span>
        
        <span v-if="comicsCount !== undefined" class="comics-count">
          {{ comicsCount }}本漫画
        </span>
      </div>
    </div>
    
    <div class="library-status">
      <el-tag v-if="isPrivacy" size="small" type="danger">
        <el-icon><Lock /></el-icon> 隐私
      </el-tag>
    </div>
    
    <div class="library-actions">
      <el-dropdown trigger="click" @click.stop>
        <el-button type="text" class="action-button">
          <el-icon><MoreFilled /></el-icon>
        </el-button>
        
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="$emit('open')">
              <el-icon><View /></el-icon> 打开
            </el-dropdown-item>
            
            <el-dropdown-item @click="$emit('edit')">
              <el-icon><Edit /></el-icon> 编辑
            </el-dropdown-item>
            
            <el-dropdown-item @click="$emit('import')">
              <el-icon><Upload /></el-icon> 导入漫画
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
import { computed } from 'vue'
import { usePrivacyStore } from '../store/privacy'
import { useBookshelfStore } from '../store/bookshelf'
import { ElMessage } from 'element-plus'
import { 
  Folder, 
  Files, 
  Collection, 
  Lock, 
  MoreFilled, 
  View, 
  Edit, 
  Upload, 
  Delete 
} from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  library: {
    type: Object,
    required: true
  }
})

// 定义事件
const emit = defineEmits(['click', 'open', 'edit', 'import', 'delete', 'privacy-changed'])

// 获取状态管理
const privacyStore = usePrivacyStore()
const bookshelfStore = useBookshelfStore()

// 计算库类型文本
const libraryTypeText = computed(() => {
  switch (props.library.type) {
    case 'folder':
      return '文件夹'
    case 'archive':
      return '压缩包'
    default:
      return '自定义'
  }
})

// 计算漫画数量
const comicsCount = computed(() => {
  if (props.library.comicsCount !== undefined) {
    return props.library.comicsCount
  }
  
  // 如果库对象中没有提供漫画数量，尝试从书架状态中获取
  const comics = bookshelfStore.comics.filter(comic => 
    comic.libraryId === props.library.id
  )
  
  return comics.length
})

// 计算是否为隐私库
const isPrivacy = computed(() => {
  return privacyStore.isPrivacyLibrary(props.library.id)
})

// 切换隐私状态
async function togglePrivacy() {
  try {
    // 如果当前不是隐私模式且要设置为隐私，需要先验证密码
    if (!isPrivacy.value && !privacyStore.isPrivacyModeAuthorized) {
      // 通知父组件需要验证
      emit('privacy-changed', { id: props.library.id, action: 'request-auth' })
      return
    }
    
    // 切换隐私状态
    await privacyStore.setLibraryPrivacy(props.library.id, !isPrivacy.value)
    
    // 通知父组件
    emit('privacy-changed', { 
      id: props.library.id, 
      isPrivacy: !isPrivacy.value,
      action: 'changed'
    })
    
    ElMessage.success(isPrivacy.value ? '已取消隐私设置' : '已设为隐私库')
  } catch (error) {
    console.error('切换隐私状态失败:', error)
    ElMessage.error('操作失败')
  }
}
</script>

<style scoped>
.library-card {
  position: relative;
  border-radius: 8px;
  overflow: hidden;
  background-color: var(--bg-color-light);
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.library-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.library-icon {
  font-size: 32px;
  color: var(--primary-color);
  display: flex;
  align-items: center;
  justify-content: center;
  width: 60px;
  height: 60px;
  background-color: var(--bg-color);
  border-radius: 8px;
}

.library-info {
  flex: 1;
  min-width: 0;
}

.library-title {
  margin: 0 0 5px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-color);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.library-description {
  margin: 0 0 8px 0;
  font-size: 13px;
  color: var(--text-color-secondary);
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  line-height: 1.4;
}

.library-meta {
  display: flex;
  gap: 15px;
  font-size: 12px;
  color: var(--text-color-secondary);
}

.library-status {
  position: absolute;
  top: 10px;
  right: 10px;
}

.library-actions {
  position: absolute;
  bottom: 10px;
  right: 10px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.library-card:hover .library-actions {
  opacity: 1;
}

.action-button {
  color: var(--text-color-secondary);
  font-size: 16px;
}

/* 状态样式 */
.library-card.is-privacy {
  border-left: 4px solid var(--danger-color);
}

/* 暗色模式适配 */
.dark .library-card {
  background-color: var(--bg-color-dark);
}

.dark .library-icon {
  background-color: var(--bg-color-light-dark);
}

.dark .library-title {
  color: var(--text-color-dark);
}

.dark .library-description,
.dark .library-meta {
  color: var(--text-color-secondary-dark);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .library-card {
    padding: 15px;
    gap: 10px;
  }
  
  .library-icon {
    font-size: 24px;
    width: 45px;
    height: 45px;
  }
  
  .library-title {
    font-size: 14px;
  }
  
  .library-description {
    font-size: 12px;
    -webkit-line-clamp: 1;
  }
  
  .library-meta {
    font-size: 11px;
  }
}
</style>