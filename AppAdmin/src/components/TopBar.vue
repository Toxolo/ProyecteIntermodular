<!-- src/components/TopBar.vue -->
<template>
  <nav class="top-bar">
    <!-- Esquerra -->
    <div class="left-buttons">
      <button 
        :class="{ active: active === 'videos' }" 
        @click="changeSection('videos')"
      >
        Videos
      </button>
      <button 
        :class="{ active: active === 'series' }" 
        @click="changeSection('series')"
      >
        Series
      </button>
    </div>

    <!-- Centre -->
    <div class="title">
      Padalustro
    </div>

    <!-- Dreta -->
    <div class="right-buttons">
      <button 
        :class="{ active: active === 'categories' }" 
        @click="changeSection('categories')"
      >
        Categorías
      </button>
      <button 
        :class="{ active: active === 'studios' }" 
        @click="changeSection('studios')"
      >
        Estudios
      </button>
    </div>
  </nav>
</template>

<script setup lang="ts">
// Props per posar la secció inicial activa
const props = defineProps<{
  activeSection?: 'videos' | 'series' | 'categories' | 'studios'
}>()

// Emissió d'esdeveniments per canviar secció
const emit = defineEmits<{
  (e: 'update:activeSection', section: 'videos' | 'series' | 'categories' | 'studios'): void
}>()

import { ref } from 'vue'

// Estat intern de la barra
const active = ref(props.activeSection || 'videos')

// Canviar secció
function changeSection(section: 'videos' | 'series' | 'categories' | 'studios') {
  active.value = section
  emit('update:activeSection', section)
}
</script>

<style scoped>
.top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #667eea;
  padding: 12px 24px;
  color: white;
  font-weight: 600;
  border-radius: 0 0 12px 12px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.left-buttons,
.right-buttons {
  display: flex;
  gap: 12px;
}

button {
  background: transparent;
  border: 2px solid rgba(255,255,255,0.7);
  color: white;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

button.active {
  background: white;
  color: #667eea;
  border-color: white;
}

button:hover {
  background: rgba(255,255,255,0.2);
}

.title {
  font-size: 1.6rem;
  font-weight: 700;
  text-align: center;
  flex: 1;
}
</style>
