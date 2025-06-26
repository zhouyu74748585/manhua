import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import './assets/main.css'

// 创建Vue应用实例
const app = createApp(App)

// 使用路由
app.use(router)

// 使用Pinia状态管理
app.use(createPinia())

// 使用Element Plus组件库
app.use(ElementPlus)

// 挂载应用
app.mount('#app')