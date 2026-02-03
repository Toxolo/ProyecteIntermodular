<!-- src/screens/HomeScreen.vue -->
<script setup lang="ts">
import { ref } from 'vue'
import VideoList from '../components/VideoList.vue'
import CategoriesList from '../components/Categories/CategoriesList.vue'
import UploadScreen from '../screens/UploadScreen.vue'
import TopBar from '../components/TopBar.vue'

const activeSection = ref<'videos' | 'series' | 'categories' | 'studios'>('videos')

const showUploadScreen = ref(false)

const tipoBuscador = [
  { id: 1, name: 'ID' },
  { id: 2, name: 'Nom' }
]

const searchQuery = ref('')
const selected = ref(2)
const refreshInterval = 30000

function handleEditVideo(videoId: number) {
  alert(`Editing video ID: ${videoId}`)
}
</script>

<template>
  <!-- Upload -->
  <UploadScreen
    v-if="showUploadScreen"
    @close="showUploadScreen = false"
  />

  <div v-else class="container">
    <TopBar v-model:activeSection="activeSection" />

    <!-- ================= VIDEOS ================= -->
    <div v-if="activeSection === 'videos'">
      <div class="filters-wrapper">
        <select v-model="selected">
          <option
            v-for="type in tipoBuscador"
            :key="type.id"
            :value="type.id"
          >
            {{ type.name }}
          </option>
        </select>

        <div class="search-container">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar vídeo..."
            class="search-input"
          />
          <span
            v-if="searchQuery"
            class="clear-btn"
            @click="searchQuery = ''"
          >
            ×
          </span>
        </div>

        <button class="upload-btn" @click="showUploadScreen = true">
          Pujar
        </button>
      </div>

      <VideoList
        :search-query="searchQuery"
        :search-type="selected"
        :refresh-interval="refreshInterval"
        @edit-video="handleEditVideo"
      />
    </div>

    <!-- ================= CATEGORIES ================= -->
    <div v-else-if="activeSection === 'categories'">
      <div class="filters-wrapper">
        <select v-model="selected">
          <option
            v-for="type in tipoBuscador"
            :key="type.id"
            :value="type.id"
          >
            {{ type.name }}
          </option>
        </select>

        <div class="search-container">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Buscar categoria..."
            class="search-input"
          />
          <span
            v-if="searchQuery"
            class="clear-btn"
            @click="searchQuery = ''"
          >
            ×
          </span>
        </div>
      </div>

      <CategoriesList
        :search-query="searchQuery"
        :search-type="selected"
        :refresh-interval="refreshInterval"
      />
    </div>

    <!-- ================= SERIES ================= -->
    <div v-else-if="activeSection === 'series'">
      <p>Gestió de sèries (per crear després)</p>
    </div>

    <!-- ================= STUDIOS ================= -->
    <div v-else-if="activeSection === 'studios'">
      <p>Gestió d’estudis (per crear després)</p>
    </div>
  </div>
</template>

<style src="../assets/css/home.css"></style>
