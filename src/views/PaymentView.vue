<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { store, cartTotal, fmt } from '../store'

const router = useRouter()
const SHIPPING = 25000
const total = computed(() => cartTotal.value + SHIPPING)
const f = ref({ name: '', address: '', city: '', state: '', phone: '', card: '', holder: '', exp: '', cvv: '' })
const orderId = ref('')

onMounted(() => { if (!store.user) router.replace('/login') })

const fmtCard = () => (f.value.card = f.value.card.replace(/\D/g, '').slice(0, 16).replace(/(.{4})/g, '$1 ').trim())
const fmtExp = () => {
  const d = f.value.exp.replace(/\D/g, '').slice(0, 4)
  f.value.exp = d.length > 2 ? d.slice(0, 2) + '/' + d.slice(2) : d
}

function pay() {
  orderId.value = 'AR-' + Date.now().toString().slice(-6)
  // Nunca guardes datos de tarjeta: solo el resumen del pedido
  store.orders.push({
    id: orderId.value, date: new Date().toLocaleString('es-CO'), email: store.user.email,
    ship: `${f.value.address}, ${f.value.city}`, total: total.value,
    items: store.cart.map(i => `${i.name} x${i.qty}`),
  })
  store.cart = []
}
</script>

<template>
  <div class="container py-5">
    <h1 class="mb-4">Pasarela de pagos</h1>

    <div v-if="orderId" class="panel p-5 text-center">
      <h2 class="text-red">¡Pago exitoso!</h2>
      <p class="text-secondary">Tu pedido <strong class="text-white">{{ orderId }}</strong> quedó registrado. Te contactaremos para coordinar el envío.</p>
      <router-link to="/" class="btn btn-red">Volver al inicio</router-link>
    </div>

    <div v-else-if="!store.cart.length" class="panel p-5 text-center">
      <p class="text-secondary">No hay productos en tu carrito.</p>
      <router-link to="/autos" class="btn btn-red">Personalizar un auto</router-link>
    </div>

    <form v-else class="row g-4" @submit.prevent="pay">
      <div class="col-lg-7 d-grid gap-4">
        <section class="panel p-4">
          <h2 class="h5 mb-3">1. Dirección de envío</h2>
          <div class="row g-3">
            <div class="col-12"><label class="form-label small" for="n">Nombre completo</label><input id="n" v-model="f.name" class="form-control" autocomplete="name" required /></div>
            <div class="col-12"><label class="form-label small" for="a">Dirección</label><input id="a" v-model="f.address" class="form-control" autocomplete="street-address" required /></div>
            <div class="col-md-6"><label class="form-label small" for="c">Ciudad</label><input id="c" v-model="f.city" class="form-control" required /></div>
            <div class="col-md-6"><label class="form-label small" for="s">Departamento</label><input id="s" v-model="f.state" class="form-control" required /></div>
            <div class="col-12"><label class="form-label small" for="p">Teléfono</label><input id="p" v-model="f.phone" type="tel" class="form-control" autocomplete="tel" required /></div>
          </div>
        </section>

        <section class="panel p-4">
          <h2 class="h5 mb-3">2. Información de pago</h2>
          <div class="row g-3">
            <div class="col-12"><label class="form-label small" for="cd">Número de tarjeta</label><input id="cd" v-model="f.card" @input="fmtCard" class="form-control" inputmode="numeric" autocomplete="cc-number" placeholder="0000 0000 0000 0000" minlength="19" required /></div>
            <div class="col-12"><label class="form-label small" for="h">Nombre en la tarjeta</label><input id="h" v-model="f.holder" class="form-control" autocomplete="cc-name" required /></div>
            <div class="col-6"><label class="form-label small" for="e">Vencimiento</label><input id="e" v-model="f.exp" @input="fmtExp" class="form-control" placeholder="MM/AA" pattern="(0[1-9]|1[0-2])/[0-9]{2}" autocomplete="cc-exp" required /></div>
            <div class="col-6"><label class="form-label small" for="v">CVV</label><input id="v" v-model="f.cvv" class="form-control" inputmode="numeric" pattern="[0-9]{3,4}" maxlength="4" autocomplete="cc-csc" required /></div>
          </div>
        </section>
      </div>

      <div class="col-lg-5">
        <aside class="panel p-4 sticky-top" style="top:90px">
          <h2 class="h5 mb-3">Resumen del pedido</h2>
          <div v-for="i in store.cart" :key="i.uid" class="d-flex justify-content-between small mb-2">
            <span class="text-secondary">{{ i.name }} ×{{ i.qty }}</span><span>{{ fmt(i.price * i.qty) }}</span>
          </div>
          <div class="border-top pt-3 mt-3 small" style="border-color:var(--line)!important">
            <div class="d-flex justify-content-between mb-1"><span class="text-secondary">Subtotal</span><span>{{ fmt(cartTotal) }}</span></div>
            <div class="d-flex justify-content-between"><span class="text-secondary">Envío</span><span>{{ fmt(SHIPPING) }}</span></div>
          </div>
          <div class="d-flex justify-content-between align-items-baseline my-3">
            <span>Total</span><strong class="fs-4 text-red">{{ fmt(total) }}</strong>
          </div>
          <button class="btn btn-red w-100">Confirmar pago</button>
        </aside>
      </div>
    </form>
  </div>
</template>
