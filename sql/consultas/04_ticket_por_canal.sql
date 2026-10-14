-- Pregunta: ¿El canal online vende tickets más altos que las tiendas físicas? ¿Cómo evolucionó su participación?
-- Técnicas: subconsulta por pedido, agregación condicional
WITH tickets AS (
    SELECT p.pedido_id, t.canal, strftime('%Y', p.fecha) AS anio,
           SUM(d.cantidad * d.precio_unitario) AS total,
           SUM(d.cantidad)                     AS unidades
    FROM pedidos p
    JOIN tiendas t        USING (tienda_id)
    JOIN detalle_pedido d USING (pedido_id)
    GROUP BY p.pedido_id
)
SELECT anio, canal,
       COUNT(*)                     AS pedidos,
       ROUND(AVG(total))            AS ticket_promedio,
       ROUND(AVG(unidades), 2)      AS unidades_por_pedido,
       ROUND(100.0 * SUM(total) / SUM(SUM(total)) OVER (PARTITION BY anio), 1) AS participacion_ingresos_pct
FROM tickets
GROUP BY anio, canal
ORDER BY anio, canal;
