with Handlers;
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Command_Line;
with Ada.Text_IO;
with Chat_Messages;
with Ada.Exceptions;

procedure Client is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package IO renames Ada.Text_IO;
   package CM renames Chat_Messages;

    -- Variables del cliente
    Dir_IP: ASU.Unbounded_String;
    Port: Natural;
    Nick: ASU.Unbounded_String;
    
    -- End Points
    Server_EP: LLU.End_Point_Type;
    Client_EP_Receive: LLU.End_Point_Type;
    Client_EP_Handler: LLU.End_Point_Type;
    
    -- Mensajes
    Buffer: aliased LLU.Buffer_Type(1024);
    Mess: CM.Message_Type;
    Request: ASU.Unbounded_String;
    Reply: ASU.Unbounded_String;
    Salir: Boolean := False;
    Usage_Error: exception;
   
begin
  
    if ACL.Argument_Count /= 3 then
	    raise Usage_Error;
	else
    -- Construye el End_Point en el que está atado el servidor.
		Dir_IP := ASU.To_Unbounded_String(LLU.To_IP(ACL.Argument(1)));
		Port := Natural'Value(ACL.Argument(2));
		Nick :=  ASU.To_Unbounded_String(ACL.Argument(3));
		Server_EP := LLU.Build (ASU.To_String(Dir_IP), Port);
   
    -- Construye un End_Point para cliente recieve y cliente handler.
        LLU.Bind_Any(Client_EP_Receive);
   	    LLU.Bind_Any(Client_EP_Handler, Handlers.Client_Handler'Access);
   	-- Envio Init    
   	    LLU.Reset(Buffer); 
	    Mess := CM.Init;
	    CM.Message_Type'Output(Buffer'Access, Mess);                    -- 1
	    LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);    -- 2
	    LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);    -- 3
	    ASU.Unbounded_String'Output(Buffer'Access, Nick);               -- 4   
       	LLU.Send(Server_EP, Buffer'Access);
       	
       	LLU.Reset (Buffer);
	    LLU.Receive(Client_EP_Receive, Buffer'Access);             --Welcome
	    Reply := ASU.Unbounded_String'Input(Buffer'Access);
        Ada.Text_IO.Put_Line(ASU.To_String(Reply));
   	end if;
    
   -- A la vez que se envian mensajes en el bucle
   -- se están recibiendo mensajes en el manejador.
   
   while not Salir loop
      
      Ada.Text_IO.Put(">> ");
      Request := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);

      elsif Request = ".quit" then
		  -- Finaliza el programa
          Salir := True;
	      LLU.Finalize;
	  else 
		  ASU.Unbounded_String'Output(Buffer'Access, Request);
          LLU.Send(Client_EP_Handler, Buffer'Access);
      end if;

   end loop;

   LLU.Finalize;

exception
   when Usage_Error =>
		IO.Put_Line("Use: ");
		IO.Put_Line("       " & ACL.Command_Name & " <Pc Name>" & 
						" <Port Number>" & " <Nick>");
		IO.New_Line;
		LLU.Finalize;
		
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;
      
end Client;
