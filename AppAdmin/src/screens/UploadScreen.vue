<template>
  <div class="upload-container">
    <!-- Left Section - Video Upload & Preview -->
    <div class="left-section">
      <!-- Hidden file input -->
      <input ref="fileInput" type="file" accept="video/*" style="display: none" @change="handleFileChange" />

      <!-- Select video button -->
      <button class="upload-btn" :disabled="uploading" @click="fileInput?.click()">
        {{ uploading ? 'Subiendo...' : 'Seleccionar video' }}
      </button>

      <!-- Video preview -->
      <div v-if="previewUrl" class="preview">
        <video controls :src="previewUrl" width="400" />
        <p>{{ file?.name }} – {{ formatFileSize(file?.size) }} MB</p>
      </div>

      <!-- Progress bar -->
      <div v-if="progressBar > 0" class="progress-bar">
        <div class="bar" :style="{ width: progressBar + '%' }"></div>
        <span>{{ Math.round(progressBar) }}%</span>
      </div>

      <!-- Error message -->
      <p v-if="error" class="error">{{ error }}</p>
    </div>

    <div class="divider"></div>

    <!-- Right Section - Form Fields -->
    <div class="right-section">
      <!-- Title -->
      <div class="form-group">
        <label class="form-label">Títol</label>
        <input type="text" class="form-input" v-model="form.title" />
      </div>

      <!-- Description -->
      <div class="form-group">
        <label class="form-label">Descripción</label>
        <textarea class="form-textarea" v-model="form.description" rows="3" />
      </div>

      <!-- Category -->
      <div class="form-group">
        <label class="form-label">Categoría 1</label>
        <div v-if="loadingCategories" class="field-loading">
          <div class="mini-spinner"></div>
          <span>Cargando categorías...</span>
        </div>
        <select v-else class="form-input" v-model="category1">
          <option value="">Selecciona una categoría</option>
          <option v-for="cat in categories" :key="cat.id ?? cat.name" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>

        <label class="form-label">Categoría 2</label>
        <div v-if="loadingCategories" class="field-loading">
          <div class="mini-spinner"></div>
          <span>Cargando categorías...</span>
        </div>
        <select v-else class="form-input" v-model="category2">
          <option value="">Selecciona una categoría</option>
          <option v-for="cat in categories" :key="cat.id ?? cat.name" :value="cat.id">
            {{ cat.name }}
          </option>
        </select>
      </div>

      <!-- PEGI 
      <div class="form-group">
        <label class="form-label">Classificación</label>
        <input type="text" class="form-input" v-model="form.classification" placeholder="p. ej. 7, 12, 16..." />
      </div>
      -->

      <!-- Studio -->
      <div class="form-group">
        <label class="form-label">Estudio</label>
        <div v-if="loadingEstudios" class="field-loading">
          <div class="mini-spinner"></div>
          <span>Cargando estudios...</span>
        </div>
        <select v-else class="form-input" v-model="estudioId">
          <option value="">Selecciona un estudio</option>
          <option v-for="est in estudios" :key="est.id ?? est.name" :value="est.id">
            {{ est.name }}
          </option>
        </select>
      </div>

      <!-- Series / Season / Episode -->
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Serie</label>
          <div v-if="loadingSeries" class="field-loading">
            <div class="mini-spinner"></div>
            <span>Cargando...</span>
          </div>
          <select v-else class="form-input" v-model="seriesId">
            <option value="">Selecciona una serie</option>
            <option v-for="s in series" :key="s.id ?? s.name" :value="s.id">
              {{ s.name }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Temporada</label>
          <input type="number" min="1" class="form-input" v-model.number="form.season" />
        </div>

        <div class="form-group">
          <label class="form-label">Número capítulo</label>
          <input type="number" min="1" class="form-input" v-model.number="form.chapter" />
        </div>
      </div>

      <!-- Bottom Actions -->
      <div class="bottom-actions">

        <button class="delete-btn" @click="$emit('close')" title="Cancelar">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <button class="save-btn" :disabled="uploading || !file" @click="handleSave">
          Guardar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../services/api' // ← importem el axios amb token automàtic
import { useToast, POSITION } from 'vue-toastification'

const toast = useToast()

// ── File & Preview ─────────────────────────
const file = ref<File | null>(null)
const previewUrl = ref<string>('')
const fileInput = ref<HTMLInputElement | null>(null)

// ── Progress & Status ─────────────────────
const progressBar = ref(0)
const progressMessage = ref('')
const uploading = ref(false)
const error = ref('')

// ── Form Data ─────────────────────────────
const form = ref({
  id: 0,
  title: '',
  description: '',
  category: [] as Array<{ id: number }>,
  study: { id: 0 },
  series: { id: 0 },
  season: null as number | null,
  chapter: null as number | null,
  duration: 0
})
const category1 = ref<number | null>(null)
const category2 = ref<number | null>(null)
const estudioId = ref<number | null>(null)
const seriesId = ref<number | null>(null)

// ── Backend Data (dropdowns) ─────────────
const categories = ref<Array<{ id: number; name: string }>>([])
const estudios = ref<Array<{ id: number; name: string }>>([])
const series = ref<Array<{ id: number; name: string }>>([])

const loadingCategories = ref(false)
const loadingEstudios = ref(false)
const loadingSeries = ref(false)

let ws: WebSocket
let clientId: string

// ── Helpers ───────────────────────────────
function formatFileSize(bytes?: number): string {
  if (!bytes) return '0.0'
  return (bytes / 1024 / 1024).toFixed(1)
}

function handleFileChange(e: Event) {
  const input = e.target as HTMLInputElement
  const selected = input.files?.[0]
  if (!selected) return
  if (!selected.type.startsWith('video/')) {
    error.value = 'Solo se permiten archivos de vídeo'
    return
  }
  if (selected.size > 500 * 1024 * 1024) {
    error.value = 'El vídeo es demasiado grande (máx. 500 MB)'
    return
  }
  file.value = selected
  previewUrl.value = URL.createObjectURL(selected)
  error.value = ''
  form.value.title = selected.name.replace(/\.[^/.]+$/, "")
}

// ── Load dropdowns ─────────────────────────
async function loadReferenceData() {
  loadingCategories.value = true
  loadingEstudios.value = true
  loadingSeries.value = true

  try {
    const [catRes, estRes, serRes] = await Promise.all([
      api.get('/Category'),
      api.get('/Estudi'),
      api.get('/Serie')
    ])
    categories.value = catRes.data
    estudios.value = estRes.data
    series.value = serRes.data
  } catch (err) {
    console.error('Error cargando datos de referencia', err)
  } finally {
    loadingCategories.value = false
    loadingEstudios.value = false
    loadingSeries.value = false
  }
}

// ── WebSocket ─────────────────────────────
async function connectWebSocket() {
  ws = new WebSocket('ws://localhost:3000/vid')

  ws.onopen = () => console.log('WebSocket connected')

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data)
    switch (data.type) {
      case 'connection':
        clientId = data.clientId
        break
      case 'progress':
        if (data.clientId === clientId) {
          progressBar.value = data.progress
          progressMessage.value = data.message
        }
        break
      case 'metadata':
        if (data.clientId === clientId) {
          form.value.id = data.videoId
          form.value.duration = data.duration
        }
        break
    }
  }
  ws.onclose = () => console.log('WebSocket disconnected')
}

