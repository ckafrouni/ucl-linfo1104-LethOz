local 
    % Vous pouvez remplacer ce chemin par celui du dossier qui contient LethOzLib.ozf
    % Please replace this path with your own working directory that contains LethOzLib.ozf

    % Dossier = {Property.condGet cwdir '/home/max/FSAB1402/Projet-2017'} % Unix example
    Dossier = {Property.condGet cwdir '.'}
    % Dossier = {Property.condGet cwdir 'C:\\Users\Thomas\Documents\UCL\Oz\Projet'} % Windows example.
    LethOzLib

    % Les deux fonctions que vous devez implémenter
    % The two function you have to implement
    Next
    DecodeStrategy

    % Hauteur et largeur de la grille
    % Width and height of the grid
    % (1 <= x <= W=24, 1 <= y <= H=24)
    W = 24
    H = 24

    Options
in
    % Merci de conserver cette ligne telle qu'elle.
    % Please do NOT change this line.
    [LethOzLib] = {Link [Dossier#'/'#'LethOzLib.ozf']}
    {Browse LethOzLib.play}

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Your code goes here  %
    % Votre code vient ici %
    %%%%%%%%%%%%%%%%%%%%%%%%

    local
        % Déclarez vos functions ici
        % Declare your functions here
        Utils
        Instructions
    in
        /*-------------------*
        * NAMESPACE 'Utils' *
        *-------------------*/
        Utils = local
            % TODO description
            fun {MapS L F U}
                case L of nil then nil
                [] H|T then {F H U}|{MapS T F H}
                end
            end

            % Creates a list with N elements E.
            % in: E:<any> - N:<integer>
            % out: <list>
            fun {Repeat E N} if N == 0 then nil else E|{Repeat E N-1} end end

            % TODO description
            fun {AbsoluteDir Turn To}
                case Turn
                of left then
                    case To
                    of north then west
                    [] west then south
                    [] south then east
                    [] east then north
                    end
                [] right then 
                    case To
                    of north then east
                    [] east then south
                    [] south then west
                    [] west then north
                    end
                end
            end
        in
            utils(
            mapS: MapS 
            repeat: Repeat
            absoluteDir: AbsoluteDir
            )
        end

        /*--------------------------*
        * NAMESPACE 'Instructions' *
        *--------------------------*/
        Instructions = local

            % Advances the spaceship forward one step.
            % in: Spaceship:<spaceship>
            % out: <spaceship>
            fun {Forward Spaceship}
            fun {Advance Pos NextPos}
                To = if NextPos == nil then Pos.to else NextPos.to end
            in
                case Pos.to
                of north then pos(x:Pos.x y:(Pos.y-1) to:To)
                [] south then pos(x:Pos.x y:(Pos.y+1) to:To)
                [] west then pos(x:(Pos.x-1) y:Pos.y to:To)
                [] east then pos(x:(Pos.x+1) y:Pos.y to:To)
                end
            end
            in
            spaceship(
                positions: {Utils.mapS Spaceship.positions Advance nil}
                effects: Spaceship.effects
            )
            end

            % Turns the spaceship without advancing
            % in: Spaceship: <spaceship> , Dir: left|right
            % out: <spaceship>
            fun {Turn Spaceship Dir}
            Positions = case Spaceship.positions
                of H|T then pos(x:H.x y:H.y to:{Utils.absoluteDir Dir H.to})|T
                else nil end
            in
            spaceship(
                positions: Positions
                effects: Spaceship.effects
            )
            end
        in
            instructions(
            forward: Forward
            turnLeft: fun {$ Spaceship} {Instructions.forward {Turn Spaceship left}} end
            turnRight: fun {$ Spaceship} {Instructions.forward {Turn Spaceship right}} end
            )
        end

        % La fonction qui renvoit les nouveaux attributs du serpent après prise
        % en compte des effets qui l'affectent et de son instruction
        % The function that computes the next attributes of the spaceship given the effects
        % affecting him as well as the instruction
        % 
        % instruction ::= forward | turn(left) | turn(right)
        % P ::= <integer x such that 1 <= x <= 24>
        % direction ::= north | south | west | east
        % spaceship ::=  spaceship(
        %               positions: [
        %                  pos(x:<P> y:<P> to:<direction>) % Head
        %                  ...
        %                  pos(x:<P> y:<P> to:<direction>) % Tail
        %               ]
        %               effects: [scrap|revert|wormhole(x:<P> y:<P>)|... ...]
        %            )
        fun {Next Spaceship Instruction}
            {Browse Instruction}
            case Instruction
            of forward then {Instructions.forward Spaceship}
            [] turn(left) then {Instructions.turnLeft Spaceship}
            [] turn(right) then {Instructions.turnRight Spaceship}
            end
        end

        
        % La fonction qui décode la stratégie d'un serpent en une liste de fonctions. Chacune correspond
        % à un instant du jeu et applique l'instruction devant être exécutée à cet instant au spaceship
        % passé en argument
        % The function that decodes the strategy of a spaceship into a list of functions. Each corresponds
        % to an instant in the game and should apply the instruction of that instant to the spaceship
        % passed as argument
        %
        % strategy ::= <instruction> '|' <strategy>
        %            | repeat(<strategy> times:<integer>) '|' <strategy>
        %            | nil
        %
        % CHRIS : TODO CHECK IF CAN BE FASTER (MAYBE THREADS ?)
        fun {DecodeStrategy Strategy}
            fun {Router Instruction}
            case Instruction
            of forward then fun {$ Spaceship} {Next Spaceship forward} end
            [] turn(D) then fun {$ Spaceship} {Next Spaceship turn(D)} end
            [] repeat(Strategy times:N) then E in
                thread E = {DecodeStrategy Strategy} end
                thread {Utils.repeat E N} end
            else raise unsupportedInstruction(Instruction) end
            end
            end
            L
        in
            L = {List.flatten {List.map Strategy Router}}
            {Browse Strategy}
            {Browse L}
            L
        end

        % Options
        Options = options(
            % Fichier contenant le scénario (depuis Dossier)
            % Path of the scenario (relative to Dossier)
            scenario:'scenario/scenario_crazy.oz'
            % scenario:'scenario/Scenario.oz'
            % Utilisez cette touche pour quitter la fenêtre
            % Use this key to leave the graphical mode
            closeKey:'Escape'
            % Visualisation de la partie
            % Graphical mode
            debug: true
            % Instants par seconde, 0 spécifie une exécution pas à pas. (appuyer sur 'Espace' fait avancer le jeu d'un pas)
            % Steps per second, 0 for step by step. (press 'Space' to go one step further)
            frameRate: 5
        )
    end

    %%%%%%%%%%%
    % The end %
    %%%%%%%%%%%
   
    local 
        R = {LethOzLib.play Dossier#'/'#Options.scenario Next DecodeStrategy Options}
    in
        {Browse R}
    end
end
