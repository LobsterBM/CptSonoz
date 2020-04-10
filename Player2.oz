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
    state(position:StartPosition)
end

fun {UpdateState Arg L State}
    nil
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    proc{TreatStream Stream State} % as as many parameters as you want
       case Stream of nil then skip
       [] initPosition(ID Position)|T then 
            {InitPosition ID Position}
            {TreatStream T State} % pas de changement de State pcq il est déjà initialisé
       [] move(ID Position Direction)|T then 
            {Move ID Position Direction State} % envoi(plutôt liage de var/val) la direction
            {TreatStream T state(position:pt(x:State.position.x+1 y:State.position.y))} %change la direction sur le player (tjrs sud pour l'instant)
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
