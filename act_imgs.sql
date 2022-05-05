-------------------------------------------------
-- INSTRUCCIONES ACTIVIDAD
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

-- 2. Se crea directorio que almacenará las imágenes de las portadas
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
-- Opciones:
-- 1 = insertar un registro
-- 2 = actualizar un registro
-- 3 = eliminar un registro
-- 4 = actualización masiva de imágenes

VARIABLE B_IDREG NUMBER(6);
-- Para opciones 2 y 3: ingresar ID del registro que se quiere actualizar o eliminar
-- Ingresar 0 en otro caso

VARIABLE B_NOMDIS VARCHAR(50);
-- Para opciones 1 y 2, ingresar nombre del disco que se desea insertar o nombre de reemplazo en caso de actualizar
-- Ingresar espacio en otro caso

VARIABLE B_NOMIMG VARCHAR(50);
-- Para opciones 1 y 2, ingresar nombre del archivo de imagen
-- Nombres de imágenes disponibles: 1.jpg; 2.jpg; 3.jpg; 4.jpg; 5.jpg; 6.jpeg; 7.jpg
-- Ingresar espacio en otro caso

DECLARE

V_CANT NUMBER(6);
V_ID NUMBER(6);
V_IDMIN NUMBER(6);
V_IDMAX NUMBER(6);
V_IMG VARCHAR(50);
V_BFILE BFILE;
V_EXISTEIMG NUMBER(1);

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
	
	-- Acción actualizar:
	ELSIF :B_ACCION = 2 THEN
	
		UPDATE DISCO
		SET NOMBRE_DISCO = :B_NOMDIS,
			IMG_DISCO = BFILENAME('DIR_IMG_DISCO', :B_NOMIMG)
		WHERE ID_DISCO = :B_IDREG;
		
		DBMS_OUTPUT.PUT_LINE('El registro '||:B_IDREG||' ha sido actualizado');
	
	-- Acción eliminar:
	ELSIF :B_ACCION = 3 THEN
		
		SELECT NOMBRE_DISCO
		INTO :B_NOMDIS
		FROM DISCO
		WHERE ID_DISCO = :B_IDREG;
		
		DELETE FROM DISCO
		WHERE ID_DISCO = :B_IDREG;
		
		DBMS_OUTPUT.PUT_LINE('El disco "'||:B_NOMDIS||'" ha sido eliminado');

	-- Acción actualización masiva de imágenes:
	ELSIF :B_ACCION = 4 THEN
		
		SELECT COUNT(ID_DISCO)
		INTO V_CANT
		FROM DISCO;
		
		-- Si la tabla está vacía, no se realiza la actualización y el bloque termina
		IF V_CANT = 0 THEN DBMS_OUTPUT.PUT_LINE('No es posible actualizar registros porque la tabla está vacía');
		
		ELSE
			-- Se obtienen los ID mínimo y máximo para recorrer la tabla
			SELECT MIN(ID_DISCO),
				MAX(ID_DISCO)
			INTO V_IDMIN, V_IDMAX
			FROM DISCO;
			
			-- Se recorre la tabla y se actualiza la imagen de cada registro, si el archivo existe
			LOOP
				V_IMG := V_IDMIN || '.jpg';
				V_BFILE := BFILENAME('DIR_IMG_DISCO', V_IMG);
				V_EXISTEIMG := DBMS_LOB.FILEEXISTS(V_BFILE);
				
				IF V_EXISTEIMG = 1 THEN
					
					UPDATE DISCO
					SET IMG_DISCO = BFILENAME('DIR_IMG_DISCO', V_IMG)
					WHERE ID_DISCO = V_IDMIN;
					
					DBMS_OUTPUT.PUT_LINE('Se actualizó la imagen del registro con ID_DISCO = '||V_IDMIN);
					
				END IF;
				
				V_IDMIN := V_IDMIN + 1;
				EXIT WHEN V_IDMIN > V_IDMAX;
				
			END LOOP;

		END IF;
				
	ELSE DBMS_OUTPUT.PUT_LINE('La opción ingresada no es válida, por favor ingrese 1, 2 o 3');
	
	END IF;

END;

-------------------------------------------------
-------------------------------------------------
