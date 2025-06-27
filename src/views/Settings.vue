<template>
  <div class="settings-page">
    <div class="page-header">
      <h1>设置</h1>
      <p class="subtitle">配置您的阅读偏好和应用设置</p>
    </div>

    <div class="settings-content">
      <el-tabs v-model="activeTab" class="settings-tabs">
        <!-- 通用设置 -->
        <el-tab-pane label="通用" name="general">
          <div class="settings-section">
            <h3>外观</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>主题</span>
                <p class="setting-desc">选择应用的外观主题</p>
              </div>
              <el-select v-model="settings.theme" @change="handleThemeChange">
                <el-option label="跟随系统" value="auto" />
                <el-option label="浅色主题" value="light" />
                <el-option label="深色主题" value="dark" />
              </el-select>
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>语言</span>
                <p class="setting-desc">选择界面语言</p>
              </div>
              <el-select v-model="settings.language">
                <el-option label="简体中文" value="zh-CN" />
                <el-option label="English" value="en-US" />
              </el-select>
            </div>
          </div>

          <div class="settings-section">
            <h3>缓存</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>缓存大小限制</span>
                <p class="setting-desc">设置本地缓存的最大大小</p>
              </div>
              <div class="cache-setting">
                <el-slider
                  v-model="settings.cacheSize"
                  :min="100"
                  :max="10000"
                  :step="100"
                  show-input
                  :format-tooltip="formatCacheSize"
                />
                <span class="cache-unit">MB</span>
              </div>
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>当前缓存使用</span>
                <p class="setting-desc">查看当前缓存使用情况</p>
              </div>
              <div class="cache-info">
                <el-progress
                  :percentage="cacheUsagePercentage"
                  :color="getCacheColor()"
                />
                <div class="cache-details">
                  <span>{{ formatBytes(currentCacheSize) }} / {{ formatBytes(settings.cacheSize * 1024 * 1024) }}</span>
                  <el-button size="small" @click="clearCache">清理缓存</el-button>
                </div>
              </div>
            </div>
          </div>

          <div class="settings-section">
            <h3>自动化</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>自动扫描</span>
                <p class="setting-desc">启动时自动扫描漫画库更新</p>
              </div>
              <el-switch v-model="settings.autoScan" />
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>检查更新</span>
                <p class="setting-desc">自动检查应用更新</p>
              </div>
              <el-switch v-model="settings.checkUpdates" />
            </div>
          </div>
        </el-tab-pane>

        <!-- 阅读设置 -->
        <el-tab-pane label="阅读" name="reader">
          <div class="settings-section">
            <h3>阅读模式</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>默认阅读模式</span>
                <p class="setting-desc">选择打开漫画时的默认阅读模式</p>
              </div>
              <el-radio-group v-model="settings.readerSettings.readingMode">
                <el-radio label="single">单页模式</el-radio>
                <el-radio label="double">双页模式</el-radio>
                <el-radio label="continuous">连续滚动</el-radio>
              </el-radio-group>
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>阅读方向</span>
                <p class="setting-desc">设置翻页方向</p>
              </div>
              <el-radio-group v-model="settings.readerSettings.readingDirection">
                <el-radio label="ltr">从左到右</el-radio>
                <el-radio label="rtl">从右到左</el-radio>
              </el-radio-group>
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>适应模式</span>
                <p class="setting-desc">图片在阅读器中的显示方式</p>
              </div>
              <el-radio-group v-model="settings.readerSettings.fitMode">
                <el-radio label="width">适应宽度</el-radio>
                <el-radio label="height">适应高度</el-radio>
                <el-radio label="original">原始大小</el-radio>
              </el-radio-group>
            </div>
          </div>

          <div class="settings-section">
            <h3>界面</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>背景颜色</span>
                <p class="setting-desc">阅读器背景颜色</p>
              </div>
              <el-color-picker v-model="settings.readerSettings.backgroundColor" />
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>自动隐藏界面</span>
                <p class="setting-desc">阅读时自动隐藏工具栏</p>
              </div>
              <el-switch v-model="settings.readerSettings.autoHideUI" />
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>启用全屏</span>
                <p class="setting-desc">允许全屏阅读</p>
              </div>
              <el-switch v-model="settings.readerSettings.enableFullscreen" />
            </div>
          </div>

          <div class="settings-section">
            <h3>性能</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>预加载页数</span>
                <p class="setting-desc">提前加载的页面数量</p>
              </div>
              <el-input-number
                v-model="settings.readerSettings.preloadPages"
                :min="1"
                :max="10"
                controls-position="right"
              />
            </div>
            
            <div class="setting-item">
              <div class="setting-label">
                <span>启用缩放</span>
                <p class="setting-desc">允许图片缩放功能</p>
              </div>
              <el-switch v-model="settings.readerSettings.enableZoom" />
            </div>
          </div>
        </el-tab-pane>

        <!-- 隐私设置 -->
        <el-tab-pane label="隐私" name="privacy">
          <div class="settings-section">
            <h3>隐私模式</h3>
            <div class="setting-item">
              <div class="setting-label">
                <span>启用隐私模式</span>
                <p class="setting-desc">保护敏感内容的访问</p>
              </div>
              <el-switch v-model="privacySettings.enabled" />
            </div>
            
            <div v-if="privacySettings.enabled" class="privacy-config">
              <div class="setting-item">
                <div class="setting-label">
                  <span>设置密码</span>
                  <p class="setting-desc">用于访问隐私内容的密码</p>
                </div>
                <div class="password-setting">
                  <el-input
                    v-model="newPassword"
                    type="password"
                    placeholder="输入新密码"
                    show-password
                  />
                  <el-button @click="updatePassword" :disabled="!newPassword">
                    更新密码
                  </el-button>
                </div>
              </div>
              
              <div class="setting-item">
                <div class="setting-label">
                  <span>会话超时</span>
                  <p class="setting-desc">隐私模式自动退出时间（分钟）</p>
                </div>
                <el-input-number
                  v-model="privacySettings.sessionTimeout"
                  :min="5"
                  :max="120"
                  controls-position="right"
                />
              </div>
            </div>
          </div>
        </el-tab-pane>

        <!-- 关于 -->
        <el-tab-pane label="关于" name="about">
          <div class="settings-section">
            <div class="about-info">
              <div class="app-icon">
                <el-icon size="64"><Reading /></el-icon>
              </div>
              <h2>漫画阅读器</h2>
              <p class="version">版本 {{ appVersion }}</p>
              <p class="description">
                一款现代化的桌面漫画阅读软件，支持多种文件格式和远程协议，
                为您提供优质的阅读体验。
              </p>
            </div>
            
            <div class="about-actions">
              <el-button @click="checkForUpdates" :loading="checkingUpdates">
                检查更新
              </el-button>
              <el-button @click="openGithub">
                GitHub
              </el-button>
              <el-button @click="showLicense">
                许可证
              </el-button>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- 保存按钮 -->
    <div class="settings-footer">
      <el-button @click="resetSettings">重置为默认</el-button>
      <el-button type="primary" @click="saveSettings" :loading="saving">
        保存设置
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useThemeStore } from '../stores/theme'
import type { AppSettings, PrivacyConfig } from '../types'
import { Reading } from '@element-plus/icons-vue'

