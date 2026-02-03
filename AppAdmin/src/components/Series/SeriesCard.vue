<script setup lang="ts">
interface Serie {
  id: number
  name: string
  classification: number
}

defineProps<{
  serie: Serie
}>()
</script>

<template>  
  <div v-if="serie" class="category-card">
    <strong>{{ serie.name }}</strong>
    <span>Clasificació: {{ serie.classification }}</span>
    <span>id:{{ serie.id }}</span>
  </div>
</template>


<style scoped>

.category-card {
  background: white;
  border-radius: 12px;
  border: 1px solid #e0e0e0;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
  padding: 15px 6px; /* 10px dalt i baix, 6px esquerra i dreta */
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 4px;
  width: 90%; /* menys que 100% per ser més estreta */
  margin: 0 auto; /* centrar dins la cel·la del grid */
  height: 50px; /* altura compacta */
  overflow: hidden;
  transition: transform 0.1s, box-shadow 0.1s;
}

.category-card:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 8px rgba(0,0,0,0.1);
}

/* Text compacte */
strong, span {
  font-size: 0.75rem;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  padding-left: 15px;
}


</style>
