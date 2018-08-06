var Player = require('./player.js');
var util = require('../shared/util.js');

class Game {

	constructor(playerIds){
		var self = this //for reference inside forEach
		this.players = [];
		playerIds.forEach(function(id){
			self.players.push(new Player(id));
		});
		this.turnPlayerIndex = util.randomXToY(0, this.players.length-1);
		this.stack = [];
	}

	getState(id){
		var playerStates = [];

		this.players.forEach(function(player){
			playerStates.push(player.getState());
		});

		return {
			"players" : playerStates,
			"turnPlayer" : this.players[this.turnPlayerIndex].id,
			"stack" : this.stack
		}
	}

	draw(playerId){
		if(!this.isTurnPlayer(playerId)){
			throw 1202;
		}

		try {
			var newCard = this.players[this.turnPlayerIndex].draw();

			return [{
				"event"		: "draw",
				"playerId" 	: this.players[this.turnPlayerIndex].id,
				"newCard"	: newCard
			}]
		} catch (err) {
			if(err === 1203){
				var thisPlayerIndex = this.turnPlayerIndex;
				this.players[thisPlayerIndex].eliminated = true;
				do {
					this.turnPlayerIndex = (this.turnPlayerIndex + 1) % this.players.length;
				} while (this.players[this.turnPlayerIndex].eliminated)
				return [
					{
						"event" : "eliminated",
						"playerId" : playerId,
						"condition" : "deck out" 
					},
					{
						"event" : "startTurn",
						"playerId" : this.players[this.turnPlayerIndex].id,
					}
				];
			} else {
				throw err;
			}
		}
	}

	play(playerId, handCardSlot){
		if(!this.isTurnPlayer(playerId)){
			throw 1202;
		}
		if(handCardSlot >= this.players[this.turnPlayerIndex].numberOfCardsInHand()){
			throw 1204;
		}
		var events = [{
			"event"		: "play",
			"playerId" 	: this.players[this.turnPlayerIndex].id,
			"cardSlot"	: handCardSlot,
		}]
		var result = this.players[this.turnPlayerIndex].play(handCardSlot, this);
		switch(result[0]){
			case "summon" :
				events.push({
					"event"		: "summon",
					"playerId" 	: result[1],
					"fieldSlot"	: result[2],
					"cardId"	: result[3]
				});
				break;
			case "heal" :
				events.push({
					"event"		: "heal",
					"playerId" 	: result[1],
					"amount"	: result[2]
				});
				break;
			default :
				throw 1209;
		}
		return events;
	}

	attack(attackingPlayerId, attackerSlot, targetPlayerId, defenderSlot){
		if(!this.isTurnPlayer(attackingPlayerId)){
			throw 1202;
		}
		if(!this.players[this.turnPlayerIndex].hasCreatureOnField(attackerSlot)){
			throw 1205;
		}
		var targetPlayer = this.players.find(function(player){
			return player.id == targetPlayerId
		});
		if(targetPlayer == null){
			throw 1208;
		}
		if(!targetPlayer.hasCreatureOnField(defenderSlot)){
			throw 1206;
		}
		return [{
			"event"			  : "attack",
			"playerId" 		  : attackingPlayerId,
			"attackerSlot"	  : attackerSlot,
			"targetPlayerId"  : targetPlayerId,
			"defenderSlot"	  : defenderSlot,
			"targetDestroyed" : targetPlayer.destroyCreature(defenderSlot)
		}]
	}

	directAttack(attackingPlayerId, attackerSlot, targetPlayerId){
		if(!this.isTurnPlayer(attackingPlayerId)){
			throw 1202;
		}
		if(!this.players[this.turnPlayerIndex].hasCreatureOnField(attackerSlot)){
			throw 1205;
		}
		var targetPlayer = this.players.find(function(player){
			return player.id == targetPlayerId
		});
		if(targetPlayer == null){
			throw 1208;
		}
		if(targetPlayer.hasAnyCreatureOnField()){
			throw 1207;
		}
		var events = [{
			"event"			  : "directAttack",
			"playerId" 		  : attackingPlayerId,
			"attackerSlot"	  : attackerSlot,
			"targetPlayerId"  : targetPlayerId,
			"damageDealt"	  : targetPlayer.loseLife(1)
		}];
		if(targetPlayer.life == 0){
			events.push({
				"event" : "eliminated",
				"playerId" : targetPlayerId,
				"condition" : "0 life"
			});
		}
		return events;
	}

	isTurnPlayer(playerId){
		return playerId === this.players[this.turnPlayerIndex].id;
	}

	endTurn(playerId){
		if(!this.isTurnPlayer(playerId)){
			throw 1202;
		}
		
		do {
			this.turnPlayerIndex = (this.turnPlayerIndex + 1) % this.players.length;
		} while (this.players[this.turnPlayerIndex].eliminated)

		var nextPlayerId = this.players[this.turnPlayerIndex].id;

		var drawEvents = this.draw(nextPlayerId);

		var endTurnEvents = [
			{
				"event" : "endTurn",
				"playerId" : playerId
			},
			{
				"event" : "startTurn",
				"playerId" : nextPlayerId
			}
		];
		return endTurnEvents.concat(drawEvents);
	}

	surrender(playerId) {
		if(!this.isTurnPlayer(playerId)){
			throw 1202;
		}
		this.players[this.turnPlayerIndex].eliminated = true;
		return [
			{
				"event" : "eliminated",
				"playerId" : playerId,
				"condition" : "surrender"
			}
		];
	}

	hasEnded() {
		var result = null;
		var stillAlive = [];
 
		this.players.forEach(function(player){
			if(!player.eliminated){
				stillAlive.push(player.id);
			}
		});
		if(stillAlive.length == 0){
			return {
				"ended"  : true,
				"result" : "Draw"
			}
		}
		if(stillAlive.length == 1){
			return {
				"ended"  : true,
				"result" : stillAlive[0]
			}
		}
		return {
			"ended" : false
		}
	}

}

module.exports = Game;