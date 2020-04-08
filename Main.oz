functor
import
    GUI
    Input
    PlayerManager
    System
define
    GuiPort
    InitPlayerPort
    PlayerList
in
	%%%%%%%%%  functions  %%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%création du port pour le gui
    GuiPort={GUI.portWindow}
    {Send GuiPort buildWindow}
    
    %création du port pour les joueurs
    PlayerList={PlayerManager.playerGenerator Input.colors.1 1}

end
