<template>
  <div class="privacy-view">
    <template v-if="!isAuthorized">
      <!-- 未授权状态 - 显示验证界面 -->
      <div class="privacy-auth">
        <div class="lock-icon">
          <el-icon><Lock /></el-icon>
        </div>
        
        <h2>隐私模式</h2>
        <p>请输入密码以访问隐私内容</p>
        
        <div class="password-input">
          <el-input 
            v-model="password" 
            type="password" 
            placeholder="请输入密码" 
            show-password
            @keyup.enter="verifyPassword"
          />
          <el-button type="primary" @click="verifyPassword" :loading="verifying">
            验证
          </el-button>
        </div>
        
        <div v-if="authError" class="auth-error">
          {{ authError }}
        </div>
        
        <div class="auth-actions">
          <el-button @click="goBack" plain>
            返回
          </el-button>
        </div>
      </div>
    </template>
    
    <template v-else>
      <!-- 已授权状态 - 显示隐私内容 -->
      <div class="privacy-content">
        <div class="privacy-header">
          <h1>隐私模式</h1>
          <div class="privacy-actions">
            <el-button @click="exitPrivacyMode" type="danger" plain>
              <el-icon><Lock /></el-icon> 退出隐私模式
            </el-button>
          </div>
        </div>
        
        <!-- 隐私库 -->
        <div class="privacy-section">
          <h2>隐私库</h2>
          
          <div v-if="privacyLibraries.length === 0" class="empty-state">
            <el-empty description="没有隐私库" />
            <p>您可以在库设置中将任何库标记为隐私库</p>
          </div>
          
          <div v-else class="libraries-grid">
            <library-card 
              v-for="library in privacyLibraries" 
              :key="library.id" 
              :library="library"
              @click="openLibrary(library.id)"
            />
          </div>
        </div>
        
        <!-- 隐私漫画 -->
        <div class="privacy-section">
          <h2>隐私漫画</h2>
          
          <div v-if="isLoading" class="loading-container">
            <el-skeleton :rows="3" animated />
          </div>
          
          <div v-else-if="privacyComics.length === 0" class="empty-state">
            <el-empty description="没有隐私漫画" />
            <p>您可以在漫画详情中将任何漫画标记为隐私内容</p>
          </div>
          
          <div v-else class="comics-grid">
            <comic-card 
              v-for="comic in privacyComics" 
              :key="comic.id" 
              :comic="comic"
              @click="openComic(comic.id)"
            />
          </div>
        </div>
        
        <!-- 隐私设置 -->
        <div class="privacy-section">
          <h2>隐私设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="更改隐私密码">
              <div class="password-change">
                <el-input 
                  v-model="newPassword" 
                  type="password" 
                  placeholder="输入新密码" 
                  show-password
                />
                <el-button type="primary" @click="changePassword" :disabled="!newPassword">
                  更改密码
                </el-button>
              </div>
            </el-form-item>
            
            <el-form-item label="自动锁定">
              <el-switch v-model="autoLock" @change="savePrivacySettings" />
              <span class="setting-description">应用最小化或闲置时自动锁定隐私内容</span>
            </el-form-item>
            
            <el-form-item label="闲置锁定时间" v-if="autoLock">
              <el-select v-model="lockTimeout" @change="savePrivacySettings">
                <el-option label="1分钟" :value="1" />
                <el-option label="5分钟" :value="5" />
                <el-option label="10分钟" :value="10" />
                <el-option label="30分钟" :value="30" />
              </el-select>
            </el-form-item>
          </el-form>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import { usePrivacyStore } from '../store/privacy'
import { useLibraryStore } from '../store/library'
import { useBookshelfStore } from '../store/bookshelf'
import { ElMessage } from 'element-plus'
import { Lock } from '@element-plus/icons-vue'
import LibraryCard from '../components/LibraryCard.vue'
import ComicCard from '../components/ComicCard.vue'

