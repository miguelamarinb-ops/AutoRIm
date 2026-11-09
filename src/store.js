import { reactive, computed, watch } from 'vue'

export const fmt = n => new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP', maximumFractionDigits: 0 }).format(n)

export const colors = [
  { name: 'Gris plata', hex: '#c9cad0' }, { name: 'Negro mate', hex: '#1b1b1f' },
  { name: 'Rojo racing', hex: '#c81e3a' }, { name: 'Azul eléctrico', hex: '#2255d8' },
  { name: 'Verde viper', hex: '#6fae1c' }, { name: 'Blanco perla', hex: '#f0f0f0' },
]
export const cars = [
  { id: 1, brand: 'Vektra', name: 'Vektra Aero GT', body: 'gt', color: '#c81e3a' },
  { id: 2, brand: 'Vektra', name: 'Vektra Rapt R', body: 'coupe', color: '#2255d8' },
  { id: 3, brand: 'Zenor', name: 'Zenor Stallion V8', body: 'muscle', color: '#1b1b1f' },
  { id: 4, brand: 'Zenor', name: 'Zenor Blitz', body: 'coupe', color: '#6fae1c' },
  { id: 5, brand: 'Kairo', name: 'Kairo Ridge X', body: 'suv', color: '#c9cad0' },
  { id: 6, brand: 'Kairo', name: 'Kairo Phantom GT', body: 'gt', color: '#f0f0f0' },
  { id: 7, brand: 'Draven', name: 'Draven Titan', body: 'suv', color: '#1b1b1f' },
  { id: 8, brand: 'Draven', name: 'Draven Havoc', body: 'muscle', color: '#c81e3a' },
]
export const rims = [
  { id: 1, name: 'Apex R5', style: 'five', finish: '#c9ccd1', price: 1890000 },
  { id: 2, name: 'Vortex Mesh', style: 'mesh', finish: '#d4af37', price: 2350000 },
  { id: 3, name: 'Turbo X', style: 'turbine', finish: '#2b2b32', price: 2100000 },
  { id: 4, name: 'Slim 14', style: 'multi', finish: '#b9bcc4', price: 1650000 },
]
export const tires = [
  { id: 'sport', name: 'Deportiva', R: 46, rimR: 35, price: 1200000 },
  { id: 'off', name: 'Off-road', R: 50, rimR: 30, price: 1450000 },
  { id: 'pre', name: 'Premium touring', R: 48, rimR: 33, price: 1350000 },
]
export const finishes = [
  { name: 'Plata', hex: '#c9ccd1' }, { name: 'Negro', hex: '#2b2b32' }, { name: 'Oro', hex: '#d4af37' },
  { name: 'Bronce', hex: '#a0703c' }, { name: 'Blanco', hex: '#f0f0f0' },
]
export const sizes = [{ l: '17"', f: 1 }, { l: '18"', f: 1.1 }, { l: '19"', f: 1.25 }, { l: '20"', f: 1.4 }]
export const tireSizes = [
  { l: '225/45 R17', f: 1 }, { l: '245/40 R18', f: 1.1 }, { l: '265/35 R19', f: 1.25 }, { l: '275/30 R20', f: 1.4 },
]

const load = (k, d) => { try { return JSON.parse(localStorage.getItem(k)) ?? d } catch { return d } }
export const store = reactive({
  cart: load('ar_cart', []), users: load('ar_users', []), user: load('ar_user', null),
  orders: load('ar_orders', []), admin: load('ar_admin', false),
})
watch(() => store.cart, v => localStorage.setItem('ar_cart', JSON.stringify(v)), { deep: true })
watch(() => store.users, v => localStorage.setItem('ar_users', JSON.stringify(v)), { deep: true })
watch(() => store.orders, v => localStorage.setItem('ar_orders', JSON.stringify(v)), { deep: true })
watch(() => store.user, v => localStorage.setItem('ar_user', JSON.stringify(v)))
watch(() => store.admin, v => localStorage.setItem('ar_admin', JSON.stringify(v)))

export const cartCount = computed(() => store.cart.reduce((s, i) => s + i.qty, 0))
export const cartTotal = computed(() => store.cart.reduce((s, i) => s + i.price * i.qty, 0))
export const addToCart = item => store.cart.push({ ...item, uid: Date.now() + Math.random(), qty: 1 })
