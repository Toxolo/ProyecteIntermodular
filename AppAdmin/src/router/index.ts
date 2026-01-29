import { createRouter, createWebHistory } from 'vue-router'
import HomeScreen from '../screens/HomeScreen.vue'
import EditScreen from '../screens/EditScreen.vue'

const routes = [
  {
    path: '/',
    component: HomeScreen
  },
  {
    path: '/videos/edit/:id',
    component: EditScreen,
    props: true
  }
]

export default createRouter({
  history: createWebHistory(),
  routes
})
