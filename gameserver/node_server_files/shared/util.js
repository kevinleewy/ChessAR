var Creature = require('../models/creature.js');
var Spell    = require('../models/spell.js');
var cardData = require('../models/cardData.js');

module.exports = {

	randomXToY : function(minVal,maxVal) {
	  var randVal = minVal+(Math.random()*(maxVal-minVal));
	  return Math.round(randVal);
	},

	createCard : function(ownerId, cardId, lang) {
		var data = cardData(cardId, lang);
		switch(data["type"]){
			case "creature" :
				return new Creature(ownerId, cardId, data["strength"], data["life"], data["effect"]);
			case "spell" :
				return new Spell(ownerId, cardId, data["effect"]);
			default:
				throw 1211
		}
	}
}