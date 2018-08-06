error_codes = {
	
	/**
	 *		GAME ROOM - PARTICIPANTS
	 */

	1001 : {
		"EN" : "This player ID is currently part of an existing game room",
	},

	1002 : {
		"EN" : "No game room exists for this player ID",
		"CN" : "此玩家ID不存在游戏",
	},

	1003 : {
		"EN" : "Game room already at maximum number of players",
	},

	1004 : {
		"EN" : "Game room already at maximum number of spectators",
	},

	1005 : {
		"EN" : "Not a player of this game room",
	},

	1006 : {
		"EN" : "Not a spectator of this game room",
	},

	1007 : {
		"EN" : "Neither a player nor spectator of this game room",
	},

	1008 : {
		"EN" : "Game room does not have enough players",
	},

	1009 : {
		"EN" : "Game room has too many players",
	},

	1010 : {
		"EN" : "Game room does not have enough spectators",
	},

	1011 : {
		"EN" : "Game room has too many spectators",
	},

	/**
	 *		GAME ROOM - GAME STATUS
	 */

	1100 : {
		"EN" : "Game state error",
	},

	1101 : {
		"EN" : "Game has not started",
	},

	1102 : {
		"EN" : "Game in progress",
	},

	1103 : {
		"EN" : "Game already ended",
	},

	1104 : {
		"EN" : "Not the leader of game room",
	},


	/**
	 *		GAME - ACTIONS
	 */

	1200 : {
		"EN" : "Invalid card ID",
	},

	1201 : {
		"EN" : "Invalid action",
	},

	1202 : {
		"EN" : "Not this players turn",
	},

	1203 : {
		"EN" : "No cards left in deck",
	},

	1204 : {
		"EN" : "Card not in hand",
	},

	1205 : {
		"EN" : "No creature in attacker slot",
	},

	1206 : {
		"EN" : "No creature in defender slot",
	},

	1207 : {
		"EN" : "Opponent still has defending creatures",
	},

	1208 : {
		"EN" : "Error finding target player",
	},

	1209 : {
		"EN" : "Invalid play event",
	},

	1210 : {
		"EN" : "No more room to summon creature",
	},

	1211 : {
		"EN" : "Invalid card type",
	},


	/**
	 *		CREATURE SPECIFIC
	 */

	1300 : {
		"EN" : "Invalid creature state",
	},

	1301 : {
		"EN" : "Already summoned",
	},

	1302 : {
		"EN" : "Creature position cannot be switched",
	},

	1303 : {
		"EN" : "Creature cannot be flipped",
	},

	1304 : {
		"EN" : "Creature cannot be set",
	},

}

module.exports = function(code, language) {
	if(code in error_codes){
		if(language in error_codes[code]){
			return error_codes[code][language];
		}
		return error_codes[code]["EN"];
	} else {
		console.error("Unknown error code: " + code);
		return code;
	}
}