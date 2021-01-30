USE GD2020

--Agregar el/los objetos necesarios para que se permita mantener la siguiente restricción:
--Nunca un jefe va a poder tener más de 20 personas a cargo y menos de 1.
--Nota: Considerar solo 1 nivel de la relación empleado-jefe.

GO
CREATE TRIGGER empleadosACargo ON EMPLEADO FOR INSERT
AS
BEGIN
	IF EXISTS (SELECT i.empl_jefe FROM inserted i JOIN Empleado e ON e.empl_codigo = i.empl_jefe 
				GROUP BY i.empl_jefe 
				HAVING COUNT(e.empl_codigo) > 20)
				--SE VERIFICA QUE SI INGRESO UN EMPLEADO, EL JEFE DEL EMPLEADO NO SUPERE LOS 20 EMPLEADOS, POR LO CUAL NO PODRIA INGRESARLO
				OR EXISTS(SELECT i.empl_codigo FROM inserted i JOIN Empleado e ON e.empl_jefe = i.empl_codigo
							GROUP BY i.empl_codigo 
							HAVING COUNT(e.empl_codigo) > 20 OR COUNT(e.empl_codigo) < 1) 
							--SE VERIFICA QUE SI ESTOY INGRESANDO UN JEFE, EL MISMO DEBE CUMPLIR CON LAS RESTRICCIONES
	BEGIN
		ROLLBACK
		RAISERROR ('Empleado ingresado no cumple con las restricciones',1,1)
	END
END