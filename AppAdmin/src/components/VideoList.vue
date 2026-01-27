<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'
import axios from 'axios'
import VideoCard from './VideoCard.vue'

// Interface for video data structure
interface Video {
  id: number
  titol: string
  duracio: number
  codec: string
  resolucio: string
  pes: number
}

// Props from parent component
const props = defineProps<{
  searchQuery: string
  searchType: number
  refreshInterval?: number // Optional refresh interval in milliseconds (default: 30000ms = 30s)
}>()

// State variables
const videos = ref<Video[]>([])
const loading = ref(true)
const error = ref<string | null>(null)
const lastRefreshTime = ref<Date | null>(null)
let refreshTimer: ReturnType<typeof setInterval> | null = null

// Fetch videos from backend
async function fetchVideos() {
  try {
    error.value = null
    const response = await axios.get('http://localhost:3000')
    videos.value = response.data
    lastRefreshTime.value = new Date()
  } catch (err) {
    console.error('Error al cargar vídeos:', err)
    error.value = "No s'han pogut carregar els vídeos"
  } finally {
    loading.value = false
  }
}

// Setup auto-refresh with interval
function setupAutoRefresh() {
  const interval = props.refreshInterval || 30000 // Default 30 seconds
  
  refreshTimer = setInterval(() => {
    console.log('Auto-refreshing video list...')
    fetchVideos()
  }, interval)
}

// Computed property: filter videos based on search query
const filteredVideos = computed(() => {
  if (!props.searchQuery.trim()) {
    return videos.value
  }

  const query = props.searchQuery.toLowerCase().trim()
 
  // Filter by ID
  if (props.searchType === 1) {
    return videos.value.filter(video =>
      video.id.toString().includes(query)
    )
  } else {
    // Filter by title
    return videos.value.filter(video =>
      video.titol.toLowerCase().includes(query)
    )
  }
})

// Format last refresh time for display
const formattedRefreshTime = computed(() => {
  if (!lastRefreshTime.value) return ''
  
  const now = new Date()
  const diff = Math.floor((now.getTime() - lastRefreshTime.value.getTime()) / 1000)
  
  if (diff < 60) return `hace ${diff}s`
  if (diff < 3600) return `hace ${Math.floor(diff / 60)}m`
  return lastRefreshTime.value.toLocaleTimeString()
})

// Initialize on mount
onMounted(() => {
  fetchVideos()
  setupAutoRefresh()
})

// Cleanup on unmount
onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})

// Expose refresh function to parent if needed
defineExpose({
  fetchVideos
})
</script>

<template>
  <div class="video-list-container">
    <!-- Refresh indicator -->
    <div v-if="lastRefreshTime" class="refresh-indicator">
      <span class="refresh-dot"></span>
      Última actualización: {{ formattedRefreshTime }}
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="status">
      <div class="spinner"></div>
      <p>Carregant...</p>
    </div>
    
    <!-- Error state -->
    <div v-else-if="error" class="status error">{{ error }}</div>
    
    <!-- Empty state -->
    <div v-else-if="filteredVideos.length === 0" class="status">
      <span v-if="searchQuery">No s'ha trobat cap vídeo amb "{{ searchQuery }}"</span>
      <span v-else>No hi ha vídeos</span>
    </div>

    <!-- Video list -->
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
.video-list-container {
  max-width: 1200px;
  margin: 0 auto;
}

/* Refresh indicator */
.refresh-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: #666;
  margin-bottom: 16px;
  padding: 8px 12px;
  background: #f8f9fa;
  border-radius: 8px;
  width: fit-content;
}

.refresh-dot {
  width: 8px;
  height: 8px;
  background: #27ae60;
  border-radius: 50%;
  animation: pulse 2s ease-in-out infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.5;
    transform: scale(0.8);
  }
}

/* Video List */
.video-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Status Messages */
.status {
  text-align: center;
  padding: 80px 20px;
  font-size: 1.1rem;
  color: #666;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.error {
  color: #e74c3c;
  font-weight: 500;
}

/* Loading Spinner */
.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Responsive */
@media (max-width: 768px) {
  .video-list {
    gap: 12px;
  }
  
  .refresh-indicator {
    font-size: 0.8rem;
  }
}
</style>