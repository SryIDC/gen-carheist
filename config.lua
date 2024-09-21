config = {}

config.NotificationType = "ox_lib" -- ox_lib or qbx_core

config.boss = {
    model = "a_m_m_og_boss_01", -- Boss model
    cooldown = 120, -- in seconds
    owned_cars = false, --Can deliver player owned vehicles?
    blip = {
        enable = true,
        text = "Illegal Car text",
        color = 1,
        sprite = 229,
        scale = 1.0,
    }, -- to show boss location in map or not
    coords = {x= 495.6126, y=-1340.8628, z=29.3121, h = 4.3495},
    drop = {x=406.3838, y=2596.4126, z=43.5194, h=12.3785}
}

config.dropCoords = { -- Vehicle delivery locations
    {x=405.1283, y=2595.9546, z=43.5195, h=15.3136},
    {x=-363.1792, y=6332.0112, z=29.8521, h=224.3867},
    {x=3601.4712, y=3758.7390, z=29.9225, h=74.4548}
}

config.Vehicles = { -- List of vehicles only in uppercase
    "ZENTORNO",
    "T20",
    "GAUNTLET",
    "BALLER",
    "SULTAN",
    "SULTANRS",
    "ADDER",
    "TENF"
}

config.Reward = {
    account = "cash", --bank, cash, crypto,
    reason = "Illegal Car Delivery", -- Bank statement reason idk
    amount = math.random(8000, 12000),
}
