<script setup lang="ts">
interface Category {
  id: number
  name?: string
}

interface Series {
  id: number
  name?: string
}

interface Study {
  id: number
  name?: string
}

interface Video {
  id: number
  title: string
  description: string
  duration: number
  season: number
  chapter: number
  rating: number
  category: Category[]
  series: Series
  study: Study
  resolucio?: string | null
  codec?: string | null
  pes?: number | null
}

const props = defineProps<{ video: Video }>()

const emit = defineEmits<{
  (e: 'edit', videoId: number): void
}>()

const handleEdit = () => emit('edit', props.video.id)

const formatDuration = (seconds: number) => {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

const formatSize = (kb: number | null | undefined) => {
  if (kb == null) return 'N/A'
  if (kb < 1024) return `${kb} KB`
  return `${(kb / 1024).toFixed(1)} MB`
}

const thumbnailUrl = `http://localhost:3000/static/${props.video.id}/thumbnail.jpg`
</script>

<template>
  <div class="video-card">
    <!-- Header -->
    <div class="card-header">
      <h3 class="title">{{ props.video.title }}</h3>

      <button class="edit-btn" @click="handleEdit" title="Editar vídeo">
        ✏️
      </button>
    </div>

    <div class="divider"></div>

    <!-- Description + Image -->
    <div class="top-content">
      <div class="description">
        {{ props.video.description }}
      </div>

      <div class="thumbnail">
        <img
          :src="thumbnailUrl"
          alt="thumbnail"
          @error="($event.target as HTMLImageElement).style.display='none'"
        />
      </div>
    </div>

    <!-- Info blocks -->
    <div class="meta-grid">
      <!-- Left -->
      <div class="meta-box">
        <div><strong>ID:</strong> {{ props.video.id }}</div>
        <div><strong>Duració:</strong> {{ formatDuration(props.video.duration) }}</div>
        <div><strong>Còdec:</strong> {{ props.video.codec ?? 'N/A' }}</div>
        <div><strong>Resolució:</strong> {{ props.video.resolucio ?? 'N/A' }}</div>
        <div><strong>Pes:</strong> {{ formatSize(props.video.pes) }}</div>
      </div>

      <!-- Right -->
      <div class="meta-box">
        <div><strong>Temporada:</strong> {{ props.video.season }}</div>
        <div><strong>Capítol:</strong> {{ props.video.chapter }}</div>
        <div><strong>Valoració:</strong> {{ props.video.rating }}</div>

        <div class="categories">
          <strong>Categories:</strong>
          <span v-for="c in props.video.category" :key="c.id" class="chip">
            {{ c.name || `#${c.id}` }}
          </span>
        </div>

        <div><strong>Sèrie:</strong> {{ props.video.series.name || `#${props.video.series.id}` }}</div>
        <div><strong>Estudi:</strong> {{ props.video.study.name || `#${props.video.study.id}` }}</div>
      </div>
    </div>
  </div>
</template>


<style scoped>
.video-card {
  background: white;
  border-radius: 12px;
  border: 1px solid #e0e0e0;
  box-shadow: 0 4px 14px rgba(0,0,0,0.08);
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

/* HEADER */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  margin: 0;
  font-size: 1.1rem;
  color: #111;
}

/* EDIT BUTTON */
.edit-btn {
  border: none;
  background: #f39c12;
  color: white;
  padding: 8px 10px;
  border-radius: 8px;
  cursor: pointer;
}

.edit-btn:hover {
  background: #e67e22;
}

/* DIVIDER */
.divider {
  height: 1px;
  background: #ddd;
}

/* DESCRIPTION + IMAGE */
.top-content {
  display: grid;
  grid-template-columns: 1fr 180px;
  gap: 12px;
  align-items: stretch;
}

/* Description fixed height ≈ 255 chars */
.description {
  font-size: 0.9rem;
  color: #444;
  line-height: 1.4;
  max-height: 120px;
  overflow-y: auto;
  white-space: pre-wrap;
  padding-right: 6px;
}

/* Thumbnail fixed size */
.thumbnail {
  width: 180px;
  height: 120px;
  background: #f3f3f3;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* META BLOCKS */
.meta-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.meta-box {
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 10px;
  font-size: 0.85rem;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

/* CATEGORIES */
.categories {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.chip {
  background: #f1f1f1;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
}

/* RESPONSIVE */
@media (min-width: 900px) {
  .video-card {
    max-width: calc(50% - 10px); /* 2 cards por fila */
  }
}

@media (max-width: 768px) {
  .top-content {
    grid-template-columns: 1fr;
  }

  .thumbnail {
    width: 100%;
    height: 160px;
  }

  .meta-grid {
    grid-template-columns: 1fr;
  }
}

</style>
