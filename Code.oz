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

<strategy> ::=
    <instruction> '|' <strategy>
    | repeat(<strategy> times:<integer>) '|' <strategy>
    | nil

*/

local
    % Please replace this path with your own working directory that contains LethOzLib.ozf
    Dossier = {Property.condGet cwdir '.'}
    % Dossier = {Property.condGet cwdir '/home/nicolas/Progr/Projet OZ/ucl-linfo1104-LethOz'}
    % Dossier = {Property.condGet cwdir 'C:\\Users\Thomas\Documents\UCL\Oz\Projet'} % Windows example.
    LethOzLib

    % The two function you have to implement
    Next
    DecodeStrategy

    % Width and height of the grid
    % (1 <= x <= W=24, 1 <= y <= H=24)
    % TODO (chris) : use these values.
    W = 24
    H = 24
in
    % Please do NOT change this line.
    [LethOzLib] = {Link [Dossier#'/'#'LethOzLib.ozf']}
    {Browse LethOzLib.play}

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Our code starts here  %
    % ↓    ↓    ↓    ↓    ↓ %

    local
        % Namespaces
        Utils Instructions Effects
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
             * Next position (moves back to the other side if out of bounds)
             * @arg Pos : <pos>
             * @arg Dir : <direction>
             * @ret : <pos>
             */
            fun {NextPos Pos Dir}
                case Pos.to
                of north then
                    if Pos.y == 1 then pos(x:Pos.x y:H to:Dir)
                    else pos(x:Pos.x y:(Pos.y-1) to:Dir) end
                [] south then 
                    if (Pos.y) == H then pos(x:Pos.x y:1 to:Dir)
                    else pos(x:Pos.x y:(Pos.y+1) to:Dir) end
                [] west then 
                    if Pos.x == 1 then pos(x:W y:Pos.y to:Dir)
                    else pos(x:(Pos.x-1) y:Pos.y to:Dir) end
                [] east then 
                    if Pos.x == W then pos(x:1 y:Pos.y to:Dir)
                    else pos(x:(Pos.x+1) y:Pos.y to:Dir) end
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
                prevPos: PrevPos)
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
                    if PrevPos == nil then
                        {Utils.nextPos Pos To}
                    else
                        PrevPos
                    end
                end
            in
                % The 'wormhole' effect is handled here.
                case Spaceship.effects
                of wormhole(x:X y:Y)|_ then
                    spaceship(
                        positions: {Utils.mapS Spaceship.positions Advance {Utils.nextPos pos(x:X y:Y to:(Spaceship.positions.1).to) (Spaceship.positions.1).to}}
                        effects: nil)
                else
                    spaceship(
                        positions: {Utils.mapS Spaceship.positions Advance nil}
                        effects: Spaceship.effects)
                end
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
                    effects: Spaceship.effects)
            end
        in
            instructions(
                forward: Forward
                turnLeft: fun {$ Spaceship} {Instructions.forward {Turn Spaceship left}} end
                turnRight: fun {$ Spaceship} {Instructions.forward {Turn Spaceship right}} end)
        end


        /*----------------------*
         * NAMESPACE 'Effects'  *
         *----------------------*/
        Effects = local
            /**
             * Scrap effect -> increases the spaceship's length by 1
             * @arg Spaceship : <spaceship>
             * @ret : <spaceship>
             */
            fun {Scrap Spaceship}
                Last = {List.last Spaceship.positions}
            in
                spaceship(
                    positions: {List.append Spaceship.positions [{Utils.prevPos Last Last.to}]}
                    effects: nil)
            end

            /**
             * Revert effect -> places the head of the spaceship at his tail
             * @arg Spaceship : <spaceship>
             * @ret : <spaceship>
             */
            fun {Revert Spaceship}
                fun {Aux PrevPos Pos}
                    To = if PrevPos == nil then Pos.to else PrevPos.to end
                in pos(x:Pos.x y:Pos.y to:{Utils.dirAfterTurn revert To}) end
            in
                spaceship(
                    positions: {Utils.mapS {List.reverse Spaceship.positions} Aux nil}
                    effects: nil)
            end

            /**
             * Malware effect -> inverts the left and right command for every spaceship excepts the catcher's for N turns
             * @arg Spaceship : <spaceship>
             * @arg N : <integer>
             * @ret : <spaceship>
             */
            fun {Malware Spaceship N} 
                if N == 0 then
                    {Record.subtract 
                        {Record.adjoinAt Spaceship 
                            effects {List.filter Spaceship.effects fun {$ E} E \= malware(0) end}}
                        flipTurns}
                else 
                    {Record.adjoinAt 
                        {Record.adjoinAt
                            Spaceship
                            effects malware(N-1)|{List.filter Spaceship.effects fun {$ E} E \= malware(N) end}}
                        flipTurns true}
                end
            end

            /**
             * Shrink effect -> shrinks the spaceship's length by N
             * @arg Spaceship : <spaceship>
             * @arg N : <integer>
             * @ret : <spaceship>
             */
            fun {Shrink Spaceship N}
                spaceship(
                    positions: {List.take Spaceship.positions {List.length Spaceship.positions}-N}
                    effects: nil)
            end

        in
            effects(
                scrap: Scrap
                revert: Revert
                malware: Malware
                shrink: Shrink)
        end


        /**
         * The function that computes the next attributes of the spaceship given the effects
         * affecting him as well as the instruction.
         * @arg Spaceship : <spaceship>
         * @arg Instruction : <instruction>
         * @ret : <spaceship>
         */
        fun {Next Spaceship Instruction}
            /**
             * Applies the effects to the spaceship.
             * @arg Spaceship : <spaceship>
             * @ret : <spaceship>
             */
            fun {ApplyEffects Spaceship}
                fun {ApplyEffect Spaceship Effect}
                    case Effect
                    of scrap then {Effects.scrap Spaceship}
                    [] revert then {Effects.revert Spaceship}
                    [] wormhole(x:_ y:_) then Spaceship % Skipped as it is handled in Instructions.forward
                    [] malware(N) then {Effects.malware Spaceship N}
                    [] shrink(N) then {Effects.shrink Spaceship N}
                    else raise unsupportedEffect(Effect) end
                    end
                end
            in {List.foldL Spaceship.effects ApplyEffect Spaceship} end

            /**
             * Applies the instruction to the spaceship.
             * @arg Spaceship : <spaceship>
             * @arg Instruction : <instruction>
             * @ret : <spaceship>
             */
            fun {ApplyInstruction Spaceship Instruction}
                case Instruction
                of forward then {Instructions.forward Spaceship}
                [] turn(left) then 
                    if {Value.hasFeature Spaceship 'flipTurns'} then {Instructions.turnRight Spaceship}
                    else {Instructions.turnLeft Spaceship} end
                [] turn(right) then 
                    if {Value.hasFeature Spaceship 'flipTurns'} then {Instructions.turnLeft Spaceship}
                    else {Instructions.turnRight Spaceship} end
                else raise unsupportedInstruction(Instruction) end
                end
            end
        in
            {Browse Instruction#Spaceship.effects} % {Browse Spaceship}
            local S1 in
                % 1. apply effects
                S1 = {ApplyEffects Spaceship}
                % 2. apply instruction
                {ApplyInstruction S1 Instruction}
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
        in {List.flatten {List.map Strategy InstToFunc}} end
    end

    % ↑    ↑    ↑    ↑    ↑ %
    %  Our code ends here   %
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
            frameRate: 2
        )
        R = {LethOzLib.play Dossier#'/'#Options.scenario Next DecodeStrategy Options}
    in
        {Browse R}
    end
end
