-- Pregunta: ¿Cuáles son los 3 productos más vendidos de cada categoría y qué margen dejan?
-- Técnicas: RANK() OVER (PARTITION BY ...), cálculo de margen
WITH ventas AS (
    SELECT pr.categoria, pr.nombre,
           SUM(d.cantidad)                                       AS unidades,
           SUM(d.cantidad * d.precio_unitario)                   AS ingresos,
           SUM(d.cantidad * (d.precio_unitario - pr.costo))      AS margen_bruto
    FROM detalle_pedido d
    JOIN productos pr USING (producto_id)
    GROUP BY pr.producto_id
),
ranking AS (
    SELECT *, RANK() OVER (PARTITION BY categoria ORDER BY ingresos DESC) AS puesto
    FROM ventas
)
SELECT categoria, puesto, nombre, unidades,
       ROUND(ingresos)                          AS ingresos,
       ROUND(100.0 * margen_bruto / ingresos, 1) AS margen_pct
FROM ranking
WHERE puesto <= 3
ORDER BY categoria, puesto;
