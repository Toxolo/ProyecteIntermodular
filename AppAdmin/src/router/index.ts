import { createRouter, createWebHistory } from 'vue-router'
import { setupRouteGuard } from './routeguard'
import HomeScreen from '../screens/HomeScreen.vue'
import EditScreen from '../screens/EditScreen.vue'
import LoginScreen from '../screens/LoginScreen.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/home', component: HomeScreen },
    { path: '/videos/edit/:id', component: EditScreen, props: true },
    { path: '/login', component: LoginScreen },
  ]
})

setupRouteGuard(router)

export default router
