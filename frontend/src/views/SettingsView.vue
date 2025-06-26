<template>
  <div class="settings-view">
    <h1>设置</h1>
    
    <el-tabs v-model="activeTab" class="settings-tabs">
      <!-- 常规设置 -->
      <el-tab-pane label="常规" name="general">
        <div class="settings-section">
          <h2>应用设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="主题">
              <el-radio-group v-model="theme" @change="handleThemeChange">
                <el-radio label="light">浅色</el-radio>
                <el-radio label="dark">深色</el-radio>
                <el-radio label="system">跟随系统</el-radio>
              </el-radio-group>
            </el-form-item>
            
            <el-form-item label="启动时">
              <el-select v-model="startupAction" @change="saveSettings">
                <el-option label="显示主页" value="home" />
                <el-option label="显示上次阅读的漫画" value="last_read" />
                <el-option label="显示上次访问的库" value="last_library" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="自动检查更新">
              <el-switch v-model="autoCheckUpdates" @change="saveSettings" />
            </el-form-item>
            
            <el-form-item label="开机自启动">
              <el-switch v-model="autoStart" @change="handleAutoStartChange" />
            </el-form-item>
          </el-form>
        </div>
        
        <div class="settings-section">
          <h2>文件关联</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="关联漫画文件格式">
              <el-checkbox-group v-model="fileAssociations" @change="handleFileAssociationsChange">
                <el-checkbox label="cbz">CBZ</el-checkbox>
                <el-checkbox label="cbr">CBR</el-checkbox>
                <el-checkbox label="cb7">CB7</el-checkbox>
                <el-checkbox label="zip">ZIP</el-checkbox>
                <el-checkbox label="rar">RAR</el-checkbox>
                <el-checkbox label="7z">7Z</el-checkbox>
                <el-checkbox label="pdf">PDF</el-checkbox>
              </el-checkbox-group>
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" @click="setAsDefaultApp">设为默认漫画阅读器</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>
      
      <!-- 阅读设置 -->
      <el-tab-pane label="阅读" name="reading">
        <div class="settings-section">
          <h2>默认阅读设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="默认阅读模式">
              <el-select v-model="defaultReadingMode" @change="saveReaderSettings">
                <el-option label="单页模式" value="single" />
                <el-option label="双页模式" value="double" />
                <el-option label="连续模式" value="continuous" />
                <el-option label="条漫模式" value="webtoon" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="默认阅读方向">
              <el-radio-group v-model="defaultReadingDirection" @change="saveReaderSettings">
                <el-radio label="ltr">从左到右</el-radio>
                <el-radio label="rtl">从右到左</el-radio>
              </el-radio-group>
            </el-form-item>
            
            <el-form-item label="默认缩放">
              <el-select v-model="defaultZoomLevel" @change="saveReaderSettings">
                <el-option label="适合宽度" value="fit-width" />
                <el-option label="适合高度" value="fit-height" />
                <el-option label="适合页面" value="fit-page" />
                <el-option label="100%" value="100" />
                <el-option label="125%" value="125" />
                <el-option label="150%" value="150" />
                <el-option label="200%" value="200" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="默认背景颜色">
              <el-radio-group v-model="defaultBackgroundColor" @change="saveReaderSettings">
                <el-radio label="white">白色</el-radio>
                <el-radio label="black">黑色</el-radio>
                <el-radio label="gray">灰色</el-radio>
                <el-radio label="sepia">棕褐色</el-radio>
              </el-radio-group>
            </el-form-item>
            
            <el-form-item label="预加载页数">
              <el-slider 
                v-model="preloadPages" 
                :min="0" 
                :max="10" 
                :format-tooltip="(val) => val === 0 ? '不预加载' : `${val}页`"
                @change="saveReaderSettings"
              />
            </el-form-item>
            
            <el-form-item label="自动隐藏UI">
              <el-switch v-model="autoHideUI" @change="saveReaderSettings" />
              <span class="setting-description">阅读时自动隐藏界面元素</span>
            </el-form-item>
            
            <el-form-item label="记住每本漫画的设置">
              <el-switch v-model="rememberPerComicSettings" @change="saveReaderSettings" />
              <span class="setting-description">为每本漫画保存单独的阅读设置</span>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>
      
      <!-- 库设置 -->
      <el-tab-pane label="库管理" name="library">
        <div class="settings-section">
          <h2>漫画库设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="自动扫描库变更">
              <el-switch v-model="autoScanLibraries" @change="saveSettings" />
              <span class="setting-description">定期检查库文件变更并自动更新</span>
            </el-form-item>
            
            <el-form-item label="扫描间隔" v-if="autoScanLibraries">
              <el-select v-model="scanInterval" @change="saveSettings">
                <el-option label="每小时" value="hourly" />
                <el-option label="每天" value="daily" />
                <el-option label="每周" value="weekly" />
                <el-option label="仅在启动时" value="startup" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="元数据获取">
              <el-switch v-model="fetchMetadata" @change="saveSettings" />
              <span class="setting-description">从在线源获取漫画元数据</span>
            </el-form-item>
            
            <el-form-item label="元数据源" v-if="fetchMetadata">
              <el-select v-model="metadataSource" @change="saveSettings">
                <el-option label="自动选择" value="auto" />
                <el-option label="ComicVine" value="comicvine" />
                <el-option label="MangaUpdates" value="mangaupdates" />
                <el-option label="MyAnimeList" value="myanimelist" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="缩略图质量">
              <el-select v-model="thumbnailQuality" @change="saveSettings">
                <el-option label="低 (更快)" value="low" />
                <el-option label="中" value="medium" />
                <el-option label="高 (更清晰)" value="high" />
              </el-select>
            </el-form-item>
          </el-form>
        </div>
        
        <div class="settings-section">
          <h2>漫画库管理</h2>
          
          <el-table :data="libraries" style="width: 100%">
            <el-table-column prop="name" label="名称" />
            <el-table-column prop="type" label="类型">
              <template #default="scope">
                {{ formatLibraryType(scope.row.type) }}
              </template>
            </el-table-column>
            <el-table-column prop="path" label="路径" show-overflow-tooltip />
            <el-table-column label="操作" width="200">
              <template #default="scope">
                <el-button-group>
                  <el-button size="small" @click="scanLibrary(scope.row.id)">
                    <el-icon><Refresh /></el-icon> 扫描
                  </el-button>
                  <el-button size="small" @click="openLibrary(scope.row.id)">
                    <el-icon><View /></el-icon> 查看
                  </el-button>
                </el-button-group>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
      
      <!-- 隐私设置 -->
      <el-tab-pane label="隐私" name="privacy">
        <div class="settings-section">
          <h2>隐私模式设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="隐私模式密码">
              <div class="password-input">
                <el-input 
                  v-model="privacyPassword" 
                  type="password" 
                  placeholder="设置隐私模式密码" 
                  show-password 
                />
                <el-button type="primary" @click="savePrivacyPassword">保存</el-button>
              </div>
            </el-form-item>
            
            <el-form-item label="自动锁定">
              <el-switch v-model="autoLockPrivacyMode" @change="savePrivacySettings" />
              <span class="setting-description">应用最小化或闲置时自动锁定隐私内容</span>
            </el-form-item>
            
            <el-form-item label="闲置锁定时间" v-if="autoLockPrivacyMode">
              <el-select v-model="privacyLockTimeout" @change="savePrivacySettings">
                <el-option label="1分钟" :value="1" />
                <el-option label="5分钟" :value="5" />
                <el-option label="10分钟" :value="10" />
                <el-option label="30分钟" :value="30" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="隐私模式图标">
              <el-switch v-model="showPrivacyIcon" @change="savePrivacySettings" />
              <span class="setting-description">在应用标题栏显示隐私模式状态图标</span>
            </el-form-item>
          </el-form>
        </div>
        
        <div class="settings-section">
          <h2>数据隐私</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="阅读历史">
              <el-button @click="clearReadingHistory">清除阅读历史</el-button>
            </el-form-item>
            
            <el-form-item label="搜索历史">
              <el-button @click="clearSearchHistory">清除搜索历史</el-button>
            </el-form-item>
            
            <el-form-item label="缓存数据">
              <el-button @click="clearCache">清除缓存</el-button>
            </el-form-item>
            
            <el-form-item label="所有数据">
              <el-button type="danger" @click="confirmResetApp">重置应用</el-button>
              <span class="setting-description">将删除所有设置和数据</span>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>
      
      <!-- 高级设置 -->
      <el-tab-pane label="高级" name="advanced">
        <div class="settings-section">
          <h2>高级设置</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="缓存大小">
              <el-select v-model="cacheSize" @change="saveSettings">
                <el-option label="256 MB" :value="256" />
                <el-option label="512 MB" :value="512" />
                <el-option label="1 GB" :value="1024" />
                <el-option label="2 GB" :value="2048" />
                <el-option label="4 GB" :value="4096" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="并行加载数">
              <el-slider 
                v-model="parallelLoading" 
                :min="1" 
                :max="10" 
                :format-tooltip="(val) => `${val}个`"
                @change="saveSettings"
              />
              <span class="setting-description">同时加载的图片数量，较高的值可能导致性能问题</span>
            </el-form-item>
            
            <el-form-item label="日志级别">
              <el-select v-model="logLevel" @change="saveSettings">
                <el-option label="错误" value="error" />
                <el-option label="警告" value="warn" />
                <el-option label="信息" value="info" />
                <el-option label="调试" value="debug" />
              </el-select>
            </el-form-item>
            
            <el-form-item label="开发者工具">
              <el-button @click="toggleDevTools">打开开发者工具</el-button>
            </el-form-item>
          </el-form>
        </div>
        
        <div class="settings-section">
          <h2>数据导入/导出</h2>
          
          <el-form label-position="left" label-width="180px">
            <el-form-item label="导出设置">
              <el-button @click="exportSettings">导出设置</el-button>
              <span class="setting-description">将所有设置导出为JSON文件</span>
            </el-form-item>
            
            <el-form-item label="导入设置">
              <el-button @click="importSettings">导入设置</el-button>
              <span class="setting-description">从JSON文件导入设置</span>
            </el-form-item>
            
            <el-form-item label="导出库数据">
              <el-button @click="exportLibraryData">导出库数据</el-button>
              <span class="setting-description">将漫画库数据导出为备份文件</span>
            </el-form-item>
            
            <el-form-item label="导入库数据">
              <el-button @click="importLibraryData">导入库数据</el-button>
              <span class="setting-description">从备份文件导入漫画库数据</span>
            </el-form-item>
          </el-form>
        </div>
      </el-tab-pane>
      
      <!-- 关于 -->
      <el-tab-pane label="关于" name="about">
        <div class="settings-section about-section">
          <div class="app-logo">
            <img src="../assets/logo.png" alt="漫画阅读器" />
          </div>
          
          <h2>漫画阅读器</h2>
          <p class="version">版本 {{ appVersion }}</p>
          
          <div class="about-actions">
            <el-button @click="checkForUpdates" :loading="checkingUpdates">
              检查更新
            </el-button>
            <el-button @click="openProjectWebsite">
              项目主页
            </el-button>
          </div>
          
          <div class="about-info">
            <p>一个功能强大的漫画阅读器，支持多种格式和来源。</p>
            <p>© 2023 漫画阅读器团队</p>
          </div>
          
          <div class="system-info">
            <h3>系统信息</h3>
            <ul>
              <li><strong>操作系统:</strong> {{ systemInfo.os }}</li>
              <li><strong>Electron:</strong> {{ systemInfo.electron }}</li>
              <li><strong>Chrome:</strong> {{ systemInfo.chrome }}</li>
              <li><strong>Node.js:</strong> {{ systemInfo.node }}</li>
            </ul>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useThemeStore } from '../store/theme'
