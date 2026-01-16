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
 
  if (selected.value === '1'){
    return videos.value.filter(video =>
      video.id.toString().includes(query)
    )
  }
  if (selected.value === '2'){
    return videos.value.filter(video =>
      video.titol.toLowerCase().includes(query)
    )
  } 

})
</script>

<template>
  <div class="container">
    <h1>Padalustro</h1>
    
    <select id="dropdown" v-model="selected">
      <option value="" disabled>Tipo</option>
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
        placeholder="Buscar..."
        class="search-input"
      />
      <span v-if="searchQuery" class="clear-btn" @click="searchQuery = ''">
        ×
      </span>
    </div>

    <div v-if="loading" class="status">Carregant...</div>
    <div v-else-if="error" class="status error">{{ error }}</div>
    <div v-else-if="filteredVideos.length === 0" class="status">
      <span v-if="searchQuery">No s'ha trobat cap vídeo amb "{{ searchQuery }}"</span>
      <span v-else>No hi ha vídeos</span>
    </div>

    <div v-else class="video-grid">
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
  margin-bottom: 1.5rem;
}

.search-container {
  position: relative;
  max-width: 500px;
  margin: 0 auto 2rem;
}

.search-input {
  width: 100%;
  padding: 12px 16px;
  padding-right: 40px;           
  border: 1px solid #ccc;
  border-radius: 8px;
  font-size: 1rem;
  box-sizing: border-box;
}

.search-input:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 3px rgba(0,123,255,0.15);
}

.clear-btn {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 1.4rem;
  color: #999;
  cursor: pointer;
  user-select: none;
}

.clear-btn:hover {
  color: #333;
}

.video-grid {
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

.status {
  text-align: center;
  padding: 80px 20px;
  font-size: 1.2rem;
  color: #444;
}

.error {
  color: #c62828;
}
</style>