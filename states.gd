extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum EVENTS {
	NO = -1,
	AVALANCHE,
	HOLE,
	FALL,
	STORM,
	BEAST,
	CAMP,
	SHORTCUT,
	GET_OBJ,
	WIN,
	ANY
}

var events_probas = {
	EVENTS.NO: 30,
	EVENTS.AVALANCHE: 2,
	EVENTS.HOLE: 2,
	EVENTS.FALL: 2,
	EVENTS.STORM: 2,
	EVENTS.BEAST: 2,
	EVENTS.CAMP: 2,
	EVENTS.SHORTCUT: 2,
	EVENTS.GET_OBJ: 2,
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

var event_descr = {
	EVENTS.NO: "NO",
	EVENTS.AVALANCHE: "AVALANCHE",
	EVENTS.HOLE: "HOLE",
	EVENTS.FALL: "FALL",
	EVENTS.STORM: "STORM",
	EVENTS.BEAST: "BEAST",
	EVENTS.CAMP: "CAMP",
	EVENTS.SHORTCUT: "SHORTCUT",
	EVENTS.GET_OBJ: "GET_OBJ",
	EVENTS.WIN: "WIN",
	EVENTS.ANY: "ANY",
	EVENTS.HARM: "HARM",
	EVENTS.KILL: "KILL"
}

var sol_descr = {
	SOLS.GO: "Keep going.",
	SOLS.REST: "Take a break.",
	SOLS.REST_PLUS: "Use the heat of your furnace to get warm.",
	SOLS.ATTACK_GUN: "Shoot the damn creature.",
	SOLS.ATTACK_KNIFE: "Try and stab the thing.",
	SOLS.ATTACK_OTHER: "Bash it with your tools.",
	SOLS.CLIMB: "Attempt to climb your way back up.",
	SOLS.CUT: "It's too risky, cut him loose.",
	SOLS.PULL: "Pull him back up.",
	SOLS.DIG_UP: "Try to dig your friend back up.",
	SOLS.DIG: "Look for loot with your shovel.",
	SOLS.GO_AROUND: "Go around to avoid it.",
	SOLS.JUMP: "Attempt to jump the chasm.",
	SOLS.ABANDON: "Leave your mate as a distraction for the beast.",
	SOLS.HELP: "Fire a shot in the air and hope they hear you."
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
		SOLS.REST: 50,
		SOLS.REST_PLUS: 75,
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
	}
}

var sol_outcomes = {
	EVENTS.NO: {
		SOLS.REST: {
			false: EVENTS.NO,
			true: EVENTS.NO
		},
		SOLS.REST_PLUS: {
			false: EVENTS.NO,
			true: EVENTS.NO
		},
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.ANY
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
			false: EVENTS.AVALANCHE,
			true: EVENTS.NO
		},
		SOLS.GO: {
			false: EVENTS.KILL,
			true: EVENTS.NO
		}
	},
	EVENTS.HOLE: {
		SOLS.JUMP: {
			false: EVENTS.FALL,
			true: EVENTS.NO
		},
		SOLS.GO_AROUND: {
			false: EVENTS.FALL,
			true: EVENTS.NO
		}
	},
	EVENTS.FALL: {
		SOLS.CUT: {
			false: EVENTS.KILL,
			true: EVENTS.KILL
		},
		SOLS.CLIMB: {
			false: EVENTS.FALL,
			true: EVENTS.NO
		},
		SOLS.PULL: {
			false: EVENTS.FALL,
			true: EVENTS.NO
		}
	},
	EVENTS.STORM: {
		SOLS.REST: {
			false: EVENTS.STORM,
			true: EVENTS.NO
		},
		SOLS.GO: {
			false: EVENTS.FALL,
			true: EVENTS.NO
		}
	},
	EVENTS.BEAST: {
		SOLS.ATTACK_GUN: {
			false: EVENTS.NO,
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
			false: EVENTS.KILL,
			true: EVENTS.NO
		}
	},
	EVENTS.CAMP: {
		SOLS.DIG: {
			false: EVENTS.CAMP,
			true: EVENTS.CAMP
		},
		SOLS.REST: {
			false: EVENTS.CAMP,
			true: EVENTS.CAMP
		},
		SOLS.REST_PLUS: {
			false: EVENTS.CAMP,
			true: EVENTS.CAMP
		},
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		}
	},
	EVENTS.SHORTCUT: {
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		},
		SOLS.GO_AROUND: {
			false: EVENTS.FALL,
			true: EVENTS.NO,
		}
	},
	EVENTS.HARM: {
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		}
	},
	EVENTS.KILL: {
		SOLS.GO: {
			false: EVENTS.NO,
			true: EVENTS.NO
		}
	}
}



func next(state, solution, items):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
