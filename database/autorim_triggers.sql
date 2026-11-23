-- ============================================================
-- PROYECTO AUTORIM
-- SISTEMA DE AUDITORIA AUTOMATICA CON TRIGGERS MYSQL
-- ============================================================
-- Registra INSERT, UPDATE y DELETE en MB_DG_AUDITORIA.
-- Ejecutar despues de crear la estructura y ANTES de cargar datos.
-- La aplicacion debe ejecutar al abrir sesion:
--     SET @app_usuario_id = <id del usuario>;
-- Las variables v_antes/v_despues usan collation binaria (utf8mb4_bin) para
-- que un UPDATE que solo cambie mayusculas o tildes tambien se audite.
-- Si el usuario se registra solo (sin @app_usuario_id), el INSERT de
-- MB_DG_USUARIOS queda auditado a nombre del propio usuario creado.
-- ============================================================

USE MB_DG_autorim;

-- ============================================================
-- 1. ELIMINAR TRIGGERS ANTERIORES SI EXISTEN
-- ============================================================

DROP TRIGGER IF EXISTS MB_DG_TRG_AUDITORIA_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_AUDITORIA_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_USUARIOS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_USUARIOS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_USUARIOS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_AUTOS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_AUTOS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_AUTOS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_COLORES_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_COLORES_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_COLORES_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_ACABADOS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_ACABADOS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_ACABADOS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_RINES_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_RINES_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_RINES_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_LLANTAS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_LLANTAS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_LLANTAS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_MEDIDAS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_MEDIDAS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_MEDIDAS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_CONFIGURACIONES_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_CONFIGURACIONES_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_CONFIGURACIONES_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDOS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDOS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDOS_DEL_ITEMS;
DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDOS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDO_ITEMS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDO_ITEMS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_PEDIDO_ITEMS_DEL;

DROP TRIGGER IF EXISTS MB_DG_TRG_PAGOS_INS;
DROP TRIGGER IF EXISTS MB_DG_TRG_PAGOS_UPD;
DROP TRIGGER IF EXISTS MB_DG_TRG_PAGOS_DEL;

DELIMITER $$


-- ============================================================
-- 2. TRIGGERS DE PROTECCION DE LA TABLA DE AUDITORIA
-- ============================================================

-- Impide modificar registros existentes de auditoria.
CREATE TRIGGER MB_DG_TRG_AUDITORIA_UPD
BEFORE UPDATE ON MB_DG_AUDITORIA
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La tabla de auditoria es de solo lectura';
END$$

-- Impide eliminar registros de auditoria.
CREATE TRIGGER MB_DG_TRG_AUDITORIA_DEL
BEFORE DELETE ON MB_DG_AUDITORIA
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No se permite eliminar registros de auditoria';
END$$


-- ============================================================
-- 3. TRIGGERS DE LA TABLA MB_DG_USUARIOS
-- ============================================================

-- INSERT: registra los datos del usuario cuando se crea.
CREATE TRIGGER MB_DG_TRG_USUARIOS_INS
AFTER INSERT ON MB_DG_USUARIOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_USUARIOS', 'INSERT', NEW.id,
        COALESCE(CAST(@app_usuario_id AS UNSIGNED), NEW.id), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'email', NEW.email,
            'password_hash', '[oculto]',
            'rol', NEW.rol,
            'codigo_acceso_hash', '[oculto]',
            'creado_en', NEW.creado_en
        )
    );
END$$

-- UPDATE: registra los valores anteriores y nuevos del usuario.
-- Los hashes no se guardan en texto dentro de la auditoria.
CREATE TRIGGER MB_DG_TRG_USUARIOS_UPD
AFTER UPDATE ON MB_DG_USUARIOS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id,
        'email', OLD.email,
        'password_hash', '[oculto]',
        'rol', OLD.rol,
        'codigo_acceso_hash', '[oculto]',
        'creado_en', OLD.creado_en
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id,
        'email', NEW.email,
        'password_hash',
        IF(NEW.password_hash <=> OLD.password_hash,
           '[oculto]', '[oculto: modificado]'),
        'rol', NEW.rol,
        'codigo_acceso_hash',
        IF(NEW.codigo_acceso_hash <=> OLD.codigo_acceso_hash,
           '[oculto]', '[oculto: modificado]'),
        'creado_en', NEW.creado_en
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_USUARIOS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

