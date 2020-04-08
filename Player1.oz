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
    InitPosition

    %variables
    MyID
    MyColor


in

%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%

proc {InitPosition ID Position} 
    ID=id(id:MyID color:MyColor name:'player1')
    Position=pt(x:1 y:3)
{System.show 'InitPosition called'} end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    proc{TreatStream Stream} % as as many parameters as you want
       case Stream of nil then skip
       [] initPosition(ID Position)|S then {InitPosition ID Position}
       end 
    end

    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
        MyID=ID
        MyColor=Color
        {System.show 'creation of player1'}
        {System.show MyID}
        {System.show MyColor}
        thread
            {TreatStream Stream}
        end
        Port
    end
end
