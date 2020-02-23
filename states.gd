extends Node

enum EVENTS {
	NO = -1,
	AVALANCHE, # 0
	HOLE, # 1
	FALL, # 2
	STORM, # 3
	BEAST, # 4
	CAMP, # 5
	SHORTCUT, # 6
	GET_OBJ, # 7
	WIN, # 8
	ANY, # 9
	REST, # 10
	REST_PLUS, # 11
	KILL, # 12
	HARM, # 13
	DELAY, # 14
	DELAY_LONG, # 15
	GAIN_TIME, # 16
	ADD_FATIGUE, # 17
	PICKUP_ITEM, # 18
}

var events_probas = {
	EVENTS.NO: 15,
	EVENTS.AVALANCHE: 2,
	EVENTS.HOLE: 5,
	EVENTS.FALL: 10,
	EVENTS.STORM: 2,
	EVENTS.BEAST: 10,
	EVENTS.CAMP: 2,
	EVENTS.SHORTCUT: 8,
	EVENTS.WIN: 0,
	EVENTS.ANY: 0,
	EVENTS.HARM: 0,
	EVENTS.KILL: 0
}

enum SOLS {
	GO = -1,
	REST,
	REST_PLUS,
	ATTACK_GUN,
	ATTACK_KNIFE,
	ATTACK_OTHER,
	CLIMB,
	CUT,
	PULL,
	DIG_UP,
	DIG,
	GO_AROUND,
	JUMP,
	ABANDON,
	WIN,
	HELP
}

enum ITEMS {
	GUN,
	KNIFE,
	PICK,
	SHOVEL,
	FURNACE
}

var items_descr = {
	ITEMS.GUN: "pistolet",
	ITEMS.KNIFE: "couteau",
	ITEMS.PICK: "piolet",
	ITEMS.SHOVEL: "pelle",
	ITEMS.FURNACE: "réchaud"
}

var event_descr = {
	EVENTS.AVALANCHE: ["Avalanche", "Une avalanche vous tombe dessus"],
	EVENTS.HOLE: ["Crevasse", "Vous arrivez à une crevasse"],
	EVENTS.FALL: ["Chute", "Quelqu'un est tombé"],
	EVENTS.STORM: ["Tempête", "Il y a une tempête"],
	EVENTS.BEAST: ["Créature", "Une créature vous attaque"],
	EVENTS.CAMP: ["Camp abandonné", "Vous arrivez à un camp abandonné"],
	EVENTS.SHORTCUT: ["Raccourci", "Vous voyez un raccourci"],
}

var sol_descr = {
	SOLS.GO: "Continuer à marcher",
	SOLS.REST: "Faire une pause",
	SOLS.REST_PLUS: "Se réchauffer à la chaleur du réchaud",
	SOLS.ATTACK_GUN: "Tirer sur la créature",
	SOLS.ATTACK_KNIFE: "Attaquer la créature avec le couteau",
	SOLS.ATTACK_OTHER: "Frapper la créature avec un outil",
	SOLS.CLIMB: "Essayer d'escalader",
	SOLS.CUT: "C'est trop risqué. Couper la corde",
	SOLS.PULL: "Essayer de le tirer",
	SOLS.DIG_UP: "Pelleter la neige pour essayer de le sortir de là",
	SOLS.DIG: "Chercher des objets avec votre pelle",
	SOLS.GO_AROUND: "La contourner",
	SOLS.JUMP: "Essayer de sauter par-dessus la crevasse",
	SOLS.ABANDON: "Abandonner un compagnon pour distraire la créature",
	SOLS.HELP: "Tirer en l'air en espérant que quelqu'un vous entende",
	SOLS.WIN: "Remettre le message"
}

var reqs = {
	SOLS.GO: [],
	SOLS.REST: [],
	SOLS.REST_PLUS: [ITEMS.FURNACE],
	SOLS.ATTACK_GUN: [ITEMS.GUN],
	SOLS.ATTACK_KNIFE: [ITEMS.KNIFE],
	SOLS.ATTACK_OTHER: [ITEMS.PICK, ITEMS.SHOVEL],
	SOLS.CLIMB: [ITEMS.PICK],
	SOLS.CUT: [ITEMS.KNIFE],
	SOLS.PULL: [],
	SOLS.DIG_UP: [ITEMS.SHOVEL],
	SOLS.DIG: [ITEMS.SHOVEL],
	SOLS.GO_AROUND: [],
	SOLS.JUMP: [],
	SOLS.ABANDON: [],
	SOLS.HELP: [ITEMS.GUN]
}

