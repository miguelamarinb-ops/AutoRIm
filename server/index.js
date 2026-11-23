import 'dotenv/config'
import express from 'express'
import bcrypt from 'bcryptjs'
import { existsSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { pool, transaccion } from './db.js'
import adminRouter from './admin.js'
import { HttpError, checkConfig, firmar, requiere, limitarLogin } from './auth.js'

checkConfig()
const app = express()
app.disable('x-powered-by')
app.set('trust proxy', 1)
app.use(express.json({ limit: '50kb' }))

// Permitir peticiones desde el frontend en Render (CORS)
app.use((req, res, next) => {
  const origin = process.env.CORS_ORIGIN || '*'
  res.setHeader('Access-Control-Allow-Origin', origin)
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
  if (req.method === 'OPTIONS') return res.sendStatus(204)
  next()
})

const ah = fn => (req, res, next) => fn(req, res, next).catch(next)

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const DUMMY_HASH = bcrypt.hashSync('relleno-para-igualar-tiempos', 10)

// ---------------------------------------------------------------- Catálogo
app.get('/api/catalogo', ah(async (_req, res) => {
  const q = async sql => (await pool.query(sql))[0]
  res.json({
    autos: await q('SELECT id, marca, nombre, carroceria, color_base FROM MB_DG_AUTOS WHERE activo ORDER BY id'),
    colores: await q('SELECT id, nombre, hex FROM MB_DG_COLORES ORDER BY id'),
    acabados: await q('SELECT id, nombre, hex FROM MB_DG_ACABADOS ORDER BY id'),
    rines: await q('SELECT id, nombre, estilo, acabado_base, precio FROM MB_DG_RINES WHERE activo ORDER BY id'),
    llantas: await q('SELECT id, codigo, nombre, svg_radio, svg_radio_rin, precio FROM MB_DG_LLANTAS WHERE activo ORDER BY id'),
    medidas: await q('SELECT id, tipo, etiqueta, factor FROM MB_DG_MEDIDAS ORDER BY tipo, factor'),
  })
}))

// ---------------------------------------------------------------- Autenticación
app.post('/api/auth/register', limitarLogin, ah(async (req, res) => {
  const email = String(req.body.email ?? '').trim().toLowerCase()
  const password = String(req.body.password ?? '')
  if (!EMAIL_RE.test(email) || email.length > 190) throw new HttpError(400, 'Correo no válido.')
  if (password.length < 6 || password.length > 72) throw new HttpError(400, 'La contraseña debe tener entre 6 y 72 caracteres.')
  try {
    const hash = await bcrypt.hash(password, 10)
    const [r] = await pool.query('INSERT INTO MB_DG_USUARIOS (email, password_hash) VALUES (?, ?)', [email, hash])
    const u = { id: r.insertId, rol: 'cliente' }
    res.status(201).json({ token: firmar(u, '7d'), user: { email, rol: u.rol } })
  } catch (e) {
    if (e.code === 'ER_DUP_ENTRY') throw new HttpError(409, 'Ese correo ya tiene una cuenta.')
    throw e
  }
}))

app.post('/api/auth/login', limitarLogin, ah(async (req, res) => {
  const email = String(req.body.email ?? '').trim().toLowerCase()
  const password = String(req.body.password ?? '')
  const [[u]] = await pool.query('SELECT id, email, password_hash, rol FROM MB_DG_USUARIOS WHERE email = ?', [email])
  if (!u) { req.fallo(); throw new HttpError(404, 'Cuenta no encontrada.', { code: 'no_account' }) }
  if (!(await bcrypt.compare(password, u.password_hash))) { req.fallo(); throw new HttpError(401, 'La contraseña no es correcta.') }
  req.exito()
  res.json({ token: firmar(u, '7d'), user: { email: u.email, rol: u.rol } })
}))

app.post('/api/auth/admin-login', limitarLogin, ah(async (req, res) => {
  const email = String(req.body.email ?? '').trim().toLowerCase()
  const password = String(req.body.password ?? '')
  const code = String(req.body.code ?? '')
  const [[u]] = await pool.query(
    "SELECT id, email, password_hash, codigo_acceso_hash, rol FROM MB_DG_USUARIOS WHERE email = ? AND rol = 'admin'", [email])
  // Se comparan siempre ambos hashes (aunque no exista el usuario) para no revelar nada por tiempo ni por mensaje.
  const okPass = await bcrypt.compare(password, u?.password_hash ?? DUMMY_HASH)
  const okCode = await bcrypt.compare(code, u?.codigo_acceso_hash ?? DUMMY_HASH)
  if (!u || !okPass || !okCode) { req.fallo(); throw new HttpError(401, 'Correo, contraseña o código incorrectos.') }
  req.exito()
  res.json({ token: firmar(u, '8h'), user: { email: u.email, rol: u.rol } })
}))

// ---------------------------------------------------------------- Pedidos
const ANCHOS = ['7.5J', '8.5J', '9.5J']
const COSTO_ENVIO = 25000
const redondear = n => Math.round(n / 1000) * 1000
const p = v => v ?? null
const pid = v => (Number.isInteger(v) ? v : null)

async function uno(conn, sql, params, msg) {
  const [[row]] = await conn.query(sql, params)
  if (!row) throw new HttpError(400, msg)
  return row
}

// Reconstruye el producto desde la base: el cliente solo manda ids, el nombre,
// el detalle y el precio salen siempre de aquí (no se puede manipular el precio).
async function construirConfiguracion(conn, cfg) {
  if (!cfg || typeof cfg !== 'object') throw new HttpError(400, 'Producto no válido.')
  if (cfg.tipo === 'kit') {
    const auto = await uno(conn, 'SELECT id, nombre FROM MB_DG_AUTOS WHERE id = ? AND activo', [pid(cfg.autoId)], 'Auto no disponible.')
    const rin = await uno(conn, 'SELECT id, nombre, precio FROM MB_DG_RINES WHERE id = ? AND activo', [pid(cfg.rinId)], 'Rin no disponible.')
    const llanta = await uno(conn, 'SELECT id, nombre, precio FROM MB_DG_LLANTAS WHERE id = ? AND activo', [pid(cfg.llantaId)], 'Llanta no disponible.')
    const color = cfg.colorId == null ? null
      : await uno(conn, 'SELECT id, nombre FROM MB_DG_COLORES WHERE id = ?', [pid(cfg.colorId)], 'Color no disponible.')
    return {
      tipo: 'kit', nombre: auto.nombre,
      detalle: `${color?.nombre ?? 'Color base'} · ${rin.nombre} · ${llanta.nombre}`,
      precio_unitario: rin.precio + llanta.precio,
      auto_id: auto.id, color_id: color?.id ?? null, rin_id: rin.id, llanta_id: llanta.id,
    }
  }
  if (cfg.tipo === 'rines') {
    const rin = await uno(conn, 'SELECT id, nombre, precio FROM MB_DG_RINES WHERE id = ? AND activo', [pid(cfg.rinId)], 'Rin no disponible.')
    const medida = await uno(conn, "SELECT id, etiqueta, factor FROM MB_DG_MEDIDAS WHERE id = ? AND tipo = 'rin'", [pid(cfg.medidaRinId)], 'Medida de rin no válida.')
    if (!ANCHOS.includes(cfg.ancho)) throw new HttpError(400, 'Ancho de rin no válido.')
    const acabado = cfg.acabadoId == null ? null
      : await uno(conn, 'SELECT id, nombre FROM MB_DG_ACABADOS WHERE id = ?', [pid(cfg.acabadoId)], 'Acabado no disponible.')
    return {
      tipo: 'rines', nombre: rin.nombre,
      detalle: `Set de 4 · ${acabado?.nombre ?? 'Original'} · ${medida.etiqueta} · ${cfg.ancho}`,
      precio_unitario: redondear(rin.precio * Number(medida.factor)),
      rin_id: rin.id, acabado_id: acabado?.id ?? null, medida_rin_id: medida.id, ancho_rin: cfg.ancho,
    }
  }
  if (cfg.tipo === 'llantas') {
    const llanta = await uno(conn, 'SELECT id, nombre, precio FROM MB_DG_LLANTAS WHERE id = ? AND activo', [pid(cfg.llantaId)], 'Llanta no disponible.')
    const medida = await uno(conn, "SELECT id, etiqueta, factor FROM MB_DG_MEDIDAS WHERE id = ? AND tipo = 'llanta'", [pid(cfg.medidaLlantaId)], 'Medida de llanta no válida.')
    return {
      tipo: 'llantas', nombre: llanta.nombre, detalle: `Set de 4 · ${medida.etiqueta}`,
      precio_unitario: redondear(llanta.precio * Number(medida.factor)),
      llanta_id: llanta.id, medida_llanta_id: medida.id,
    }
  }
  throw new HttpError(400, 'Tipo de producto no válido.')
}

const COLS = ['tipo', 'nombre', 'detalle', 'precio_unitario', 'auto_id', 'color_id', 'rin_id', 'acabado_id',
  'medida_rin_id', 'ancho_rin', 'llanta_id', 'medida_llanta_id']

const texto = (v, max, campo) => {
  const s = String(v ?? '').trim()
  if (!s || s.length > max) throw new HttpError(400, `Revisa el campo ${campo}.`)
  return s
}

app.post('/api/pedidos', requiere(), ah(async (req, res) => {
  const { envio, items } = req.body ?? {}
  if (!envio || !Array.isArray(items) || items.length < 1 || items.length > 50) throw new HttpError(400, 'Pedido no válido.')
  const dir = {
    nombre: texto(envio.name, 120, 'nombre'), direccion: texto(envio.address, 200, 'dirección'),
    ciudad: texto(envio.city, 80, 'ciudad'), departamento: texto(envio.state, 80, 'departamento'),
    telefono: texto(envio.phone, 30, 'teléfono'),
  }
  // Solo llegan la marca y los últimos 4 dígitos; nunca el número completo ni el CVV.
  const ultimos4 = String(req.body.pago?.ultimos4 ?? '')
  const marca = String(req.body.pago?.marca ?? '')
  if (!/^[0-9]{4}$/.test(ultimos4) || !/^[a-z]{1,20}$/.test(marca)) throw new HttpError(400, 'Datos de pago no válidos.')

  const out = await transaccion(req.user.id, async conn => {
    const lineas = []
    for (const it of items) {
      const qty = it?.qty
      if (!Number.isInteger(qty) || qty < 1 || qty > 99) throw new HttpError(400, 'Cantidad no válida.')
      lineas.push({ cfg: await construirConfiguracion(conn, it.pedido), qty })
    }
    const subtotal = lineas.reduce((s, l) => s + l.cfg.precio_unitario * l.qty, 0)
    const total = subtotal + COSTO_ENVIO

    let pedidoId, codigo
    for (let i = 0; i < 5 && !pedidoId; i++) {
      codigo = 'AR-' + String(Math.floor(Math.random() * 1e6)).padStart(6, '0')
      try {
        // El pago es simulado en esta versión, por eso el pedido nace como 'pagado'.
        const [r] = await conn.query(
          `INSERT INTO MB_DG_PEDIDOS (codigo, usuario_id, nombre_completo, direccion, ciudad, departamento, telefono, subtotal, costo_envio, total, estado)
           VALUES (?,?,?,?,?,?,?,?,?,?, 'pagado')`,
          [codigo, req.user.id, dir.nombre, dir.direccion, dir.ciudad, dir.departamento, dir.telefono, subtotal, COSTO_ENVIO, total])
        pedidoId = r.insertId
      } catch (e) { if (e.code !== 'ER_DUP_ENTRY') throw e }
    }
    if (!pedidoId) throw new HttpError(500, 'No se pudo generar el código del pedido. Intenta de nuevo.')

    // Pago simulado (aprueba siempre). Con una pasarela real, aquí se guardaría su respuesta.
    await conn.query(
      `INSERT INTO MB_DG_PAGOS (pedido_id, pasarela, referencia_externa, estado, monto, metodo_tipo, marca, ultimos4)
       VALUES (?, 'simulada', ?, 'aprobado', ?, 'tarjeta', ?, ?)`,
      [pedidoId, `SIM-${codigo}`, total, marca, ultimos4])

    for (const { cfg, qty } of lineas) {
      const [c] = await conn.query(
        `INSERT INTO MB_DG_CONFIGURACIONES (${COLS.join(',')}) VALUES (${COLS.map(() => '?').join(',')})`,
        COLS.map(k => p(cfg[k])))
      await conn.query('INSERT INTO MB_DG_PEDIDO_ITEMS (pedido_id, configuracion_id, cantidad) VALUES (?,?,?)', [pedidoId, c.insertId, qty])
    }
    return { codigo, total }
  })

  res.status(201).json(out)
}))

// ---------------------------------------------------------------- Administración
app.get('/api/admin/resumen', requiere('admin'), ah(async (_req, res) => {
  const [[r]] = await pool.query('SELECT pedidos, clientes FROM MB_DG_V_RESUMEN_ADMIN')
  res.json(r)
}))
app.get('/api/admin/pedidos', requiere('admin'), ah(async (_req, res) => {
  const [rows] = await pool.query('SELECT pedido, fecha, cliente, productos, total, estado FROM MB_DG_V_PEDIDOS_ADMIN ORDER BY fecha DESC')
  res.json(rows)
}))

app.use('/api/admin', adminRouter) // CRUD de tablas y reporte de auditoría

const dist = fileURLToPath(new URL('../dist', import.meta.url))
if (existsSync(dist)) {
  app.use(express.static(dist))
  app.get(/^\/(?!api\/).*/, (_req, res) => res.sendFile(join(dist, 'index.html')))
}

// ---------------------------------------------------------------- Errores
app.use('/api', (_req, _res, next) => next(new HttpError(404, 'Ruta no encontrada.')))
app.use((err, _req, res, _next) => {
  if (err instanceof HttpError) return res.status(err.status).json({ error: err.message, ...err.extra })
  if (err.type === 'entity.too.large') return res.status(413).json({ error: 'Solicitud demasiado grande.' })
  if (err.type === 'entity.parse.failed') return res.status(400).json({ error: 'JSON no válido.' })
  console.error(err)
  res.status(500).json({ error: 'Error del servidor.' })
})

const port = Number(process.env.PORT) || 3001
const host = process.env.HOST || (process.env.RENDER ? '0.0.0.0' : '127.0.0.1')
app.listen(port, host, () => console.log(`API AutoRim en http://${host}:${port}`))