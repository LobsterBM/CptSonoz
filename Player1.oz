functor
import
    Input
    System
export
    portPlayer:StartPlayer
define
    StartPlayer
    TreatStream

    %functions
    CreateState
    InitPosition
    Move
    UpdateState
    InitState
    ConvertMapToArray
    PosToIndex
    IndexToPos
    IsValidPos
    ListPossibleMove
    CleanPath
   


    %variables
    MyID
    MyColor
    StartPosition



    MapArray
    % 0 = vide
    % 1 = île
    % 2 = position déjà visitée


in

%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%

proc {InitPosition ID Position} 
    ID=MyID
    Position=StartPosition
    {Array.put MapArray {PosToIndex StartPosition} 2}
{System.show 'InitPosition called'}
end 

%%%%%%%%%%%%%%%%%%%%%

fun {ConvertMapToArray Map NColumn NRow}
    proc {Sub N L A}
        case L of H1|T1 then 
                case H1 of H2|T2 then {Array.put A N H2} {Sub N+1 T2 A}  {Sub N+NColumn T1 A}
        [] nil then skip
        [] X then {Array.put A N X} {Sub N+1 T1 A} end
    [] nil then skip
    else {System.show 'should not appear'}
    end
    end
    Yolo %le tableau de retour
in
    {Array.new 1 NColumn*NRow 69 Yolo}
    {Sub 1 Map Yolo}
     Yolo
end

%%%%%%%%%%%%%%%%%%%%%

fun {PosToIndex Pos}
    Pos.y+(Pos.x-1)*Input.nColumn
end 

%%%%%%%%%%%%%%%%%%%%%

fun {IndexToPos Index} Y X in
   {Int.'div' Index Input.nColumn Y}
   {Int.'mod' Index Input.nColumn X}
   if X==0 then pt(x:Y y:Input.nColumn)
   else pt(x:Y+1 y:X)end
end

%%%%%%%%%%%%%%%%%%%%%

fun {IsValidPos Pos NColumn NRow Map} Val in
   if Pos.y>NColumn then  0
   elseif Pos.y<1 then 0
   elseif Pos.x<1 then  0
   elseif Pos.x>NRow then 0
   else {Array.get Map {PosToIndex Pos} Val}
        if Val==0 then 1
    else 0 end
   end
end

%%%%%%%%%%%%%%%%%%%%%

fun {ListPossibleMove Pos Map}
   fun {Sub L}
      case L of H|T then
     case H of r(dir:Dir pos:Position valid:Val) then
        if Val==1 then H|{Sub T}
        else {Sub T}
        end
     end
      [] nil then nil 
      end
   end
   L1
   North
   South
   East
   West
      in
   South = {IsValidPos pt(x:Pos.x+1 y:Pos.y) Input.nColumn Input.nRow Map}
   North = {IsValidPos pt(x:Pos.x-1 y:Pos.y) Input.nColumn Input.nRow Map}
   West  = {IsValidPos pt(x:Pos.x y:Pos.y-1) Input.nColumn Input.nRow Map}
   East  = {IsValidPos pt(x:Pos.x y:Pos.y+1) Input.nColumn Input.nRow Map}
   L1=r(dir:south pos:pt(x:Pos.x+1 y:Pos.y) valid:South)|r(dir:north pos:pt(x:Pos.x-1 y:Pos.y) valid:North)|
   r(dir:West pos:pt(x:Pos.x y:Pos.y-1) valid:West)|r(dir:East pos:pt(x:Pos.x y:Pos.y+1) valid:East)|nil

   {Sub L1}

end

%%%%%%%%%%%%%%%%%%%%%

proc {CleanPath Map Min Max}
   for I in Min..Max do Val in
      {Array.get Map I Val}
      if Val==2 then {Array.put Map I 0} end
   end
end

%%%%%%%%%%%%%%%%%%%%%

proc {Move ID Position Direction State} Val L in
    ID=MyID
    L={ListPossibleMove State.position MapArray}
    case L of H|T then {Array.put MapArray {PosToIndex H.pos} 2} Position=H.pos Direction=H.dir 
    [] nil then Direction=surface Position=State.position {System.show 'go surface 1'} {CleanPath MapArray 1 100} end

    