const themeStore = useThemeStore()
const activeTab = ref('general')
const saving = ref(false)
const checkingUpdates = ref(false)
const newPassword = ref('')
const appVersion = ref('1.0.0')
const currentCacheSize = ref(0)

// 默认设置
const defaultSettings: AppSettings = {
  theme: 'auto',
  language: 'zh-CN',
  cacheSize: 1000,
  autoScan: true,
  checkUpdates: true,
  readerSettings: {
    readingMode: 'single',
    readingDirection: 'ltr',
    fitMode: 'width',
    backgroundColor: '#000000',
    autoHideUI: true,
    preloadPages: 3,
    enableZoom: true,
    enableFullscreen: true
  }
}

// 当前设置
const settings = reactive<AppSettings>({ ...defaultSettings })

// 隐私设置
const privacySettings = reactive<PrivacyConfig>({
  enabled: false,
  sessionTimeout: 30,
  biometricEnabled: false
})

// 计算缓存使用百分比
const cacheUsagePercentage = computed(() => {
  const maxSize = settings.cacheSize * 1024 * 1024 // 转换为字节
  return Math.min((currentCacheSize.value / maxSize) * 100, 100)
})

// 格式化缓存大小
const formatCacheSize = (value: number) => {
  return `${value} MB`
}

// 格式化字节
const formatBytes = (bytes: number) => {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 获取缓存颜色
const getCacheColor = () => {
  const percentage = cacheUsagePercentage.value
  if (percentage < 70) return '#67c23a'
  if (percentage < 90) return '#e6a23c'
  return '#f56c6c'
}

// 处理主题变化
const handleThemeChange = (theme: string) => {
  if (theme === 'auto') {
    // 跟随系统主题
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    themeStore.setTheme(prefersDark ? 'dark' : 'light')
  } else {
    themeStore.setTheme(theme as 'light' | 'dark')
  }
}

// 清理缓存
const clearCache = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要清理所有缓存吗？这将删除所有已缓存的漫画页面。',
      '确认清理',
      {
        confirmButtonText: '清理',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    // 这里调用清理缓存的API
    currentCacheSize.value = 0
    ElMessage.success('缓存清理完成')
  } catch (error) {
    // 用户取消
  }
}

// 更新密码
const updatePassword = async () => {
  if (!newPassword.value) return
  
  try {
    // 这里应该调用加密和存储密码的API
    // const hashedPassword = await hashPassword(newPassword.value)
    // privacySettings.passwordHash = hashedPassword
    
    newPassword.value = ''
    ElMessage.success('密码更新成功')
  } catch (error) {
    ElMessage.error('密码更新失败')
  }
}

