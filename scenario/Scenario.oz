local
    NoBomb=false|NoBomb
in
    scenario(
        bombLatency:3
        walls:true
        step: 0
        spaceships: [
                spaceship(team:red name:gordon
                    positions: [pos(x:6 y:6 to:east) pos(x:5 y:6 to:east) pos(x:4 y:6 to:east) pos(x:3 y:6 to:east)
                                pos(x:3 y:7 to:north) pos(x:3 y:8 to:north) pos(x:3 y:9 to:north)
                                pos(x:4 y:9 to:west) pos(x:5 y:9 to:west) pos(x:6 y:9 to:west)]
                    effects: nil
                    % strategy: [repeat([forward] times:6) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) repeat([forward] times:4)]
                    strategy: keyboard(left:'Left' right:'Right' intro:nil)
                    seismicCharge: NoBomb)
            ]
        bonuses: [
            bonus(position:pos(x:23 y:3) color:red  effect:revert target:catcher)
            bonus(position:pos(x:2 y:12) color:red  effect:revert target:catcher)

            bonus(position:pos(x:12 y:12) color:orange  effect:scrap target:catcher)
            bonus(position:pos(x:20 y:12) color:orange  effect:scrap target:catcher)
            bonus(position:pos(x:5 y:8) color:orange  effect:scrap target:catcher)

		    bonus(position:pos(x:6 y:3)   color:yellow effect:wormhole(x:12 y:17) target:catcher)
		    bonus(position:pos(x:12 y:17) color:yellow effect:wormhole(x:6 y:3) target:catcher)
        ]
        bombs: nil
    )
end
