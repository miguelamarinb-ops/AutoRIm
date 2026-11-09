<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import TireFace from '../components/TireFace.vue'
import { tires, tireSizes, addToCart, fmt } from '../store'

const route = useRoute()
const tire = computed(() => tires.find(t => t.id === route.params.id) || tires[0])
const size = ref(tireSizes[1])
const added = ref(false)
watch(tire, () => (added.value = false))
const price = computed(() => Math.round((tire.value.price * size.value.f) / 1000) * 1000)

function add() {
  addToCart({ name: `Llanta ${tire.value.name}`, detail: `Set de 4 · ${size.value.l}`, price: price.value, tire: tire.value })
  added.value = true
}
</script>

<template>
  <div class="container py-4">
    <h1 class="h2 mb-3">Llanta {{ tire.name }}</h1>
    <div class="row g-4">
      <div class="col-lg-8"><div class="stage p-4"><TireFace :tire="tire" /></div></div>
      <div class="col-lg-4">
        <div class="panel p-3 d-grid gap-3">
          <h2 class="h5">Personalización llantas</h2>
          <div>
            <h3 class="h6">Tipo</h3>
            <div class="d-grid gap-2">
              <router-link v-for="t in tires" :key="t.id" :to="`/llanta/${t.id}`" class="opt text-decoration-none text-white" :class="{ on: t.id === tire.id }">{{ t.name }}</router-link>
            </div>
          </div>
          <div>
            <label class="form-label small" for="ts">Medida</label>
            <select id="ts" v-model="size" class="form-select"><option v-for="s in tireSizes" :key="s.l" :value="s">{{ s.l }}</option></select>
          </div>
          <div class="border-top pt-3" style="border-color:var(--line)!important">
            <div class="d-flex justify-content-between align-items-baseline mb-3">
              <span class="text-secondary">Set de 4 llantas</span><strong class="fs-4 text-red">{{ fmt(price) }}</strong>
            </div>
            <button class="btn btn-red w-100" @click="add">Agregar al carrito</button>
            <router-link v-if="added" to="/carrito" class="btn btn-outline-light w-100 mt-2">Ver carrito</router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
