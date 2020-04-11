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
    CheckDiveLoop
    UpdateState
    

    %var
    PlayerList
    GUIPort
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
        proc {Sub L N} ID Position in 
            case L of H|T then 
                {Send H initPosition(ID Position)}
                {Send GUIPort initPlayer(ID Position)}
                {Sub T N+1}
            [] nil then NbPlayer=N end
        end
    in
        {Sub L 1}
    end

    %%%%%%%%%%%%%%

    proc {MoveLoop PlayerList} ID Position Direction in
        {System.show 'MoveLoop'}
        case PlayerList of H|T then 
            {System.show 'move H|T'}
            {Send H move(ID Position Direction)}
            {Send GUIPort movePlayer(ID Position)}
            {MoveLoop T}
        [] nil then skip end
        
    end

    %%%%%%%%%%%%%%

    %return un nouveau State
    fun {CheckDiveLoop PlayerList State}
        %return une nouvelle playerStateList et envoi le msg dive si un sub peut dive
        fun {Sub PlayerList L}
            {System.show 'appel de checkdive sub'}
            case PlayerList#L of (H1|T1)#(H2|T2) then 
                {System.show 'sub case X#Y'}
                if H2.isSurface==true andthen H2.turnSurface==0 then 
                    {System.show 'sub dive'}
                   {Send H1 dive}
                   playerState(isSurface:false turnSurface:0 isDead:H2.isDead)|{Sub T1 T2}
                elseif  H2.isSurface==true then
                    {System.show 'sub no dive'} 
                   playerState(isSurface:true turnSurface:H2.turnSurface-1 isDead:H2.isDead)|{Sub T1 T2}
                else 
                    H2|{Sub T1 T2}
                end
            [] nil#nil then {System.show 'sub case nil'} nil 
            else {System.show 'fail dans le case'}  yolo
            end
        end
    in 
        %change le state pour un nouveau state avec les décompte des turnSurface et les envois de msg dive (si nécéssaire) faits

        {UpdateState playerStateList|nil list(v:{Sub PlayerList State.playerStateList})|nil State} 
        
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
            case H1 of turn then {UpdateState T1 T2 state(turn:H2  playerStateList:State.playerStateList)} 
            [] playerStateList then {UpdateState T1 T2 state(turn:State.turn playerStateList:H2.v)}
            else {System.show 'erreur dans UpdateState'}
            end
        [] nil#nil then State end 
    end

    %%%%%%%%%%%%%%

    proc {MainLoop State} NewState in 
        {System.show 'turn:'} {System.show State.turn} % moche af
        {MoveLoop PlayerList}
        NewState= {CheckDiveLoop PlayerList State}
        {Delay 2000}
        {MainLoop {UpdateState turn|nil NewState.turn+1|nil NewState}}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%creation of the GUI's port
    GUIPort={GUI.portWindow}
    {Send GUIPort buildWindow}
    
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
