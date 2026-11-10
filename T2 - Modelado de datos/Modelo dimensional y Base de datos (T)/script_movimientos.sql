--
-- MODELO ROLAP - Movimientos WWIMPORTERS 
-- BASE DE DATOS: DB_202615_df_perezj
--

USE DB_202615_df_perezj;


-- BLOQUE 1 CREACIÓN DE TABLAS DIMENSIONALES Y DE HECHOS
-- 1. Dimensión de fecha

CREATE TABLE IF NOT EXISTS M_Fecha (
    ID_Fecha INT NOT NULL,
    Fecha DATE NOT NULL,
    Dia INT NOT NULL,
    Mes INT NOT NULL,
    Anio INT NOT NULL,
    Numero_semana_ISO INT NOT NULL,
    PRIMARY KEY (ID_Fecha)
);

-- 2. Dimensión de producto

CREATE TABLE IF NOT EXISTS M_Producto (
    ID_Producto_DWH INT NOT NULL,
    ID_Producto_T INT,
    Nombre VARCHAR(100),
    Marca VARCHAR(50),
    Color VARCHAR(30),
    Necesitarefrigeracion VARCHAR(10),
    Dias_tiempo_entrega INT,
    cantidad_por_salida INT,
    Precio_minorista_recomendado DECIMAL(10, 2),
    Impuesto DECIMAL(10, 2),
    Precio_unitario DECIMAL(10, 2),
    PRIMARY KEY (ID_Producto_DWH)
);

-- Dimensión de proveedor

CREATE TABLE IF NOT EXISTS M_Proveedor (
    ID_Proveedor_DWH INT NOT NULL,
    ID_Proveedor_T INT,
    Nombre VARCHAR(100),
    Categoria VARCHAR(50),
    Contacto_principal VARCHAR(100),
    Dias_pago INT,
    Codigo_postal VARCHAR(20),
    PRIMARY KEY (ID_Proveedor_DWH)
);

-- 4. Dimensión de cliente

CREATE TABLE IF NOT EXISTS M_Cliente (
    ID_Cliente_DWH INT NOT NULL,
    ID_Cliente_T INT,
    Nombre VARCHAR(100),
    ClienteFactura VARCHAR(100),
    ID_CiudadEntrega_DWH INT,
    LimiteCredito DECIMAL(12, 2),
    FechaAperturaCuenta DATE,
    DiasPago INT,
    NombreGrupoCompra VARCHAR(50),
    NombreCategoria VARCHAR(50),
    PRIMARY KEY (ID_Cliente_DWH)
);

-- 5. Dimensión TipoTransaccion

CREATE TABLE IF NOT EXISTS M_TipoTransaccion (
    ID_Tipo_transaccion_DWH INT NOT NULL,
    ID_Tipo_transaccion_T INT,
    Tipo VARCHAR(50),
    PRIMARY KEY (ID_Tipo_transaccion_DWH)
);

-- 6. Tabla de hechos: Movimientos

CREATE TABLE IF NOT EXISTS M_Hecho_Movimiento (
    ID_Fecha INT NOT NULL,
    ID_Producto_DWH INT NOT NULL,
    ID_Proveedor_DWH INT NOT NULL,
    ID_Cliente_DWH INT NOT NULL,
    ID_Tipo_transaccion_DWH INT NOT NULL,
    Cantidad INT NOT NULL,
    CONSTRAINT FK_Movimiento_Fecha FOREIGN KEY (ID_Fecha) 
        REFERENCES M_Fecha(ID_Fecha),
    CONSTRAINT FK_Movimiento_Producto FOREIGN KEY (ID_Producto_DWH) 
        REFERENCES M_Producto(ID_Producto_DWH),
    CONSTRAINT FK_Movimiento_Proveedor FOREIGN KEY (ID_Proveedor_DWH) 
        REFERENCES M_Proveedor(ID_Proveedor_DWH),
    CONSTRAINT FK_Movimiento_Cliente FOREIGN KEY (ID_Cliente_DWH) 
        REFERENCES M_Cliente(ID_Cliente_DWH),
    CONSTRAINT FK_Movimiento_TipoTransaccion FOREIGN KEY (ID_Tipo_transaccion_DWH) 
        REFERENCES M_TipoTransaccion(ID_Tipo_transaccion_DWH)
);


-- BLOQUE 2 Insertar datos en las tablas dimensionales y de hechos
-- 1. Insertar en M_Fecha con el formato de fecha 'YYYYMMDD'
INSERT INTO M_Fecha (ID_Fecha, Fecha, Dia, Mes, Anio, Numero_semana_ISO) VALUES
(20261020, '2026-10-20', 20, 10, 2026, 43),
(20261021, '2026-10-21', 21, 10, 2026, 43);