// ── Upload video + save ───────────────────
async function uploadVideoAndSave() {
  if (!file.value) return false
  uploading.value = true
  error.value = ''

  try {
    // 1️⃣ Upload video to video service
    const fd = new FormData()
    fd.append('video', file.value)
    await api.post('http://localhost:3000/vid', fd, { headers: { 'X-Client-Id': clientId } })

    // 2️⃣ Prepare payload EXACTO como lo espera el backend
    const payload = {
      id: Number(form.value.id) || Date.now(), // ejemplo de id único si no tienes uno
      title: form.value.title || 'Sin título',
      description: form.value.description || '',
      duration: Number(form.value.duration) || 0,
      chapter: Number(form.value.chapter) || 1,
      season: Number(form.value.season) || 1,
      rating: 0.0, // default si no tienes rating
      thumbnail: '', // o asigna la thumbnail si la tienes
      category: [] as Array<{ id: number }>,
      study: { id: estudioId.value || 0 },
      series: { id: seriesId.value || 0 }
    }

    // Añadir categorías
    if (category1.value) payload.category.push({ id: Number(category1.value) })
    if (category2.value) payload.category.push({ id: Number(category2.value) })

    // Evitar array vacío
    if (payload.category.length === 0) payload.category.push({ id: 0 })

    console.log('Payload enviado:', payload) // para depuración

    // 3️⃣ POST al backend con token automático via api
    await api.post('/Cataleg', payload)

    toast.success('Vídeo subido y añadido correctamente', { position: POSITION.TOP_CENTER, timeout: 4000 })
    resetForm()
    return true

  } catch (err: any) {
    console.error('Error al guardar el vídeo:', err)
    error.value = err.response?.data?.message || 'Error al guardar el vídeo'
    return false

  } finally {
    uploading.value = false
    progressBar.value = 0
  }
}


