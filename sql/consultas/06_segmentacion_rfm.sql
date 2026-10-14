-- Pregunta: ¿Cómo se segmentan los clientes según Recencia, Frecuencia y Monto (RFM)
--           y cuánto aporta cada segmento?
-- Técnicas: NTILE() para quintiles, julianday() para recencia, reglas de negocio con CASE
WITH base AS (
    SELECT p.cliente_id,
           julianday('2024-12-31') - julianday(MAX(p.fecha)) AS dias_desde_ultima,
           COUNT(DISTINCT p.pedido_id)                       AS frecuencia,
           SUM(d.cantidad * d.precio_unitario)               AS monto
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    GROUP BY p.cliente_id
),
puntajes AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY dias_desde_ultima DESC) AS r,   -- 5 = compró hace poco
           NTILE(5) OVER (ORDER BY frecuencia)             AS f,
           NTILE(5) OVER (ORDER BY monto)                  AS m
    FROM base
),
segmentos AS (
    SELECT *,
           CASE
               WHEN r >= 4 AND f >= 4                 THEN '1. Campeones'
               WHEN r >= 3 AND f >= 3                 THEN '2. Leales'
               WHEN r >= 4 AND f <= 2                 THEN '3. Nuevos / prometedores'
               WHEN r <= 2 AND f >= 3                 THEN '4. En riesgo (eran buenos)'
               WHEN r <= 2 AND f <= 2                 THEN '6. Perdidos'
               ELSE                                        '5. Necesitan atención'
           END AS segmento
    FROM puntajes
)
SELECT segmento,
       COUNT(*)                                              AS clientes,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)    AS pct_clientes,
       ROUND(100.0 * SUM(monto) / SUM(SUM(monto)) OVER (), 1) AS pct_ingresos,
       ROUND(AVG(dias_desde_ultima))                         AS recencia_prom_dias,
       ROUND(AVG(frecuencia), 1)                             AS pedidos_prom
FROM segmentos
GROUP BY segmento
ORDER BY segmento;