import { usePrivacyStore } from '../store/privacy'
import { useLibraryStore } from '../store/library'
import { ElMessageBox, ElMessage } from 'element-plus'
import { Refresh, View } from '@element-plus/icons-vue'

const router = useRouter()
const themeStore = useThemeStore()
const privacyStore = usePrivacyStore()
const libraryStore = useLibraryStore()

// 当前激活的标签页
const activeTab = ref('general')

// 常规设置
const theme = ref('system')
const startupAction = ref('home')
const autoCheckUpdates = ref(true)
const autoStart = ref(false)
const fileAssociations = ref(['cbz', 'cbr', 'cb7'])

// 阅读设置
const defaultReadingMode = ref('single')
const defaultReadingDirection = ref('ltr')
const defaultZoomLevel = ref('fit-page')
const defaultBackgroundColor = ref('white')
const preloadPages = ref(3)
const autoHideUI = ref(true)
const rememberPerComicSettings = ref(true)

// 库设置
const autoScanLibraries = ref(false)
const scanInterval = ref('daily')
const fetchMetadata = ref(true)
const metadataSource = ref('auto')
const thumbnailQuality = ref('medium')
const libraries = ref([])

// 隐私设置
const privacyPassword = ref('')
const autoLockPrivacyMode = ref(true)
const privacyLockTimeout = ref(5)
const showPrivacyIcon = ref(true)

