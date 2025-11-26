with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

procedure Parte3 is

   Gen : Generator;


   task Ordenie is
      entry Entrar(Id : Integer);
      entry Salir(Id : Integer);
   end Ordenie;

   task body Ordenie is
      Dentro : Integer := 0;
   begin
      loop
         select
            when Dentro < 15 =>
               accept Entrar(Id : Integer) do
                  Dentro := Dentro + 1;
                  Put_Line("La vaca" & Integer'Image(Id) & " está entrando al área de ordeñe");
               end Entrar;
         or
            accept Salir(Id : Integer) do
               Dentro := Dentro - 1;
               Put_Line("La vaca" & Integer'Image(Id) & " está saliendo del área de ordeñe");
            end Salir;
         or
            terminate;
         end select;
      end loop;
   end Ordenie;



   task Pasillo is
      entry Entrar;
      entry Salir;
   end Pasillo;

   task body Pasillo is
   begin
      loop
         select
            accept Entrar;
            accept Salir;
         or
            terminate;
         end select;
      end loop;
   end Pasillo;

   



   task Vacunacion is
      entry Entrar(Id : Integer; Manga : out Integer);
      entry Salir(Id : Integer; Manga : Integer);
   end Vacunacion;

   task body Vacunacion is
      Mangas : array(1..5) of Boolean := (others => False);
      Ocupadas : Integer := 0;
   begin
      loop
         select
            when Ocupadas < 5 =>
               accept Entrar(Id : Integer; Manga : out Integer) do
                  for I in 1..5 loop
                     if not Mangas(I) then
                        Mangas(I) := True;
                        Manga := I;
                        Ocupadas := Ocupadas + 1;
                        Put_Line("La vaca" & Integer'Image(Id) & " está entrando al área de vacunación");
                        exit;
                     end if;
                  end loop;
               end Entrar;
         or
            accept Salir(Id : Integer; Manga : Integer) do
               Mangas(Manga) := False;
               Ocupadas := Ocupadas - 1;
               Put_Line("La vaca" & Integer'Image(Id) & " está saliendo del área de vacunación");
            end Salir;
         or
            terminate;
         end select;
      end loop;
   end Vacunacion;




   
   task Camiones is
      entry Subir(Id : Integer);
      entry Consultar(Llenos : out Boolean);
   end Camiones;

   task body Camiones is
      C1, C2 : Integer := 0;
   begin
      loop
         select
            when C1 < 50 or C2 < 50 =>
               accept Subir(Id : Integer) do
                  if C1 < 50 then
                     C1 := C1 + 1;
                     Put_Line("La vaca" & Integer'Image(Id) & " está entrando al Camión 1");
                  else
                     C2 := C2 + 1;
                     Put_Line("La vaca" & Integer'Image(Id) & " está entrando al Camión 2");
                  end if;
               end Subir;
         or
            accept Consultar(Llenos : out Boolean) do
               Llenos := (C1 >= 50 and C2 >= 50);
            end Consultar;
         or
            terminate;
         end select;
      end loop;
   end Camiones;




   task type Vaca is
      entry Iniciar(Id : Integer);
   end Vaca;

   task body Vaca is
      Mi_Id, M : Integer;
   begin
      accept Iniciar(Id : Integer) do
         Mi_Id := Id;
      end Iniciar;

      if (Mi_Id mod 2) = 0 then
         Pasillo.Entrar;
         Vacunacion.Entrar(Mi_Id, M);
         delay Duration(Random(Gen) * 2.0);
         Vacunacion.Salir(Mi_Id, M);
         Pasillo.Salir;

         Ordenie.Entrar(Mi_Id);
         delay Duration(Random(Gen) * 3.0);
         Ordenie.Salir(Mi_Id);
      else
         Ordenie.Entrar(Mi_Id);
         delay Duration(Random(Gen) * 3.0);
         Ordenie.Salir(Mi_Id);

         Pasillo.Entrar;
         Vacunacion.Entrar(Mi_Id, M);
         delay Duration(Random(Gen) * 2.0);
         Vacunacion.Salir(Mi_Id, M);
         Pasillo.Salir;
      end if;

      Camiones.Subir(Mi_Id);
   end Vaca;

   Vacas : array(1..100) of Vaca;
   Fin : Boolean := False;

begin
   Reset(Gen);
   Put_Line("=== INICIO SIMULACIÓN TAMBO ===");

   for I in 1..100 loop
      Vacas(I).Iniciar(I);
   end loop;

   while not Fin loop
      delay 0.5;
      Camiones.Consultar(Fin);
   end loop;

   Put_Line("=== FIN: Camiones llenos ===");
end Parte3;
