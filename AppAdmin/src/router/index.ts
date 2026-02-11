import { createRouter, createWebHistory } from 'vue-router'
import { setupRouteGuard } from './routeguard'
import HomeScreen from '../screens/HomeScreen.vue'
import EditScreen from '../screens/Videos/EditScreen.vue'
import LoginScreen from '../screens/LoginScreen.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/home', component: HomeScreen },
    { path: '/videos/edit/:id', component: EditScreen, props: true },
    { path: '/login', component: LoginScreen },
    { path: "/series/edit/:id", name: "EditSerie", component: () => import("../screens/Series/EditSeriesScreen.vue") },
    { path: "/estudis/edit/:id", name: "EditEstudi", component: () => import("../screens/Estudis/EditEstudisScreen.vue") },
    { path: "/categories/edit/:id", name: "EditCategoria", component: () => import("../screens/Categories/EditCategoriesScreen.vue") }

  ]
})

setupRouteGuard(router)

export default router
