var Card = require('./card.js');

//Creature States
CREATURE_STATE_OUT_OF_PLAY = 0;
CREATURE_STATE_SET = 1;
CREATURE_STATE_SUMMONED_ATTACK = 2;
CREATURE_STATE_SUMMONED_DEFENSE = 3;

const EMPTY = -1;

function findAvailableSlot(field){
	var priority = [2, 1, 3, 0, 4];
	return priority.find(function(slot){
		return field[slot] == EMPTY;
	});
}

class Creature extends Card {

	constructor(owner, cardId, strength, life, effect){
		super(owner, cardId, effect);
		this.strength = strength;
		this.life     = life;
		this.maxLife  = life;
		this.originalStrength = strength;
		this.originalMaxLife  = life;
		this.shield   = 0
		this.state    = CREATURE_STATE_OUT_OF_PLAY;
	}

	getState(){
		return {
			"id" : this.id,
			"strength" : this.strength,
			"life" : this.life,
			"shield" : this.shield
		}
	}

	play(player, gameState){
		return this.summon(player);
	}

	summon(player){
		var fieldSlot = findAvailableSlot(player.field);
		if(typeof fieldSlot === "undefined"){
			throw 1210;
		}

		
		//Update card state
		switch(this.state){
			case CREATURE_STATE_SUMMONED_ATTACK:
			case CREATURE_STATE_SUMMONED_DEFENSE:
				throw 1301;
			case CREATURE_STATE_OUT_OF_PLAY:
			case CREATURE_STATE_SET:
				this.state = CREATURE_STATE_SUMMONED_ATTACK;
				break;
			default:
				throw 1300;
		}

		player.field[fieldSlot] = this;	//add creature to the field
		return ["summon", player.id, fieldSlot, this.id];
	}

	set(player){
		var fieldSlot = findAvailableSlot(player.field);
		if(typeof fieldSlot === "undefined"){
			throw 1210;
		}

		//Update card state
		switch(this.state){
			case CREATURE_STATE_SUMMONED_ATTACK:
			case CREATURE_STATE_SUMMONED_DEFENSE:
			case CREATURE_STATE_OUT_OF_PLAY:
				this.state = CREATURE_STATE_SET;
				break;
			case CREATURE_STATE_SET:
				throw 1304;
			default:
				throw 1300;
		}

		player.field[fieldSlot] = this;	//add creature to the field
		return ["set", player.id, fieldSlot, this.id];
	}

	switchPosition(){
		switch(this.state){
			case CREATURE_STATE_SUMMONED_ATTACK:
				this.state = CREATURE_STATE_SUMMONED_DEFENSE;
				break;
			case CREATURE_STATE_SUMMONED_DEFENSE:
				this.state = CREATURE_STATE_SUMMONED_ATTACK;
				break;
			case CREATURE_STATE_OUT_OF_PLAY:
			case CREATURE_STATE_SET:
				throw 1302;
			default:
				throw 1300;
		}
		return ["creatureSwitchPosition", player.id, fieldSlot, this.id];
	}

	flip(){
		switch(this.state){
			case CREATURE_STATE_SUMMONED_ATTACK:
				this.state = CREATURE_STATE_SET;
				break;
			case CREATURE_STATE_SET:
				this.state = CREATURE_STATE_SUMMONED_DEFENSE;
				break;
			case CREATURE_STATE_OUT_OF_PLAY:
			case CREATURE_STATE_SUMMONED_DEFENSE:
				throw 1303;
			default:
				throw 1300;
		}
		return ["creatureFlip", player.id, fieldSlot, this.id];
	}

	loseLife(amount){
		var newLife = Math.max(0, this.life - amount);
		var lifeLost = this.life - newLife;
		this.life = newLife
		return ["creatureFlip", player.id, fieldSlot, this.id, lifeLost];
	}

	
}

module.exports = Creature