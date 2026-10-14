-- Pregunta: ¿Qué categorías se compran juntas en el mismo pedido? (base para combos y venta cruzada)
-- Métricas: soporte (% de pedidos con ambas), confianza (P(B|A)) y lift (> 1 = se compran juntas más que por azar)
-- Técnicas: self-join, subconsultas escalares
WITH cat_pedido AS (
    SELECT DISTINCT d.pedido_id, pr.categoria
    FROM detalle_pedido d
    JOIN productos pr USING (producto_id)
),
total AS (SELECT COUNT(DISTINCT pedido_id) AS n FROM cat_pedido),
freq AS (SELECT categoria, COUNT(*) AS n FROM cat_pedido GROUP BY categoria),
pares AS (
    SELECT a.categoria AS cat_a, b.categoria AS cat_b, COUNT(*) AS n_ab
    FROM cat_pedido a
    JOIN cat_pedido b ON a.pedido_id = b.pedido_id AND a.categoria < b.categoria
    GROUP BY cat_a, cat_b
)
SELECT p.cat_a || ' + ' || p.cat_b                                   AS combinacion,
       p.n_ab                                                        AS pedidos,
       ROUND(100.0 * p.n_ab / t.n, 2)                                AS soporte_pct,
       ROUND(100.0 * p.n_ab / fa.n, 1)                               AS confianza_a_b_pct,
       ROUND(1.0 * p.n_ab * t.n / (fa.n * fb.n), 2)                  AS lift
FROM pares p
CROSS JOIN total t
JOIN freq fa ON fa.categoria = p.cat_a
JOIN freq fb ON fb.categoria = p.cat_b
ORDER BY lift DESC;
