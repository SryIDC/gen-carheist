config = {}

config.boss = {
    model = "a_m_m_og_boss_01", -- Boss model
    cooldown = 120, -- in seconds
    blip = false, -- to show boss location in map or not
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
    reason = "Illegal Car Delivery" -- Bank statement reason idk
}

config.Rewards = {
    [0] = 1000, -- Compact
    [1] = 2000, -- Sedan
    [2] = 3000, -- SUV
    [3] = 4000, -- Coupe
    [4] = 5000, -- Muscle
    [5] = 6000, -- Sport
    [6] = 7000, -- Sport Classic
    [7] = 8000, -- SUV
    [8] = 9000, -- Off-road
    [9] = 10000, -- Industrial
    [10] = 11000, -- Utility
    [11] = 12000, -- Van
    [12] = 13000, -- BMX
    [13] = 14000, -- Boat
    [14] = 15000, -- Helicopter
    [15] = 16000, -- Plane
    [16] = 17000, -- Service
    [17] = 18000, -- Emergency
    [18] = 19000, -- Military
    [19] = 20000, -- Commercial
}
