functor
import
    GUI
    Input
    PlayerManager
    System
define
    
    %functions
    InitPlayers
    InitPlayerPort

    %var
    ID 
    Position
    PlayerList
    GuiPort

in
	%%%%%%%%%  functions  %%%%%%%%%%%%%  {PlayerManager.playerGenerator Kind Input.colors.1 1}

    fun {InitPlayerPort}
        fun {Sub Kind Color N} 
            if N=<Input.nbPlayer then 
                case Kind#Color of (H1|T1)#(H2|T2) then 
                    {PlayerManager.playerGenerator H1 H2 N}|{Sub T1 T2 N+1}
                else 
                    %{System.show 'should not appear'} 
                    nil
                end
            else   
                nil
            end
        end 
    in
      {Sub Input.players Input.colors 1}  
    end




    proc {InitPlayers L} ID Position in 
        case L of nil then skip
        [] H|T then {Send H initPosition(ID Position)} {InitPlayers T}
        end
    end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%creation of the GUI's port
    GuiPort={GUI.portWindow}
    {Send GuiPort buildWindow}
    
    %creation of the players's port
    PlayerList={InitPlayerPort}

    %init players
    %{InitPlayers PlayerList}

    %launch the game





end