// 检查更新
const checkForUpdates = async () => {
  checkingUpdates.value = true
  try {
    // 模拟检查更新
    await new Promise(resolve => setTimeout(resolve, 2000))
    ElMessage.info('当前已是最新版本')
  } catch (error) {
    ElMessage.error('检查更新失败')
  } finally {
    checkingUpdates.value = false
  }
}

// 打开GitHub
const openGithub = () => {
  // 这里应该调用Electron的shell.openExternal
  window.open('https://github.com/your-repo/manga-reader', '_blank')
}

// 显示许可证
const showLicense = () => {
  ElMessageBox.alert(
    'MIT License\n\nCopyright (c) 2024 Manga Reader\n\nPermission is hereby granted...',
    '许可证信息',
    {
      confirmButtonText: '确定'
    }
  )
}

// 重置设置
const resetSettings = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要重置所有设置为默认值吗？',
      '确认重置',
      {
        confirmButtonText: '重置',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    Object.assign(settings, defaultSettings)
    ElMessage.success('设置已重置')
  } catch (error) {
    // 用户取消
  }
}

// 保存设置
const saveSettings = async () => {
  saving.value = true
  try {
    // 保存到本地存储
    localStorage.setItem('app-settings', JSON.stringify(settings))
    localStorage.setItem('privacy-settings', JSON.stringify(privacySettings))
    
    ElMessage.success('设置保存成功')
  } catch (error) {
    ElMessage.error('设置保存失败')
  } finally {
    saving.value = false
  }
}

// 加载设置
const loadSettings = () => {
  try {
    const savedSettings = localStorage.getItem('app-settings')
    if (savedSettings) {
      Object.assign(settings, JSON.parse(savedSettings))
    }
    
    const savedPrivacySettings = localStorage.getItem('privacy-settings')
    if (savedPrivacySettings) {
      Object.assign(privacySettings, JSON.parse(savedPrivacySettings))
    }
  } catch (error) {
    console.error('加载设置失败:', error)
  }
}

// 获取应用版本
const getAppVersion = async () => {
  try {
    if (window.electronAPI) {
      appVersion.value = await window.electronAPI.getAppVersion()
    }
  } catch (error) {
    console.error('获取版本信息失败:', error)
  }
}

// 初始化
onMounted(async () => {
  loadSettings()
  await getAppVersion()
  
  // 模拟获取当前缓存大小
  currentCacheSize.value = Math.random() * settings.cacheSize * 1024 * 1024 * 0.5
})
</script>

<style scoped>
.settings-page {
  padding: 24px;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
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

.settings-content {
  flex: 1;
  overflow: auto;
}

.settings-tabs {
  height: 100%;
}

.settings-section {
  margin-bottom: 32px;
}

.settings-section h3 {
  margin: 0 0 16px 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  border-bottom: 1px solid var(--el-border-color-lighter);
  padding-bottom: 8px;
}

.setting-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid var(--el-border-color-extra-light);
}

.setting-item:last-child {
  border-bottom: none;
}

.setting-label {
  flex: 1;
  margin-right: 24px;
}

.setting-label span {
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.setting-desc {
  margin: 4px 0 0 0;
  font-size: 12px;
  color: var(--el-text-color-regular);
  line-height: 1.4;
}

.cache-setting {
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 300px;
}

.cache-unit {
  font-size: 14px;
  color: var(--el-text-color-regular);
}

.cache-info {
  min-width: 300px;
}

.cache-details {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 8px;
  font-size: 12px;
  color: var(--el-text-color-regular);
}

.privacy-config {
  margin-left: 24px;
  padding-left: 24px;
  border-left: 2px solid var(--el-border-color-light);
}

.password-setting {
  display: flex;
  gap: 12px;
  min-width: 300px;
}

.password-setting .el-input {
  flex: 1;
}

.about-info {
  text-align: center;
  padding: 32px;
}

.app-icon {
  margin-bottom: 16px;
  color: var(--el-color-primary);
}

.about-info h2 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.version {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: var(--el-text-color-regular);
}

.description {
  margin: 0 0 32px 0;
  color: var(--el-text-color-regular);
  line-height: 1.6;
  max-width: 500px;
  margin-left: auto;
  margin-right: auto;
}

.about-actions {
  display: flex;
  justify-content: center;
  gap: 12px;
}

.settings-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding-top: 24px;
  border-top: 1px solid var(--el-border-color-lighter);
  margin-top: 24px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .settings-page {
    padding: 16px;
  }
  
  .setting-item {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .setting-label {
    margin-right: 0;
  }
  
  .cache-setting,
  .password-setting,
  .cache-info {
    min-width: auto;
  }
  
  .settings-footer {
    flex-direction: column;
  }
  
  .about-actions {
    flex-direction: column;
  }
}
</style>