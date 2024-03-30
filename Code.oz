/*

[LINFO1104] - LethOz Company - Spaceship Game
authors: Christophe Kafrouni, Nicolas ...

*/

/*

EBNF Grammar for the spaceship game

<instruction> ::= forward | turn(left) | turn(right)
<direction> ::= north | south | west | east
<P> ::= <integer x such that 1 <= x <= 24>

<spaceship> ::=
    spaceship(
        positions: [
            pos(x:<P> y:<P> to:<direction>) % Head
            ...
            pos(x:<P> y:<P> to:<direction>) % Tail
        ]
        effects: [scrap|revert|wormhole(x:<P> y:<P>)|... ...]
    )

strategy ::=
    <instruction> '|' <strategy>
    | repeat(<strategy> times:<integer>) '|' <strategy>
    | nil

*/

local
    % Please replace this path with your own working directory that contains LethOzLib.ozf
    % Dossier = {Property.condGet cwdir '/home/max/FSAB1402/Projet-2017'} % Unix example
    Dossier = {Property.condGet cwdir '.'}
    % Dossier = {Property.condGet cwdir 'C:\\Users\Thomas\Documents\UCL\Oz\Projet'} % Windows example.
    LethOzLib

    % The two function you have to implement
    Next
    DecodeStrategy

    % Width and height of the grid
    % (1 <= x <= W=24, 1 <= y <= H=24)
    % TODO (chris) : use these values.
    % W = 24
    % H = 24
