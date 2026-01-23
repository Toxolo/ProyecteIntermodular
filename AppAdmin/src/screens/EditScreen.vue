<template>
  <div class="upload-container">
    <!-- Left Section - Video Upload & Preview -->

    <!-- Right Section - Form Fields -->
    <div class="right-section">
      <!-- Title field -->
      <div class="form-group">
        <label class="form-label">Títol</label>
        <input type="text" class="form-input" v-model="formData.titol" />
      </div>

      <!-- Description field -->
      <div class="form-group">
        <label class="form-label">Descripción</label>
        <textarea class="form-textarea" v-model="formData.descripcio" rows="2"></textarea>
      </div>

      <!-- Category dropdown with loading state -->
      <div class="form-group">
        <label class="form-label">Categoría</label>
        <div v-if="loadingCategories" class="field-loading">
          <div class="mini-spinner"></div>
          <span>Cargando categorías...</span>
        </div>
        <select v-else class="form-input" v-model="formData.categoria">
          <option value="">Selecciona una categoría</option>
          <option v-for="(item, index) in categories" :key="index" :value="item.name">
            {{ item.name }}
          </option>
        </select>
      </div>

      <!-- Pegi field -->
      <div class="form-group">
        <label class="form-label">Pegi</label>
        <input type="text" class="form-input" v-model="formData.pegi" />
      </div>

      <!-- Studio dropdown with loading state -->
      <div class="form-group">
        <label class="form-label">Estudio</label>
        <div v-if="loadingEstudios" class="field-loading">
          <div class="mini-spinner"></div>
          <span>Cargando estudios...</span>
        </div>
        <select v-else class="form-input" v-model="formData.estudio">
          <option value="">Selecciona un estudio</option>
          <option v-for="(item, index) in estudios" :key="index" :value="item.name">
            {{ item.name }}
          </option>
        </select>
      </div>

      <!-- Series, Season, Episode row -->
      <div class="form-row">
        <!-- Series dropdown with loading state -->
        <div class="form-group">
          <label class="form-label">Serie</label>
          <div v-if="loadingSeries" class="field-loading">
            <div class="mini-spinner"></div>
            <span>Cargando...</span>
          </div>
          <select v-else class="form-input" v-model="formData.serie">
            <option value="">Selecciona una serie</option>
            <option v-for="(item, index) in series" :key="index" :value="item.name">
              {{ item.name }}
            </option>
          </select>
        </div>
        
        <!-- Season field -->
        <div class="form-group">
          <label class="form-label">Temporada</label>
          <input type="text" class="form-input" v-model="formData.temporada" />
        </div>
        
        <!-- Episode number field -->
        <div class="form-group">
          <label class="form-label">Número capitulo</label>
          <input type="text" class="form-input" v-model="formData.numero" />
        </div>
      </div>

      <!-- Bottom Actions -->
      <div class="bottom-actions">
        <!-- Visibility toggle -->
        <VisibilityToggle v-model="formData.visible" />
        
        <!-- Close button -->
        <button class="delete-btn" @click="emit('close')" title="Eliminar">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
        
        <!-- Save button -->
        <button class="save-btn" title="Desar" @click="handleSave">
          SAVE
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import axios from 'axios'
import { onMounted, ref } from 'vue'
import { useToast, POSITION } from 'vue-toastification'
import VisibilityToggle from '../components/VisibilityToggle.vue'

const toast = useToast()

// File and preview state
const file = ref<File | null>(null)
const previewUrl = ref('')
const progress = ref(0)
const uploading = ref(false)
const error = ref('')
const thumbnail = ref('')

// Data from backend
const categories = ref([])
const estudios = ref([])
const series = ref([])

// Loading states for dropdowns
const loadingCategories = ref(false)
const loadingEstudios = ref(false)
const loadingSeries = ref(false)

const fileInput = ref<HTMLInputElement | null>(null)

const emit = defineEmits(['close'])

// Form data object
const formData = ref({
  id: '',
  titol: '',
  descripcio: '',
  categoria: '',
  pegi: '',
  estudio: '',
  serie: '',
  temporada: '',
  numero: '',
  visible: false
})

