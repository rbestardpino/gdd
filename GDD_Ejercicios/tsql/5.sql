CREATE PROC P5 AS
BEGIN
    CREATE TABLE Fact_table
    (
        anio     CHAR(4),
        mes      CHAR(2),
        familia  CHAR(3) FOREIGN KEY REFERENCES Familia (fami_id),
        rubro    CHAR(4) FOREIGN KEY REFERENCES Rubro (rubr_id),
        zona     CHAR(3) FOREIGN KEY REFERENCES Zona (zona_codigo),
        cliente  CHAR(6) FOREIGN KEY REFERENCES Cliente (clie_codigo),
        producto CHAR(8) FOREIGN KEY REFERENCES Producto (prod_codigo),
        cantidad DECIMAL(12, 2),
        monto    DECIMAL(12, 2)
    );

    ALTER TABLE Fact_table
        ADD CONSTRAINT PK_Fact_Table PRIMARY KEY (anio, mes, familia, rubro, zona, cliente, producto);

    INSERT INTO Fact_table
    SELECT YEAR(F.fact_fecha),
           MONTH(F.fact_fecha),
           P.prod_familia,
           P.prod_rubro,
           D.depa_zona,
           F.fact_cliente,
           P.prod_codigo,
           SUM(I.item_cantidad),
           SUM(F.fact_total)
    FROM Factura F
             JOIN Item_Factura I
                  ON F.fact_tipo = I.item_tipo AND F.fact_sucursal = I.item_sucursal AND F.fact_numero = I.item_numero
             JOIN Producto P ON I.item_producto = P.prod_codigo
             JOIN Empleado E ON F.fact_vendedor = E.empl_codigo
             JOIN Departamento D ON E.empl_departamento = D.depa_codigo
    GROUP BY YEAR(F.fact_fecha), MONTH(F.fact_fecha), P.prod_familia, P.prod_rubro, D.depa_zona, F.fact_cliente,
             P.prod_codigo;
END;