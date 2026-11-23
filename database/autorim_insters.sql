USE MB_DG_autorim;

        -- Usuario de la aplicacion que queda registrado en la auditoria
        -- (los triggers ya deben estar creados).
        SET @app_usuario_id = 1;

        -- =====================================================
        -- 1. USUARIOS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_USUARIOS
        (id, email, password_hash, rol, codigo_acceso_hash) VALUES
        (1, 'admin1@autorim.com', '$2b$10$lB7sfzb4X5NDPQLQbUKBTev/0Ld7EVk7lWoWfEkyaNzX0wUlmwXf2', 'admin', '$2b$10$/ud8go9qc65S4SlvRn4Kx./rCeop98TPyeg9V0XN9hGRT4JYs0rpu'),
        (2, 'admin2@autorim.com', '$2b$10$lB7sfzb4X5NDPQLQbUKBTev/0Ld7EVk7lWoWfEkyaNzX0wUlmwXf2', 'admin', '$2b$10$/ud8go9qc65S4SlvRn4Kx./rCeop98TPyeg9V0XN9hGRT4JYs0rpu'),
        (3, 'carlos@gmail.com', 'hash_demo_003', 'cliente', NULL),
        (4, 'laura@gmail.com', 'hash_demo_004', 'cliente', NULL),
        (5, 'andres@gmail.com', 'hash_demo_005', 'cliente', NULL),
        (6, 'maria@gmail.com', 'hash_demo_006', 'cliente', NULL),
        (7, 'juan@gmail.com', 'hash_demo_007', 'cliente', NULL),
        (8, 'sofia@gmail.com', 'hash_demo_008', 'cliente', NULL),
        (9, 'pedro@gmail.com', 'hash_demo_009', 'cliente', NULL),
        (10, 'ana@gmail.com', 'hash_demo_010', 'cliente', NULL),
        (11, 'diego@gmail.com', 'hash_demo_011', 'cliente', NULL),
        (12, 'camila@gmail.com', 'hash_demo_012', 'cliente', NULL),
        (13, 'felipe@gmail.com', 'hash_demo_013', 'cliente', NULL),
        (14, 'valentina@gmail.com', 'hash_demo_014', 'cliente', NULL),
        (15, 'santiago@gmail.com', 'hash_demo_015', 'cliente', NULL);


        -- =====================================================
        -- 2. AUTOS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_AUTOS
        (id, marca, nombre, carroceria, color_base) VALUES
        (1, 'Vektra', 'Vektra Aero GT', 'gt', '#c81e3a'),
        (2, 'Vektra', 'Vektra Rapt', 'coupe', '#2255d8'),
        (3, 'Zenor', 'Zenor Stallion V8', 'muscle', '#1b1b1f'),
        (4, 'Zenor', 'Zenor Blitz', 'coupe', '#6fae1c'),
        (5, 'Kairo', 'Kairo Ridge X', 'suv', '#c9cad0'),
        (6, 'Kairo', 'Kairo Phantom GT', 'gt', '#f0f0f0'),
        (7, 'Draven', 'Draven Titan', 'suv', '#1b1b1f'),
        (8, 'Draven', 'Draven Havoc', 'muscle', '#c81e3a'),
        (9, 'Vektra', 'Vektra Storm', 'coupe', '#d4af37'),
        (10, 'Zenor', 'Zenor Thunder', 'gt', '#2255d8'),
        (11, 'Kairo', 'Kairo Falcon', 'coupe', '#facc15'),
        (12, 'Draven', 'Draven Raptor', 'suv', '#6fae1c'),
        (13, 'Vektra', 'Vektra Nova', 'gt', '#f97316'),
        (14, 'Zenor', 'Zenor Cobra', 'muscle', '#2255d8'),
        (15, 'Kairo', 'Kairo Arrow', 'coupe', '#14b8a6');


        -- =====================================================
        -- 3. COLORES (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_COLORES
        (id, nombre, hex) VALUES
        (1, 'Gris plata', '#c9cad0'),
        (2, 'Negro mate', '#1b1b1f'),
        (3, 'Rojo racing', '#c81e3a'),
        (4, 'Azul eléctrico', '#2255d8'),
        (5, 'Verde viper', '#6fae1c'),
        (6, 'Blanco perla', '#f0f0f0'),
        (7, 'Amarillo deportivo', '#facc15'),
        (8, 'Naranja intenso', '#f97316'),
        (9, 'Morado oscuro', '#7e22ce'),
        (10, 'Turquesa', '#14b8a6'),
        (11, 'Rosa neón', '#ec4899'),
        (12, 'Verde militar', '#4d5d3a'),
        (13, 'Azul marino', '#1e3a8a'),
        (14, 'Café chocolate', '#5b3a29'),
        (15, 'Gris cemento', '#8b8d94');


        -- =====================================================
        -- 4. ACABADOS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_ACABADOS
        (id, nombre, hex) VALUES
        (1, 'Plata', '#c9ccd1'),
        (2, 'Negro', '#2b2b32'),
        (3, 'Oro', '#d4af37'),
        (4, 'Bronce', '#a0703c'),
        (5, 'Blanco', '#f0f0f0'),
        (6, 'Gris titanio', '#71717a'),
        (7, 'Cobre', '#b45309'),
        (8, 'Rojo metálico', '#991b1b'),
        (9, 'Azul metálico', '#1d4ed8'),
        (10, 'Grafito', '#374151'),
        (11, 'Cromo', '#e2e8f0'),
        (12, 'Negro brillante', '#0a0a0c'),
        (13, 'Oro rosa', '#b76e79'),
        (14, 'Verde metálico', '#365314'),
        (15, 'Morado metálico', '#6b21a8');


        -- =====================================================
        -- 5. RINES (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_RINES
        (id, nombre, estilo, acabado_base, precio) VALUES
        (1, 'Apex R5', 'five', '#c9ccd1', 1890000),
        (2, 'Vortex Mesh', 'mesh', '#d4af37', 2350000),
        (3, 'Turbo X', 'turbine', '#2b2b32', 2100000),
        (4, 'Slim 14', 'multi', '#b9bcc4', 1650000),
        (5, 'Nitro 5', 'five', '#2b2b32', 1750000),
        (6, 'Orbit Mesh', 'mesh', '#c9ccd1', 2480000),
        (7, 'Cyclone', 'turbine', '#a0703c', 2290000),
        (8, 'Forge V', 'multi', '#4a4a52', 1980000),
        (9, 'Racer Lite', 'five', '#e5e7eb', 1590000),
        (10, 'Stellar', 'mesh', '#d4af37', 2650000),
        (11, 'Phantom S', 'five', '#2b2b32', 1820000),
        (12, 'Helix', 'mesh', '#71717a', 2390000),
        (13, 'Jet Turbine', 'turbine', '#c9ccd1', 2210000),
        (14, 'Prime 18', 'multi', '#d4af37', 2050000),
        (15, 'Rocket Z', 'five', '#a0703c', 1920000);


        -- =====================================================
        -- 6. LLANTAS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_LLANTAS
        (id, codigo, nombre, svg_radio, svg_radio_rin, precio) VALUES
        (1, 'sport', 'Deportiva', 46, 35, 1200000),
        (2, 'off', 'Off-road', 50, 30, 1450000),
        (3, 'pre', 'Premium touring', 48, 33, 1350000),
        (4, 'rain', 'Lluvia', 47, 34, 1280000),
        (5, 'track', 'Pista slick', 45, 36, 1650000),
        (6, 'all', 'Todo terreno', 49, 31, 1500000),
        (7, 'eco', 'Eco eficiente', 48, 34, 1100000),
        (8, 'winter', 'Invierno', 48, 32, 1420000),
        (9, 'run', 'Run-flat', 47, 33, 1580000),
        (10, 'mud', 'Barro extremo', 51, 29, 1720000),
        (11, 'sand', 'Arena y dunas', 50, 31, 1560000),
        (12, 'comf', 'Confort urbano', 47, 34, 1180000),
        (13, 'uhp', 'Ultra alto rendimiento', 46, 35, 1750000),
        (14, 'tour', 'Gran turismo', 48, 33, 1390000),
        (15, 'drift', 'Drift', 46, 36, 1600000);


        -- =====================================================
        -- 7. MEDIDAS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_MEDIDAS
        (id, tipo, etiqueta, factor) VALUES
        (1, 'rin', '15"', 0.90),
        (2, 'rin', '16"', 0.95),
        (3, 'rin', '17"', 1.00),
        (4, 'rin', '18"', 1.10),
        (5, 'rin', '19"', 1.25),
        (6, 'rin', '20"', 1.40),
        (7, 'llanta', '195/65 R15', 0.90),
        (8, 'llanta', '205/55 R16', 0.95),
        (9, 'llanta', '225/45 R17', 1.00),
        (10, 'llanta', '245/40 R18', 1.10),
        (11, 'rin', '21"', 1.55),
        (12, 'rin', '22"', 1.70),
        (13, 'llanta', '255/35 R19', 1.25),
        (14, 'llanta', '275/30 R20', 1.40),
        (15, 'llanta', '285/30 R21', 1.55);


        -- =====================================================
        -- 8. CONFIGURACIONES (15 REGISTROS)
        -- Para tipo 'rines' y 'llantas' el precio_unitario es el
        -- precio de UNA unidad; el set de 4 se vende con cantidad = 4.
        -- =====================================================
        INSERT INTO MB_DG_CONFIGURACIONES
        (id, tipo, nombre, detalle, precio_unitario,
        auto_id, color_id, rin_id, acabado_id,
        medida_rin_id, ancho_rin, llanta_id, medida_llanta_id) VALUES

        (1, 'kit', 'Vektra Aero Deportivo',
        'Auto rojo con rines Apex y llantas deportivas',
        5500000, 1, 3, 1, 1, 3, '8.5J', 1, 9),

        (2, 'kit', 'Vektra Rapt Azul',
        'Auto azul con rines Vortex y llantas premium',
        6200000, 2, 4, 2, 3, 4, '9.5J', 3, 10),

        (3, 'kit', 'Zenor Stallion Negro',
        'Auto negro con rines Turbo X y llantas off-road',
        5800000, 3, 2, 3, 2, 5, '9.5J', 2, 10),

        (4, 'kit', 'Zenor Blitz Verde',
        'Auto verde con rines Nitro y llantas deportivas',
        4900000, 4, 5, 5, 6, 3, '7.5J', 1, 9),

        (5, 'kit', 'Kairo Ridge Plata',
        'SUV plata con rines Orbit Mesh y llantas todo terreno',
        6500000, 5, 1, 6, 1, 6, '9.5J', 6, 10),

        (6, 'kit', 'Kairo Phantom Blanco',
        'Auto blanco con rines Stellar y llantas premium',
        7100000, 6, 6, 10, 3, 5, '8.5J', 3, 9),

        (7, 'rines', 'Rines Cyclone Bronce',
        'Rin Cyclone en acabado bronce (precio por unidad)',
        2290000, NULL, NULL, 7, 4, 4, '8.5J', NULL, NULL),

        (8, 'rines', 'Rines Forge V Grafito',
        'Rin Forge V en acabado grafito (precio por unidad)',
        1980000, NULL, NULL, 8, 10, 5, '9.5J', NULL, NULL),

        (9, 'llantas', 'Llantas Eco Eficiente',
        'Llanta eco eficiente (precio por unidad)',
        1100000, NULL, NULL, NULL, NULL, NULL, NULL, 7, 9),

        (10, 'llantas', 'Llantas Todo Terreno',
        'Llanta para todo terreno (precio por unidad)',
        1500000, NULL, NULL, NULL, NULL, NULL, NULL, 6, 10),

        (11, 'kit', 'Kairo Falcon Amarillo',
        'Coupe amarillo con rines Phantom S y llantas ultra alto rendimiento',
        6000000, 11, 7, 11, 2, 4, '8.5J', 13, 10),

        (12, 'kit', 'Draven Raptor Verde',
        'SUV verde con rines Jet Turbine y llantas arena y dunas',
        6800000, 12, 5, 13, 1, 6, '9.5J', 11, 14),

        (13, 'kit', 'Vektra Nova Naranja',
        'GT naranja con rines Prime 18 y llantas de pista',
        6400000, 13, 8, 14, 3, 5, '8.5J', 5, 9),

        (14, 'rines', 'Rines Helix Titanio',
        'Rin Helix en acabado gris titanio (precio por unidad)',
        2390000, NULL, NULL, 12, 6, 3, '7.5J', NULL, NULL),

        (15, 'llantas', 'Llantas Gran Turismo',
        'Llanta gran turismo (precio por unidad)',
        1390000, NULL, NULL, NULL, NULL, NULL, NULL, 14, 8);


        -- =====================================================
        -- 9. PEDIDOS (15 REGISTROS)
        -- Se insertan con un estado inicial y luego se actualizan
        -- (ver bloque de actualizaciones al final) para que la
        -- auditoria registre tambien movimientos UPDATE reales.
        -- =====================================================
        INSERT INTO MB_DG_PEDIDOS
        (id, codigo, usuario_id, nombre_completo, direccion,
        ciudad, departamento, telefono, subtotal, costo_envio,
        total, estado) VALUES

        (1, 'AR-100001', 3, 'Carlos Pérez', 'Calle 10 #20-30',
        'Bogotá', 'Cundinamarca', '3001112233', 5500000, 25000, 5525000, 'pagado'),

        (2, 'AR-100002', 4, 'Laura Gómez', 'Carrera 15 #40-20',
        'Medellín', 'Antioquia', '3012223344', 6200000, 25000, 6225000, 'pendiente'),

        (3, 'AR-100003', 5, 'Andrés López', 'Calle 50 #10-15',
        'Cali', 'Valle del Cauca', '3023334455', 5800000, 25000, 5825000, 'pagado'),

        (4, 'AR-100004', 6, 'María Rodríguez', 'Carrera 8 #12-45',
        'Barranquilla', 'Atlántico', '3034445566', 4900000, 25000, 4925000, 'pagado'),

        (5, 'AR-100005', 7, 'Juan Martínez', 'Calle 25 #30-10',
        'Bucaramanga', 'Santander', '3045556677', 6500000, 25000, 6525000, 'pagado'),

        (6, 'AR-100006', 8, 'Sofía Torres', 'Carrera 20 #15-50',
        'Pereira', 'Risaralda', '3056667788', 7100000, 25000, 7125000, 'pendiente'),

        (7, 'AR-100007', 9, 'Pedro Ramírez', 'Calle 18 #22-11',
        'Manizales', 'Caldas', '3067778899', 9160000, 25000, 9185000, 'pagado'),

        (8, 'AR-100008', 10, 'Ana Herrera', 'Carrera 5 #8-20',
        'Cartagena', 'Bolívar', '3078889900', 7920000, 25000, 7945000, 'pagado'),

        (9, 'AR-100009', 3, 'Carlos Pérez', 'Calle 10 #20-30',
        'Bogotá', 'Cundinamarca', '3001112233', 4400000, 25000, 4425000, 'pendiente'),

        (10, 'AR-100010', 4, 'Laura Gómez', 'Carrera 15 #40-20',
        'Medellín', 'Antioquia', '3012223344', 6000000, 25000, 6025000, 'pagado'),

        (11, 'AR-100011', 11, 'Diego Vargas', 'Calle 72 #10-34',
        'Bogotá', 'Cundinamarca', '3081112233', 6000000, 25000, 6025000, 'pagado'),

        (12, 'AR-100012', 12, 'Camila Ruiz', 'Carrera 30 #45-12',
        'Medellín', 'Antioquia', '3092223344', 6800000, 25000, 6825000, 'pagado'),

        (13, 'AR-100013', 13, 'Felipe Castro', 'Calle 9 #14-60',
        'Cali', 'Valle del Cauca', '3103334455', 6400000, 25000, 6425000, 'pendiente'),

        (14, 'AR-100014', 14, 'Valentina Mejía', 'Carrera 12 #6-18',
        'Cúcuta', 'Norte de Santander', '3114445566', 9560000, 25000, 9585000, 'pagado'),

        (15, 'AR-100015', 15, 'Santiago Ortiz', 'Calle 33 #21-09',
        'Villavicencio', 'Meta', '3125556677', 5560000, 25000, 5585000, 'pagado');


        -- =====================================================
        -- 10. DETALLES DE PEDIDOS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_PEDIDO_ITEMS
        (id, pedido_id, configuracion_id, cantidad) VALUES
        (1, 1, 1, 1),
        (2, 2, 2, 1),
        (3, 3, 3, 1),
        (4, 4, 4, 1),
        (5, 5, 5, 1),
        (6, 6, 6, 1),
        (7, 7, 7, 4),
        (8, 8, 8, 4),
        (9, 9, 9, 4),
        (10, 10, 10, 4),
        (11, 11, 11, 1),
        (12, 12, 12, 1),
        (13, 13, 13, 1),
        (14, 14, 14, 4),
        (15, 15, 15, 4);


        -- =====================================================
        -- 11. AUDITORIA
        -- No se insertan datos a mano: los triggers registran
        -- automaticamente cada INSERT y UPDATE de este script.
        -- =====================================================


        -- =====================================================
        -- 12. PAGOS (15 REGISTROS)
        -- =====================================================
        INSERT INTO MB_DG_PAGOS
        (id, pedido_id, pasarela, referencia_externa, estado,
        monto, moneda, metodo_tipo, marca, ultimos4) VALUES

        (1, 1, 'Wompi', 'WOM-100001', 'aprobado', 5525000, 'COP', 'tarjeta', 'Visa', '1234'),
        (2, 2, 'Wompi', 'WOM-100002', 'pendiente', 6225000, 'COP', 'pse', NULL, NULL),
        (3, 3, 'PayU', 'PAY-100003', 'aprobado', 5825000, 'COP', 'tarjeta', 'Mastercard', '5678'),
        (4, 4, 'Wompi', 'WOM-100004', 'aprobado', 4925000, 'COP', 'nequi', NULL, NULL),
        (5, 5, 'PayU', 'PAY-100005', 'aprobado', 6525000, 'COP', 'tarjeta', 'Visa', '9012'),
        (6, 6, 'Wompi', 'WOM-100006', 'pendiente', 7125000, 'COP', 'pse', NULL, NULL),
        (7, 7, 'PayU', 'PAY-100007', 'aprobado', 9185000, 'COP', 'tarjeta', 'Mastercard', '3456'),
        (8, 8, 'Wompi', 'WOM-100008', 'aprobado', 7945000, 'COP', 'nequi', NULL, NULL),
        (9, 9, 'PayU', 'PAY-100009', 'pendiente', 4425000, 'COP', 'tarjeta', 'Visa', '7890'),
        (10, 10, 'Wompi', 'WOM-100010', 'aprobado', 6025000, 'COP', 'tarjeta', 'Mastercard', '2468'),
        (11, 11, 'Wompi', 'WOM-100011', 'aprobado', 6025000, 'COP', 'tarjeta', 'Visa', '1357'),
        (12, 12, 'PayU', 'PAY-100012', 'aprobado', 6825000, 'COP', 'nequi', NULL, NULL),
        (13, 13, 'Wompi', 'WOM-100013', 'pendiente', 6425000, 'COP', 'pse', NULL, NULL),
        (14, 14, 'PayU', 'PAY-100014', 'aprobado', 9585000, 'COP', 'tarjeta', 'Mastercard', '8642'),
        (15, 15, 'Wompi', 'WOM-100015', 'aprobado', 5585000, 'COP', 'tarjeta', 'Visa', '9753');


        -- =====================================================
        -- 13. ACTUALIZACIONES (historial real para la auditoria)
        -- =====================================================

        -- Correccion de nombre de un auto
        UPDATE MB_DG_AUTOS SET nombre = 'Vektra Rapt R' WHERE id = 2;

        -- Avance de estados de pedidos
        UPDATE MB_DG_PEDIDOS SET estado = 'enviado'   WHERE id IN (3, 8, 12);
        UPDATE MB_DG_PEDIDOS SET estado = 'entregado' WHERE id IN (5, 10);

        -- Pedido 9: el pago fue rechazado y el pedido cancelado
        UPDATE MB_DG_PAGOS   SET estado = 'rechazado' WHERE id = 9;
        UPDATE MB_DG_PEDIDOS SET estado = 'cancelado' WHERE id = 9;

        -- Pedido 15: se cancela y se reembolsa el pago
        UPDATE MB_DG_PEDIDOS SET estado = 'cancelado'   WHERE id = 15;
        UPDATE MB_DG_PAGOS   SET estado = 'reembolsado' WHERE id = 15;