end

%%%%%%%%%%%%%%%%%%%%%

fun {InitState} 
    state(position:StartPosition turnSurface:Input.turnSurface life:Input.MaxDamage sonarCharge:0 mineCharge:0 itemPriority:sonar sonar:false mine:false target:none)
end

%%%%%%%%%%%%%%%%%%%%%

fun {UpdateState Arg L State}
   case Arg#L of (H1|T1)#(H2|T2)then 
            case H1 of position then {UpdateState T1 T2 state(position:H2 turnSurface:State.turnSurface life:State.life )} 
            [] turnSurface then {UpdateState T1 T2 state(position:State.position turnSurface:H2 life:State.life)} end
            []sonarReady then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:0 mineCharge:State.mineCharge itemPriority:mine sonar:true mine:State.mine target:State.target )}
            []chargeSonar then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge+1 mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:State.sonar mine:State.mine target:State.target )} 
            []mineReady then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:0 itemPriority:sonar sonar:State.mine mine:State.target target:State.target )}
            []chargeMine then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:State.mineCharge+1 itemPriority:State.itemPriority sonar:State.sonar mine:State.mine  target:State.target)}
            []sonarFired then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:false mine:State.mine target:State.target )}
            []mineFired then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:State.sonar mine:H2 target:State.target )}
            [] life then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:H2 sonarCharge:State.sonarCharge mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:State.sonar mine:State.mine target:State.target)} 
            []newTarget then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:State.sonar mine:State.mine target:H2 )} 
            []removeMine then {UpdateState T1 T2 state(position:State.position turnSurface:State.turnSurface life:State.life sonarCharge:State.sonarCharge mineCharge:State.mineCharge itemPriority:State.itemPriority sonar:State.sonar mine:false target:State.target )} 
        [] nil#nil then State end 
end

%%%%%%%%%%%%%%%%%%%%%%%


