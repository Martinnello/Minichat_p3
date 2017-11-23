with Lower_Layer_UDP;
with Handlers;
with Chat_Messages;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Text_IO;
with Ada.Exceptions;

procedure Server is

   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package IO renames Ada.Text_IO;
   package CM renames Chat_Messages;
   use type ASU.Unbounded_String;

   Maquina: ASU.Unbounded_String;
   Dir_IP: ASU.Unbounded_String;
   Port : Natural;
   
   Server_EP: LLU.End_Point_Type;
   Finish: Boolean;
   C: Character;
   Usage_Error: exception;
   
begin
   
   if ACL.Argument_Count /= 1 then
	   raise Usage_Error;
			
   else 
			
			-- Construye un End_Point en la direccion del servidor
					-- y con el puerto que elegimos
	
       Port := Natural'Value(ACL.Argument(1)); 
	   --MAX := (ACL.Argument(2));
	   Maquina := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	   Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Maquina)));
	   Server_EP := LLU.Build (ASU.To_String(Dir_IP), Port);
       LLU.Bind(Server_EP, Handlers.Server_Handler'Access);
   
    end if;

   -- Se ata al End_Point para poder recibir en él con un handler/manejador.
   -- Tras llamar a Bind ya se pueden estar recibiendo mensajes automáticamente
   -- en el manejador
   
    IO.New_Line;
    Ada.Text_IO.Put("Server in: ");
    IO.Put_Line(ASU.To_String(Maquina));
    IO.Put_Line("IP: " & ASU.To_String(Dir_IP));
    IO.Put_Line("Port: " & (Natural'Image(Port)));
    IO.New_Line;
    Ada.Text_IO.Put_Line ("Para terminar este servidor pulse 'T' o 't'");

   -- Hasta que no pulsen 'T' o 't' en el teclado no termina el servidor
   Finish := False;
   
   while not Finish loop
      Ada.Text_IO.Get_Immediate (C);
      if C = 'T' or C = 't' then
         Finish := True;
         LLU.Finalize;
      else
         Ada.Text_IO.Put_Line ("Para terminar este servidor pulse 'T' o 't'");
      end if;
   end loop;

exception
   when Usage_Error =>
		IO.Put_Line("Use: ");
		IO.Put_Line("       " & ACL.Command_Name & " <Port Number> ");
		IO.New_Line;
		LLU.Finalize;
		
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Server;
