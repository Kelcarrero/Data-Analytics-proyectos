

USE Ventas_Tech_DB;


IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = 6)
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro)
    VALUES (6, 'Sofía Díaz', 'sofia@mail.com', 'La Plata', '2024-03-20');

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = 7)
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo)
    VALUES (7, 'Webcam HD', 2, 65.00, 25, 1);
GO

-- =====================================================================
-- CONSULTA 1: Vista base del proyecto (INNER JOIN)
-- Una fila por venta con los datos de cliente, producto y categoría.
-- Columna para agrupar: nombre_categoria / region
-- Columna para filtrar: ciudad / region / fecha_venta
-- =====================================================================

SELECT
    v.id_venta,
    v.fecha_venta,
    c.id_cliente,
    c.nombre                              AS nombre_cliente,
    c.ciudad,
    CASE
        WHEN c.ciudad = 'Buenos Aires' THEN 'Capital'
        ELSE 'Interior'
    END                                   AS region,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario        AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;


-- =====================================================================
-- CONSULTA 2: Clientes sin ventas (LEFT JOIN + IS NULL)
-- El LEFT JOIN conserva todos los clientes; los que no tienen ventas
-- quedan con las columnas de ventas en NULL.
-- =====================================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- =====================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN + IS NULL)
-- LEFT JOIN a categorias también, para no perder un producto que
-- no tenga categoría asignada.
-- =====================================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos AS p
LEFT JOIN ventas     AS v   ON p.id_producto  = v.id_producto
LEFT JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;


-- =====================================================================
-- CONSULTA 4: Consolidado por canal (UNION ALL + GROUP BY)
-- Criterio: ubicación del cliente. 'Capital' = Buenos Aires,
-- 'Interior' = resto de las ciudades.
-- La columna canal NO existe en las tablas: se crea como texto fijo
-- en cada SELECT. UNION ALL (y no UNION) para no eliminar filas
-- repetidas: cada venta se cuenta exactamente una vez.
-- =====================================================================

SELECT
    canal,
    COUNT(*)    AS cantidad_ventas,
    SUM(total)  AS total_ventas
FROM (
    SELECT
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Capital' AS canal
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad = 'Buenos Aires'

    UNION ALL

    SELECT
        v.fecha_venta,
        v.cantidad * v.precio_unitario AS total,
        'Interior' AS canal
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad <> 'Buenos Aires'
) AS consolidado
GROUP BY canal
ORDER BY total_ventas DESC;

