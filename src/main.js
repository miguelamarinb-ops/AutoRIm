import { createApp } from 'vue'
import { createRouter, createWebHashHistory } from 'vue-router'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import './style.css'
import App from './App.vue'

const routes = [
  { path: '/', component: () => import('./views/HomeView.vue') },
  { path: '/login', component: () => import('./views/LoginView.vue') },
  { path: '/autos', component: () => import('./views/CatalogView.vue') },
  { path: '/personalizar/:id', component: () => import('./views/CustomizeView.vue') },
  { path: '/rin/:id', component: () => import('./views/RimView.vue') },
  { path: '/llanta/:id', component: () => import('./views/TireView.vue') },
  { path: '/carrito', component: () => import('./views/CartView.vue') },
  { path: '/pago', component: () => import('./views/PaymentView.vue') },
  { path: '/admin', component: () => import('./views/AdminView.vue') },
]

createApp(App)
  .use(createRouter({ history: createWebHashHistory(), routes, scrollBehavior: () => ({ top: 0 }) }))
  .mount('#app')
