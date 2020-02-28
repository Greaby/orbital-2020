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
	EVENTS.CAMP: 0,
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
	EVENTS.NO: [
		"Repère",
		"Vous avez atteint un endroit abrité qui serait propice pour vous arrêter."
	],
	EVENTS.AVALANCHE: [
		"Avalanche",
		"Vous entendez un grondement sourd et avez à peine le temps de crier \"Avalanche!\" que la neige s'abat sur vous. Vous vous en êtes sorti mais une personne du groupe a disparu."
	],
	EVENTS.HOLE: [
		"Obstacle",
		"Vous arrivez au bord d'une crevasse de plusieurs mètres de large. Vous pouvez essayer de sauter par-dessus, mais c'est risqué."
	],
	EVENTS.FALL: [
		"Chute",
		"Vous entendez un cri au même moment que vous sentez une tension dans la corde. Une personne du groupe est tombée! "
	],
	EVENTS.STORM: [
		"Tempête",
		"Le vent se fait plus fort, le froid se fait plus mordant, la neige vous aveugle. Une tempête se lève, il serait risqué de continuer."
	],
	EVENTS.BEAST: [
		"La mort qui rôde",
		"Votre sang ne fait qu'un tour au moment où vous entendez le cri d'une bête sauvage. Elle se trouve juste devant vous!"
	],
	EVENTS.CAMP: [
		"Camp abandonné",
		"TODO"
	],
	EVENTS.SHORTCUT: [
		"Raccourci?",
		"Vous pensez pouvoir traverser le long d'une corniche pour gagner du temps. Elle n'est pas très large et quelqu'un risquerait de tomber."
	],
}

var sol_descr = {
	SOLS.GO: "Continuer à avancer",
	SOLS.REST: "Faire une pause",
	SOLS.REST_PLUS: "Utiliser le réchaud pour se réchauffer",
	SOLS.ATTACK_GUN: "Essayer de tirer sur la créature",
	SOLS.ATTACK_KNIFE: "Essayer d'attaquer la créature avec le couteau",
	SOLS.ATTACK_OTHER: "Essayer de frapper la créature avec un outil",
	SOLS.CLIMB: "Essayer d'escalader",
	SOLS.CUT: "C'est trop risqué. Couper la corde",
	SOLS.PULL: "Tirer sur la corde pour essayer de remonter la personne",
	SOLS.DIG_UP: "Pelleter la neige pour essayer de le retrouver",
	SOLS.DIG: "Chercher des objets avec la pelle",
	SOLS.GO_AROUND: "Faire un détour",
	SOLS.JUMP: "Essayer de sauter par-dessus la crevasse",
	SOLS.ABANDON: "Sacrifier une personne pour distraire la créature",
	SOLS.HELP: "Tirer en l'air en espérant que quelqu'un vous entende",
	SOLS.WIN: "Remettre le message"
}

