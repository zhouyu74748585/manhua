<template>
  <div class="not-found-container">
    <div class="not-found-content">
      <div class="error-illustration">
        <svg viewBox="0 0 200 200" class="error-svg">
          <!-- 404 数字 -->
          <text x="100" y="80" class="error-number">404</text>
          
          <!-- 漫画书图标 -->
          <g class="book-icon">
            <rect x="70" y="120" width="60" height="40" rx="4" class="book-cover" />
            <rect x="75" y="125" width="50" height="30" rx="2" class="book-page" />
            <line x1="80" y1="135" x2="120" y2="135" class="book-line" />
            <line x1="80" y1="140" x2="115" y2="140" class="book-line" />
            <line x1="80" y1="145" x2="110" y2="145" class="book-line" />
          </g>
          
          <!-- 问号 -->
          <circle cx="150" cy="100" r="8" class="question-mark" />
          <text x="150" y="105" class="question-text">?</text>
        </svg>
      </div>
      
      <h1 class="error-title">页面未找到</h1>
      <p class="error-description">
        抱歉，您访问的页面不存在或已被移动。
      </p>
      
      <div class="error-actions">
        <el-button type="primary" @click="goHome" size="large">
          <el-icon><House /></el-icon>
          返回首页
        </el-button>
        <el-button @click="goBack" size="large">
          <el-icon><ArrowLeft /></el-icon>
          返回上页
        </el-button>
      </div>
      
      <div class="helpful-links">
        <h3>您可能想要：</h3>
        <ul>
          <li>
            <router-link to="/library" class="helpful-link">
              <el-icon><FolderOpened /></el-icon>
              管理漫画库
            </router-link>
          </li>
          <li>
            <router-link to="/bookshelf" class="helpful-link">
              <el-icon><Reading /></el-icon>
              浏览书架
            </router-link>
          </li>
          <li>
            <router-link to="/settings" class="helpful-link">
              <el-icon><Setting /></el-icon>
              应用设置
            </router-link>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import {
  House,
  ArrowLeft,
  FolderOpened,
  Reading,
  Setting
} from '@element-plus/icons-vue'

const router = useRouter()

const goHome = () => {
  router.push('/')
}

const goBack = () => {
  if (window.history.length > 1) {
    router.go(-1)
  } else {
    router.push('/')
  }
}
</script>

<style scoped>
.not-found-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
}

.not-found-content {
  text-align: center;
  max-width: 500px;
  background: var(--el-bg-color);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
}

.error-illustration {
  margin-bottom: 30px;
}

.error-svg {
  width: 200px;
  height: 200px;
  margin: 0 auto;
}

.error-number {
  font-size: 36px;
  font-weight: bold;
  fill: var(--el-color-primary);
  text-anchor: middle;
  font-family: 'Arial', sans-serif;
}

.book-cover {
  fill: var(--el-color-primary);
  opacity: 0.8;
}

.book-page {
  fill: var(--el-bg-color);
  stroke: var(--el-border-color);
  stroke-width: 1;
}

.book-line {
  stroke: var(--el-text-color-regular);
  stroke-width: 1;
  opacity: 0.6;
}

.question-mark {
  fill: var(--el-color-warning);
}

.question-text {
  font-size: 12px;
  font-weight: bold;
  fill: white;
  text-anchor: middle;
}

.error-title {
  font-size: 32px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin-bottom: 16px;
}

.error-description {
  font-size: 16px;
  color: var(--el-text-color-regular);
  margin-bottom: 32px;
  line-height: 1.6;
}

.error-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-bottom: 40px;
  flex-wrap: wrap;
}

.helpful-links {
  text-align: left;
}

.helpful-links h3 {
  font-size: 18px;
  color: var(--el-text-color-primary);
  margin-bottom: 16px;
  text-align: center;
}

.helpful-links ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.helpful-links li {
  margin-bottom: 12px;
}

.helpful-link {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border-radius: 8px;
  color: var(--el-text-color-primary);
  text-decoration: none;
  transition: all 0.3s ease;
  border: 1px solid var(--el-border-color);
}

.helpful-link:hover {
  background-color: var(--el-color-primary-light-9);
  border-color: var(--el-color-primary);
  color: var(--el-color-primary);
  transform: translateY(-2px);
}

.helpful-link .el-icon {
  font-size: 18px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .not-found-content {
    padding: 30px 20px;
    margin: 0 10px;
  }
  
  .error-svg {
    width: 150px;
    height: 150px;
  }
  
  .error-number {
    font-size: 28px;
  }
  
  .error-title {
    font-size: 24px;
  }
  
  .error-description {
    font-size: 14px;
  }
  
  .error-actions {
    flex-direction: column;
    align-items: center;
  }
  
  .error-actions .el-button {
    width: 100%;
    max-width: 200px;
  }
}

/* 暗色主题适配 */n.dark .not-found-container {
  background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
}

.dark .error-number {
  fill: var(--el-color-primary-light-3);
}

.dark .book-cover {
  fill: var(--el-color-primary-light-3);
}

/* 动画效果 */
.error-illustration {
  animation: float 3s ease-in-out infinite;
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.helpful-link {
  animation: slideInUp 0.6s ease-out;
  animation-fill-mode: both;
}

.helpful-links li:nth-child(1) .helpful-link {
  animation-delay: 0.1s;
}

.helpful-links li:nth-child(2) .helpful-link {
  animation-delay: 0.2s;
}

.helpful-links li:nth-child(3) .helpful-link {
  animation-delay: 0.3s;
}

@keyframes slideInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>