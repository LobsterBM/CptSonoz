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

proc {Move ID Position Direction State} Val L in
    ID=MyID
    L={ListPossibleMove State.position MapArray}
    case L of H|T then {Array.put MapArray {PosToIndex H.pos} 2} Position=H.pos Direction=H.dir 
    [] nil then Direction=dive {System.show 'go surface'} end

    
end

%%%%%%%%%%%%%%%%%%%%%

fun {InitState} 
    state(position:StartPosition turnSurface:Input.turnSurface)
end

%%%%%%%%%%%%%%%%%%%%%

fun {UpdateState Arg L State}
   case Arg#L of (H1|T1)#(H2|T2)then 
            case H1 of position then {UpdateState T1 T2 state(position:H2 turnSurface:State.turnSurface)} 
            [] turnSurface then {UpdateState T1 T2 state(position:State.position turnSurface:H2)} end
        [] nil#nil then State end 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    proc{TreatStream Stream State} % as as many parameters as you want
        case Stream of nil then skip
        [] initPosition(ID Position)|T then 
            {InitPosition ID Position}
            {TreatStream T State} % pas de changement de State pcq il est déjà initialisé
        [] move(ID Position Direction)|T then 
            {System.show 'player1 did move'}
            {Move ID Position Direction State} % envoi(plutôt liage de var/val) la direction
            {TreatStream T {UpdateState position|nil Position|nil State}}         %change la direction sur le player (tjrs sud pour l'instant)  
            %state(position:pt(x:State.position.x+1 y:State.position.y))
        [] dive|T then {System.show ' go go go dive'} {TreatStream T State}
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