var sol_probas = {
	EVENTS.NO: {
		SOLS.REST: 100,
		SOLS.REST_PLUS: 100,
		SOLS.GO: 100
	},
	EVENTS.AVALANCHE: {
		SOLS.DIG_UP: 50,
		SOLS.GO: 100
	},
	EVENTS.HOLE: {
		SOLS.JUMP: 50,
		SOLS.GO_AROUND: 75
	},
	EVENTS.FALL: {
		SOLS.CUT: 100,
		SOLS.CLIMB: 50,
		SOLS.PULL: 50
	},
	EVENTS.STORM: {
		SOLS.REST: 75,
		SOLS.GO: 50
	},
	EVENTS.BEAST: {
		SOLS.ATTACK_GUN: 100,
		SOLS.ATTACK_KNIFE: 50,
		SOLS.ATTACK_OTHER: 25,
		SOLS.ABANDON: 100
	},
	EVENTS.CAMP: {
		SOLS.DIG: 50,
		SOLS.REST: 75,
		SOLS.GO: 100,
	},
	EVENTS.SHORTCUT: {
		SOLS.GO: 100,
		SOLS.GO_AROUND: 50
	},
}

var sol_outcomes = {
	EVENTS.NO: {
		SOLS.REST: {
			false: EVENTS.NO,
			true: EVENTS.REST
		},
		SOLS.REST_PLUS: {
			false: EVENTS.NO,
			true: EVENTS.REST_PLUS
		},
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		},
		SOLS.HELP: {
			false: EVENTS.NO,
			true: EVENTS.WIN
		},
		SOLS.WIN: {
			false: EVENTS.NO,
			true: EVENTS.WIN
		}
	},
	EVENTS.AVALANCHE: {
		SOLS.DIG_UP: {
			false: EVENTS.KILL,
			true: EVENTS.NO
		},
		SOLS.GO: {
			false: EVENTS.KILL,
			true: EVENTS.KILL,
		}
	},
	EVENTS.HOLE: {
		SOLS.JUMP: {
			false: EVENTS.KILL,
			true: EVENTS.ADD_FATIGUE
		},
		SOLS.GO_AROUND: {
			false: EVENTS.DELAY,
			true: EVENTS.DELAY
		}
	},
	EVENTS.FALL: {
		SOLS.CUT: {
			false: EVENTS.KILL,
			true: EVENTS.KILL
		},
		SOLS.CLIMB: {
			false: EVENTS.KILL,
			true: EVENTS.NO
		},
		SOLS.PULL: {
			false: EVENTS.KILL,
			true: EVENTS.ADD_FATIGUE
		}
	},
	EVENTS.STORM: {
		SOLS.REST: {
			false: EVENTS.KILL,
			true: EVENTS.DELAY_LONG
		},
		SOLS.GO: {
			false: EVENTS.FALL,
			true: EVENTS.DELAY
		}
	},
	EVENTS.BEAST: {
		SOLS.ATTACK_GUN: {
			false: EVENTS.KILL,
			true: EVENTS.NO
		},
		SOLS.ATTACK_KNIFE: {
			false: EVENTS.HARM,
			true: EVENTS.NO
		},
		SOLS.ATTACK_OTHER: {
			false: EVENTS.HARM,
			true: EVENTS.NO
		},
		SOLS.ABANDON: {
			false: EVENTS.NO,
			true: EVENTS.KILL
		}
	},
	EVENTS.CAMP: {
		SOLS.DIG: {
			false: EVENTS.NO,
			true: EVENTS.PICKUP_ITEM
		},
		SOLS.REST: {
			false: EVENTS.NO,
			true: EVENTS.REST
		},
		SOLS.REST_PLUS: {
			false: EVENTS.NO,
			true: EVENTS.REST_PLUS
		},
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		}
	},
	EVENTS.SHORTCUT: {
		SOLS.GO: {
			false: EVENTS.FALL,
			true: EVENTS.GAIN_TIME
		},
		SOLS.GO_AROUND: {
			false: EVENTS.DELAY,
			true: EVENTS.DELAY,
		}
	},
}

func next(state, solution, items):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
