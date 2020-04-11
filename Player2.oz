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


    %variables
    MyID
    MyColor
    StartPosition


in

%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%

proc {InitPosition ID Position} 
    ID=MyID
    Position=StartPosition
{System.show 'InitPosition called'}
end 

%%%%%%%%%%%%%%%%%%%%%

proc {Move ID Position Direction State}
    ID=MyID
    Position=State.position
    Direction=south
end

%%%%%%%%%%%%%%%%%%%%%

fun {InitState} 
    state(position:StartPosition turnSurface:Input.turnSurface)
end

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
            {Move ID Position Direction State} % envoi(plutôt liage de var/val) la direction
            {TreatStream T {UpdateState position|nil pt(x:State.position.x+1 y:State.position.y)|nil State}} %change la direction sur le player (tjrs sud pour l'instant)  
            %state(position:pt(x:State.position.x+1 y:State.position.y))
        [] dive|T then {TreatStream T State}
       end 
    end

    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
        MyColor=Color
        MyID=id(id:ID color:MyColor name:'player2')
        StartPosition=pt(x:1 y:6)
        {System.show MyID}
        thread
            {TreatStream Stream {InitState}}
        end
        Port
    end
end
