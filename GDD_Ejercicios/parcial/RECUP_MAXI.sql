GO
CREATE TRIGGER parcialMaxi ON FACTURA FOR INSERT
AS
BEGIN
	IF EXISTS(SELECT fact_vendedor FROM inserted WHERE fact_vendedor NOT IN (SELECT empl_codigo FROM Empleado))
	BEGIN
		DECLARE @NUMERO char(8)
		DECLARE cursorFacturas CURSOR FOR (SELECT fact_numero FROM inserted GROUP BY fact_numero)

		OPEN cursorFacturas
		FETCH NEXT FROM cursorFacturas
			INTO @NUMERO

			WHILE(@@FETCH_STATUS = 0)
			BEGIN
				DELETE FROM Factura WHERE fact_numero = @NUMERO
				DELETE FROM Item_Factura WHERE item_numero = @NUMERO
				
				FETCH NEXT FROM cursorFacturas
					INTO @NUMERO
			END
		CLOSE cursorFacturas
		DEALLOCATE cursorFacturas
		ROLLBACK
		RAISERROR ('EMPLEADO NO EXISTENTE',1,1)
	END
END

SELECT fact_vendedor FROM inserted WHERE fact_vendedor NOT IN (SELECT empl_codigo FROM Empleado)