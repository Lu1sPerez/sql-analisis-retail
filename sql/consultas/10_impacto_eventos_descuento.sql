-- Pregunta: ¿Los eventos de descuento (Hot Sale, Cyber Monday) generan ventas incrementales
--           o solo adelantan compras y erosionan el margen?
-- Técnicas: clasificación de fechas con CASE, comparación contra días normales
WITH diario AS (
    SELECT p.fecha,
           CASE
               WHEN strftime('%m', p.fecha) = '05' AND CAST(strftime('%d', p.fecha) AS INT) BETWEEN 13 AND 15 THEN 'Hot Sale'
               WHEN strftime('%m', p.fecha) = '11' AND CAST(strftime('%d', p.fecha) AS INT) BETWEEN 4 AND 6   THEN 'Cyber Monday'
               WHEN strftime('%m', p.fecha) = '12' AND CAST(strftime('%d', p.fecha) AS INT) <= 24            THEN 'Fiestas'
               ELSE 'Día normal'
           END                                                        AS tipo_dia,
           SUM(d.cantidad * d.precio_unitario)                        AS ingresos,
           SUM(d.cantidad * (d.precio_unitario - pr.costo))           AS margen,
           COUNT(DISTINCT p.pedido_id)                                AS pedidos
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    JOIN productos pr     USING (producto_id)
    GROUP BY p.fecha
)
SELECT tipo_dia,
       COUNT(*)                                     AS dias,
       ROUND(AVG(pedidos), 1)                       AS pedidos_por_dia,
       ROUND(AVG(ingresos))                         AS ingresos_por_dia,
       ROUND(AVG(ingresos) / (SELECT AVG(ingresos) FROM diario WHERE tipo_dia = 'Día normal'), 2) AS veces_un_dia_normal,
       ROUND(100.0 * SUM(margen) / SUM(ingresos), 1) AS margen_pct
FROM diario
GROUP BY tipo_dia
ORDER BY ingresos_por_dia DESC;
