<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import Wheel from '../components/Wheel.vue'
import { rims, tires, finishes, sizes, addToCart, fmt } from '../store'

const route = useRoute()
const base = computed(() => rims.find(r => r.id == route.params.id) || rims[0])
const finish = ref(base.value.finish)
const size = ref(sizes[1])
const width = ref('8.5J')
const added = ref(false)
watch(base, b => { finish.value = b.finish; added.value = false })

const rim = computed(() => ({ ...base.value, finish: finish.value }))
const finishName = computed(() => finishes.find(f => f.hex === finish.value)?.name || 'Original')
const price = computed(() => Math.round((base.value.price * size.value.f) / 1000) * 1000)

function add() {
  addToCart({ name: base.value.name, detail: `Set de 4 · ${finishName.value} · ${size.value.l} · ${width.value}`, price: price.value, rim: rim.value })
  added.value = true
}
</script>

<template>
  <div class="container py-4">
    <div class="d-flex gap-2 flex-wrap mb-3">
      <router-link v-for="r in rims" :key="r.id" :to="`/rin/${r.id}`" class="btn btn-sm" :class="r.id === base.id ? 'btn-red' : 'btn-outline-light'">{{ r.name }}</router-link>
    </div>
    <h1 class="h2 mb-3">{{ base.name }}</h1>
    <div class="row g-4">
      <div class="col-lg-8">
        <div class="stage p-4 text-center">
          <svg viewBox="-60 -60 120 120" class="rim-big" role="img" :aria-label="`Rin ${base.name}`"><Wheel :key="base.id" :rim="rim" :tire="tires[0]" /></svg>
        </div>
      </div>
      <div class="col-lg-4">
        <div class="panel p-3 d-grid gap-3">
          <h2 class="h5">Personalización rines</h2>
          <div>
            <h3 class="h6">Acabado: <span class="text-secondary">{{ finishName }}</span></h3>
            <div class="d-flex gap-2 flex-wrap">
              <button v-for="f in finishes" :key="f.hex" class="swatch" :class="{ on: f.hex === finish }" :style="{ background: f.hex }" :aria-label="f.name" :title="f.name" @click="finish = f.hex"></button>
            </div>
          </div>
          <div>
            <label class="form-label small" for="sz">Tamaño</label>
            <select id="sz" v-model="size" class="form-select"><option v-for="s in sizes" :key="s.l" :value="s">{{ s.l }}</option></select>
          </div>
          <div>
            <label class="form-label small" for="wd">Ancho</label>
            <select id="wd" v-model="width" class="form-select"><option v-for="w in ['7.5J', '8.5J', '9.5J']" :key="w">{{ w }}</option></select>
          </div>
          <div class="border-top pt-3" style="border-color:var(--line)!important">
            <div class="d-flex justify-content-between align-items-baseline mb-3">
              <span class="text-secondary">Set de 4 rines</span><strong class="fs-4 text-red">{{ fmt(price) }}</strong>
            </div>
            <button class="btn btn-red w-100" @click="add">Agregar al carrito</button>
            <router-link v-if="added" to="/carrito" class="btn btn-outline-light w-100 mt-2">Ver carrito</router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
