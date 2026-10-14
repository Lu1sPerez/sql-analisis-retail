-- Esquema relacional: retail de indumentaria y calzado deportivo
-- Motor: SQLite 3.35+ (compatible con PostgreSQL salvo funciones de fecha)


DROP TABLE IF EXISTS detalle_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS tiendas;

CREATE TABLE tiendas (
    tienda_id     INTEGER PRIMARY KEY,
    nombre        TEXT    NOT NULL,
    canal         TEXT    NOT NULL CHECK (canal IN ('Tienda física', 'Online')),
    ciudad        TEXT    NOT NULL
);

CREATE TABLE clientes (
    cliente_id    INTEGER PRIMARY KEY,
    fecha_alta    DATE    NOT NULL,
    provincia     TEXT    NOT NULL,
    genero        TEXT,
    rango_edad    TEXT
);

CREATE TABLE productos (
    producto_id   INTEGER PRIMARY KEY,
    nombre        TEXT    NOT NULL,
    marca         TEXT    NOT NULL,
    categoria     TEXT    NOT NULL,      -- Zapatillas, Remeras, Buzos, Pantalones, Accesorios
    precio_lista  NUMERIC NOT NULL CHECK (precio_lista > 0),
    costo         NUMERIC NOT NULL CHECK (costo > 0)
);

CREATE TABLE pedidos (
    pedido_id     INTEGER PRIMARY KEY,
    cliente_id    INTEGER NOT NULL REFERENCES clientes(cliente_id),
    tienda_id     INTEGER NOT NULL REFERENCES tiendas(tienda_id),
    fecha         DATE    NOT NULL,
    medio_pago    TEXT    NOT NULL
);

CREATE TABLE detalle_pedido (
    pedido_id       INTEGER NOT NULL REFERENCES pedidos(pedido_id),
    producto_id     INTEGER NOT NULL REFERENCES productos(producto_id),
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC NOT NULL,     -- precio efectivamente cobrado
    descuento_pct   NUMERIC NOT NULL DEFAULT 0,
    PRIMARY KEY (pedido_id, producto_id)
);

CREATE TABLE stock (
    tienda_id     INTEGER NOT NULL REFERENCES tiendas(tienda_id),
    producto_id   INTEGER NOT NULL REFERENCES productos(producto_id),
    unidades      INTEGER NOT NULL CHECK (unidades >= 0),
    PRIMARY KEY (tienda_id, producto_id)
);

-- Índices para las consultas analíticas más frecuentes
CREATE INDEX idx_pedidos_fecha      ON pedidos(fecha);
CREATE INDEX idx_pedidos_cliente    ON pedidos(cliente_id);
CREATE INDEX idx_detalle_producto   ON detalle_pedido(producto_id);
