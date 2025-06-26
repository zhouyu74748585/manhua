<template>
  <div class="sort-dropdown">
    <el-dropdown @command="handleSortChange" trigger="click">
      <el-button type="default" size="small">
        <el-icon><Sort /></el-icon>
        {{ currentSortLabel }}
        <el-icon class="el-icon--right"><ArrowDown /></el-icon>
      </el-button>
      
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item 
            v-for="option in sortOptions" 
            :key="option.value" 
            :command="option.value"
            :class="{ 'is-active': modelValue === option.value }"
          >
            <el-icon v-if="option.icon"><component :is="option.icon" /></el-icon>
            {{ option.label }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
    
    <el-button 
      type="text" 
      size="small" 
      class="order-toggle" 
      @click="toggleOrder"
      :title="isAscending ? '降序排列' : '升序排列'"
    >
      <el-icon>
        <component :is="isAscending ? 'SortUp' : 'SortDown'" />
      </el-icon>
    </el-button>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { 
  Sort, 
  ArrowDown, 
  SortUp, 
  SortDown, 
  Calendar, 
  Reading, 
  Timer, 
  Document,
  Star
} from '@element-plus/icons-vue'

// 定义属性
const props = defineProps({
  // 当前排序字段
  modelValue: {
    type: String,
    default: 'title'
  },
  // 排序方向（true为升序，false为降序）
  ascending: {
    type: Boolean,
    default: true
  },
  // 自定义排序选项
  options: {
    type: Array,
    default: () => []
  }
})

// 定义事件
const emit = defineEmits(['update:modelValue', 'update:ascending', 'sort-change'])

// 默认排序选项
const defaultSortOptions = [
  { value: 'title', label: '按名称', icon: 'Document' },
  { value: 'lastReadTime', label: '按最近阅读', icon: 'Reading' },
  { value: 'addTime', label: '按添加时间', icon: 'Calendar' },
  { value: 'updateTime', label: '按更新时间', icon: 'Timer' },
  { value: 'rating', label: '按评分', icon: 'Star' }
]

// 合并排序选项
const sortOptions = computed(() => {
  if (props.options && props.options.length > 0) {
    return props.options
  }
  return defaultSortOptions
})

// 当前排序选项标签
const currentSortLabel = computed(() => {
  const option = sortOptions.value.find(opt => opt.value === props.modelValue)
  return option ? option.label : '排序'
})

// 是否升序
const isAscending = computed(() => props.ascending)

// 处理排序变更
function handleSortChange(value) {
  if (value === props.modelValue) return
  
  emit('update:modelValue', value)
  emit('sort-change', { field: value, ascending: isAscending.value })
}

// 切换排序方向
function toggleOrder() {
  const newOrder = !isAscending.value
  emit('update:ascending', newOrder)
  emit('sort-change', { field: props.modelValue, ascending: newOrder })
}
</script>

<style scoped>
.sort-dropdown {
  display: flex;
  align-items: center;
  gap: 5px;
}

.order-toggle {
  padding: 5px;
  border-radius: 4px;
}

.order-toggle:hover {
  background-color: var(--bg-color-light);
}

.is-active {
  color: var(--primary-color);
  font-weight: 500;
}

/* 暗色模式适配 */
.dark .order-toggle:hover {
  background-color: var(--bg-color-dark);
}
</style>