-- DELETE: conserva los datos del usuario antes de eliminarlo.
CREATE TRIGGER MB_DG_TRG_USUARIOS_DEL
AFTER DELETE ON MB_DG_USUARIOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_USUARIOS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id,
            'email', OLD.email,
            'password_hash', '[oculto]',
            'rol', OLD.rol,
            'codigo_acceso_hash', '[oculto]',
            'creado_en', OLD.creado_en
        ),
        NULL
    );
END$$


-- ============================================================
-- 4. TRIGGERS DE LA TABLA MB_DG_AUTOS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_AUTOS_INS
AFTER INSERT ON MB_DG_AUTOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_AUTOS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'marca', NEW.marca,
            'nombre', NEW.nombre,
            'carroceria', NEW.carroceria,
            'color_base', NEW.color_base,
            'activo', NEW.activo
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_AUTOS_UPD
AFTER UPDATE ON MB_DG_AUTOS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'marca', OLD.marca,
        'nombre', OLD.nombre, 'carroceria', OLD.carroceria,
        'color_base', OLD.color_base, 'activo', OLD.activo
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'marca', NEW.marca,
        'nombre', NEW.nombre, 'carroceria', NEW.carroceria,
        'color_base', NEW.color_base, 'activo', NEW.activo
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_AUTOS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_AUTOS_DEL
AFTER DELETE ON MB_DG_AUTOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_AUTOS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'marca', OLD.marca,
            'nombre', OLD.nombre, 'carroceria', OLD.carroceria,
            'color_base', OLD.color_base, 'activo', OLD.activo
        ),
        NULL
    );
END$$


-- ============================================================
-- 5. TRIGGERS DE LA TABLA MB_DG_COLORES
-- ============================================================

CREATE TRIGGER MB_DG_TRG_COLORES_INS
AFTER INSERT ON MB_DG_COLORES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_COLORES', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'hex', NEW.hex
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_COLORES_UPD
AFTER UPDATE ON MB_DG_COLORES
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'nombre', OLD.nombre, 'hex', OLD.hex
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'nombre', NEW.nombre, 'hex', NEW.hex
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_COLORES', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_COLORES_DEL
AFTER DELETE ON MB_DG_COLORES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_COLORES', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'nombre', OLD.nombre, 'hex', OLD.hex
        ),
        NULL
    );
END$$


-- ============================================================
-- 6. TRIGGERS DE LA TABLA MB_DG_ACABADOS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_ACABADOS_INS
AFTER INSERT ON MB_DG_ACABADOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_ACABADOS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'hex', NEW.hex
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_ACABADOS_UPD
AFTER UPDATE ON MB_DG_ACABADOS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'nombre', OLD.nombre, 'hex', OLD.hex
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'nombre', NEW.nombre, 'hex', NEW.hex
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_ACABADOS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_ACABADOS_DEL
AFTER DELETE ON MB_DG_ACABADOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_ACABADOS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'nombre', OLD.nombre, 'hex', OLD.hex
        ),
        NULL
    );
END$$


-- ============================================================
-- 7. TRIGGERS DE LA TABLA MB_DG_RINES
-- ============================================================

CREATE TRIGGER MB_DG_TRG_RINES_INS
AFTER INSERT ON MB_DG_RINES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_RINES', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'nombre', NEW.nombre,
            'estilo', NEW.estilo,
            'acabado_base', NEW.acabado_base,
            'precio', NEW.precio,
            'activo', NEW.activo
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_RINES_UPD
AFTER UPDATE ON MB_DG_RINES
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'nombre', OLD.nombre,
        'estilo', OLD.estilo, 'acabado_base', OLD.acabado_base,
        'precio', OLD.precio, 'activo', OLD.activo
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'nombre', NEW.nombre,
        'estilo', NEW.estilo, 'acabado_base', NEW.acabado_base,
        'precio', NEW.precio, 'activo', NEW.activo
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_RINES', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_RINES_DEL
AFTER DELETE ON MB_DG_RINES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_RINES', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'nombre', OLD.nombre,
            'estilo', OLD.estilo, 'acabado_base', OLD.acabado_base,
            'precio', OLD.precio, 'activo', OLD.activo
        ),
        NULL
    );
END$$


