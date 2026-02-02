<script setup lang="ts">
import { ref } from 'vue'
import VideoList from '../components/VideoList.vue'
import UploadScreen from '../screens/UploadScreen.vue'
import EditScreen from './screens/EditScreen.vue'

// Search filter options
const tipoBuscador = [
  { id: 1, name: 'ID' },
  { id: 2, name: 'Titol' }  
]

// State variables
const searchQuery = ref('')
const selected = ref('')
const showUploadScreen = ref(false)

// Refresh interval in milliseconds (30 seconds by default)
const refreshInterval = 30000

// Handle edit video event
function handleEditVideo(videoId: number) {
  console.log('Edit video with ID:', videoId)
  // TODO: Open edit modal or navigate to edit page
  // For now, you can show the upload screen with the video data
  // or create a separate EditScreen component
  alert(`Editing video ID: ${videoId}`)
}
</script>

<template>
  <!-- Upload Screen Modal -->
  <UploadScreen v-if="showUploadScreen" @close="showUploadScreen = false" />

  <!-- Main Content -->
  <div v-else class="container">
    <h1>Padalustro</h1>
    
    <!-- Search and filters section -->
    <div class="filters-wrapper">
      <!-- Dropdown to select search type -->
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

      <!-- Search input -->
      <div class="search-container">
        <input
          v-model="searchQuery"
          type="text"
          :placeholder="`Buscar per ${selected ? tipoBuscador.find(t => t.id === Number(selected))?.name : 'titol'}...`"
          class="search-input"
        />
        <!-- Clear search button -->
        <span v-if="searchQuery" class="clear-btn" @click="searchQuery = ''">
          ×
        </span>
      </div>

      <!-- Upload button -->
      <button class="upload-btn" @click="showUploadScreen = true">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
          <polyline points="17 8 12 3 7 8"></polyline>
          <line x1="12" y1="3" x2="12" y2="15"></line>
        </svg>
        Pujar
      </button>
    </div>

    <!-- Video List Component with auto-refresh -->
    <VideoList 
      :search-query="searchQuery" 
      :search-type="Number(selected) || 2"
      :refresh-interval="refreshInterval"
      @edit-video="handleEditVideo"
    />
  </div>
</template>

<style src="../assets/css/home.css">

</style>