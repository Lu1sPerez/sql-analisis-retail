"""
Crea la base SQLite `retail.db` con datos sintéticos reproducibles.

Patrones incluidos: clientes con distinta frecuencia de compra y abandono (churn),
estacionalidad (Hot Sale en mayo, Cyber Monday en noviembre, fiestas en diciembre),
crecimiento del canal online y canastas con productos complementarios.

    python scripts/crear_base.py
"""
import sqlite3
from datetime import date, timedelta
from pathlib import Path

import numpy as np

RAIZ = Path(__file__).resolve().parents[1]
DB = RAIZ / "retail.db"
rng = np.random.default_rng(7)

INICIO, FIN = date(2023, 1, 1), date(2024, 12, 31)
DIAS = (FIN - INICIO).days + 1

TIENDAS = [
    (1, "Tienda Centro", "Tienda física", "La Plata"),
    (2, "Tienda Shopping", "Tienda física", "Buenos Aires"),
    (3, "Tienda Patagonia", "Tienda física", "Comodoro Rivadavia"),
    (4, "E-commerce", "Online", "Nacional"),
]
PROVINCIAS = ["Buenos Aires", "CABA", "Córdoba", "Santa Fe", "Mendoza", "Chubut", "Santa Cruz", "Neuquén"]
PESO_PROV = [0.34, 0.20, 0.10, 0.09, 0.07, 0.08, 0.06, 0.06]
MARCAS = ["Nike", "Adidas", "Puma", "New Balance", "Topper", "Fila"]
CATEGORIAS = {  # categoria: (precio base, margen medio, peso en ventas, modelos)
    "Zapatillas": (120000, 0.42, 0.34, ["Running", "Urbana", "Training", "Basket", "Retro"]),
    "Remeras":    (28000, 0.55, 0.22, ["Dry-fit", "Algodón", "Oversize", "Estampada"]),
    "Buzos":      (65000, 0.50, 0.14, ["Hoodie", "Cuello redondo", "Polar"]),
    "Pantalones": (55000, 0.50, 0.15, ["Jogger", "Short", "Calza", "Cargo"]),
    "Accesorios": (15000, 0.62, 0.15, ["Medias x3", "Gorra", "Mochila", "Riñonera"]),
}

SINGULAR = {"Zapatillas": "Zapatilla", "Remeras": "Remera", "Buzos": "Buzo", "Pantalones": "Pantalón", "Accesorios": ""}


def eventos(d: date) -> tuple[float, float]:
    """Multiplicador de demanda y descuento promedio para una fecha."""
    if d.month == 5 and 13 <= d.day <= 15:   # Hot Sale
        return 3.0, 0.25
    if d.month == 11 and 4 <= d.day <= 6:    # Cyber Monday
        return 3.2, 0.25
    if d.month == 12 and d.day <= 24:        # Fiestas
        return 1.8, 0.0
    if d.month in (1, 2):                    # vacaciones
        return 0.8, 0.10
    return 1.0, 0.0


