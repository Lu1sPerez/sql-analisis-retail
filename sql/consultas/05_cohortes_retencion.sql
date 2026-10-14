-- Pregunta: De los clientes que compraron por primera vez en cada trimestre,
--           ¿qué porcentaje vuelve a comprar en los trimestres siguientes?
-- Técnicas: análisis de cohortes, MIN() OVER, aritmética de fechas, pivot con CASE
-- Se excluyen clientes dados de alta antes de 2023 (no sabemos cuándo fue su primera compra real).
WITH compras AS (
    SELECT p.cliente_id,
           CAST(strftime('%Y', p.fecha) AS INTEGER) * 4 + (CAST(strftime('%m', p.fecha) AS INTEGER) - 1) / 3 AS trim_idx
    FROM pedidos p
    JOIN clientes c USING (cliente_id)
    WHERE c.fecha_alta >= '2023-01-01'
),
con_cohorte AS (
    SELECT DISTINCT cliente_id, trim_idx,
           MIN(trim_idx) OVER (PARTITION BY cliente_id) AS cohorte_idx
    FROM compras
),
tabla AS (
    SELECT cohorte_idx, trim_idx - cohorte_idx AS trimestres_despues, COUNT(DISTINCT cliente_id) AS clientes
    FROM con_cohorte
    GROUP BY cohorte_idx, trimestres_despues
)
SELECT (cohorte_idx / 4) || '-T' || (cohorte_idx % 4 + 1)                                  AS cohorte,
       MAX(CASE WHEN trimestres_despues = 0 THEN clientes END)                              AS clientes_nuevos,
       ROUND(100.0 * MAX(CASE WHEN trimestres_despues = 1 THEN clientes END) / MAX(CASE WHEN trimestres_despues = 0 THEN clientes END), 1) AS t_mas_1_pct,
       ROUND(100.0 * MAX(CASE WHEN trimestres_despues = 2 THEN clientes END) / MAX(CASE WHEN trimestres_despues = 0 THEN clientes END), 1) AS t_mas_2_pct,
       ROUND(100.0 * MAX(CASE WHEN trimestres_despues = 3 THEN clientes END) / MAX(CASE WHEN trimestres_despues = 0 THEN clientes END), 1) AS t_mas_3_pct,
       ROUND(100.0 * MAX(CASE WHEN trimestres_despues = 4 THEN clientes END) / MAX(CASE WHEN trimestres_despues = 0 THEN clientes END), 1) AS t_mas_4_pct
FROM tabla
GROUP BY cohorte_idx
ORDER BY cohorte_idx;
