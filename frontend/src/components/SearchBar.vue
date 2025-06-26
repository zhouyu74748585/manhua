<template>
  <div class="search-bar">
    <el-input
      v-model="searchQuery"
      placeholder="搜索漫画..."
      clearable
      @input="handleSearch"
      @clear="clearSearch"
    >
      <template #prefix>
        <el-icon><Search /></el-icon>
      </template>
      
      <template #append v-if="showAdvanced">
        <el-button @click="toggleAdvanced">
          <el-icon><Setting /></el-icon>
        </el-button>
      </template>
    </el-input>
    
    <el-collapse-transition>
      <div v-if="showAdvanced && isAdvancedVisible" class="advanced-search">
        <div class="advanced-options">
          <div class="option-group">
            <h4>搜索范围</h4>
            <el-checkbox-group v-model="searchFields">
              <el-checkbox label="title">标题</el-checkbox>
              <el-checkbox label="tags">标签</el-checkbox>
              <el-checkbox label="author">作者</el-checkbox>
              <el-checkbox label="description">描述</el-checkbox>
            </el-checkbox-group>
          </div>
          
          <div class="option-group">
            <h4>搜索历史</h4>
            <div v-if="searchHistory.length > 0" class="search-history">
              <el-tag 
                v-for="(item, index) in searchHistory" 
                :key="index"
                size="small"
                closable
                @click="applyHistoryItem(item)"
                @close="removeHistoryItem(index)"
              >
                {{ item }}
              </el-tag>
              
              <el-button type="text" size="small" @click="clearHistory">
                清空历史
              </el-button>
            </div>
            <div v-else class="empty-history">
              <span>无搜索历史</span>
            </div>
          </div>
        </div>
        
        <div class="advanced-actions">
          <el-button size="small" @click="applyAdvancedSearch">
            应用
          </el-button>
          <el-button size="small" @click="toggleAdvanced">
            关闭
          </el-button>
        </div>
      </div>
    </el-collapse-transition>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { Search, Setting } from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  // 搜索关键词
  modelValue: {
    type: String,
    default: ''
  },
  // 是否显示高级搜索
  showAdvanced: {
    type: Boolean,
    default: true
  },
  // 搜索延迟（毫秒）
  searchDelay: {
    type: Number,
    default: 300
  },
  // 最大历史记录数
  maxHistory: {
    type: Number,
    default: 10
  }
})

// 定义事件
const emit = defineEmits(['update:modelValue', 'search', 'clear'])

// 搜索关键词
const searchQuery = ref('')

// 高级搜索是否可见
const isAdvancedVisible = ref(false)

// 搜索字段
const searchFields = ref(['title', 'tags'])

// 搜索历史
const searchHistory = ref([])

// 搜索计时器
let searchTimer = null

// 监听 modelValue 变化
watch(() => props.modelValue, (newVal) => {
  searchQuery.value = newVal
}, { immediate: true })

// 加载搜索历史
function loadSearchHistory() {
  try {
    const history = localStorage.getItem('search_history')
    if (history) {
      searchHistory.value = JSON.parse(history)
    }
  } catch (error) {
    console.error('加载搜索历史失败:', error)
    searchHistory.value = []
  }
}

// 保存搜索历史
function saveSearchHistory() {
  try {
    localStorage.setItem('search_history', JSON.stringify(searchHistory.value))
  } catch (error) {
    console.error('保存搜索历史失败:', error)
  }
}

// 添加搜索历史
function addToHistory(query) {
  if (!query || query.trim() === '') return
  
  // 移除已存在的相同查询
  const index = searchHistory.value.indexOf(query)
  if (index !== -1) {
    searchHistory.value.splice(index, 1)
  }
  
  // 添加到历史开头
  searchHistory.value.unshift(query)
  
  // 限制历史记录数量
  if (searchHistory.value.length > props.maxHistory) {
    searchHistory.value = searchHistory.value.slice(0, props.maxHistory)
  }
  
  // 保存历史
  saveSearchHistory()
}

// 移除历史记录项
function removeHistoryItem(index) {
  searchHistory.value.splice(index, 1)
  saveSearchHistory()
}

// 应用历史记录项
function applyHistoryItem(query) {
  searchQuery.value = query
  handleSearch()
}

// 清空历史记录
function clearHistory() {
  searchHistory.value = []
  saveSearchHistory()
}

// 处理搜索
function handleSearch() {
  // 清除之前的计时器
  if (searchTimer) {
    clearTimeout(searchTimer)
  }
  
  // 设置新的计时器
  searchTimer = setTimeout(() => {
    emit('update:modelValue', searchQuery.value)
    
    // 如果搜索词不为空，添加到历史记录
    if (searchQuery.value && searchQuery.value.trim() !== '') {
      addToHistory(searchQuery.value)
    }
    
    // 触发搜索事件
    emit('search', {
      query: searchQuery.value,
      fields: searchFields.value
    })
  }, props.searchDelay)
}

// 清除搜索
function clearSearch() {
  searchQuery.value = ''
  emit('update:modelValue', '')
  emit('clear')
}

// 切换高级搜索
function toggleAdvanced() {
  isAdvancedVisible.value = !isAdvancedVisible.value
}

// 应用高级搜索
function applyAdvancedSearch() {
  handleSearch()
}

// 组件挂载时加载搜索历史
loadSearchHistory()
</script>

<style scoped>
.search-bar {
  width: 100%;
  position: relative;
}

.advanced-search {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 10;
  background-color: var(--bg-color-light);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  margin-top: 5px;
  padding: 15px;
}

.advanced-options {
  margin-bottom: 15px;
}

.option-group {
  margin-bottom: 15px;
}

.option-group h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  color: var(--text-color);
  font-weight: 500;
}

.search-history {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
}

.empty-history {
  color: var(--text-color-secondary);
  font-size: 13px;
}

.advanced-actions {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

/* 暗色模式适配 */
.dark .advanced-search {
  background-color: var(--bg-color-dark);
  border-color: var(--border-color-dark);
}

.dark .option-group h4 {
  color: var(--text-color-dark);
}

.dark .empty-history {
  color: var(--text-color-secondary-dark);
}
</style>