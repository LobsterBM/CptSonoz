functor
import
   GUI at 'GUI.ozf'
   Input at 'Input.ozf'
   PlayerManager at 'PlayerManager.ozf'
   Game at 'Game.ozf'
   Util at 'Projet2019util.ozf'
   Browser
   System(showInfo:Print)
define
   GUI_port
   BomberList

    /*
      Génère une liste de joueur sous le format tuple: player(port: *type* bomber(id: color: nom:))|player()
    */
    fun {GeneratePlayers}
      fun {Aux BomberList ColorList IDnum}
          if IDnum > Input.nbBombers then nil
          else
            case BomberList#ColorList of (H1|T1)#(H2|T2) then
              if (Input.isTurnByTurn) then
                player(port:{PlayerManager.playerGenerator H1 bomber(id:IDnum color:H2 name:H1)})|{Aux T1 T2 IDnum+1}
              else
                player(port:{PlayerManager.playerGenerator H1 bomber(id:IDnum color:H2 name:H1)})|{Aux T1 T2 IDnum+1}
              end
            end
          end
      end
    in 
      {Aux Input.bombers Input.colorsBombers 1}
    end


   /*
    Script exécuter sur chacun des players. 
    Permet d'initialiser le port du player, et le rendre "visible" pour l'interface graphique 
   */
   proc {InitPlayer Player}
      local PlayerID Message ID Pos SpawnPos in
        {Send Player.port getId(PlayerID)}
        {Wait PlayerID}
        {Send Player.port assignSpawn(SpawnPos)} %% Assigne un spawn (lieu de départ du joueur) au joueur %%Spawn pos doit etre une position sur la map = 4 et pas encore spawn pour un joueur.
        {Send GUI_port initPlayer(PlayerID)}
        {Send GUI_port spawnPlayer(PlayerID pt(x:2 y:2))} %% Affiche le joueur sur l'interface graphique
      end
   end
   
in
  
  %% Initialisation de l'interface graphique
  GUI_port = {GUI.portWindow}
  {Send GUI_port buildWindow}

  %% Récupération de la liste des players 
  BomberList = {GeneratePlayers}

  %% Exécution du script InitPlayer sur chacun des players
  {List.forAll BomberList InitPlayer}

  %% Exécution du mode de jeu adéqua 
  if (Input.isTurnByTurn) then
    {Game.startTurnByTurn GUI_port BomberList}
  else
    {Game.startSimultaneous GUI_port BomberList}
  end
end