var outcomes_descr = {
	SOLS.REST_PLUS: [
		"La chaleur du réchaud est réconfortante et vous aide à vous reposer."
	],
	SOLS.ATTACK_GUN: [
		"Vous appuyez sur la détente. Le coup de feu vous assourdit. Vous voyez la créature bondir et fuir.",
		"Vous appuyez sur la détente. Le coup de feu aurait probablement fait fuir l'animal s'il n'avait pas été aussi affamé. Il vous bondit dessus et vous arrache la gorge. Vous essayez de crier à l'aide mais seul un borborygme s'échappe alors que vous voyez vos compagnons prendre leurs jambes à leur cou."
	],
	SOLS.ATTACK_KNIFE: [
		"La créature vous bondit dessus et vous met à terre. Vous sortez votre couteau et parvenez à la repousser. Elle s'enfuit.",
		"La créature vous bondit dessus et vous met à terre. Vous sortez votre couteau et frappez... dans le vide. Son coup de griffes vous atteint au bras et elle s'enfuit au moment où vous arrivez à l'atteindre avec votre arme."
	],
	SOLS.ATTACK_OTHER: [
		"Vous faites un pas de côté au moment où la bête vous saute dessus. Profitant qu'elle soit désabilisée, vous la frappez avec votre outil. Elle prend peur et s'enfuit.",
		"Vous faites un pas de côté au moment où la bête vous saute dessus. Mais elle est plus rapide que vous, et vous avez à peine le temps d'attraper votre outil qu'elle est déjà en train de déchirer votre gorge alors que vos compagnons vous abandonnent à votre sort."
	],
	SOLS.CLIMB: [
		"Vous escaladez la paroi et arrivez de l'autre côté.",
		"Vous essayez d'escalader la paroi mais au moment de passer un endroit délicat, vous glissez et chutez."
	],
	SOLS.CUT: [
		"Vous espériez ne jamais avoir à faire ça, mais dans ce froid il n'y a qu'une chose à faire. Vous sortez votre couteau et coupez la corde. Vous entendez l'écho d'un cri."
	],
	SOLS.PULL: [
		"Malgré vos mains gelées, vous tirez de toutes vos forces sur la corde. Vous arrivez à remonter votre compagnon.",
		"Vos mains sont gelées et vos doigts engourdis. Vous tirez de toutes vos forces sur la corde mais elle vous glisse des mains. Vous entendez l'écho d'un cri."
	],
	SOLS.DIG_UP: [
		"Vous sortez votre pelle et passez plusieurs heures à creuser en hurlant le nom de votre compagnon. Vous finissez par le retrouver, miraculeusement sain et sauf.",
		"Vous sortez votre pelle et passez plusieurs heures à creuser en hurlant le nom de votre compagnon. Le froid finit par vous faire abandonner. Vous décidez de continuer sans lui."
	],
	SOLS.DIG: [
		"Après avoir creusé, vous trouvez un outil dans le campement abandonné.",
		"Vous n'avez rien trouvé."
	],
	SOLS.GO_AROUND: [
		"Vous prenez un chemin plus long mais plus sûr. Vous avez perdu un temps précieux et espérez arriver à temps."
	],
	SOLS.JUMP: [
		"Vous prenez votre élan et sautez par-dessus la crevasse. Vous n'accordez aucune attention aux mètres de vide sous vos pieds et arrivez de justesse à atteindre l'autre côté.",
		"Vous prenez votre élan et sentez votre pied glisser au moment où vous sautez par-dessus la crevasse. Vous avez le temps de sentir votre estomac se nouer avant de faire une chute de plusieurs mètres et de vous briser les jambes en contrebas."
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
			false: EVENTS.KILL,
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
			false: EVENTS.NO,
			true: EVENTS.NO,
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
			true: "J'entends des gens!"
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
			true: "Heureusement que nous avons une arme."
		},
		SOLS.ATTACK_KNIFE: {
			false: "Il m'a presque dévoré.",
			true: "Ce couteau m'a sauvé la vie."
		},
		SOLS.ATTACK_OTHER: {
			false: "Nous aurions mieux fait de fuir!",
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

var progress_dialogue = {
	"night" : [
		"Nous devons nous dépêcher!",
		"On risque de se blesser plus facilement pendant la nuit.",
		"Je n'y vois rien, c'est dur d'avancer."
	],
	"death" : {
		1 : [
			"Jamais je n’ai assisté à la mort de quelqu’un auparavant."
		],
		2 : [
			"C’est vous et moi maintenant.",
			"Cette mission devient pire à chaque heure!"
		],
		3 : [
			"Il ne reste que moi.",
			"Pourquoi moi?",
			"Tout repose sur moi maintenant.",
			"Vais-je mourir seul?"
		]
	},
	"distance" : {
		0 : [
			"Le moteur est mort. Nous n’avons pas le choix. Il faut continuer à pied et délivrer le message.",
			"Le message doit atteindre le sommet. Tout en dépend.",
			"Il ne reste plus que nous quatre. Vous vous souvenez tous du message?"
		],
		1 : [
			"J’espère qu’on y arrivera...",
			"On est encore loin"
		],
		2 : [
			"On dirait qu'on est à mi-chemin.",
			"Nous progressons."
		],
		3 : [
			"Je peux apercevoir le sommet d’ici!",
			"Je ne suis pas arrivé si loin pour mourir maintenant.",
			"On peut le faire!"
		]
	},
	"health" : {
		0 : [
			"On avance bien.",
			"On va y arriver avant la nuit."
		],
		1 : [
			"Je ne dirais pas non à une petite halte",
			"J'ai faim.",
			"Juste mettre un pied devant l'autre...",
			"Mes pieds commencent à geler"
		],
		2 : [
			"J'ai besoin de me reposer.",
			"J'ai mal aux jambes.",
			"Je meurs de faim.",
			"C'est trop difficile."
		],
		3 : [
			"Je n'en peux plus, arrêtons-nous, par pitié!",
			"Je suis à bout de souffle...",
			"Laissez-moi ici, je ne peux plus continuer.",
			"SEIGNEUR, AIDE MOI!"
		]
	}
}
