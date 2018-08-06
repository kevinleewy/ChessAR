var Card = require('./card.js');

//Spell States

class Spell extends Card {

	constructor(owner, cardId, effect){
		super(owner, cardId, effect);
	}

	play(player, gameState){
		return this.activate(player, gameState);
	}
	
}

module.exports = Spell