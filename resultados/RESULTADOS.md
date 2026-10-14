# Resultados de las consultas

> Generado automáticamente por `scripts/ejecutar_consultas.py`. No editar a mano.

## 01 ventas mensuales crecimiento

**Pregunta:** ¿Cómo evolucionan las ventas mes a mes y cuánto crecen contra el mes anterior y contra el mismo mes del año pasado?  
**Técnicas:** CTE, agregación, funciones ventana LAG  
**Consulta:** [`01_ventas_mensuales_crecimiento.sql`](../sql/consultas/01_ventas_mensuales_crecimiento.sql)

| mes | pedidos | ingresos | crec_vs_mes_ant_pct | crec_interanual_pct |
|---|---|---|---|---|
| 2023-01 | 306 | 27.054.990 | – | – |
| 2023-02 | 187 | 16.428.330 | -39,3 | – |
| 2023-03 | 263 | 26.616.470 | 62 | – |
| 2023-04 | 278 | 26.589.915 | -0,1 | – |
| 2023-05 | 354 | 31.095.150 | 16,9 | – |
| 2023-06 | 315 | 30.164.590 | -3 | – |
| 2023-07 | 341 | 31.009.645 | 2,8 | – |
| 2023-08 | 371 | 36.155.605 | 16,6 | – |
| 2023-09 | 350 | 33.753.850 | -6,6 | – |
| 2023-10 | 391 | 36.668.240 | 8,6 | – |
| 2023-11 | 448 | 42.129.465 | 14,9 | – |
| 2023-12 | 618 | 58.952.670 | 39,9 | – |
| 2024-01 | 313 | 27.724.860 | -53 | 2,5 |
| 2024-02 | 322 | 28.210.410 | 1,8 | 71,7 |
| 2024-03 | 411 | 38.787.475 | 37,5 | 45,7 |
| 2024-04 | 423 | 40.661.495 | 4,8 | 52,9 |
| 2024-05 | 493 | 43.155.020 | 6,1 | 38,8 |
| 2024-06 | 406 | 38.065.710 | -11,8 | 26,2 |
| 2024-07 | 427 | 41.767.825 | 9,7 | 34,7 |
| 2024-08 | 433 | 41.219.410 | -1,3 | 14 |
| 2024-09 | 360 | 34.517.200 | -16,3 | 2,3 |
| 2024-10 | 392 | 37.593.375 | 8,9 | 2,5 |
| 2024-11 | 485 | 44.854.650 | 19,3 | 6,5 |
| 2024-12 | 662 | 63.498.220 | 41,6 | 7,7 |

## 02 pareto productos

**Pregunta:** ¿Qué porcentaje de los productos genera el 80% de los ingresos? (análisis de Pareto / ABC)  
**Técnicas:** SUM() OVER con orden (acumulado), clasificación con CASE  
**Consulta:** [`02_pareto_productos.sql`](../sql/consultas/02_pareto_productos.sql)

| clase | productos | pct_del_catalogo | ingresos |
|---|---|---|---|
| A (80% de ingresos) | 31 | 27,9 | 700.209.315 |
| B (siguiente 15%) | 33 | 29,7 | 130.523.075 |
| C (último 5%) | 47 | 42,3 | 45.942.180 |

## 03 top productos por categoria

**Pregunta:** ¿Cuáles son los 3 productos más vendidos de cada categoría y qué margen dejan?  
**Técnicas:** RANK() OVER (PARTITION BY ...), cálculo de margen  
**Consulta:** [`03_top_productos_por_categoria.sql`](../sql/consultas/03_top_productos_por_categoria.sql)

| categoria | puesto | nombre | unidades | ingresos | margen_pct |
|---|---|---|---|---|---|
| Accesorios | 1 | Riñonera Puma | 428 | 8.217.000 | 64,6 |
| Accesorios | 2 | Gorra Nike | 429 | 6.918.880 | 58,5 |
| Accesorios | 3 | Mochila Nike | 296 | 5.749.605 | 55,7 |
| Buzos | 1 | Buzo Polar Nike | 517 | 41.258.880 | 46,5 |
| Buzos | 2 | Buzo Polar New Balance | 266 | 22.942.240 | 50 |
| Buzos | 3 | Buzo Cuello redondo Topper | 159 | 12.015.430 | 48,7 |
| Pantalones | 1 | Pantalón Short New Balance | 297 | 19.020.960 | 43 |
| Pantalones | 2 | Pantalón Short Topper | 242 | 14.774.220 | 52,8 |
| Pantalones | 3 | Pantalón Jogger Adidas | 143 | 9.917.050 | 53,1 |
| Remeras | 1 | Remera Algodón Nike | 529 | 23.010.020 | 51 |
| Remeras | 2 | Remera Algodón New Balance | 400 | 11.991.720 | 52 |
| Remeras | 3 | Remera Dry-fit New Balance | 322 | 8.510.775 | 50,4 |
| Zapatillas | 1 | Zapatilla Basket Nike | 775 | 97.431.890 | 41,9 |
| Zapatillas | 2 | Zapatilla Running Topper | 526 | 60.596.350 | 44,2 |
| Zapatillas | 3 | Zapatilla Training Fila | 565 | 58.550.400 | 39,1 |

