const { execSync } = require('child_process')
const fs = require('fs')
const path = require('path')

console.log('🚀 开始构建 Electron 应用...')

// 1. 构建前端
console.log('📦 构建前端应用...')
try {
  execSync('npm run build', { stdio: 'inherit' })
  console.log('✅ 前端构建完成')
} catch (error) {
  console.error('❌ 前端构建失败:', error.message)
  process.exit(1)
}

// 2. 构建后端
console.log('📦 构建后端应用...')
try {
  execSync('npm run build:backend', { stdio: 'inherit' })
  console.log('✅ 后端构建完成')
} catch (error) {
  console.error('❌ 后端构建失败:', error.message)
  process.exit(1)
}

// 3. 检查后端 JAR 文件是否存在
const backendTargetDir = path.join(__dirname, 'backend', 'target')
if (!fs.existsSync(backendTargetDir)) {
  console.error('❌ 后端目标目录不存在')
  process.exit(1)
}

const jarFiles = fs.readdirSync(backendTargetDir)
  .filter(file => file.endsWith('.jar') && !file.includes('sources') && !file.includes('original'))

if (jarFiles.length === 0) {
  // 检查是否有 .original 文件，如果有则重命名
  const originalFiles = fs.readdirSync(backendTargetDir)
    .filter(file => file.endsWith('.jar.original'))
  
  if (originalFiles.length > 0) {
    const originalFile = originalFiles[0]
    const newFileName = originalFile.replace('.jar.original', '.jar')
    const originalPath = path.join(backendTargetDir, originalFile)
    const newPath = path.join(backendTargetDir, newFileName)
    
    console.log(`🔄 重命名 ${originalFile} 为 ${newFileName}`)
    fs.renameSync(originalPath, newPath)
    console.log(`✅ 找到后端 JAR 文件: ${newFileName}`)
  } else {
    console.error('❌ 未找到后端 JAR 文件')
    process.exit(1)
  }
} else {
  console.log(`✅ 找到后端 JAR 文件: ${jarFiles[0]}`)
}

// 4. 构建 Electron 应用
console.log('📦 构建 Electron 应用...')
try {
  execSync('npx electron-builder', { stdio: 'inherit' })
  console.log('✅ Electron 应用构建完成')
} catch (error) {
  console.error('❌ Electron 应用构建失败:', error.message)
  process.exit(1)
}

console.log('🎉 构建完成！应用程序已打包到 dist-app 目录')