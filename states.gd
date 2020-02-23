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
	SOLS.GO: "Continuer à avancer",
	SOLS.REST: "Faire une pause",
	SOLS.REST_PLUS: "Utiliser le réchaud pour se réchauffer",
	SOLS.ATTACK_GUN: "Tirer sur la créature",
	SOLS.ATTACK_KNIFE: "Attaquer la créature avec le couteau",
	SOLS.ATTACK_OTHER: "Frapper la créature avec un outil",
	SOLS.CLIMB: "Essayer d'escalader",
	SOLS.CUT: "C'est trop risqué. Couper la corde",
	SOLS.PULL: "Tirer sur la corde pour essayer de le remonter",
	SOLS.DIG_UP: "Pelleter la neige pour essayer de le sortir de là",
	SOLS.DIG: "Chercher des objets avec la pelle",
	SOLS.GO_AROUND: "La contourner",
	SOLS.JUMP: "Essayer de sauter par-dessus la crevasse",
	SOLS.ABANDON: "Abandonner un compagnon pour distraire la créature",
	SOLS.HELP: "Tirer en l'air en espérant que quelqu'un vous entende",
	SOLS.WIN: "Remettre le message"
}

var outcomes_descr = {
	SOLS.REST_PLUS: [
		"La chaleur du réchaud vous détend et vous aide à vous reposer."
	],
	SOLS.ATTACK_GUN: [
		"Le coup de feu est assourdissant. La créature s'effondre.",
		"Le coup de feu est assourdissant. Vous avez manqué votre coup, la créature bondit et dévore l'un de vos malheureux compagnons. Vous prenez vos jambes à votre cou."
	],
	SOLS.ATTACK_KNIFE: [
		"Vous tuez la créature avec le couteau.",
		"Vous essayez de tuer la créature avec le couteau mais elle est plus forte."
	],
	SOLS.ATTACK_OTHER: [
		"Vous frappez la créature avec votre outil.",
		"Vous essayez d'attaquer la créature avec votre outil mais elle est plus forte."
	],
	SOLS.CLIMB: [
		"Vous escaladez la paroi.",
		"Vous essayez d'escaladez la paroi mais vous manquez une prise et chutez."
	],
	SOLS.CUT: [
		"Vous avez coupé la corde, oups."
	],
	SOLS.PULL: [
		"Vous tirez sur la corde et arrivez à le remonter.",
		"Vous tirez sur la corde pour essayer de le remonter mais c'est trop difficile."
	],
	SOLS.DIG_UP: [
		"Après plusieurs heures passées à chercher et creuser, vous retrouvez votre compagnon",
		"Aprés plusieurs heures passées à chercher et creuser, vous n'arrivez pas à retrouver votre compagnon."
	],
	SOLS.DIG: [
		"Après avoir creusé, vous trouvez un outil dans le campement abandonné.",
		"Vous n'avez rien trouvé."
	],
	SOLS.GO_AROUND: [
		"Vous décidez de contourner la crevasse et perdez du temps."	
	],
	SOLS.JUMP: [
		"Vous passez la crevasse en sautant par dessus.",
		"Un camarade glisse et chute à sa mort lors de son saut."
	],
	SOLS.ABANDON: [
		"Vous faites le choix difficile d'abandonner un compagnon à la merci de la créature. Cette distraction vous permet de vous enfuir."	
	]
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
			true: EVENTS.DELAY_LONG
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
			false: EVENTS.DELAY_LONG,
			true: EVENTS.DELAY
		},
		SOLS.GO: {
			false: EVENTS.FALL,
			true: EVENTS.DELAY_LONG
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

var sols_dialogue = {
	EVENTS.NO: {
		SOLS.REST: {
			false: "Je n'arrive pas à dormir...",
			true: "Cette pause était nécessaire."
		},
		SOLS.REST_PLUS: {
			false: "Ce réchaud faiblit; je n'arrive pas à me réchauffer.",
			true: "Quel bonheur d'avoir un peu de chaleur dans cet enfer enneigé."
		},
		SOLS.GO: {
			false: null,
			true: "Continuons."
		},
		SOLS.HELP: {
			false: "Personne n'a entendu...",
			true: "J'entends des gens!'"
		},
		SOLS.WIN: {
			false: null,
			true: "Je suis sauvé!"
		}
	},
	EVENTS.AVALANCHE: {
		SOLS.DIG_UP: {
			false: "Je ne le trouve pas!",
			true: "Quelle chance que nous avions cette pelle."
		},
		SOLS.GO: {
			false: null,
			true: "Il est condamné. Nous ne pouvons pas perdre plus de temps.",
		}
	},
	EVENTS.HOLE: {
		SOLS.JUMP: {
			false: "C'était une terrible erreur.",
			true: "Ceci aurait pu finir très mal."
		},
		SOLS.GO_AROUND: {
			false: null,
			true: "Nous avons perdu du temps, mais nous n'avions pas le choix."
		}
	},
	EVENTS.FALL: {
		SOLS.CUT: {
			false: null,
			true: "Jamais je ne me pardonnerai ceci."
		},
		SOLS.CLIMB: {
			false: "Il n'a rien laché, mais c'était trop dur.",
			true: "Ce n'est pas passé loin."
		},
		SOLS.PULL: {
			false: "Nous avons tout essayé...",
			true: "Je ne pensais pas pouvoir le rattraper."
		}
	},
	EVENTS.STORM: {
		SOLS.REST: {
			false: "Cette tempête était interminable.",
			true: "Le vent se calme. Nous pouvons continuer."
		},
		SOLS.GO: {
			false: "Nous ne pouvions rien voir dans cette tempête.",
			true: "Nous sommes enfin sortis."
		}
	},
	EVENTS.BEAST: {
		SOLS.ATTACK_GUN: {
			false: "Comment avons-nous pu le rater?",
			true: "HAAA! Prends ça!"
		},
		SOLS.ATTACK_KNIFE: {
			false: "Il m'a presque dévoré.",
			true: "Ce couteau m'a sauvé la vie."
		},
		SOLS.ATTACK_OTHER: {
			false: "Ce n'est vraiment pas une arme pratique.",
			true: "Je n'arrive pas à croire que ça a marché."
		},
		SOLS.ABANDON: {
			false: null,
			true: "Je ne peux pas regarder..."
		}
	},
	EVENTS.CAMP: {
		SOLS.DIG: {
			false: "Pas de chance cette fois.",
			true: "J'ai trouvé quelque chose!"
		},
		SOLS.REST: {
			false: "Je n'arrive pas à dormir...",
			true: "Cette pause était nécessaire."
		},
		SOLS.REST_PLUS: {
			false: "Ce réchaud faiblit; je n'arrive pas à me réchauffer.",
			true: "Quel bonheur d'avoir un peu de chaleur dans cet enfer enneigé."
		},
		SOLS.GO: {
			false: null,
			true: "Continuons."
		}
	},
	EVENTS.SHORTCUT: {
		SOLS.GO: {
			false: "C'était plus difficile que j'imaginais",
			true: "Regardez l'avance qu'on a pris!"
		},
		SOLS.GO_AROUND: {
			false: null,
			true: "Ce n'est pas le moment de prendre des risques qui pourraient nous coûter.",
		}
	},
}
