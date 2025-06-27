import { createRouter, createWebHashHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'Layout',
    component: () => import('../views/Layout.vue'),
    redirect: '/library',
    children: [
      {
        path: '/library',
        name: 'Library',
        component: () => import('../views/Library.vue'),
        meta: { title: '漫画库' }
      },
      {
        path: '/bookshelf',
        name: 'Bookshelf',
        component: () => import('../views/Bookshelf.vue'),
        meta: { title: '书架' }
      },
      {
        path: '/settings',
        name: 'Settings',
        component: () => import('../views/Settings.vue'),
        meta: { title: '设置' }
      }
    ]
  },
  {
    path: '/reader/:id',
    name: 'Reader',
    component: () => import('../views/Reader.vue'),
    meta: { title: '阅读器' }
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('../views/NotFound.vue')
  }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // 设置页面标题
  if (to.meta?.title) {
    document.title = `${to.meta.title} - 漫画阅读器`
  } else {
    document.title = '漫画阅读器'
  }
  next()
})

export default router