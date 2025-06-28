<template>
  <div class="bookshelf-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h1>书架</h1>
        <p class="subtitle">浏览和管理您的漫画收藏</p>
      </div>
      <div class="header-right">
        <el-button-group>
          <el-button
            :type="viewMode === 'grid' ? 'primary' : 'default'"
            @click="viewMode = 'grid'"
            :icon="Grid"
          >
            网格
          </el-button>
          <el-button
            :type="viewMode === 'list' ? 'primary' : 'default'"
            @click="viewMode = 'list'"
            :icon="List"
          >
            列表
          </el-button>
        </el-button-group>
      </div>
    </div>

    <!-- 筛选和搜索 -->
    <div class="filter-bar">
      <div class="filter-left">
        <el-select
          v-model="filters.libraryId"
          placeholder="选择漫画库"
          clearable
          style="width: 200px"
        >
          <el-option label="全部漫画库" value="" />
          <el-option
            v-for="library in activeLibraries"
            :key="library.id"
            :label="library.name"
            :value="library.id"
          />
        </el-select>
        
        <el-select
          v-model="filters.status"
          placeholder="阅读状态"
          clearable
          style="width: 150px"
        >
          <el-option label="全部状态" value="" />
          <el-option label="未读" value="UNREAD" />
          <el-option label="阅读中" value="READING" />
          <el-option label="已完成" value="COMPLETED" />
        </el-select>
        
        <el-select
          v-model="sortOptions.field"
          style="width: 150px"
        >
          <el-option label="按标题排序" value="title" />
          <el-option label="按作者排序" value="author" />
          <el-option label="按创建时间" value="createdAt" />
          <el-option label="按最近阅读" value="lastReadAt" />
          <el-option label="按评分排序" value="rating" />
        </el-select>
        
        <el-button
          :icon="sortOptions.order === 'asc' ? SortUp : SortDown"
          @click="toggleSortOrder"
        />
      </div>
      
      <div class="filter-right">
        <el-input
          v-model="filters.searchText"
          placeholder="搜索漫画..."
          :prefix-icon="Search"
          style="width: 300px"
          clearable
        />
      </div>
    </div>

    <!-- 漫画列表 -->
    <div class="manga-content" v-loading="loading">
      <!-- 网格视图 -->
      <div v-if="viewMode === 'grid'" class="manga-grid">
        <div
          v-for="manga in filteredMangas"
          :key="manga.id"
          class="manga-card"
          @click="openReader(manga)"
        >
          <div class="manga-cover">
            <img
              :src="manga.coverImage || '/placeholder-cover.png'"
              :alt="manga.title"
              @error="handleImageError"
            />
            <div class="manga-overlay">
              <div class="progress-info">
                <span>{{ manga.currentPage }}/{{ manga.totalPages }}</span>
              </div>
              <div class="manga-actions">
                <el-button
                  :icon="Reading"
                  circle
                  size="small"
                  type="primary"
                />
              </div>
            </div>
          </div>
          
          <div class="manga-info">
            <h3 class="manga-title" :title="manga.title">{{ manga.title }}</h3>
            <p class="manga-author" v-if="manga.author">{{ manga.author }}</p>
            <div class="manga-meta">
              <el-tag
                :type="getStatusColor(manga.status)"
                size="small"
              >
                {{ getStatusText(manga.status) }}
              </el-tag>
              <div class="manga-rating" v-if="manga.rating">
                <el-rate
                  v-model="manga.rating"
                  disabled
                  size="small"
                  show-score
                />
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 列表视图 -->
      <div v-else class="manga-list">
        <el-table :data="filteredMangas" @row-click="openReader">
          <el-table-column width="80">
            <template #default="{ row }">
              <img
                :src="row.coverImage || '/placeholder-cover.png'"
                :alt="row.title"
                class="table-cover"
                @error="handleImageError"
              />
            </template>
          </el-table-column>
          
          <el-table-column prop="title" label="标题" min-width="200">
            <template #default="{ row }">
              <div class="table-title">
                <span class="title-text">{{ row.title }}</span>
                <div class="title-tags">
                  <el-tag
                    v-for="tag in (row.tags || []).slice(0, 3)"
                    :key="tag"
                    size="small"
                    type="info"
                  >
                    {{ tag }}
                  </el-tag>
                </div>
              </div>
            </template>
          </el-table-column>
          
          <el-table-column prop="author" label="作者" width="150" />
          
          <el-table-column label="进度" width="120">
            <template #default="{ row }">
              <div class="progress-cell">
                <span>{{ row.currentPage }}/{{ row.totalPages }}</span>
                <el-progress
                  :percentage="(row.currentPage / row.totalPages) * 100"
                  :show-text="false"
                  size="small"
                />
              </div>
            </template>
          </el-table-column>
          
          <el-table-column label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusColor(row.status)" size="small">
                {{ getStatusText(row.status) }}
              </el-tag>
            </template>
          </el-table-column>
          
          <el-table-column label="评分" width="120">
            <template #default="{ row }">
              <el-rate
                v-if="row.rating"
                v-model="row.rating"
                disabled
                size="small"
              />
            </template>
          </el-table-column>
          
          <el-table-column label="最近阅读" width="150">
            <template #default="{ row }">
              <span v-if="row.lastReadAt">
                {{ formatDate(row.lastReadAt) }}
              </span>
              <span v-else class="text-muted">未阅读</span>
            </template>
          </el-table-column>
          
          <el-table-column label="操作" width="120" fixed="right">
            <template #default="{ row }">
              <el-button
                :icon="Reading"
                size="small"
                @click.stop="openReader(row)"
              >
                阅读
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>
      
      <!-- 分页组件 -->
      <div v-if="filteredMangas.length > 0" class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="mangas?.size||20"
          :total="mangas?.totalElements||0"
          layout="total, prev, pager, next, jumper"
          @current-change="handlePageChange"
        />
      </div>
      
      <!-- 空状态 -->
      <el-empty v-if="filteredMangas.length === 0 && !loading" description="暂无漫画">
        <el-button type="primary" @click="$router.push('/library')">
          去添加漫画库
        </el-button>
      </el-empty>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { useLibraryStore } from '../stores/library'
