<!-- App.vue o el componente donde muestras la lista de vídeos -->
<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import axios from 'axios'
import VideoCard from './components/VideoCard.vue'

// interface per als videos obtinguts
interface Video {
  id: number
  titol: string
  duracio: number
  codec: string
  resolucio: string
  pes: number
}

const tipoBuscador =[
  { id:1, name:'ID'},
  { id:2, name:'Titol'}  
]

// definicio de constants
const videos = ref<Video[]>([])
const searchQuery = ref('')           
const loading = ref(true)
const error = ref<string | null>(null)
const selected = ref('')

async function fetchVideos() {
  try {
    const response = await axios.get('http://localhost:3000')
    videos.value = response.data
  } catch (err) {
    console.error('Error al cargar vídeos:', err)
    error.value = "No s'han pogut carregar els vídeos"
  } finally {
    loading.value = false
  }
}

// executa la funcio fetchVideos al iniciar
onMounted(fetchVideos)

// Llista de videos filtrats amb el buscador
const filteredVideos = computed(() => {
  if (!searchQuery.value.trim()) {
    return videos.value
  }

  const query = searchQuery.value.toLowerCase().trim()
 
  if (Number(selected.value) === 1){
    return videos.value.filter(video =>
      video.id.toString().includes(query)
    )
  } else {
    return videos.value.filter(video =>
      video.titol.toLowerCase().includes(query)
    )
  }
})
</script>

<template>
  <div class="container">
    <h1>Padalustro</h1>
    
    <div class="filters-wrapper">
      <select id="dropdown" v-model="selected">
        <option value="" disabled>Selecciona tipus de cerca</option>
        <option
          v-for="type in tipoBuscador"
          :key="type.id"
          :value="type.id"
        >
          {{ type.name }}
        </option>
      </select>

      <!-- Buscador -->
      <div class="search-container">
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="`Buscar per ${selected ? tipoBuscador.find(t => t.id === Number(selected))?.name : 'titol'}...`"
          class="search-input"
        />
        <span v-if="searchQuery" class="clear-btn" @click="searchQuery = ''">
          ×
        </span>
      </div>
    </div>

    <div v-if="loading" class="status">Carregant...</div>
    <div v-else-if="error" class="status error">{{ error }}</div>
    <div v-else-if="filteredVideos.length === 0" class="status">
      <span v-if="searchQuery">No s'ha trobat cap vídeo amb "{{ searchQuery }}"</span>
      <span v-else>No hi ha vídeos</span>
    </div>

    <div v-else class="video-list">
      <VideoCard
        v-for="video in filteredVideos" 
        :key="video.id"
        :video="video"
      />
    </div>
  </div>
</template>

<style scoped>
.container {
  max-width: 1240px;
  margin: 0 auto;
  padding: 20px 16px;
}

h1 {
  text-align: center;
  margin-bottom: 2rem;
  font-size: 2.5rem;
  color: #1a1a1a;
}

/* Filters Wrapper - Side by Side */
.filters-wrapper {
  display: flex;
  gap: 16px;
  max-width: 900px;
  margin: 0 auto 3rem;
  align-items: center;
}

/* Dropdown Styles */
#dropdown {
  flex: 0 0 220px;
  padding: 14px 18px;
  padding-right: 45px;
  font-size: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  color: #1a1a1a;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23555' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 18px center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

#dropdown:hover {
  background: white;
  border-color: #3498db;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

#dropdown:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 4px rgba(52, 152, 219, 0.15);
}

#dropdown option:disabled {
  color: #999;
}

/* Search Container */
.search-container {
  position: relative;
  flex: 1;
}

/* Search Input */
.search-input {
  width: 100%;
  padding: 14px 18px;
  padding-right: 45px;
  font-size: 16px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  color: #1a1a1a;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  transition: all 0.3s ease;
  box-sizing: border-box;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
}

.search-input::placeholder {
  color: #999;
}

.search-input:hover {
  background: white;
  border-color: #3498db;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.search-input:focus {
  outline: none;
  background: white;
  border-color: #3498db;
  box-shadow: 0 0 0 4px rgba(52, 152, 219, 0.15);
}

/* Clear Button */
.clear-btn {
  position: absolute;
  right: 16px;
  top: 50%;
  transform: translateY(-50%);
  width: 26px;
  height: 26px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  font-weight: 300;
  color: #999;
  cursor: pointer;
  background-color: #f5f5f5;
  border-radius: 50%;
  transition: all 0.2s ease;
  line-height: 1;
  user-select: none;
}

.clear-btn:hover {
  background-color: #e0e0e0;
  color: #666;
  transform: translateY(-50%) scale(1.1);
}

.clear-btn:active {
  transform: translateY(-50%) scale(0.95);
}

/* Video List - Full Width Cards */
.video-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  max-width: 1200px;
  margin: 0 auto;
}

/* Status Messages */
.status {
  text-align: center;
  padding: 80px 20px;
  font-size: 1.1rem;
  color: #666;
}

.error {
  color: #e74c3c;
  font-weight: 500;
}

/* Responsive */
@media (max-width: 768px) {
  .filters-wrapper {
    flex-direction: column;
    max-width: 100%;
  }
  
  #dropdown {
    flex: 1;
    width: 100%;
  }
  
  h1 {
    font-size: 2rem;
  }
  
  .video-list {
    gap: 12px;
  }
}
</style>