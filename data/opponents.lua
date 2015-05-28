local Opponents = {

	ShortsRattata = {
		type2 = "normal",
		type1 = "normal",
		def = 14,
		id = 165,
		spec = 12,
		hp = 29,
		speed = 22,
		level = 11,
		att = 19,

		moves = {
			{
				name = "Quick-Attack",
				accuracy = 100,
				max_pp = 30,
				power = 40,
				id = 98,
				special = false,
				outspeed = true,
				move_type = "normal",
			},
		},
	},

	ErikaTangela = {
		type2 = "grass",
		type1 = "grass",
		def = 78,
		id = 30,
		spec = 69,
		hp = 83,
		speed = 45,
		level = 30,
		att = 43,

		moves = {
			{
				name = "Mega-Drain",
				accuracy = 100,
				power = 40,
				id = 72,
				special = true,
				max_pp = 10,
				move_type = "grass",
			},
		},
	},

	RivalGyarados = {
		type1 = "water",
		type2 = "flying",
		def = 71,
		id = 22,
		spec = 87,
		hp = 126,
		speed = 72,
		level = 38,
		att = 106,
		moves = {
			{
				name = "Hydro-Pump",
				accuracy = 80,
				power = 120,
				id = 56,
				special = true,
				max_pp = 5,
				move_type = "water",
			},
		},
		boost = {
			stat = "spec",
			mp = 1.5
		},
	},

	HypnoHeadbutt = {
		type1 = "psychic",
		type2 = "psychic",
		def = 58,
		id = 129,
		spec = 88,
		hp = 107,
		speed = 56,
		level = 34,
		att = 60,
		moves = {
			{
				name = "Headbutt",
				accuracy = 100,
				power = 70,
				id = 29,
				special = false,
				max_pp = 15,
				move_type = "normal",
			}
		},
	},

	HypnoConfusion = {
		type1 = "psychic",
		type2 = "psychic",
		def = 58,
		id = 129,
		spec = 88,
		hp = 107,
		speed = 56,
		level = 34,
		att = 60,
		moves = {
			{
				name = "Confusion",
				accuracy = 100,
				power = 50,
				id = 93,
				special = true,
				max_pp = 25,
				move_type = "psychic",
			},
		},
	},

	KogaWeezing = {
		type1 = "poison",
		type2 = "poison",
		def = 115,
		id = 143,
		spec = 84,
		hp = 115,
		speed = 63,
		level = 43,
		att = 90,
		moves = {
			{
				name = "Self-Destruct",
				accuracy = 100,
				power = 260,
				id = 120,
				special = false,
				max_pp = 5,
				move_type = "normal",
			},
		},
	},

	GiovanniRhyhorn = {
		type1 = "ground",
		type2 = "rock",
		def = 97,
		id = 18,
		spec = 39,
		hp = 134,
		speed = 34,
		level = 45,
		att = 89,
		moves = {
			{
				name = "Stomp",
				move_type = "normal",
				accuracy = 100,
				power = 65,
				id = 23,
				special = false,
				max_pp = 20,
				damage = 21,
			},
		},
	},

	LoreleiDewgong = {
		type1 = "water",
		type2 = "ice",
		def = 100,
		id = 120,
		spec = 116,
		hp = 169,
		speed = 89,
		level = 54,
		att = 90,
		moves = {
			{
				name = "Aurora-Beam",
				accuracy = 100,
				power = 65,
				id = 62,
				special = true,
				max_pp = 20,
				move_type = "ice",
			},
		},
		boost = {
			stat = "spec",
			mp = 2 / 3
		},
	},

	LanceGyarados = {
		type1 = "water",
		type2 = "flying",
		def = 105,
		id = 22,
		spec = 130,
		hp = 187,
		speed = 108,
		level = 58,
		att = 160,
		moves = {
			{
				name = "Hydro-Pump",
				accuracy = 80,
				power = 120,
				id = 56,
				special = true,
				max_pp = 5,
				move_type = "water",
			},
		},
		boost = {
			stat = "spec",
			mp = 1.5
		},
	},

	BluePidgeot = {
		type1 = "normal",
		type2 = "flying",
		def = 106,
		id = 151,
		spec = 100,
		hp = 182,
		speed = 125,
		level = 61,
		att = 113,
		moves = {
			{
				name = "Wing-Attack",
				accuracy = 100,
				power = 35,
				id = 17,
				special = false,
				max_pp = 35,
				move_type = "flying",
			},
		},
	},

	BlueSky = {
		type1 = "normal",
		type2 = "flying",
		def = 106,
		id = 151,
		spec = 100,
		hp = 182,
		speed = 125,
		level = 61,
		att = 113,
		moves = {
			{
				name = "Sky-Attack",
				accuracy = 90,
				power = 140,
				id = 143,
				special = false,
				max_pp = 5,
				move_type = "flying",
			},
		},
	},

-- YELLOW

	BlaineNinetails = {
		type1 = "fire",
		type2 = "fire",
		def = 84,
		id = 83,
		spec = 108,
		hp = 135,
		speed = 108,
		level = 48,
		att = 86,

		moves = {
			{
				accuracy = 100,
				name = "Flamethrower",
				power = 95,
				id = 53,
				special = true,
				max_pp = 15,
				move_type = "fire",
			},
		},
	},

	GarySandslash = {
		type1 = "ground",
		type2 = "ground",
		def = 148,
		id = 97,
		spec = 81,
		hp = 172,
		speed = 94,
		level = 61,
		att = 137,
		moves = {
			{
				max_pp = 10,
				accuracy = 100,
				name = "Earthquake",
				power = 100,
				id = 89,
				special = false,
				pp = 6,
				move_type = "ground",
			},
		},
		boost = {
			stat = "def",
			mp = 9 / 8
		},
	},

}

return Opponents
