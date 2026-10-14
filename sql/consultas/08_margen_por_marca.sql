-- Pregunta: ¿Qué marcas dejan más margen bruto y cuánto dependen de las zapatillas?
--           ¿Hay marcas que venden mucho pero con poco margen?
-- Técnicas: agregación multinivel, participación sobre el total con ventana
SELECT pr.marca,
       ROUND(SUM(d.cantidad * d.precio_unitario))                                   AS ingresos,
       ROUND(SUM(d.cantidad * (d.precio_unitario - pr.costo)))                      AS margen_bruto,
       ROUND(100.0 * SUM(d.cantidad * (d.precio_unitario - pr.costo))
                   / SUM(d.cantidad * d.precio_unitario), 1)                        AS margen_pct,
       ROUND(100.0 * SUM(d.cantidad * d.precio_unitario)
                   / SUM(SUM(d.cantidad * d.precio_unitario)) OVER (), 1)           AS participacion_ventas_pct,
       ROUND(100.0 * SUM(CASE WHEN pr.categoria = 'Zapatillas' THEN d.cantidad * d.precio_unitario END)
                   / SUM(d.cantidad * d.precio_unitario), 1)                        AS pct_ventas_en_zapatillas
FROM detalle_pedido d
JOIN productos pr USING (producto_id)
GROUP BY pr.marca
ORDER BY margen_bruto DESC;
