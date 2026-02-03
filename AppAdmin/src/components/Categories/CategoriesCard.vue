<script setup lang="ts">
interface Category {
  id: number
  name: string
}

defineProps<{
  category: Category
}>()
</script>

<template>
  <div v-if="category" class="category-card">
    <strong>#{{ category.id }}</strong>
    <span>{{ category.name }}</span>
  </div>
</template>


<style src="../../assets/css/cards.css"></style>
