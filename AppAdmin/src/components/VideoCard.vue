<script setup lang="ts">

// Crea una "interficie" a partir dels valors que recibeix
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

// Funcio per a formatar el temps de duracio
const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60)
  const secs = Math.floor(seconds % 60)
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

// Funcio per a formatar el tamany dels videos
const formatSize = (kb: number) => {
  if (kb < 1024) return `${kb} KB`
  const mb = kb / 1024
  return `${mb.toFixed(1)} MB`
}
</script>

<template>
  <div class="video-card">
    
    <div class="card-content">
      <h3 class="title">{{ video.titol }}</h3>

    <!-- Metadates del video -->
      <div class="meta">
        <div>ID: {{ video.id }}</div>
        <div>Resolució: {{ video.resolucio }}</div>
        <div>Còdec: {{ video.codec }}</div>
        <div>Pes: {{ formatSize(video.pes) }}</div>
        <div>Duracio : {{ formatDuration(video.duracio) }}</div>
      </div>
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
  border-color: #111;
  border-style: solid;
  margin: 10px 5px;
}

.video-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.14);
}

.thumbnail {
  position: relative;
  height: 158px;
  background: #111;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #aaa;
  font-size: 3.5rem;
}

.placeholder {
  opacity: 0.35;
}

.duration {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background: rgba(0,0,0,0.75);
  color: white;
  padding: 3px 7px;
  border-radius: 4px;
  font-size: 0.78rem;
  font-weight: 600;
}

.card-content {
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

/* .play-btn {
  margin-top: 12px;
  padding: 8px 16px;
  background: #e50914;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
} */
</style>