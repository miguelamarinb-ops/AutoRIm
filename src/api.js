// Cliente HTTP para la API (server/index.js). Los tokens viven en localStorage:
// uno para el cliente y otro para el panel de administración.
const KEYS = { user: 'ar_token', admin: 'ar_admin_token' }
const API_BASE = (import.meta.env.VITE_API_URL || '').replace(/\/$/, '')

export const setToken = (kind, value) => {
  try { value ? localStorage.setItem(KEYS[kind], value) : localStorage.removeItem(KEYS[kind]) } catch {}
}
const getToken = kind => { try { return localStorage.getItem(KEYS[kind]) } catch { return null } }

export async function api(path, { method = 'GET', body, admin = false } = {}) {
  const token = getToken(admin ? 'admin' : 'user')
  let res
  try {
    res = await fetch(`${API_BASE}/api${path}`, {
      method,
      headers: { ...(body && { 'Content-Type': 'application/json' }), ...(token && { Authorization: `Bearer ${token}` }) },
      body: body && JSON.stringify(body),
    })
  } catch {
    throw Object.assign(new Error('No se pudo conectar con el servidor.'), { status: 0 })
  }
  const data = await res.json().catch(() => ({}))
  if (!res.ok) throw Object.assign(new Error(data.error || 'Error del servidor.'), { status: res.status, code: data.code })
  return data
}