function resetForm() {
  file.value = null
  previewUrl.value = ''
  form.value = {
    id: 0,
    title: '',
    description: '',
    category: [],
    study: { id: 0 },
    series: { id: 0 },
    season: null,
    chapter: null,
    duration: 0
  }
  category1.value = null
  category2.value = null
  estudioId.value = null
  seriesId.value = null
}

// ── Save button ──────────────────────────
async function handleSave() {
  await uploadVideoAndSave()
}

// ── Lifecycle ────────────────────────────
onMounted(() => {
  loadReferenceData()
  connectWebSocket()
})
</script>



<style scoped>
html,
body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}

.upload-container {
  display: flex;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.left-section {
  flex: 0 0 320px;
  padding: 40px;
  display: flex;
  flex-direction: column;
  gap: 24px;
  background: #f8f9fa;
  border-radius: 16px 0 0 16px;
}

.preview {
  background: #f0f0f0;
  border-radius: 12px;
  padding: 10px;
}

.preview video {
  width: 100%;
  border-radius: 8px;
}

.preview p {
  margin-top: 8px;
  font-size: 0.9rem;
  color: #555;
}

.progress-bar {
  position: relative;
  width: 100%;
  height: 30px;
  background: #e0e0e0;
  border-radius: 15px;
  overflow: hidden;
}

.progress-bar .bar {
  height: 100%;
  background: linear-gradient(90deg, #3498db, #2ecc71);
  transition: width 0.3s ease;
}

.progress-bar span {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-weight: 600;
  color: #2c3e50;
}

.upload-btn {
  padding: 14px 20px;
  background: #27ae60;
  color: white;
  border: none;
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.upload-btn:hover {
  background: #229954;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
}

.error {
  color: #e74c3c;
  font-size: 0.9rem;
  font-weight: 500;
}

.thumbnail-preview {
  background: #fff;
  border-radius: 12px;
  padding: 12px;
  border: 2px solid #3498db;
}

.thumbnail-label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.thumbnail-img {
  width: 100%;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

button:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}

.divider {
  width: 2px;
  background: #e0e0e0;
}

.right-section {
  flex: 1;
  padding: 40px 50px;
  display: flex;
  flex-direction: column;
  gap: 18px;
  overflow-y: auto;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-label {
  font-weight: 600;
  font-size: 1rem;
  color: #2c3e50;
}

.form-input,
.form-textarea {
  padding: 12px 14px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  transition: all 0.3s ease;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #3498db;
  box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 70px;
}

.form-row {
  display: flex;
  gap: 16px;
}

.form-row .form-group {
  flex: 1;
}

/* Loading state for form fields */
.field-loading {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 14px;
  background: #f8f9fa;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  color: #666;
  font-size: 0.95rem;
}

/* Mini spinner for loading fields */
.mini-spinner {
  width: 20px;
  height: 20px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}

.bottom-actions {
  display: flex;
  gap: 14px;
  margin-top: auto;
  padding-top: 24px;
}

.view-btn,
.delete-btn,
.save-btn {
  padding: 14px 24px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
}

.view-btn {
  background: #3498db;
  color: white;
}

.delete-btn {
  background: #e74c3c;
  color: white;
}

.save-btn {
  flex: 1;
  background: #27ae60;
  color: white;
  font-size: 1.1rem;
}

.view-btn:hover {
  background: #2980b9;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.delete-btn:hover {
  background: #c0392b;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(231, 76, 60, 0.3);
}

.save-btn:hover {
  background: #229954;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(39, 174, 96, 0.3);
}

@media (max-width: 900px) {
  .upload-container {
    flex-direction: column;
    border: 3px solid #2c3e50;
  }

  .left-section {
    flex: none;
    padding: 30px;
    border-radius: 16px 16px 0 0;
  }

  .divider {
    width: 100%;
    height: 2px;
  }

  .right-section {
    padding: 30px;
  }

  .form-row {
    flex-direction: column;
  }

  .bottom-actions {
    flex-wrap: wrap;
  }
}
</style>