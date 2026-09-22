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