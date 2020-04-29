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
    CheckDive
    UpdateState
    Move
    MineExploder
    MineRecursive
    PlayerRadio
    Delete
    ItemFire
    MissileExploder
    MissileRecursive
    

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

    fun {Move PlayerState} ID Position Direction in
                {Send PlayerState.port move(ID Position Direction)}
                if Direction == surface then 
                    {System.show 'dir=surface'} {Send GUIPort surface(ID)}
                else 
                    {Send GUIPort movePlayer(ID Position)}
                end

                if Direction == idle orelse Direction == surface then true
                else false end
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


    fun {Delete L I}
        case L of H|T then
            if I==0 then T
            else H|{Delete T I-1}end
        else 
            {System.show 'Should not appear (Delete)'}
       end   
    end

    %%%%%%%%%%%%%%

    /*proc{SonarRes PlayerList Sonar Sender } %TODO : not sure if sonar is it's own type like drone 
    ID Answer in
        case PlayerList of H|T then 
            {Send H sayPassingSonar(ID Answer)}
            {Send Player sayAnswerSonar(ID Answer)}
            {SonarRes T Sonar Sender }
        [] nil then skip end
    end */


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

    proc {ItemFire State PlayerList PlayerPort}
        ID KindFire 
    in
        {Send PlayerPort fireItem(ID KindFire)}

        case KindFire of null then skip
        [] mine(Aim) then % oops , Pos was already taken
                       /* %ID Mine in
                        %{Send H fireMine(ID Mine)} 
                        %% pas clair si fireMine est appelé pendant la phase fire ou explode ou les deux ? 
                        %if Mine == null then 
                        {PlayerRadio PlayerList sayMinePlaced(ID)}
                        {Send GUIPort putMine(ID Aim)} %% pour l'affichage graphique 

                        %% keep record of mines placed on array ? */
                        skip

        [] missile(Aim) then
                        {System.show 'Missile has been fired'} 
                        {MissileExploder State PlayerList ID}
        [] sonar(ID) then %% not mandatory , will do if I have time 
                        /*{Send GUIPort sonar(ID)}
                        {SonarRes PlayerList ID Player}*/
                        skip
        [] drone(ID Drone) then %% drones only detects players , not mines , uses single line instead of classic sector search
                        /*{Send GUIPort drone(ID Drone)}
                        {DroneRes PlayerList Drone Player}*/
                        skip
        else {System.show 'message unhandled received (Main,ItemFire)'}
        end
    end



    %%%%%%%%%%%%%%
    proc {MissileRecursive PlayerPortList Aim ID} %keep basplayerlist intact for radio function
        Message 
    in
        case PlayerPortList of H|T then 
           
            %Loop through players 
            {Send H sayMissileExplode(ID Aim Message)}

            case Message of null then skip
                []sayDeath(ID2) then 
                    {PlayerRadio PlayerPortList sayDeath(ID2)}
                    {Send GUIPort removePlayer(ID2)}
                []sayDamageTaken(ID2 Damage LifeLeft) then 
                    {PlayerRadio PlayerPortList sayDamandeTaken(ID2 Damage LifeLeft)}
                    {Send GUIPort lifeUpdate(ID2 LifeLeft)}
                end

            {MissileRecursive T Aim ID} 
        [] nil then skip 
        end
    end
    
    
    %%%%%%%%%%%%%%
    
    
    proc {MissileExploder State PlayerPortList  ID}
        ID Missile
    in
         {MissileRecursive  PlayerPortList Missile ID}
    end
    


    

    %%%%%%%%%%%%%%
    proc {MineRecursive State PlayerPortList Position ID BasePlayerList } %keep basplayerlist intact for radio function 
        
        case PlayerPortList of H|T then %Loop through players 
            Message 
            NewState
            NewList
        in
           {Send H sayMineExplode(ID Position Message)}
            
            case Message of null then skip
                [] sayDeath(ID2) then 
                    {PlayerRadio BasePlayerList sayDeath(ID2)}
                    {Send GUIPort removePlayer(ID2)}
                []sayDamageTaken(ID2 Damage LifeLeft) then 
                    {PlayerRadio BasePlayerList sayDamandeTaken(ID2 Damage LifeLeft)}
                    {Send GUIPort lifeUpdate(ID2 LifeLeft)}
                else {System.show 'Should not appear (MineRecursive)'}
        
            end

            {MineRecursive State T Position ID BasePlayerList } %TODO  use new state variable after updating 


        [] nil then skip end %{Send GUIPort removeMine(ID Position)}  end
    end
        
    
    %%%%%%%%%%%%%%
    

    
    proc{MineExploder State PlayerList PlayerPort}
        ID Mine 
    in 
        {Send PlayerPort fireMine(ID Mine)}
        if Mine == null then skip %no mine exploded 
        else
            {MineRecursive State PlayerList Mine ID PlayerList } 
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
    %% playerState(isSurface<bool>:x turnSurface<int>:x isDead<bool>:x prot<Port>:x)

    fun {UpdateState Arg L State}
        case Arg#L of (H1|T1)#(H2|T2)then 
            case H1 of turn then {UpdateState T1 T2 state(turn:H2  playerStateList:State.playerStateList)} 
            [] playerStateList then {UpdateState T1 T2 state(turn:State.turn playerStateList:H2)}
            else {System.show 'erreur dans UpdateState'}
            end
        [] nil#nil then State end 
    end

    %%%%%%%%%%%%%%

    proc {MainLoop State} NewState NewPlayerList

        fun {Turn PlayerState} Surface S1 S2 in
            S1={CheckDive PlayerState}
            Surface={Move PlayerState} % if the player's at the surface then he moves to his own position
            if Surface==true then S1 
            else 
                {ItemFire State PlayerPortList PlayerState.port}
                {MineExploder State PlayerPortList PlayerState.port}
                S1
            end
        end

        fun {Sub L}
            case L of H|T then 
                {Turn H}|{Sub T}
            [] nil then nil end
        end

    
    in 
        {System.show 'turn:'#State.turn} 
        
        {Delay 1000}
        NewPlayerList = {Sub State.playerStateList}
        NewState = {UpdateState playerStateList|nil NewPlayerList|nil State}
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




