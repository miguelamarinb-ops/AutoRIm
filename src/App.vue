<script setup>
import { store, cartCount } from './store'
</script>

<template>
  <nav class="navbar navbar-expand-lg sticky-top border-bottom" style="background:#0a0a0acc;backdrop-filter:blur(8px);border-color:var(--line)!important">
    <div class="container">
      <router-link to="/" class="brand">AUTO<span>RIM</span></router-link>
      <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav" aria-label="Menú"><span class="navbar-toggler-icon"></span></button>
      <div id="nav" class="collapse navbar-collapse">
        <ul class="navbar-nav me-auto">
          <li class="nav-item"><router-link class="nav-link text-secondary" to="/">Inicio</router-link></li>
          <li class="nav-item"><router-link class="nav-link text-secondary" to="/autos">Autos</router-link></li>
          <li class="nav-item"><router-link class="nav-link text-secondary" to="/rin/1">Rines</router-link></li>
          <li class="nav-item"><router-link class="nav-link text-secondary" to="/llanta/sport">Llantas</router-link></li>
        </ul>
        <div class="d-flex gap-2 align-items-center">
          <router-link v-if="!store.user" to="/login" class="btn btn-sm btn-outline-light">Ingresar</router-link>
          <button v-else class="btn btn-sm btn-outline-light" @click="store.user = null">{{ store.user.email.split('@')[0] }} · Salir</button>
          <router-link to="/carrito" class="btn btn-sm btn-red position-relative">
            Carrito <span v-if="cartCount" class="badge text-bg-light ms-1">{{ cartCount }}</span>
          </router-link>
        </div>
      </div>
    </div>
  </nav>

  <main><router-view /></main>

  <footer class="border-top mt-5 py-5" style="border-color:var(--line)!important">
    <div class="container row mx-auto g-4">
      <div class="col-md-5"><span class="brand">AUTO<span>RIM</span></span>
        <p class="text-secondary small mt-2">Rines y llantas para tu auto. Pruébalos antes de comprar.</p></div>
      <div class="col-6 col-md-3"><h5 class="h6">Catálogo</h5>
        <router-link to="/autos" class="d-block small text-secondary text-decoration-none">Autos compatibles</router-link>
        <router-link to="/rin/1" class="d-block small text-secondary text-decoration-none">Rines</router-link>
        <router-link to="/llanta/sport" class="d-block small text-secondary text-decoration-none">Llantas</router-link></div>
      <div class="col-6 col-md-4"><h5 class="h6">Contacto</h5>
        <p class="small text-secondary mb-1">email.infot@gmail.com<br>(411) 878-7855</p>
        <router-link to="/admin" class="small text-secondary text-decoration-none">Acceso personal</router-link></div>
    </div>
    <p class="text-center text-secondary small mt-4 mb-0">© 2026 AutoRim. Todos los derechos reservados.</p>
  </footer>
</template>
