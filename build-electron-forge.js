const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

function buildElectron() {
  console.log('开始构建 Electron 应用...');
  
  try {
    // 1. 构建前端
    console.log('1. 构建前端应用...');
    execSync('npm run build', { stdio: 'inherit' });
    
    // 2. 构建后端
    console.log('2. 构建后端应用...');
    execSync('npm run build:backend', { stdio: 'inherit' });
    
    // 3. 编译 Electron TypeScript 文件
    console.log('3. 编译 Electron TypeScript 文件...');
    execSync('npx tsc -p tsconfig.electron.json', { stdio: 'inherit' });
    
    // 4. 检查后端 JAR 文件
    const backendTargetDir = path.join(__dirname, 'backend', 'target');
    if (fs.existsSync(backendTargetDir)) {
      const files = fs.readdirSync(backendTargetDir);
      const originalJar = files.find(file => file.endsWith('.jar.original'));
      const jarFile = files.find(file => file.endsWith('.jar') && !file.endsWith('.jar.original'));
      
      if (originalJar && !jarFile) {
        const originalPath = path.join(backendTargetDir, originalJar);
        const newPath = path.join(backendTargetDir, originalJar.replace('.jar.original', '.jar'));
        fs.copyFileSync(originalPath, newPath);
        console.log(`重命名 JAR 文件: ${originalJar} -> ${path.basename(newPath)}`);
      }
    }
    
    // 5. 使用 electron-forge 打包
    console.log('4. 使用 electron-forge 打包应用...');
    execSync('npx electron-forge make', { stdio: 'inherit' });
    
    console.log('✅ Electron 应用构建完成!');
    
  } catch (error) {
    console.error('❌ 构建失败:', error.message);
    process.exit(1);
  }
}

buildElectron();