-- ============================================================
-- 8. TRIGGERS DE LA TABLA MB_DG_LLANTAS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_LLANTAS_INS
AFTER INSERT ON MB_DG_LLANTAS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_LLANTAS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'codigo', NEW.codigo,
            'nombre', NEW.nombre,
            'svg_radio', NEW.svg_radio,
            'svg_radio_rin', NEW.svg_radio_rin,
            'precio', NEW.precio,
            'activo', NEW.activo
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_LLANTAS_UPD
AFTER UPDATE ON MB_DG_LLANTAS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'codigo', OLD.codigo,
        'nombre', OLD.nombre, 'svg_radio', OLD.svg_radio,
        'svg_radio_rin', OLD.svg_radio_rin,
        'precio', OLD.precio, 'activo', OLD.activo
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'codigo', NEW.codigo,
        'nombre', NEW.nombre, 'svg_radio', NEW.svg_radio,
        'svg_radio_rin', NEW.svg_radio_rin,
        'precio', NEW.precio, 'activo', NEW.activo
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_LLANTAS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_LLANTAS_DEL
AFTER DELETE ON MB_DG_LLANTAS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_LLANTAS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'codigo', OLD.codigo,
            'nombre', OLD.nombre, 'svg_radio', OLD.svg_radio,
            'svg_radio_rin', OLD.svg_radio_rin,
            'precio', OLD.precio, 'activo', OLD.activo
        ),
        NULL
    );
END$$


-- ============================================================
-- 9. TRIGGERS DE LA TABLA MB_DG_MEDIDAS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_MEDIDAS_INS
AFTER INSERT ON MB_DG_MEDIDAS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_MEDIDAS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'tipo', NEW.tipo,
            'etiqueta', NEW.etiqueta,
            'factor', NEW.factor
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_MEDIDAS_UPD
AFTER UPDATE ON MB_DG_MEDIDAS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'tipo', OLD.tipo,
        'etiqueta', OLD.etiqueta, 'factor', OLD.factor
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'tipo', NEW.tipo,
        'etiqueta', NEW.etiqueta, 'factor', NEW.factor
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_MEDIDAS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_MEDIDAS_DEL
AFTER DELETE ON MB_DG_MEDIDAS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_MEDIDAS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'tipo', OLD.tipo,
            'etiqueta', OLD.etiqueta, 'factor', OLD.factor
        ),
        NULL
    );
END$$


-- ============================================================
-- 10. TRIGGERS DE LA TABLA MB_DG_CONFIGURACIONES
-- ============================================================

CREATE TRIGGER MB_DG_TRG_CONFIGURACIONES_INS
AFTER INSERT ON MB_DG_CONFIGURACIONES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_CONFIGURACIONES', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id,
            'tipo', NEW.tipo,
            'nombre', NEW.nombre,
            'detalle', NEW.detalle,
            'precio_unitario', NEW.precio_unitario,
            'auto_id', NEW.auto_id,
            'color_id', NEW.color_id,
            'rin_id', NEW.rin_id,
            'acabado_id', NEW.acabado_id,
            'medida_rin_id', NEW.medida_rin_id,
            'ancho_rin', NEW.ancho_rin,
            'llanta_id', NEW.llanta_id,
            'medida_llanta_id', NEW.medida_llanta_id,
            'creado_en', NEW.creado_en
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_CONFIGURACIONES_UPD
AFTER UPDATE ON MB_DG_CONFIGURACIONES
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'tipo', OLD.tipo,
        'nombre', OLD.nombre, 'detalle', OLD.detalle,
        'precio_unitario', OLD.precio_unitario,
        'auto_id', OLD.auto_id, 'color_id', OLD.color_id,
        'rin_id', OLD.rin_id, 'acabado_id', OLD.acabado_id,
        'medida_rin_id', OLD.medida_rin_id,
        'ancho_rin', OLD.ancho_rin, 'llanta_id', OLD.llanta_id,
        'medida_llanta_id', OLD.medida_llanta_id,
        'creado_en', OLD.creado_en
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'tipo', NEW.tipo,
        'nombre', NEW.nombre, 'detalle', NEW.detalle,
        'precio_unitario', NEW.precio_unitario,
        'auto_id', NEW.auto_id, 'color_id', NEW.color_id,
        'rin_id', NEW.rin_id, 'acabado_id', NEW.acabado_id,
        'medida_rin_id', NEW.medida_rin_id,
        'ancho_rin', NEW.ancho_rin, 'llanta_id', NEW.llanta_id,
        'medida_llanta_id', NEW.medida_llanta_id,
        'creado_en', NEW.creado_en
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_CONFIGURACIONES', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_CONFIGURACIONES_DEL
AFTER DELETE ON MB_DG_CONFIGURACIONES
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_CONFIGURACIONES', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'tipo', OLD.tipo,
            'nombre', OLD.nombre, 'detalle', OLD.detalle,
            'precio_unitario', OLD.precio_unitario,
            'auto_id', OLD.auto_id, 'color_id', OLD.color_id,
            'rin_id', OLD.rin_id, 'acabado_id', OLD.acabado_id,
            'medida_rin_id', OLD.medida_rin_id,
            'ancho_rin', OLD.ancho_rin, 'llanta_id', OLD.llanta_id,
            'medida_llanta_id', OLD.medida_llanta_id,
            'creado_en', OLD.creado_en
        ),
        NULL
    );
