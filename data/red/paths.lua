local Paths = {

	-- Red's room
	{38, {3,6}, {5,6}, {5,1}, {7,1}},
	-- Red's house
	{39, {7,1}, {7,6}, {3,6}, {3,8}},
	-- Into the Wild
	{0, {5,6}, {10,6}, {10,1}},
	-- Choose your character!
	{40, {5,3}, {c="a",a="Pallet Rival"}, {5,4}, {7,4}, {s="squirtleIChooseYou"}, {5,4}, {5,6}, {s="fightBulbasaur"}, {s="split"}, {5,12}},

-- 1: RIVAL 1

	-- Let's try this escape again
	{0, {12,12}, {c="a",a="Pallet Town"}, {c="viridianExp"}, {c="encounters",limit=3}, {c="trackEncounters",area="route1"}, {9,12}, {9,2}, {10,2}, {10,-1}},
	-- First encounters
	{12, {10,35}, {10,30}, {8,30}, {8,24}, {12,24}, {12,20}, {9,20}, {9,14}, {14,14}, {s="dodgePalletBoy"}, {14,2}, {10,2}, {10,-1}},
	-- To the Mart
	{1, {20,35}, {20,28}, {19,28}, {19,20}, {29,20}, {29,19}},
	-- Viridian Mart
	{42, {2,5}, {3,5}, {3,8}},
	-- Backtracking
	{1, {29,20}, {c="encounters",limit=4}, {29,21}, {26,21}, {26,30}, {20,30}, {20,36}},
	-- Parkour
	{12, {10, 0}, {10,3}, {8,3}, {8,18}, {9,18}, {9,21}, {12,21}, {12,24}, {10,24}, {10,36}},
	-- To Oak's lab
	{0, {10,0}, {10,7}, {9,7}, {9,12}, {12,12}, {12,11}},
	-- Parcel delivery
	{40, {5,11}, {5,3}, {4,3}, {4,1}, {5,1}, {s="talk",dir="Down"}, {4,1}, {4,12}},
	-- Leaving home
	{0, {12,12}, {c="viridianBackupExp"}, {c="encounters",limit=5}, {9,12}, {9,2}, {10,2}, {10,-1}},
	-- The grass again!?
	{12, {10,35}, {10,30}, {8,30}, {8,24}, {12,24}, {12,20}, {9,20}, {9,14}, {14,14}, {s="dodgePalletBoy"}, {14,2}, {10,2}, {10,-1}},
	-- Back to the Mart
	{1, {20,35}, {20,28}, {19,28}, {19,20}, {29,20}, {29,19}},
	-- Viridian Mart redux
	{42, {3,7}, {3,5}, {2,5}, {s="shopViridianPokeballs"}, {3,5}, {3,8}},
	-- Sidequest
	{1, {29,20}, {c="trackEncounters",area="nidoran"}, {15,20}, {15,17}, {-1, 17}},
	-- Nidoran
	{33, {39, 9}, {c="a",a="Nidoran grass"}, {c="nidoranBackupExp"}, {c="encounters",limit=7,extra="spearow"}, {35, 9}, {35,12}, {33,12}, {c="catchNidoran"}, {s="catchNidoran"}, {33,12}, {s="split"}, {37,12}, {37,9}, {40,9}},

-- 2: NIDORAN

	-- Out of Viridian City
	{1, {0,17}, {c="a",a="Tree Potion"}, {c="encounters",limit=8,extra="spearow"}, {16,17}, {16,16}, {18,16}, {18,6}, {s="dodgeViridianOldMan"}, {17,4}, {s="grabTreePotion"}, {17,4}, {17, 0}, {17, -1}},
	-- To the Forest
	{13, {7,71}, {7,57}, {4,57}, {4,52}, {10,52}, {10,44}, {3,44}, {3,43}},
	-- Forest entrance
	{50, {4,7}, {c="a",a="Viridian Forest"}, {c="trackEncounters",area="forest"}, {4,1}, {5,1}, {5,0}},
	-- Viridian Forest
	{51, {17,47}, {17,43}, {26,43}, {26,34}, {25,34}, {25,32}, {27,32}, {27,20}, {25,20}, {25,12}, {s="grabAntidote"}, {25,9}, {17,9}, {17,16}, {13,16}, {13,3}, {7,3}, {7,22}, {1,22}, {1,19}, {s="grabForestPotion"}, {1,18}, {s="fightWeedle"}, {c="encounters",limit=nil}, {1,16}, {c="potion",b=false}, {s="equipForBrock",anti=true}, {1,5}, {s="equipForBrock"}, {1,-1}},
	-- Forest exit
	{47, {4,7}, {s="exitForest"}, {4,1}, {5,1}, {5,0}},
	-- Road to Pewter City
	{13, {3,11}, {c="a",a="Pewter City"}, {3,8}, {8,8}, {8,-1}},
	-- Pewter City
	{2, {18,35}, {18,22}, {19,22}, {19,13}, {10,13}, {10,18}, {16,18}, {16,17}},
	-- Brock
	{54, {4,13}, {c="a",a="Brock's Gym"}, {4,8}, {1,8}, {1,4}, {4,4}, {4,2}, {s="talk",dir="Up"}, {s="fightBrock"}, {s="splitBrock"}, {s="changeSpeed", speed=AFTER_BROCK_SPEED, extra="We have a run going"}, {4,14}},

-- 3: BROCK

	-- To Pewter Mart
	{2, {16,18}, {c="potion",b=true}, {10,18}, {10,13}, {21,13}, {21,18}, {23,18}, {23,17}},
	-- Pewter Mart
	{56, {3,7}, {3,5}, {2,5}, {s="shopPewterMart"}, {2,6}, {3,6}, {3,8}},
	-- Leaving Pewter City
	{2, {23,18}, {40,18}},
	-- Route 3
	{14, {0,10}, {c="a",a="Route 3"}, {c="catchFlier"}, {c="pp",on=true}, {c="trackEncounters",area="route3"}, {s="battleModeSet"}, {8,10}, {8,8}, {11,8}, {11,6}, {s="bugCatcher"}, {11,4}, {12,4}, {c="a",a="Shorts Kid"}, {s="potionBeforeShorts"}, {13,4}, {s="talk",dir="Right"}, {s="shortsKid"}, {s="tweetBrock"}, {13,5}, {c="a",a="Route 3"}, {s="potionBeforeCocoons"}, {18,5}, {s="talk",dir="Right"}, {s="swapMove",move="horn_attack",to=0}, {18,6}, {22,6}, {22,5}, {23,5}, {s="potion",hp=4}, {24,5}, {s="talk",dir="Down"}, {s="fightMetapod"}, {27,5}, {27,9}, {s="catchFlierBackup"}, {37,8}, {37,5}, {49,5}, {49,10}, {57,10}, {57,8}, {59,8}, {59,-1}},
	-- To the Center
	{15, {9,16}, {c="pp",on=false}, {12,16}, {12,6}, {11,6}, {11,5}},
	-- PP up
	{68, {3,7}, {3,3}, {s="dialogue",dir="Up"}, {3,8}},
	-- Enter Mt. Moon
	{15, {11,6}, {18,6}, {s="split"}, {18,5}},

-- 4: ROUTE 3

	-- Mt. Moon F1
	{59, {14,35}, {c="a",a="Mt. Moon"}, {c="trackEncounters",area="moon"}, {c="startMtMoon"}, {c="catchParas"}, {14,22}, {21,22}, {21,15}, {24,15}, {24,27}, {25,27}, {25,31}, {s="talk",dir="Left"}, {25,32}, {33,32}, {33,31}, {34,31}, {s="take",dir="Right"}, {35,31}, {35,23}, {s="take",dir="Right"}, {35,7}, {30,7}, {s="evolveNidorino"}, {c="moon1Exp"}, {28,7}, {16,7}, {16,17}, {2,17}, {2,3}, {s="take",dir="Up"}, {5,3}, {5,5}},
	-- Mt. Moon B2
	{60, {5,5}, {5,17}, {21,17}},
	-- Mt. Moon B3
	{61, {21,17}, {22,17}, {s="evolveNidoking",early=true,poke="paras"}, {23,17}, {23,14}, {27,14}, {27,16}, {33,16}, {33,14}, {36,14}, {36,24}, {32, 24}, {32,31}, {10,31}, {10,18}, {s="potion",hp=11,yolo=6,chain=true}, {s="evolveNidoking"}, {10,17}, {12,17}, {c="moon2Exp"}, {12,9}, {s="potion",hp=7}, {s="talk",dir="Up"}, {s="fightGrimer"}, {13,9}, {c="moon3Exp"}, {13,7}, {s="dialogue",dir="Up"}, {13,5}, {12,5}, {12,4}, {3,4}, {3,7}, {5,7}},
	-- Mt. Moon escape
	{60, {23,3}, {27,3}},

-- 5: MT. MOON

	-- To Cerulean
	{15, {24,6}, {s="reportMtMoon"}, {s="split"}, {s="changeSpeed", speed=AFTER_MOON_SPEED, extra="Things are getting serious"}, {c="trackEncounters",area=nil}, {24,8}, {35,8}, {35,10}, {61,10}, {61,8}, {79,8}, {79,10}, {90,10}},
	-- Enter Cerulean
	{3, {0,18}, {c="a",a="Cerulean"}, {14,18}, {s="dodgeCerulean"}, {19,18}, {19,17}},
	-- Cerulean Center
	{64, {3,7}, {3,3}, {s="dialogue",dir="Up"}, {3,8}},
	-- To the house
	{3, {19,18}, {16,18}, {s="dodgeCerulean",left=true}, {8,16}, {8,12}, {9,12}, {9,11}},
	-- In the house
	{230, {2,7}, {2,0}},
	-- Outback
	{3, {9,9}, {9,8}, {14,8}, {s="take",dir="Right"}, {9,8}, {9,10}},
	-- Out the house
	{230, {2,1}, {2,8}},
	-- Rival 2
	{3, {9,12}, {c="a",a="Cerulean Rival"}, {21,12}, {21,6}, {s="rivalSandAttack"}, {21,-1}},
	-- Nugget bridge
	{35, {11,35}, {c="a",a="Nugget Bridge"}, {11,32}, {s="talk",dir="Up"}, {s="hornAttackCaterpie"}, {10,32}, {10,29}, {s="potion",hp=12,yolo=10}, {s="talk",dir="Up"}, {11,29}, {11,27}, {s="rareCandyEarly",chain=true}, {s="potion",hp=10,yolo=8}, {11,26}, {s="talk",dir="Up"}, {s="swapThrash"}, {10,26}, {10,24}, {s="teachThrash",chain=true}, {s="potion",hp=4}, {10,23}, {s="talk",dir="Up"}, {s="swapThrash"}, {11,23}, {11,21}, {s="teachThrash",chain=true}, {s="potionForMankey"}, {11,20}, {s="talk",dir="Up"}, {s="swapThrash"}, {s="redbarMankey"}, {10,20}, {10,19}, {s="teachThrash"}, {10,15}, {s="learnThrash"}, {s="swapThrash"}, {s="waitToFight"}, {s="teachThrash"}, {s="split"}, {10,8}, {20,8}},

-- 6: NUGGET BRIDGE

	-- To Bill's
	{36, {0,8}, {9,8}, {9,6}, {9,6}, {8,6}, {8,5}, {s="talk",dir="Up"}, {s="thrashGeodude"}, {10,5}, {s="hikerElixer"}, {10,4}, {13,4}, {13,6}, {15,6}, {15,4}, {17,4}, {17,7}, {18,7}, {s="talk",dir="Down"}, {20,7}, {20,8}, {22,8}, {22,6}, {23,6}, {s="potion",hp=5,yolo=0}, {35,6}, {35,4}, {36,4}, {s="talk",dir="Right"}, {36,5}, {38,5}, {38,4}, {s="lassEther"}, {45,4}, {45,3}},
	-- Save Bill
	{88, {2,7}, {2,5}, {5,5}, {s="dialogue",dir="Right"}, {1,5}, {s="interact",dir="Up"}, {4,5}, {s="talkToBill"}, {s="waitToTalk"}, {s="potionBeforeMisty",goldeen=true,chain=true}, {s="item",item="escape_rope"}},
	-- To Misty
	{3, {19,18}, {19,20}, {30,20}, {30,19}},
	-- Misty
	{65, {4,13}, {c="a",a="Misty's Gym"}, {c="potion",b=false}, {4,8}, {2,8}, {2,5}, {7,5}, {7,3}, {6,3}, {5,3}, {s="waitToFight"}, {s="potionBeforeMisty"}, {5,2}, {s="talk",dir="Left"}, {s="fightMisty"}, {s="split"}, {s="tweetMisty"}, {5,3}, {7,3}, {7,5}, {5,5}, {5,14}},

-- 7: MISTY

	-- Past the policeman
	{3, {30,20}, {8,20}, {8,12}, {27,12}, {27,11}},
	-- Wrecked house
	{62, {2,7}, {2,2}, {3,2}, {3,0}},
	-- Cerulean Rocket
	{3, {27,9}, {28,9}, {s="potionBeforeRocket"}, {30,9}, {s="announceMachop"}, {33,9}, {33,18}, {36,18}, {36,31}, {25,31}, {25,36}},
	-- Out of Cerulean
	{16, {15,0}, {c="potion",b=true,yolo=true}, {15,28}, {17,28}, {17,27}},
	-- Underground entrance
	{71, {3,7}, {3,4}, {4,4}},
	-- Underground to Vermilion
	{119, {5,4}, {4,4}, {s="jingleSkip"}, {2,4}, {2,41}},
	-- Underground exit
	{74, {4,4}, {3,8}},
	-- Oddish
	{17, {17,14}, {c="a",a="Vermilion City"}, {c="catchOddish"}, {17,15}, {s="potion",hp=10,yolo=7}, {17,19}, {s="catchOddish"}, {11,29}, {s="potion",hp=10,yolo=7}, {11,29}, {s="waitToFight",dir="Down"}, {10,29}, {10,30}, {s="potionBeforeRaticate"}, {10,31}, {9,31}, {9,36}},
	-- Enter Vermilion
	{5, {19,0}, {c="disableCatch"}, {19,6}, {21,6}, {21,14}, {23,14}, {23,13}},
	-- Vermilion mart
	{91, {3,7}, {3,5}, {2,5}, {s="shopVermilionMart"}, {3,5}, {3,8}},
	-- To S.S. Anne
	{5, {23,14}, {30,14}, {30,26}, {18,26}, {18,31}},
	-- Mew
	{94, {14,0}, {c="a",a="S.S. Anne"}, {14,3}},
	-- First deck
	{95, {27,0}, {27,1}, {26,1}, {26,7}, {2,7}, {2,6}},
	-- Rival 3
	{96, {2,4}, {2,11}, {3,11}, {3,12}, {37,12}, {37,9}, {s="swap",item=2,dest="potion",chain=true}, {s="potion",hp=25,yolo=19,chain=true}, {s="teach",move="bubblebeam",replace="tackle"}, {37,8}, {s="rivalSandAttack"}, {36,8}, {36,4}},
	-- Old man Cut
	{101, {0,7}, {0,4}, {4,4}, {4,3}, {s="talk",dir="Up"}, {4,5}, {0,5}, {0,7}},
	-- Second deck out
	{96, {36,4}, {s="guess",game="trash",enabled=true}, {36,12}, {3,12}, {3,11}, {2,11}, {2,4}},
	-- First deck out
	{95, {2,6}, {2,7}, {26,7}, {26,-1}},
	-- Departure
	{94, {14,2}, {s="epicCutscene"}},
	-- To Surge
	{5, {18,29}, {18,26}, {30,26}, {30,14}, {15,14}, {15,17}, {s="potionBeforeSurge"}, {s="swap",item="repel",dest=0,chain=true}, {s="teach",move="cut",poke={"oddish","paras"},chain=true}, {s="teach",move="dig",poke={"paras","squirtle"},chain=true}, {s="skill",move="cut",done=0x0D4D}, {15,20}, {12,20}, {12,19}},
	-- Trashcans
	{92, {4,17}, {c="a",a="Surge's Gym"}, {4,16}, {2,16}, {2,11}, {s="guess",game="trash",enabled=false}, {s="trashcans"}, {4,6}, {4,3}, {5,3}, {5,2}, {s="talk",dir="Up"}, {s="fightSurge"}, {s="split"}, {s="tweetSurge"}, {4,2}, {4,13}, {5,13}, {5,18}},

-- 8: SURGE

	-- To bicycle house
	{5, {12,20}, {c="a",a="Bicycle Shop"}, {15,20}, {15,19}, {s="skill",move="cut",done=0x0D4D}, {15,14}, {9,14}, {9,13}},
	-- Bicycle cert
	{90, {2,7}, {2,5}, {0,5}, {0,1}, {2,1}, {s="dialogue",dir="Right"}, {s="skill",move="dig",map=90}},
	-- Cerulean warp
	{3, {19,18}, {19,23}, {16,23}, {16,26}, {13,26}, {13,25}},
	-- Bicycle shop
	{66, {2,7}, {2,3}, {4,3}, {4,2}, {s="procureBicycle"}, {4,7}, {3,7}, {3,8}},
	-- Bicycle out of Cerulean
	{3, {13,26}, {s="swap",item="bicycle",dest=1,chain=true}, {s="teach",move="thunderbolt",replace="horn_attack",chain=true}, {s="bicycle"}, {19,26}, {19,27}, {s="skill",move="cut",done=0x0D4D}, {19,29}, {36,29}, {36,16}, {40,16}},
	-- TPP's Bane
	{20, {0,8}, {c="a",a="Route 9"}, {4,8}, {s="skill",move="cut",done=0x0C17,val=2}, {13,8}, {13,9}, {s="talk",dir="Down"}, {s="fourTurnThrash"}, {12,9}, {12,12}, {23,12}, {23,11}, {29,11}, {29,12}, {41,12}, {41,10}, {40,10}, {40,9}, {s="talk",dir="Up"}, {s="announceVenonat"}, {41,9}, {41,6}, {39,6}, {39,4}, {45,4}, {45,3}, {51,3}, {51,8}, {60,8}},
	-- To the cave
	{21, {0,8}, {3,8}, {3,10}, {13,10}, {13,15}, {14,15}, {14,26}, {3,26}, {3,18}, {7,18}, {s="item",item="repel"}, {8,18}, {8,17}},
	-- Rock Tunnel
	{82, {15,3}, {c="a",a="Rock Tunnel"}, {c="potion",b=false}, {15,6}, {23,6}, {23,7}, {s="talk",dir="Down"}, {s="redbarCubone"}, {22,7}, {22,10}, {37,10}, {37,3}},
	-- B1
	{232, {33,25}, {33,30}, {27,30}, {s="talk",dir="Left"}, {27,31}, {14,31}, {14,29}, {s="potion",hp=6,yolo=0}, {s="talk",dir="Up"}, {s="announceOddish"}, {17,29}, {17,24}, {25,24}, {25,16}, {37,16}, {37,11}, {s="item",item="repel",chain=true}, {s="healParalysis"}, {37,3}, {27,3}},
	-- B2
	{82, {5,3}, {5,9}, {11,9}, {11,14}, {17,14}, {17,11}},
	-- B1
	{232, {23,11}, {14,11}, {14,17}, {8,17}, {8,10}, {7,10}, {s="talk",dir="Left"}, {7,11}, {5,11}, {s="item",item="repel"}, {5,3}, {3,3}},
	-- Out of the Tunnel
	{82, {37,17}, {32,17}, {32,23}, {37,23}, {37,28}, {28,28}, {26,24}, {23,24}, {s="talk",dir="Left"}, {23,27}, {15,27}, {15,33}},
	-- To Lavender Town
	{21, {8,54}, {c="a",a="Lavender Town"}, {15,54}, {15,65}, {11,65}, {11,69}, {6,69}, {6,72}},
	-- Through Lavender
	{4, {6,0}, {6,6}, {0,6}, {0,8}, {-1,8}},
	-- Leave Lavender
	{19, {59,8}, {52,8}, {52,13}, {47,13}, {s="talk",dir="Left"}, {47,14}, {42,14}, {42,7}, {40,7}, {40,6}, {29,6}, {29,7}, {23,7}, {23,12}, {14,12}, {14,4}, {13,4}, {13,3}},
	-- Underground entrance
	{80, {3,7}, {3,6}, {4,6}, {4,4}},
	-- Underground
	{121, {47,2}, {s="bicycle"}, {47,5}, {22,5}, {s="undergroundElixer"}, {2,5}},
	-- Underground exit
	{77, {4,4}, {4,8}},
	-- To Celadon
	{18, {5,14}, {s="bicycle"}, {8,14}, {8,8}, {4,8}, {4,3}, {-1,3}},
	-- Celadon
	{6, {49,11}, {c="a",a="Celadon Mart"}, {14,11}, {14,14}, {10,14}, {10,13}},
	-- F1: Department store
	{122, {16,7}, {c="potion",b=true,yolo=true}, {c="pp",on=true}, {16,3}, {12,3}, {12,1}},
	-- F2
	{123, {12,2}, {8,2}, {8,5}, {6,5}, {s="shopTM07"}, {5,5}, {s="shopRepels"}, {9,5}, {s="dodgeDepartment"}, {15,2}, {16,2}, {16,1}},
	-- F3
	{124, {16,2}, {12,2}, {12,1}},
	-- F4: Poke Doll
	{125, {12,2}, {10,2}, {10,5}, {5,5}, {s="shopPokeDoll"}, {11,5}, {11,2}, {16,2}, {16,1}},
	-- F5
	{136, {16,2}, {12,2}, {12,1}},
	-- Roof
	{126, {15,3}, {12,3}, {s="shopVending"}, {6,3}, {6,4}, {s="giveWater"}, {6,4}, {7,3}, {12,3}, {s="shopExtraWater"}, {15,3}, {15,2}},
	-- F5: Buffs
	{136, {12,2}, {8,2}, {8,5}, {5,5}, {s="shopBuffs"}, {1,5}, {1,1}},
	-- Elevator
	{127, {1,3}, {1,2}, {3,2}, {3,1}, {s="deptElevator"}, {2,1}, {2,4}},
	-- F1: Exit department store
	{122, {1,2}, {1,6}, {2,6}, {2,8}},
	-- Leave Celadon
	{6, {8,14}, {s="bicycle"}, {8,15}, {2,15}, {2,18}, {-1,18}},
	-- Cut out of Celadon
	{27, {39,10}, {34,10}, {s="skill",move="cut",dir="Up",done=0x0D4D}, {34,6}, {27,6}, {27,4}, {23,4}},
	-- Old man's hall
	{186, {7,2}, {-1,2}},
	-- To the Fly house
	{27, {17,4}, {c="a",a="HM02 Fly"}, {10,4}, {10,6}, {7,6}, {7,5}},
	-- Fly house
	{188, {2,7}, {2,4}, {s="talk",dir="Up"}, {2,5}, {s="split"}, {2,8}},

-- 9: FLY

	-- Fly to Lavender
	{27, {7,6}, {s="swap",item="super_repel",dest=1,chain=true}, {s="potion",hp=10,chain=true}, {s="teach",move="horn_drill",replace="bubblebeam",chain=true}, {s="item",item="super_repel",chain=true}, {s="swap",item="x_accuracy",dest=2,chain=true}, {s="teach",move="fly",poke={"spearow","pidgey"},chain=true}, {s="teach",move="rock_slide",replace="poison_sting",chain=true}, {s="fly",dest="lavender",map=4}},
	-- To the tower
	{4, {3,6}, {c="a",a="Pokemon Tower"}, {14,6}, {14,5}},
	-- Pokemon Tower
	{142, {10,17}, {10,10}, {18,10}, {18,9}},
	-- F2: Rival
	{143, {18,9}, {c="thrash",disable=true}, {18,7}, {16,7}, {16,5}, {15,5}, {s="lavenderRival"}, {5,5}, {5,8}, {3,8}, {3,9}},
	-- F3
	{144, {3,9}, {3,10}, {6,10}, {6,13}, {8,13}, {8,6}, {17,6}, {17,9}, {18,9}},
	-- F4
	{145, {18,9}, {c="allowDeath",on=true}, {c="potion",b=false}, {18,7}, {16,7}, {s="talk",dir="Left"}, {s="digFight"}, {16,9}, {c="potion",b=true,yolo=true}, {14,9}, {14,10}, {13,10}, {s="take",dir="Left"}, {14,10}, {14,8}, {11,8}, {11,9}, {10,9}, {10,12}, {7,12}, {7,11}, {4,11}, {4,10}, {3,10}, {3,9}},
	-- F5
	{146, {3,9}, {4,9}, {4,11}, {s="take",dir="Down"}, {4,6}, {13,6}, {13,9}, {9,9}, {9,12}, {14,12}, {14,10}, {18,10}, {c="allowDeath",on=false}, {18,9}},
	-- F6
 	{147, {18,9}, {18,7}, {15,7}, {15,3}, {11,3}, {11,5}, {10,5}, {s="interact",dir="Left"}, {10,6}, {6,6}, {6,7}, {s="interact",dir="Down"}, {6,14}, {10,14}, {10,16}, {s="pokeDoll"}, {9,16}},
	-- F7: Top
	{148, {9,16}, {10,16}, {10,9}, {s="fightX",x="accuracy"}, {c="thrash",disable=false}, {10,7}, {s="thunderboltFirst"}, {10,4}, {s="interact",dir="Up"}},
	-- Old man's house
	{149, {3,7}, {3,6}, {2,6}, {2,1}, {s="talk",dir="Right"}, {2,8}},

-- 10: POKéFLUTE

	-- Lavender -> Celadon
	{4, {7,10}, {s="split"}, {s="fly",dest="celadon",map=6}},
	-- To Celadon Center
	{6, {41,10}, {41,9}},
	-- Celadon Center
	{133, {3,7}, {3,3}, {s="dialogue",dir="Up"}, {3,8}},
	-- Leave Celadon
	{6, {41,10}, {c="a",a="Snorlax"}, {s="item",item="super_repel",chain=true}, {s="bicycle"}, {41,11}, {14,11}, {14,14}, {2,14}, {2,18}, {-1,18}},
	-- トトロだ！
	{27, {39,10}, {27,10}, {s="swapXSpeeds"}, {s="playPokeFlute"}, {23,10}},
	-- Snorlax pass
	{186, {7,8}, {-1,8}},
	-- Bicycle road
	{27, {17,10}, {c="a",a="Bicycle Road"}, {12,10}, {12,13}, {11,13}, {11,18}},
	-- Forced down inputs
	{28, {11,0}, {11,5}, {15,5}, {15,12}, {s="drivebyRareCandy"}, {15,14}, {18,14}, {18,122}, {13,122}, {13,143}},
	-- Cycling road exit
	{29, {13,0}, {13,8}, {34,8}},
	-- Exit building
	{190, {0,4}, {8,4}},
	-- Enter Safari City
	{29, {40,8}, {s="item",item="super_repel",chain=true}, {s="teach",move="ice_beam",replace="rock_slide",chain=true}, {s="bicycle"}, {50,8}},
	-- Safari City
	{7, {0,16}, {c="a",a="Safari Zone"}, {3,16}, {3,20}, {23,20}, {23,14}, {29,14}, {29,15}, {35,15}, {35,8}, {37,8}, {37,2}, {22,2}, {22,4}, {18,4}, {18,3}},
	-- Safari entrance
	{156, {3,5}, {3,2}, {4,2}, {s="dialogue",dir="Right"}},
	-- Safari 1
	{220, {15,25}, {s="bicycle"}, {15,16}, {28,16}, {28,11}, {30,11}},
	-- Safari 2
	{217, {0,23}, {4,23}, {4,24}, {20,24}, {20,20}, {s="safariCarbos"}, {12,20}, {12,22}, {11,22}, {10,22}, {s="item",item="super_repel",chain=true}, {s="tossInSafari"}, {s="item",item="carbos",poke="nidoking"}, {9,22}, {9,8}, {12,8}, {12,6}, {17,6}, {17,8}, {20,8}, {s="extraFullRestore"}, {20,3}, {7,3}, {7,5}, {-1,5}},
	-- Safari 3
	{218, {39,31}, {22,31}, {22,22}, {16,22}, {16,28}, {13,28}, {13,9}, {28,9}, {28,3}, {3,3}, {3,36}},
	-- Safari 4
	{219, {21,0}, {21,5}, {19,5}, {19,6}, {s="interact",dir="Down"}, {19,5}, {7,5}, {7,6}, {3,6}, {3,3}},
	-- Warden
	{222, {2,7}, {2,6}, {3,6}, {3,4}, {s="talk",dir="Up"}, {3,8}},
	-- Safari Warp
	{219, {3,4}, {s="skill",move="dig",map=219}},
	-- Celadon again
	{6, {41,10}, {s="bicycle"}, {41,11}, {50,11}},
	-- To Saffron
	{18, {0,3}, {c="a",a="Saffron City"}, {4,3}, {4,9}, {10,9}, {10,10}, {12,10}},
	-- Thirsty guard
	{76, {0,4}, {6,4}},
	-- Saffron entry
	{18, {18,10}, {s="bicycle"}, {20,10}},
	-- Saffron City
	{10, {0,18}, {3,18}, {3,22}, {18,22}, {18,21}},
	-- Silph Co
	{181, {10,17}, {c="a",a="Silph Co."}, {10,9}, {8,9}, {8,1}, {20,1}, {20,0}},
	-- Elivator
	{236, {1,3}, {1,2}, {3,2}, {3,1}, {s="silphElevator"}, {2,1}, {2,4}},
	-- F10
	{234, {12,1}, {12,3}, {4,3}, {4,9}, {s="fightSilphMachoke"}, {6,9}, {6,11}, {s="silphCarbos"}, {6,16}, {3,16}, {3,14}, {s="interact",dir="Right"}, {3,15}, {1,15}, {1,13}, {s="item",item="carbos",poke="nidoking",full=true}, {1,12}, {s="interact",dir="Right"}, {1,16}, {3,16}, {s="swapXSpecials"}, {s="teach",move="surf",poke="squirtle",replace="tail_whip",chain=true}, {s="teach",move="earthquake",replace="thrash",chain=true}, {s="item",item="carbos",poke="nidoking"}, {6,16}, {6,9}, {4,9}, {4,1}, {8,1}, {8,0}},
	-- F9
	{233, {14,1}, {14,3}, {24,3}, {24,16}, {17,16}, {17,15}},
	-- Warped
	{210, {9,15}, {9,16}, {20,16}, {s="take",dir="Right"}, {9,16}, {9,15}},
	-- Warp back
	{233, {17,15}, {17,14}, {17,15}},
	-- First card
	{210, {9,15}, {9,13}, {8,13}, {s="interact",dir="Left"}, {6,13}, {6,16}, {3,16}, {3,15}},
	-- Warp down
	{208, {3,15}, {3,14}, {18,14}, {18,9}, {s="interact",dir="Left"}, {14,9}, {14,11}, {11,11}},
	-- Rival 5
	{212, {5,3}, {c="a",a="Silph Rival"}, {4,3}, {4,2}, {3,2}, {c="potion",b=false}, {s="silphRival"}, {3,7}, {c="potion",b=true,yolo=true}, {5,7}},
	-- Giovanni
	{235, {3,2}, {c="a",a="Silph Giovanni"}, {3,11}, {2,11}, {2,15}, {s="rareCandyGiovanni"}, {2,16}, {s="talk",dir="Right"}, {2,15}, {5,15}, {s="potion",hp=17,yolo=12}, {6,15}, {6,14}, {s="interact",dir="Up"}, {6,13}, {s="fightX",x="accuracy"}, {s="fightSilphGiovanni"}, {s="split"}, {s="skill",move="dig",map=235}},

-- 11: SILPH CO.

	-- Fly to Fuschia
	{6, {41,10}, {s="fly",dest="fuchsia",map=7}},
	-- To Koga
	{7, {19,28}, {c="a",a="Koga's Gym"}, {5,28}, {5,27}},
	-- Koga
	{157, {4,17}, {4,16}, {9,16}, {9,9}, {7,9}, {s="talk",dir="Up"}, {9,9}, {9,1}, {1,1}, {1,2}, {s="elixer",move="earthquake",min=2,chain=true}, {s="potionBeforeHypno"}, {1,3}, {2,3}, {2,5}, {1,5}, {c="potion",b=false}, {1,7}, {s="fightHypno"}, {1,9}, {2,9}, {s="elixer",move="earthquake",min=4}, {4,9}, {s="talk",dir="Down"}, {s="fightKoga"}, {s="split"}, {1,9}, {1,5}, {2,5}, {2,3}, {1,3}, {1,1}, {9,1}, {9,16}, {5,16}, {5,18}},

-- 12: KOGA

	-- To the Warden
	{7, {5,28}, {s="bicycle"}, {6,28}, {6,30}, {24,30}, {30,30}, {30,28}, {27,28}, {27,27}},
	-- HM04 Strength
	{155, {4,7}, {4,6}, {2,6}, {2,4}, {s="talk",dir="Up"}, {4,4}, {4,8}},
	-- Fly home
	{7, {27,28}, {s="fly",dest="pallet",map=0}},
	-- Pallet to Cinnabar
	--TODO combine RC for Carbos
	{0, {5,6}, {s="item",item="super_repel",chain=true}, {s="item",item="rare_candy",poke="nidoking",all=true,chain=true}, {s="bicycle"}, {c="allowDeath",on=false}, {3,6}, {s="dodgeGirl"}, {3,17}, {s="skill",move="surf",dir="Right",x=4}, {4,18}},
	-- To Cinnabar
	{32, {4,0}, {4,14}, {3,14}, {3,90}},
	-- Enter Cinnabar Mansion
	{8, {3,0}, {c="a",a="Cinnabar Mansion"}, {3,4}, {6,4}, {6,3}},
	-- F1
	{165, {5,27}, {5,10}},
	-- F2
	{214, {5,11}, {10,11}, {10,5}, {6,5}, {6,1}},
	-- F3
	{215, {6,2}, {11,2}, {11,6}, {10,6}, {s="dialogue",dir="Up"}, {14,6}, {14,11}, {16,11}, {16,14}},
	-- F1 drop
	{165, {16,14}, {16,16}, {13,16}, {13,20}, {s="cinnabarCarbos"}, {21,23}},
	-- B1
	--TODO menu cancel for RC
	{216, {23,22}, {23,15}, {21,15}, {s="item",item="super_repel",chain=true}, {s="item",item="carbos",poke="nidoking"}, {17,15}, {17,19}, {18,19}, {18,23}, {17,23}, {17,26}, {18,26}, {s="dialogue",dir="Up"}, {14,26}, {14,22}, {12,22}, {12,15}, {24,15}, {24,18}, {26,18}, {26,6}, {24,6}, {24,4}, {20,4}, {s="dialogue",dir="Up"}, {24,4}, {24,6}, {12,6}, {12,2}, {11,2}, {s="take",dir="Left"}, {12,2}, {12,7}, {4,7}, {4,9}, {2,9}, {s="take",dir="Left"}, {5,9}, {5,10}, {s="teach",move="strength",poke="squirtle",replace="tackle",chain=true}, {s="item",item="rare_candy",all=true,poke="nidoking"}, {5,12}, {s="take",dir="Down"}, {5,12}, {s="skill",move="dig",map=216}},
	-- Celadon once again
	{6, {41,10}, {s="bicycle"}, {41,13}, {36,13}, {36,23}, {25,23}, {25,30}, {35,30}, {35,31}, {s="skill",move="cut",dir="Down",done=0x0D4D}, {35,34}, {5,34}, {5,29}, {12,29}, {12,27}},
	-- Erika
	{134, {4,17}, {c="a",a="Erika's Gym"}, {4,16}, {1,16}, {1,9}, {0,9}, {0,4}, {1,4}, {s="skill",move="cut",done=0x0D4D}, {4,4}, {s="talk",dir="Up"}, {s="fightErika"}, {s="split"}, {5,4}, {5,6}, {s="skill",move="cut",dir="Down",done=0x0D4D}, {5,18}},

-- 13: ERIKA

	-- Fly to Cinnabar
	{6, {12,28}, {s="fly",dest="cinnabar",map=8}},
	-- Cinnabar
	{8, {11,12}, {s="elixer",move="earthquake",min=4,chain=true}, {s="bicycle"}, {18,12}, {18,3}},
	-- Cinnabar Gym
	{166, {16,17}, {c="a",a="Blaine's Gym"}, {16,14}, {18,14}, {18,10}, {15,10}, {15,8}, {s="dialogue",dir="Up"}, {16,8}, {16,7}, {18,7}, {18,1}, {12,1}, {12,2}, {10,2}, {s="dialogue",dir="Up",decline=true}, {12,2}, {12,7}, {10,7}, {10,8}, {9,8}, {s="dialogue",dir="Up",decline=true}, {9,11}, {12,11}, {12,13}, {10,13}, {10,14}, {9,14}, {s="dialogue",dir="Up",decline=true}, {9,16}, {1,16}, {1,14}, {s="dialogue",dir="Up"}, {2,14}, {2,13}, {4,13}, {4,9}, {1,9}, {1,8}, {s="dialogue",dir="Up",decline=true}, {2,8}, {2,7}, {4,7}, {4,5}, {3,5}, {3,4}, {c="potion",b=false}, {s="waitToFight",dir="Up"}, {s="split"}, {s="skill",move="dig",map=166}},

-- 14: BLAINE

	-- Celadon too many times
	{6, {41,10}, {c="potion",b=true,yolo=true}, {s="bicycle"}, {41,11}, {50,11}},
	-- Exit Celadon
	{18, {0,3}, {4,3}, {4,9}, {10,9}, {10,10}, {12,10}},
	-- Saffron gate
	{76, {0,4}, {c="a",a="Saffron City"}, {6,4}},
	-- Saffron edge
	{18, {18,10}, {s="elixer",move="earthquake",min=4,chain=true}, {s="bicycle"}, {20,10}},
	-- Saffron again
	{10, {0,18}, {3,18}, {3,6}, {31,6}, {31,4}, {34,4}, {34,3}},
	-- Sabrina
	{178, {8,17}, {c="a",a="Sabrina's Gym"}, {8,16}, {11,16}, {11,15}, {16,17}, {16,15}, {15,15}, {18,3}, {18,5}, {15,5}, {1,5}, {11,11}, {11,8}, {10,8}, {s="waitToFight",dir="Left"}, {s="split"}, {11,8}, {11,11}, {s="elixer",move="earthquake",min=4,chain=true}, {s="skill",move="dig",map=178}},

-- 15: SABRINA

	-- Celadon
	{6, {41,10}, {s="fly",dest="viridian",map=1}},
	-- Viridian again
	{1, {23,26}, {s="bicycle"}, {19,26}, {19,4}, {27,4}, {27,3}, {34,3}, {34,8}, {32,8}, {32,7}},
	-- Giovanni Gym
	{45, {16,17}, {c="potion",b=false}, {c="a",a="Giovanni's Gym"}, {16,16}, {14,16}, {14,9}, {13,9}, {13,7}, {15,7}, {15,4}, {12,4}, {12,5}, {10,5}, {c="a",a="Machoke"}, {10,4}, {s="fightGiovanniMachoke"}, {10,5}, {13,5}, {13,4}, {15,4}, {15,7}, {13,7}, {13,11}, {14,11}, {14,16}, {16,16}, {16,18}},
	-- Reset Gym
	{1, {32,8}, {c="a",a="Giovanni's Gym"}, {32,7}},
	-- Giovanni
	{45, {16,17}, {c="potion",b=false}, {16,16}, {14,16}, {14,9}, {13,9}, {13,7}, {15,7}, {15,4}, {12,4}, {12,5}, {10,5}, {10,2}, {7,2}, {7,4}, {2,4}, {s="checkGiovanni"}, {2,2}, {s="talk",dir="Up"}, {s="fightGiovanni"}, {s="split"}, {2,4}, {7,4}, {7,2}, {10,2}, {10,5}, {12,5}, {12,4}, {15,4}, {15,7}, {13,7}, {13,11}, {14,11}, {14,16}, {16,16}, {16,18}},

-- 16: GIOVANNI

	-- Leave Viridian
	{1, {32,8}, {s="bicycle"}, {32,12}, {17,12}, {17,16}, {16,16}, {16,17}, {-1,17}},
	-- To Pokemon League
	{33, {39,9}, {c="a",a="Viridian Rival"}, {35,9}, {35,12}, {31,12}, {31,5}, {29,5}, {s="viridianRival"}, {16,5}, {16,12}, {5,12}, {5,10}, {11,10}, {11,6}, {8,6}, {8,5}},
	-- Pokemon League 1
	{193, {4,7}, {4,0}},
	-- PL 2
	{34, {7,139}, {s="checkEther"}, {s="ether",max=true,chain=true}, {s="tossInVictoryRoad"}, {s="bicycle"}, {7,132}, {14,132}, {14,124}, {9,124}, {9,116}, {10,116}, {10,104}, {s="skill",move="surf",y=103}, {10,92}, {7,92}, {7,90}, {s="grabMaxEther"}, {7,72}, {8,72}, {8,71}, {s="item",item="super_repel",chain=true}, {s="bicycle"}, {8,66}, {10,66}, {10,57}, {12,57}, {12,48}, {6,48}, {6,32}, {4,32}, {4,31}},
	-- Victory Road
	{108, {8,17}, {c="a",a="Victory Road"}, {s="tweetVictoryRoad"}, {8,16}, {4,16}, {4,14}, {5,14}, {s="skill",move="strength"}, {5,15}, {4,15}, {4,16}, {7,16}, {s="push",dir="Right",x=0x0255,y=0x0254}, {7,17}, {9,17}, {9,15}, {8,15}, {8,14}, {15,14}, {15,15}, {16,15}, {16,14}, {s="push",dir="Up",x=0x0255,y=0x0254}, {14,14}, {14,12}, {16,12}, {16,11}, {17,11}, {17,12}, {14,12}, {14,14}, {8,14}, {8,16}, {5,16}, {5,12}, {11,12}, {11,6}, {7,6}, {7,8}, {3,8}, {3,5}, {2,5}, {2,1}, {1,1}},
	-- F2
	{194, {0,8}, {0,9}, {3,9}, {3,13}, {5,13}, {5,14}, {s="item",item="super_repel",chain=true}, {s="skill",move="strength"}, {4,14}, {4,13}, {3,13}, {3,15}, {4,15}, {4,16}, {3,16}, {s="push",dir="Left",x=0x02B5,y=0x02B4}, {3,11}, {5,11}, {5,8}, {14,8}, {14,14}, {21,14}, {21,16}, {28,16}, {28,11}, {23,11}, {23,7}},
	-- F3
	{198, {23,7}, {23,6}, {22,6}, {22,4}, {s="skill",move="strength"}, {22,2}, {23,2}, {23,1}, {7,1}, {7,0}, {6,0}, {6,1}, {7,1}, {7,2}, {3,2}, {3,1}, {2,1}, {2,4}, {1,4}, {1,5}, {2,5}, {2,4}, {4,4}, {4,2}, {7,2}, {7,1}, {20,1}, {20,6}, {17,6}, {17,4}, {9,4}, {9,10}, {5,10}, {5,8}, {1,8}, {1,15}, {11,15}, {11,16}, {20,16}, {20,15}, {23,15}},
	-- F2
	{194, {22,16}, {s="item",item="super_repel",chain=true}, {s="potionBeforeLorelei",chain=true}, {s="skill",move="strength"}, {s="bicycle"}, {22,17}, {24,17}, {24,16}, {11,16}, {s="push",dir="Left",x=0x02D5,y=0x02D4}, {21,16}, {21,14}, {25,14}},
	-- F3
	{198, {27,15}, {27,8}, {26,8}},
	-- F2 Exit
	{194, {27,7}, {30,7}},
	-- Victory end
	{34, {14,32}, {18,32}, {18,20}, {14,20}, {14,10}, {13,10}, {13,6}, {10,6}, {10,-1}},
	-- Elite Four entrance
	{9, {10,17}, {c="a",a="Elite Four"}, {10,5}},
	-- Last Center
	{174, {7,11}, {15,9}, {15,8}, {s="depositPokemon"}, {7,8}, {7,7}, {s="centerSkip"}, {4,7}, {3,7}, {3,2}, {8,2}, {8,0}},

-- 17: LORELEI

	-- Lorelei
	{245, {s="changeSpeed", speed=E4_SPEED, extra="Enjoy the show"}, {4,5}, {c="a",a="Lorelei"}, {c="potion",b=false}, {4,2}, {s="talk",dir="Right"}, {s="lorelei"}, {s="split"}, {4,0}},
	-- Bruno
	{246, {4,5}, {c="a",a="Bruno"}, {s="item",item="elixer",poke="nidoking"}, {4,2}, {s="talk",dir="Right"}, {s="bruno"}, {s="split"}, {4,0}},
	-- Agatha
	{247, {4,5}, {c="a",a="Agatha"}, {s="potion",hp=113,full=true}, {4,2}, {s="talk",dir="Right"}, {s="agatha"}, {s="split"}, {4,1}, {s="prepareForLance"}, {s="ether"}, {4,0}},
	-- Lance
	{113, {6,11}, {c="a",a="Lance"}, {6,2}, {s="lance"}, {s="split"}, {5,2}, {5,1}, {s="prepareForBlue"}, {5,-1}},
	-- Blue
	{120, {4,3}, {c="a",a="Blue"}, {s="blue"}, {3,0}},
	-- Champion
	{118, {4,2}, {c="a",a="Champion"}, {s="champion"}}

}

return Paths
