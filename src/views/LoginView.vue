<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { store } from '../store'
const router = useRouter()
const mode = ref('login') // login | register | notfound
const f = ref({ email: '', password: '', confirm: '' })
const error = ref('')

function submit() {
  error.value = ''
  const email = f.value.email.trim().toLowerCase()
  if (mode.value === 'login') {
    const u = store.users.find(u => u.email === email)
    if (!u) { mode.value = 'notfound'; return }
    if (u.password !== f.value.password) { error.value = 'La contraseña no es correcta.'; return }
  } else {
    if (f.value.password !== f.value.confirm) { error.value = 'Las contraseñas no coinciden.'; return }
    if (store.users.some(u => u.email === email)) { error.value = 'Ese correo ya tiene una cuenta.'; return }
    store.users.push({ email, password: f.value.password }) // solo demo
  }
  store.user = { email }
  router.push('/')
}
</script>

<template>
  <div class="container py-5" style="max-width:440px">
    <div v-if="mode === 'notfound'" class="panel p-4 text-center">
      <h1 class="h3">Cuenta no encontrada</h1>
      <p class="text-secondary">No hay una cuenta con <strong>{{ f.email }}</strong>. Crea una o revisa el correo.</p>
      <button class="btn btn-red w-100 mb-2" @click="mode = 'register'">Crear cuenta</button>
      <button class="btn btn-outline-light w-100" @click="mode = 'login'">Probar otro correo</button>
    </div>

    <div v-else class="panel p-4">
      <div class="nav nav-pills nav-fill mb-3">
        <button class="nav-link" :class="{ active: mode === 'login' }" @click="mode = 'login'">Ingresar</button>
        <button class="nav-link" :class="{ active: mode === 'register' }" @click="mode = 'register'">Registrarme</button>
      </div>
      <h1 class="h3 mb-3">{{ mode === 'login' ? 'Ingresa a tu cuenta' : 'Crea tu cuenta' }}</h1>
      <div v-if="error" class="alert alert-danger py-2 small">{{ error }}</div>
      <form class="d-grid gap-3" @submit.prevent="submit">
        <div><label class="form-label small" for="em">Correo</label><input id="em" v-model="f.email" type="email" class="form-control" required /></div>
        <div><label class="form-label small" for="pw">Contraseña</label><input id="pw" v-model="f.password" type="password" minlength="6" class="form-control" required /></div>
        <div v-if="mode === 'register'"><label class="form-label small" for="cf">Confirmar contraseña</label><input id="cf" v-model="f.confirm" type="password" class="form-control" required /></div>
        <button class="btn btn-red">{{ mode === 'login' ? 'Ingresar' : 'Crear cuenta' }}</button>
      </form>
    </div>
  </div>
</template>
