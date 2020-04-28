functor
import
    GUI
    Input
    PlayerManager
    System
define
    
    %functions
    InitPlayers
    InitPlayerPortList
    InitState
    MainLoop
    MoveLoop
    CheckDiveLoop
    CheckDive
    UpdateState
    Move
    

    %var
    PlayerPortList
    GUIPort
    NbPlayer

in

    


	%%%%%%%%%  functions  %%%%%%%%%%%%%  {PlayerManager.playerGenerator Kind Input.colors.1 1}

    fun {InitPlayerPortList}
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



    %%%%%%%%%%%%%

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

    proc {Move PlayerState} ID Position Direction in
                {Send PlayerState.port move(ID Position Direction)}
                if Direction == surface then 
                    {System.show 'dir=surface'} {Send GUIPort surface(ID)}
                else 
                    {Send GUIPort movePlayer(ID Position)}
                end
    end

    %%%%%%%%%%%%%%


    /*
    proc {MoveLoop Zero Pos PlayerList} ID Position Direction in
        {System.show 'MoveLoop'}
        case PlayerList of H|T then 
            if Zero == Pos then
                {System.show 'move H|T'}
                {Send H move(ID Position Direction)}
                {Send GUIPort movePlayer(ID Position)}
                {MoveLoop Zero+1 Pos T}
            else
                {MoveLoop Zero+1 Pos T}
        [] nil then skip end
        
    end*/

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

      fun {CheckDive PlayerState}
        if PlayerState.isSurface==true andthen PlayerState.turnSurface==0 then 
                    {System.show 'sub dive'}
                    {Send PlayerState.port dive}
                   playerState(isSurface:false turnSurface:0 isDead:PlayerState.isDead port:PlayerState.port)
        elseif  PlayerState.isSurface==true then
                    {System.show 'sub no dive'} 
                   playerState(isSurface:true turnSurface:PlayerState.turnSurface-1 isDead:PlayerState.isDead port:PlayerState.port)
        else PlayerState
        end
      end

      %%%%%%%%%%%%%%

  /*  %return un nouveau State
    fun {CheckDiveSingle  Pos PlayerList State}
        %return une nouvelle playerStateList et envoi le msg dive si un sub peut dive
        fun {Sub Zero Pos PlayerList L}
            {System.show 'appel de checkdive sub'}
            case PlayerList#L of (H1|T1)#(H2|T2) then 
                if Zero == Pos then 
                
                    {System.show 'sub case X#Y'}
                    if H2.isSurface==true andthen H2.turnSurface==0 then 
                        {System.show 'sub dive'}
                    {Send H1 dive}
                    playerState(isSurface:false turnSurface:0 isDead:H2.isDead)|{Sub Zero+1 Pos T1 T2}
                    elseif  H2.isSurface==true then
                        {System.show 'sub no dive'} 
                    playerState(isSurface:true turnSurface:H2.turnSurface-1 isDead:H2.isDead)|{Sub Zero+1 Pos T1 T2}
                    else 
                        H2|{Sub Zero+1 Pos T1 T2}
                    end
                    else
                        H2|{Sub Zero+1 Pos T1 T2} 
                    end
            [] nil#nil then {System.show 'sub case nil'} nil 
            else {System.show 'fail dans le case'}  yolo
            end
        end
    in 
        %change le state pour un nouveau state avec les décompte des turnSurface et les envois de msg dive (si nécéssaire) faits

        {UpdateState playerStateList|nil list(v:{Sub 0 Pos PlayerList State.playerStateList})|nil State} 
        
    end */

    %%%%%%%%%%%%%%
   /* proc{ItemCharge Player PlayerList }
        ID KindItem in 
        {Send Player chargeItem(ID KindItem)}
        if KindItem \= null %ie an item was created by the charge 
            then {PlayerRadio PlayerList sayCharge(ID KindItem)}
        else 
            skip
        end 

    end*/

    
    %%%%%%%%%%%%%%

    proc{SonarRes PlayerList Sonar Sender } %TODO : not sure if sonar is it's own type like drone 
    ID Answer in
        case PlayerList of H|T then 
        {Send H sayPassingSonar(ID Answer)}
        {Send Player sayAnswerSonar(ID Answer)}
        {SonarRes T Sonar Sender }
    [] nil then skip 
    end
    
    end 

    %%%%%%%%%%%%%%
    /*proc{DroneRes PlayerList Drone Sender } %% sender is the player that launched drone 
    ID Answer in
        case PlayerList of H|T then
        {Send H sayPassingDrone(Drone ID Answer)} %checks only one point ?
        {Send Sender sayAnswerDrone(Drone ID Answer)}
        {DroneRes T Drone Sender}
        []nil then skip 
        end
    end*/

    %%%%%%%%%%%%%%

    fun{ItemFire State PlayerList Player}
    ID KindFire in
    {Send Player fireItem(ID KindFire)}

            if ID == null then 
                State
            else
                
                case Type of 
                    mine(Aim) then % oops , Pos was already taken
                        %ID Mine in
                        %{Send H fireMine(ID Mine)} 
                        %% pas clair si fireMine est appelé pendant la phase fire ou explode ou les deux ? 
                        %if Mine == null then 
                        {PlayerRadio PlayerList sayMinePlaced(ID)}
                        {Send GUIPort putMine(ID Aim)} %% pour l'affichage graphique 
                        State
                        %not sure if state need to be updated 
                        %% keep record of mines placed on array ? 

                    [] missile(Aim) then
                        {MissileExploder State PlayerList Player}
                        %maybe send newState?
                    [] sonar(ID) then %% not mandatory , will do if I have time 
                        {Send GUIPort sonar(ID)}
                        {SonarRes PlayerList ID Player}
                        %TODO state ?



                    [] drone(ID Drone) then %% drones only detects players , not mines , uses single line instead of classic sector search
                        {Send GUIPort drone(ID Drone)}
                        {DroneRes PlayerList Drone Player}
                        %TODO state? 

                    else null then State
                end
            end




        else
            State
        end
        
    end



    %%%%%%%%%%%%%%
    fun{MissileRecursive State PlayerList Aim ID BasePlayerList} %keep basplayerlist intact for radio function
        case PlayerList of H|T then 
            Message in
            %Loop through players 
            {Send H sayMissileExplode(ID Aim Message)}
            %if Message == null then State
            case Message of null then State
                []sayDeath(ID2) then 
                    {PlayerRadio BasePlayerList sayDeath(ID2)}
                    {Send GUIPort removePlayer(ID2)}
                    %% TODO updateState 


                []sayDamageTaken(ID2 Damage LifeLeft) then 
                {PlayerRadio BasePlayerList sayDamandeTaken(ID2 Damage LifeLeft)}
                {Send GUIPort lifeUpdate(ID2 LifeLeft)}
                %TODO updatestate 

                end

            {MissileRecursive State T Aim ID BasePlayerList} %TODO  use new state variable after updating 


            end

            {Send GUIPort removeMine(ID Aim )}



    end

    
    %%%%%%%%%%%%%%
    

    fun{MissileExploder State PlayerList  Player}
    ID Mine in
        MissileState = {MissileRecursive State PlayerList Missile }
        MissileState
    end



    

    %%%%%%%%%%%%%%
    fun{MineRecursive State PlayerList Aim ID BasePlayerList} %keep basplayerlist intact for radio function
        case PlayerList of H|T then 
            Message in
            %Loop through players 
            {Send H sayMineExplode(ID Aim Message)}
            %if Message == null then State
            case Message of null then State
                []sayDeath(ID2) then 
                    {PlayerRadio BasePlayerList sayDeath(ID2)}
                    {Send GUIPort removePlayer(ID2)}
                    %% TODO updateState 


                []sayDamageTaken(ID2 Damage LifeLeft) then 
                {PlayerRadio BasePlayerList sayDamandeTaken(ID2 Damage LifeLeft)}
                {Send GUIPort lifeUpdate(ID2 LifeLeft)}
                %TODO updatestate 

                end

            {MineRecursive State T Aim ID BasePlayerList} %TODO  use new state variable after updating 


            end

            {Send GUIPort removeMine(ID Aim )}



    end

    
    %%%%%%%%%%%%%%
    

    fun{MineExploder State PlayerList Player}
    ID Mine in 
    {Send Player fireMine(ID Mine)}
    if Mine == null then State %no mine exploded 
    else
       ResState = {MineRecursive State PlayerList Mine ID PlayerList} 
       ResState
       %realised this could have been done cleaner , but if it aint broke don't fix it 

    end


    end


    %%%%%%%%%%%%%%
    
    proc{PlayerRadio PlayerList Info} %TODO maybe send back acknowledgement with fun instead?
        case PlayerList of H|T then 
            {Send H Info}
            {PlayerRadio T Info}
        [] nil then
            {System.show "Message has been sent to all players "}
        end 
    end

    


    %%%%%%%%%%%%%%

    fun {InitState PlayerPortList}  
        fun {Sub L}
            case L of H|T then playerState(isSurface:true turnSurface:Input.turnSurface isDead:false port:H)|{Sub T} 
            else nil end
        end
    in
        state(turn:1 playerStateList:{Sub PlayerPortList})
    end

    %%%%%%%%%%%%%% 
    
    %% state(turn<int>:x  playerStateList<list<record>>:x)
    %% playerState(isSurface<bool>:x turnSurface<int>:x isDead<bool>:x)

    fun {UpdateState Arg L State}
        case Arg#L of (H1|T1)#(H2|T2)then 
            case H1 of turn then {UpdateState T1 T2 state(turn:H2  playerStateList:State.playerStateList)} 
            [] playerStateList then {UpdateState T1 T2 state(turn:State.turn playerStateList:H2)}
            else {System.show 'erreur dans UpdateState'}
            end
        [] nil#nil then State end 
    end

    %%%%%%%%%%%%%%

  /*  proc {MainLoop State} NewState 
        fun{Turn State L Count} NewState in
            case L of H|T then 

                %SurfaceState = % checkdiveloop 
                %{SurfaceChecker State L Count} %% TODO make surf funtion that returns whether or not turn is over
                if SurfaceState == false then
                  %%TODO reassign TurnOver to change from tru to false and vice versa 
                  MoveState = {Move SurfaceState L Count}
                  %%checkdiveloop in move 

                  SurfaceState2 =   %

                  if SurfaceState2 == false %% in case direction is surface 
                      ChargeState = {ItemCharge MoveState L Count}
                       FireState = {ItemFire ChargeState L Count}
                      EndState{MineExploder FireState L Count}
                      %%% 

                   else
                   end
             else 
             end
           

            nil then State %%end turn ? 
            else
        end

    
    in 
        {System.show 'turn:'#State.turn} 
       % {MoveLoop PlayerList}
        %NewState= {CheckDiveLoop PlayerList State}
        {Delay 2000}
        
        {MainLoop {UpdateState turn|nil NewState.turn+1|nil NewState}}
    end*/

    %%%%%%%%%%%%%%

    proc {MainLoop State} NewState NewPlayerPortList

        fun {Turn PlayerState} S1 in
            S1={CheckDive PlayerState}
            {Move PlayerState}
            S1
        end

        fun {Sub L}
            case L of H|T then 
                {Turn H}|{Sub T}
            [] nil then nil end
        end

    
    in 
        {System.show 'turn:'#State.turn} 
        
        {Delay 2000}
        NewPlayerPortList = {Sub State.playerStateList}
        NewState = {UpdateState playerStateList|nil NewPlayerPortList|nil State}
        {MainLoop {UpdateState turn|nil NewState.turn+1|nil NewState}}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	%creation of the GUI's port
    GUIPort={GUI.portWindow}
    {Send GUIPort buildWindow}
    
    %creation of the players's port
    PlayerPortList={InitPlayerPortList}


    %init players
    {InitPlayers PlayerPortList}
    {System.show 'waiting for the GUI to be ready'}
    {Delay 5000}
    {System.show 'GUI should be ready at this point'}

    %launch the game
    {MainLoop {InitState PlayerPortList}}



end




