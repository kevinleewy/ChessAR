class Card {

	constructor(owner, cardId, effect){
		this.owner  = owner;
		this.id     = cardId;
		this.effect = effect;
	}

	activate(player, gameState){
		if(typeof this.effect === "function"){
			return this.effect(player, gameState);
		}
	}

	
}

module.exports = Card