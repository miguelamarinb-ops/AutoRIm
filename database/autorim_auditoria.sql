-- ============================================================
-- PROYECTO AUTORIM
-- VISTAS Y CONSULTAS PARA LA TABLA DE AUDITORIA
-- ============================================================
-- Ejecutar despues de la estructura, los triggers y la carga de datos.
-- MySQL no tiene bloques anonimos; la consulta se resuelve con vistas.
-- ============================================================

USE MB_DG_autorim;

-- ============================================================
-- 1. VISTA GENERAL: quien, cuando y que cambio
-- ============================================================
CREATE OR REPLACE VIEW MB_DG_V_AUDITORIA AS
SELECT
    a.id                AS auditoria_id,
    a.fecha             AS fecha_operacion,
    a.tabla             AS tabla_afectada,
    a.operacion,
    a.registro_id,
    a.usuario_app,
    u.email             AS usuario_app_email,
    a.usuario_bd,
    a.datos_anteriores,
    a.datos_nuevos
FROM MB_DG_AUDITORIA a
LEFT JOIN MB_DG_USUARIOS u
    ON u.id = a.usuario_app;

-- ============================================================
-- 2. VISTA RESUMEN: movimientos por tabla y operacion
-- ============================================================
CREATE OR REPLACE VIEW MB_DG_V_AUDITORIA_RESUMEN AS
SELECT
    tabla     AS tabla_afectada,
    operacion,
    COUNT(*)  AS movimientos,
    MAX(fecha) AS ultimo_movimiento
FROM MB_DG_AUDITORIA
GROUP BY tabla, operacion;

-- ============================================================
-- 3. VISTA DE CAMBIOS DE ESTADO (PEDIDOS y PAGOS)
-- Muestra el estado anterior y el nuevo de cada UPDATE.
-- ============================================================
CREATE OR REPLACE VIEW MB_DG_V_AUDITORIA_ESTADOS AS
SELECT
    a.id          AS auditoria_id,
    a.fecha       AS fecha_operacion,
    a.tabla       AS tabla_afectada,
    a.registro_id,
    a.usuario_app,
    u.email       AS usuario_app_email,
    JSON_UNQUOTE(JSON_EXTRACT(a.datos_anteriores, '$.estado')) AS estado_anterior,
    JSON_UNQUOTE(JSON_EXTRACT(a.datos_nuevos,     '$.estado')) AS estado_nuevo
FROM MB_DG_AUDITORIA a
LEFT JOIN MB_DG_USUARIOS u
    ON u.id = a.usuario_app
WHERE a.operacion = 'UPDATE'
  AND a.tabla IN ('MB_DG_PEDIDOS', 'MB_DG_PAGOS')
  AND JSON_EXTRACT(a.datos_anteriores, '$.estado')
      <> JSON_EXTRACT(a.datos_nuevos, '$.estado');

-- ============================================================
-- 4. CONSULTAS DE EJEMPLO
-- ============================================================

-- 4.1 Ultimos 20 movimientos
SELECT auditoria_id, fecha_operacion, tabla_afectada, operacion,
       registro_id, usuario_app_email
FROM MB_DG_V_AUDITORIA
ORDER BY auditoria_id DESC
LIMIT 20;

-- 4.2 Resumen de movimientos por tabla y operacion
SELECT * FROM MB_DG_V_AUDITORIA_RESUMEN
ORDER BY tabla_afectada, operacion;

-- 4.3 Historial completo de un registro (ejemplo: pedido 9)
SELECT fecha_operacion, operacion, usuario_app_email,
       datos_anteriores, datos_nuevos
FROM MB_DG_V_AUDITORIA
WHERE tabla_afectada = 'MB_DG_PEDIDOS'
  AND registro_id = 9
ORDER BY auditoria_id;

-- 4.4 Solo las actualizaciones (valores antes y despues)
SELECT fecha_operacion, tabla_afectada, registro_id,
       datos_anteriores, datos_nuevos
FROM MB_DG_V_AUDITORIA
WHERE operacion = 'UPDATE'
ORDER BY auditoria_id;

-- 4.5 Cambios de estado de pedidos y pagos
SELECT * FROM MB_DG_V_AUDITORIA_ESTADOS
ORDER BY auditoria_id;

-- 4.6 Movimientos de un usuario de la aplicacion
SELECT fecha_operacion, tabla_afectada, operacion, registro_id
FROM MB_DG_V_AUDITORIA
WHERE usuario_app = 1
ORDER BY auditoria_id DESC;

-- 4.7 Movimientos en un rango de fechas
SELECT fecha_operacion, tabla_afectada, operacion, registro_id
FROM MB_DG_V_AUDITORIA
WHERE fecha_operacion >= CURDATE()
  AND fecha_operacion <  CURDATE() + INTERVAL 1 DAY;

-- 4.8 Registros eliminados (dato borrado conservado en auditoria)
SELECT fecha_operacion, tabla_afectada, registro_id, datos_anteriores
FROM MB_DG_V_AUDITORIA
WHERE operacion = 'DELETE';

-- 4.9 Resumen general del sistema
SELECT * FROM MB_DG_V_RESUMEN_ADMIN;