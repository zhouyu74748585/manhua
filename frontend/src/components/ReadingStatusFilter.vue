<template>
  <div class="reading-status-filter">
    <div class="filter-header">
      <h3>阅读状态</h3>
      <el-button 
        v-if="selectedStatus !== 'all'" 
        type="text" 
        size="small" 
        @click="clearFilter"
      >
        清除
      </el-button>
    </div>
    
    <div class="status-options">
      <el-radio-group v-model="selectedStatus" @change="handleStatusChange">
        <el-radio-button label="all">
          全部
          <span class="status-count" v-if="counts.all">{{ counts.all }}</span>
        </el-radio-button>
        
        <el-radio-button label="unread">
          未读
          <span class="status-count" v-if="counts.unread">{{ counts.unread }}</span>
        </el-radio-button>
        
        <el-radio-button label="reading">
          阅读中
          <span class="status-count" v-if="counts.reading">{{ counts.reading }}</span>
        </el-radio-button>
        
        <el-radio-button label="completed">
          已读完
          <span class="status-count" v-if="counts.completed">{{ counts.completed }}</span>
        </el-radio-button>
      </el-radio-group>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

// 定义属性
const props = defineProps({
  // 当前选中的阅读状态
  modelValue: {
    type: String,
    default: 'all'
  },
  // 各状态的漫画数量
  statusCounts: {
    type: Object,
    default: () => ({})
  }
})

// 定义事件
const emit = defineEmits(['update:modelValue', 'filter-change'])

// 选中的状态
const selectedStatus = ref(props.modelValue || 'all')

// 状态计数
const counts = computed(() => {
  return {
    all: props.statusCounts.all || 0,
    unread: props.statusCounts.unread || 0,
    reading: props.statusCounts.reading || 0,
    completed: props.statusCounts.completed || 0
  }
})

// 监听 modelValue 变化
watch(() => props.modelValue, (newVal) => {
  selectedStatus.value = newVal || 'all'
}, { immediate: true })

// 处理状态变更
function handleStatusChange() {
  emit('update:modelValue', selectedStatus.value)
  emit('filter-change', selectedStatus.value)
}

// 清除筛选
function clearFilter() {
  selectedStatus.value = 'all'
  handleStatusChange()
}
</script>

<style scoped>
.reading-status-filter {
  width: 100%;
  margin-bottom: 20px;
}

.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.filter-header h3 {
  margin: 0;
  font-size: 16px;
  color: var(--text-color);
}

.status-options {
  width: 100%;
}

.status-options .el-radio-group {
  display: flex;
  width: 100%;
}

.status-options .el-radio-button {
  flex: 1;
  text-align: center;
}

.status-count {
  margin-left: 4px;
  font-size: 12px;
  opacity: 0.8;
}

/* 暗色模式适配 */
.dark .filter-header h3 {
  color: var(--text-color-dark);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .status-options .el-radio-group {
    flex-wrap: wrap;
    gap: 10px;
  }
  
  .status-options .el-radio-button {
    flex: 1 0 calc(50% - 5px);
  }
  
  .status-options :deep(.el-radio-button__inner) {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .status-options .el-radio-button {
    flex: 1 0 100%;
  }
}
</style>