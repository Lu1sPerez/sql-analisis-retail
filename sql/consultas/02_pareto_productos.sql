-- Pregunta: ¿Qué porcentaje de los productos genera el 80% de los ingresos? (análisis de Pareto / ABC)
-- Técnicas: SUM() OVER con orden (acumulado), clasificación con CASE
WITH por_producto AS (
    SELECT pr.producto_id, pr.nombre, pr.categoria,
           SUM(d.cantidad * d.precio_unitario) AS ingresos
    FROM detalle_pedido d
    JOIN productos pr USING (producto_id)
    GROUP BY pr.producto_id
),
acumulado AS (
    SELECT *,
           100.0 * SUM(ingresos) OVER (ORDER BY ingresos DESC ROWS UNBOUNDED PRECEDING)
                 / SUM(ingresos) OVER ()                        AS pct_acumulado,
           ROW_NUMBER() OVER (ORDER BY ingresos DESC)            AS ranking,
           COUNT(*) OVER ()                                      AS total_productos
    FROM por_producto
)
SELECT CASE WHEN pct_acumulado <= 80 THEN 'A (80% de ingresos)'
            WHEN pct_acumulado <= 95 THEN 'B (siguiente 15%)'
            ELSE 'C (último 5%)' END                AS clase,
       COUNT(*)                                     AS productos,
       ROUND(100.0 * COUNT(*) / MAX(total_productos), 1) AS pct_del_catalogo,
       ROUND(SUM(ingresos))                         AS ingresos
FROM acumulado
GROUP BY clase
ORDER BY clase;
