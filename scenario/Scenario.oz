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
                    strategy: [repeat([forward] times:6) turn(right) repeat([forward] times:4) turn(right) repeat([forward] times:4) repeat([turn(left)] times:2) repeat([forward] times:4)]
                    seismicCharge: NoBomb)
            ]
        bonuses: nil
        bombs: nil
    )
end
