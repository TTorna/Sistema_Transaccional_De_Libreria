-- sp_mostrar_prestamo

CREATE OR REPLACE PACKAGE BIBLIO_PKG is

  PROCEDURE sp_realisar_prestamo(idCliente Biblioteca.Clientes.cli_codigo%TYPE, Pdias Biblioteca.Prestamos_Libros.pli_dias%TYPE , idLibro Biblioteca.Prestamos_Libros.pli_libro%TYPE);
  PROCEDURE sp_mostrar_prestamo(Parametro NUMBER, Registro OUT Sys_refcursor, idCliente Biblioteca.Clientes.cli_codigo%TYPE);
  PROCEDURE sp_listar_libros(Parametro NUMBER, Registro OUT Sys_refcursor);
  PROCEDURE sp_listar_clientes(Parametro NUMBER, Registro OUT Sys_refcursor);
  PROCEDURE sp_listar_autores(Parametro NUMBER, Registro OUT Sys_refcursor,Fecha1 Biblioteca.Prestamos.pre_fecha%TYPE, Fecha2 Biblioteca.Prestamos.pre_fecha%TYPE);
  PROCEDURE sp_devoluciones(idCliente Biblioteca.Clientes.cli_codigo%TYPE, idLibro Biblioteca.Prestamos_Libros.pli_libro%TYPE);

END BIBLIO_PKG;

CREATE OR REPLACE PACKAGE BODY BIBLIO_PKG is

PROCEDURE sp_mostrar_prestamo(Parametro NUMBER, Registro OUT Sys_refcursor, idCliente Biblioteca.Clientes.cli_codigo%TYPE) AS
   Script VARCHAR(300) := ' Select P.pre_cliente, P.pre_numero, P.pre_fecha
                            FROM Biblioteca.Prestamos P
                            INNER JOIN Biblioteca.Prestamos_libros PL ON P.pre_numero=PL.pli_prestamo
                            Where PL.pli_estado=0';
   Hoy DATE;

BEGIN

    SELECT Trunc(SYSDATE) INTO Hoy FROM DUAL;


                              -- LISTADO TOTAL NO LO PONGO PORQUE ES EL SCRIPT DEFAULT

      IF (Parametro = 1) THEN -- LISTA POR CLIENTE
         Script:=Script || ' AND pre_cliente=' || idCliente;
      ELSE
          IF (Parametro = 2) THEN -- LISTADO DE MOROSOS

                Script:=Script || ' AND pre_fecha < '|| Chr(39) || Hoy || Chr(39);

          END IF;
      END IF;

   -- Dbms_Output.put_line(Script);

   OPEN Registro FOR Script;
END;
END BIBLIO_PKG;

DECLARE
    vParametro NUMBER;
    vIdCliente Biblioteca.Prestamos.pre_cliente%TYPE;
    vRegistro SYS_REFCURSOR;
    vPrestamo Biblioteca.Prestamos.pre_numero%TYPE;
    vFecha Biblioteca.Prestamos.pre_fecha%TYPE;
    --vCliente Biblioteca.Prestamos.pre_cliente%TYPE;

BEGIN
     vParametro:=0;     -- 0=LISTADO TOTAL      1=LISTA POR CLIENTE       2=LISTADO DE MOROSOS
     vIdCliente:=7;

     Biblioteca.BIBLIO_PKG.sp_mostrar_prestamo(vParametro, vRegistro, vIdCliente);
     LOOP
      FETCH vRegistro INTO vIdCliente, vPrestamo, vFecha;
      EXIT WHEN vRegistro%NOTFOUND;
      Dbms_Output.put_line('Cliente: ' || vIdCliente || '  Prestamo N�: ' || vPrestamo ||'  Fecha de entrega: '|| vFecha);
     END LOOP;
     CLOSE vRegistro;
END;

SELECT * FROM Biblioteca.Prestamos_Libros PL INNER JOIN Biblioteca.Prestamos P ON pre_numero=pli_prestamo --WHERE P.pre_cliente=3;

SELECT pre_cliente, pre_numero FROM Biblioteca.Prestamos P INNER JOIN Biblioteca.Prestamos_libros PL ON P.pre_numero=PL.pli_prestamo Where PL.pli_estado=0 AND pre_fecha < (SELECT Trunc(SYSDATE) FROM DUAL)

COMMIT;
