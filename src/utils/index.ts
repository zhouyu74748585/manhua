/**
 * 格式化文件大小
 * @param bytes 字节数
 * @returns 格式化后的文件大小字符串
 */
export function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 B'
  
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB', 'TB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

/**
 * 格式化日期
 * @param date 日期对象或时间戳
 * @param format 格式字符串，默认为 'YYYY-MM-DD HH:mm:ss'
 * @returns 格式化后的日期字符串
 */
export function formatDate(date: Date | number | string, format = 'YYYY-MM-DD HH:mm:ss'): string {
  const d = new Date(date)
  
  if (isNaN(d.getTime())) {
    return '无效日期'
  }
  
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  const hours = String(d.getHours()).padStart(2, '0')
  const minutes = String(d.getMinutes()).padStart(2, '0')
  const seconds = String(d.getSeconds()).padStart(2, '0')
  
  return format
    .replace('YYYY', String(year))
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hours)
    .replace('mm', minutes)
    .replace('ss', seconds)
}

/**
 * 获取相对时间描述
 * @param date 日期对象或时间戳
 * @returns 相对时间描述
 */
export function getRelativeTime(date: Date | number | string): string {
  const now = new Date()
  const target = new Date(date)
  
  if (isNaN(target.getTime())) {
    return '未知时间'
  }
  
  const diff = now.getTime() - target.getTime()
  const seconds = Math.floor(diff / 1000)
  const minutes = Math.floor(seconds / 60)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)
  const months = Math.floor(days / 30)
  const years = Math.floor(days / 365)
  
  if (years > 0) {
    return `${years}年前`
  } else if (months > 0) {
    return `${months}个月前`
  } else if (days > 0) {
    return `${days}天前`
  } else if (hours > 0) {
    return `${hours}小时前`
  } else if (minutes > 0) {
    return `${minutes}分钟前`
  } else if (seconds > 30) {
    return `${seconds}秒前`
  } else {
    return '刚刚'
  }
}

/**
 * 防抖函数
 * @param func 要防抖的函数
 * @param wait 等待时间（毫秒）
 * @returns 防抖后的函数
 */
export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null
  
  return function (...args: Parameters<T>) {
    if (timeout) {
      clearTimeout(timeout)
    }
    
    timeout = setTimeout(() => {
      func.apply(this, args)
    }, wait)
  }
}

/**
 * 节流函数
 * @param func 要节流的函数
 * @param wait 等待时间（毫秒）
 * @returns 节流后的函数
 */
export function throttle<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let lastTime = 0
  
  return function (...args: Parameters<T>) {
    const now = Date.now()
    
    if (now - lastTime >= wait) {
      lastTime = now
      func.apply(this, args)
    }
  }
}

/**
 * 深拷贝对象
 * @param obj 要拷贝的对象
 * @returns 拷贝后的对象
 */
export function deepClone<T>(obj: T): T {
  if (obj === null || typeof obj !== 'object') {
    return obj
  }
  
  if (obj instanceof Date) {
    return new Date(obj.getTime()) as T
  }
  
  if (obj instanceof Array) {
    return obj.map(item => deepClone(item)) as T
  }
  
  if (typeof obj === 'object') {
    const cloned = {} as T
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        cloned[key] = deepClone(obj[key])
      }
    }
    return cloned
  }
  
  return obj
}

/**
 * 生成唯一ID
 * @param prefix 前缀
 * @returns 唯一ID字符串
 */
export function generateId(prefix = ''): string {
  const timestamp = Date.now().toString(36)
  const random = Math.random().toString(36).substr(2, 9)
  return prefix + timestamp + random
}

/**
 * 验证文件类型是否为图片
 * @param filename 文件名
 * @returns 是否为图片文件
 */
export function isImageFile(filename: string): boolean {
  const imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg']
  const ext = filename.toLowerCase().substring(filename.lastIndexOf('.'))
  return imageExtensions.includes(ext)
}

/**
 * 验证文件类型是否为压缩包
 * @param filename 文件名
 * @returns 是否为压缩包文件
 */
export function isArchiveFile(filename: string): boolean {
  const archiveExtensions = ['.zip', '.rar', '.7z', '.tar', '.gz', '.cbz', '.cbr']
  const ext = filename.toLowerCase().substring(filename.lastIndexOf('.'))
  return archiveExtensions.includes(ext)
}

/**
 * 获取文件扩展名
 * @param filename 文件名
 * @returns 文件扩展名（不包含点）
 */
export function getFileExtension(filename: string): string {
  const lastDotIndex = filename.lastIndexOf('.')
  if (lastDotIndex === -1) return ''
  return filename.substring(lastDotIndex + 1).toLowerCase()
}

/**
 * 获取文件名（不包含扩展名）
 * @param filename 完整文件名
 * @returns 不包含扩展名的文件名
 */
export function getFileNameWithoutExtension(filename: string): string {
  const lastDotIndex = filename.lastIndexOf('.')
  if (lastDotIndex === -1) return filename
  return filename.substring(0, lastDotIndex)
}

/**
 * 自然排序比较函数
 * @param a 字符串A
 * @param b 字符串B
 * @returns 比较结果
 */
