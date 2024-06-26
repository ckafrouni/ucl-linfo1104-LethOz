local
    NoBomb=false|NoBomb
in
    scenario(
        bombLatency:3
        walls:false
        step: 0
        spaceships: [
                spaceship(team:red name:gordon
                    positions: [pos(x:6 y:6 to:east) pos(x:5 y:6 to:east) pos(x:4 y:6 to:east)]
                    effects: nil
                    % strategy: [repeat([forward] times:6) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) repeat([forward] times:12) turn(left) repeat([forward] times:2) turn(right) repeat([forward] times:2) turn(left) repeat([forward] times:12)]
                    strategy: keyboard(left:'Left' right:'Right' intro:[repeat([forward] times:6) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) repeat([forward] times:12) turn(left) repeat([forward] times:2) turn(right) repeat([forward] times:2) turn(left) repeat([forward] times:5) turn(left) repeat([forward] times:6) turn(left) repeat([forward] times:5) turn(right) repeat([forward] times:2) turn(left) repeat([forward] times:15) turn(left) repeat([forward] times:2) turn(right) turn(left) turn(right) turn(right) turn(left)])
                    % seismicCharge: NoBomb)
                    seismicCharge: false|false|true|false|false|false|true|false|false|false|true|NoBomb)

                spaceship(team:blue name:chris
                    positions: [pos(x:18 y:15 to:west) pos(x:19 y:15 to:west) pos(x:19 y:15 to:west)]
                    effects: nil
                    % strategy: [repeat([forward] times:6) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) repeat([forward] times:4)]
                    strategy: keyboard(left:'d' right:'f' intro:[repeat([forward] times:5) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) turn(right) repeat([forward] times:13) repeat([turn(left)] times:2) repeat([turn(right)] times:2) turn(left) turn(right) repeat([repeat([turn(left) forward] times:2) repeat([turn(right) forward] times:2)] times:2) forward turn(left) turn(left) forward turn(right) repeat([forward] times:12) turn(right) repeat([forward] times:15) turn(left) repeat([forward] times:4) turn(left) forward turn(right) repeat([forward] times:15)  turn(left) forward turn(right) turn(left) forward turn(right) turn(left) forward turn(right)])
                    seismicCharge: false|false|false|true|false|false|false|true|NoBomb)
            ]
        bonuses: [
            bonus(position:pos(x:23 y:3) color:red  effect:revert target:catcher)

            bonus(position:pos(x:12 y:12) color:orange  effect:scrap target:catcher)
            bonus(position:pos(x:20 y:12) color:orange  effect:scrap target:catcher)
            bonus(position:pos(x:5 y:8) color:orange  effect:scrap target:catcher)

            % Mega scrap (this is a bonus that gives 3 scrap)
            bonus(position:pos(x:17 y:8) color:green  effect:scrap target:catcher)
            bonus(position:pos(x:17 y:8) color:green  effect:scrap target:catcher)
            bonus(position:pos(x:17 y:8) color:green  effect:scrap target:catcher)

		    bonus(position:pos(x:6 y:3)   color:yellow effect:wormhole(x:12 y:17) target:catcher)
		    bonus(position:pos(x:12 y:17) color:yellow effect:wormhole(x:6 y:3) target:catcher)

            bonus(position:pos(x:12 y:3) color:'#808000' effect:malware(6) target:opponents)

            bonus(position:pos(x:2 y:19) color:pink  effect:shrink(2) target:catcher)

            bonus(position:pos(x:16 y:3) color:purple  effect:dropSeismicCharge(true|true|nil) target:catcher)
            % Unused colors: blue, pink, brown
        ]
        % bombs: [
		%     bomb(position:pos(x:15 y:12) explodesIn:3)
		%     bomb(position:pos(x:9 y:8) explodesIn:6)
		% ]
        bombs: nil
    )
end
