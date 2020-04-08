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

proc {InitPosition ID Position} {System.show 'InitPosition called'} end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    proc{TreatStream Stream} % as as many parameters as you want
       case Stream of nil then skip
       []initPosition(ID Position) then {InitPosition ID Position}
       else skip
       end 
    end

    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
       % MyID=ID
        {System.show 'creation of a player'}
        %{System.show MyID}
        thread
            {TreatStream Stream}
        end
        Port
    end
end