// 高级设置
const cacheSize = ref(512)
const parallelLoading = ref(3)
const logLevel = ref('info')

// 关于
const appVersion = ref('1.0.0')
const checkingUpdates = ref(false)
const systemInfo = ref({
  os: '',
  electron: '',
  chrome: '',
  node: ''
})

// 加载设置
async function loadSettings() {
  try {
    // 加载主题设置
    theme.value = themeStore.isDarkMode ? 'dark' : 'light'
    
    // 加载常规设置
    const generalSettings = JSON.parse(localStorage.getItem('general_settings') || '{}')
    startupAction.value = generalSettings.startupAction || 'home'
    autoCheckUpdates.value = generalSettings.autoCheckUpdates !== undefined ? generalSettings.autoCheckUpdates : true
    autoStart.value = await window.electronAPI.isAutoStartEnabled()
    fileAssociations.value = generalSettings.fileAssociations || ['cbz', 'cbr', 'cb7']
    
    // 加载阅读设置
    const readerSettings = JSON.parse(localStorage.getItem('reader_settings_global') || '{}')
    defaultReadingMode.value = readerSettings.readingMode || 'single'
    defaultReadingDirection.value = readerSettings.readingDirection || 'ltr'
    defaultZoomLevel.value = readerSettings.zoomLevel || 'fit-page'
    defaultBackgroundColor.value = readerSettings.backgroundColor || 'white'
    preloadPages.value = readerSettings.preloadPages !== undefined ? readerSettings.preloadPages : 3
    autoHideUI.value = readerSettings.autoHideUI !== undefined ? readerSettings.autoHideUI : true
    rememberPerComicSettings.value = readerSettings.rememberPerComicSettings !== undefined ? readerSettings.rememberPerComicSettings : true
    
    // 加载库设置
    const librarySettings = JSON.parse(localStorage.getItem('library_settings') || '{}')
    autoScanLibraries.value = librarySettings.autoScanLibraries || false
    scanInterval.value = librarySettings.scanInterval || 'daily'
    fetchMetadata.value = librarySettings.fetchMetadata !== undefined ? librarySettings.fetchMetadata : true
    metadataSource.value = librarySettings.metadataSource || 'auto'
    thumbnailQuality.value = librarySettings.thumbnailQuality || 'medium'
    
    // 加载隐私设置
    const privacySettings = JSON.parse(localStorage.getItem('privacy_settings') || '{}')
    autoLockPrivacyMode.value = privacySettings.autoLockPrivacyMode !== undefined ? privacySettings.autoLockPrivacyMode : true
    privacyLockTimeout.value = privacySettings.privacyLockTimeout || 5
    showPrivacyIcon.value = privacySettings.showPrivacyIcon !== undefined ? privacySettings.showPrivacyIcon : true
    
    // 加载高级设置
    const advancedSettings = JSON.parse(localStorage.getItem('advanced_settings') || '{}')
    cacheSize.value = advancedSettings.cacheSize || 512
    parallelLoading.value = advancedSettings.parallelLoading || 3
    logLevel.value = advancedSettings.logLevel || 'info'
    
    // 加载系统信息
    systemInfo.value = await window.electronAPI.getSystemInfo()
    appVersion.value = systemInfo.value.appVersion || '1.0.0'
    
    // 加载库列表
    await loadLibraries()
  } catch (error) {
    console.error('加载设置失败:', error)
    ElMessage.error('加载设置失败')
  }
}

