<script setup>
import CarSvg from '../components/CarSvg.vue'
import Wheel from '../components/Wheel.vue'
import TireFace from '../components/TireFace.vue'
import { store, cartTotal, tires, fmt } from '../store'
const qty = (i, d) => (i.qty = Math.max(1, i.qty + d))
const remove = uid => (store.cart = store.cart.filter(i => i.uid !== uid))
</script>

<template>
  <div class="container py-5">
    <h1 class="mb-4">Tu carrito de compras</h1>
    <div v-if="!store.cart.length" class="panel p-5 text-center">
      <p class="text-secondary">Tu carrito está vacío.</p>
      <router-link to="/autos" class="btn btn-red">Personalizar un auto</router-link>
    </div>
    <template v-else>
      <div class="d-grid gap-3">
        <div v-for="i in store.cart" :key="i.uid" class="panel p-3 d-flex align-items-center gap-3 flex-wrap">
          <div style="width:120px">
            <CarSvg v-if="i.cfg" v-bind="i.cfg" />
            <TireFace v-else-if="i.tire" :tire="i.tire" />
            <svg v-else viewBox="-52 -52 104 104"><Wheel :rim="i.rim" :tire="tires[0]" /></svg>
          </div>
          <div class="flex-grow-1"><h2 class="h6 mb-1">{{ i.name }}</h2><p class="small text-secondary mb-0">{{ i.detail }}</p></div>
          <div class="d-flex align-items-center gap-2">
            <button class="btn btn-sm btn-outline-light" aria-label="Menos" @click="qty(i, -1)">−</button>
            <span>{{ i.qty }}</span>
            <button class="btn btn-sm btn-outline-light" aria-label="Más" @click="qty(i, 1)">+</button>
          </div>
          <strong>{{ fmt(i.price * i.qty) }}</strong>
          <button class="btn btn-sm text-danger" @click="remove(i.uid)">Eliminar</button>
        </div>
      </div>
      <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top" style="border-color:var(--line)!important">
        <span class="fs-4">Total: <strong class="text-red">{{ fmt(cartTotal) }}</strong></span>
        <router-link :to="store.user ? '/pago' : '/login'" class="btn btn-red btn-lg">{{ store.user ? 'Proceder al pago' : 'Ingresa para pagar' }}</router-link>
      </div>
    </template>
  </div>
</template>