fun{ManDistance Pos1 Pos2}
Res Res1 Res2 in
{Number.abs (Pos1.x Pos2.x) Res1}
{Number.abs (Pos1.y Pos2.y) Res2}
Res = Res1 + Res2 
Res
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    proc{TreatStream Stream State} % as as many parameters as you want
        case Stream of nil then skip
        [] initPosition(ID Position)|T then 
            {InitPosition ID Position}
            {TreatStream T State} % pas de changement de State pcq il est déjà initialisé
        [] move(ID Position Direction)|T then 
            {System.show 'player1 did move. turnSurface:'#State.turnSurface}
            if State.turnSurface>0 then 
              ID=MyID
              Direction=idle
              Position=State.position
              {TreatStream T State}  
            else
              {Move ID Position Direction State} 
              {TreatStream T {UpdateState position|nil Position|nil State}}    
            end
        [] dive|T then {System.show ' go go go dive'} {TreatStream T {UpdateState turnSurface|nil 0|nil State}}
       
       [] chargeItem(ID KindItem)|T then 
       if State.itemPriority == sonar then
        ID = State.ID 
        if(State.sonarCharge == Input.Drone-1) then
            KindItem = sonar
            {TreatStream T {UpdateState sonarReady|nil 0|nil State}}
        else
              {TreatStream T {UpdateState chargeSonar|nil State.sonarCharge+1|nil State}}
        end
        
        else 
            ID = State.id
            if(State.mineCharge == Input.Mine-1) then 
                KindItem = mine
                %TODO add position for mine 
                {TreatStream T {UpdateState mineReady|nil 0|nil State}}

            else
                {TreatStream T {UpdateState chargeMine|nil State.mineCharge+1|nil State}}
            end
        end

       []fireItem(ID KindFire)|T then 
       ID = State.id
       if State.sonar == true then 
       KindFire = sonar
       {TreatStream T {UpdateState sonarFired|nil 0|nil State}}

       elseif State.mine \= false then
        MineDistance
       in
        MineDistance = {ManDistance State.position Mine.position}
        Id= State.id
        if  {And (MineDistance =< Input.MaxDistanceMine) (MineDistance >= Input.MinDistanceMine)} then
             
            KindFire = mine(State.mine)
            {TreatStream T {UpdateState removeMine|nil 0|nil State}}
        else
            {TreatStream T State }
        end
       else 
       {TreatStream T State }

       []fireMine(ID Mine)|T then 
       MineDistance
       in
       MineDistance = {ManDistance State.position Mine.position}
       Id= State.id
        if {And (State.mine \= true)  (State.mine \= false)}then 
            Mine = mien(State.mine)
            {TreatStream T {UpdateState removeMine|nil 0|nil State}}
        else
            {TreatStream T State }
        end
    
       
       [] isDead(Answer)|T then 
       if State.life > 0 then
       Answer  = true
       else 
       Answer = false
       end 

       {TreatStream T State}
       
       []sayMove(ID Direction)|T then
       {TreatStream T State}  
       
       []saySurface(ID)|T then 
       %say that player ID has made surface 
       {TreatStream T State}  
       []sayCharge(ID KindItem)|T then 
       
       {TreatStream T State}  
       
       []sayMinePlaced(ID)|T then
       {TreatStream T State}   
       
       []sayMissileExplode(ID Position Message)|T then 
       Explosion
       in
       Explosion = {ManDistance Position State.position}
       if Explosion > 1 then
            {TreatStream T State}
        else if Explosion == 1 then
            if State.life < 2 then
             %say death
             Message= sayDeath(State.id)
             {TreatStream T {UpdateState life|nil 0|nil State}}
             else
             Message= sayDamageTaken(State.id 1 State.life-1)
             {TreatStream T {UpdateState life|nil State.life-1|nil State}}
             end
        else 
            if State.life < 3 then
             %say death
             Message= sayDeath(State.id)
             {TreatStream T {UpdateState life|nil 0|nil State}}
             else
             Message= sayDamageTaken(State.id 2 State.life-2)
             {TreatStream T {UpdateState life|nil State.life-2|nil State}}
             end
        end
       
       
       []sayMineExplode(ID Position Message)|T then 
           Explosion
       in
       Explosion = {ManDistance Position State.position}
       if Explosion > 1 then
            {TreatStream T State}
        else if Explosion == 1 then
            if State.life < 2 then
             %say death
             Message= sayDeath(State.id)
             {TreatStream T {UpdateState life|nil 0|nil State}}
             else
             Message= sayDamageTaken(State.id 1 State.life-1)
             {TreatStream T {UpdateState life|nil State.life-1|nil State}}
             end
        else 
            if State.life < 3 then
             %say death
             Message= sayDeath(State.id)
             {TreatStream T {UpdateState life|nil 0|nil State}}
             else
             Message= sayDamageTaken(State.id 2 State.life-2)
             {TreatStream T {UpdateState life|nil State.life-2|nil State}}
             end
        end


       %check position
       []sayPassingDrone(Drone ID Answer)|T then 
    
       ID = State.id 
       case Drone of drone(row X) then
        if(X == State.position.x ) the
            Answer =true 
        else 
            Answer=false
        end

       [] column(Y) then 
        if(State.position.y == Y) then 
            Answer = true
        else 
            Answer = false
        end

       {TreatStream T State}
       
       
       []sayAnswerDrone(Drone ID Answer)|T then 
        {TreatStream T State}
       []sayPassingSonar(ID Answer)|T then 
       ID= State.id
       Answer = pt(x:State.position.x  y:State.position.x)
       {TreatStream T State}  

       []sayAnswerSonar(ID Answer)|T then 
       if (ID \= State.id) then %tant que cest pas le joueur meme 
        {TreatStream T {UpdateState newTarget|nil Answer|nil State}}
       else
       {TreatStream T State}  
       end 
       
       
       []sayDeath(ID)|T then 
       %informative message of ID's death 
       {TreatStream T State}  
       
       []sayDamageTaken(ID Damage LifeLeft)|T then 
       {TreatStream T State}  
       
       
       end 
    end

    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
        MapArray={ConvertMapToArray Input.map 10 10}
        MyColor=Color
        MyID=id(id:ID color:MyColor name:'player1')
        StartPosition=pt(x:1 y:3)
        {System.show MyID}
        thread
            {TreatStream Stream {InitState}}
        end
        Port
    end
end