// 加载库列表
async function loadLibraries() {
  try {
    await libraryStore.fetchLibraries()
    libraries.value = libraryStore.libraries
  } catch (error) {
    console.error('加载库列表失败:', error)
  }
}

// 保存常规设置
function saveSettings() {
  try {
    // 保存常规设置
    const generalSettings = {
      startupAction: startupAction.value,
      autoCheckUpdates: autoCheckUpdates.value,
      fileAssociations: fileAssociations.value
    }
    localStorage.setItem('general_settings', JSON.stringify(generalSettings))
    
    // 保存库设置
    const librarySettings = {
      autoScanLibraries: autoScanLibraries.value,
      scanInterval: scanInterval.value,
      fetchMetadata: fetchMetadata.value,
      metadataSource: metadataSource.value,
      thumbnailQuality: thumbnailQuality.value
    }
    localStorage.setItem('library_settings', JSON.stringify(librarySettings))
    
    // 保存高级设置
    const advancedSettings = {
      cacheSize: cacheSize.value,
      parallelLoading: parallelLoading.value,
      logLevel: logLevel.value
    }
    localStorage.setItem('advanced_settings', JSON.stringify(advancedSettings))
    
    ElMessage.success('设置已保存')
  } catch (error) {
    console.error('保存设置失败:', error)
    ElMessage.error('保存设置失败')
  }
}

