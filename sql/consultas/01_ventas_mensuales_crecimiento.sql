-- Pregunta: ¿Cómo evolucionan las ventas mes a mes y cuánto crecen contra el mes anterior
--           y contra el mismo mes del año pasado?
-- Técnicas: CTE, agregación, funciones ventana LAG
WITH mensual AS (
    SELECT strftime('%Y-%m', p.fecha)                 AS mes,
           COUNT(DISTINCT p.pedido_id)               AS pedidos,
           ROUND(SUM(d.cantidad * d.precio_unitario)) AS ingresos
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    GROUP BY mes
)
SELECT mes,
       pedidos,
       ingresos,
       ROUND(100.0 * (ingresos - LAG(ingresos, 1)  OVER (ORDER BY mes)) / LAG(ingresos, 1)  OVER (ORDER BY mes), 1) AS crec_vs_mes_ant_pct,
       ROUND(100.0 * (ingresos - LAG(ingresos, 12) OVER (ORDER BY mes)) / LAG(ingresos, 12) OVER (ORDER BY mes), 1) AS crec_interanual_pct
FROM mensual
ORDER BY mes;
