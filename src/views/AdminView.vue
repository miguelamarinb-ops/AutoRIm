<script setup>
import { ref } from 'vue'
import { store, fmt } from '../store'

// SOLO DEMO: en un sitio real la validación debe hacerse en un servidor
const ADMIN = { email: 'admin@autorim.com', password: 'admin123', code: 'AR-2026' }
const f = ref({ email: '', password: '', code: '' })
const error = ref('')

function login() {
  const ok = f.value.email.trim().toLowerCase() === ADMIN.email && f.value.password === ADMIN.password && f.value.code === ADMIN.code
  if (ok) { store.admin = true; error.value = '' } else error.value = 'Correo, contraseña o código incorrectos.'
}
</script>

<template>
  <div v-if="!store.admin" class="container py-5" style="max-width:440px">
    <div class="panel p-4">
      <h1 class="h3">Acceso de personal</h1>
      <p class="text-secondary small">Solo para administradores de AutoRim.</p>
      <div v-if="error" class="alert alert-danger py-2 small">{{ error }}</div>
      <form class="d-grid gap-3" @submit.prevent="login">
        <div><label class="form-label small" for="ae">Correo</label><input id="ae" v-model="f.email" type="email" class="form-control" required /></div>
        <div><label class="form-label small" for="ap">Contraseña</label><input id="ap" v-model="f.password" type="password" class="form-control" required /></div>
        <div><label class="form-label small" for="ac">Código de acceso</label><input id="ac" v-model="f.code" class="form-control" required /></div>
        <button class="btn btn-red">Ingresar como administrador</button>
      </form>
    </div>
  </div>

  <div v-else class="container py-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="mb-0">Panel de administración</h1>
      <button class="btn btn-outline-light btn-sm" @click="store.admin = false">Cerrar sesión</button>
    </div>
    <div class="row g-3 mb-4">
      <div class="col-6 col-md-3"><div class="panel p-3"><div class="text-secondary small">Pedidos</div><div class="fs-3">{{ store.orders.length }}</div></div></div>
      <div class="col-6 col-md-3"><div class="panel p-3"><div class="text-secondary small">Clientes</div><div class="fs-3">{{ store.users.length }}</div></div></div>
    </div>
    <div class="panel p-3 table-responsive">
      <table class="table align-middle mb-0">
        <thead><tr><th>Pedido</th><th>Fecha</th><th>Cliente</th><th>Productos</th><th class="text-end">Total</th></tr></thead>
        <tbody>
          <tr v-for="o in store.orders" :key="o.id">
            <td>{{ o.id }}</td><td>{{ o.date }}</td><td>{{ o.email }}</td>
            <td class="small text-secondary">{{ o.items.join(', ') }}</td><td class="text-end">{{ fmt(o.total) }}</td>
          </tr>
          <tr v-if="!store.orders.length"><td colspan="5" class="text-center text-secondary py-4">Todavía no hay pedidos.</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</template>