// 保存阅读设置
function saveReaderSettings() {
  try {
    const readerSettings = {
      readingMode: defaultReadingMode.value,
      readingDirection: defaultReadingDirection.value,
      zoomLevel: defaultZoomLevel.value,
      backgroundColor: defaultBackgroundColor.value,
      preloadPages: preloadPages.value,
      autoHideUI: autoHideUI.value,
      rememberPerComicSettings: rememberPerComicSettings.value
    }
    
    localStorage.setItem('reader_settings_global', JSON.stringify(readerSettings))
    ElMessage.success('阅读设置已保存')
  } catch (error) {
    console.error('保存阅读设置失败:', error)
    ElMessage.error('保存阅读设置失败')
  }
}

// 保存隐私设置
function savePrivacySettings() {
  try {
    const privacySettings = {
      autoLockPrivacyMode: autoLockPrivacyMode.value,
      privacyLockTimeout: privacyLockTimeout.value,
      showPrivacyIcon: showPrivacyIcon.value
    }
    
    localStorage.setItem('privacy_settings', JSON.stringify(privacySettings))
    ElMessage.success('隐私设置已保存')
  } catch (error) {
    console.error('保存隐私设置失败:', error)
    ElMessage.error('保存隐私设置失败')
  }
}

// 保存隐私密码
async function savePrivacyPassword() {
  if (!privacyPassword.value) {
    ElMessage.warning('请输入密码')
    return
  }
  
  try {
    await privacyStore.setPrivacyPassword(privacyPassword.value)
    ElMessage.success('隐私密码已设置')
    privacyPassword.value = '' // 清空输入框
  } catch (error) {
    console.error('设置隐私密码失败:', error)
    ElMessage.error('设置隐私密码失败')
  }
}

// 处理主题变更
function handleThemeChange() {
  if (theme.value === 'dark') {
    themeStore.setDarkMode()
  } else if (theme.value === 'light') {
    themeStore.setLightMode()
  } else {
    // 跟随系统
    themeStore.initTheme()
  }
}

// 处理自启动变更
async function handleAutoStartChange() {
  try {
    await window.electronAPI.setAutoStart(autoStart.value)
    ElMessage.success(`自启动已${autoStart.value ? '启用' : '禁用'}`)
  } catch (error) {
    console.error('设置自启动失败:', error)
    ElMessage.error('设置自启动失败')
    // 恢复原值
    autoStart.value = await window.electronAPI.isAutoStartEnabled()
  }
}

// 处理文件关联变更
async function handleFileAssociationsChange() {
  try {
    await window.electronAPI.setFileAssociations(fileAssociations.value)
    saveSettings()
  } catch (error) {
    console.error('设置文件关联失败:', error)
    ElMessage.error('设置文件关联失败')
  }
}

// 设为默认应用
async function setAsDefaultApp() {
  try {
    await window.electronAPI.setAsDefaultApp()
    ElMessage.success('已设置为默认漫画阅读器')
  } catch (error) {
    console.error('设置默认应用失败:', error)
    ElMessage.error('设置默认应用失败')
  }
}

// 扫描库
async function scanLibrary(libraryId) {
  try {
    ElMessage.info('开始扫描库...')
    await libraryStore.scanLibrary(libraryId)
    ElMessage.success('库扫描完成')
  } catch (error) {
    console.error('扫描库失败:', error)
    ElMessage.error('扫描库失败')
  }
}

// 打开库
function openLibrary(libraryId) {
  router.push(`/library/${libraryId}`)
}

// 清除阅读历史
async function clearReadingHistory() {
  try {
    await ElMessageBox.confirm(
      '确定要清除所有阅读历史记录吗？这将重置所有漫画的阅读进度。',
      '确认清除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    // 执行清除操作
    await window.electronAPI.clearReadingHistory()
    ElMessage.success('阅读历史已清除')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清除阅读历史失败:', error)
      ElMessage.error('清除阅读历史失败')
    }
  }
}