END$$


-- ============================================================
-- 11. TRIGGERS DE LA TABLA MB_DG_PEDIDOS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_PEDIDOS_INS
AFTER INSERT ON MB_DG_PEDIDOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PEDIDOS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id, 'codigo', NEW.codigo,
            'usuario_id', NEW.usuario_id,
            'nombre_completo', NEW.nombre_completo,
            'direccion', NEW.direccion, 'ciudad', NEW.ciudad,
            'departamento', NEW.departamento,
            'telefono', NEW.telefono, 'subtotal', NEW.subtotal,
            'costo_envio', NEW.costo_envio, 'total', NEW.total,
            'estado', NEW.estado, 'creado_en', NEW.creado_en
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_PEDIDOS_UPD
AFTER UPDATE ON MB_DG_PEDIDOS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'codigo', OLD.codigo,
        'usuario_id', OLD.usuario_id,
        'nombre_completo', OLD.nombre_completo,
        'direccion', OLD.direccion, 'ciudad', OLD.ciudad,
        'departamento', OLD.departamento,
        'telefono', OLD.telefono, 'subtotal', OLD.subtotal,
        'costo_envio', OLD.costo_envio, 'total', OLD.total,
        'estado', OLD.estado, 'creado_en', OLD.creado_en
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'codigo', NEW.codigo,
        'usuario_id', NEW.usuario_id,
        'nombre_completo', NEW.nombre_completo,
        'direccion', NEW.direccion, 'ciudad', NEW.ciudad,
        'departamento', NEW.departamento,
        'telefono', NEW.telefono, 'subtotal', NEW.subtotal,
        'costo_envio', NEW.costo_envio, 'total', NEW.total,
        'estado', NEW.estado, 'creado_en', NEW.creado_en
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_PEDIDOS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

-- BEFORE DELETE: elimina explicitamente los items del pedido.
-- Esto permite que se ejecute el trigger de auditoria de cada item.
-- MySQL no ejecuta triggers por eliminaciones en cascada de FK.
CREATE TRIGGER MB_DG_TRG_PEDIDOS_DEL_ITEMS
BEFORE DELETE ON MB_DG_PEDIDOS
FOR EACH ROW
BEGIN
    DELETE FROM MB_DG_PEDIDO_ITEMS
    WHERE pedido_id = OLD.id;
END$$

CREATE TRIGGER MB_DG_TRG_PEDIDOS_DEL
AFTER DELETE ON MB_DG_PEDIDOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PEDIDOS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'codigo', OLD.codigo,
            'usuario_id', OLD.usuario_id,
            'nombre_completo', OLD.nombre_completo,
            'direccion', OLD.direccion, 'ciudad', OLD.ciudad,
            'departamento', OLD.departamento,
            'telefono', OLD.telefono, 'subtotal', OLD.subtotal,
            'costo_envio', OLD.costo_envio, 'total', OLD.total,
            'estado', OLD.estado, 'creado_en', OLD.creado_en
        ),
        NULL
    );
END$$


