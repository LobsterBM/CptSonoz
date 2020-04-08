functor
import
	Player1
	Player2
	System
	
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		{System.show Kind}
		case Kind
		of player1 then {Player1.portPlayer Color ID}
		[] player2 then {Player2.portPlayer Color ID}
		end
	end
end