in
    % Please do NOT change this line.
    [LethOzLib] = {Link [Dossier#'/'#'LethOzLib.ozf']}
    {Browse LethOzLib.play}

    %%%%%%%%%%%%%%%%%%%%%%%%%
    %  Our code goes here   %
    % ↓    ↓    ↓    ↓    ↓ %

    local
        % Namespaces
        Utils Instructions
    in
        /*-------------------*
         * NAMESPACE 'Utils' *
         *-------------------*/
        Utils = local
            /**
             * Maps the function F onto every item of L with a state.
             * @arg L : <list A>
             * @arg F : <fun (A|nil, A) : B>
             * @arg U : <A>
             * @ret : <list B>
             */
            fun {MapS L F U}
                case L of nil then nil
                [] H|T then {F U H}|{MapS T F H}
                end
            end

            /**
             * Creates a list with N elements E.
             * @arg E : <A>
             * @arg N : <integer>
             * @ret : <list A>
             */
            fun {Repeat E N} if N == 0 then nil else E|{Repeat E N-1} end end

            /**
             * Gets the new absolute direction after turn
             * @arg Turn : left|right|revert
             * @arg Dir : <direction>
             * @ret : <direction>
             */
            fun {DirAfterTurn Turn Dir}
                case Turn
                of left then
                    case Dir
                    of north then west
                    [] west then south
                    [] south then east
                    [] east then north
                    end
                [] right then
                    case Dir
                    of north then east
                    [] east then south
                    [] south then west
                    [] west then north
                    end
                [] revert then
                    case Dir
                    of north then south
                    [] south then north
                    [] west then east
                    [] east then west
                    end
                end
            end

            /**
             * Next position
             * @arg Pos : <pos>
             * @arg Dir : <direction>
             * @ret : <pos>
             */
            fun {NextPos Pos Dir}
                case Pos.to
                of north then pos(x:Pos.x y:(Pos.y-1) to:Dir)
                [] south then pos(x:Pos.x y:(Pos.y+1) to:Dir)
                [] west then pos(x:(Pos.x-1) y:Pos.y to:Dir)
                [] east then pos(x:(Pos.x+1) y:Pos.y to:Dir)
                end
            end

            /**
             * Previous position
             * @arg Pos : <pos>
             * @arg Dir : <direction>
             * @ret : <pos>
             */
            fun {PrevPos Pos Dir}
                case Pos.to
                of north then pos(x:Pos.x y:(Pos.y+1) to:Dir)
                [] south then pos(x:Pos.x y:(Pos.y-1) to:Dir)
                [] west then pos(x:(Pos.x+1) y:Pos.y to:Dir)
                [] east then pos(x:(Pos.x-1) y:Pos.y to:Dir)
                end
            end
        in
            utils(
                mapS: MapS
                repeat: Repeat
                dirAfterTurn: DirAfterTurn
                nextPos: NextPos
                prevPos: PrevPos
            )
        end

        /*--------------------------*
         * NAMESPACE 'Instructions' *
         *--------------------------*/
        Instructions = local
            /**
             * Advances the spaceship forward one step.
             * @arg Spaceship : <spaceship>
             * @ret : <spaceship>
             */
            fun {Forward Spaceship}
                fun {Advance PrevPos Pos}
                    To = if PrevPos == nil then Pos.to else PrevPos.to end
                in
                    {Utils.nextPos Pos To}
                end
            in
                spaceship(
                    positions: {Utils.mapS Spaceship.positions Advance nil}
                    effects: Spaceship.effects
                )
            end

            /**
             * Turns the spaceship *without* advancing.
             * @arg Spaceship : <spaceship>
             * @arg Dir : left|right
             * @ret : <spaceship>
             */
            fun {Turn Spaceship Dir}
                Positions = case Spaceship.positions
                    of H|T then pos(x:H.x y:H.y to:{Utils.dirAfterTurn Dir H.to})|T
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

        /**
         * The function that computes the next attributes of the spaceship given the effects
         * affecting him as well as the instruction.
         * @arg Spaceship : <spaceship>
         * @arg Instruction : <instruction>
         * @ret : <spaceship>
         */
        fun {Next Spaceship Instruction}
            fun {ApplyEffect Spaceship Effect}
                {Browse Effect}
                case Effect
                of scrap then Last = {List.last Spaceship.positions} in spaceship(
                    positions: {List.append Spaceship.positions [{Utils.prevPos Last Last.to}]}
                    effects: nil % TODO (chris) : Do we remove all effects ?
                    )
                [] revert then 
                    fun {Revert PrevPos Pos} 
                        To = if PrevPos == nil then Pos.to else PrevPos.to end 
                    in pos(x:Pos.x y:Pos.y to:{Utils.dirAfterTurn revert To}) end
                in spaceship(
                    positions: {Utils.mapS {List.reverse Spaceship.positions} Revert nil}
                    effects: nil % TODO (chris) : Do we remove all effects ?
                )
                % [] wormhole(x:X y:Y) then % TODO (chris) : Implement wormhole
                else raise unsupportedEffect(Effect) end
                end
            end
            Spaceship2
        in
            {Browse Instruction} % {Browse Spaceship}
            % 1. apply effects
            Spaceship2 = {List.foldL Spaceship.effects ApplyEffect Spaceship}
            
            % 2. apply instruction
            case Instruction
            of forward then {Instructions.forward Spaceship2}
            [] turn(left) then {Instructions.turnLeft Spaceship2}
            [] turn(right) then {Instructions.turnRight Spaceship2}
            else {Browse expressionNotSupported(Instruction)} Spaceship2
            end
        end

        /**
         * The function that decodes the strategy of a spaceship into a list of functions. Each corresponds
         * to an instant in the game and should apply the instruction of that instant to the spaceship
         * passed as argument.
         *
         * @arg Strategy : <strategy>
         */
        fun {DecodeStrategy Strategy}
            % TODO (chris) : Can we make this more efficient ? Threads or not having to call flatten ?
            /**
             * Converts an instruction into a function that calls Next.
             * @arg Instruction : <instruction>
             * @ret : <list <fun (spaceship) : spaceship>>
             */
            fun {InstToFunc Instruction}
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
            L = {List.flatten {List.map Strategy InstToFunc}}
            % {Browse Strategy} {Browse L}
            L
        end
    end

    % ↑    ↑    ↑    ↑    ↑ %
    %   Our code end here   %
    %%%%%%%%%%%%%%%%%%%%%%%%%

    local
        Options = options(
            % Path of the scenario (relative to Dossier)
            % scenario:'scenario/scenario_test_moves.oz'
            scenario:'scenario/Scenario.oz'
            % Use this key to leave the graphical mode
            closeKey:'Escape'
            % Graphical mode
            debug: true
            % Steps per second, 0 for step by step. (press 'Space' to go one step further)
            frameRate: 5
        )
        R = {LethOzLib.play Dossier#'/'#Options.scenario Next DecodeStrategy Options}
    in
        {Browse R}
    end
end
