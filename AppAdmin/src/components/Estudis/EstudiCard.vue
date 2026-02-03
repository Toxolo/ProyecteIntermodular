<script setup lang="ts">
interface Estudi {
  id: number
  name: string
}

defineProps<{
  estudi: Estudi
}>()
</script>

<template>
  <div v-if="estudi" class="category-card">
    <strong>{{ estudi.name }}</strong>
    <span>id:{{ estudi.id }}</span>
  </div>
</template>


<style src="../../assets/css/cards.css"></style>