-- 2. Insertar en M_Producto
INSERT INTO M_Producto (ID_Producto_DWH, ID_Producto_T, Nombre, Marca, Color, Necesitarefrigeracion, 
Dias_tiempo_entrega, cantidad_por_salida, Precio_minorista_recomendado, Impuesto, Precio_unitario) VALUES
(1, 101, 'Cinta Adhesiva Industrial', 'TapeMaster', 'Transparente', 'No', 3, 10, 15000.00, 2850.00, 12000.00),
(2, 102, 'Sellador Térmico', 'SealPro', 'Negro', 'Sí', 5, 5, 45000.00, 8550.00, 38000.00);

-- 3. Insertar en M_Proveedor
INSERT INTO M_Proveedor (ID_Proveedor_DWH, ID_Proveedor_T, Nombre, Categoria, Contacto_principal, Dias_pago, Codigo_postal) VALUES
(1, 201, 'Empaques Andinos S.A.', 'Empaque y Embalaje', 'Carlos Mendoza', 30, '110111'),
(2, 202, 'Suministros Industriales Ltda.', 'Ferretería Industrial', 'Ana Rincón', 45, '110221');

-- 4. Insertar en M_Cliente
INSERT INTO M_Cliente (ID_Cliente_DWH, ID_Cliente_T, Nombre, ClienteFactura, ID_CiudadEntrega_DWH, LimiteCredito, FechaAperturaCuenta, 
DiasPago, NombreGrupoCompra, NombreCategoria) VALUES
(1, 301, 'Distribuidora del Norte', 'Distribuidora del Norte SAS', 10, 5000000.00, '2024-01-15', 30, 'Mayoristas', 'Comercial'),
(2, 302, 'Logística Central', 'Logística Central SA', 20, 8000000.00, '2023-06-10', 15, 'Corporativos', 'Industrial');

-- 5. Insertar en M_TipoTransaccion
INSERT INTO M_TipoTransaccion (ID_Tipo_transaccion_DWH, ID_Tipo_transaccion_T, Tipo) VALUES
(1, 1, 'Entrada por Compra'),
(2, 2, 'Salida por Venta');

-- 6. Insertar en M_Hecho_Movimiento
-- Mismos datos que arriba
INSERT INTO M_Hecho_Movimiento (ID_Fecha, ID_Producto_DWH, ID_Proveedor_DWH, ID_Cliente_DWH, ID_Tipo_transaccion_DWH, Cantidad) VALUES
(20261020, 1, 1, 1, 2, 50),
(20261021, 2, 2, 2, 1, 120);


-- BLOQUE 3 Sentencias SQL para consultas analíticas
-- 1. Consulta Principal: Productos movidos en un rango de fechas desglosados por
-- Cliente, Proveedor, Tipo de Transacción y Producto.

SELECT 
    f.Fecha,
    c.Nombre AS Cliente,
    pv.Nombre AS Proveedor,
    t.Tipo AS Tipo_Transaccion,
    p.Nombre AS Producto,
    SUM(h.Cantidad) AS Total_Productos_Movidos
FROM M_Hecho_Movimiento h
INNER JOIN M_Fecha f 
    ON h.ID_Fecha = f.ID_Fecha
INNER JOIN M_Cliente c 
    ON h.ID_Cliente_DWH = c.ID_Cliente_DWH
INNER JOIN M_Proveedor pv 
    ON h.ID_Proveedor_DWH = pv.ID_Proveedor_DWH
INNER JOIN M_TipoTransaccion t 
    ON h.ID_Tipo_transaccion_DWH = t.ID_Tipo_transaccion_DWH
INNER JOIN M_Producto p 
    ON h.ID_Producto_DWH = p.ID_Producto_DWH
WHERE f.Fecha BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY 
    f.Fecha,
    c.Nombre,
    pv.Nombre,
    t.Tipo,
    p.Nombre
ORDER BY f.Fecha ASC, Total_Productos_Movidos DESC;

-- Consulta 2: Agrupación por Cliente en el rango);
SELECT 
    c.Nombre AS Cliente,
    SUM(h.Cantidad) AS Total_Movido
FROM M_Hecho_Movimiento h
INNER JOIN M_Fecha f ON h.ID_Fecha = f.ID_Fecha
INNER JOIN M_Cliente c ON h.ID_Cliente_DWH = c.ID_Cliente_DWH
WHERE f.Fecha BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY c.Nombre;

-- Counsulta 3: Agrupación por Tipo de Transacción
SELECT
    t.Tipo AS Tipo_Transaccion,
    SUM(h.Cantidad) AS Total_Movido
FROM M_Hecho_Movimiento h
INNER JOIN M_Fecha f ON h.ID_Fecha = f.ID_Fecha
INNER JOIN M_TipoTransaccion t ON h.ID_Tipo_transaccion_DWH = t.ID_Tipo_transaccion_DWH
WHERE f.Fecha BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY t.Tipo;