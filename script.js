/* ---------- Datos de prueba (prototipo) ---------- */
const cars = [
  { id:1, name:'Porsche 911 Carrera', desc:'Deportivo icónico alemán', price:14500000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Porsche+911' },
  { id:2, name:'Audi R8 V10', desc:'Motor V10 aspirado naturalmente', price:16500000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Audi+R8' },
  { id:3, name:'Ford Mustang GT', desc:'Muscle car clásico americano', price:5800000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Mustang+GT' },
  { id:4, name:'Subaru WRX STI', desc:'Tracción integral de rally', price:4200000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Subaru+WRX' },
  { id:5, name:'Nissan GT-R Nismo', desc:'El "Godzilla" japonés', price:21500000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Nissan+GT-R' },
  { id:6, name:'Audi R8 Spyder', desc:'Versión convertible del R8', price:17500000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Audi+R8+Spyder' },
  { id:7, name:'Ford Mustang Shelby', desc:'Edición de alto rendimiento', price:7500000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=Shelby+GT500' },
  { id:8, name:'Subaru WRX Rally', desc:'Preparado para competencia', price:4800000, img:'https://placehold.co/600x400/1a1a1e/e2273f?text=WRX+Rally' },
];

const rines = [
  { id:1, name:'Model R-5', price:249000, img:'https://placehold.co/300x300/101014/e2273f?text=R-5' },
  { id:2, name:'GTR Performance', price:240000, img:'https://placehold.co/300x300/101014/e2273f?text=GTR' },
  { id:3, name:'Model R-5 Sport', price:299000, img:'https://placehold.co/300x300/101014/e2273f?text=R-5+S' },
  { id:4, name:'GTR Performance Pro', price:349000, img:'https://placehold.co/300x300/101014/e2273f?text=GTR+Pro' },
  { id:5, name:'Vortex X1', price:210000, img:'https://placehold.co/300x300/101014/e2273f?text=X1' },
  { id:6, name:'Vortex X1 Black', price:225000, img:'https://placehold.co/300x300/101014/e2273f?text=X1+B' },
  { id:7, name:'Apex Carbon', price:399000, img:'https://placehold.co/300x300/101014/e2273f?text=Apex' },
  { id:8, name:'Apex Carbon Pro', price:429000, img:'https://placehold.co/300x300/101014/e2273f?text=Apex+Pro' },
  { id:9, name:'Storm Racing', price:189000, img:'https://placehold.co/300x300/101014/e2273f?text=Storm' },
];

const colors = [
  { name:'Gris Plata', hex:'#c9cad0' },
  { name:'Negro Mate', hex:'#1b1b1f' },
  { name:'Rojo Racing', hex:'#c81e3a' },
  { name:'Azul Eléctrico', hex:'#2255d8' },
  { name:'Blanco Perla', hex:'#f0f0f0' },
];

const FEATURED_CAR_ID = 5;

/* ---------- Estado global ---------- */
const state = {
  cart: [],
  user: null,
  selectedCarId: cars[0].id,
  selectedColor: colors[0].hex,
  selectedRimId: null,
};
let authMode = 'login';

/* ---------- Helpers ---------- */
const formatPrice = (n) => '$' + n.toLocaleString('en-US');
const findCar = (id) => cars.find(c => c.id === Number(id));
const findRim = (id) => rines.find(r => r.id === Number(id));
const colorName = (hex) => (colors.find(c => c.hex === hex) || {}).name || '';

/* ---------- Navegación entre vistas ---------- */
function showView(name){
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  document.getElementById('view-' + name).classList.add('active');
  document.querySelectorAll('.nav-link-custom').forEach(l => {
    const isActive = l.dataset.view === name;
    l.classList.toggle('active', isActive);
    l.classList.toggle('text-secondary', !isActive);
  });
  window.scrollTo({ top:0, behavior:'smooth' });
}

/* ---------- HOME ---------- */
function renderFeaturedCar(){
  const car = findCar(FEATURED_CAR_ID);
  document.getElementById('featuredCarImg').src = car.img;
  document.getElementById('featuredCarName').textContent = car.name;
}

function renderPricingPanel(){
  const grid = document.getElementById('pricingGrid');
  grid.innerHTML = rines.slice(0, 4).map(r => `
    <div class="col-6">
      <div class="bg-surface-2 border border-custom rounded-3 p-2 text-center position-relative h-100">
        <span class="position-absolute top-0 end-0 bg-danger text-white rounded px-2 py-1 m-1" style="font-size:0.65rem;">${formatPrice(r.price)}</span>
        <img src="${r.img}" class="rounded-circle object-fit-cover my-2" style="width:60px; height:60px;" alt="${r.name}">
        <p class="small fw-semibold mb-2 text-truncate">${r.name}</p>
        <button class="btn btn-sm btn-outline-light w-100 py-0" style="font-size:0.75rem;" onclick="showView('catalogo-rines')">Ver Detalles</button>
      </div>
    </div>
  `).join('');
}

function renderHomeCars(){
  const grid = document.getElementById('homeCarsGrid');
  grid.innerHTML = cars.slice(0, 8).map(c => `
    <div class="col-6 col-md-3">
      <div class="bg-surface border border-custom rounded-3 overflow-hidden cursor-pointer" onclick="openPersonalizar(${c.id})">
        <img src="${c.img}" class="w-100 object-fit-cover" style="height:120px;" alt="${c.name}">
        <p class="p-2 m-0 small fw-semibold text-truncate">${c.name}</p>
      </div>
    </div>
  `).join('');
}

/* ---------- CATALOGO DE CARROS ---------- */
function renderCarsCatalog(){
  const grid = document.getElementById('carsGrid');
  grid.innerHTML = cars.map(c => `
    <div class="col-md-4">
      <div class="bg-surface border border-custom rounded-4 overflow-hidden h-100 d-flex flex-column justify-content-between">
        <img src="${c.img}" class="w-100 object-fit-cover" style="height:180px;" alt="${c.name}">
        <div class="p-3 d-flex flex-column flex-grow-1 justify-content-between">
          <div>
            <h3 class="fs-5 mb-1">${c.name}</h3>
            <p class="small text-secondary mb-3">${c.desc}</p>
          </div>
          <button class="btn btn-outline-red w-100 fw-semibold" onclick="openPersonalizar(${c.id})">Personalizar</button>
        </div>
      </div>
    </div>
  `).join('');
}

/* ---------- CATALOGO DE RINES ---------- */
function renderRinesCatalog(){
  const grid = document.getElementById('rinesGrid');
  grid.innerHTML = rines.map(r => `
    <div class="col-md-4">
      <div class="bg-surface border border-custom rounded-4 p-3 text-center h-100 d-flex flex-column justify-content-between">
        <div>
          <img src="${r.img}" class="rounded-circle object-fit-cover mb-3" style="width:120px; height:120px;" alt="${r.name}">
          <h4 class="fs-5 mb-1">${r.name}</h4>
          <p class="text-red fw-semibold mb-3">${formatPrice(r.price)}</p>
        </div>
        <button class="btn btn-red w-100 fw-semibold" onclick="addRimToCart(${r.id})">Agregar al Carrito</button>
      </div>
    </div>
  `).join('');
}

/* ---------- PERSONALIZAR ---------- */
function openPersonalizar(carId){
  state.selectedCarId = Number(carId);
  state.selectedRimId = null;
  showView('personalizar');
  renderPersonalizar();
}

function renderPersonalizar(){
  const car = findCar(state.selectedCarId);

  const select = document.getElementById('personalizeCarSelect');
  select.innerHTML = cars.map(c => `<option value="${c.id}" ${c.id === car.id ? 'selected' : ''}>${c.name}</option>`).join('');

  document.getElementById('personalizeCarImg').src = car.img;

  document.getElementById('colorSwatches').innerHTML = colors.map(c => `
    <div class="swatch ${c.hex === state.selectedColor ? 'active' : ''}"
         style="background:${c.hex}" title="${c.name}"
         onclick="selectColor('${c.hex}')"></div>
  `).join('');

  document.getElementById('rimOptions').innerHTML = rines.map(r => `
    <div class="col-4">
      <div class="rim-option ${r.id === state.selectedRimId ? 'active' : ''}" onclick="selectRim(${r.id})">
        <img src="${r.img}" class="rounded-circle object-fit-cover mb-1" style="width:40px; height:40px;" alt="${r.name}">
        <div class="text-truncate">${r.name}</div>
      </div>
    </div>
  `).join('');

  const rim = findRim(state.selectedRimId);
  const total = car.price + (rim ? rim.price : 0);
  document.getElementById('personalizeSummary').innerHTML = `
    <p class="fw-bold text-white mb-1">${car.name}</p>
    <p class="mb-1">Color: ${colorName(state.selectedColor)}</p>
    <p class="mb-1">Rines: ${rim ? rim.name : 'Sin seleccionar'}</p>
    <p class="text-red fw-semibold mt-2 mb-0">Total: ${formatPrice(total)}</p>
  `;
}

function changePersonalizeCar(id){
  state.selectedCarId = Number(id);
  state.selectedRimId = null;
  renderPersonalizar();
}
function selectColor(hex){ state.selectedColor = hex; renderPersonalizar(); }
function selectRim(id){ state.selectedRimId = Number(id); renderPersonalizar(); }

function addPersonalizadoToCart(){
  if (!state.selectedRimId){
    alert('Selecciona unos rines antes de continuar');
    return;
  }
  const car = findCar(state.selectedCarId);
  const rim = findRim(state.selectedRimId);
  state.cart.push({
    key: Date.now(),
    name: `${car.name} + ${rim.name}`,
    detail: `Color: ${colorName(state.selectedColor)} · Rines: ${rim.name}`,
    price: car.price + rim.price,
    img: car.img,
    qty: 1,
  });
  updateCartBadge();
  showView('carrito');
  renderCart();
}

function addRimToCart(id){
  const rim = findRim(id);
  state.cart.push({
    key: Date.now(),
    name: rim.name,
    detail: 'Set de rines',
    price: rim.price,
    img: rim.img,
    qty: 1,
  });
  updateCartBadge();
}

/* ---------- CARRITO ---------- */
function updateCartBadge(){
  const badge = document.getElementById('cartBadge');
  const count = state.cart.reduce((s, i) => s + i.qty, 0);
  badge.textContent = count;
  badge.style.display = count > 0 ? 'inline-block' : 'none';
}

function cartTotal(){
  return state.cart.reduce((s, i) => s + i.price * i.qty, 0);
}

function renderCart(){
  const container = document.getElementById('cartItems');
  if (state.cart.length === 0){
    container.innerHTML = '<p class="text-secondary text-center py-5 m-0">Tu carrito está vacío.</p>';
  } else {
    container.innerHTML = state.cart.map((item, i) => `
      <div class="bg-surface border border-custom rounded-3 p-3 d-flex align-items-center gap-3">
        <img src="${item.img}" class="rounded-2 object-fit-cover" style="width:70px; height:70px;" alt="${item.name}">
        <div class="flex-grow-1">
          <h4 class="fs-6 mb-1">${item.name}</h4>
          <p class="small text-secondary m-0">${item.detail}</p>
        </div>
        <div class="d-flex align-items-center gap-2">
          <button class="btn btn-sm btn-outline-light px-2 py-0" onclick="changeQty(${i}, -1)">−</button>
          <span>${item.qty}</span>
          <button class="btn btn-sm btn-outline-light px-2 py-0" onclick="changeQty(${i}, 1)">+</button>
        </div>
        <p class="m-0 fw-semibold">${formatPrice(item.price * item.qty)}</p>
        <button class="btn btn-sm text-danger" onclick="removeItem(${i})">Eliminar</button>
      </div>
    `).join('');
  }
  document.getElementById('cartTotal').textContent = formatPrice(cartTotal());
}

function changeQty(index, delta){
  state.cart[index].qty = Math.max(1, state.cart[index].qty + delta);
  renderCart();
  updateCartBadge();
}
function removeItem(index){
  state.cart.splice(index, 1);
  renderCart();
  updateCartBadge();
}

function goToPayment(){
  if (state.cart.length === 0){
    alert('Agrega productos a tu carrito antes de pagar');
    return;
  }
  renderPaymentSummary();
  showView('pago');
}

/* ---------- PAGO ---------- */
function renderPaymentSummary(){
  document.getElementById('paymentSummaryList').innerHTML = state.cart.map(item => `
    <div class="d-flex justify-content-between small text-secondary">
      <span>${item.name} x${item.qty}</span>
      <span>${formatPrice(item.price * item.qty)}</span>
    </div>
  `).join('');
  document.getElementById('paymentTotal').textContent = formatPrice(cartTotal());
}

function handlePaymentSubmit(e){
  e.preventDefault();
  document.getElementById('paymentLayout').style.display = 'none';
  document.getElementById('paymentSuccess').style.display = 'block';
  state.cart = [];
  updateCartBadge();
}

function backToHomeAfterPayment(){
  document.getElementById('paymentForm').reset();
  document.getElementById('paymentLayout').style.display = 'flex';
  document.getElementById('paymentSuccess').style.display = 'none';
  showView('home');
}

/* ---------- AUTENTICACIÓN ---------- */
function setAuthMode(mode){
  authMode = mode;
  const isRegistro = mode === 'registro';
  document.getElementById('authTitle').textContent = isRegistro ? 'Crear Cuenta' : 'Iniciar Sesión';
  document.getElementById('confirmPasswordGroup').style.display = isRegistro ? 'block' : 'none';
  document.getElementById('termsGroup').style.display = isRegistro ? 'block' : 'none';
  document.getElementById('authSubmitBtn').textContent = isRegistro ? 'Registrarme' : 'Iniciar Sesión';
  
  const tabLogin = document.getElementById('tabLogin');
  const tabRegistro = document.getElementById('tabRegistro');
  
  tabLogin.classList.toggle('active', !isRegistro);
  tabLogin.classList.toggle('text-secondary', isRegistro);
  tabRegistro.classList.toggle('active', isRegistro);
  tabRegistro.classList.toggle('text-secondary', !isRegistro);
}

function handleAuthSubmit(e){
  e.preventDefault();
  const email = document.getElementById('authEmail').value.trim();
  if (!email) return;

  if (authMode === 'registro' && !document.getElementById('termsCheck').checked){
    alert('Debes aceptar los términos y condiciones');
    return;
  }

  state.user = { name: email.split('@')[0] };
  updateAuthUI();
  e.target.reset();
  showView('home');
}

function updateAuthUI(){
  const btn = document.getElementById('navUserBtn');
  btn.textContent = state.user ? `👤 ${state.user.name}` : '👤 Ingresar';
}

function handleUserIconClick(){
  if (state.user){
    if (confirm('¿Cerrar sesión?')){
      state.user = null;
      updateAuthUI();
    }
  } else {
    showView('login');
  }
}

/* ---------- Inicialización ---------- */
document.addEventListener('DOMContentLoaded', () => {
  renderFeaturedCar();
  renderPricingPanel();
  renderHomeCars();
  renderCarsCatalog();
  renderRinesCatalog();
  renderPersonalizar();
  updateCartBadge();
  renderCart();
  setAuthMode('login');
});