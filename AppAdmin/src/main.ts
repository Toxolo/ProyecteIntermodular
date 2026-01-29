import { createApp } from "vue"
import App from "./App.vue"
import Toast from 'vue-toastification'
import "vue-toastification/dist/index.css"
import router from './router'   // 👈 AÑADIR ESTO

const app = createApp(App)

app.use(router)                // 👈 Y ESTO (ANTES del mount)
app.use(Toast, {
  position: "top-right",
  timeout: 4000,
  closeOnClick: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  hideProgressBar: false,
  newestOnTop: true
})

app.mount('#app')
