USE Ventas_Tech_DB;
GO
 
 
/* =====================================================================
   CONSULTA 1 - Vista base del proyecto (INNER JOIN)
   Fuente principal de datos para Power BI.
   - Columna para agrupar: categoria
   - Columna para filtrar: ciudad
   Resultado esperado: 10 filas (una por venta)
   ===================================================================== */
 
SELECT
    v.id_venta,
    v.fecha_venta                    AS fecha,
    c.id_cliente,
    c.nombre                         AS cliente,
    c.ciudad,
    p.nombre_producto                AS producto,
    cat.nombre_categoria             AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario   AS total_venta
FROM ventas AS v
INNER JOIN clientes   AS c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  AS p   ON v.id_producto  = p.id_producto
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
 
 
/* =====================================================================
   CONSULTA 2 - Clientes sin ventas (LEFT JOIN + IS NULL)
   Para el área de CRM.
   Resultado esperado: Jorge Díaz y Sofía Martín
   ===================================================================== */
 
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;
 
 
/* =====================================================================
   CONSULTA 3 - Productos sin ventas (LEFT JOIN + IS NULL)
   Para el área de producto.
   Resultado esperado: Webcam HD y Pendrive 64GB
   ===================================================================== */
 
SELECT
    p.nombre_producto     AS producto,
    cat.nombre_categoria  AS categoria,
    p.precio
FROM productos AS p
INNER JOIN categorias AS cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas      AS v   ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL
ORDER BY cat.nombre_categoria, p.nombre_producto;
 
 
/* =====================================================================
   CONSULTA 4 - Consolidado por canal (UNION ALL + GROUP BY)
   La columna "canal" NO existe en las tablas: se crea como texto fijo
   en cada SELECT.
   Criterio de separación: origen del cliente
     - 'Capital'  -> clientes de Buenos Aires
     - 'Interior' -> clientes del resto del país
   Se usa UNION ALL (y no UNION) para que no se eliminen filas
   repetidas: cada venta se cuenta una sola vez.
   Resultado esperado:
     Capital   ->  2 ventas -> 2640.00
     Interior  ->  8 ventas -> 3804.00
   ===================================================================== */
 
SELECT
    canal,
    COUNT(*)          AS cantidad_ventas,
    SUM(total_venta)  AS total_por_canal
FROM (
    SELECT
        v.fecha_venta                    AS fecha,
        v.cantidad * v.precio_unitario   AS total_venta,
        'Capital'                        AS canal
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad = 'Buenos Aires'
 
    UNION ALL
 
    SELECT
        v.fecha_venta                    AS fecha,
        v.cantidad * v.precio_unitario   AS total_venta,
        'Interior'                       AS canal
    FROM ventas AS v
    INNER JOIN clientes AS c ON v.id_cliente = c.id_cliente
    WHERE c.ciudad <> 'Buenos Aires'
) AS consolidado
GROUP BY canal
ORDER BY canal;
