<template>
  <div class="upload-container">
    <!-- Left Section -->
    <div class="left-section">
      <div class="preview">
        <p><strong>Editando vídeo ID:</strong> {{ videoId }}</p>
        <p><strong>Duración:</strong> {{ form.duration }} s</p>
      </div>

      <p v-if="error" class="error">{{ error }}</p>
    </div>

    <div class="divider"></div>

    <!-- Right Section -->
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

      <!-- Categories -->
      <div class="form-group">
        <label class="form-label">Categoría 1</label>
        <select class="form-input" v-model="category1">
          <option value="">Selecciona una categoría</option>
          <option v-for="c in categories" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>

        <label class="form-label">Categoría 2</label>
        <select class="form-input" v-model="category2">
          <option value="">Selecciona una categoría</option>
          <option v-for="c in categories" :key="c.id" :value="c.id">
            {{ c.name }}
          </option>
        </select>
      </div>

      <!-- Studio -->
      <div class="form-group">
        <label class="form-label">Estudio</label>
        <select class="form-input" v-model="estudioId">
          <option value="">Selecciona un estudio</option>
          <option v-for="e in estudios" :key="e.id" :value="e.id">
            {{ e.name }}
          </option>
        </select>
      </div>

      <!-- Series -->
      <div class="form-row">
        <div class="form-group">
          <label class="form-label">Serie</label>
          <select class="form-input" v-model="seriesId">
            <option value="">Selecciona una serie</option>
            <option v-for="s in series" :key="s.id" :value="s.id">
              {{ s.name }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Temporada</label>
          <input type="number" class="form-input" v-model.number="form.season" />
        </div>

        <div class="form-group">
          <label class="form-label">Capítulo</label>
          <input type="number" class="form-input" v-model.number="form.chapter" />
        </div>
      </div>

      <!-- Actions -->
      <div class="bottom-actions">
        <button class="delete-btn" @click="goBack">Cancelar</button>
        <button class="save-btn" :disabled="uploading" @click="handleSave">
          Guardar cambios
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()
const route = useRoute()
const router = useRouter()

const videoId = Number(route.params.id)

const uploading = ref(false)
const error = ref('')

const form = ref({
  id: 0,
  title: '',
  description: '',
  season: null as number | null,
  chapter: null as number | null,
  duration: 0,
  category: [] as Array<{ id: number }>,
  study: { id: 0 },
  series: { id: 0 }
})

const category1 = ref<number | null>(null)
const category2 = ref<number | null>(null)
const estudioId = ref<number | null>(null)
const seriesId = ref<number | null>(null)

const categories = ref<any[]>([])
const estudios = ref<any[]>([])
const series = ref<any[]>([])

async function loadVideo() {
  const { data } = await axios.get(`http://localhost:8090/Cataleg/${videoId}`)

  form.value = {
    ...form.value,
    ...data
  }

  category1.value = data.category?.[0]?.id ?? null
  category2.value = data.category?.[1]?.id ?? null
  estudioId.value = data.study?.id ?? null
  seriesId.value = data.series?.id ?? null
}

async function loadReferenceData() {
  const [c, e, s] = await Promise.all([
    axios.get('http://localhost:8090/Category'),
    axios.get('http://localhost:8090/Estudi'),
    axios.get('http://localhost:8090/Serie')
  ])

  categories.value = c.data
  estudios.value = e.data
  series.value = s.data
}

async function handleSave() {
  uploading.value = true

  try {
    form.value.category = []

    if (category1.value) form.value.category.push({ id: category1.value })
    if (category2.value) form.value.category.push({ id: category2.value })

    if (estudioId.value) form.value.study = { id: estudioId.value }
    if (seriesId.value) form.value.series = { id: seriesId.value }

    await axios.put(
      `http://localhost:8090/Cataleg/${videoId}`,
      form.value
    )

    toast.success('Vídeo actualizado correctamente')
    router.back()

  } catch (e) {
    error.value = 'Error al actualizar el vídeo'
  } finally {
    uploading.value = false
  }
}

function goBack() {
  router.back()
}

onMounted(async () => {
  await Promise.all([
    loadReferenceData(),
    loadVideo()
  ])
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