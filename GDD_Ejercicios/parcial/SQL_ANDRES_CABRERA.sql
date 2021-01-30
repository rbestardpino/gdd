--Se necesita saber que productos no han sido vendidos durante el año 2012 pero que sí tuvieron ventas en año anteriores. De esos productos mostrar:
--Código de producto
--Nombre de Producto
--Un string que diga si es compuesto o no.
--El resultado deberá ser ordenado por cantidad vendida en años anteriores.

USE GD2020

SELECT prod_codigo AS CODIGO, prod_detalle AS NOMBRE, (CASE WHEN (SELECT COUNT(*) FROM Composicion WHERE comp_producto = prod_codigo) > 0 THEN 'ES COMPUESTO'
		ELSE 'NO ES COMPUESTO' END) COMPOSICION
FROM Producto
JOIN Item_Factura ON item_producto = prod_codigo
JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
WHERE prod_codigo NOT IN (SELECT item_producto 
							FROM Item_Factura 
							JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
							WHERE YEAR(fact_fecha) = 2012) 
	AND YEAR(fact_fecha) < 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY SUM(item_cantidad)--SE ENTIENDE QUE POR AÑOS ANTERIORES SE REFIERE A AÑOS ANTERIORES AL 2012