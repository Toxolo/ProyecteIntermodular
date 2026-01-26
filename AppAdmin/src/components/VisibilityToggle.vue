<template>
  <button
    class="view-btn"
    :class="{ 'active': isVisible }"
    :title="isVisible ? 'Visible' : 'Oculto'"
    @click="toggle"
  >
    <!-- Eye icon SVG -->
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
      <circle cx="12" cy="12" r="3"></circle>
    </svg>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue';

// Component props - receives boolean value from parent
const props = defineProps<{
  modelValue: boolean
}>()

// Emits update event to parent component
const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
}>()

// Computed property for two-way binding with v-model
const isVisible = computed({
  get: () => props.modelValue,
  set: (val: boolean) => emit('update:modelValue', val)
})

// Toggle visibility state
function toggle() {
  isVisible.value = !isVisible.value
}
</script>

<style scoped>
.view-btn {
  padding: 14px;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s ease;
  background: #e0e0e0;
  color: #555;
}

/* Active state when visible */
.view-btn.active {
  background: #3498db;
  color: white;
}

.view-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
}

.view-btn.active:hover {
  background: #2980b9;
}
</style>