functor
import
    GUI
    Input
    PlayerManager
    System
define
    
    %functions
    InitPlayers
    InitPlayerList
    MainLoop
    

    %var
    PlayerList
    GuiPort
    InitGui

in
	%%%%%%%%%  functions  %%%%%%%%%%%%%  {PlayerManager.playerGenerator Kind Input.colors.1 1}

    fun {InitPlayerList}
        fun {Sub Kind Color N} 
            if N=<Input.nbPlayer then 
                case Kind#Color of (H1|T1)#(H2|T2) then 
                    {PlayerManager.playerGenerator H1 H2 N}|{Sub T1 T2 N+1}
                end
            else   
                nil
            end
        end 
    in
      {Sub Input.players Input.colors 1}  
    end




    proc {InitPlayers L} ID Position in 
        case L of H|T then 
            {Send H initPosition(ID Position)}
            {Send GuiPort initPlayer(ID Position)}
            {InitPlayers T}
        [] nil then skip
        end
    end

    proc {MainLoop} ID Position Direction in
        {Send PlayerList.1 move(ID Position Direction)}
        case Direction of south then %{System.show 'direction sud captain'} 
        %{System.show ID}
        {Send GuiPort movePlayer(ID Position)}
        end
        {Delay 3000}
        {MainLoop}
    end


    

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%creation of the GUI's port
    GuiPort={GUI.portWindow}
    {Send GuiPort buildWindow}
    
    %creation of the players's port
    PlayerList={InitPlayerList}


    %init players
    {InitPlayers PlayerList}
    {System.show 'waiting for the GUI to be ready'}
    {Delay 10000}
    {System.show 'GUI should be ready at this point'}
    %launch the game
    {MainLoop}




end