## 04 ticket por canal

**Pregunta:** ¿El canal online vende tickets más altos que las tiendas físicas? ¿Cómo evolucionó su participación?  
**Técnicas:** subconsulta por pedido, agregación condicional  
**Consulta:** [`04_ticket_por_canal.sql`](../sql/consultas/04_ticket_por_canal.sql)

| anio | canal | pedidos | ticket_promedio | unidades_por_pedido | participacion_ingresos_pct |
|---|---|---|---|---|---|
| 2023 | Online | 1.686 | 95.663 | 1,5 | 40,7 |
| 2023 | Tienda física | 2.536 | 92.796 | 1,47 | 59,3 |
| 2024 | Online | 2.570 | 94.352 | 1,49 | 50,5 |
| 2024 | Tienda física | 2.557 | 92.910 | 1,47 | 49,5 |

## 05 cohortes retencion

**Pregunta:** De los clientes que compraron por primera vez en cada trimestre, ¿qué porcentaje vuelve a comprar en los trimestres siguientes? Se excluyen clientes dados de alta antes de 2023 (no sabemos cuándo fue su primera compra real).  
**Técnicas:** análisis de cohortes, MIN() OVER, aritmética de fechas, pivot con CASE  
**Consulta:** [`05_cohortes_retencion.sql`](../sql/consultas/05_cohortes_retencion.sql)

| cohorte | clientes_nuevos | t_mas_1_pct | t_mas_2_pct | t_mas_3_pct | t_mas_4_pct |
|---|---|---|---|---|---|
| 2023-T1 | 125 | 40,8 | 29,6 | 24,8 | 16,8 |
| 2023-T2 | 187 | 47,1 | 34,8 | 27,8 | 22,5 |
| 2023-T3 | 213 | 49,8 | 36,6 | 32,4 | 19,7 |
| 2023-T4 | 237 | 40,5 | 35 | 20,7 | 19,8 |
| 2024-T1 | 176 | 43,8 | 33 | 29,5 | – |
| 2024-T2 | 207 | 42 | 36,7 | – | – |
| 2024-T3 | 237 | 38,8 | – | – | – |
| 2024-T4 | 241 | – | – | – | – |

## 06 segmentacion rfm

**Pregunta:** ¿Cómo se segmentan los clientes según Recencia, Frecuencia y Monto (RFM) y cuánto aporta cada segmento?  
**Técnicas:** NTILE() para quintiles, julianday() para recencia, reglas de negocio con CASE  
**Consulta:** [`06_segmentacion_rfm.sql`](../sql/consultas/06_segmentacion_rfm.sql)

| segmento | clientes | pct_clientes | pct_ingresos | recencia_prom_dias | pedidos_prom |
|---|---|---|---|---|---|
| 1. Campeones | 434 | 21,3 | 51,3 | 44 | 10,9 |
| 2. Leales | 404 | 19,8 | 22,2 | 179 | 5,2 |
| 3. Nuevos / prometedores | 227 | 11,1 | 2,2 | 77 | 1 |
| 4. En riesgo (eran buenos) | 383 | 18,8 | 18,9 | 498 | 4,4 |
| 5. Necesitan atención | 156 | 7,7 | 1,5 | 248 | 1 |
| 6. Perdidos | 433 | 21,3 | 3,9 | 592 | 1 |

## 07 clientes en riesgo

**Pregunta:** ¿Qué clientes valiosos dejaron de comprar? (lista accionable para una campaña de reactivación) Criterio: 4+ pedidos históricos, gasto en el 20% superior y más de 120 días sin comprar.  
**Técnicas:** HAVING, PERCENT_RANK(), intervalo promedio entre compras con LAG  
**Consulta:** [`07_clientes_en_riesgo.sql`](../sql/consultas/07_clientes_en_riesgo.sql)

