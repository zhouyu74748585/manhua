<template>
  <div class="not-found">
    <div class="not-found-content">
      <div class="error-code">404</div>
      <h1>页面未找到</h1>
      <p>抱歉，您访问的页面不存在或已被移除</p>
      <div class="actions">
        <el-button type="primary" @click="goHome">
          <el-icon><HomeFilled /></el-icon> 返回首页
        </el-button>
        <el-button @click="goBack">
          <el-icon><Back /></el-icon> 返回上一页
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { HomeFilled, Back } from '@element-plus/icons-vue'

const router = useRouter()

function goHome() {
  router.push('/')
}

function goBack() {
  router.go(-1)
}
</script>

<style scoped>
.not-found {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 120px);
  padding: 20px;
}

.not-found-content {
  text-align: center;
  max-width: 500px;
}

.error-code {
  font-size: 120px;
  font-weight: 700;
  color: var(--primary-color);
  line-height: 1;
  margin-bottom: 20px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

h1 {
  font-size: 28px;
  margin-bottom: 15px;
  color: var(--text-color);
}

p {
  font-size: 16px;
  color: var(--text-color-secondary);
  margin-bottom: 30px;
}

.actions {
  display: flex;
  justify-content: center;
  gap: 15px;
}

/* 暗色模式适配 */
.dark h1 {
  color: var(--text-color-dark);
}

.dark p {
  color: var(--text-color-secondary-dark);
}

/* 响应式调整 */
@media (max-width: 768px) {
  .error-code {
    font-size: 100px;
  }
  
  h1 {
    font-size: 24px;
  }
  
  p {
    font-size: 14px;
  }
  
  .actions {
    flex-direction: column;
    gap: 10px;
  }
}
</style>