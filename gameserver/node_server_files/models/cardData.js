card_data = {
	
	0 : {
		"name" : {
			"EN" : "Wolf"
		},
		"text" : {
			"EN" : ""
		},
		"type"  : "creature",
		"class" : "",
		"strength" : 2,
		"life" : 1,
		"effect" : function(player, gameState){ return; }

	},

	1 : {
		"name" : {
			"EN" : "Bear"
		},
		"text" : {
			"EN" : ""
		},
		"type"  : "spell",
		"class" : "",
		"strength" : 1,
		"life" : 2,
		"effect" : function(player, gameState){
			var lifeGained = player.gainLife(1);
			return [
				"heal",
				player.id, //recipient of life
				lifeGained //amount gained
			];
		}

	},

	2 : {
		"name" : {
			"EN" : "Dragon"
		},
		"text" : {
			"EN" : ""
		},
		"type"  : "creature",
		"class" : "",
		"strength" : 5,
		"life" : 5,
		"effect" : function(player, gameState){ return; }

	},

	3 : {
		"name" : {
			"EN" : "Ivysaur"
		},
		"text" : {
			"EN" : ""
		},
		"type"  : "creature",
		"class" : "",
		"strength" : 3,
		"life" : 4,
		"effect" : function(player, gameState){ return; }

	},

	10 : {
		"name" : {
			"EN" : "Potion"
		},
		"text" : {
			"EN" : ""
		},
		"type"  : "creature",
		"class" : "",
		"targetCount" : 1,
		"targetMask" : "",
		"effect" : function(player, gameState){ return; }

	},

}

module.exports = function(id, language) {
	if(id in card_data){
		var cardData = {};
		if(language in card_data[id]["name"]){
			cardData["name"] = card_data[id]["name"][language];
		} else {
			cardData["name"] = card_data[id]["name"]["EN"];
		}
		if(language in card_data[id]["text"]){
			cardData["text"] = card_data[id]["text"][language];
		} else {
			cardData["text"] = card_data[id]["text"]["EN"];
		}
		cardData["type"]     = card_data[id]["type"];
		cardData["class"]    = card_data[id]["class"];
		cardData["strength"] = card_data[id]["strength"];
		cardData["life"]     = card_data[id]["life"];
		cardData["effect"]   = card_data[id]["effect"];
		return cardData;
	} else {
		throw 1200;
	}
}