with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Chat_Messages;

package body Handlers is

   package ASU renames Ada.Strings.Unbounded;
   package IO renames Ada.Text_IO;
   package CM renames Chat_Messages;
   use type CM.Message_Type;
   
   Mess: CM.Message_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Nick: ASU.Unbounded_String;
      
   Reply: ASU.Unbounded_String;
   Request: ASU.Unbounded_String;
   Tipo: ASU.Unbounded_String;

   procedure Server_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
      
    begin
      
        Mess := CM.Message_Type'Input(P_Buffer);	
	    Tipo := ASU.To_Unbounded_String(CM.Message_Type'Image(Mess));
	    Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
        Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
        Nick := ASU.Unbounded_String'Input (P_Buffer);
        IO.Put_Line(ASU.To_String(Tipo)
                  &" recieved from " & ASU.To_String(Nick));
      
        if Mess = CM.Init then
            Reply := ASU.To_Unbounded_String("Mini-Chat v2.0: Welcome "
                                    & ASU.To_String(Nick));
            -- reinicializa (vacía) el buffer P_Buffer.all
            LLU.Reset (P_Buffer.all);
          
            -- introduce el Unbounded_String en el Buffer P_Buffer.all
            ASU.Unbounded_String'Output(P_Buffer, Reply);

            -- envía el contenido del Buffer P_Buffer.all
            LLU.Send(Client_EP_Receive, P_Buffer);
        end if;

    end Server_Handler;


    procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
 
   begin
      
     --Mess := CM.Message_Type'Input(P_Buffer);	
	 --Tipo := ASU.To_Unbounded_String(CM.Message_Type'Image(Mess));
	 --Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
			
	 IO.Put_Line(ASU.To_String(Nick) & ": "); --& ASU.To_String(Texto));
        

    end Client_Handler;

end Handlers;

