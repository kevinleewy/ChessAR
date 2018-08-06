var Deck = require('./deck.js');
var util = require('../shared/util.js');

const EMPTY = -1;
const MAXLIFE = 3;
const STARTINGHANDSIZE = 3;

function findAvailableSlot(field){
	var priority = [2, 1, 3, 0, 4];
	return priority.find(function(slot){
		return field[slot] == EMPTY;
	});
}

class Player {

	constructor(id){
		this.id = id;
		this.life = MAXLIFE;
		this.hand = [];
		this.deck = new Deck()
		for(var i = 0; i < STARTINGHANDSIZE; i++){
			this.hand.push(this.deck.removeFromTop());
		}

		this.field = [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY];
		this.eliminated = false;
	}

	getId(){
		return this.id;
	}

	getState() {
		var fieldState = [];
		this.field.forEach(function(creature){
			if(creature == EMPTY){
				fieldState.push(EMPTY);
			} else {
				fieldState.push(creature.getState());
			}
		});

		return {
			"id"	: this.id,
			"life"  : this.life,
			"hand"  : this.hand,
			"deck"  : this.deck.deckCount(),
			"field" : fieldState,
			"eliminated" : this.eliminated
		}
	}

	numberOfCardsInHand() {
		return this.hand.length;
	}

	hasCreatureOnField(slot) {
		return this.field[slot] != EMPTY;
	}

	hasAnyCreatureOnField() {
		for(var i=0; i<this.field.length; i++){
			if(this.field[i] != EMPTY) {
				console.log(i,this.field[i]);
				return true;
			}
		}
		return false;
	}


	shuffleDeck(){
		this.deck.shuffle();
	}

	draw(){
		if(this.deck.isEmpty()){
			throw 1203;
		}
		var newCardId = this.deck.removeFromTop();
		this.hand.push(newCardId);
		return newCardId;
	}

	play(handSlot, gameState){
		var cardId = this.hand[handSlot];
		this.hand.splice(handSlot, 1);
		var card = util.createCard(this.id, cardId, "EN");
		return card.play(this, gameState);
		/*if(cardId == 1){
			return this.playSpell(cardId);
		} else {
			return this.summon(cardId);
		}*/
	}
/*
	summon(cardId){
		var fieldSlot = findAvailableSlot(this.field);
		if(typeof fieldSlot === "undefined"){
			throw 1210;
		}

		this.field[fieldSlot] = cardId;
		return ["summon", this.id, fieldSlot, cardId];
	}

	playSpell(cardId){
		if(cardId == 1){
			var lifeGained = this.gainLife(1);
			return [
				"heal",
				this.id, //recipient of life
				lifeGained //amount gained
			];
		}
		throw 1200;
	}
*/
	gainLife(amount){
		var newLife = Math.min(MAXLIFE, this.life + amount);
		var lifeHealed = newLife - this.life;
		this.life = newLife
		return lifeHealed
	}

	loseLife(amount){
		var newLife = Math.max(0, this.life - amount);
		var lifeLost = this.life - newLife;
		this.life = newLife
		return lifeLost
	}

	destroyCreature(slot){
		this.field[slot] = EMPTY
		return true;
	}

	surrender(){
		this.life = 0;
	}

	isDead() {
		return this.life <= 0;
	}
}

module.exports = Player