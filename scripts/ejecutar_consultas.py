"""
Ejecuta todas las consultas de sql/consultas/ y guarda los resultados en resultados/RESULTADOS.md.
Solo usa la librería estándar de Python (sqlite3).

    python scripts/crear_base.py        # una vez
    python scripts/ejecutar_consultas.py
"""
import sqlite3
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
DB = RAIZ / "retail.db"
CONSULTAS = sorted((RAIZ / "sql" / "consultas").glob("*.sql"))
SALIDA = RAIZ / "resultados" / "RESULTADOS.md"
MAX_FILAS = 25


def formato(v) -> str:
    if v is None:
        return "–"
    if isinstance(v, float):
        if v.is_integer() and abs(v) >= 1000:
            return f"{int(v):,}".replace(",", ".")
        return f"{v:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".").rstrip("0").rstrip(",")
    if isinstance(v, int) and abs(v) >= 1000:
        return f"{v:,}".replace(",", ".")
    return str(v)


def encabezado(sql: str) -> tuple[str, str]:
    pregunta, tecnicas = [], ""
    for linea in sql.splitlines():
        if not linea.startswith("--"):
            break
        texto = linea[2:].strip()
        if texto.startswith("Técnicas:"):
            tecnicas = texto.removeprefix("Técnicas:").strip()
        else:
            pregunta.append(texto.removeprefix("Pregunta:").strip())
    return " ".join(pregunta), tecnicas


def tabla_md(columnas, filas) -> str:
    lineas = ["| " + " | ".join(columnas) + " |", "|" + "|".join("---" for _ in columnas) + "|"]
    lineas += ["| " + " | ".join(formato(v) for v in fila) + " |" for fila in filas[:MAX_FILAS]]
    if len(filas) > MAX_FILAS:
        lineas.append(f"\n*… {len(filas) - MAX_FILAS} filas más*")
    return "\n".join(lineas)


def main() -> None:
    if not DB.exists():
        sys.exit("No existe retail.db. Ejecutá primero: python scripts/crear_base.py")
    con = sqlite3.connect(DB)
    partes = ["# Resultados de las consultas\n",
              "> Generado automáticamente por `scripts/ejecutar_consultas.py`. No editar a mano.\n"]
    for ruta in CONSULTAS:
        sql = ruta.read_text(encoding="utf-8")
        pregunta, tecnicas = encabezado(sql)
        cur = con.execute(sql)
        columnas = [c[0] for c in cur.description]
        filas = cur.fetchall()
        partes.append(f"## {ruta.stem.replace('_', ' ').capitalize()}\n")
        partes.append(f"**Pregunta:** {pregunta}  \n**Técnicas:** {tecnicas}  \n"
                      f"**Consulta:** [`{ruta.name}`](../sql/consultas/{ruta.name})\n")
        partes.append(tabla_md(columnas, filas) + "\n")
        print(f"✔ {ruta.name}: {len(filas)} filas")
    SALIDA.parent.mkdir(exist_ok=True)
    SALIDA.write_text("\n".join(partes), encoding="utf-8")
    print(f"\nResultados guardados en {SALIDA.relative_to(RAIZ)}")


if __name__ == "__main__":
    main()
