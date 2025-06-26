import { defineStore } from 'pinia'
import { ElMessageBox } from 'element-plus'

// 隐私模式状态管理
export const usePrivacyStore = defineStore('privacy', {
  // 状态
  state: () => ({
    isPrivacyMode: false, // 是否处于隐私模式
    isPrivacyModeAuthorized: false, // 是否已授权访问隐私内容
    privacyLibraries: [], // 隐私库ID列表
    privacyBooks: [], // 隐私书ID列表
  }),
  
  // 动作
  actions: {
    // 初始化隐私设置
    async initPrivacySettings() {
      try {
        // 从后端获取隐私设置
        const response = await fetch('/api/privacy/settings')
        const data = await response.json()
        
        this.privacyLibraries = data.privacyLibraries || []
        this.privacyBooks = data.privacyBooks || []
      } catch (error) {
        console.error('获取隐私设置失败:', error)
      }
    },
    
    // 请求进入隐私模式
    async requestPrivacyModeAccess() {
      // 显示密码输入对话框
      try {
        const { value: password } = await ElMessageBox.prompt(
          '请输入隐私模式密码',
          '隐私验证',
          {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            inputType: 'password',
            inputValidator: (value) => {
              if (!value) {
                return '密码不能为空'
              }
              return true
            },
          }
        )
        
        // 验证密码
        await this.verifyPrivacyPassword(password)
      } catch (error) {
        // 用户取消或验证失败
        console.log('隐私模式访问取消或失败')
      }
    },
    
    // 验证隐私模式密码
    async verifyPrivacyPassword(password) {
      try {
        // 调用后端API验证密码
        const response = await fetch('/api/privacy/verify', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ password }),
        })
        
        const data = await response.json()
        
        if (data.success) {
          // 验证成功，进入隐私模式
          this.enterPrivacyMode()
          return true
        } else {
          // 验证失败
          ElMessageBox.alert('密码错误，请重试', '验证失败', {
            confirmButtonText: '确定',
            type: 'error',
          })
          return false
        }
      } catch (error) {
        console.error('验证密码失败:', error)
        ElMessageBox.alert('验证过程中发生错误', '验证失败', {
          confirmButtonText: '确定',
          type: 'error',
        })
        return false
      }
    },
    
    // 进入隐私模式
    enterPrivacyMode() {
      this.isPrivacyMode = true
      this.isPrivacyModeAuthorized = true
    },
    
    // 退出隐私模式
    exitPrivacyMode() {
      this.isPrivacyMode = false
      this.isPrivacyModeAuthorized = false
    },
    
    // 检查是否是隐私库
    isPrivacyLibrary(libraryId) {
      return this.privacyLibraries.includes(libraryId)
    },
    
    // 检查是否是隐私书
    isPrivacyBook(bookId) {
      return this.privacyBooks.includes(bookId)
    },
    
    // 设置库为隐私库
    async setLibraryPrivacy(libraryId, isPrivate) {
      try {
        // 调用后端API设置库隐私状态
        const response = await fetch(`/api/privacy/library/${libraryId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ isPrivate }),
        })
        
        const data = await response.json()
        
        if (data.success) {
          // 更新本地状态
          if (isPrivate && !this.privacyLibraries.includes(libraryId)) {
            this.privacyLibraries.push(libraryId)
          } else if (!isPrivate) {
            this.privacyLibraries = this.privacyLibraries.filter(id => id !== libraryId)
          }
          return true
        }
        return false
      } catch (error) {
        console.error('设置库隐私状态失败:', error)
        return false
      }
    },
    
    // 设置书为隐私书
    async setBookPrivacy(bookId, isPrivate) {
      try {
        // 调用后端API设置书隐私状态
        const response = await fetch(`/api/privacy/book/${bookId}`, {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ isPrivate }),
        })
        
        const data = await response.json()
        
        if (data.success) {
          // 更新本地状态
          if (isPrivate && !this.privacyBooks.includes(bookId)) {
            this.privacyBooks.push(bookId)
          } else if (!isPrivate) {
            this.privacyBooks = this.privacyBooks.filter(id => id !== bookId)
          }
          return true
        }
        return false
      } catch (error) {
        console.error('设置书隐私状态失败:', error)
        return false
      }
    },
  }
})