import type { Manga } from '../types'

// 定义筛选选项类型
interface FilterOptions {
  libraryId: string
  status?: string
  searchText: string
}

// 定义排序选项类型
interface SortOptions {
  field: string
  order: 'asc' | 'desc'
}
import {
  Grid,
  List,
  Search,
  Reading,
  SortUp,
  SortDown,
} from '@element-plus/icons-vue'

const router = useRouter()
const libraryStore = useLibraryStore()

const viewMode = ref<'grid' | 'list'>('grid')
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(20)
const totalCount = ref(0)

// 筛选选项
const filters = ref<FilterOptions>({
  libraryId: '',
  status: undefined,
  searchText: ''
})

// 排序选项
const sortOptions = ref<SortOptions>({
  field: 'title',
  order: 'asc'
})

// 计算属性
const libraries = computed(() => libraryStore.libraries)
const mangas = computed(() => libraryStore.mangas)

// 计算属性 - 只显示激活库的漫画
const activeLibraries = computed(() => {
  return (libraries.value || []).filter(lib => lib.isActive)
})

// 筛选和排序后的漫画列表
const filteredMangas = computed(() => {
  let result = [...(mangas.value?.content || [])]
  
  // 应用排序
  result.sort((a, b) => {
    const field = sortOptions.value.field
    const order = sortOptions.value.order
    
    let aValue: any = a[field as keyof Manga]
    let bValue: any = b[field as keyof Manga]
    
    // 处理日期类型
    if (field === 'createdAt' || field === 'lastReadAt') {
      aValue = new Date(aValue || 0).getTime()
      bValue = new Date(bValue || 0).getTime()
    }
    
    // 处理字符串类型
    if (typeof aValue === 'string') {
      aValue = aValue.toLowerCase()
      bValue = bValue?.toLowerCase() || ''
    }
    
    if (aValue < bValue) {
      return order === 'asc' ? -1 : 1
    }
    if (aValue > bValue) {
      return order === 'asc' ? 1 : -1
    }
    return 0
  })
  
  return result
})

// 获取状态颜色
const getStatusColor = (status: Manga['status']) => {
  const colors = {
    UNREAD: 'info',
    READING: 'warning',
    COMPLETED: 'success'
  }
  return colors[status]
}

// 获取状态文本
const getStatusText = (status: Manga['status']) => {
  const texts = {
    UNREAD: '未读',
    READING: '阅读中',
    COMPLETED: '已完成'
  }
  return texts[status]
}

// 格式化日期
const formatDate = (date: Date | string) => {
  return new Date(date).toLocaleDateString('zh-CN')
}

// 切换排序顺序
const toggleSortOrder = () => {
  sortOptions.value.order = sortOptions.value.order === 'asc' ? 'desc' : 'asc'
}

// 处理图片加载错误
const handleImageError = (event: Event) => {
  const img = event.target as HTMLImageElement
  img.src = '/placeholder-cover.png'
}

// 打开阅读器
const openReader = (manga: Manga) => {
  router.push(`/reader/${manga.id}`)
}