| cliente_id | provincia | pedidos | gasto_total | intervalo_habitual_dias | dias_sin_comprar | veces_su_intervalo |
|---|---|---|---|---|---|---|
| 484 | Buenos Aires | 68 | 5.675.455 | 6 | 320 | 53,3 |
| 626 | Santa Fe | 50 | 4.755.795 | 10 | 213 | 21,3 |
| 1.005 | Buenos Aires | 39 | 3.448.685 | 14 | 140 | 10 |
| 1.187 | Buenos Aires | 31 | 2.957.760 | 10 | 299 | 29,9 |
| 1.324 | Buenos Aires | 31 | 2.917.155 | 11 | 195 | 17,7 |
| 601 | CABA | 25 | 2.730.295 | 22 | 170 | 7,7 |
| 1.281 | Buenos Aires | 29 | 2.707.625 | 11 | 232 | 21,1 |
| 1.224 | Córdoba | 31 | 2.539.240 | 8 | 342 | 42,8 |
| 821 | CABA | 23 | 2.464.600 | 18 | 323 | 17,9 |
| 1.043 | Chubut | 23 | 2.292.430 | 14 | 346 | 24,7 |
| 529 | Buenos Aires | 25 | 2.255.420 | 20 | 187 | 9,3 |
| 159 | CABA | 18 | 2.248.770 | 18 | 399 | 22,2 |
| 1.541 | Santa Fe | 23 | 2.205.130 | 14 | 132 | 9,4 |
| 1.061 | Santa Fe | 24 | 2.203.735 | 20 | 188 | 9,4 |
| 1.311 | Santa Fe | 18 | 2.147.870 | 10 | 320 | 32 |

## 08 margen por marca

**Pregunta:** ¿Qué marcas dejan más margen bruto y cuánto dependen de las zapatillas? ¿Hay marcas que venden mucho pero con poco margen?  
**Técnicas:** agregación multinivel, participación sobre el total con ventana  
**Consulta:** [`08_margen_por_marca.sql`](../sql/consultas/08_margen_por_marca.sql)

| marca | ingresos | margen_bruto | margen_pct | participacion_ventas_pct | pct_ventas_en_zapatillas |
|---|---|---|---|---|---|
| Nike | 288.730.120 | 129.714.120 | 44,9 | 32,9 | 60,6 |
| Topper | 129.134.115 | 61.146.515 | 47,4 | 14,7 | 57,4 |
| New Balance | 114.176.000 | 55.689.100 | 48,8 | 13 | 8,1 |
| Puma | 114.855.215 | 49.619.615 | 43,2 | 13,1 | 72,9 |
| Fila | 115.924.130 | 47.652.930 | 41,1 | 13,2 | 78 |
| Adidas | 113.854.990 | 47.537.290 | 41,8 | 13 | 54,5 |

## 09 cobertura stock

**Pregunta:** ¿Qué productos se van a quedar sin stock en las próximas 2 semanas en cada tienda? Cobertura = stock actual / venta diaria promedio de las últimas 8 semanas.  
**Técnicas:** CTE con filtro de fechas relativo, NULLIF para evitar división por cero, CASE para priorizar  
**Consulta:** [`09_cobertura_stock.sql`](../sql/consultas/09_cobertura_stock.sql)

| tienda | producto | stock_actual | venta_semanal | dias_de_cobertura | accion |
|---|---|---|---|---|---|
| Tienda Shopping | Riñonera New Balance | 3 | 1,9 | 11,2 | Reponer esta semana |
| E-commerce | Gorra Nike | 6 | 3,8 | 11,2 | Reponer esta semana |
| Tienda Centro | Remera Algodón Nike | 3 | 1,6 | 12,9 | Reponer esta semana |

## 10 impacto eventos descuento

**Pregunta:** ¿Los eventos de descuento (Hot Sale, Cyber Monday) generan ventas incrementales o solo adelantan compras y erosionan el margen?  
**Técnicas:** clasificación de fechas con CASE, comparación contra días normales  
**Consulta:** [`10_impacto_eventos_descuento.sql`](../sql/consultas/10_impacto_eventos_descuento.sql)

