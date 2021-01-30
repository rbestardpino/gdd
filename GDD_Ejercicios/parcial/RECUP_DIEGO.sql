Armar una consulta que muestre para todos los productos:

Producto

Detalle del producto

Detalle composición (si no es compuesto un string “SIN COMPOSICION”,, si es compuesto un string “CON COMPOSICION”

Cantidad de Componentes (si no es compuesto, tiene que mostrar 0)

Cantidad de veces que fue comprado por distintos clientes

SELECT prod_codigo AS PRODUCTO , prod_detalle AS NOMBRE, (CASE WHEN COUNT(comp_componente) > 0 THEN 'ES COMPUESTO'
		ELSE 'NO ES COMPUESTO' END) COMPOSICION, isnull(sum(comp_cantidad),0),
		(SELECT COUNT(distinct fact_cliente)
			FROM Factura
			JOIN Item_Factura ON item_numero = fact_numero
			WHERE item_producto = prod_codigo)
FROM Producto
LEFT JOIN Composicion ON comp_producto = prod_codigo
GROUP BY prod_codigo , prod_detalle