const router = useRouter()
const privacyStore = usePrivacyStore()
const libraryStore = useLibraryStore()
const bookshelfStore = useBookshelfStore()

// 授权状态
const isAuthorized = computed(() => privacyStore.isPrivacyModeAuthorized)

// 验证相关
const password = ref('')
const verifying = ref(false)
const authError = ref('')

// 隐私内容
const isLoading = ref(true)
const privacyLibraries = computed(() => privacyStore.privacyLibraries)
const privacyComics = computed(() => privacyStore.privacyBooks)

// 隐私设置
const newPassword = ref('')
const autoLock = ref(true)
const lockTimeout = ref(5)
const idleTimer = ref(null)

// 验证密码
async function verifyPassword() {
  if (!password.value) {
    authError.value = '请输入密码'
    return
  }
  
  try {
    verifying.value = true
    authError.value = ''
    
    const success = await privacyStore.verifyPrivacyPassword(password.value)
    
    if (success) {
      // 验证成功，进入隐私模式
      await privacyStore.enterPrivacyMode()
      password.value = ''
    } else {
      // 验证失败
      authError.value = '密码错误，请重试'
    }
  } catch (error) {
    console.error('验证密码失败:', error)
    authError.value = '验证失败，请重试'
  } finally {
    verifying.value = false
  }
}

// 返回上一页
function goBack() {
  router.go(-1)
}

// 退出隐私模式
function exitPrivacyMode() {
  privacyStore.exitPrivacyMode()
  router.push('/')
}

// 打开库
function openLibrary(libraryId) {
  router.push(`/library/${libraryId}`)
}

// 打开漫画
function openComic(comicId) {
  router.push(`/reader/${comicId}`)
}

// 更改密码
async function changePassword() {
  if (!newPassword.value) {
    ElMessage.warning('请输入新密码')
    return
  }
  
  try {
    await privacyStore.setPrivacyPassword(newPassword.value)
    ElMessage.success('密码已更改')
    newPassword.value = ''
  } catch (error) {
    console.error('更改密码失败:', error)
    ElMessage.error('更改密码失败')
  }
}

// 保存隐私设置
function savePrivacySettings() {
  try {
    const settings = {
      autoLockPrivacyMode: autoLock.value,
      privacyLockTimeout: lockTimeout.value
    }
    
    localStorage.setItem('privacy_settings', JSON.stringify(settings))
    
    // 如果启用了自动锁定，设置闲置计时器
    if (autoLock.value) {
      setupIdleTimer()
    } else {
      clearIdleTimer()
    }
    
    ElMessage.success('设置已保存')
  } catch (error) {
    console.error('保存设置失败:', error)
    ElMessage.error('保存设置失败')
  }
}

// 设置闲置计时器
function setupIdleTimer() {
  // 清除现有计时器
  clearIdleTimer()
  
  // 如果启用了自动锁定，设置新计时器
  if (autoLock.value && isAuthorized.value) {
    const timeoutMs = lockTimeout.value * 60 * 1000 // 转换为毫秒
    
    idleTimer.value = setTimeout(() => {
      // 闲置时间到，退出隐私模式
      if (isAuthorized.value) {
        privacyStore.exitPrivacyMode()
        ElMessage.info('由于长时间闲置，隐私模式已自动锁定')
        
        // 如果当前在隐私页面，跳转到首页
        if (router.currentRoute.value.path === '/privacy') {
          router.push('/')
        }
      }
    }, timeoutMs)
  }
}

// 清除闲置计时器
function clearIdleTimer() {
  if (idleTimer.value) {
    clearTimeout(idleTimer.value)
    idleTimer.value = null
  }
}

// 重置闲置计时器
function resetIdleTimer() {
  if (autoLock.value && isAuthorized.value) {
    clearIdleTimer()
    setupIdleTimer()
  }
}

