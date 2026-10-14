-- Pregunta: ¿Qué clientes valiosos dejaron de comprar? (lista accionable para una campaña de reactivación)
-- Criterio: 4+ pedidos históricos, gasto en el 20% superior y más de 120 días sin comprar.
-- Técnicas: HAVING, PERCENT_RANK(), intervalo promedio entre compras con LAG
WITH pedidos_cliente AS (
    SELECT p.cliente_id, p.pedido_id, p.fecha,
           SUM(d.cantidad * d.precio_unitario) AS total,
           julianday(p.fecha) - julianday(LAG(p.fecha) OVER (PARTITION BY p.cliente_id ORDER BY p.fecha)) AS dias_desde_anterior
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    GROUP BY p.pedido_id
),
resumen AS (
    SELECT cliente_id,
           COUNT(*)                                          AS pedidos,
           ROUND(SUM(total))                                 AS gasto_total,
           ROUND(AVG(dias_desde_anterior))                   AS intervalo_habitual_dias,
           CAST(julianday('2024-12-31') - julianday(MAX(fecha)) AS INTEGER) AS dias_sin_comprar
    FROM pedidos_cliente
    GROUP BY cliente_id
    HAVING COUNT(*) >= 4
),
rankeado AS (
    SELECT *, PERCENT_RANK() OVER (ORDER BY gasto_total) AS pct_rank FROM resumen
)
SELECT r.cliente_id, c.provincia, r.pedidos, r.gasto_total, r.intervalo_habitual_dias, r.dias_sin_comprar,
       ROUND(1.0 * r.dias_sin_comprar / r.intervalo_habitual_dias, 1) AS veces_su_intervalo
FROM rankeado r
JOIN clientes c USING (cliente_id)
WHERE r.pct_rank >= 0.8
  AND r.dias_sin_comprar > 120
ORDER BY r.gasto_total DESC
LIMIT 15;
