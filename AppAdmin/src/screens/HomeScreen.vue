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
  max-width: 1100px;
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

/* Upload Button */
.upload-btn {
  flex: 0 0 auto;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 24px;
  font-size: 16px;
  font-weight: 600;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.upload-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.upload-btn:active {
  transform: translateY(0);
}

/* Responsive */
@media (max-width: 768px) {
  .filters-wrapper {
    flex-direction: column;
    max-width: 100%;
  }
  
  #dropdown,
  .upload-btn {
    width: 100%;
  }
  
  h1 {
    font-size: 2rem;
  }
}
</style>