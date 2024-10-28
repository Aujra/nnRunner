local profile = {}
profile["Name"] = "Cinderbrew Meadery"
profile["Description"] = "Profile for Cinderbrew Meadery"
profile["Steps"] = {
    {
        ["Name"] = "Move to main room",
        ["Task"] = "move_to",
        ["MobAlive"] = "Brew Master Aldryr",
        ["Locations"] = {
            {
                ["X"] = 2650.897705,
                ["Y"] = -4878.177246,
                ["Z"] = 99.709610,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing left side of main room",
        ["Task"] = "move_to",
        ["MobAlive"] = "Brew Master Aldryr",
        ["Locations"] = {
            {
                ["X"] = 2682.002197,
                ["Y"] = -4897.634766,
                ["Z"] = 99.709610,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing right side of main room",
        ["Task"] = "move_to",
        ["MobAlive"] = "Brew Master Aldryr",
        ["Locations"] = {
            {
                ["X"] = 2621.745117,
                ["Y"] = -4901.299316,
                ["Z"] = 99.709259,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Kill the first boss",
        ["Task"] = "kill",
        ["Mobs"] = {
            "Brew Master Aldryr"
        },
        ["Mechanics"] = {
            {
                ["Name"] = "Grab the mug",
                ["Condition"] = {
                    ["Type"] = "casting",
                    ["Mob"] = "Brew Master Aldryr",
                    ["SpellName"] = "Happy Hour",
                    ["NoAuraPlayer"] = "Carrying Cinderbrew"
                },
                ["Task"] = "interact_without_aura",
                ["Object"] = "Mug of Cinderbrew",
            },
            {
                ["Name"] = "Give mug to angry bitch",
                ["Condition"] = {
                    ["Type"] = "casting",
                    ["Mob"] = "Brew Master Aldryr",
                    ["SpellName"] = "Happy Hour",
                    ["PlayerAura"] = "Carrying Cinderbrew"
                },
                ["Task"] = "move_to_with_aura",
                ["Mob"] = "Thirsty Patron",
                ["Aura"] = "Rowdy Yell",
                ["Player_Aura"] = "Carrying Cinderbrew"
            }
        }
    },
    {
        ["Name"] = "Move to left room door",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2687.399902,
                ["Y"] = -4928.763672,
                ["Z"] = 99.709419,
                ["Radius"] = 3
            }
        },
    },
    {
        ["Name"] = "Move to left room hallway",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2719.337158,
                ["Y"] = -4928.008789,
                ["Z"] = 99.703087,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Continue down hallway",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2718.667480,
                ["Y"] = -4889.416504,
                ["Z"] = 102.840622,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Continue down hallway",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2808.717773,
                ["Y"] = -4887.342773,
                ["Z"] = 102.840637,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Continue down hallway",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2807.699463,
                ["Y"] = -4977.304199,
                ["Z"] = 99.703430,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Heading into brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2780.289795,
                ["Y"] = -4977.255859,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing the brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2748.026123,
                ["Y"] = -4991.331055,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing the brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2721.672852,
                ["Y"] = -4987.727539,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing the brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2718.986328,
                ["Y"] = -4960.686035,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Clearing the brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2749.557129,
                ["Y"] = -4965.956543,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Finishing clearing the brewing room",
        ["Task"] = "move_to",
        ["MobAlive"] = "I'pa",
        ["Locations"] = {
            {
                ["X"] = 2761.145752,
                ["Y"] = -4935.989258,
                ["Z"] = 99.718224,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Kill the second boss",
        ["Task"] = "kill",
        ["Mobs"] = {
            "I'pa"
        },
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2759.038086,
                ["Y"] = -4977.250977,
                ["Z"] = 99.717522,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2702.961426,
                ["Y"] = -4963.194336,
                ["Z"] = 99.717522,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2624.5598144531, ["Y"] = -4926.0922851562, ["Z"] = 99.709114074707,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2608.0505371094, ["Y"] = -4925.2431640625, ["Z"] = 99.709114074707,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2589.8781738281, ["Y"] = -4924.8115234375, ["Z"] = 99.704879760742,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2512.6813964844, ["Y"] = -4925.4033203125, ["Z"] = 99.704879760742,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2514.1252441406, ["Y"] = -4996.5283203125, ["Z"] = 99.704879760742,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2513.802734375, ["Y"] = -5021.40234375, ["Z"] = 100.05768585205,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2519.7583007812, ["Y"] = -5052.92578125, ["Z"] = 100.05768585205,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2515.7846679688, ["Y"] = -5049.8598632812, ["Z"] = 100.05950164795,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2515.7846679688, ["Y"] = -5049.8598632812, ["Z"] = 100.05950164795,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2565.7294921875, ["Y"] = -5047.4663085938, ["Z"] = 96.918098449707,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to third boss area",
        ["Task"] = "move_to",
        ["MobAlive"] = "Benk Buzzbee",
        ["Locations"] = {
            {
                ["X"] = 2565.7294921875, ["Y"] = -5047.4663085938, ["Z"] = 96.918098449707,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Kill the third boss",
        ["Task"] = "kill",
        ["Mobs"] = {
            "Benk Buzzbee"
        },
    },
    {
        ["Name"] = "Moving to bee transports",
        ["Task"] = "move_to",
        ["MobAlive"] = "Bee Line",
        ["Locations"] = {
            {
                ["X"] = 2564.853515625, ["Y"] = -5017.0405273438, ["Z"] = 97.017120361328,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to bee transports",
        ["Task"] = "move_to",
        ["MobAlive"] = "Bee Line",
        ["Locations"] = {
            {
                ["X"] = 2593.6574707031, ["Y"] = -4965.2548828125, ["Z"] = 99.50609588623,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Moving to bee transports",
        ["Task"] = "move_to",
        ["MobAlive"] = "Bee Line",
        ["Locations"] = {
            {
                ["X"] = 2618.1909179688, ["Y"] = -4947.2602539062, ["Z"] = 99.709449768066,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Taking the bee up",
        ["Task"] = "interact_with",
        ["Object"] = "Bee Line",
        ["Range"] = 4
    },
    {
        ["Name"] = "Moving to final boss",
        ["Task"] = "move_to",
        ["MobAlive"] = "Goldie Baronbottom",
        ["Locations"] = {
            {
                ["X"] = 2650.1989746094, ["Y"] = -5000.4555664062, ["Z"] = 110.29638671875,
                ["Radius"] = 3
            }
        }
    },
    {
        ["Name"] = "Kill the third boss",
        ["Task"] = "kill",
        ["Mobs"] = {
            "Goldie Baronbottom"
        },
    },
}

registerProfile(profile)