// 清除搜索历史
async function clearSearchHistory() {
  try {
    await ElMessageBox.confirm(
      '确定要清除所有搜索历史记录吗？',
      '确认清除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    // 执行清除操作
    await window.electronAPI.clearSearchHistory()
    ElMessage.success('搜索历史已清除')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清除搜索历史失败:', error)
      ElMessage.error('清除搜索历史失败')
    }
  }
}

// 清除缓存
async function clearCache() {
  try {
    await ElMessageBox.confirm(
      '确定要清除所有缓存数据吗？这可能会导致应用暂时变慢。',
      '确认清除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    // 执行清除操作
    await window.electronAPI.clearCache()
    ElMessage.success('缓存已清除')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('清除缓存失败:', error)
      ElMessage.error('清除缓存失败')
    }
  }
}

// 确认重置应用
async function confirmResetApp() {
  try {
    await ElMessageBox.confirm(
      '确定要重置应用吗？这将删除所有设置、库和阅读记录，此操作无法撤销。',
      '确认重置',
      {
        confirmButtonText: '重置',
        cancelButtonText: '取消',
        type: 'danger'
      }
    )
    
    // 执行重置操作
    await window.electronAPI.resetApp()
    ElMessage.success('应用已重置，即将重启...')
    
    // 延迟重启应用
    setTimeout(() => {
      window.electronAPI.restartApp()
    }, 2000)
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重置应用失败:', error)
      ElMessage.error('重置应用失败')
    }
  }
}

// 切换开发者工具
async function toggleDevTools() {
  try {
    await window.electronAPI.toggleDevTools()
  } catch (error) {
    console.error('打开开发者工具失败:', error)
  }
}

// 导出设置
async function exportSettings() {
  try {
    const result = await window.electronAPI.saveFileDialog({
      title: '导出设置',
      defaultPath: 'comic-reader-settings.json',
      filters: [{ name: 'JSON文件', extensions: ['json'] }]
    })
    
    if (!result.canceled && result.filePath) {
      // 收集所有设置
      const allSettings = {
        general: JSON.parse(localStorage.getItem('general_settings') || '{}'),
        reader: JSON.parse(localStorage.getItem('reader_settings_global') || '{}'),
        library: JSON.parse(localStorage.getItem('library_settings') || '{}'),
        privacy: JSON.parse(localStorage.getItem('privacy_settings') || '{}'),
        advanced: JSON.parse(localStorage.getItem('advanced_settings') || '{}')
      }
      
      // 导出设置
      await window.electronAPI.writeFile(result.filePath, JSON.stringify(allSettings, null, 2))
      ElMessage.success('设置已导出')
    }
  } catch (error) {
    console.error('导出设置失败:', error)
    ElMessage.error('导出设置失败')
  }
}

// 导入设置
async function importSettings() {
  try {
    const result = await window.electronAPI.openFileDialog({
      title: '导入设置',
      filters: [{ name: 'JSON文件', extensions: ['json'] }]
    })
    
    if (!result.canceled && result.filePaths.length > 0) {
      // 读取设置文件
      const settingsJson = await window.electronAPI.readFile(result.filePaths[0])
      const importedSettings = JSON.parse(settingsJson)
      
      // 导入各类设置
      if (importedSettings.general) {
        localStorage.setItem('general_settings', JSON.stringify(importedSettings.general))
      }
      
      if (importedSettings.reader) {
        localStorage.setItem('reader_settings_global', JSON.stringify(importedSettings.reader))
      }
      
      if (importedSettings.library) {
        localStorage.setItem('library_settings', JSON.stringify(importedSettings.library))
      }
      
      if (importedSettings.privacy) {
        localStorage.setItem('privacy_settings', JSON.stringify(importedSettings.privacy))
      }
      
      if (importedSettings.advanced) {
        localStorage.setItem('advanced_settings', JSON.stringify(importedSettings.advanced))
      }
      
      ElMessage.success('设置已导入，即将重新加载...')
      
      // 重新加载设置
      setTimeout(() => {
        loadSettings()
      }, 1000)
    }
  } catch (error) {
    console.error('导入设置失败:', error)
    ElMessage.error('导入设置失败')
  }
}