// Generate thumbnail from video file
function generateThumbnail() {
  if (!file.value) return

  const video = document.createElement('video')
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')

  video.src = previewUrl.value
  video.preload = 'metadata'
  video.muted = true
  video.playsInline = true
  
  // Seek to 1/4 of video or 3 seconds
  video.addEventListener('loadedmetadata', () => {
    video.currentTime = Math.min(video.duration / 4, 3)
  })

  // When video seeks to position, capture frame
  video.addEventListener('seeked', () => {
    canvas.width = video.videoWidth
    canvas.height = video.videoHeight
    ctx?.drawImage(video, 0, 0, canvas.width, canvas.height)
    
    // Convert canvas to base64 image
    thumbnail.value = canvas.toDataURL('image/jpeg', 0.85)
    
    // Free resources
    video.src = ''
  })

  video.addEventListener('error', (e) => {
    console.error('Error generando thumbnail:', e)
  })
}

// Extract video metadata from backend
async function getMetadata() {
  if (!file.value) return
  
  try {
    error.value = ''
    
    // Generate thumbnail before sending
    generateThumbnail()

    const uploadFormData = new FormData()
    uploadFormData.append('video', file.value)

    const response = await axios.post('http://localhost:3000/meta', uploadFormData, { 
      onUploadProgress: (progressEvent: any) => {     
        if (progressEvent.lengthComputable) {
          progress.value = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        }
      }
    })

    if (response.status !== 200) throw new Error('Error al obtener metadata')

    const data = response.data
    formData.value.titol = data.name
    formData.value.id = data.id
    
    progress.value = 0
  } catch (err: any) {
    error.value = 'Error al obtener metadata: ' + err.message
  }
}

// Fetch categories, studios, and series from backend
async function getData() {
  // Set loading states
  loadingCategories.value = true
  loadingEstudios.value = true
  loadingSeries.value = true

  try {
    // Fetch categories
    const cats = await axios.get('http://localhost:8090/Category')
    categories.value = cats.data
  } catch (err: any) {
    console.error('Error al cargar categorías:', err)
  } finally {
    loadingCategories.value = false
  }

  try {
    // Fetch studios
    const est = await axios.get('http://localhost:8090/Estudy')
    estudios.value = est.data
  } catch (err: any) {
    console.error('Error al cargar estudios:', err)
  } finally {
    loadingEstudios.value = false
  }

  try {
    // Fetch series
    const ser = await axios.get('http://localhost:8090/Series')
    series.value = ser.data
  } catch (err: any) {
    console.error('Error al cargar series:', err)
  } finally {
    loadingSeries.value = false
  }
}

// Add to catalog (placeholder)
function addCataleg() {
  console.log('Añadiendo al catálogo:', formData.value)
  // TODO: Send formData to backend
}

// Handle file selection
function handleFileChange(e: any) {
  const selectedFile = e.target.files?.[0]
  if (!selectedFile) return

  // Validate file type
  if (!selectedFile.type.startsWith('video/')) {
    error.value = 'Solo se permiten archivos de video'
    return
  }

  // Validate file size (max 500MB)
  if (selectedFile.size > 500 * 1024 * 1024) {
    error.value = 'El video es demasiado grande (máx 500 MB)'
    return
  }

  file.value = selectedFile
  previewUrl.value = URL.createObjectURL(selectedFile)
  error.value = ''
}

// Upload video to backend
async function uploadVideo() {
  if (!file.value) return

  uploading.value = true
  progress.value = 0
  error.value = ''

  const uploadFormData = new FormData()
  uploadFormData.append('video', file.value)

  try {
    const response = await axios.post('http://localhost:3000/vid', uploadFormData, { 
      onUploadProgress: (progressEvent: any) => {     
        if (progressEvent.lengthComputable) {
          progress.value = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        }
      }
    })
    
    if (response.status !== 200) throw new Error('Error al subir')

    const data = response.data
    console.log('¡Video subido!', data)

    // Clear state after upload
    file.value = null
    previewUrl.value = ''
    if (fileInput.value) fileInput.value.value = ''

  } catch (err: any) {
    error.value = 'Falló la subida: ' + err.message
  } finally {
    uploading.value = false
    progress.value = 0
  }
}

// Handle save: upload video and add to catalog
async function handleSave() {
  await uploadVideo()
  addCataleg()
  toast.success('Video subido y añadido al catálogo con éxito!', {
    position: POSITION.TOP_CENTER,
    timeout: 3000
  })
}

// Load data when component mounts
onMounted(getData)
</script>

<style scoped>
html, body {
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
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
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