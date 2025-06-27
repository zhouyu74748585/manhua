const { build } = require('esbuild')
const { join } = require('path')

const isDev = process.env.NODE_ENV === 'development'

async function buildElectron() {
  try {
    // 构建主进程
    await build({
      entryPoints: [join(__dirname, 'main.ts')],
      bundle: true,
      platform: 'node',
      target: 'node16',
      external: ['electron'],
      outfile: join(__dirname, '../dist-electron/main.js'),
      sourcemap: isDev,
      minify: !isDev
    })

    // 构建预加载脚本
    await build({
      entryPoints: [join(__dirname, 'preload.ts')],
      bundle: true,
      platform: 'node',
      target: 'node16',
      external: ['electron'],
      outfile: join(__dirname, '../dist-electron/preload.js'),
      sourcemap: isDev,
      minify: !isDev
    })

    console.log('Electron build completed successfully')
  } catch (error) {
    console.error('Electron build failed:', error)
    process.exit(1)
  }
}

buildElectron()