-- ============================================================
-- 12. TRIGGERS DE LA TABLA MB_DG_PEDIDO_ITEMS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_PEDIDO_ITEMS_INS
AFTER INSERT ON MB_DG_PEDIDO_ITEMS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PEDIDO_ITEMS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id, 'pedido_id', NEW.pedido_id,
            'configuracion_id', NEW.configuracion_id,
            'cantidad', NEW.cantidad
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_PEDIDO_ITEMS_UPD
AFTER UPDATE ON MB_DG_PEDIDO_ITEMS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'pedido_id', OLD.pedido_id,
        'configuracion_id', OLD.configuracion_id,
        'cantidad', OLD.cantidad
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'pedido_id', NEW.pedido_id,
        'configuracion_id', NEW.configuracion_id,
        'cantidad', NEW.cantidad
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_PEDIDO_ITEMS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_PEDIDO_ITEMS_DEL
AFTER DELETE ON MB_DG_PEDIDO_ITEMS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PEDIDO_ITEMS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'pedido_id', OLD.pedido_id,
            'configuracion_id', OLD.configuracion_id,
            'cantidad', OLD.cantidad
        ),
        NULL
    );
END$$


-- ============================================================
-- 13. TRIGGERS DE LA TABLA MB_DG_PAGOS
-- ============================================================

CREATE TRIGGER MB_DG_TRG_PAGOS_INS
AFTER INSERT ON MB_DG_PAGOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PAGOS', 'INSERT', NEW.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(), NULL,
        JSON_OBJECT(
            'id', NEW.id, 'pedido_id', NEW.pedido_id,
            'pasarela', NEW.pasarela,
            'referencia_externa', NEW.referencia_externa,
            'estado', NEW.estado, 'monto', NEW.monto,
            'moneda', NEW.moneda, 'metodo_tipo', NEW.metodo_tipo,
            'marca', NEW.marca, 'ultimos4', NEW.ultimos4,
            'creado_en', NEW.creado_en
        )
    );
END$$

CREATE TRIGGER MB_DG_TRG_PAGOS_UPD
AFTER UPDATE ON MB_DG_PAGOS
FOR EACH ROW
BEGIN
    DECLARE v_antes LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
    DECLARE v_despues LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

    SET v_antes = JSON_OBJECT(
        'id', OLD.id, 'pedido_id', OLD.pedido_id,
        'pasarela', OLD.pasarela,
        'referencia_externa', OLD.referencia_externa,
        'estado', OLD.estado, 'monto', OLD.monto,
        'moneda', OLD.moneda, 'metodo_tipo', OLD.metodo_tipo,
        'marca', OLD.marca, 'ultimos4', OLD.ultimos4,
        'creado_en', OLD.creado_en
    );

    SET v_despues = JSON_OBJECT(
        'id', NEW.id, 'pedido_id', NEW.pedido_id,
        'pasarela', NEW.pasarela,
        'referencia_externa', NEW.referencia_externa,
        'estado', NEW.estado, 'monto', NEW.monto,
        'moneda', NEW.moneda, 'metodo_tipo', NEW.metodo_tipo,
        'marca', NEW.marca, 'ultimos4', NEW.ultimos4,
        'creado_en', NEW.creado_en
    );

    IF NOT (v_antes <=> v_despues) THEN
        INSERT INTO MB_DG_AUDITORIA
        (tabla, operacion, registro_id, usuario_app, usuario_bd,
         datos_anteriores, datos_nuevos)
        VALUES (
            'MB_DG_PAGOS', 'UPDATE', NEW.id,
            CAST(@app_usuario_id AS UNSIGNED), USER(),
            v_antes, v_despues
        );
    END IF;
END$$

CREATE TRIGGER MB_DG_TRG_PAGOS_DEL
AFTER DELETE ON MB_DG_PAGOS
FOR EACH ROW
BEGIN
    INSERT INTO MB_DG_AUDITORIA
    (tabla, operacion, registro_id, usuario_app, usuario_bd,
     datos_anteriores, datos_nuevos)
    VALUES (
        'MB_DG_PAGOS', 'DELETE', OLD.id,
        CAST(@app_usuario_id AS UNSIGNED), USER(),
        JSON_OBJECT(
            'id', OLD.id, 'pedido_id', OLD.pedido_id,
            'pasarela', OLD.pasarela,
            'referencia_externa', OLD.referencia_externa,
            'estado', OLD.estado, 'monto', OLD.monto,
            'moneda', OLD.moneda, 'metodo_tipo', OLD.metodo_tipo,
            'marca', OLD.marca, 'ultimos4', OLD.ultimos4,
            'creado_en', OLD.creado_en
        ),
        NULL
    );
END$$

DELIMITER ;

-- ============================================================
-- FIN DE LOS TRIGGERS
-- ============================================================