export function naturalSort(a: string, b: string): number {
  const collator = new Intl.Collator(undefined, {
    numeric: true,
    sensitivity: 'base'
  })
  return collator.compare(a, b)
}

/**
 * 转义HTML字符
 * @param text 要转义的文本
 * @returns 转义后的文本
 */
export function escapeHtml(text: string): string {
  const div = document.createElement('div')
  div.textContent = text
  return div.innerHTML
}

/**
 * 截断文本
 * @param text 原始文本
 * @param maxLength 最大长度
 * @param suffix 后缀，默认为 '...'
 * @returns 截断后的文本
 */
export function truncateText(text: string, maxLength: number, suffix = '...'): string {
  if (text.length <= maxLength) {
    return text
  }
  return text.substring(0, maxLength - suffix.length) + suffix
}

/**
 * 检查是否为有效的URL
 * @param url URL字符串
 * @returns 是否为有效URL
 */
export function isValidUrl(url: string): boolean {
  try {
    new URL(url)
    return true
  } catch {
    return false
  }
}

/**
 * 检查是否为有效的IP地址
 * @param ip IP地址字符串
 * @returns 是否为有效IP地址
 */
export function isValidIp(ip: string): boolean {
  const ipv4Regex = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  const ipv6Regex = /^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$/
  return ipv4Regex.test(ip) || ipv6Regex.test(ip)
}

/**
 * 下载文件
 * @param url 文件URL
 * @param filename 文件名
 */
export function downloadFile(url: string, filename: string): void {
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

/**
 * 复制文本到剪贴板
 * @param text 要复制的文本
 * @returns Promise<boolean> 是否复制成功
 */
export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
      return true
    } else {
      // 降级方案
      const textArea = document.createElement('textarea')
      textArea.value = text
      textArea.style.position = 'fixed'
      textArea.style.left = '-999999px'
      textArea.style.top = '-999999px'
      document.body.appendChild(textArea)
      textArea.focus()
      textArea.select()
      const result = document.execCommand('copy')
      document.body.removeChild(textArea)
      return result
    }
  } catch {
    return false
  }
}

/**
 * 获取设备类型
 * @returns 设备类型
 */
export function getDeviceType(): 'mobile' | 'tablet' | 'desktop' {
  const userAgent = navigator.userAgent.toLowerCase()
  const isMobile = /android|webos|iphone|ipad|ipod|blackberry|iemobile|opera mini/i.test(userAgent)
  const isTablet = /ipad|android(?!.*mobile)/i.test(userAgent)
  
  if (isMobile && !isTablet) {
    return 'mobile'
  } else if (isTablet) {
    return 'tablet'
  } else {
    return 'desktop'
  }
}

/**
 * 获取操作系统类型
 * @returns 操作系统类型
 */
export function getOSType(): 'windows' | 'macos' | 'linux' | 'android' | 'ios' | 'unknown' {
  const userAgent = navigator.userAgent.toLowerCase()
  
  if (userAgent.includes('win')) {
    return 'windows'
  } else if (userAgent.includes('mac')) {
    return 'macos'
  } else if (userAgent.includes('linux')) {
    return 'linux'
  } else if (userAgent.includes('android')) {
    return 'android'
  } else if (userAgent.includes('iphone') || userAgent.includes('ipad')) {
    return 'ios'
  } else {
    return 'unknown'
  }
}

/**
 * 等待指定时间
 * @param ms 等待时间（毫秒）
 * @returns Promise
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms))
}

/**
 * 重试函数
 * @param fn 要重试的函数
 * @param maxRetries 最大重试次数
 * @param delay 重试间隔（毫秒）
 * @returns Promise
 */
export async function retry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delay = 1000
): Promise<T> {
  let lastError: Error
  
  for (let i = 0; i <= maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error
      if (i < maxRetries) {
        await sleep(delay)
      }
    }
  }
  
  throw lastError!
}

/**
 * 创建可取消的Promise
 * @param promise 原始Promise
 * @returns 包含cancel方法的Promise
 */
export function makeCancelable<T>(promise: Promise<T>) {
  let isCanceled = false
  
  const wrappedPromise = new Promise<T>((resolve, reject) => {
    promise
      .then(value => {
        if (!isCanceled) {
          resolve(value)
        }
      })
      .catch(error => {
        if (!isCanceled) {
          reject(error)
        }
      })
  })
  
  return {
    promise: wrappedPromise,
    cancel: () => {
      isCanceled = true
    }
  }
}

/**
 * 数组分块
 * @param array 原数组
 * @param size 块大小
 * @returns 分块后的数组
 */
export function chunk<T>(array: T[], size: number): T[][] {
  const chunks: T[][] = []
  for (let i = 0; i < array.length; i += size) {
    chunks.push(array.slice(i, i + size))
  }
  return chunks
}

/**
 * 数组去重
 * @param array 原数组
 * @param key 去重依据的键（可选）
 * @returns 去重后的数组
 */
export function unique<T>(array: T[], key?: keyof T): T[] {
  if (!key) {
    return [...new Set(array)]
  }
  
  const seen = new Set()
  return array.filter(item => {
    const value = item[key]
    if (seen.has(value)) {
      return false
    }
    seen.add(value)
    return true
  })
}