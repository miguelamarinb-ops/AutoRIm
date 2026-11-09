<script setup>
import { ref } from 'vue'
import Wheel from '../components/Wheel.vue'
import { rims, tires, addToCart, fmt } from '../store'
const hero = ref(rims[1])
const cats = [
  ['Rines deportivos', 'Ligeros y de alto desempeño', '/rin/1'],
  ['Rines de lujo', 'Acabados oro y mesh', '/rin/2'],
  ['Llantas deportivas', 'Agarre máximo en curva', '/llanta/sport'],
  ['Llantas off-road', 'Para terreno exigente', '/llanta/off'],
]
const why = [['Envío en 24 horas', 'Despachamos a todo el país.'], ['Garantía completa', 'Cobertura en cada set de rines.'], ['Instalación profesional', 'Montaje y balanceo con técnicos.']]
const add = r => addToCart({ name: r.name, detail: 'Set de 4 rines · 18"', price: Math.round(r.price * 1.1 / 1000) * 1000, rim: r })
</script>

<template>
  <section class="container py-5">
    <div class="row align-items-center g-5">
      <div class="col-lg-6">
        <h1 class="display-3">Rines que transforman tu estilo</h1>
        <p class="lead text-secondary">Elige tu auto, prueba rines, llantas y color en vivo, y compra el set exacto.</p>
        <div class="d-flex gap-2 flex-wrap">
          <router-link to="/autos" class="btn btn-red btn-lg">Personalizar mi auto</router-link>
          <a href="#rines" class="btn btn-outline-light btn-lg">Ver rines</a>
        </div>
      </div>
      <div class="col-lg-6 text-center">
        <svg viewBox="-60 -60 120 120" class="hero-wheel"><Wheel :key="hero.id" :rim="hero" :tire="tires[0]" /></svg>
        <div class="d-flex justify-content-center gap-2 mt-3 flex-wrap">
          <button v-for="r in rims" :key="r.id" class="btn btn-sm" :class="r.id === hero.id ? 'btn-red' : 'btn-outline-light'" @click="hero = r">{{ r.name }}</button>
        </div>
      </div>
    </div>
  </section>

  <section id="rines" class="container py-4">
    <h2 class="mb-4">Rines destacados</h2>
    <div class="row g-3">
      <div v-for="r in rims" :key="r.id" class="col-6 col-lg-3">
        <div class="panel p-3 h-100 d-flex flex-column">
          <svg viewBox="-55 -55 110 110" class="mb-2"><Wheel :rim="r" :tire="tires[0]" /></svg>
          <h3 class="h6">{{ r.name }}</h3>
          <p class="text-red fw-semibold mb-3">{{ fmt(r.price) }}</p>
          <router-link :to="`/rin/${r.id}`" class="btn btn-outline-light btn-sm mb-2 mt-auto">Personalizar</router-link>
          <button class="btn btn-red btn-sm" @click="add(r)">Agregar al carrito</button>
        </div>
      </div>
    </div>
  </section>

  <section class="container py-4">
    <h2 class="mb-4">Categorías de productos</h2>
    <div class="row g-3">
      <div v-for="c in cats" :key="c[0]" class="col-6 col-lg-3">
        <router-link :to="c[2]" class="panel p-4 d-block h-100 text-decoration-none text-white">
          <h3 class="h5">{{ c[0] }}</h3><p class="small text-secondary mb-0">{{ c[1] }}</p>
        </router-link>
      </div>
    </div>
  </section>

  <section class="container py-4">
    <h2 class="mb-4">¿Por qué elegir AutoRim?</h2>
    <div class="row g-3">
      <div v-for="w in why" :key="w[0]" class="col-md-4"><div class="panel p-4 h-100"><h3 class="h5 text-red">{{ w[0] }}</h3><p class="text-secondary mb-0">{{ w[1] }}</p></div></div>
    </div>
  </section>

  <section class="container py-4">
    <div class="panel p-5 text-center">
      <h2>Cotiza tu set completo</h2>
      <p class="text-secondary">Escoge tu auto y arma rines y llantas en minutos.</p>
      <router-link to="/autos" class="btn btn-red btn-lg">Elegir mi auto</router-link>
    </div>
  </section>
</template>