// 筛选和排序处理函数
const handleFilter = async (reset: boolean = true) => {
  try {
    loading.value = true
    
    if (reset) {
      currentPage.value = 1
    }
    
    // 构建查询参数
    const params: any = {
      page: currentPage.value,
      limit: pageSize.value
    }
    
    if (filters.value.libraryId) {
      params.libraryId = filters.value.libraryId
    }
    
    if (filters.value.status && filters.value.status !== 'all') {
      params.status = filters.value.status
    }
    
    if (filters.value.searchText) {
      params.search = filters.value.searchText
    }
    
    if (sortOptions.value.field) {
      params.sort = sortOptions.value.field
      params.order = sortOptions.value.order
    }
    
    // 只查询激活库的漫画
    const activeLibraryIds = activeLibraries.value.map(lib => lib.id)
    if (activeLibraryIds.length > 0) {
      params.activeLibraryIds = activeLibraryIds.join(',') // 传递激活库的ID列表
    }
    
    // 调用后端API进行过滤
    const response = await libraryStore.loadMangas(undefined, params)
    
    // 更新总数
    if (response && response.data) {
      totalCount.value = response.data.totalElements || 0
    }
    
    // 保存筛选状态到本地存储
    localStorage.setItem('bookshelf-filters', JSON.stringify(filters.value))
  } catch (error) {
    console.error('筛选失败:', error)
    ElMessage.error('筛选失败')
  } finally {
    loading.value = false
  }
}



// 分页变化处理
const handlePageChange = (page: number) => {
  currentPage.value = page
  handleFilter(false)
}

// 监听筛选变化，保存到本地存储
watch(filters, (newFilters) => {
  // 只有当 filters 真正改变时才触发 handleFilter，避免 onMounted 时的重复调用
  localStorage.setItem('bookshelf-filters', JSON.stringify(newFilters))
  handleFilter(true)
}, { deep: true })

watch(sortOptions, (newSortOptions) => {
  localStorage.setItem('bookshelf-sort', JSON.stringify(newSortOptions))
  handleFilter(true) // 排序改变时重置到第一页
}, { deep: true })

watch(viewMode, (newViewMode) => {
  localStorage.setItem('bookshelf-view-mode', newViewMode)
})

// 初始化
  onMounted(async () => {
    // 先加载库列表
    await libraryStore.initializeData()
    
    const savedViewMode = localStorage.getItem('bookshelf-view-mode')
    if (savedViewMode) {
      viewMode.value = savedViewMode as 'grid' | 'list'
    }
    
    // 加载第一页数据
    await handleFilter(true)
  })

  // 监听路由变化，当回到书架页面时重新加载数据
  watch(() => router.currentRoute.value.path, async (newPath) => {
    if (newPath === '/bookshelf') {
       await libraryStore.initializeData()
       await handleFilter(true)
    }
  })
</script>

<style scoped>
.bookshelf-page {
  padding: 24px;
  height: 100%;
  display: flex;
  flex-direction: column;
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

.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  gap: 16px;
}

.filter-left {
  display: flex;
  gap: 12px;
  align-items: center;
}

.manga-content {
  flex: 1;
  overflow: auto;
}

/* 网格视图样式 */
.manga-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 20px;
  padding: 4px;
}

.manga-card {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  border-radius: 8px;
  overflow: hidden;
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-lighter);
}

.manga-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
}

.manga-cover {
  position: relative;
  aspect-ratio: 3/4;
  overflow: hidden;
}

.manga-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.manga-card:hover .manga-cover img {
  transform: scale(1.05);
}

.manga-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 60%, rgba(0, 0, 0, 0.8));
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 12px;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.manga-card:hover .manga-overlay {
  opacity: 1;
}

.progress-info {
  align-self: flex-end;
  background: rgba(0, 0, 0, 0.6);
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.manga-actions {
  display: flex;
  justify-content: center;
}

.manga-info {
  padding: 12px;
}

.manga-title {
  margin: 0 0 4px 0;
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.manga-author {
  margin: 0 0 8px 0;
  font-size: 12px;
  color: var(--el-text-color-regular);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.manga-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.manga-rating {
  font-size: 12px;
}

/* 列表视图样式 */
.manga-list {
  background: var(--el-bg-color);
  border-radius: 8px;
}

.table-cover {
  width: 50px;
  height: 70px;
  object-fit: cover;
  border-radius: 4px;
}

.table-title {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.title-text {
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.title-tags {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.progress-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.text-muted {
  color: var(--el-text-color-placeholder);
}

/* 分页样式 */
.pagination-container {
  display: flex;
  justify-content: center;
  padding: 20px;
  margin-top: 20px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .bookshelf-page {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .filter-bar {
    flex-direction: column;
    align-items: stretch;
  }
  
  .filter-left {
    flex-wrap: wrap;
  }
  
  .manga-grid {
    grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
    gap: 16px;
  }
}
</style>