local profile = {}
profile["Name"] = "Onyxia's Lair"
profile["Description"] = "Profile for Onyxia Mount Farm"
profile["LootBossOnly"] = true
profile["Steps"] = {
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = 29.512203216553, ["Y"] = -69.60375213623, ["Z"] = -7.2150392532349, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = 24.132915496826, ["Y"] = -82.399353027344, ["Z"] = -14.505576133728, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = 17.604047775269, ["Y"] = -82.667137145996, ["Z"] = -12.297238349915, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = 4.0402054786682, ["Y"] = -75.382034301758, ["Z"] = -26.950841903687, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -32.559143066406, ["Y"] = -98.412551879883, ["Z"] = -36.147987365723, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -68.960578918457, ["Y"] = -99.010620117188, ["Z"] = -37.148174285889, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -91.476997375488, ["Y"] = -105.93446350098, ["Z"] = -38.28825378418, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -125.90441894531, ["Y"] = -133.8645324707, ["Z"] = -51.429893493652, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -149.57737731934, ["Y"] = -152.34674072266, ["Z"] = -53.425098419189, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -169.77520751953, ["Y"] = -177.59271240234, ["Z"] = -64.176826477051, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -156.53910827637, ["Y"] = -210.45932006836, ["Z"] = -66.48713684082, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -130.6886138916, ["Y"] = -214.33386230469, ["Z"] = -70.881126403809, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -88.367179870605, ["Y"] = -214.73304748535, ["Z"] = -82.468719482422, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -68.580619812012, ["Y"] = -215.09127807617, ["Z"] = -84.042587280273, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -48.753005981445, ["Y"] = -214.72193908691, ["Z"] = -86.118438720703, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -20.52770614624, ["Y"] = -215.41455078125, ["Z"] = -88.988426208496, ["Radius"] = 3, }}
    }, 
    
    { ["Name"] = "Move to Onyxia's Room",
    ["Task"] = "move_to",
    ["Locations"] = {{["X"] = -9.3317756652832, ["Y"] = -215.68927001953, ["Z"] = -87.550018310547, ["Radius"] = 3, }}
    },    
    {
        ["Name"] = "Kill Onyxia",
        ["Task"] = "kill",
        ["Mobs"] = {
            "Onyxia"
        },
    },
}

registerProfile(profile)
