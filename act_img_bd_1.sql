-------------------------------------------------
-- INSTRUCCIONES
-------------------------------------------------

-- Actividad complementaria grupal:
-- =========================
-- El desarrollo completo de esta actividad, tendrá 1 punto adicional, que será considerado en la segunda prueba.
-- 
-- Considerar que:
-- ============
-- El SCRIPT debe insertar, actualizar y eliminar registros que contengan al menos una columna tipo imagen.
-- 
-- La entrega de este trabajo, deberá contener, el nombre de los integrantes del grupo y la documentación de scripts y print de pantallas que muestren los resultados logrados. 
-- 
-- Material de apoyo en PPT:
-- ====================
-- 2_1_2_Usando Tipos de Datos LOB en Bloques PLSQL

-------------------------------------------------
-- DESARROLLO ACTIVIDAD
-------------------------------------------------

-- En usuario system:

-- 1. Se crea nuevo usuario
CREATE USER C##IMGUSR IDENTIFIED BY IMGUSR
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP"
QUOTA UNLIMITED ON "USERS";

GRANT RESOURCE, CONNECT TO C##IMGUSR;

-- 2. Se crea directorio que almacenará las imágenes de portadas discos
CREATE DIRECTORY DIR_IMG_DISCO AS 'C:\MDY3131\img_discos';

-- 3. Se otorga permiso de lectura en el directorio al usuario creado
GRANT READ ON DIRECTORY DIR_IMG_DISCO TO C##IMGUSR;

-- En usuario IMGUSR:

-- 4. Se crea tabla para almacenar portadas de discos
CREATE TABLE DISCO (
	ID_DISCO NUMBER(10) NOT NULL CONSTRAINT PK_DISCO PRIMARY KEY,
	NOMBRE_DISCO VARCHAR2(50) NOT NULL,
	IMG_DISCO BFILE
);

-- 5. Se ejecuta el bloque que permite insertar, actualizar o eliminar portadas de discos

VARIABLE B_ACCION CHAR(1);
-- 1 = insertar; 2 = actualizar; 3 = eliminar
VARIABLE B_IDREG NUMBER(6);
-- ID del registro que se quiere actualizar o eliminar
-- Si no se desea actualizar o eliminar (sino insertar), ingresar 0.
VARIABLE B_NOMDIS VARCHAR(50);
-- Nombre del disco que se desea insertar o nombre de reemplazo en caso de actualizar.
-- Si se desea eliminar un registro, ingresar espacio.
VARIABLE B_NOMIMG VARCHAR(50);
-- Opciones de imágenes para almacenar: artaud.jpg; bad_religion.jpg; beth.jpg; pink_floyd.jpg; ramones.jpg; the_smiths.jpg; tijoux.jpg
-- Si se desea eliminar un registro, ingresar espacio.

DECLARE

V_CANT NUMBER(6);
V_ID NUMBER(6);

BEGIN
	
	-- Acción insertar:
	IF :B_ACCION = 1 THEN
	
		SELECT COUNT(ID_DISCO)
		INTO V_CANT
		FROM DISCO;
		
		-- Se obtiene el ID para el nuevo registro
		IF V_CANT = 0 THEN V_ID := 1;
		ELSE
			SELECT MAX(ID_DISCO) + 1
			INTO V_ID
			FROM DISCO;
		END IF;
		
		DBMS_OUTPUT.PUT_LINE('Siguiente ID: '||V_ID);
		
		INSERT INTO DISCO (
			ID_DISCO,
			NOMBRE_DISCO,
			IMG_DISCO
		)
		VALUES (
			V_ID,
			:B_NOMDIS,
			BFILENAME('DIR_IMG_DISCO', :B_NOMIMG)
		);
		
		DBMS_OUTPUT.PUT_LINE('Se ha guardado el disco "'||:B_NOMDIS||'"');
	
	ELSIF :B_ACCION = 2 THEN DBMS_OUTPUT.PUT_LINE('Estamos en la opción 2');
	ELSIF :B_ACCION = 3 THEN DBMS_OUTPUT.PUT_LINE('Estamos en la opción 3');
	ELSE DBMS_OUTPUT.PUT_LINE('La opción ingresada no es válida, por favor ingrese 1, 2 o 3');
	
	END IF;

END;