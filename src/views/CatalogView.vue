<script setup>
import { ref, computed } from 'vue'
import CarSvg from '../components/CarSvg.vue'
import { cars, rims, tires } from '../store'
const brand = ref('Todas')
const brands = ['Todas', ...new Set(cars.map(c => c.brand))]
const list = computed(() => cars.filter(c => brand.value === 'Todas' || c.brand === brand.value))
</script>

<template>
  <div class="container py-5">
    <h1 class="mb-3">Catálogo de autos compatibles</h1>
    <div class="d-flex gap-2 flex-wrap mb-4">
      <button v-for="b in brands" :key="b" class="btn btn-sm" :class="b === brand ? 'btn-red' : 'btn-outline-light'" @click="brand = b">{{ b }}</button>
    </div>
    <div class="row g-4">
      <div v-for="c in list" :key="c.id" class="col-md-6 col-lg-4">
        <div class="panel overflow-hidden h-100">
          <div class="stage border-0 rounded-0 p-3"><CarSvg :body="c.body" :color="c.color" :rim="rims[0]" :tire="tires[0]" /></div>
          <div class="p-3">
            <h2 class="h5">{{ c.name }}</h2>
            <router-link :to="`/personalizar/${c.id}`" class="btn btn-red w-100">Personalizar</router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
