<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CarSvg from '../components/CarSvg.vue'
import Wheel from '../components/Wheel.vue'
import { cars, colors, rims, tires, addToCart, fmt } from '../store'

const route = useRoute(), router = useRouter()
const car = computed(() => cars.find(c => c.id == route.params.id) || cars[0])
const color = ref(car.value.color)
const rim = ref(rims[0])
const tire = ref(tires[0])
const colorName = computed(() => colors.find(c => c.hex === color.value)?.name || 'Color base')
const price = computed(() => rim.value.price + tire.value.price)

function add() {
  addToCart({
    name: car.value.name,
    detail: `${colorName.value} · ${rim.value.name} · ${tire.value.name}`,
    price: price.value,
    cfg: { body: car.value.body, color: color.value, rim: rim.value, tire: tire.value },
  })
  router.push('/carrito')
}
</script>

<template>
  <div class="container py-4">
    <router-link to="/autos" class="text-secondary text-decoration-none small">← Cambiar auto</router-link>
    <h1 class="h2 mt-2 mb-3">{{ car.name }}</h1>
    <div class="row g-4">
      <div class="col-lg-8">
        <div class="stage p-3"><CarSvg :body="car.body" :color="color" :rim="rim" :tire="tire" /></div>
        <p class="text-secondary small mt-2">{{ colorName }} · {{ rim.name }} · {{ tire.name }}</p>
      </div>
      <div class="col-lg-4">
        <div class="panel p-3 d-grid gap-4">
          <div>
            <h2 class="h6">Color del carro</h2>
            <div class="d-flex gap-2 flex-wrap">
              <button v-for="c in colors" :key="c.hex" class="swatch" :class="{ on: c.hex === color }" :style="{ background: c.hex }" :aria-label="c.name" :title="c.name" @click="color = c.hex"></button>
            </div>
          </div>
          <div>
            <h2 class="h6">Rines</h2>
            <div class="row g-2">
              <div v-for="r in rims" :key="r.id" class="col-6">
                <button class="opt w-100" :class="{ on: r.id === rim.id }" @click="rim = r">
                  <svg viewBox="-52 -52 104 104" width="56"><Wheel :rim="r" :tire="tires[0]" /></svg>
                  <div class="small">{{ r.name }}</div>
                </button>
              </div>
            </div>
          </div>
          <div>
            <h2 class="h6">Llantas</h2>
            <div class="d-grid gap-2">
              <button v-for="t in tires" :key="t.id" class="opt d-flex justify-content-between" :class="{ on: t.id === tire.id }" @click="tire = t">
                <span>{{ t.name }}</span><span class="text-secondary small">{{ fmt(t.price) }}</span>
              </button>
            </div>
          </div>
          <div class="border-top pt-3" style="border-color:var(--line)!important">
            <div class="d-flex justify-content-between align-items-baseline mb-3">
              <span class="text-secondary">Total del kit</span><strong class="fs-4 text-red">{{ fmt(price) }}</strong>
            </div>
            <button class="btn btn-red w-100" @click="add">Agregar al carrito</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
