local paths = {
	-- Red's room
	{38, {3,6}, {5,6}, {5,1}, {7,1}},
	-- Red's house
	{39, {7,1}, {7,6}, {3,6}, {3,8}},
	-- Into the Wild
	{0, {5,6}, {10,6}, {10,1}},
	-- Choose your character!
	{40, {5,3}, {s="a",a="Pallet Rival"}, {5,4}, {7,4}, {s="squirtleIChooseYou"}, {5,4}, {5,6}, {s="fightBulbasaur"}, {s="split"}, {5,12}},

-- 1: RIVAL 1

	-- Let's try this escape again
	{0, {12,12}, {s="a",a="Pallet Town"}, {c="viridianExp"}, {c="encounters",limit=4}, {9,12}, {9,2}, {10,2}, {10,-1}},
	-- First encounters
	{12, {10,35}, {10,30}, {8,30}, {8,24}, {12,24}, {12,20}, {9,20}, {9,14}, {14,14}, {s="dodgePalletBoy"}, {14,2}, {11,2}, {11,-1}},
	-- To the Mart
	{1, {21,35}, {21,30}, {19,30}, {19,20}, {29,20}, {29,19}},
	-- Viridian Mart
	{42, {2,5}, {3,5}, {3,8}},
	-- Backtracking
	{1, {29,20}, {c="encounters",limit=5}, {29,21}, {26,21}, {26,30}, {20,30}, {20,36}},
	-- Parkour
	{12, {10, 0}, {10,3}, {8,3}, {8,18}, {9,18}, {9,22}, {12,22}, {12,24}, {10,24}, {10,36}},
	-- To Oak's lab
	{0, {10,0}, {10,7}, {9,7}, {9,12}, {12,12}, {12,11}},
	-- Parcel delivery
	{40, {5,11}, {5,3}, {4,3}, {4,1}, {5,1}, {s="interact",dir="Down"}, {4,1}, {4,12}},
	-- Leaving home
	{0, {12,12}, {c="viridianBackupExp"}, {9,12}, {9,2}, {10,2}, {10,-1}},
	-- The grass again!?
	{12, {10,35}, {10,30}, {8,30}, {8,24}, {12,24}, {12,20}, {9,20}, {9,14}, {14,14}, {s="dodgePalletBoy"}, {14,2}, {11,2}, {11,-1}},
	-- Back to the Mart
	{1, {21,35}, {21,30}, {19,30}, {19,20}, {29,20}, {29,19}},
	-- Viridian Mart redux
	{42, {3,7}, {3,5}, {2,5}, {s="viridianBuyPokeballs"}, {3,5}, {3,8}},
	-- Sidequest
	{1, {29,20}, {15,20}, {15,17}, {-1, 17}},
	-- Nidoran
	{33, {39, 9}, {s="a",a="Nidoran grass"}, {c="nidoranBackupExp"}, {c="encounters",limit=7,extra="spearow"}, {35, 9}, {35,12}, {33,12}, {c="catchNidoran"}, {s="catchNidoran"}, {33,12}, {s="split"}, {37,12}, {37,9}, {40,9}},

-- 2: NIDORAN

	-- Out of Viridian City
	{1, {0,17}, {c="encounters",limit=10,extra="spearow"}, {16,17}, {16,16}, {18,16}, {18,6}, {s="dodgeViridianOldMan"}, {17,4}, {15,4}, {s="interact",dir="Left"}, {17,4}, {17, 0}, {17, -1}},
	-- To the Forest
	{13, {7,71}, {7,57}, {4,57}, {4,52}, {10,52}, {10,44}, {3,44}, {3,43}},
	-- Forest entrance
	{50, {4,7}, {s="a",a="Viridian Forest"}, {4,1}, {5,1}, {5,0}},
	-- Viridian Forest
	{51, {17,47}, {17,43}, {26,43}, {26,34}, {25,34}, {25,12}, {s="grabAntidote"}, {25,9}, {17,9}, {17,16}, {13,16}, {13,3}, {7,3}, {7,22}, {1,22}, {1,19}, {s="grabForestPotion"}, {1,18}, {s="fightWeedle"}, {c="encounters",limit=22,extra="paras"}, {1,16}, {c="potion",b=false}, {s="equipForBrock",anti=true}, {1,5}, {s="equipForBrock"}, {1,-1}},
	-- Forest exit
	{47, {4,7}, {4,1}, {5,1}, {5,0}},
	-- Road to Pewter City
	{13, {3,11}, {s="a",a="Pewter City"}, {3,8}, {8,8}, {8,-1}},
	-- Pewter City
	{2, {18,35}, {18,22}, {19,22}, {19,13}, {10,13}, {10,18}, {16,18}, {16,17}},
	-- Brock
	{54, {4,13}, {s="a",a="Brock's Gym"}, {4,8}, {1,8}, {1,4}, {4,4}, {4,2}, {s="interact",dir="Up"}, {s="fightBrock"}, {s="split"}, {s="emuSpeed",percent=100}, {4,14}},

-- 3: BROCK

	-- To Pewter Mart
	{2, {16,18}, {c="potion",b=true}, {10,18}, {10,13}, {21,13}, {21,18}, {23,18}, {23,17}},
	-- Pewter Mart
	{56, {3,7}, {3,5}, {2,5}, {s="pewterMart"}, {2,6}, {3,6}, {3,8}},
	-- Leaving Pewter City
	{2, {23,18}, {40,18}},
	-- Route 3
	{14, {0,10}, {s="a",a="Route 3"}, {c="catchFlier"}, {c="pp",on=true}, {s="battleModeSet"}, {8,10}, {8,8}, {11,8}, {11,6}, {s="leer",{"caterpie",8},{"weedle",7}}, {11,4}, {12,4}, {s="potion",hp=19}, {13,4}, {s="interact",dir="Right"}, {s="shortsKid"}, {13,5}, {s="potionBeforeCocoons"}, {18,5}, {s="interact",dir="Right"}, {s="swapHornAttack"}, {18,6}, {22,6}, {22,5}, {s="potion",hp=4}, {24,5}, {s="interact",dir="Down"}, {s="fightMetapod"}, {27,5}, {27,9}, {s="catchFlierBackup"}, {37,8}, {37,5}, {49,5}, {49,10}, {57,10}, {57,8}, {59,8}, {59,-1}},
	-- To the Center
	{15, {9,16}, {c="pp",on=false}, {12,16}, {12,6}, {11,6}, {11,5}},
	-- PP up
	{68, {3,7}, {3,3}, {s="confirm",dir="Up"}, {3,8}},
	-- Enter Mt. Moon
	{15, {11,6}, {s="a",a="Mt. Moon"}, {18,6}, {s="split"}, {18,5}},

-- 4: ROUTE 3

	-- Mt. Moon F1
	{59, {14,35}, {s="startMtMoon"}, {c="catchParas"}, {14,22}, {21,22}, {21,15}, {24,15}, {24,27}, {25,27}, {25,31}, {s="interact",dir="Left"}, {25,32}, {33,32}, {33,31}, {34,31}, {s="interact",dir="Right"}, {34,7}, {30,7}, {s="evolveNidorino"}, {c="moon1Exp"}, {28,7}, {16,7}, {16,17}, {2,17}, {2,3}, {s="interact",dir="Up"}, {5,3}, {5,5}},
	-- Mt. Moon B2
	{60, {5,5}, {5,17}, {21,17}},
	-- Mt. Moon B3
	{61, {21,17}, {23,17}, {23,14}, {27,14}, {27,16}, {33,16}, {33,14}, {36,14}, {36,24}, {32, 24}, {32,31}, {10,31}, {10,18}, {s="evolveNidoking"}, {c="encounters",limit=nil}, {10,17}, {12,17}, {c="moon2Exp"}, {12,9}, {s="potion",hp=7}, {s="interact",dir="Up"}, {13,9}, {c="moon3Exp"}, {13,7}, {s="helix"}, {13,5}, {12,5}, {12,4}, {3,4}, {3,7}, {5,7}},
	-- Mt. Moon escape
	{60, {23,3}, {27,3}},

-- 5: MT. MOON

	-- To Cerulean
	{15, {24,6}, {s="reportMtMoon"}, {s="split"}, {35,6}, {35,10}, {61,10}, {61,8}, {79,8}, {79,10}, {90,10}},
	-- Enter Cerulean
	{3, {0,18}, {s="a",a="Cerulean"}, {14,18}, {s="dodgeCerulean"}, {19,18}, {19,17}},
	-- Cerulean Center
	{64, {3,7}, {3,3}, {s="confirm",dir="Up"}, {3,8}},
	-- To the house
	{3, {19,18}, {16,18}, {s="dodgeCeruleanLeft"}, {8,16}, {8,12}, {9,12}, {9,11}},
	-- In the house
	{230, {2,7}, {2,0}},
	-- Outback
	{3, {9,9}, {9,8}, {14,8}, {s="interact",dir="Right"}, {9,8}, {9,10}},
	-- Out the house
	{230, {2,1}, {2,8}},
	-- Rival 2
	{3, {9,12}, {s="a",a="Cerulean Rival"}, {21,12}, {21,6}, {s="rivalSandAttack"}, {21,-1}},
	-- Nugget bridge
	{35, {11,35}, {s="a",a="Nugget Bridge"}, {11,32}, {s="interact",dir="Up"}, {10,32}, {10,29}, {s="interact",dir="Up"}, {11,29}, {11,26}, {s="interact",dir="Up"}, {10,26}, {10,24}, {s="teachThrash"}, {10,23}, {s="interact",dir="Up"}, {11,23}, {11,21}, {s="teachThrash"}, {11,20}, {s="interact",dir="Up"}, {s="redbarMankey"}, {10,20}, {10,19}, {s="teachThrash"}, {10,15}, {s="waitToFight"}, {s="teachThrash"}, {s="split"}, {10,8}, {20,8}},

-- 6: NUGGET BRIDGE

	-- To Bill's
	{36, {0,8}, {9,8}, {9,6}, {9,6}, {8,6}, {8,5}, {s="interact",dir="Up"}, {s="thrashGeodude"}, {10,5}, {10,2}, {s="interact",dir="Up"}, {10,4}, {13,4}, {13,6}, {15,6}, {15,4}, {17,4}, {17,7}, {18,7}, {s="interact",dir="Down"}, {20,7}, {20,8}, {22,8}, {22,6}, {35,6}, {35,4}, {36,4}, {s="interact",dir="Right"}, {36,5}, {38,5}, {38,4}, {s="interact",dir="Up"}, {45,4}, {45,3}},
	-- Save Bill
	{88, {2,7}, {2,5}, {5,5}, {s="confirm",dir="Right"}, {1,5}, {s="interact",dir="Up"}, {4,5}, {s="interact",dir="Up"}, {s="waitToTalk"}, {s="potionBeforeGoldeen"}, {s="item",item="escape_rope"}},
	-- To Misty
	{3, {19,18}, {19,20}, {30,20}, {30,19}},
	-- Misty
	{65, {4,13}, {s="a",a="Misty's Gym"}, {c="potion",b=false}, {4,8}, {2,8}, {2,5}, {7,5}, {7,3}, {6,3}, {5,3}, {s="waitToFight"}, {s="potionBeforeMisty"}, {5,2}, {s="waitToFight",dir="Left"}, {s="split"}, {s="tweetMisty"}, {5,3}, {7,3}, {7,5}, {5,5}, {5,14}},

-- 7: MISTY

	-- Past the policeman
	{3, {30,20}, {c="potion",b=true,yolo=true}, {8,20}, {8,12}, {27,12}, {27,11}},
	-- Wrecked house
	{62, {2,7}, {2,2}, {3,2}, {3,0}},
	-- Cerulean Rocket
	{3, {27,9}, {28,9}, {s="potionBeforeRocket"}, {33,9}, {33,18}, {36,18}, {36,31}, {25,31}, {25,36}},
	-- Out of Cerulean
	{16, {15,0}, {15,28}, {17,28}, {17,27}},
	-- Underground entrance
	{71, {3,7}, {3,4}, {4,4}},
	-- Underground to Vermilion
	{119, {5,4}, {4,4}, {s="jingleSkip"}, {2,4}, {2,41}},
	-- Underground exit
	{74, {4,4}, {3,8}},
	-- Oddish
	{17, {17,14}, {s="a",a="Vermilion City"}, {c="catchOddish"}, {17,15}, {s="potion",hp=9,yolo=5}, {17,19}, {s="catchOddish"}, {11,29}, {s="potion",hp=9,yolo=5}, {11,29}, {s="waitToFight",dir="Down"}, {10,29}, {10,30}, {s="potion",hp=9,yolo=5}, {10,31}, {9,31}, {9,32}, {s="potion",hp=20,yolo=18}, {9,36}},
	-- Enter Vermilion
	{5, {19,0}, {c="disableCatch"}, {19,6}, {21,6}, {21,14}, {23,14}, {23,13}},
	-- Vermilion mart
	{91, {3,7}, {3,5}, {2,5}, {s="vermilionMart"}, {3,5}, {s="teach",move="bubblebeam",replace="tackle"}, {3,8}},
	-- To S.S. Anne
	{5, {23,14}, {30,14}, {30,26}, {18,26}, {18,31}},
	-- Mew
	{94, {14,0}, {s="a",a="S.S. Anne"}, {14,3}},
	-- First deck
	{95, {27,0}, {27,1}, {26,1}, {26,7}, {2,7}, {2,6}},
	-- Rival 3
	{96, {2,4}, {2,11}, {3,11}, {3,12}, {s="potion",hp=20,yolo=16}, {37,12}, {37,8}, {s="rivalSandAttack"}, {37,5}, {36,5}, {36,4}},
	-- Old man Cut
	{101, {0,7}, {0,4}, {4,4}, {4,3}, {s="interact",dir="Up"}, {4,5}, {0,5}, {0,7}},
	-- Second deck out
	{96, {36,4}, {36,12}, {3,12}, {3,11}, {2,11}, {2,4}},
	-- First deck out
	{95, {2,6}, {2,7}, {26,7}, {26,-1}},
	-- Departure
	{94, {14,2}},
	-- To Surge
	{5, {18,29}, {18,26}, {30,26}, {30,14}, {15,14}, {15,17}, {s="potion",hp=20,yolo=5,forced="potion",chain=true}, {s="potion",hp=5,chain=true}, {s="teach",move="cut",poke="oddish",alt="paras",chain=true}, {s="skill",move="cut",done=0x0D4D}, {15,20}, {12,20}, {12,19}},
	-- Trashcans
	{92, {4,17}, {s="a",a="Surge's Gym"}, {4,16}, {2,16}, {2,11}, {s="trashcans"}, {4,6}, {4,3}, {5,3}, {5,2}, {s="interact",dir="Up"}, {s="fightSurge"}, {s="split"}, {4,2}, {4,13}, {5,13}, {5,18}},

-- 8: SURGE

	-- To bicycle house
	{5, {12,20}, {s="a",a="Bicycle Shop"}, {15,20}, {15,19}, {s="skill",move="cut",done=0x0D4D}, {15,14}, {9,14}, {9,13}},
	-- Bicycle cert
	{90, {2,7}, {2,5}, {0,5}, {0,1}, {2,1}, {s="confirm",dir="Right"}, {s="teach",move="dig",poke="paras",alt="squirtle",chain=true}, {s="skill",move="dig",map=90}},
	-- Cerulean warp
	{3, {19,18}, {19,23}, {16,23}, {16,26}, {13,26}, {13,25}},
	-- Bicycle shop
	{66, {2,7}, {2,5}, {4,5}, {s="dodgeBicycleGirlRight"}, {6,4}, {6,4}, {s="procureBicycle"}, {s="dodgeBicycleGirlLeft"}, {3,8}},
	-- Bicycle out of Cerulean
	{3, {13,26}, {s="swapBicycle"}, {s="teach",move="thunderbolt",replace="horn_attack",chain=true}, {s="bicycle"}, {19,26}, {19,27}, {s="skill",move="cut",done=0x0D4D}, {19,29}, {36,29}, {36,16}, {40,16}},
	-- TPP's Bane
	{20, {0,8}, {s="a",a="Route 9"}, {4,8}, {s="skill",move="cut",done=0x0C17,val=2}, {13,8}, {13,9}, {s="interact",dir="Down"}, {12,9}, {12,12}, {23,12}, {23,11}, {29,11}, {29,12}, {41,12}, {41,10}, {40,10}, {40,9}, {s="interact",dir="Up"}, {41,9}, {41,6}, {39,6}, {39,4}, {45,4}, {45,3}, {51,3}, {51,8}, {60,8}},
	-- To the cave
	{21, {0,8}, {3,8}, {3,10}, {13,10}, {13,15}, {14,15}, {14,26}, {3,26}, {3,18}, {8,18}, {8,17}},
	-- Rock tunnel
	{82, {15,3}, {s="a",a="Rock Tunnel"}, {c="potion",b=false}, {s="item",item="repel"}, {15,6}, {23,6}, {23,7}, {s="interact",dir="Down"}, {s="redbarCubone"}, {22,7}, {22,10}, {37,10}, {37,3}},
	-- B1
	{232, {33,25}, {33,30}, {27,30}, {s="interact",dir="Left"}, {27,31}, {14,31}, {14,29}, {s="interact",dir="Up"}, {17,29}, {17,24}, {25,24}, {25,16}, {37,16}, {37,11}, {s="item",item="repel"}, {37,3}, {27,3}},
	-- B2
	{82, {5,3}, {5,9}, {11,9}, {11,14}, {17,14}, {17,11}},
	-- B1
	{232, {23,11}, {14,11}, {14,17}, {8,17}, {8,10}, {7,10}, {s="interact",dir="Left"}, {7,11}, {5,11}, {s="item",item="repel"}, {5,3}, {3,3}},
	-- Out of the Tunnel
	{82, {37,17}, {32,17}, {32,23}, {37,23}, {37,28}, {28,28}, {26,24}, {23,24}, {s="interact",dir="Left"}, {23,27}, {15,27}, {15,33}},
	-- To Lavender Town
	{21, {8,54}, {s="a",a="Lavender Town"}, {15,54}, {15,65}, {11,65}, {11,69}, {6,69}, {6,72}},
	-- Through Lavender
	{4, {6,0}, {6,6}, {0,6}, {0,8}, {-1,8}},
	-- Leave Lavender
	{19, {59,8}, {52,8}, {52,13}, {47,13}, {s="interact",dir="Left"}, {47,14}, {42,14}, {42,7}, {40,7}, {40,6}, {29,6}, {29,7}, {23,7}, {23,12}, {14,12}, {14,4}, {13,4}, {13,3}},
	-- Underground entrance
	{80, {3,7}, {3,6}, {4,6}, {4,4}},
	-- Underground
	{121, {47,2}, {s="bicycle"}, {47,5}, {22,5}, {s="interact",dir="Left"}, {2,5}},
	-- Underground exit
	{77, {4,4}, {4,8}},
	-- To Celadon
	{18, {5,14}, {s="bicycle"}, {8,14}, {8,8}, {4,8}, {4,3}, {-1,3}},
	-- Celadon
	{6, {49,11}, {s="a",a="Celadon Mart"}, {14,11}, {14,14}, {10,14}, {10,13}},
	-- Department store
	{122, {16,7}, {c="potion",b=true,yolo=true}, {c="pp",on=true}, {16,3}, {12,3}, {12,1}},
	-- F2
	{123, {12,2}, {16,2}, {16,1}},
	-- F3
	{124, {16,2}, {12,2}, {12,1}},
	-- F4: Poke Doll
	{125, {12,2}, {10,2}, {10,5}, {5,5}, {s="shopPokeDoll"}, {11,5}, {11,2}, {16,2}, {16,1}},
	-- F5: Buffs
	{136, {16,2}, {8,2}, {8,5}, {5,5}, {s="shopBuffs"}, {9,5}, {9,2}, {12,2}, {12,1}},
	-- Roof
	{126, {15,3}, {12,3}, {s="shopVending"}, {6,3}, {6,4}, {s="giveWater"}, {6,4}, {7,3}, {12,3}, {s="shopExtraWater"}, {15,3}, {15,2}},
	-- F5
	{136, {12,2}, {16,2}, {16,1}},
	-- F4
	{125, {16,2}, {12,2}, {12,1}},
	-- F3
	{124, {12,2}, {16,2}, {16,1}},
	-- F2: TM and repel
	{123, {16,2}, {8,2}, {8,5}, {6,5}, {s="shopTM07"}, {5,5}, {s="shopRepels"}, {9,5}, {9,2}, {12,2}, {12,1}},
	-- Exit department store
	{122, {12, 2}, {12,6}, {16,6}, {16,8}},
	-- Leave Celadon
	{6, {10,14}, {s="bicycle"}, {10,15}, {2,15}, {2,18}, {-1,18}},
	-- Cut out of Celadon
	{27, {39,10}, {34,10}, {s="teach",move="horn_drill",replace="bubblebeam",full=true,chain=true}, {s="skill",move="cut",dir="Up",done=0x0D4D}, {34,6}, {27,6}, {27,4}, {23,4}},
	-- Old man's hall
	{186, {7,2}, {-1,2}},
	-- To the Fly house
	{27, {17,4}, {s="a",a="HM02 Fly"}, {10,4}, {10,6}, {7,6}, {7,5}},
	-- Fly house
	{188, {2,7}, {2,4}, {s="interact",dir="Up"}, {2,5}, {s="split"}, {2,8}},

-- 9: FLY

	-- Fly to Lavender
	{27, {7,6}, {s="swapRepels"}, {s="teach",move="fly",poke="spearow",alt="pidgey",chain=true}, {s="teach",move="horn_drill",replace="bubblebeam",chain=true}, {s="item",item="super_repel",chain=true}, {s="potion",hp=6,chain=true}, {s="teach",move="rock_slide",replace="poison_sting",chain=true}, {s="fly",dest="lavender",map=4}},
	-- To the tower
	{4, {3,6}, {s="a",a="Pokemon Tower"}, {14,6}, {14,5}},
	-- Pokemon Tower
	{142, {10,17}, {10,10}, {18,10}, {18,9}},
	-- F2: Rival
	{143, {18,9}, {c="setThrash",disable=true}, {18,7}, {16,7}, {16,5}, {15,5}, {s="lavenderRival"}, {5,5}, {5,8}, {3,8}, {3,9}},
	-- F3
	{144, {3,9}, {3,10}, {6,10}, {6,13}, {8,13}, {8,6}, {17,6}, {17,9}, {18,9}},
	-- F4
	{145, {18,9}, {s="allowDeath",on=true}, {c="potion",b=false}, {18,7}, {16,7}, {s="interact",dir="Left"}, {s="digFight"}, {16,9}, {c="potion",b=true,yolo=true}, {14,9}, {14,10}, {13,10}, {s="interact",dir="Left"}, {14,10}, {14,8}, {11,8}, {11,9}, {10,9}, {10,12}, {7,12}, {7,11}, {4,11}, {4,10}, {3,10}, {3,9}},
	-- F5
	{146, {3,9}, {4,9}, {4,11}, {s="interact",dir="Down"}, {4,6}, {13,6}, {13,9}, {9,9}, {9,12}, {14,12}, {14,10}, {18,10}, {s="allowDeath",on=false}, {18,9}},
	-- F6
 	{147, {18,9}, {18,7}, {15,7}, {15,3}, {11,3}, {11,5}, {10,5}, {s="interact",dir="Left"}, {10,6}, {6,6}, {6,7}, {s="interact",dir="Down"}, {6,14}, {10,14}, {10,16}, {s="pokeDoll"}, {9,16}},
	-- F7: Top
	{148, {9,16}, {10,16}, {10,9}, {s="fightXAccuracy"}, {c="setThrash",disable=false}, {10,7}, {s="thunderboltFirst"}, {10,4}, {s="interact",dir="Up"}},
	-- Old man's house
	{149, {3,7}, {3,6}, {2,6}, {2,1}, {s="interact",dir="Right"}, {2,8}},

-- 10: POKéFLUTE

	-- Lavender -> Celadon
	{4, {7,10}, {s="split"}, {s="fly",dest="celadon",map=6}},
	-- To Celadon Center
	{6, {41,10}, {41,9}},
	-- Celadon Center
	{133, {3,7}, {3,3}, {s="confirm",dir="Up"}, {3,8}},
	-- Leave Celadon
	{6, {41,10}, {s="a",a="Snorlax"}, {s="item",item="super_repel",chain=true}, {s="bicycle"}, {41,11}, {14,11}, {14,14}, {2,14}, {2,18}, {-1,18}},
	-- トトロだ！
	{27, {39,10}, {27,10}, {s="playPokeflute"}, {23,10}},
	-- Snorlax pass
	{186, {7,8}, {-1,8}},
	-- Bicycle road
	{27, {17,10}, {s="a",a="Bicycle Road"}, {12,10}, {12,13}, {11,13}, {11,18}},
	-- Forced down inputs
	{28, {11,0}, {11,5}, {15,5}, {15,12}, {s="drivebyRareCandy"}, {15,14}, {18,14}, {18,122}, {13,122}, {13,143}},
	-- Cycling road exit
	{29, {13,0}, {13,8}, {34,8}},
	-- Exit building
	{190, {0,4}, {8,4}},
	-- Enter Safari City
	{29, {40,8}, {s="item",item="super_repel",chain=true}, {s="teach",move="ice_beam",replace="rock_slide",chain=true}, {s="bicycle"}, {50,8}},
	-- Safari City
	{7, {0,16}, {s="a",a="Safari Zone"}, {3,16}, {3,20}, {23,20}, {23,14}, {29,14}, {29,15}, {35,15}, {35,8}, {37,8}, {37,2}, {22,2}, {22,4}, {18,4}, {18,3}},
	-- Safari entrance
	{156, {3,5}, {3,2}, {4,2}, {s="confirm",dir="Right"}},
	-- Safari 1
	{220, {15,25}, {s="bicycle"}, {15,16}, {28,16}, {28,11}, {30,11}},
	-- Safari 2
	{217, {0,23}, {4,23}, {4,24}, {20,24}, {20,20}, {s="safariCarbos"}, {12,20}, {12,22}, {11,22}, {10,22}, {s="item",item="super_repel",chain=true}, {s="item",item="carbos",poke="nidoking",close=true}, {9,22}, {9,8}, {12,8}, {12,6}, {17,6}, {17,8}, {20,8}, {s="centerSkipFullRestore"}, {20,3}, {7,3}, {7,5}, {-1,5}},
	-- Safari 3
	{218, {39,31}, {22,31}, {22,22}, {16,22}, {16,28}, {13,28}, {13,9}, {28,9}, {28,3}, {3,3}, {3,36}},
	-- Safari 4
	{219, {21,0}, {21,5}, {19,5}, {19,6}, {s="interact",dir="Down"}, {19,5}, {7,5}, {7,6}, {3,6}, {3,3}},
	-- Warden
	{222, {2,7}, {2,6}, {3,6}, {3,4}, {s="interact",dir="Up"}, {3,8}},
	-- Safari Warp
	{219, {3,4}, {s="skill",move="dig",map=219}},
	-- Celadon again
	{6, {41,10}, {s="bicycle"}, {41,11}, {50,11}},
	-- To Saffron
	{18, {0,3}, {s="a",a="Saffron City"}, {4,3}, {4,9}, {10,9}, {10,10}, {12,10}},
	-- Thirsty guard
	{76, {0,4}, {6,4}},
	-- Saffron entry
	{18, {18,10}, {s="bicycle"}, {20,10}},
	-- Saffron City
	{10, {0,18}, {3,18}, {3,22}, {18,22}, {18,21}},
	-- Silph Co
	{181, {10,17}, {s="a",a="Silph Co."}, {10,9}, {8,9}, {8,1}, {20,1}, {20,0}},
	-- Elivator
	{236, {1,3}, {1,2}, {3,2}, {3,1}, {s="silphElevator"}, {2,1}, {2,4}},
	-- F10
	{234, {12,1}, {12,3}, {4,3}, {4,9}, {s="fightSilphMachoke"}, {6,9}, {6,11}, {s="silphCarbos"}, {6,16}, {3,16}, {3,14}, {s="interact",dir="Right"}, {3,15}, {1,15}, {s="item",item="carbos",poke="nidoking",full=true}, {1,12}, {s="interact",dir="Right"}, {1,16}, {3,16}, {s="teach",move="surf",poke="squirtle",replace="tail_whip",chain=true}, {s="teach",move="earthquake",replace="thrash",chain=true}, {s="item",item="carbos",poke="nidoking",close=true}, {6,16}, {6,9}, {4,9}, {4,1}, {8,1}, {8,0}},
	-- F9
	{233, {14,1}, {14,3}, {24,3}, {24,16}, {17,16}, {17,15}},
	-- Warped
	{210, {9,15}, {9,16}, {20,16}, {s="interact",dir="Right"}, {9,16}, {9,15}},
	-- Warp back
	{233, {17,15}, {17,14}, {17,15}},
	-- First card
	{210, {9,15}, {9,13}, {8,13}, {s="interact",dir="Left"}, {6,13}, {6,16}, {3,16}, {3,15}},
	-- Warp down
	{208, {3,15}, {3,14}, {18,14}, {18,9}, {s="interact",dir="Left"}, {14,9}, {14,11}, {11,11}},
	-- Rival 5
	{212, {5,3}, {s="a",a="Silph Rival"}, {4,3}, {4,2}, {3,2}, {c="potion",b=false}, {s="silphRival"}, {3,7}, {c="potion",b=true,yolo=true}, {5,7}},
	-- Giovanni
	{235, {3,2}, {s="a",a="Silph Giovanni"}, {3,11}, {2,11}, {2,16}, {s="interact",dir="Right"}, {2,15}, {5,15}, {s="potion",hp=16,yolo=12}, {6,15}, {6,14}, {s="interact",dir="Up"}, {6,13}, {s="fightXAccuracy"}, {s="fightSilphGiovanni"}, {s="split"}, {s="waitToPause"}, {s="skill",move="dig",map=235}},

-- 11: SILPH CO.

	-- Fly to Fuschia
	{6, {41,10}, {s="fly",dest="fuchsia",map=7}},
	-- To Koga
	{7, {19,28}, {s="a",a="Koga's Gym"}, {5,28}, {5,27}},
	-- Koga
	-- TODO save turn frames?
	{157, {4,17}, {9,17}, {9,9}, {7,9}, {s="interact",dir="Up"}, {9,9}, {9,1}, {1,1}, {1,2}, {s="potion",hp="KogaHypno",yolo=18,chain=true}, {s="earthquakeElixer",min=2,close=true}, {1,3}, {2,3}, {2,5}, {1,5}, {c="potion",b=false}, {1,7}, {s="fightHypno"}, {1,9}, {2,9}, {s="earthquakeElixer",min=4}, {4,9}, {s="interact",dir="Down"}, {s="fightKoga"}, {s="split"}, {1,9}, {1,5}, {2,5}, {2,3}, {1,3}, {1,1}, {9,1}, {9,16}, {5,16}, {5,18}},

-- 12: KOGA

	-- To the Warden
	{7, {5,28}, {s="bicycle"}, {6,28}, {6,30}, {24,30}, {30,30}, {30,28}, {27,28}, {27,27}},
	-- HM04 Strength
	{155, {4,7}, {4,6}, {2,6}, {2,4}, {s="interact",dir="Up"}, {4,4}, {4,8}},
	-- Fly home
	{7, {27,28}, {s="fly",dest="pallet",map=0}},
	-- Pallet to Cinnabar
	{0, {5,6}, {s="item",item="super_repel",chain=true}, {s="item",item="rare_candy",amount=3,poke="nidoking",chain=true}, {s="bicycle"}, {s="allowDeath",on=false}, {3,6}, {s="dodgeGirl"}, {3,17}, {s="skill",move="surf",dir="Right",x=4}, {4,18}},
	-- To Cinnabar
	{32, {4,0}, {4,14}, {3,14}, {3,90}},
	-- Enter Cinnabar Mansion
	{8, {3,0}, {s="a",a="Cinnabar Mansion"}, {3,4}, {6,4}, {6,3}},
	-- F1
	{165, {5,27}, {5,10}},
	-- F2
	{214, {5,11}, {10,11}, {10,5}, {6,5}, {6,1}},
	-- F3
	{215, {6,2}, {11,2}, {11,6}, {10,6}, {s="confirm",dir="Up"}, {14,6}, {14,11}, {16,11}, {16,14}},
	-- F1 drop
	{165, {16,14}, {16,15}, {13,15}, {13,20}, {s="cinnabarCarbos"}, {21,23}},
	-- B1
	{216, {23,22}, {23,15}, {21,15}, {s="item",item="super_repel",chain=true}, {s="item",item="carbos",poke="nidoking",close=true}, {17,15}, {17,19}, {18,19}, {18,23}, {17,23}, {17,26}, {18,26}, {s="confirm",dir="Up"}, {14,26}, {14,22}, {12,22}, {12,15}, {24,15}, {24,18}, {26,18}, {26,6}, {24,6}, {24,4}, {20,4}, {s="confirm",dir="Up"}, {24,4}, {24,6}, {12,6}, {12,2}, {11,2}, {s="interact",dir="Left"}, {12,2}, {12,7}, {4,7}, {4,9}, {2,9}, {s="interact",dir="Left"}, {5,9}, {5,10}, {s="teach",move="strength",poke="squirtle",replace="tackle",chain=true}, {s="item",item="rare_candy",amount=2,poke="nidoking",close=true}, {5,12}, {s="interact",dir="Down"}, {5,12}, {s="skill",move="dig",map=216}},
	-- Celadon once again
	{6, {41,10}, {s="bicycle"}, {41,13}, {36,13}, {36,23}, {25,23}, {25,30}, {35,30}, {35,31}, {s="skill",move="cut",dir="Down",done=0x0D4D}, {35,34}, {5,34}, {5,29}, {12,29}, {12,27}},
	-- Erika
	{134, {4,17}, {s="a",a="Erika's Gym"}, {4,16}, {1,16}, {1,9}, {0,9}, {0,4}, {1,4}, {s="skill",move="cut",done=0x0D4D}, {4,4}, {s="interact",dir="Up"}, {s="fightErika"}, {s="split"}, {4,5}, {5,5}, {5,6}, {s="skill",move="cut",dir="Down",done=0x0D4D}, {5,18}},

-- 13: ERIKA

	-- Fly to Cinnabar
	{6, {12,28}, {s="fly",dest="cinnabar",map=8}},
	-- Cinnabar
	{8, {11,12}, {s="earthquakeElixer",min=4,chain=true}, {s="bicycle"}, {18,12}, {18,3}},
	-- Cinnabar Gym
	{166, {16,17}, {s="a",a="Blaine's Gym"}, {16,14}, {18,14}, {18,10}, {15,10}, {15,8}, {s="confirm",dir="Up"}, {16,8}, {16,7}, {18,7}, {18,1}, {12,1}, {12,2}, {10,2}, {s="confirm",dir="Up",type="B"}, {12,2}, {12,7}, {10,7}, {10,8}, {9,8}, {s="confirm",dir="Up",type="B"}, {9,11}, {12,11}, {12,13}, {10,13}, {10,14}, {9,14}, {s="confirm",dir="Up",type="B"}, {9,16}, {1,16}, {1,14}, {s="confirm",dir="Up"}, {2,14}, {2,13}, {4,13}, {4,9}, {1,9}, {1,8}, {s="confirm",dir="Up",type="B"}, {2,8}, {2,7}, {4,7}, {4,5}, {3,5}, {3,4}, {c="potion",b=false}, {s="waitToFight",dir="Up"}, {s="split"}, {s="waitToReceive"}, {s="skill",move="dig",map=166}},

-- 14: BLAINE

	-- Celadon too many times
	{6, {41,10}, {c="potion",b=true,yolo=true}, {s="bicycle"}, {41,11}, {50,11}},
	-- Exit Celadon
	{18, {0,3}, {4,3}, {4,9}, {10,9}, {10,10}, {12,10}},
	-- Saffron gate
	{76, {0,4}, {s="a",a="Saffron City"}, {6,4}},
	-- Saffron edge
	{18, {18,10}, {s="earthquakeElixer",min=4,chain=true}, {s="bicycle"}, {20,10}},
	-- Saffron again
	{10, {0,18}, {3,18}, {3,6}, {31,6}, {31,4}, {34,4}, {34,3}},
	-- Sabrina
	{178, {8,17}, {s="a",a="Sabrina's Gym"}, {8,16}, {11,16}, {11,15}, {16,17}, {16,15}, {15,15}, {18,3}, {18,5}, {15,5}, {1,5}, {11,11}, {11,8}, {10,8}, {s="waitToFight",dir="Left"}, {s="split"}, {11,8}, {11,11}, {s="earthquakeElixer",min=4,chain=true}, {s="skill",move="dig",map=178}},

-- 15: SABRINA

	-- Celadon
	{6, {41,10}, {s="fly",dest="viridian",map=1}},
	-- Viridian again
	{1, {23,26}, {s="bicycle"}, {19,26}, {19,4}, {27,4}, {27,3}, {34,3}, {34,8}, {32,8}, {32,7}},
	-- Giovanni Gym
	{45, {16,17}, {c="potion",b=false}, {s="a",a="Giovanni's Gym"}, {16,16}, {14,16}, {14,9}, {13,9}, {13,7}, {15,7}, {15,4}, {12,4}, {12,5}, {10,5}, {s="a",a="Machoke"}, {10,4}, {s="fightGiovanniMachoke"}, {10,5}, {s="a",a="Giovanni's Gym"}, {13,5}, {13,4}, {15,4}, {15,7}, {13,7}, {13,11}, {14,11}, {14,16}, {16,16}, {16,18}},
	-- Reset Gym
	{1, {32,8}, {32,7}},
	-- Giovanni
	{45, {16,17}, {c="potion",b=false}, {16,16}, {14,16}, {14,9}, {13,9}, {13,7}, {15,7}, {15,4}, {12,4}, {12,5}, {10,5}, {10,2}, {7,2}, {7,4}, {2,4}, {s="checkGiovanni"}, {2,2}, {s="interact",dir="Up"}, {s="fightGiovanni"}, {s="split"}, {2,4}, {7,4}, {7,2}, {10,2}, {10,5}, {12,5}, {12,4}, {15,4}, {15,7}, {13,7}, {13,11}, {14,11}, {14,16}, {16,16}, {16,18}},

-- 16: GIOVANNI

	-- Leave Viridian
	{1, {32,8}, {s="bicycle"}, {32,12}, {17,12}, {17,16}, {16,16}, {16,17}, {-1,17}},
	-- To Pokemon League
	{33, {39,9}, {s="a",a="Viridian Rival"}, {35,9}, {35,12}, {31,12}, {31,5}, {29,5}, {s="viridianRival"}, {16,5}, {16,12}, {5,12}, {5,10}, {11,10}, {11,6}, {8,6}, {8,5}},
	-- Pokemon League 1
	{193, {4,7}, {4,0}},
	-- PL 2
	{34, {7,139}, {s="ether",max=true,chain=true}, {s="bicycle"}, {7,132}, {14,132}, {14,124}, {9,124}, {9,116}, {10,116}, {10,104}, {s="skill",move="surf",y=103}, {10,92}, {7,92}, {7,90}, {s="pickMaxEther"}, {7,72}, {8,72}, {8,71}, {s="item",item="super_repel",chain=true}, {s="bicycle"}, {8,66}, {10,66}, {10,57}, {12,57}, {12,48}, {6,48}, {6,32}, {4,32}, {4,31}},
	-- Victory Road
	{108, {8,17}, {s="a",a="Victory Road"}, {s="tweetVictoryRoad"}, {8,16}, {4,16}, {4,14}, {5,14}, {s="skill",move="strength"}, {5,15}, {4,15}, {4,16}, {7,16}, {s="push",dir="Right",x=0x0255,y=0x0254}, {7,17}, {9,17}, {9,15}, {8,15}, {8,14}, {15,14}, {15,15}, {16,15}, {16,14}, {s="push",dir="Up",x=0x0255,y=0x0254}, {14,14}, {14,12}, {16,12}, {16,11}, {17,11}, {17,12}, {14,12}, {14,14}, {8,14}, {8,16}, {5,16}, {5,12}, {11,12}, {11,6}, {7,6}, {7,8}, {3,8}, {3,5}, {2,5}, {2,1}, {1,1}},
	-- F2
	{194, {0,8}, {0,9}, {3,9}, {3,13}, {5,13}, {5,14}, {s="item",item="super_repel",chain=true}, {s="skill",move="strength"}, {4,14}, {4,13}, {3,13}, {3,15}, {4,15}, {4,16}, {3,16}, {s="push",dir="Left",x=0x02B5,y=0x02B4}, {3,11}, {5,11}, {5,8}, {14,8}, {14,14}, {21,14}, {21,16}, {28,16}, {28,11}, {23,11}, {23,7}},
	-- F3
	{198, {23,7}, {23,6}, {22,6}, {22,4}, {s="skill",move="strength"}, {22,2}, {23,2}, {23,1}, {7,1}, {7,0}, {6,0}, {6,1}, {7,1}, {7,2}, {3,2}, {3,1}, {2,1}, {2,4}, {1,4}, {1,5}, {2,5}, {2,4}, {4,4}, {4,2}, {7,2}, {7,1}, {20,1}, {20,6}, {17,6}, {17,4}, {9,4}, {9,10}, {5,10}, {5,8}, {1,8}, {1,15}, {11,15}, {11,16}, {20,16}, {20,15}, {23,15}},
	-- F2
	{194, {22,16}, {s="healBeforeLorelei"}, {s="item",item="super_repel",chain=true}, {s="skill",move="strength"}, {s="bicycle"}, {22,17}, {24,17}, {24,16}, {11,16}, {s="push",dir="Left",x=0x02D5,y=0x02D4}, {21,16}, {21,14}, {25,14}},
	-- F3
	{198, {27,15}, {27,8}, {26,8}},
	-- F2 Exit
	{194, {27,7}, {30,7}},
	-- Victory end
	{34, {14,32}, {18,32}, {18,20}, {14,20}, {14,10}, {13,10}, {13,6}, {10,6}, {10,-1}},
	-- Elite Four entrance
	{9, {10,17}, {s="a",a="Elite Four"}, {10,5}},
	-- Last Center
	{174, {7,11}, {15,9}, {15,8}, {s="depositPokemon"}, {7,8}, {7,7}, {s="centerSkip"}, {4,7}, {3,7}, {3,2}, {8,2}, {8,0}},

-- 17: LORELEI

	{245, {4,5}, {s="a",a="Lorelei"}, {c="potion",b=false}, {4,2}, {s="interact",dir="Right"}, {s="lorelei"}, {s="split"}, {4,0}},

	{246, {4,5}, {s="a",a="Bruno"}, {s="item",item="elixer",poke="nidoking"}, {4,2}, {s="interact",dir="Right"}, {s="bruno"}, {s="split"}, {4,0}},

	{247, {4,5}, {s="a",a="Agatha"}, {s="potion",hp=113,full=true}, {4,2}, {s="interact",dir="Right"}, {s="agatha"}, {s="split"}, {4,1}, {s="prepareForLance"}, {s="ether"}, {4,0}},

	{113, {6,11}, {s="a",a="Lance"}, {6,2}, {s="lance"}, {s="waitToFight"}, {s="split"}, {5,2}, {5,1}, {s="prepareForBlue"}, {5,-1}},

	{120, {4,3}, {s="a",a="Blue"}, {s="blue"}, {3,0}},

	{118, {4,2}, {s="champion"}}
}

return paths
