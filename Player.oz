functor
import
    Input
    System
export
    portPlayer:StartPlayer
define
    StartPlayer
    TreatStream
in
    proc{TreatStream Stream} % as as many parameters as you want
       {System.show 'yolo'}
    end
    fun{StartPlayer Color ID}
        Stream
        Port
    in
        {NewPort Stream Port}
        thread
            {TreatStream Stream}
        end
        Port
    end
end
