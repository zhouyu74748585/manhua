<template>
  <div class="tag-filter">
    <div class="filter-header">
      <h3>标签筛选</h3>
      <el-button 
        v-if="selectedTags.length > 0" 
        type="text" 
        size="small" 
        @click="clearAll"
      >
        清除全部
      </el-button>
    </div>
    
    <div v-if="loading" class="loading-tags">
      <el-skeleton :rows="3" animated />
    </div>
    
    <div v-else-if="availableTags.length === 0" class="empty-tags">
      <el-empty description="没有可用标签" :image-size="60" />
    </div>
    
    <div v-else class="tags-container">
      <el-checkbox-group v-model="selectedTags" @change="handleTagsChange">
        <div v-for="category in tagCategories" :key="category.name" class="tag-category">
          <h4 v-if="category.name !== 'default'">{{ category.name }}</h4>
          
          <div class="tag-list">
            <el-checkbox 
              v-for="tag in category.tags" 
              :key="tag" 
              :label="tag"
              border
            >
              {{ tag }}
              <span class="tag-count" v-if="tagCounts[tag]">{{ tagCounts[tag] }}</span>
            </el-checkbox>
          </div>
        </div>
      </el-checkbox-group>
    </div>
    
    <div v-if="selectedTags.length > 0" class="selected-tags">
      <div class="selected-header">
        <h4>已选标签</h4>
        <span class="tag-count-total">{{ selectedTags.length }}个</span>
      </div>
      
      <div class="selected-tag-list">
        <el-tag 
          v-for="tag in selectedTags" 
          :key="tag" 
          closable 
          @close="removeTag(tag)"
          size="small"
        >
          {{ tag }}
        </el-tag>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'

// 定义属性
const props = defineProps({
  // 所有可用标签
  tags: {
    type: Array,
    default: () => []
  },
  // 标签计数（每个标签对应的漫画数量）
  counts: {
    type: Object,
    default: () => ({})
  },
  // 已选标签
  modelValue: {
    type: Array,
    default: () => []
  },
  // 是否正在加载
  loading: {
    type: Boolean,
    default: false
  }
})

// 定义事件
const emit = defineEmits(['update:modelValue', 'filter-change'])

// 已选标签
const selectedTags = ref([])

// 标签计数
const tagCounts = computed(() => props.counts || {})

// 所有可用标签
const availableTags = computed(() => props.tags || [])

// 标签分类
const tagCategories = computed(() => {
  const categories = {
    default: { name: 'default', tags: [] }
  }
  
  // 处理标签分类
  // 格式：category:tag 或 tag
  availableTags.value.forEach(tag => {
    if (tag.includes(':')) {
      const [category, tagName] = tag.split(':', 2)
      
      if (!categories[category]) {
        categories[category] = { name: category, tags: [] }
      }
      
      categories[category].tags.push(tag)
    } else {
      categories.default.tags.push(tag)
    }
  })
  
  // 转换为数组并排序
  return Object.values(categories)
    .filter(category => category.tags.length > 0)
    .sort((a, b) => {
      // 默认分类始终排在最后
      if (a.name === 'default') return 1
      if (b.name === 'default') return -1
      return a.name.localeCompare(b.name)
    })
})

// 监听 modelValue 变化
watch(() => props.modelValue, (newVal) => {
  selectedTags.value = [...newVal]
}, { immediate: true })

// 处理标签变更
function handleTagsChange() {
  emit('update:modelValue', selectedTags.value)
  emit('filter-change', selectedTags.value)
}

// 移除标签
function removeTag(tag) {
  const index = selectedTags.value.indexOf(tag)
  if (index !== -1) {
    selectedTags.value.splice(index, 1)
    handleTagsChange()
  }
}

// 清除所有标签
function clearAll() {
  selectedTags.value = []
  handleTagsChange()
}
</script>

<style scoped>
.tag-filter {
  width: 100%;
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

.loading-tags,
.empty-tags {
  padding: 20px 0;
}

.tag-category {
  margin-bottom: 15px;
}

.tag-category h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  color: var(--text-color-secondary);
  font-weight: 500;
}

.tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 10px;
}

.tag-count {
  margin-left: 5px;
  font-size: 12px;
  color: var(--text-color-secondary);
}

.selected-tags {
  margin-top: 20px;
  padding-top: 15px;
  border-top: 1px solid var(--border-color);
}

.selected-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.selected-header h4 {
  margin: 0;
  font-size: 14px;
  color: var(--text-color);
}

.tag-count-total {
  font-size: 12px;
  color: var(--text-color-secondary);
}

.selected-tag-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* 暗色模式适配 */
.dark .filter-header h3,
.dark .selected-header h4 {
  color: var(--text-color-dark);
}

.dark .tag-category h4,
.dark .tag-count,
.dark .tag-count-total {
  color: var(--text-color-secondary-dark);
}
</style>