def main() -> None:
    DB.unlink(missing_ok=True)
    con = sqlite3.connect(DB)
    con.executescript((RAIZ / "sql" / "schema.sql").read_text(encoding="utf-8"))
    con.executemany("INSERT INTO tiendas VALUES (?,?,?,?)", TIENDAS)

    # --- productos
    productos, pid = [], 1
    for cat, (precio, margen, _, modelos) in CATEGORIAS.items():
        for marca in MARCAS:
            for modelo in rng.choice(modelos, size=min(4, len(modelos)), replace=False):
                p = round(precio * rng.uniform(0.7, 1.5) * (1.15 if marca in ("Nike", "Adidas") else 1), -2)
                c = round(p * (1 - rng.normal(margen, 0.05)), -2)
                productos.append((pid, f"{SINGULAR[cat]} {modelo} {marca}".strip(), marca, cat, p, c))
                pid += 1
    con.executemany("INSERT INTO productos VALUES (?,?,?,?,?,?)", productos)
    prod_por_cat = {cat: [p for p in productos if p[3] == cat] for cat in CATEGORIAS}
    # popularidad dentro de cada categoría (pocos productos venden mucho: Pareto)
    popularidad = {cat: rng.dirichlet(np.ones(len(ps)) * 0.6) for cat, ps in prod_por_cat.items()}

    # --- clientes
    n_clientes = 2500
    # 35% de los clientes ya existían antes de 2023 (base histórica); el resto se suma durante el período
    offsets = np.where(rng.random(n_clientes) < 0.35, rng.integers(-540, 0, n_clientes), rng.integers(0, DIAS - 30, n_clientes))
    altas = [INICIO + timedelta(days=int(d)) for d in np.sort(offsets)]
    clientes = [(i + 1, altas[i].isoformat(), rng.choice(PROVINCIAS, p=PESO_PROV),
                 rng.choice(["F", "M", "X"], p=[0.48, 0.48, 0.04]),
                 rng.choice(["18-24", "25-34", "35-44", "45-54", "55+"], p=[0.22, 0.33, 0.22, 0.14, 0.09]))
                for i in range(n_clientes)]
    con.executemany("INSERT INTO clientes VALUES (?,?,?,?,?)", clientes)

    # --- pedidos
    pedidos, detalle, oid = [], [], 1
    mult = np.array([eventos(INICIO + timedelta(days=d))[0] for d in range(DIAS)])
    for cid, alta, prov, *_ in clientes:
        alta = date.fromisoformat(alta)
        tasa = rng.gamma(1.3, 1 / 70)          # compras por día (heterogénea: media ~ 1 cada 54 días)
        vida = rng.exponential(320)            # días hasta abandonar la marca
        d_alta = (alta - INICIO).days
        d0 = max(0, d_alta)                    # solo se registran pedidos desde 2023
        d1 = min(DIAS, d_alta + int(vida) + 1)
        if d1 <= d0:
            continue                           # abandonó antes de 2023: sin pedidos en el período
        prob = np.clip(tasa * mult[d0:d1], 0, 0.9)
        dias_compra = d0 + np.nonzero(rng.random(d1 - d0) < prob)[0]
        if len(dias_compra) == 0:
            dias_compra = np.array([d0])      # todo cliente registrado compra al menos una vez
        tienda_fisica = 3 if prov in ("Chubut", "Santa Cruz", "Neuquén") else int(rng.choice([1, 2]))
        for d in dias_compra:
            f = INICIO + timedelta(days=int(d))
            online_share = 0.30 + 0.25 * d / DIAS + (0.25 if eventos(f)[1] > 0.2 else 0)
            tienda = 4 if rng.random() < online_share else tienda_fisica
            pago = rng.choice(["Tarjeta crédito", "Débito", "Mercado Pago", "Efectivo"],
                              p=[0.42, 0.22, 0.28, 0.08] if tienda != 4 else [0.55, 0.12, 0.33, 0.0])
            pedidos.append((oid, cid, tienda, f.isoformat(), pago))
            # canasta
            cats = list(CATEGORIAS)
            pesos = np.array([CATEGORIAS[c][2] for c in cats])
            # lista sin repetidos (no un set: el orden de un set de textos cambia entre ejecuciones
            # de Python y rompería la reproducibilidad de los datos)
            elegidas = [str(rng.choice(cats, p=pesos))]
            if "Zapatillas" in elegidas and rng.random() < 0.45:
                elegidas.append("Accesorios")         # medias con las zapatillas
            if rng.random() < 0.35:
                extra = str(rng.choice(cats, p=pesos))
                if extra not in elegidas:
                    elegidas.append(extra)
            desc_evento = eventos(f)[1]
            for cat in elegidas:
                ps = prod_por_cat[cat]
                prod = ps[rng.choice(len(ps), p=popularidad[cat])]
                desc = desc_evento if desc_evento else (0.15 if rng.random() < 0.08 else 0.0)
                cant = 1 if cat != "Accesorios" else int(rng.choice([1, 2], p=[0.8, 0.2]))
                detalle.append((oid, prod[0], cant, round(prod[4] * (1 - desc), 2), desc))
            oid += 1
    con.executemany("INSERT INTO pedidos VALUES (?,?,?,?,?)", pedidos)
    con.executemany("INSERT INTO detalle_pedido VALUES (?,?,?,?,?)", detalle)

    # --- stock actual (fotografía al cierre)
    stock = [(t[0], p[0], int(rng.poisson(14 if t[0] != 4 else 30) * rng.choice([1, 0.2], p=[0.85, 0.15])))
             for t in TIENDAS for p in productos]
    con.executemany("INSERT INTO stock VALUES (?,?,?)", stock)
    con.commit()

    for tabla in ["tiendas", "clientes", "productos", "pedidos", "detalle_pedido", "stock"]:
        n = con.execute(f"SELECT COUNT(*) FROM {tabla}").fetchone()[0]
        print(f"{tabla:16s} {n:>7,} filas")
    con.close()


if __name__ == "__main__":
    main()