// 导出库数据
async function exportLibraryData() {
  try {
    const result = await window.electronAPI.saveFileDialog({
      title: '导出库数据',
      defaultPath: 'comic-reader-library-backup.json',
      filters: [{ name: 'JSON文件', extensions: ['json'] }]
    })
    
    if (!result.canceled && result.filePath) {
      // 导出库数据
      await libraryStore.exportLibraryData(result.filePath)
      ElMessage.success('库数据已导出')
    }
  } catch (error) {
    console.error('导出库数据失败:', error)
    ElMessage.error('导出库数据失败')
  }
}

// 导入库数据
async function importLibraryData() {
  try {
    const result = await window.electronAPI.openFileDialog({
      title: '导入库数据',
      filters: [{ name: 'JSON文件', extensions: ['json'] }]
    })
    
    if (!result.canceled && result.filePaths.length > 0) {
      // 确认导入
      await ElMessageBox.confirm(
        '导入库数据将覆盖现有的库和漫画信息，确定要继续吗？',
        '确认导入',
        {
          confirmButtonText: '导入',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      
      // 导入库数据
      await libraryStore.importLibraryData(result.filePaths[0])
      ElMessage.success('库数据已导入')
      
      // 重新加载库列表
      await loadLibraries()
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('导入库数据失败:', error)
      ElMessage.error('导入库数据失败')
    }
  }
}

// 检查更新
async function checkForUpdates() {
  try {
    checkingUpdates.value = true
    const updateInfo = await window.electronAPI.checkForUpdates()
    
    if (updateInfo.hasUpdate) {
      // 有更新可用
      ElMessageBox.confirm(
        `发现新版本: ${updateInfo.version}\n\n${updateInfo.releaseNotes}\n\n是否现在更新？`,
        '更新可用',
        {
          confirmButtonText: '更新',
          cancelButtonText: '稍后',
          type: 'info'
        }
      ).then(() => {
        // 开始下载更新
        window.electronAPI.downloadUpdate()
      }).catch(() => {
        // 用户选择稍后更新
      })
    } else {
      // 没有更新
      ElMessage.info('当前已是最新版本')
    }
  } catch (error) {
    console.error('检查更新失败:', error)
    ElMessage.error('检查更新失败')
  } finally {
    checkingUpdates.value = false
  }
}

// 打开项目网站
function openProjectWebsite() {
  window.electronAPI.openExternalLink('https://github.com/your-username/comic-reader')
}

// 格式化库类型
function formatLibraryType(type) {
  const typeMap = {
    'local_folder': '本地文件夹',
    'archive': '压缩文件',
    'smb': '网络共享 (SMB)',
    'ftp': 'FTP/SFTP',
    'webdav': 'WebDAV',
    'nfs': 'NFS'
  }
  
  return typeMap[type] || type
}

// 组件挂载时加载设置
onMounted(async () => {
  await loadSettings()
})
</script>

<style scoped>
.settings-view {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.settings-view h1 {
  font-size: 24px;
  margin-bottom: 20px;
  color: var(--primary-color);
}

.settings-tabs {
  margin-top: 20px;
}

.settings-section {
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--border-color);
}

.settings-section:last-child {
  border-bottom: none;
}

.settings-section h2 {
  font-size: 18px;
  margin-bottom: 15px;
  color: var(--primary-color);
}

.setting-description {
  font-size: 12px;
  color: var(--text-color-secondary);
  margin-left: 10px;
}

.password-input {
  display: flex;
  gap: 10px;
}

.password-input .el-input {
  flex: 1;
}

.about-section {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.app-logo {
  margin-bottom: 20px;
}

.app-logo img {
  width: 100px;
  height: 100px;
}

.version {
  margin-top: 5px;
  color: var(--text-color-secondary);
}

.about-actions {
  margin: 20px 0;
  display: flex;
  gap: 10px;
}

.about-info {
  margin: 20px 0;
  max-width: 500px;
}

.system-info {
  margin-top: 30px;
  text-align: left;
  width: 100%;
  max-width: 500px;
}

.system-info h3 {
  font-size: 16px;
  margin-bottom: 10px;
}

.system-info ul {
  list-style: none;
  padding: 0;
}

.system-info li {
  margin-bottom: 5px;
}

@media (max-width: 768px) {
  .settings-view {
    padding: 10px;
  }
  
  .el-form-item {
    margin-bottom: 20px;
  }
}
</style>