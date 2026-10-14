-- Pregunta: ¿Qué productos se van a quedar sin stock en las próximas 2 semanas en cada tienda?
-- Cobertura = stock actual / venta diaria promedio de las últimas 8 semanas.
-- Técnicas: CTE con filtro de fechas relativo, NULLIF para evitar división por cero, CASE para priorizar
WITH venta_reciente AS (
    SELECT p.tienda_id, d.producto_id,
           SUM(d.cantidad) / 56.0 AS venta_diaria
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    WHERE p.fecha > date('2024-12-31', '-56 days')
    GROUP BY p.tienda_id, d.producto_id
)
SELECT t.nombre                                AS tienda,
       pr.nombre                               AS producto,
       s.unidades                              AS stock_actual,
       ROUND(v.venta_diaria * 7, 1)            AS venta_semanal,
       ROUND(s.unidades / NULLIF(v.venta_diaria, 0), 1) AS dias_de_cobertura,
       CASE WHEN s.unidades = 0 THEN 'SIN STOCK'
            WHEN s.unidades / v.venta_diaria < 7 THEN 'Reponer urgente'
            ELSE 'Reponer esta semana' END     AS accion
FROM stock s
JOIN tiendas t   USING (tienda_id)
JOIN productos pr USING (producto_id)
JOIN venta_reciente v ON v.tienda_id = s.tienda_id AND v.producto_id = s.producto_id
WHERE s.unidades / NULLIF(v.venta_diaria, 0) < 14 OR s.unidades = 0
ORDER BY dias_de_cobertura
LIMIT 15;
