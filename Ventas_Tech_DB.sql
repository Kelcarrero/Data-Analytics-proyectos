CREATE DATABASE Ventas_Tech_DB

=== SECCIÓN 1: DROP ===

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS categorias;

=== SECCIÓN 2: CREATE ===

-- Tabla categorias (dimensión)
CREATE TABLE categorias (
    id_categoria     INT             PRIMARY KEY,
    nombre_categoria VARCHAR(50)     NOT NULL,
    descripcion      VARCHAR(200)
);
CREATE TABLE clientes (
    id_cliente      INT             PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(100)    UNIQUE,
    ciudad          VARCHAR(50),
    fecha_registro  DATE            NOT NULL
);
-- Tabla productos (dimensión, depende de categorias)
CREATE TABLE productos (
    id_producto      INT             PRIMARY KEY,
    nombre_producto  VARCHAR(100)    NOT NULL,
    id_categoria     INT,
    precio           DECIMAL(10,2)   NOT NULL,
    stock            INT             DEFAULT 0,
    activo           BIT             DEFAULT 1,
    CONSTRAINT FK_productos_categorias
        FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
 
-- Tabla ventas (hechos, depende de clientes y productos)
CREATE TABLE ventas (
    id_venta         INT             PRIMARY KEY,
    id_cliente       INT,
    id_producto      INT,
    cantidad         INT             NOT NULL,
    precio_unitario  DECIMAL(10,2)   NOT NULL,
    fecha_venta      DATE            NOT NULL,
    CONSTRAINT FK_ventas_clientes
        FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT FK_ventas_productos
        FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

=== SECCIÓN 3: INSERT ===

INSERT INTO categorias (id_categoria, nombre_categoria, descripcion) VALUES
  (1, 'Computación',    'Laptops, PCs y monitores'),
  (2, 'Accesorios',     'Periféricos y complementos'),
  (3, 'Audio',          'Auriculares y parlantes'),
  (4, 'Almacenamiento', 'Discos y memorias');

  INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
  (1, 'María López',  'maria@mail.com',  'Buenos Aires', '2024-01-05'),
  (2, 'Carlos Ruiz',  'carlos@mail.com', 'Córdoba',      '2024-01-10'),
  (3, 'Ana Gómez',    'ana@mail.com',    'Rosario',      '2024-02-01'),
  (4, 'Pedro Sanz',   'pedro@mail.com',  'Mendoza',      '2024-02-15'),
  (5, 'Laura Torres', 'laura@mail.com',  'Tucumán',      '2024-03-01');

  INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
  (1, 'Laptop Pro 15',      1, 1200.00, 15, 1),
  (2, 'Mouse Inalámbrico',  2,   28.00, 80, 1),
  (3, 'Monitor 4K 27',      1,  450.00, 12, 1),
  (4, 'Auriculares BT Pro', 3,  120.00, 35, 1),
  (5, 'SSD Externo 1TB',    4,  130.00, 18, 1),
  (6, 'Teclado Mecánico',   2,   95.00, 40, 1);

  INSERT INTO ventas (id_venta, id_cliente, id_producto, cantidad, precio_unitario, fecha_venta) VALUES
  ( 1, 1, 1, 2, 1200.00, '2024-03-05'),
  ( 2, 2, 2, 5,   28.00, '2024-03-06'),
  ( 3, 3, 3, 1,  450.00, '2024-03-07'),
  ( 4, 1, 4, 2,  120.00, '2024-03-08'),
  ( 5, 4, 5, 3,  130.00, '2024-03-10'),
  ( 6, 2, 6, 4,   95.00, '2024-03-11'),
  ( 7, 5, 1, 1, 1200.00, '2024-03-12'),
  ( 8, 3, 2, 8,   28.00, '2024-03-13'),
  ( 9, 4, 4, 1,  120.00, '2024-03-14'),
  (10, 5, 3, 2,  450.00, '2024-03-15');

  === SECCIÓN 4: VALIDACIÓN ===
SELECT * FROM categorias;   -- esperado: 4 filas
SELECT * FROM clientes;     -- esperado: 5 filas
SELECT * FROM productos;    -- esperado: 6 filas
SELECT * FROM ventas;       -- esperado: 10 filas

-- Motor utilizado: SQL Server (SSMS)
-- Base de datos: Ventas_Tech_DB (creada en M3)
-- Pre-entrega M4: Consultas SQL de negocio
-- Nota: la consigna sugiere EXTRACT(MONTH FROM fecha_venta), que es sintaxis
-- de PostgreSQL/MySQL. En SQL Server el equivalente es MONTH(fecha_venta),
-- que es lo que se usa en todo este script.
 
USE Ventas_Tech_DB;
 
-- =====================================================
-- CONSULTA 1 — Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio por mes.
-- =====================================================
SELECT
    MONTH(fecha_venta)                                   AS mes,
    SUM(cantidad * precio_unitario)                      AS total_facturado,
    COUNT(*)                                             AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) / COUNT(*)           AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;
 
 
-- =====================================================
-- CONSULTA 2 — Ranking de productos
-- Top 5 de id_producto por total facturado.
-- =====================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                      AS unidades_vendidas,
    SUM(cantidad * precio_unitario)    AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;
 
 
-- =====================================================
-- CONSULTA 3 — Clientes recurrentes
-- id_cliente con más de un pedido, cantidad de pedidos y total gastado.
-- =====================================================
SELECT
    id_cliente,
    COUNT(*)                           AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)    AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;
 
 
-- =====================================================
-- CONSULTA 4 — Meses por encima/por debajo del promedio
-- Total facturado por mes, etiquetado contra el promedio mensual general.
-- =====================================================
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)                 AS mes,
        SUM(cantidad * precio_unitario)    AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_mensual
ORDER BY mes;
 
 
-- =====================================================
-- HALLAZGOS
-- =====================================================
-- 1. El producto 1 (Laptop Pro 15) concentra $3.600 de los $6.444 facturados
--    en el período, es decir, cerca del 56% del total, a pesar de representar
--    solo 3 de las unidades vendidas. Es el principal impulsor de la
--    facturación.
-- 2. El 100% de los clientes (5 de 5) realizó más de un pedido en el período,
--    por lo que no hay clientes "de una sola compra" en esta muestra. El
--    cliente 1 es el de mayor gasto ($2.640), coincidiendo con la compra del
--    producto de mayor ticket (la laptop).
-- 3. Todos los registros de venta caen en marzo de 2024, por lo que la
--    Consulta 4 no puede mostrar variación real entre meses: el total
--    facturado del único mes disponible coincide exactamente con el
--    promedio general, y por el uso de un operador estricto (>) en el
--    CASE, ese empate se etiqueta como "Por debajo" en lugar de "Igual".
--    Para ver variación mes a mes real, la base necesitaría ventas
--    distribuidas en más de un mes.