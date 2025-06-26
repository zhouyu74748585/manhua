import { createRouter, createWebHashHistory } from 'vue-router'
import { usePrivacyStore } from '../store/privacy'

// 路由配置
const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/HomeView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/library/:id',
    name: 'Library',
    component: () => import('../views/LibraryView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/reader/:id',
    name: 'Reader',
    component: () => import('../views/ReaderView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/SettingsView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/privacy',
    name: 'Privacy',
    component: () => import('../views/PrivacyView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('../views/NotFoundView.vue'),
    meta: { requiresAuth: false }
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// 路由守卫，处理隐私模式的访问控制
router.beforeEach((to, from, next) => {
  const privacyStore = usePrivacyStore()
  
  // 检查路由是否需要隐私模式授权
  if (to.meta.requiresAuth && !privacyStore.isPrivacyModeAuthorized) {
    // 如果需要授权但未授权，重定向到验证页面
    next({ name: 'PrivacyAuth', query: { redirect: to.fullPath } })
  } else {
    // 检查是否访问的是隐私库内容
    if (to.params.id && privacyStore.isPrivacyLibrary(to.params.id) && !privacyStore.isPrivacyModeAuthorized) {
      // 如果访问的是隐私库但未授权，重定向到验证页面
      next({ name: 'PrivacyAuth', query: { redirect: to.fullPath } })
    } else {
      // 其他情况正常放行
      next()
    }
  }
})

export default router