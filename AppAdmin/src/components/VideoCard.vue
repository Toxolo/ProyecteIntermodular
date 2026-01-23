<script setup lang="ts">

// Define component props interface
defineProps<{
  video: {
    id: number
    titol: string
    duracio: number
    codec: string
    resolucio: string
    pes: number
  }
}>()

// Define emits for events to parent
const emit = defineEmits<{
  (e: 'edit', videoId: number): void
}>()

// Format duration from seconds to MM:SS
const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

// Format file size from KB to readable format
const formatSize = (kb: number) => {
  if (kb < 1024) return `${kb} KB`
  const mb = kb / 1024
  return `${mb.toFixed(1)} MB`
}


// Emit edit event to parent
const handleEdit = (videoId: number) => {
  emit('edit', videoId)
}
</script>

<template>
  <div class="video-card">
    <!-- Card content -->
    <div class="card-content">
      <!-- Video title -->
      <h3 class="title">{{ video.titol }}</h3>

      <!-- Video metadata -->
      <div class="meta">
        <div>ID: {{ video.id }}</div>
        <div>Resolució: {{ video.resolucio }}</div>
        <div>Còdec: {{ video.codec }}</div>
        <div>Pes: {{ formatSize(video.pes) }}</div>
        <div>Duracio : {{ formatDuration(video.duracio) }}</div>
      </div>
    </div>
    
    <!-- Action buttons container -->
    <div class="actions">
      <!-- Edit button -->
      <button 
        class="edit-btn" 
        @click="handleEdit(video.id)"
        title="Editar video"
      >
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
        </svg>
      </button>
    </div>
  </div>
</template>

<style scoped>
.video-card {
  background: white;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 4px 14px rgba(0,0,0,0.08);
  transition: all 0.18s ease;
  border: 1px solid #e0e0e0;
  margin: 10px 5px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-right: 16px;
}

.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.14);
}

.card-content {
  flex: 1;
  padding: 14px 16px;
}

.title {
  margin: 0 0 10px 0;
  font-size: 1.05rem;
  line-height: 1.3;
  color: #111;
}

.meta {
  display: flex;
  flex-direction: column;
  gap: 5px;
  font-size: 0.84rem;
  color: #555;
}

.meta div {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Actions container */
.actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

/* Edit button */
.edit-btn {
  padding: 12px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #f39c12;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
}

.edit-btn:hover {
  background: #e67e22;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(243, 156, 18, 0.3);
}

.edit-btn:active {
  transform: translateY(0);
}

/* Responsive */
@media (max-width: 768px) {
  .video-card {
    flex-direction: column;
    align-items: stretch;
    padding-right: 0;
  }
  
  .actions {
    padding: 0 16px 14px 16px;
    justify-content: flex-end;
  }
}
</style>