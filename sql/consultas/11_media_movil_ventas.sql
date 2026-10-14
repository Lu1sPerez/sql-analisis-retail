-- Pregunta: ¿Cuál es la tendencia de ventas diarias sin el ruido día a día? (últimos 30 días de 2024)
-- Técnicas: marco de ventana ROWS BETWEEN para media móvil de 7 y 28 días
WITH diario AS (
    SELECT p.fecha, SUM(d.cantidad * d.precio_unitario) AS ingresos
    FROM pedidos p
    JOIN detalle_pedido d USING (pedido_id)
    GROUP BY p.fecha
),
movil AS (
    SELECT fecha,
           ROUND(ingresos) AS ingresos,
           ROUND(AVG(ingresos) OVER (ORDER BY fecha ROWS BETWEEN 6 PRECEDING AND CURRENT ROW))  AS media_movil_7d,
           ROUND(AVG(ingresos) OVER (ORDER BY fecha ROWS BETWEEN 27 PRECEDING AND CURRENT ROW)) AS media_movil_28d
    FROM diario
)
SELECT * FROM movil
WHERE fecha > date('2024-12-31', '-30 days')
ORDER BY fecha;
