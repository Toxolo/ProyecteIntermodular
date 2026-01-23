import { createApp } from "vue";
import App from "./App.vue";
import Toast from 'vue-toastification'
import "vue-toastification/dist/index.css"

const app = createApp(App)

app.use(Toast, {
  position: "top-right",              // ← string is official & recommended
  // position: POSITION.TOP_RIGHT,    // ← also works, but less common now
  timeout: 4000,
  closeOnClick: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: "button",
  icon: true,
  rtl: false,
  transition: "Vue-Toastification__bounce",   
  maxToasts: 20,                             
  newestOnTop: true
})

app.mount('#app')
