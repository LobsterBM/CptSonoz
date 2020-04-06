functor
import
  Input at 'Input.ozf'
  Util at 'Projet2019util.ozf'
  System(showInfo:Print show:Show)
  Browser
export
  startTurnByTurn:StartTurnByTurn
  startSimultaneous:StartSimultaneous
  initPosition:InitPosition
define
  StartTurnByTurn
  StartSimultaneous
  InitPosition
  GetInitPlaceAvailable
  NewPlayerList
  A B C
in
  proc {StartTurnByTurn GUI_PORT PlayerList}

    proc {BombCount TurnLeft}
      {Delay 500}
    end

    proc {Inform Message PlayerId}
      
      proc {SendMessage Player}
        ID 
      in
        {Send Player.port getId(ID)}
        {Wait ID}
        if PlayerId == null then
          {Send Player.port info(Message)}
        elseif (ID.id \= PlayerId.id)  then
          {Send Player.port info(Message)}
        end
      end

      in
      {List.forAll PlayerList SendMessage}
    end
    
    fun {PlayTurn Player}
      ID2 Action State Pos NPlayer 
    in
      {Delay 500}
      {Send Player.port doaction(ID2 Action)}
      {Wait Action}
     {ClearBomb pt(x:6 y:4)}
     {Browser.browse Input.map}
     {Delay 10000}
      case Action of move(Pos) then
        {Send GUI_PORT movePlayer(ID2 Pos)}
        {Inform movePlayer(ID2 Pos) ID2}
        Player
      [] bomb(Pos) then
        {Browser.browse 'Bomb'}
        {Inform bombPlanted(Pos) ID2}
        {Delay 600} %TODO gerer bombe
        {VisualExplosion pt(x:6 y:4)}
        %{Record.adjoin Player player(alive:false) NPlayer}
        Player
      end
    end

    fun {Run PlayerList}
      case PlayerList of nil then nil
      [] Player|T then
        if Player.alive == true then
          {PlayTurn Player}|{Run T}
        else
          {Run T}
        end
      end
    end

    proc {Loop PlayerList}
      ID 
    in
      if ({List.length PlayerList} > 1) then
        {Loop {Run PlayerList}}
      else
        {Send PlayerList.1.port getId(ID)}
        {Wait ID}
        {Send GUI_PORT displayWinner(ID)} % Player Win
      end
    end

     fun{MapElement Pos}
      {Nth {Nth Input.map Pos.y} Pos.x }
    end
    
    
    fun {IsObstacle Pos}
      local MapPos in
        MapPos = {MapElement Pos} 
        if {Or MapPos == 0 MapPos== 4} then false
        else true
        end
      end
    end

    proc{FireStarter Pos}
      local MapPos in
        MapPos = {MapElement Pos}
        if MapPos == 2 then
          {Send GUI_PORT spawnFire(Pos)}
          {Send GUI_PORT hideBox(Pos)}
          {Inform boxRemoved(Pos) null}
        elseif MapPos == 3 then
          {Send GUI_PORT spawnFire(Pos)}
          {Send GUI_PORT hideBox(Pos)}
          {Inform boxRemoved(Pos) null}
          {Send GUI_PORT spawnBonus(Pos)}
          
        elseif {Or MapPos == 4 MapPos == 0 } then
          {Send GUI_PORT spawnFire(Pos)}
        else skip
        end
      end
    end


    proc {EastPropagation Pos N}
      if N == 0 then skip
      else 
        {FireStarter Pos} % does appropriate action on selected case 
        if {IsObstacle Pos} then skip
        else 
         {EastPropagation pt(x:(Pos.x)+1 y:Pos.y) N-1}
        end
      end 
    end

    proc {WestPropagation Pos N}
      if N == 0 then skip
      else 
        {FireStarter Pos} % does appropriate action on selected case 
        if {IsObstacle Pos} then skip
        else 
         {WestPropagation pt(x:(Pos.x)-1 y:Pos.y) N-1}
        end
      end 
    end

    proc {NorthPropagation Pos N}
      if N == 0 then skip
      else 
        {FireStarter Pos} % does appropriate action on selected case
        if {IsObstacle Pos} then skip
        else  
         {NorthPropagation pt(y:(Pos.y)+1 x:Pos.x) N-1}
        end
      end 
    end

  
    proc {SouthPropagation Pos N}
     if N == 0 then skip
     else 
        {FireStarter Pos} % does appropriate action on selected case 
        if {IsObstacle Pos} then skip
        else 
          {SouthPropagation pt(y:(Pos.y)-1 x:Pos.x) N-1}
        end
     end 
   end




    proc {VisualExplosion Pos}
    {Inform bombExploded(Pos) null}
    {Send GUI_PORT hideFire(Pos)}
    {Send GUI_PORT spawnBomb(Pos)}
     {EastPropagation pt(x:(Pos.x)+1 y:Pos.y ) Input.fire+1}
     {WestPropagation pt(x:(Pos.x)-1 y:Pos.y ) Input.fire+1}
     {NorthPropagation pt(y:(Pos.y)+1 x:Pos.x ) Input.fire+1}
     {SouthPropagation pt(y:(Pos.y)-1 x:Pos.x ) Input.fire+1}
     %north east south west check 
    end

    
    proc {EastClear Pos N}
      if N == 0 then skip
      else 
        {Send GUI_PORT hideFire(Pos)}
        {EastClear pt(x:(Pos.x)+1 y:Pos.y) N-1}      
      end 
    end

    proc {WestClear Pos N}
      if N == 0 then skip
      else 
        {Send GUI_PORT hideFire(Pos)}
        {WestClear pt(x:(Pos.x)-1 y:Pos.y) N-1}      
      end 
    end

    proc {NorthClear Pos N}
      if N == 0 then skip
      else 
        {Send GUI_PORT hideFire(Pos)}
        {NorthClear pt(y:(Pos.y)+1 x:Pos.x) N-1}      
      end 
    end

    
    proc {SouthClear Pos N}
      if N == 0 then skip
      else 
        {Send GUI_PORT hideFire(Pos)}
        {SouthClear pt(y:(Pos.y)-1 x:Pos.x) N-1}      
      end 
    end

    proc{ClearBomb Pos}
      {Send GUI_PORT hideBomb(Pos)}
      {EastClear pt(x:(Pos.x)+1 y:Pos.y ) Input.fire}
      {WestClear pt(x:(Pos.x)-1 y:Pos.y ) Input.fire}
      {NorthClear pt(y:(Pos.y)+1 x:Pos.x ) Input.fire}
      {SouthClear pt(y:(Pos.y)-1 x:Pos.x ) Input.fire}
    end




    





  in
  
    {Loop PlayerList}

  end



end