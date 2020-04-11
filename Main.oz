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
    InitState
    MainLoop
    MoveLoop
    UpdateState
    

    %var
    PlayerList
    GuiPort
    InitGui
    NbPlayer

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


    %%%%%%%%%%%%%%

    proc {InitPlayers L} 
        N
        proc {Sub L N} ID Position in 
            case L of H|T then 
                {Send H initPosition(ID Position)}
                {Send GuiPort initPlayer(ID Position)}
                {Sub T N+1}
            [] nil then NbPlayer=N end
        end
    in
        {Sub L 1}
    end

    %%%%%%%%%%%%%%

    proc {MoveLoop PlayerList} ID Position Direction in
        case PlayerList of H|T then 
            {Send H move(ID Position Direction)}
            {Send GuiPort movePlayer(ID Position)}
            {MoveLoop T}
        [] nil then skip end
        
    end

   
    %%%%%%%%%%%%%%

    fun {InitState PlayerList}  
        fun {Sub L}
            case L of H|T then playerState(isSurface:true turnSurface:Input.turnSurface isDead:false)|{Sub T} 
            else nil end
        end
    in
        state(turn:1 playerStateList:{Sub PlayerList})
    end

    %%%%%%%%%%%%%%

    %% state(turn<int>:x  playerStateList<list<record>>:x)
    %% playerState(isSurface<bool>:x turnSurface<int>:x isDead<bool>:x)

    fun {UpdateState Arg L State}
        case Arg#L of (H1|T1)#(H2|T2)then 
            case H1 of turn then {UpdateState T1 T2 state(turn:H2  playerStateList:State.playerStateList)} end
        [] nil#nil then State end 
    end

    %%%%%%%%%%%%%%

    proc {MainLoop State} ID Position Direction in
        {System.show 'turn:'} {System.show State.turn} % moche af
        {MoveLoop PlayerList}
        {Delay 2000}
        {MainLoop {UpdateState turn|nil State.turn+1|nil State}}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%creation of the GUI's port
    GuiPort={GUI.portWindow}
    {Send GuiPort buildWindow}
    
    %creation of the players's port
    PlayerList={InitPlayerList}


    %init players
    {InitPlayers PlayerList}
    {System.show 'waiting for the GUI to be ready'}
    {Delay 5000}
    {System.show 'GUI should be ready at this point'}

    %launch the game
    {MainLoop {InitState PlayerList}}




end