| tipo_dia | dias | pedidos_por_dia | ingresos_por_dia | veces_un_dia_normal | margen_pct |
|---|---|---|---|---|---|
| Cyber Monday | 6 | 39,3 | 2.959.588 | 2,69 | 28,4 |
| Hot Sale | 6 | 33,3 | 2.386.600 | 2,17 | 28,4 |
| Fiestas | 48 | 23,2 | 2.209.131 | 2,01 | 45,9 |
| Día normal | 671 | 11,6 | 1.100.684 | 1 | 45,2 |

## 11 media movil ventas

**Pregunta:** ¿Cuál es la tendencia de ventas diarias sin el ruido día a día? (últimos 30 días de 2024)  
**Técnicas:** marco de ventana ROWS BETWEEN para media móvil de 7 y 28 días  
**Consulta:** [`11_media_movil_ventas.sql`](../sql/consultas/11_media_movil_ventas.sql)

| fecha | ingresos | media_movil_7d | media_movil_28d |
|---|---|---|---|
| 2024-12-02 | 2.291.650 | 1.583.242 | 1.568.985 |
| 2024-12-03 | 2.507.600 | 1.777.328 | 1.548.533 |
| 2024-12-04 | 3.032.200 | 2.113.682 | 1.574.880 |
| 2024-12-05 | 3.970.210 | 2.522.286 | 1.653.019 |
| 2024-12-06 | 1.398.845 | 2.587.706 | 1.662.767 |
| 2024-12-07 | 2.039.570 | 2.622.169 | 1.686.645 |
| 2024-12-08 | 2.814.025 | 2.579.157 | 1.715.439 |
| 2024-12-09 | 1.151.430 | 2.416.269 | 1.701.673 |
| 2024-12-10 | 1.542.565 | 2.278.406 | 1.732.618 |
| 2024-12-11 | 2.719.405 | 2.233.721 | 1.770.622 |
| 2024-12-12 | 2.012.870 | 1.954.101 | 1.798.264 |
| 2024-12-13 | 2.043.545 | 2.046.201 | 1.821.639 |
| 2024-12-14 | 2.588.535 | 2.124.625 | 1.866.508 |
| 2024-12-15 | 3.362.775 | 2.203.018 | 1.946.047 |
| 2024-12-16 | 2.874.830 | 2.449.218 | 1.986.392 |
| 2024-12-17 | 2.315.895 | 2.559.694 | 2.023.053 |
| 2024-12-18 | 2.360.910 | 2.508.480 | 2.031.782 |
| 2024-12-19 | 2.020.285 | 2.509.539 | 2.047.245 |
| 2024-12-20 | 998.700 | 2.360.276 | 2.048.249 |
| 2024-12-21 | 2.043.700 | 2.282.442 | 2.077.181 |
| 2024-12-22 | 2.151.385 | 2.109.386 | 2.091.941 |
| 2024-12-23 | 1.335.020 | 1.889.414 | 2.084.536 |
| 2024-12-24 | 2.646.000 | 1.936.571 | 2.138.000 |
| 2024-12-25 | 821.435 | 1.716.646 | 2.143.133 |
| 2024-12-26 | 1.532.300 | 1.646.934 | 2.158.215 |

*… 5 filas más*

## 12 analisis canasta

**Pregunta:** ¿Qué categorías se compran juntas en el mismo pedido? (base para combos y venta cruzada) Métricas: soporte (% de pedidos con ambas), confianza (P(B|A)) y lift (> 1 = se compran juntas más que por azar)  
**Técnicas:** self-join, subconsultas escalares  
**Consulta:** [`12_analisis_canasta.sql`](../sql/consultas/12_analisis_canasta.sql)

| combinacion | pedidos | soporte_pct | confianza_a_b_pct | lift |
|---|---|---|---|---|
| Accesorios + Zapatillas | 1.688 | 18,06 | 53,3 | 1,26 |
| Pantalones + Remeras | 238 | 2,55 | 12,8 | 0,45 |
| Remeras + Zapatillas | 502 | 5,37 | 19,1 | 0,45 |
| Buzos + Remeras | 199 | 2,13 | 12,4 | 0,44 |
| Buzos + Zapatillas | 297 | 3,18 | 18,5 | 0,44 |
| Pantalones + Zapatillas | 331 | 3,54 | 17,8 | 0,42 |
| Buzos + Pantalones | 124 | 1,33 | 7,7 | 0,39 |
| Accesorios + Pantalones | 230 | 2,46 | 7,3 | 0,36 |
| Accesorios + Buzos | 191 | 2,04 | 6 | 0,35 |
| Accesorios + Remeras | 311 | 3,33 | 9,8 | 0,35 |
