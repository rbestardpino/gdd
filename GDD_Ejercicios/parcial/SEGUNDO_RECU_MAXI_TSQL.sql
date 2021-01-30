--RECUPERATORIO MAXI

--Armar un procedimiento almacenado que actualice todos los precios donde se vendió una composición y la sumatoria de los productos con los componentes,
--no da el precio unitario de la venta  realizada. Ademas, debera actualizar todas las tablas correspondientes del modelo para que quede la lógica consistente. 
--La diferencia actualizada, deberá acumularse en una nueva tabla que aun no existe llamada diferencias, donde se debe registrar clliente, ano, diferencias_acumuladas.

CREATE PROCEDURE parcialRecu 
AS
BEGIN
	DECLARE @PRODUCTO numeric(6)
	DECLARE @CLIENTE numeric(6)
	DECLARE @ANIO char(4)
	DECLARE @PRECIO numeric(6)
	DECLARE @SUMATORIA numeric(6)
	DECLARE cursorItems CURSOR FOR (SELECT item_producto, fact_cliente, YEAR(fact_fecha), item_precio FROM Item_Factura JOIN Factura ON item_numero = fact_numero
										WHERE item_producto IN (SELECT comp_producto FROM Composicion))

	OPEN cursorItems
	FETCH NEXT FROM cursorItems
		INTO @PRODUCTO, @CLIENTE, @ANIO, @PRECIO

		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			SET @SUMATORIA = (SELECT SUM(prod_precio) FROM Composicion JOIN Producto ON comp_componente = prod_codigo WHERE comp_producto = @PRODUCTO)
			IF( @SUMATORIA != @PRECIO)
			BEGIN
				INSERT INTO diferencias_Acumuladas VALUES (@CLIENTE, @ANIO , ABS(@SUMATORIA - @PRECIO))

			END
		END

	CLOSE cursorItems
	DEALLOCATE cursorItems


END

SELECT ABS(prod_precio - item_precio) FROM Producto JOIN Item_Factura ON item_producto = prod_codigo