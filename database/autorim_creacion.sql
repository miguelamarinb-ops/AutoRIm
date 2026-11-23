-- =====================================================================
--  AutoRim · ESTRUCTURA de la base de datos (MySQL 8 / MariaDB 10.5+)
--  Solo estructura (sin datos): tablas, restricciones, indices y vistas
--  del panel de administracion. 12 tablas con prefijo MB_DG_.
--
--  Orden de ejecucion:
--    1. autorim_creacion.sql   (este archivo)
--    2. autorim_triggers.sql
--    3. autorim_inserts.sql
--    4. autorim_auditoria.sql  (vistas y consultas de auditoria)
--
--  ¡OJO! Este script BORRA y vuelve a crear la base MB_DG_autorim.
-- =====================================================================

DROP DATABASE IF EXISTS MB_DG_autorim;
CREATE DATABASE MB_DG_autorim CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE MB_DG_autorim;

-- ---------------------------------------------------------------------
--  1. USUARIOS (clientes y administradores)
--  Contraseña y código de acceso se guardan con hash bcrypt, nunca en claro.
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_USUARIOS (
  id                  INT AUTO_INCREMENT NOT NULL,
  email               VARCHAR(190) NOT NULL,
  password_hash       VARCHAR(255) NOT NULL,
  rol                 ENUM('cliente','admin') NOT NULL DEFAULT 'cliente',
  codigo_acceso_hash  VARCHAR(255) NULL,          -- solo administradores (panel /admin)
  creado_en           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_usuarios_email (email),
  CONSTRAINT ck_usuarios_admin CHECK (rol <> 'admin' OR codigo_acceso_hash IS NOT NULL)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  2-7. CATÁLOGO
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_AUTOS (
  id          INT AUTO_INCREMENT NOT NULL,
  marca       VARCHAR(60)  NOT NULL,
  nombre      VARCHAR(100) NOT NULL,
  carroceria  ENUM('gt','coupe','muscle','suv') NOT NULL,
  color_base  CHAR(7)      NOT NULL,
  activo      BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_autos_nombre (nombre),
  KEY ix_autos_marca (marca),
  CONSTRAINT ck_autos_color CHECK (color_base REGEXP '^#[0-9a-fA-F]{6}$')
) ENGINE=InnoDB;

CREATE TABLE MB_DG_COLORES (
  id      INT AUTO_INCREMENT NOT NULL,
  nombre  VARCHAR(40) NOT NULL,
  hex     CHAR(7)     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_colores_nombre (nombre),
  UNIQUE KEY uq_colores_hex (hex),
  CONSTRAINT ck_colores_hex CHECK (hex REGEXP '^#[0-9a-fA-F]{6}$')
) ENGINE=InnoDB;

CREATE TABLE MB_DG_ACABADOS (
  id      INT AUTO_INCREMENT NOT NULL,
  nombre  VARCHAR(40) NOT NULL,
  hex     CHAR(7)     NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_acabados_nombre (nombre),
  UNIQUE KEY uq_acabados_hex (hex),
  CONSTRAINT ck_acabados_hex CHECK (hex REGEXP '^#[0-9a-fA-F]{6}$')
) ENGINE=InnoDB;

CREATE TABLE MB_DG_RINES (
  id            INT AUTO_INCREMENT NOT NULL,
  nombre        VARCHAR(60)  NOT NULL,
  estilo        ENUM('five','mesh','turbine','multi') NOT NULL,
  acabado_base  CHAR(7)      NOT NULL,
  precio        INT NOT NULL,                      -- COP, set de 4
  activo        BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_rines_nombre (nombre),
  CONSTRAINT ck_rines_precio CHECK (precio >= 0),
  CONSTRAINT ck_rines_acabado CHECK (acabado_base REGEXP '^#[0-9a-fA-F]{6}$')
) ENGINE=InnoDB;

CREATE TABLE MB_DG_LLANTAS (
  id             INT AUTO_INCREMENT NOT NULL,
  codigo         VARCHAR(10)  NOT NULL,            -- 'sport', 'off', 'pre' (se usa en la URL)
  nombre         VARCHAR(60)  NOT NULL,
  svg_radio      INT NOT NULL,                     -- radio del dibujo SVG
  svg_radio_rin  INT NOT NULL,                     -- radio del rin dentro de la llanta
  precio         INT NOT NULL,                     -- COP, set de 4
  activo         BOOLEAN      NOT NULL DEFAULT TRUE,
  PRIMARY KEY (id),
  UNIQUE KEY uq_llantas_codigo (codigo),
  CONSTRAINT ck_llantas_precio CHECK (precio >= 0),
  CONSTRAINT ck_llantas_radios CHECK (svg_radio >= 1 AND svg_radio_rin >= 1)
) ENGINE=InnoDB;

CREATE TABLE MB_DG_MEDIDAS (                       -- tamaños de rin (17") y de llanta (225/45 R17)
  id        INT AUTO_INCREMENT NOT NULL,
  tipo      ENUM('rin','llanta') NOT NULL,
  etiqueta  VARCHAR(20)  NOT NULL,
  factor    DECIMAL(4,2) NOT NULL,                 -- multiplica el precio base
  PRIMARY KEY (id),
  UNIQUE KEY uq_medidas (tipo, etiqueta),
  CONSTRAINT ck_medidas_factor CHECK (factor > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  8. CONFIGURACIONES: producto armado por el cliente (inmutable).
--     kit = auto+color+rin+llanta · rines = set de 4 · llantas = set de 4
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_CONFIGURACIONES (
  id                INT AUTO_INCREMENT NOT NULL,
  tipo              ENUM('kit','rines','llantas') NOT NULL,
  nombre            VARCHAR(120)  NOT NULL,
  detalle           VARCHAR(255)  NOT NULL,
  precio_unitario   INT NOT NULL,
  auto_id           INT NULL,
  color_id          INT NULL,
  rin_id            INT NULL,
  acabado_id        INT NULL,                      -- NULL = acabado original
  medida_rin_id     INT NULL,
  ancho_rin         ENUM('7.5J','8.5J','9.5J') NULL,
  llanta_id         INT NULL,
  medida_llanta_id  INT NULL,
  creado_en         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT ck_cfg_precio CHECK (precio_unitario >= 0),
  CONSTRAINT fk_cfg_auto    FOREIGN KEY (auto_id)          REFERENCES MB_DG_AUTOS (id),
  CONSTRAINT fk_cfg_color   FOREIGN KEY (color_id)         REFERENCES MB_DG_COLORES (id),
  CONSTRAINT fk_cfg_rin     FOREIGN KEY (rin_id)           REFERENCES MB_DG_RINES (id),
  CONSTRAINT fk_cfg_acabado FOREIGN KEY (acabado_id)       REFERENCES MB_DG_ACABADOS (id),
  CONSTRAINT fk_cfg_medrin  FOREIGN KEY (medida_rin_id)    REFERENCES MB_DG_MEDIDAS (id),
  CONSTRAINT fk_cfg_llanta  FOREIGN KEY (llanta_id)        REFERENCES MB_DG_LLANTAS (id),
  CONSTRAINT fk_cfg_medlla  FOREIGN KEY (medida_llanta_id) REFERENCES MB_DG_MEDIDAS (id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  9-10. PEDIDOS y sus renglones
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_PEDIDOS (
  id               INT AUTO_INCREMENT NOT NULL,
  codigo           VARCHAR(20)   NOT NULL,         -- 'AR-123456'
  usuario_id       INT NOT NULL,
  nombre_completo  VARCHAR(120)  NOT NULL,
  direccion        VARCHAR(200)  NOT NULL,
  ciudad           VARCHAR(80)   NOT NULL,
  departamento     VARCHAR(80)   NOT NULL,
  telefono         VARCHAR(30)   NOT NULL,
  subtotal         INT NOT NULL,
  costo_envio      INT NOT NULL DEFAULT 25000,
  total            INT NOT NULL,
  estado           ENUM('pendiente','pagado','enviado','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  creado_en        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pedidos_codigo (codigo),
  KEY ix_pedidos_usuario (usuario_id),
  KEY ix_pedidos_fecha (creado_en),
  CONSTRAINT ck_pedidos_montos CHECK (subtotal >= 0 AND costo_envio >= 0 AND total = subtotal + costo_envio),
  CONSTRAINT fk_pedidos_usuario FOREIGN KEY (usuario_id) REFERENCES MB_DG_USUARIOS (id)
) ENGINE=InnoDB;

CREATE TABLE MB_DG_PEDIDO_ITEMS (
  id                INT AUTO_INCREMENT NOT NULL,
  pedido_id         INT NOT NULL,
  configuracion_id  INT NOT NULL,
  cantidad          INT NOT NULL,
  PRIMARY KEY (id),
  CONSTRAINT ck_items_cantidad CHECK (cantidad >= 1),
  CONSTRAINT fk_pi_pedido FOREIGN KEY (pedido_id)        REFERENCES MB_DG_PEDIDOS (id) ON DELETE CASCADE,
  CONSTRAINT fk_pi_config FOREIGN KEY (configuracion_id) REFERENCES MB_DG_CONFIGURACIONES (id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  11. PAGOS (simulados). Solo marca y últimos 4 dígitos; nunca el número
--  completo ni el CVV. Sin ON DELETE CASCADE a propósito: un pedido con
--  pagos no se puede borrar.
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_PAGOS (
  id                  INT AUTO_INCREMENT NOT NULL,
  pedido_id           INT NOT NULL,
  pasarela            VARCHAR(30) NOT NULL,        -- 'simulada', 'wompi', 'payu'...
  referencia_externa  VARCHAR(80) NULL,
  estado              ENUM('pendiente','aprobado','rechazado','reembolsado') NOT NULL DEFAULT 'pendiente',
  monto               INT NOT NULL,                -- COP, sin decimales
  moneda              CHAR(3) NOT NULL DEFAULT 'COP',
  metodo_tipo         ENUM('tarjeta','pse','nequi') NOT NULL DEFAULT 'tarjeta',
  marca               VARCHAR(20) NULL,
  ultimos4            CHAR(4) NULL,
  creado_en           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado_en      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_pagos_referencia (referencia_externa),
  KEY ix_pagos_pedido (pedido_id),
  KEY ix_pagos_fecha (creado_en),
  CONSTRAINT fk_pagos_pedido FOREIGN KEY (pedido_id) REFERENCES MB_DG_PEDIDOS (id),
  CONSTRAINT ck_pagos_monto CHECK (monto >= 0),
  CONSTRAINT ck_pagos_ultimos4 CHECK (ultimos4 IS NULL OR ultimos4 REGEXP '^[0-9]{4}$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  12. AUDITORÍA: una fila por cada INSERT, UPDATE o DELETE (la llenan los
--  triggers; la app no escribe aquí). Es de solo agregar. usuario_app no es
--  llave foránea a propósito: el historial sobrevive si se borra el usuario.
-- ---------------------------------------------------------------------
CREATE TABLE MB_DG_AUDITORIA (
  id                INT AUTO_INCREMENT NOT NULL,
  tabla             VARCHAR(40)  NOT NULL,
  operacion         ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  registro_id       INT NOT NULL,
  usuario_app       INT NULL,                      -- @app_usuario_id que informa el backend
  usuario_bd        VARCHAR(128) NOT NULL,         -- USER() de MySQL
  fecha             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  datos_anteriores  JSON NULL,
  datos_nuevos      JSON NULL,
  PRIMARY KEY (id),
  KEY ix_aud_tabla_registro (tabla, registro_id),
  KEY ix_aud_fecha (fecha),
  KEY ix_aud_usuario_app (usuario_app)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
--  VISTAS del panel de administración
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW MB_DG_V_PEDIDOS_ADMIN AS
SELECT p.codigo               AS pedido,
       p.creado_en            AS fecha,
       u.email                AS cliente,
       GROUP_CONCAT(CONCAT(c.nombre, ' x', pi.cantidad) ORDER BY pi.id SEPARATOR ', ') AS productos,
       p.total,
       p.estado
FROM MB_DG_PEDIDOS p
JOIN MB_DG_USUARIOS u        ON u.id = p.usuario_id
JOIN MB_DG_PEDIDO_ITEMS pi   ON pi.pedido_id = p.id
JOIN MB_DG_CONFIGURACIONES c ON c.id = pi.configuracion_id
GROUP BY p.id, p.codigo, p.creado_en, u.email, p.total, p.estado;

CREATE OR REPLACE VIEW MB_DG_V_RESUMEN_ADMIN AS
SELECT (SELECT COUNT(*) FROM MB_DG_PEDIDOS)                        AS pedidos,
       (SELECT COUNT(*) FROM MB_DG_USUARIOS WHERE rol = 'cliente') AS clientes;