SELECT
    f1.fact_cliente,
    COUNT(DISTINCT f1.fact_numero) AS cant_compras,
    (
        SELECT
            AVG(ISNULL(fact_total, 0))
        FROM
            Factura f2
        WHERE
            f2.fact_cliente = f1.fact_cliente
            AND YEAR(f2.fact_fecha) = (
                SELECT
                    MAX(YEAR(f4.fact_fecha))
                FROM
                    Factura f4
            )
    ) AS prom_por_compra,
    COUNT(DISTINCT item_producto) AS cant_prods_diferentes,
    MAX(f1.fact_total_impuestos) AS monto_mayor_compra
FROM
    Factura f1
    JOIN Item_Factura ON item_numero = fact_numero
    AND item_sucursal = fact_sucursal
    AND item_tipo = fact_tipo
WHERE
    YEAR(fact_fecha) = (
        SELECT
            MAX(YEAR(f3.fact_fecha))
        FROM
            Factura f3
    )
GROUP BY
    fact_cliente
ORDER BY
    cant_compras DESC