// 加载设置
function loadSettings() {
  try {
    const settings = JSON.parse(localStorage.getItem('privacy_settings') || '{}')
    
    autoLock.value = settings.autoLockPrivacyMode !== undefined ? settings.autoLockPrivacyMode : true
    lockTimeout.value = settings.privacyLockTimeout || 5
    
    // 如果启用了自动锁定，设置闲置计时器
    if (autoLock.value && isAuthorized.value) {
      setupIdleTimer()
    }
  } catch (error) {
    console.error('加载设置失败:', error)
  }
}

// 加载数据
async function loadData() {
  try {
    isLoading.value = true
    
    // 初始化隐私设置
    await privacyStore.initPrivacySettings()
    
    // 加载库和漫画
    await libraryStore.fetchLibraries()
    await bookshelfStore.fetchAllComics()
    
    // 加载设置
    loadSettings()
  } catch (error) {
    console.error('加载数据失败:', error)
    ElMessage.error('加载数据失败')
  } finally {
    isLoading.value = false
  }
}

// 组件挂载时
onMounted(() => {
  // 加载数据
  loadData()
  
  // 添加用户活动事件监听器
  window.addEventListener('mousemove', resetIdleTimer)
  window.addEventListener('keydown', resetIdleTimer)
  window.addEventListener('click', resetIdleTimer)
  
  // 添加窗口事件监听器
  window.electronAPI.onWindowBlur(() => {
    // 窗口失去焦点时，如果启用了自动锁定，退出隐私模式
    if (autoLock.value && isAuthorized.value) {
      privacyStore.exitPrivacyMode()
      
      // 如果当前在隐私页面，跳转到首页
      if (router.currentRoute.value.path === '/privacy') {
        router.push('/')
      }
    }
  })
})

// 组件卸载前
onBeforeUnmount(() => {
  // 移除事件监听器
  window.removeEventListener('mousemove', resetIdleTimer)
  window.removeEventListener('keydown', resetIdleTimer)
  window.removeEventListener('click', resetIdleTimer)
  
  // 清除计时器
  clearIdleTimer()
})
</script>

<style scoped>
.privacy-view {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* 未授权状态 */
.privacy-auth {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  text-align: center;
}

.lock-icon {
  font-size: 48px;
  margin-bottom: 20px;
  color: var(--primary-color);
}

.privacy-auth h2 {
  font-size: 24px;
  margin-bottom: 10px;
  color: var(--primary-color);
}

.privacy-auth p {
  margin-bottom: 20px;
  color: var(--text-color-secondary);
}

.password-input {
  display: flex;
  gap: 10px;
  width: 100%;
  max-width: 400px;
  margin-bottom: 15px;
}

.password-input .el-input {
  flex: 1;
}

.auth-error {
  color: var(--danger-color);
  margin-bottom: 15px;
}

.auth-actions {
  margin-top: 20px;
}

/* 已授权状态 */
.privacy-content {
  width: 100%;
}

.privacy-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}

.privacy-header h1 {
  font-size: 24px;
  margin: 0;
  color: var(--primary-color);
}

.privacy-section {
  margin-bottom: 40px;
}

.privacy-section h2 {
  font-size: 18px;
  margin-bottom: 20px;
  color: var(--primary-color);
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 10px;
}

.empty-state {
  text-align: center;
  padding: 30px 0;
}

.empty-state p {
  margin-top: 15px;
  color: var(--text-color-secondary);
}

.libraries-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}

.comics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
  gap: 20px;
}

.loading-container {
  padding: 30px 0;
}

.password-change {
  display: flex;
  gap: 10px;
  max-width: 400px;
}

.password-change .el-input {
  flex: 1;
}

.setting-description {
  font-size: 12px;
  color: var(--text-color-secondary);
  margin-left: 10px;
}

@media (max-width: 768px) {
  .privacy-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 15px;
  }
  
  .libraries-grid {
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  }
  
  .comics-grid {
    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  }
  
  .password-change {
    flex-direction: column;
  }
}
</style>